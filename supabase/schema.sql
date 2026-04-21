-- ============================================================
-- Pas de trois — Supabase Schema
-- Platform: Korean Proxy Shopping
-- Version: v2.0（代購管理系統 × 代購網站 統一版）
-- Updated: 2026-04-21
-- ============================================================

-- Enable required extensions
create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- ============================================================
-- ENUMS
-- ============================================================

create type order_status as enum (
  '待付款',       -- 網站下單預設
  '待確認',       -- 後台手建預設
  '採買中',
  '集貨等待中',
  '運送中',
  '準備出貨',
  '已出貨',
  '完成',
  '已取消'
);

create type user_role as enum ('customer', 'admin');

create type shipping_method as enum (
  '7-11店到店',
  '全家店到店',
  '宅配',
  '面交',
  '其他'
);

create type order_source as enum (
  '網站',
  'IG',
  'Threads',
  'FB粉專',
  'FB社團',
  'Line',
  '其他'
);

-- ============================================================
-- SHARED FUNCTIONS
-- ============================================================

create or replace function update_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- ============================================================
-- PROFILES
-- Extends auth.users, created automatically via trigger.
-- ============================================================

create table profiles (
  id           uuid primary key references auth.users(id) on delete cascade,
  email        text not null,
  full_name    text,
  phone        text,
  role         user_role not null default 'customer',
  is_admin     boolean generated always as (role = 'admin') stored,
  is_active    boolean not null default true,
  admin_notes  text,
  points       integer not null default 0,
  created_at   timestamptz not null default now()
);

alter table profiles enable row level security;

create policy "profiles_select_own"
  on profiles for select
  using (auth.uid() = id);

create policy "profiles_update_own"
  on profiles for update
  using (auth.uid() = id);

