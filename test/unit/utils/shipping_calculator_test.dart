import 'package:flutter_test/flutter_test.dart';
import 'package:korea_proxy/core/utils/shipping_calculator.dart';

void main() {
  group('ShippingCalculator.calculateBillableWeight', () {
    test('should_return_0_5_when_actual_weight_is_below_0_5_kg', () {
      expect(ShippingCalculator.calculateBillableWeight(0.1), 0.5);
      expect(ShippingCalculator.calculateBillableWeight(0.3), 0.5);
    });

    test('should_return_0_5_when_actual_weight_is_exactly_0_5_kg', () {
      expect(ShippingCalculator.calculateBillableWeight(0.5), 0.5);
    });

    test('should_return_1_0_when_actual_weight_is_between_0_5_and_1_0_kg', () {
      expect(ShippingCalculator.calculateBillableWeight(0.6), 1.0);
      expect(ShippingCalculator.calculateBillableWeight(0.9), 1.0);
    });

    test('should_return_1_0_when_actual_weight_is_exactly_1_0_kg', () {
      expect(ShippingCalculator.calculateBillableWeight(1.0), 1.0);
    });

    test('should_round_up_to_nearest_0_5_when_weight_exceeds_1_0_kg', () {
      // 1.1 → 1.5
      expect(ShippingCalculator.calculateBillableWeight(1.1), 1.5);
      // 1.5 → 1.5
      expect(ShippingCalculator.calculateBillableWeight(1.5), 1.5);
      // 1.6 → 2.0
      expect(ShippingCalculator.calculateBillableWeight(1.6), 2.0);
      // 2.3 → 2.5
      expect(ShippingCalculator.calculateBillableWeight(2.3), 2.5);
      // 3.0 → 3.0
      expect(ShippingCalculator.calculateBillableWeight(3.0), 3.0);
    });

    test('should_throw_when_weight_is_zero', () {
      expect(() => ShippingCalculator.calculateBillableWeight(0), throwsArgumentError);
    });

    test('should_throw_when_weight_is_negative', () {
      expect(() => ShippingCalculator.calculateBillableWeight(-0.5), throwsArgumentError);
    });
  });

  group('ShippingCalculator.calculateIntlFee', () {
    test('should_return_90_when_weight_is_0_3_kg_with_default_rate', () {
      // billable = 0.5 kg × 180 = 90
      expect(ShippingCalculator.calculateIntlFee(0.3), 90);
    });

    test('should_return_180_when_weight_is_0_5_kg_with_default_rate', () {
      // billable = 0.5 kg × 180 = 90
      expect(ShippingCalculator.calculateIntlFee(0.5), 90);
    });

    test('should_return_180_when_weight_is_0_8_kg_with_default_rate', () {
      // billable = 1.0 kg × 180 = 180
      expect(ShippingCalculator.calculateIntlFee(0.8), 180);
    });

    test('should_return_270_when_weight_is_1_3_kg_with_default_rate', () {
      // billable = 1.5 kg × 180 = 270
      expect(ShippingCalculator.calculateIntlFee(1.3), 270);
    });

    test('should_use_custom_rate_when_provided', () {
      // weight 1.0 kg, billable 1.0 kg, rate 200 → 200
      expect(ShippingCalculator.calculateIntlFee(1.0, ratePerKg: 200), 200);
    });

    test('should_throw_when_rate_is_zero', () {
      expect(
        () => ShippingCalculator.calculateIntlFee(1.0, ratePerKg: 0),
        throwsArgumentError,
      );
    });
  });
}
