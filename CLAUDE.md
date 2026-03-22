# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Brand:** Pas de trois — Korean proxy shopping platform
**Platforms:** Flutter Web (primary) + Flutter App (secondary)
**Language:** Traditional Chinese (繁體中文)
**Style:** Korean minimalist luxury (SLOWAND-inspired)

- **Package name:** `korea_proxy`
- **Dart SDK:** ^3.11.0
- **Flutter:** 3.41.2

## Tech Stack

| Package | Purpose |
|---|---|
| flutter_riverpod + riverpod_annotation | State management |
| go_router | Navigation |
| supabase_flutter | Backend / Auth / Storage |
| freezed + freezed_annotation | Immutable models |
| json_serializable | JSON serialization |
| build_runner + riverpod_generator | Code generation |
| cached_network_image | Image caching |
| flutter_dotenv | Environment variables |

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run code generation (freezed, riverpod, json)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation
dart run build_runner watch --delete-conflicting-outputs

# Run the app
flutter run -d chrome        # Web
flutter run -d android       # Android
flutter run -d ios           # iOS

# Analyze code
flutter analyze

# Run all tests
flutter test

# Run a single test file
flutter test test/unit/utils/price_calculator_test.dart

# Build release
flutter build web --release
flutter build apk --release
```

## Architecture: Clean Architecture + Feature-first

```
lib/
  core/
    theme/           # AppTheme, colors, typography
    constants/       # AppConstants, ShippingConstants
    utils/           # PriceCalculator, ShippingCalculator
    router/          # AppRouter (go_router)
  features/
    auth/
      data/
        datasources/
        repositories/
      domain/
        models/
        interfaces/
      presentation/
        screens/
        widgets/
        providers/
    products/
      data/
        datasources/
        repositories/
      domain/
        models/
        interfaces/
      presentation/
        screens/
        widgets/
        providers/
    cart/
      data/
        datasources/     # SupabaseCartDataSource
        repositories/    # CartRepositoryImpl
      domain/
        models/          # CartItem
        interfaces/      # ICartRepository
      presentation/
    orders/
      data/
      domain/
      presentation/
    wishlist/
      data/
      domain/
      presentation/
    admin/
      data/
      domain/
      presentation/
  shared/
    widgets/

test/
  unit/
    utils/
      price_calculator_test.dart
      shipping_calculator_test.dart
  widget/
    products/
      product_card_test.dart
  integration/
    auth/
      login_flow_test.dart
```

## Design Specification

| Token | Value |
|---|---|
| Primary | `#8B1A33` (wine red) |
| Secondary | `#FFB3C1` (pink) |
| Background | `#FFFFFF` |
| Surface | `#FFF0F3` |
| Text | `#2D2D2D` |

## Price Formula

```
TWD Price = KRW Price ÷ Exchange Rate (admin setting)

Proxy Fee:
  twd_price ≤ 800  → fixed 120
  twd_price ≤ 1000 → twd_price × 15%
  twd_price ≤ 3000 → twd_price × 12%
  twd_price > 3000 → twd_price × 10%

Korea Domestic Shipping = set per product at listing time
International Shipping = weight_kg × rate_per_kg (admin, default 180)
  - weight < 0.5kg → charged as 0.5kg
  - 0.5kg < weight < 1.0kg → charged as 1.0kg
  - round up to nearest 0.5kg after 1.0kg

Display Price = TWD Price + Proxy Fee + Korea Domestic Shipping + International Shipping
Taiwan Domestic Shipping = 60 (convenience store) / 100 (home delivery)
                           Free shipping above threshold (admin setting)
Checkout Total = Display Price + Taiwan Domestic Shipping
```

## Order Status Flow

`待付款` → `備貨中` → `韓國處理中` → `空運回台中` → `台灣配送中` → `已完成`

## Dart Code Change Rule (MUST FOLLOW)

每次修改 Dart 程式碼後，必須執行 `dart analyze` 確認零錯誤才算完成。
若有錯誤必須自行修正後再回報。

## Coding Rules (MUST FOLLOW)

