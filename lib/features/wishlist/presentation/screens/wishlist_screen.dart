import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/shipping_constants.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/price_calculator.dart';
import '../../../../core/utils/shipping_calculator.dart';
import '../../../products/domain/models/product.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../providers/wishlist_providers.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(wishlistProductsProvider);

    return CustomScrollView(
      controller: _scrollCtrl,
      slivers: [
        productsAsync.when(
          loading: () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => SliverFillRemaining(
            child: Center(child: Text('載入失敗：$e')),
          ),
          data: (products) => products.isEmpty
              ? SliverFillRemaining(
                  child: _EmptyState(
                    onBrowse: () => context.go(RoutePaths.products),
                  ),
                )
              : _WishlistGrid(products: products),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onBrowse});
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 64,
              color: colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              '還沒有收藏商品',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              '點擊商品頁的愛心加入收藏',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colorScheme.outline),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onBrowse,
              icon: const Icon(Icons.grid_view_rounded, size: 18),
              label: const Text('去逛逛'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(160, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Product grid
// ---------------------------------------------------------------------------

class _WishlistGrid extends StatelessWidget {
  const _WishlistGrid({required this.products});
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final isWeb = AppBreakpoints.isWeb(context);
    final columns = isWeb ? 4 : 2;
    const spacing = 8.0;
    final hPad = isWeb ? 24.0 : 16.0;

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 32),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: 0.62,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) => _WishlistCard(product: products[i]),
          childCount: products.length,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Wishlist card
// ---------------------------------------------------------------------------

class _WishlistCard extends ConsumerWidget {
  const _WishlistCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(productSettingsProvider).valueOrNull ?? {};
    final intlRate =
        double.tryParse(settings['intl_shipping_rate_per_kg'] ?? '') ??
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
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => context.push('/products/${product.id}'),
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image with remove button overlay
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 3 / 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, _) =>
                              Container(color: AppColors.surface),
                          errorWidget: (_, _, _) => _placeholder(),
                        )
                      : _placeholder(),
                ),
              ),
              // Remove button
              Positioned(
                top: 6,
                right: 6,
                child: _RemoveButton(productId: product.id),
              ),
            ],
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
            style: AppTextStyles.priceSmall.copyWith(
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.surface,
        child: const Center(
          child: Icon(Icons.image_outlined, color: AppColors.border, size: 40),
        ),
      );
}

// ---------------------------------------------------------------------------
// Remove button
// ---------------------------------------------------------------------------

class _RemoveButton extends ConsumerWidget {
  const _RemoveButton({required this.productId});
  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () async {
        try {
          await toggleWishlist(ref, productId, currentlyWished: true);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('移除失敗：$e')),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.88),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(
          Icons.close_rounded,
          size: 14,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}
