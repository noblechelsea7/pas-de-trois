import 'package:flutter_test/flutter_test.dart';
import 'package:korea_proxy/core/utils/price_calculator.dart';

void main() {
  group('PriceCalculator.convertKrwToTwd', () {
    test('should_convert_correctly_when_standard_rate', () {
      // 25000 KRW ÷ 25.0 = 1000 TWD
      expect(PriceCalculator.convertKrwToTwd(25000, 25.0), 1000);
    });

    test('should_round_to_nearest_integer_when_result_has_decimal', () {
      // 10000 KRW ÷ 25.3 ≈ 395.26 → 395
      expect(PriceCalculator.convertKrwToTwd(10000, 25.3), 395);
    });

    test('should_throw_when_exchange_rate_is_zero', () {
      expect(() => PriceCalculator.convertKrwToTwd(10000, 0), throwsArgumentError);
    });

    test('should_throw_when_exchange_rate_is_negative', () {
      expect(() => PriceCalculator.convertKrwToTwd(10000, -1), throwsArgumentError);
    });
  });

  group('PriceCalculator.calculateProxyFee', () {
    test('should_return_120_when_twd_price_is_800_or_below', () {
      expect(PriceCalculator.calculateProxyFee(500), 120);
      expect(PriceCalculator.calculateProxyFee(800), 120);
    });

    test('should_return_15_percent_when_twd_price_is_between_801_and_1000', () {
      // 900 × 15% = 135
      expect(PriceCalculator.calculateProxyFee(900), 135);
      // 1000 × 15% = 150
      expect(PriceCalculator.calculateProxyFee(1000), 150);
    });

    test('should_return_12_percent_when_twd_price_is_between_1001_and_3000', () {
      // 2000 × 12% = 240
      expect(PriceCalculator.calculateProxyFee(2000), 240);
      // 3000 × 12% = 360
      expect(PriceCalculator.calculateProxyFee(3000), 360);
    });

    test('should_return_10_percent_when_twd_price_exceeds_3000', () {
      // 5000 × 10% = 500
      expect(PriceCalculator.calculateProxyFee(5000), 500);
      // 10000 × 10% = 1000
      expect(PriceCalculator.calculateProxyFee(10000), 1000);
    });

    test('should_throw_when_twd_price_is_negative', () {
      expect(() => PriceCalculator.calculateProxyFee(-1), throwsArgumentError);
    });
  });

  group('PriceCalculator.calculateDisplayPrice', () {
    test('should_sum_all_components_correctly', () {
      // TWD 1000 → proxy fee 150 (15%)
      // Korea domestic: 200, intl: 180
      // Display = 1000 + 150 + 200 + 180 = 1530
      final result = PriceCalculator.calculateDisplayPrice(
        twdPrice: 1000,
        koreaDomesticShippingFee: 200,
        internationalShippingFee: 180,
      );
      expect(result, 1530);
    });

    test('should_use_fixed_proxy_fee_when_twd_price_is_low', () {
      // TWD 500 → proxy fee 120 (fixed)
      // Korea domestic: 100, intl: 90
      // Display = 500 + 120 + 100 + 90 = 810
      final result = PriceCalculator.calculateDisplayPrice(
        twdPrice: 500,
        koreaDomesticShippingFee: 100,
        internationalShippingFee: 90,
      );
      expect(result, 810);
    });
  });

  group('PriceCalculator.calculateTaiwanShippingFee', () {
    test('should_return_60_when_convenience_store_and_below_threshold', () {
      final fee = PriceCalculator.calculateTaiwanShippingFee(
        displayPrice: 1000,
        isConvenienceStore: true,
      );
      expect(fee, 60);
    });

    test('should_return_100_when_home_delivery_and_below_threshold', () {
      final fee = PriceCalculator.calculateTaiwanShippingFee(
        displayPrice: 1000,
        isConvenienceStore: false,
      );
      expect(fee, 100);
    });

    test('should_return_0_when_display_price_meets_free_shipping_threshold', () {
      final fee = PriceCalculator.calculateTaiwanShippingFee(
        displayPrice: 3000,
        isConvenienceStore: false,
        freeShippingThreshold: 3000,
      );
      expect(fee, 0);
    });

    test('should_return_0_when_display_price_exceeds_threshold', () {
      final fee = PriceCalculator.calculateTaiwanShippingFee(
        displayPrice: 5000,
        isConvenienceStore: true,
        freeShippingThreshold: 3000,
      );
      expect(fee, 0);
    });
  });

  group('PriceCalculator.calculateCheckoutTotal', () {
    test('should_add_display_price_and_taiwan_shipping', () {
      final total = PriceCalculator.calculateCheckoutTotal(
        displayPrice: 1530,
        taiwanShippingFee: 60,
      );
      expect(total, 1590);
    });

    test('should_equal_display_price_when_free_shipping', () {
      final total = PriceCalculator.calculateCheckoutTotal(
        displayPrice: 3200,
        taiwanShippingFee: 0,
      );
      expect(total, 3200);
    });
  });
}
