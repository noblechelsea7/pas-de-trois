import '../constants/shipping_constants.dart';

/// All monetary calculation logic for Pas de trois.
///
/// Rules:
/// - All input amounts in their natural unit (KRW, TWD, kg).
/// - All returned amounts are in TWD (NT$), rounded to the nearest integer.
/// - Never instantiate — use static methods only.
abstract final class PriceCalculator {
  /// Converts KRW price to TWD using the given exchange rate.
  ///
  /// [krwPrice] Korean Won price.
  /// [exchangeRate] KRW → TWD rate (e.g., 25.0 means 1 KRW = 1/25 TWD).
  static int convertKrwToTwd(int krwPrice, double exchangeRate) {
    if (exchangeRate <= 0) {
      throw ArgumentError('Exchange rate must be positive, got $exchangeRate');
    }
    return (krwPrice / exchangeRate).round();
  }

  /// Calculates the proxy service fee based on TWD price.
  ///
  /// Tiers:
  ///   twd ≤ 800  → fixed NT$120
  ///   twd ≤ 1000 → twd × 15%
  ///   twd ≤ 3000 → twd × 12%
  ///   twd > 3000 → twd × 10%
  static int calculateProxyFee(int twdPrice) {
    if (twdPrice < 0) {
      throw ArgumentError('TWD price must be non-negative, got $twdPrice');
    }

    if (twdPrice <= ShippingConstants.proxyFeeFixedThreshold) {
      return ShippingConstants.proxyFeeFixed;
    } else if (twdPrice <= ShippingConstants.proxyFeeTier1Threshold) {
      return (twdPrice * ShippingConstants.proxyFeeTier1Rate).round();
    } else if (twdPrice <= ShippingConstants.proxyFeeTier2Threshold) {
      return (twdPrice * ShippingConstants.proxyFeeTier2Rate).round();
    } else {
      return (twdPrice * ShippingConstants.proxyFeeTier3Rate).round();
    }
  }

  /// Calculates the display price shown on product page.
  ///
  /// Display Price = TWD Price + Proxy Fee + Korea Domestic Shipping + International Shipping
  ///
  /// [twdPrice] Product price in TWD (already converted from KRW).
  /// [koreaDomesticShippingFee] Fixed fee set by admin at product listing (NT$).
  /// [internationalShippingFee] Calculated via [ShippingCalculator.calculateIntlFee].
  static int calculateDisplayPrice({
    required int twdPrice,
    required int koreaDomesticShippingFee,
    required int internationalShippingFee,
  }) {
    final proxyFee = calculateProxyFee(twdPrice);
    return twdPrice + proxyFee + koreaDomesticShippingFee + internationalShippingFee;
  }

  /// Calculates the final checkout total.
  ///
  /// Checkout Total = Display Price + Taiwan Domestic Shipping
  ///
  /// [displayPrice] Sum from [calculateDisplayPrice].
  /// [taiwanShippingFee] 0 if free shipping threshold is met, otherwise 60 or 100.
  static int calculateCheckoutTotal({
    required int displayPrice,
    required int taiwanShippingFee,
  }) {
    return displayPrice + taiwanShippingFee;
  }

  /// Determines the Taiwan domestic shipping fee.
  ///
  /// Returns 0 if [displayPrice] ≥ [freeShippingThreshold].
  ///
  /// [isConvenienceStore] true → 60, false → 100.
  static int calculateTaiwanShippingFee({
    required int displayPrice,
    required bool isConvenienceStore,
    int freeShippingThreshold = ShippingConstants.defaultFreeShippingThreshold,
  }) {
    if (displayPrice >= freeShippingThreshold) return 0;
    return isConvenienceStore
        ? ShippingConstants.convenienceStoreShippingFee
        : ShippingConstants.homeDeliveryShippingFee;
  }
}
