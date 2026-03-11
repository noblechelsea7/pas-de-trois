# Pas de trois — 韓國精品代購平台

韓國精品代購電商平台，提供買家端購物流程與完整管理後台。

## 技術棧

| 類別 | 套件 |
|---|---|
| 框架 | Flutter 3.x（Web + Android + iOS） |
| 狀態管理 | flutter_riverpod 2.x + riverpod_annotation（@riverpod） |
| 導航 | go_router 14.x（StatefulShellRoute + ShellRoute） |
| 後端 | Supabase（Auth / Database / Storage / RLS） |
| 不可變模型 | freezed + json_serializable |
| 程式碼生成 | build_runner + riverpod_generator |

## 功能列表

### 買家端

- 商品瀏覽 / 搜尋 / 商品詳情
- 購物車（Web localStorage + 登入同步）
- 結帳（收件地址 / 配送方式選擇 / 訂單確認）
- 訂單列表 / 訂單詳情 / 訂單追蹤
- 個人中心（訂單狀態總覽、收件地址管理、個人資料編輯）
- 收藏清單（Wishlist）
- 前台公告顯示

### 管理後台（`/admin`，需管理員帳號）

- 管理總覽（今日訂單 / 待處理訂單 / 總會員數）
- 訂單管理（狀態更新、展開訂單明細 / 收件資訊 / 備註）
- 商品管理（新增 / 編輯 / 上下架）
- 會員管理（管理員切換 / 帳號封鎖 / 歷史訂單 / 備註）
- 系統設定（KRW/TWD 匯率 / 國際運費 / 免運門檻 / 首頁公告）

## 架構說明

```
MVVM + Clean Architecture + Feature-first
```

```
lib/
  core/
    config/        # AppConfig（編譯期環境變數）
    constants/     # AppConstants、ShippingConstants
    layout/        # WebNavBar、WebNavBarStandalone
    router/        # AppRouter（go_router）、RoutePaths
    theme/         # AppTheme、AppColors、AppTextStyles
    utils/         # PriceCalculator、ShippingCalculator、Responsive
  features/
    auth/          # 登入 / 註冊 / 個人中心
    products/      # 商品列表 / 詳情
    cart/          # 購物車
    orders/        # 訂單 / 結帳 / 地址
    wishlist/      # 收藏（實作中）
    admin/         # 管理後台
  shared/
    widgets/       # 跨 feature 共用元件
```

每個 feature 遵循三層分層：

```
data/
  datasources/   ← Supabase 原始呼叫
  repositories/  ← 實作 domain interface
domain/
  interfaces/    ← 抽象 Repository 介面
  models/        ← freezed 不可變模型
presentation/
  providers/     ← @riverpod 狀態
  screens/       ← ConsumerWidget 頁面
  widgets/       ← 頁面專屬子元件
```

## 本地執行步驟

### 1. 安裝依賴

```bash
flutter pub get
```

### 2. 設定環境變數

複製範本並填入你的 Supabase 憑證：

```bash
cp .env.example .env.json
```

編輯 `.env.json`：

```json
{
  "SUPABASE_URL": "https://your-project-id.supabase.co",
  "SUPABASE_ANON_KEY": "your-anon-key-here"
}
```

> 在 Supabase 後台 → Project Settings → API 取得這兩個值。

### 3. 執行

```bash
# Web（開發）
flutter run -d chrome --dart-define-from-file=.env.json

# Android
flutter run -d android --dart-define-from-file=.env.json

# iOS
flutter run -d ios --dart-define-from-file=.env.json
```

### 4. 程式碼生成（修改 freezed / riverpod 後執行）

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. 建置發布版

```bash
# Web
flutter build web --release --dart-define-from-file=.env.json

# Android APK
flutter build apk --release --dart-define-from-file=.env.json
```

### 6. 靜態分析

```bash
flutter analyze
```

### 7. 執行測試

```bash
flutter test
```

## VS Code 設定（選用）

在 `.vscode/launch.json` 加入，免得每次手動輸入 `--dart-define-from-file`：

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter (Web)",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": ["--dart-define-from-file=.env.json"]
    }
  ]
}
```

## 資料庫

Schema 定義於 `supabase/schema.sql`。
在 Supabase SQL Editor 執行該檔案以初始化所有資料表與 RLS 政策。

## 注意事項

- `.env.json` 已加入 `.gitignore`，請勿將真實憑證提交至版本控制
- 管理員帳號需在 Supabase 後台將 `profiles.role` 設為 `'admin'`
