-- ============================================================
-- Pas de trois — Supabase Schema
-- Platform: Korean Proxy Shopping
-- ============================================================

-- Enable required extensions
create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- ============================================================
-- ENUMS
-- ============================================================

create type order_status as enum (
  '待付款',
  '備貨中',
  '韓國處理中',
  '空運回台中',
  '台灣配送中',
  '已完成'
);

create type user_role as enum ('customer', 'admin');

create type shipping_method as enum ('convenience_store', 'home_delivery');

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

-- RLS
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

-- Seed default categories
insert into categories (name, slug, sort_order) values
  ('BEST', 'best', 1),
  ('NEW', 'new', 2),
  ('上衣', 'tops', 3),
  ('外套', 'outerwear', 4),
  ('褲子', 'bottoms', 5),
  ('配件', 'accessories', 6);

-- ============================================================
-- PRODUCTS
-- ============================================================

create table products (
  id                      uuid primary key default uuid_generate_v4(),
  category_id             uuid references categories(id) on delete set null,
  name                    text not null,
  description             text,
  size_info               text,
  krw_price               integer not null,
  twd_price               integer not null,
  weight_kg               numeric(6, 3) not null,
  domestic_shipping_fee   integer not null default 0,
  purchase_count          integer not null default 0,
  source_url              text,
  social_link             text,
  brand_name              text,
  image_url               text,
  is_active               boolean not null default true,
  created_at              timestamptz not null default now()
);

alter table products enable row level security;

create policy "products_read_active"
  on products for select
  using (is_active = true or (
    exists (
      select 1 from profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  ));

create policy "products_write_admin"
  on products for all
  using (
    exists (
      select 1 from profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

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

-- Trigger: ensure only one default address per user
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
-- WISHLIST
-- ============================================================

create table wishlist (
  id          uuid primary key default uuid_generate_v4(),
  user_id     uuid not null references profiles(id) on delete cascade,
  product_id  uuid not null references products(id) on delete cascade,
  created_at  timestamptz not null default now(),
  unique (user_id, product_id)
);

alter table wishlist enable row level security;

create policy "wishlist_own"
  on wishlist for all
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
  user_id           uuid not null references profiles(id) on delete restrict,
  order_number      text not null unique,
  status            order_status not null default '待付款',
  shipping_method   shipping_method not null,
  shipping_fee      integer not null default 0,
  total_amount      integer not null,
  address_snapshot  jsonb not null,
  note              text,
  created_at        timestamptz not null default now()
);

alter table orders enable row level security;

create policy "orders_select_own"
  on orders for select
  using (auth.uid() = user_id);

create policy "orders_insert_own"
  on orders for insert
  with check (auth.uid() = user_id);

create policy "orders_admin"
  on orders for all
  using (
    exists (
      select 1 from profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- Generate order number: PDT-YYYYMMDD-XXXXXX
create or replace function generate_order_number()
returns text language plpgsql as $$
declare
  v_date text := to_char(now(), 'YYYYMMDD');
  v_rand text := upper(substring(md5(random()::text) from 1 for 6));
begin
  return 'PDT-' || v_date || '-' || v_rand;
end;
$$;

-- Trigger: auto-generate order number
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
  quantity          integer not null check (quantity >= 1),
  unit_price        integer not null,
  created_at        timestamptz not null default now()
);

alter table order_items enable row level security;

create policy "order_items_via_order"
  on order_items for select
  using (
    exists (
      select 1 from orders o
      where o.id = order_id and o.user_id = auth.uid()
    )
  );

create policy "order_items_admin"
  on order_items for all
  using (
    exists (
      select 1 from profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

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

-- Trigger: auto-log status change
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
  id          uuid primary key default uuid_generate_v4(),
  title       text not null,
  content     text not null,
  is_active   boolean not null default true,
  created_at  timestamptz not null default now()
);

alter table announcements enable row level security;

create policy "announcements_read_active"
  on announcements for select
  using (is_active = true or (
    exists (
      select 1 from profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  ));

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

-- Seed default pages
insert into pages (key, title, content) values
  ('how-to-buy', '購買須知', E'## 購買流程\n1. 瀏覽商品，加入購物車\n2. 填寫收件資訊\n3. 確認訂單，完成付款\n4. 等待代購方購買並寄出\n5. 收到商品\n\n## 注意事項\n- 代購商品以韓國當地庫存為準\n- 下單後約 10-14 個工作天到貨\n- 如有問題請聯繫客服'),
  ('faq', '常見問題', E'## 常見問題\n\n**Q: 運費怎麼計算？**\nA: 國際運費已包含在商品價格中，台灣境內配送另計。\n\n**Q: 可以退換貨嗎？**\nA: 商品有明顯瑕疵可於收貨後 3 天內申請退換。\n\n**Q: 多久會到貨？**\nA: 下單後約 10-14 個工作天。'),
  ('return-policy', '退換貨政策', E'## 退換貨說明\n\n商品有明顯瑕疵（非人為損壞）可於收貨後 3 天內聯繫客服申請退換。\n\n以下情況恕不受理：\n- 人為損壞\n- 使用後商品\n- 主觀因素（尺寸、顏色偏差）\n\n退換處理時間約 7-14 個工作天。')
on conflict (key) do nothing;

-- Migration: add is_published column to pages (run if upgrading from initial schema)
-- ALTER TABLE pages ADD COLUMN IF NOT EXISTS is_published boolean not null default true;
-- UPDATE pages SET is_published = true WHERE is_published IS NULL;

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

-- Seed default settings
insert into settings (key, value) values
  ('exchange_rate', '25.0'),
  ('intl_shipping_rate_per_kg', '180'),
  ('free_shipping_threshold', '3000'),
  ('delivery_days', '10-14');

-- ============================================================
-- INDEXES for performance
-- ============================================================

create index idx_products_category on products(category_id);
create index idx_products_is_active on products(is_active);
create index idx_product_images_product on product_images(product_id);
create index idx_cart_items_user on cart_items(user_id);
create index idx_wishlist_user on wishlist(user_id);
create index idx_orders_user on orders(user_id);
create index idx_orders_status on orders(status);
create index idx_order_items_order on order_items(order_id);
create index idx_order_status_logs_order on order_status_logs(order_id);
create index idx_addresses_user on addresses(user_id);
