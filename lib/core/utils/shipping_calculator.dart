import '../constants/shipping_constants.dart';

/// International shipping fee calculation for Pas de trois.
///
/// Weight rounding rules:
///   weight < 0.5 kg  → charged as 0.5 kg
///   0.5 ≤ weight < 1.0 kg → charged as 1.0 kg
///   weight ≥ 1.0 kg  → round up to nearest 0.5 kg
abstract final class ShippingCalculator {
  /// Returns the billable weight in kg after applying rounding rules.
  static double calculateBillableWeight(double actualWeightKg) {
    if (actualWeightKg <= 0) {
      throw ArgumentError('Weight must be positive, got $actualWeightKg');
    }

    if (actualWeightKg <= ShippingConstants.halfKgThreshold) {
      return ShippingConstants.halfKgThreshold; // 0.5 kg
    }

    if (actualWeightKg <= ShippingConstants.firstWeightThreshold) {
      return ShippingConstants.firstWeightThreshold; // 1.0 kg
    }

    // Round up to nearest 0.5 kg
    return (actualWeightKg / ShippingConstants.minWeightUnit).ceil() *
        ShippingConstants.minWeightUnit;
  }

  /// Calculates the international shipping fee in TWD.
  ///
  /// [actualWeightKg] Actual product weight.
  /// [ratePerKg] NT$ per kg (admin setting, default 180).
  static int calculateIntlFee(
    double actualWeightKg, {
    double ratePerKg = ShippingConstants.defaultIntlShippingRatePerKg,
  }) {
    if (ratePerKg <= 0) {
      throw ArgumentError('Rate per kg must be positive, got $ratePerKg');
    }
    final billableWeight = calculateBillableWeight(actualWeightKg);
    return (billableWeight * ratePerKg).round();
  }
}
