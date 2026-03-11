import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/shipping_constants.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/price_calculator.dart';
import '../../../../core/utils/shipping_calculator.dart';
import '../../../../shared/widgets/wishlist_heart_button.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../domain/models/product.dart';
import '../providers/product_providers.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});
  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productByIdProvider(productId));

    return productAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (error, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('載入失敗', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.invalidate(productByIdProvider(productId)),
              child: const Text('重試'),
            ),
          ],
        ),
      ),
      data: (product) => _ProductDetail(product: product),
    );
  }
}

class _ProductDetail extends ConsumerStatefulWidget {
  const _ProductDetail({required this.product});
  final Product product;

  @override
  ConsumerState<_ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends ConsumerState<_ProductDetail> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
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

    final selectedVariants =
        ref.watch(selectedVariantsProvider(product.id));

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: CustomScrollView(
      slivers: [
        // Fixed-height image gallery
        SliverToBoxAdapter(
          child: SizedBox(
            height: 360,
            child: _ImageGallery(
              images: product.images,
              currentIndex: _currentImageIndex,
              pageController: _pageController,
              onPageChanged: (i) => setState(() => _currentImageIndex = i),
            ),
          ),
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + wishlist heart
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: AppTextStyles.headlineMedium,
                      ),
                    ),
                    WishlistHeartButton(
                      productId: product.id,
                      size: 24,
                      withBackground: false,
                      padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Final price only
                Text(
                  'NT\$ $displayPrice',
                  style: AppTextStyles.price.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 4),
                Text(
                  '含代購費、韓國及國際運費',
                  style: AppTextStyles.bodySmall,
                ),

                // Variant selectors
                if (product.variants.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  ...product.variants.map(
                    (variant) => _VariantSelector(
                      productId: product.id,
                      variant: variant,
                      selectedOption: selectedVariants[variant.name],
                      onSelect: (option) => ref
                          .read(selectedVariantsProvider(product.id).notifier)
                          .select(variant.name, option),
                    ),
                  ),
                ],

                // Quantity selector
                const SizedBox(height: 8),
                _QuantityRow(productId: product.id),

                const SizedBox(height: 24),

                // Size info
                if (product.sizeInfo != null) ...[
                  Text('尺寸資訊', style: AppTextStyles.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    product.sizeInfo!,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                ],

                // Description
                if (product.description != null) ...[
                  Text('商品說明', style: AppTextStyles.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    product.description!,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary, height: 1.7),
                  ),
                  const SizedBox(height: 24),
                ],

                // Weight info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.scale_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '商品重量 ${product.weightKg} kg',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
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
// Variant selector: label + option chips
// ---------------------------------------------------------------------------

class _VariantSelector extends StatelessWidget {
  const _VariantSelector({
    required this.productId,
    required this.variant,
    required this.selectedOption,
    required this.onSelect,
  });

  final String productId;
  final ProductVariant variant;
  final String? selectedOption;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(variant.name, style: AppTextStyles.titleMedium),
              if (selectedOption != null) ...[
                const SizedBox(width: 8),
                Text(
                  selectedOption!,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: variant.options.map((option) {
              final isSelected = selectedOption == option;
              return GestureDetector(
                onTap: () => onSelect(option),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    option,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected
                          ? AppColors.white
                          : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quantity row  – | n | +
// ---------------------------------------------------------------------------

class _QuantityRow extends ConsumerWidget {
  const _QuantityRow({required this.productId});
  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quantity = ref.watch(productDetailQuantityProvider(productId));
    final notifier = ref.read(productDetailQuantityProvider(productId).notifier);
    final settings = ref.watch(productSettingsProvider).valueOrNull ?? {};
    final maxQty = int.tryParse(
          settings[AppConstants.settingMaxQuantityPerItem] ?? '',
        ) ??
        AppConstants.defaultMaxQuantityPerItem;

    return Row(
      children: [
        Text('數量', style: AppTextStyles.titleMedium),
        const SizedBox(width: 16),
        Container(
          height: 36,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: quantity > 1 ? notifier.decrement : null,
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(
                    Icons.remove,
                    size: 16,
                    color: quantity > 1
                        ? AppColors.textSecondary
                        : AppColors.border,
                  ),
                ),
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  '$quantity',
                  style: AppTextStyles.titleMedium.copyWith(fontSize: 15),
                ),
              ),
              InkWell(
                onTap: quantity < maxQty ? notifier.increment : null,
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(
                    Icons.add,
                    size: 16,
                    color: quantity < maxQty
                        ? AppColors.textSecondary
                        : AppColors.border,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '（最多 $maxQty 件）',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Image gallery with PageView + dot indicator
// ---------------------------------------------------------------------------

class _ImageGallery extends StatelessWidget {
  const _ImageGallery({
    required this.images,
    required this.currentIndex,
    required this.pageController,
    required this.onPageChanged,
  });

  final List images;
  final int currentIndex;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(
        color: AppColors.surface,
        child: const Center(
          child: Icon(Icons.image_outlined, size: 80, color: AppColors.border),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: pageController,
          onPageChanged: onPageChanged,
          itemCount: images.length,
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: images[index].url as String,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: AppColors.surface),
              errorWidget: (_, _, _) => Container(
                color: AppColors.surface,
                child: const Center(
                  child: Icon(Icons.broken_image_outlined,
                      size: 48, color: AppColors.border),
                ),
              ),
            );
          },
        ),

        // Dot indicators
        if (images.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) {
                final selected = i == currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: selected ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : AppColors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Add to cart bottom bar — two buttons: add to cart | buy now
// ---------------------------------------------------------------------------

class ProductDetailBottomBar extends ConsumerWidget {
  const ProductDetailBottomBar({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedVariants = ref.watch(selectedVariantsProvider(product.id));
    final quantity = ref.watch(productDetailQuantityProvider(product.id));
    final allSelected = product.variants.every(
      (v) => selectedVariants.containsKey(v.name),
    );

    void showVariantWarning() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('請先選擇所有規格'),
          backgroundColor: AppColors.textSecondary,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }

    void addToCart() {
      ref.read(cartItemsProvider.notifier).add(
            product.id,
            selectedVariants: Map.from(selectedVariants),
            quantity: quantity,
          );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // 加入購物車
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                if (!allSelected) {
                  showVariantWarning();
                  return;
                }
                addToCart();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('已加入購物車'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.shopping_bag_outlined, size: 18),
              label: const Text('加入購物車'),
            ),
          ),
          const SizedBox(width: 12),
          // 直接購買
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (!allSelected) {
                  showVariantWarning();
                  return;
                }
                addToCart();
                context.push(RoutePaths.checkout);
              },
              child: const Text('直接購買'),
            ),
          ),
        ],
      ),
    );
  }
}
