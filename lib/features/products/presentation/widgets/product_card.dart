import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/shipping_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/price_calculator.dart';
import '../../../../core/utils/shipping_calculator.dart';
import '../../domain/models/product.dart';
import '../providers/product_providers.dart';

class ProductCard extends ConsumerWidget {
  const ProductCard({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(productSettingsProvider).valueOrNull ?? {};
    final intlRate = double.tryParse(settings['intl_shipping_rate_per_kg'] ?? '') ??
        ShippingConstants.defaultIntlShippingRatePerKg;

    final intlFee = ShippingCalculator.calculateIntlFee(
      product.weightKg,
      ratePerKg: intlRate,
    );
    final displayPrice = PriceCalculator.calculateDisplayPrice(
      twdPrice: product.twdPrice,
      koreaDomesticShippingFee: product.domesticShippingFee,
      internationalShippingFee: intlFee,
    );

    final imageUrl = product.images.isNotEmpty ? product.images.first.url : null;

    return InkWell(
      onTap: () => context.push('/products/${product.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image — 3:4 portrait, always fills card width
          AspectRatio(
            aspectRatio: 3 / 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(color: AppColors.surface),
                      errorWidget: (_, _, _) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.name,
            style: AppTextStyles.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'NT\$ $displayPrice',
            style: AppTextStyles.priceSmall,
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Icon(Icons.image_outlined, color: AppColors.border, size: 40),
      ),
    );
  }
}
