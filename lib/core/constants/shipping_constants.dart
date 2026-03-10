/// Shipping-related constants for Pas de trois.
/// Default values used when admin settings are not yet loaded.
abstract final class ShippingConstants {
  // International shipping
  static const double defaultIntlShippingRatePerKg = 180.0; // NT$/kg
  static const double minWeightUnit = 0.5; // kg — minimum chargeable weight unit
  static const double firstWeightThreshold = 1.0; // kg — under 1kg rounds to 1kg
  static const double halfKgThreshold = 0.5; // kg — under 0.5kg rounds to 0.5kg

  // Taiwan domestic shipping (NT$)
  static const int convenienceStoreShippingFee = 60;
  static const int homeDeliveryShippingFee = 100;
  static const int defaultFreeShippingThreshold = 3000; // NT$

  // Proxy fee tiers
  static const int proxyFeeFixedThreshold = 800; // twd_price ≤ 800
  static const int proxyFeeFixed = 120; // NT$
  static const int proxyFeeTier1Threshold = 1000; // twd_price ≤ 1000
  static const double proxyFeeTier1Rate = 0.15; // 15%
  static const int proxyFeeTier2Threshold = 3000; // twd_price ≤ 3000
  static const double proxyFeeTier2Rate = 0.12; // 12%
  static const double proxyFeeTier3Rate = 0.10; // 10%

  // Default exchange rate (KRW → TWD), fallback only
  static const double defaultExchangeRate = 25.0;
}
