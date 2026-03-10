import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/shipping_constants.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/price_calculator.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/shipping_calculator.dart';
import '../../../products/domain/models/product.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../providers/cart_providers.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartItemsProvider); // Map<String, CartItem>
    final isWeb = AppBreakpoints.isWeb(context);
    final hPad = isWeb ? 24.0 : 16.0;

    if (cartItems.isEmpty) {
      return _EmptyCart(hPad: hPad);
    }

    return _CartContent(cartItems: cartItems, hPad: hPad);
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.hPad});
  final double hPad;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          pinned: true,
          title: const Text('購物車'),
        ),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 72,
                  color: AppColors.border,
                ),
                const SizedBox(height: 16),
                Text(
                  '購物車是空的',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '快去挑選喜歡的韓國商品吧',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 160,
                  child: OutlinedButton(
                    onPressed: () => context.go(RoutePaths.products),
                    child: const Text('去逛逛'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Cart content (has items)
// ---------------------------------------------------------------------------

class _CartContent extends ConsumerWidget {
  const _CartContent({required this.cartItems, required this.hPad});
  final Map<String, CartItem> cartItems;
  final double hPad;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(productSettingsProvider).valueOrNull ?? {};
    final intlRate =
        double.tryParse(settings[AppConstants.settingIntlShippingRate] ?? '') ??
            ShippingConstants.defaultIntlShippingRatePerKg;
    final freeThreshold =
        int.tryParse(settings[AppConstants.settingFreeShippingThreshold] ?? '') ??
            ShippingConstants.defaultFreeShippingThreshold;

    // Resolve each productId → AsyncValue<Product>
    final productAsyncMap = {
      for (final item in cartItems.values)
        item.productId: ref.watch(productByIdProvider(item.productId)),
    };

    final isLoading = productAsyncMap.values.any((a) => a.isLoading);

    // Build resolved list: only items whose product data loaded
    final resolvedItems = cartItems.values
        .where((item) =>
            productAsyncMap[item.productId]?.hasValue == true)
        .map((item) => (
              cartItem: item,
              product: productAsyncMap[item.productId]!.requireValue,
            ))
        .toList();

    // Calculate totals
    int subtotal = 0;
    for (final entry in resolvedItems) {
      final intlFee = ShippingCalculator.calculateIntlFee(
        entry.product.weightKg,
        ratePerKg: intlRate,
      );
      final unitPrice = PriceCalculator.calculateDisplayPrice(
        twdPrice: entry.product.twdPrice,
        koreaDomesticShippingFee: entry.product.domesticShippingFee,
        internationalShippingFee: intlFee,
      );
      subtotal += unitPrice * entry.cartItem.quantity;
    }

    final taiwanShipping = subtotal >= freeThreshold
        ? 0
        : ShippingConstants.convenienceStoreShippingFee;
    final total = subtotal + taiwanShipping;

    return CustomScrollView(
      slivers: [
        // App bar
        SliverAppBar(
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          pinned: true,
          title: const Text('購物車'),
          actions: [
            TextButton(
              onPressed: resolvedItems.isEmpty
                  ? null
                  : () => ref.read(cartItemsProvider.notifier).clear(),
              child: Text(
                '清空',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),

        // Loading overlay
        if (isLoading)
          const SliverToBoxAdapter(
            child: LinearProgressIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              minHeight: 2,
            ),
          ),

        // Item list
        SliverPadding(
          padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final entry = resolvedItems[index];
                return _CartItemRow(
                  product: entry.product,
                  cartItem: entry.cartItem,
                  intlRate: intlRate,
                  onIncrease: () => ref
                      .read(cartItemsProvider.notifier)
                      .updateQuantity(
                        entry.cartItem.key,
                        entry.cartItem.quantity + 1,
                      ),
                  onDecrease: () => ref
                      .read(cartItemsProvider.notifier)
                      .updateQuantity(
                        entry.cartItem.key,
                        entry.cartItem.quantity - 1,
                      ),
                  onRemove: () => ref
                      .read(cartItemsProvider.notifier)
                      .remove(entry.cartItem.key),
                );
              },
              childCount: resolvedItems.length,
            ),
          ),
        ),

        // Order summary
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 48),
            child: _OrderSummary(
              subtotal: subtotal,
              taiwanShipping: taiwanShipping,
              total: total,
              freeThreshold: freeThreshold,
              isFreeShipping: taiwanShipping == 0,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Single cart item row
// ---------------------------------------------------------------------------

class _CartItemRow extends ConsumerWidget {
  const _CartItemRow({
    required this.product,
    required this.cartItem,
    required this.intlRate,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  final Product product;
  final CartItem cartItem;
  final double intlRate;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intlFee = ShippingCalculator.calculateIntlFee(
      product.weightKg,
      ratePerKg: intlRate,
    );
    final unitPrice = PriceCalculator.calculateDisplayPrice(
      twdPrice: product.twdPrice,
      koreaDomesticShippingFee: product.domesticShippingFee,
      internationalShippingFee: intlFee,
    );
    final itemTotal = unitPrice * cartItem.quantity;
    final imageUrl = product.images.isNotEmpty ? product.images.first.url : null;

    // Build variant label e.g. "M・黑"
    final variantLabel = cartItem.selectedVariants.values.join('・');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          InkWell(
            onTap: () => context.push('/products/${product.id}'),
            child: SizedBox(
              width: 80,
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, _) =>
                              Container(color: AppColors.surface),
                          errorWidget: (_, _, _) =>
                              Container(color: AppColors.surface),
                        )
                      : Container(color: AppColors.surface),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Info + quantity
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + delete
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: AppTextStyles.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: onRemove,
                      icon: const Icon(Icons.close, size: 18),
                      color: AppColors.textHint,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                // Variant label
                if (variantLabel.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    variantLabel,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],

                const SizedBox(height: 4),

                // Unit price
                Text(
                  'NT\$ $unitPrice',
                  style: AppTextStyles.bodySmall,
                ),

                const SizedBox(height: 12),

                // Quantity stepper + item total
                Row(
                  children: [
                    _QuantityStepper(
                      quantity: cartItem.quantity,
                      onIncrease: onIncrease,
                      onDecrease: onDecrease,
                    ),
                    const Spacer(),
                    Text(
                      'NT\$ $itemTotal',
                      style: AppTextStyles.priceSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quantity stepper  (– | n | +)
// ---------------------------------------------------------------------------

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove,
            onTap: onDecrease,
          ),
          Container(
            width: 36,
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: AppTextStyles.titleMedium.copyWith(fontSize: 14),
            ),
          ),
          _StepButton(
            icon: Icons.add,
            onTap: onIncrease,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Icon(icon, size: 16, color: AppColors.textSecondary),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Order summary
// ---------------------------------------------------------------------------

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({
    required this.subtotal,
    required this.taiwanShipping,
    required this.total,
    required this.freeThreshold,
    required this.isFreeShipping,
  });

  final int subtotal;
  final int taiwanShipping;
  final int total;
  final int freeThreshold;
  final bool isFreeShipping;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(color: AppColors.divider),
        const SizedBox(height: 16),

        // Subtotal
        _SummaryRow(label: '商品小計', value: 'NT\$ $subtotal'),
        const SizedBox(height: 10),

        // Taiwan shipping
        _SummaryRow(
          label: '台灣國內運費',
          value: isFreeShipping ? '免運' : 'NT\$ $taiwanShipping',
          valueColor:
              isFreeShipping ? AppColors.success : AppColors.textSecondary,
          hint: isFreeShipping
              ? null
              : '滿 NT\$ $freeThreshold 免運，便利商店取貨',
        ),

        const SizedBox(height: 16),
        const Divider(color: AppColors.divider),
        const SizedBox(height: 16),

        // Total
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('合計', style: AppTextStyles.titleLarge),
            Text(
              'NT\$ $total',
              style: AppTextStyles.price.copyWith(fontSize: 20),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Checkout button
        ElevatedButton(
          onPressed: () => context.push(RoutePaths.checkout),
          child: const Text('前往結帳'),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.hint,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: valueColor ?? AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (hint != null) ...[
          const SizedBox(height: 2),
          Text(hint!, style: AppTextStyles.bodySmall),
        ],
      ],
    );
  }
}
