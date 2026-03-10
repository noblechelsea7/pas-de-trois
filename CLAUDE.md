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
      domain/
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

## Platform Notes

- **Android:** `android/app/src/main/kotlin/com/koreanproxy/korea_proxy/MainActivity.kt`
- **iOS:** `ios/Runner/`
- **Web:** `web/index.html`, `web/manifest.json`
- **Supabase Schema:** `supabase/schema.sql`
