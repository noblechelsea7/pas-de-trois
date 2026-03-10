/// Application-wide constants for Pas de trois.
abstract final class AppConstants {
  // Brand
  static const String brandName = 'Pas de trois';
  static const String brandNameFull = 'Pas de trois 代購';

  // Pagination
  static const int defaultPageSize = 20;

  // Image
  static const double productCardAspectRatio = 3 / 4;
  static const double bannerAspectRatio = 16 / 5;

  // Layout breakpoints (px)
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  // Web nav
  static const double webNavHeight = 64;
  static const double webNavMaxWidth = 1280;

  // Product grid
  static const int mobileGridColumns = 2;
  static const int desktopGridColumns = 4;
  static const double gridSpacing = 16;

  // Taiwan domestic shipping fees (NT$)
  static const int convenienceStoreShippingFee = 60;
  static const int homeDeliveryShippingFee = 100;

  // Order
  static const List<String> orderStatusList = [
    '待付款',
    '備貨中',
    '韓國處理中',
    '空運回台中',
    '台灣配送中',
    '已完成',
  ];

  // Categories (slug → display)
  static const Map<String, String> categoryLabels = {
    'best': 'BEST',
    'new': 'NEW',
    'tops': '上衣',
    'outerwear': '外套',
    'bottoms': '褲子',
    'accessories': '配件',
  };

  // Static pages keys
  static const String pagePurchaseGuide = 'purchase_guide';
  static const String pagePaymentInfo = 'payment_info';
  static const String pageShippingInfo = 'shipping_info';
  static const String pageReturnPolicy = 'return_policy';
  static const String pageRemittanceInfo = 'remittance_info';

  // Settings keys (Supabase settings table)
  static const String settingExchangeRate = 'exchange_rate';
  static const String settingIntlShippingRate = 'intl_shipping_rate_per_kg';
  static const String settingFreeShippingThreshold = 'free_shipping_threshold';
  static const String settingMaxQuantityPerItem = 'max_quantity_per_item';

  // Settings defaults (used while loading or if setting missing)
  static const int defaultMaxQuantityPerItem = 10;
}