create policy "profiles_select_admin"
  on profiles for select
  using (
    exists (
      select 1 from profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

create policy "profiles_update_admin"
  on profiles for update
  using (
    exists (
      select 1 from profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- Trigger: auto-create profile on signup
create or replace function handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles (id, email, full_name)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', '')
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- ============================================================
-- CUSTOMERS
-- 統一買家身份，涵蓋網站會員與各平台訪客
-- ============================================================

create table customers (
  id            uuid primary key default uuid_generate_v4(),
  phone         text unique,
  name          text,
  email         text,
  auth_user_id  uuid references auth.users(id) on delete set null,
  notes         text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

comment on table customers is '統一買家身份，涵蓋網站會員與各平台訪客';
comment on column customers.phone is '手機號碼，查詢入口，可更新，不作為永久識別鍵';
comment on column customers.auth_user_id is '若有網站帳號則關聯 auth.users，訪客為 null';

alter table customers enable row level security;

create policy "customers_authenticated_full" on customers
  for all to authenticated using (true) with check (true);

create policy "customers_anon_read" on customers
  for select to anon using (true);

create trigger customers_updated_at
  before update on customers
  for each row execute function update_updated_at();

-- Trigger: profiles.phone 更新時同步到 customers
create or replace function sync_customer_phone_from_profile()
returns trigger as $$
begin
  update customers
  set phone = new.phone,
      name  = coalesce(customers.name, new.full_name)
  where auth_user_id = new.id;
  return new;
end;
$$ language plpgsql security definer;

create trigger profiles_phone_sync
  after update of phone on profiles
  for each row
  when (old.phone is distinct from new.phone)
  execute function sync_customer_phone_from_profile();

-- Trigger: 新會員註冊時自動關聯或建立 customer
create or replace function sync_customer_on_profile_insert()
returns trigger as $$
begin
  if new.phone is not null then
    update customers
    set auth_user_id = new.id,
        name = coalesce(customers.name, new.full_name),
        updated_at = now()
    where phone = new.phone
      and auth_user_id is null;

    if not found then
      insert into customers (phone, name, auth_user_id)
      values (new.phone, new.full_name, new.id)
      on conflict (phone) do update
        set auth_user_id = new.id,
            updated_at = now();
    end if;
  end if;
  return new;
end;
$$ language plpgsql security definer;

create trigger profiles_insert_sync
  after insert on profiles
  for each row execute function sync_customer_on_profile_insert();

-- ============================================================
-- CATEGORIES
-- ============================================================

create table categories (
  id          uuid primary key default uuid_generate_v4(),
  name        text not null,
  slug        text not null unique,
  sort_order  integer not null default 0,
  is_active   boolean not null default true
);

alter table categories enable row level security;

create policy "categories_read_all"
  on categories for select using (true);

create policy "categories_write_admin"
  on categories for all
  using (
    exists (
      select 1 from profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

insert into categories (name, slug, sort_order) values
  ('BEST', 'best', 1),
  ('NEW', 'new', 2),
  ('上衣', 'tops', 3),
  ('外套', 'outerwear', 4),
  ('褲子', 'bottoms', 5),
  ('配件', 'accessories', 6);

-- ============================================================
-- BATCHES（採購批次）
-- ============================================================

create table batches (
  id                      uuid primary key default uuid_generate_v4(),
  name                    text not null,
  purchase_date           date,
  intl_shipping_cost_twd  integer default 0,
  notes                   text,
  created_at              timestamptz not null default now()
);

comment on table batches is '採購批次，一次寄貨 = 一個批次，國際運費以整批記錄';

alter table batches enable row level security;

create policy "batches_authenticated_full" on batches
  for all to authenticated using (true) with check (true);

-- ============================================================
-- PRODUCTS
-- ============================================================

create table products (
  id                    uuid primary key default uuid_generate_v4(),
  category_id           uuid references categories(id) on delete set null,
  batch_id              uuid references batches(id) on delete set null,
  name                  text not null,
  description           text,
  size_info             text,
  brand_name            text,
  image_url             text,
  variants              jsonb not null default '[]'::jsonb,
  krw_price             integer not null,
  twd_price             integer not null,
  cost_krw              integer,
  exchange_rate         numeric(6,4),
  cost_twd              integer,
  weight_kg             numeric(6,3) not null,
  domestic_shipping_fee integer not null default 0,
  stock_qty             integer default 0,
  purchase_count        integer not null default 0,
  source_url            text,
  social_link           text,
  is_active             boolean not null default true,
  is_published          boolean not null default false,
  created_at            timestamptz not null default now()
);

comment on column products.batch_id      is '所屬採購批次';
comment on column products.cost_krw      is '韓幣買價';
comment on column products.exchange_rate is '購入當下匯率，1 KRW = ? TWD';
comment on column products.cost_twd      is 'ROUND(cost_krw * exchange_rate)，可手動覆蓋';
comment on column products.stock_qty     is '進貨數量';
comment on column products.is_active     is '商品是否存在，false = 封存，管理後台幾乎不顯示';
comment on column products.is_published  is '是否在網站前台顯示，false = 後台可操作但前台看不到';

alter table products enable row level security;

create policy "products_anon_published" on products
  for select to anon
  using (is_published = true and is_active = true);

create policy "products_authenticated_full" on products
  for all to authenticated using (true) with check (true);

-- ============================================================
-- PRODUCT IMAGES
-- ============================================================

create table product_images (
  id          uuid primary key default uuid_generate_v4(),
  product_id  uuid not null references products(id) on delete cascade,
  url         text not null,
  sort_order  integer not null default 0,
  is_primary  boolean not null default false
);

alter table product_images enable row level security;

create policy "product_images_read_all"
  on product_images for select using (true);

create policy "product_images_write_admin"
  on product_images for all
  using (
    exists (
      select 1 from profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- ============================================================
-- ADDRESSES
-- ============================================================

create table addresses (
  id               uuid primary key default uuid_generate_v4(),
  user_id          uuid not null references profiles(id) on delete cascade,
  label            text not null default '預設',
  recipient_name   text not null,
  phone            text not null,
  address          text not null,
  is_default       boolean not null default false,
  created_at       timestamptz not null default now()
);

alter table addresses enable row level security;

create policy "addresses_own"
  on addresses for all
  using (auth.uid() = user_id);

create or replace function ensure_single_default_address()
returns trigger language plpgsql as $$
begin
  if new.is_default then
    update addresses
    set is_default = false
    where user_id = new.user_id and id != new.id;
  end if;
  return new;
end;
$$;

create trigger trg_single_default_address
  after insert or update on addresses
  for each row when (new.is_default = true)
  execute function ensure_single_default_address();

-- ============================================================
-- WISHLISTS
-- ============================================================

create table wishlists (
  id          uuid primary key default uuid_generate_v4(),
  user_id     uuid not null references profiles(id) on delete cascade,
  product_id  uuid not null references products(id) on delete cascade,
  created_at  timestamptz not null default now(),
  unique (user_id, product_id)
);

alter table wishlists enable row level security;

create policy "wishlists_own"
  on wishlists for all
  using (auth.uid() = user_id);

-- ============================================================
-- CART ITEMS
-- ============================================================

create table cart_items (
  id            uuid primary key default uuid_generate_v4(),
  user_id       uuid not null references profiles(id) on delete cascade,
  product_id    uuid not null references products(id) on delete cascade,
  quantity      integer not null default 1 check (quantity >= 1),
  variant_label text not null default '',
  created_at    timestamptz not null default now(),
  unique (user_id, product_id, variant_label)
);

alter table cart_items enable row level security;

create policy "cart_items_own"
  on cart_items for all
  using (auth.uid() = user_id);

-- ============================================================
-- ORDERS
-- ============================================================

create table orders (
  id                uuid primary key default uuid_generate_v4(),
  user_id           uuid references profiles(id) on delete restrict,  -- nullable：訪客下單
  customer_id       uuid references customers(id) on delete set null,
  order_number      text not null unique,
  status            order_status not null default '待確認',
  source            order_source not null default '網站',
  shipping_method   shipping_method not null,
  shipping_fee      integer not null default 0,
  total_amount      integer not null,
  address_snapshot  jsonb not null,
  pickup_code       text,
  note              text,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

comment on column orders.user_id     is '網站會員 FK，訪客下單為 null';
comment on column orders.customer_id is '統一買家身份 FK，網站會員與訪客都有';
comment on column orders.source      is '訂單來源平台';
comment on column orders.pickup_code is '店到店取件代碼或宅配追蹤碼';

alter table orders enable row level security;

create policy "orders_anon_read" on orders
  for select to anon using (true);

create policy "orders_authenticated_full" on orders
  for all to authenticated using (true) with check (true);

create trigger orders_updated_at
  before update on orders
  for each row execute function update_updated_at();

-- Generate order number: XX26-MMDDXXX
create or replace function generate_order_number()
returns text language plpgsql as $$
declare
  chars     text := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  alphanum  text := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  prefix    text := '';
  suffix    text := '';
  date_part text;
  result    text;
  attempts  integer := 0;
begin
  loop
    prefix := substr(chars, floor(random() * 26 + 1)::int, 1)
           || substr(chars, floor(random() * 26 + 1)::int, 1);
    prefix := prefix || to_char(now(), 'YY');
    date_part := to_char(now(), 'MMDD');
    suffix := substr(alphanum, floor(random() * 36 + 1)::int, 1)
           || substr(alphanum, floor(random() * 36 + 1)::int, 1)
           || substr(alphanum, floor(random() * 36 + 1)::int, 1);
    result := prefix || '-' || date_part || suffix;

    exit when not exists (select 1 from orders where order_number = result);

    attempts := attempts + 1;
    if attempts > 100 then
      raise exception '無法產生唯一訂單編號，請重試';
    end if;
  end loop;
  return result;
end;
$$;

create or replace function set_order_number()
returns trigger language plpgsql as $$
begin
  if new.order_number is null or new.order_number = '' then
    new.order_number := generate_order_number();
  end if;
  return new;
end;
$$;

create trigger trg_set_order_number
  before insert on orders
  for each row execute function set_order_number();

-- ============================================================
-- ORDER ITEMS
-- ============================================================

create table order_items (
  id                uuid primary key default uuid_generate_v4(),
  order_id          uuid not null references orders(id) on delete cascade,
  product_id        uuid references products(id) on delete set null,
  product_snapshot  jsonb not null,
  -- product_snapshot 須包含：
  -- { "name": "商品名稱", "spec": "規格", "batch_name": "批次", "cost_twd": 成本 }
  quantity          integer not null check (quantity >= 1),
  unit_price        integer not null,
  created_at        timestamptz not null default now()
);

alter table order_items enable row level security;

create policy "order_items_anon_read" on order_items
  for select to anon using (true);

create policy "order_items_authenticated_full" on order_items
  for all to authenticated using (true) with check (true);

-- ============================================================
-- ORDER STATUS LOGS
-- ============================================================

create table order_status_logs (
  id          uuid primary key default uuid_generate_v4(),
  order_id    uuid not null references orders(id) on delete cascade,
  status      order_status not null,
  note        text,
  created_at  timestamptz not null default now()
);

alter table order_status_logs enable row level security;

create policy "order_status_logs_via_order"
  on order_status_logs for select
  using (
    exists (
      select 1 from orders o
      where o.id = order_id and o.user_id = auth.uid()
    )
  );

create policy "order_status_logs_admin"
  on order_status_logs for all
  using (
    exists (
      select 1 from profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

create or replace function log_order_status_change()
returns trigger language plpgsql as $$
begin
  if (tg_op = 'INSERT') or (old.status is distinct from new.status) then
    insert into order_status_logs (order_id, status)
    values (new.id, new.status);
  end if;
  return new;
end;
$$;

create trigger trg_log_order_status
  after insert or update of status on orders
  for each row execute function log_order_status_change();

-- ============================================================
-- ANNOUNCEMENTS
-- ============================================================

create table announcements (
  id           uuid primary key default uuid_generate_v4(),
  title        text not null,
  content      text not null,
  is_published boolean not null default false,
  starts_at    timestamptz,
  ends_at      timestamptz,
  created_at   timestamptz not null default now()
);

alter table announcements enable row level security;

create policy "announcements_read_published"
  on announcements for select
  using (
    is_published = true
    and (starts_at is null or starts_at <= now())
    and (ends_at is null or ends_at >= now())
    or (
      exists (
        select 1 from profiles p
        where p.id = auth.uid() and p.role = 'admin'
      )
    )
  );

create policy "announcements_write_admin"
  on announcements for all
  using (
    exists (
      select 1 from profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- ============================================================
-- PAGES (static content)
-- ============================================================

create table pages (
  id           uuid primary key default uuid_generate_v4(),
  key          text not null unique,
  title        text not null,
  content      text not null default '',
  is_published boolean not null default true,
  updated_at   timestamptz not null default now()
);

alter table pages enable row level security;

create policy "pages_read_published"
  on pages for select
  using (is_published = true or (
    exists (
      select 1 from profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  ));

create policy "pages_write_admin"
  on pages for all
  using (
    exists (
      select 1 from profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

insert into pages (key, title, content) values
  ('how-to-buy', '購買須知', E'## 購買流程\n1. 瀏覽商品，加入購物車\n2. 填寫收件資訊\n3. 確認訂單，完成付款\n4. 等待代購方購買並寄出\n5. 收到商品\n\n## 注意事項\n- 代購商品以韓國當地庫存為準\n- 下單後約 10-14 個工作天到貨\n- 如有問題請聯繫客服'),
  ('faq', '常見問題', E'## 常見問題\n\n**Q: 運費怎麼計算？**\nA: 國際運費已包含在商品價格中，台灣境內配送另計。\n\n**Q: 可以退換貨嗎？**\nA: 商品有明顯瑕疵可於收貨後 3 天內申請退換。\n\n**Q: 多久會到貨？**\nA: 下單後約 10-14 個工作天。'),
  ('return-policy', '退換貨政策', E'## 退換貨說明\n\n商品有明顯瑕疵（非人為損壞）可於收貨後 3 天內聯繫客服申請退換。\n\n以下情況恕不受理：\n- 人為損壞\n- 使用後商品\n- 主觀因素（尺寸、顏色偏差）\n\n退換處理時間約 7-14 個工作天。')
on conflict (key) do nothing;

-- ============================================================
-- SETTINGS (key-value store)
-- ============================================================

create table settings (
  key    text primary key,
  value  text not null
);

alter table settings enable row level security;

create policy "settings_read_all"
  on settings for select using (true);

create policy "settings_write_admin"
  on settings for all
  using (
    exists (
      select 1 from profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

insert into settings (key, value) values
  ('exchange_rate', '25.0'),
  ('intl_shipping_rate_per_kg', '180'),
  ('free_shipping_threshold', '3000'),
  ('delivery_days', '10-14'),
  ('helper_pin', '1234');

-- ============================================================
-- VIEWS
-- ============================================================

-- 消費者查詢 view（不含金額）
create or replace view public.customer_order_view as
select
  o.order_number,
  o.status,
  o.shipping_method,
  o.pickup_code,
  o.source,
  o.updated_at,
  c.name    as customer_name,
  c.phone   as customer_phone,
  oi.product_snapshot->>'name'       as product_name,
  oi.product_snapshot->>'spec'       as product_spec,
  oi.product_snapshot->>'batch_name' as batch_name,
  oi.quantity
from orders o
join customers c on c.id = o.customer_id
join order_items oi on oi.order_id = o.id
where o.status != '已取消';

comment on view customer_order_view is '消費者查詢用，不含任何金額與成本';

-- 庫存計算 view
create or replace view public.product_stock_view as
select
  p.id,
  p.batch_id,
  b.name                    as batch_name,
  p.name,
  p.size_info               as spec,
  p.variants,
  p.cost_krw,
  p.exchange_rate,
  p.cost_twd,
  p.krw_price,
  p.twd_price,
  p.stock_qty,
  p.is_active,
  p.is_published,
  coalesce(sum(
    case when o.status != '已取消' then oi.quantity else 0 end
  ), 0)::integer             as sold_qty,
  greatest(0, p.stock_qty - coalesce(sum(
    case when o.status != '已取消' then oi.quantity else 0 end
  ), 0))::integer            as available_qty,
  p.created_at
from products p
left join batches b on b.id = p.batch_id
left join order_items oi on oi.product_id = p.id
left join orders o on o.id = oi.order_id
group by p.id, b.name;

comment on view product_stock_view is '商品含庫存計算，available_qty 排除已取消訂單';

-- 批次財務 view
create or replace view public.batch_finance_view as
select
  b.id                            as batch_id,
  b.name                          as batch_name,
  b.purchase_date,
  b.intl_shipping_cost_twd,
  count(distinct o.id)            as order_count,
  coalesce(sum(
    case when o.status != '已取消'
    then oi.unit_price * oi.quantity else 0 end
  ), 0)                           as revenue,
  coalesce(sum(
    case when o.status != '已取消'
    then oi.unit_price * oi.quantity else 0 end
  ), 0) +
  coalesce(sum(
    case when o.status != '已取消'
    then o.shipping_fee else 0 end
  ), 0)                           as revenue_with_shipping,
  coalesce(sum(
    case when o.status != '已取消'
    then (oi.product_snapshot->>'cost_twd')::integer * oi.quantity
    else 0 end
  ), 0)                           as cost,
  coalesce(sum(
    case when o.status != '已取消'
    then oi.unit_price * oi.quantity else 0 end
  ), 0) -
  coalesce(sum(
    case when o.status != '已取消'
    then (oi.product_snapshot->>'cost_twd')::integer * oi.quantity
    else 0 end
  ), 0) - b.intl_shipping_cost_twd as profit
from batches b
left join products p on p.batch_id = b.id
left join order_items oi on oi.product_id = p.id
left join orders o on o.id = oi.order_id
group by b.id;

comment on view batch_finance_view is '批次財務報表，profit 已扣除國際運費';

-- ============================================================
-- INDEXES for performance
-- ============================================================

create index idx_products_category   on products(category_id);
create index idx_products_batch      on products(batch_id);
create index idx_products_is_active  on products(is_active);
create index idx_products_published  on products(is_published);
create index idx_product_images_product on product_images(product_id);
create index idx_cart_items_user     on cart_items(user_id);
create index idx_wishlists_user      on wishlists(user_id);
create index idx_orders_user         on orders(user_id);
create index idx_orders_customer     on orders(customer_id);
create index idx_orders_status       on orders(status);
create index idx_order_items_order   on order_items(order_id);
create index idx_order_status_logs_order on order_status_logs(order_id);
create index idx_addresses_user      on addresses(user_id);
create index idx_customers_phone     on customers(phone);
create index idx_customers_auth_user on customers(auth_user_id);