1. **ShellRoute 子頁面絕對不能有自己的 Scaffold**
2. **所有資料存取透過 Repository Pattern（依賴抽象介面）**
3. **Provider 命名：camelCase + Provider 結尾**
4. **頁面命名：PascalCase + Screen 結尾**
5. **使用 @riverpod 標註，不用舊式 Provider**
6. **所有金額計算邏輯統一放在 core/utils/price_calculator.dart**
7. **Web 版導覽列與 App 版底部導覽列分開處理**
8. **核心邏輯必須有對應單元測試**
9. **Feature 之間不互相 import，只透過 shared/ 溝通**
10. **Repository 隔離資料來源，UI 層不直接碰 Supabase**
11. **魔術數字統一放 core/constants/**
12. **測試命名：should_[預期結果]_when_[條件]**
13. **Web 版非 ShellRoute 子頁面（如商品詳情）需自行在 Scaffold body 加入 `WebNavBarStandalone()`，不會自動繼承頂部導覽列**
14. **循環依賴解法：將常數/路徑抽到獨立檔案（如 `route_paths.dart`），再由主檔用 `export` 重新匯出，讓既有 import 不受影響**
15. **跨頁面持久化的 notifier 使用 `@Riverpod(keepAlive: true)`** — 需要在 navigation 之間保留 state 的 notifier（如購物車）必須加 keepAlive，否則離開頁面時 state 會被 dispose 重置
16. **執行 build_runner 後必須將 generated files 一起 commit** — 每次執行 `dart run build_runner build` 之後，必須將以下檔案加入同一個 commit，否則 CI build 會失敗：
    - `*.freezed.dart`
    - `*.g.dart`
    - `*.gr.dart`

## Python 路徑

Windows 上執行 Python 腳本（包含 UI/UX Pro Max skill）請使用：

```bash
PYTHONIOENCODING=utf-8 "C:/Users/CHELSEA/AppData/Local/Programs/Python/Python312/python.exe" <script> <args>
```

不要使用 `python3` 或 `python` 指令，會呼叫到 Windows Store stub（exit code 49）。
`PYTHONIOENCODING=utf-8` 必須加上，否則輸出特殊字元時會發生 cp950 編碼錯誤。

---

## 已完成功能清單（2026-03-22 審視）

**前台**
- 首頁：Hero banner、首頁公告（from settings）、新品上架 grid、品牌特色區
- 商品列表：分類篩選、品牌名稱 + 商品名 + 價格卡片
- 商品詳情：桌面雙欄（55/45）、手機單欄、多圖輪播（箭頭 + 計數）、尺寸對照表（依分類）、可配置到貨天數、收藏心型、加入購物車 / 立即購買
- 購物車：查看、調整數量、刪除
- 結帳：地址填寫、配送方式選擇、訂單建立
- 訂單成功頁
- 我的訂單列表
- 訂單詳情：狀態時間軸、收件資訊、金額摘要
- 收藏清單
- 個人資料頁：訂單統計、訂單狀態快覽、選單
- 個人資料編輯、地址管理（透過 `/profile/address`）
- 登入 / 註冊 / 忘記密碼

**後台 Admin**
- Dashboard：今日訂單、待處理訂單、會員數統計卡、快速連結
- 商品管理：列表、新增 / 編輯 dialog（多圖上傳、品牌名稱、KRW→TWD 自動換算）、上下架切換
- 訂單管理：列表 + 展開查看明細（商品、收件人、備註）、狀態 dropdown 即時更新
- 會員管理：列表、查看訂單、切換 admin / 啟用狀態、備注
- 系統設定：匯率、國際運費、免運門檻、到貨天數、首頁公告文字

## 已知 Bug 與視覺問題

- **行動版 Profile 子頁 NavBar** — `/profile/edit`、`/profile/address` 嵌套在 `StatefulShellBranch` 內，行動版子頁面會顯示底部 NavBar。Web 版正常，行動版上線前需改為獨立頂層路由或動態隱藏 BottomNavigationBar
- **Hero banner 外部紋理圖** — `home_screen.dart` 抓 `transparenttextures.com`，網路不穩時 fallback 空白，應改為本地 asset 或移除
- **`_StatusChip` 重複定義** — `orders_screen.dart` 與 `order_detail_screen.dart` 各自有一份相同邏輯，應抽到 `shared/widgets/`

## 待實作功能（Placeholder 路由）

以下路由已定義在 `app_router.dart`，但頁面尚未實作（目前顯示 `_PlaceholderScreen`）：

優先順序：
- 🔴 `/page/:pageKey` — 靜態說明頁（購買須知、FAQ、退換貨政策等）
- 🔴 `/admin/dashboard/pages` — Admin 說明頁管理（搭配上方前台頁面）
- 🔴 `/admin/dashboard/announcements` — Admin 公告管理
- 🟠 `/announcements` — 前台公告列表頁（搭配 Admin 公告管理）
- 🟠 `/search` — 搜尋頁
- 🟢 `/admin/dashboard/orders/:orderId` — Admin 訂單詳情獨立頁（目前展開列已有基本資訊，低優先）

## 已知技術債

> MVP 階段暫緩補齊，優先完成功能開發。

- **orders 缺 data 層** — 目前邏輯在 provider 直接呼叫 Supabase，未經過 datasource / repository / interface 分層
- **admin 缺 domain models** — 系統設定目前以 `Map<String, String>` 傳遞，應抽出 `AdminSetting` 等 model
- **各 feature 缺 `presentation/widgets/` 資料夾** — 可重用子元件目前直接寫在 screen 檔案內，未拆分

## 套件升級（MVP 完成後整批處理）

> 以下三個套件有破壞性變更，必須同時升級，不要單獨升。

- **Riverpod 2.x → 3.x** — breaking changes，需整批遷移所有 providers
- **go_router 14.x → 17.x** — breaking API changes
- **freezed 2.x → 3.x** — breaking changes（含 freezed_annotation、riverpod_generator 同步升級）

## dart:html 廢棄（待處理）

- `web_history_web.dart` 第 2 行使用 `dart:html`
- Flutter 3.x 官方建議改用 `package:web` + `dart:js_interop`
- 目前用 `// ignore` 壓住，功能正常
- 等升級 Flutter 版本時一起處理

## Platform Notes

- **Android:** `android/app/src/main/kotlin/com/koreanproxy/korea_proxy/MainActivity.kt`
- **iOS:** `ios/Runner/`
- **Web:** `web/index.html`, `web/manifest.json`
- **Supabase Schema:** `supabase/schema.sql`
