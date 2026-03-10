import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'web_history_stub.dart'
    if (dart.library.html) 'web_history_web.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/shipping_constants.dart';
import '../../../../core/layout/web_nav_bar.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/price_calculator.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/shipping_calculator.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../providers/order_providers.dart';

// ---------------------------------------------------------------------------
// Shipping method enum
// ---------------------------------------------------------------------------

enum _ShippingMethod {
  convenienceStore(
    'convenience_store',
    '超商取貨',
    ShippingConstants.convenienceStoreShippingFee,
  ),
  homeDelivery(
    'home_delivery',
    '宅配到府',
    ShippingConstants.homeDeliveryShippingFee,
  );

  const _ShippingMethod(this.dbValue, this.label, this.baseFee);
  final String dbValue;
  final String label;
  final int baseFee;
}

const _kCities = [
  '台北市', '新北市', '桃園市', '台中市', '台南市', '高雄市',
  '基隆市', '新竹市', '嘉義市', '新竹縣', '苗栗縣', '彰化縣',
  '南投縣', '雲林縣', '嘉義縣', '屏東縣', '宜蘭縣', '花蓮縣',
  '台東縣', '澎湖縣', '金門縣', '連江縣',
];

// ---------------------------------------------------------------------------
// CheckoutScreen
// ---------------------------------------------------------------------------

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String? _selectedAddressId;
  bool _showAddressForm = false;
  _ShippingMethod _shippingMethod = _ShippingMethod.convenienceStore;
  bool _isSubmitting = false;
  String? _errorMessage;

  // Note
  final _noteController = TextEditingController();

  // Address form
  final _addressFormKey = GlobalKey<FormState>();
  final _labelController = TextEditingController(text: '預設');
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressDetailController = TextEditingController();
  String _selectedCity = _kCities.first;

  @override
  void dispose() {
    _noteController.dispose();
    _labelController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressDetailController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Place order
  // -------------------------------------------------------------------------

  Future<void> _placeOrder({
    required int subtotal,
    required int shippingFee,
    required int total,
    required List<Address> addresses,
  }) async {
    // Validate address
    Map<String, dynamic> addressSnapshot;
    if (_showAddressForm || addresses.isEmpty) {
      if (!_addressFormKey.currentState!.validate()) return;
      addressSnapshot = {
        'recipient_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': '$_selectedCity${_addressDetailController.text.trim()}',
      };
    } else {
      final addr = addresses.firstWhere(
        (a) => a.id == _selectedAddressId,
        orElse: () => addresses.first,
      );
      addressSnapshot = {
        'recipient_name': addr.recipientName,
        'phone': addr.phone,
        'address': addr.address,
      };
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final cartItems = ref.read(cartItemsProvider);
      final settings =
          ref.read(productSettingsProvider).valueOrNull ?? {};
      final intlRate =
          double.tryParse(
                settings[AppConstants.settingIntlShippingRate] ?? '',
              ) ??
              ShippingConstants.defaultIntlShippingRatePerKg;

      // Build items list
      final items = <Map<String, dynamic>>[];
      for (final cartItem in cartItems.values) {
        final productAsync =
            ref.read(productByIdProvider(cartItem.productId));
        if (!productAsync.hasValue) continue;
        final product = productAsync.requireValue;
        final intlFee = ShippingCalculator.calculateIntlFee(
          product.weightKg,
          ratePerKg: intlRate,
        );
        final unitPrice = PriceCalculator.calculateDisplayPrice(
          twdPrice: product.twdPrice,
          koreaDomesticShippingFee: product.domesticShippingFee,
          internationalShippingFee: intlFee,
        );
        items.add({
          'product_id': cartItem.productId,
          'product_snapshot': {
            'name': product.name,
            'selected_variants': cartItem.selectedVariants,
          },
          'quantity': cartItem.quantity,
          'unit_price': unitPrice,
        });
      }

      final orderId = await Supabase.instance.client.rpc(
        'create_order',
        params: {
          'p_shipping_method': _shippingMethod.dbValue,
          'p_shipping_fee': shippingFee,
          'p_total_amount': total,
          'p_address_snapshot': addressSnapshot,
          'p_note': _noteController.text.trim(),
          'p_items': items,
        },
      ) as String;

      // Clear cart
      ref.read(cartItemsProvider.notifier).clear();

      if (mounted) {
        // Replace checkout's browser history entry with /#/ before leaving,
        // so pressing back from success (or later pages) never returns here.
        replaceHistoryWithHome();
        context.go('/order-success/$orderId');
      }
    } catch (e) {
      setState(() => _errorMessage = '下單失敗，請稍後再試');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartItemsProvider);
    final addressesAsync = ref.watch(userAddressesProvider);
    final settings = ref.watch(productSettingsProvider).valueOrNull ?? {};
    final intlRate =
        double.tryParse(settings[AppConstants.settingIntlShippingRate] ?? '') ??
            ShippingConstants.defaultIntlShippingRatePerKg;
    final freeThreshold =
        int.tryParse(
              settings[AppConstants.settingFreeShippingThreshold] ?? '',
            ) ??
            ShippingConstants.defaultFreeShippingThreshold;

    // Resolve products & calculate subtotal
    final productAsyncMap = {
      for (final item in cartItems.values)
        item.productId: ref.watch(productByIdProvider(item.productId)),
    };

    int subtotal = 0;
    for (final cartItem in cartItems.values) {
      final pa = productAsyncMap[cartItem.productId];
      if (pa?.hasValue == true) {
        final p = pa!.requireValue;
        final fee = ShippingCalculator.calculateIntlFee(
          p.weightKg,
          ratePerKg: intlRate,
        );
        final price = PriceCalculator.calculateDisplayPrice(
          twdPrice: p.twdPrice,
          koreaDomesticShippingFee: p.domesticShippingFee,
          internationalShippingFee: fee,
        );
        subtotal += price * cartItem.quantity;
      }
    }

    final isFreeShipping = subtotal >= freeThreshold;
    final shippingFee = isFreeShipping ? 0 : _shippingMethod.baseFee;
    final total = subtotal + shippingFee;

    final isWeb = AppBreakpoints.isWeb(context);
    final hPad = isWeb ? 24.0 : 16.0;

    final addresses = addressesAsync.valueOrNull ?? [];

    // Auto-select first address
    if (_selectedAddressId == null && addresses.isNotEmpty) {
      final defaultAddr = addresses.firstWhere(
        (a) => a.isDefault,
        orElse: () => addresses.first,
      );
      _selectedAddressId = defaultAddr.id;
    }
    if (addresses.isEmpty && !_showAddressForm) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _showAddressForm = true);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isWeb
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              title: const Text('結帳'),
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios, size: 20),
              ),
            ),
      body: Column(
        children: [
          if (isWeb) const WebNavBarStandalone(),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isWeb)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Text(
                              '結帳',
                              style: AppTextStyles.headlineMedium,
                            ),
                          ),

                        // Cart items
                        _SectionCard(
                          title: '訂購商品',
                          child: _CartItemsList(
                            cartItems: cartItems,
                            intlRate: intlRate,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Address
                        _SectionCard(
                          title: '收件地址',
                          trailing: addresses.isNotEmpty
                              ? TextButton(
                                  onPressed: () => setState(
                                    () => _showAddressForm = !_showAddressForm,
                                  ),
                                  child: Text(
                                    _showAddressForm ? '使用已儲存地址' : '＋ 新增地址',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                )
                              : null,
                          child: addressesAsync.when(
                            loading: () => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            error: (_, _) => Text(
                              '地址載入失敗',
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.error),
                            ),
                            data: (addrs) => _showAddressForm || addrs.isEmpty
                                ? _AddressForm(
                                    formKey: _addressFormKey,
                                    labelController: _labelController,
                                    nameController: _nameController,
                                    phoneController: _phoneController,
                                    addressDetailController:
                                        _addressDetailController,
                                    selectedCity: _selectedCity,
                                    onCityChanged: (c) =>
                                        setState(() => _selectedCity = c),
                                  )
                                : _AddressList(
                                    addresses: addrs,
                                    selectedId: _selectedAddressId,
                                    onSelected: (id) =>
                                        setState(() => _selectedAddressId = id),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Shipping method
                        _SectionCard(
                          title: '配送方式',
                          child: Column(
                            children: _ShippingMethod.values.map((method) {
                              final feeLabel =
                                  isFreeShipping ? '免運' : 'NT\$ ${method.baseFee}';
                              return RadioListTile<_ShippingMethod>(
                                value: method,
                                groupValue: _shippingMethod,
                                onChanged: (v) =>
                                    setState(() => _shippingMethod = v!),
                                activeColor: AppColors.primary,
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  method.label,
                                  style: AppTextStyles.bodyMedium,
                                ),
                                subtitle: Text(
                                  feeLabel,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isFreeShipping
                                        ? AppColors.success
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Note
                        _SectionCard(
                          title: '備註（選填）',
                          child: TextField(
                            controller: _noteController,
                            maxLines: 3,
                            style: AppTextStyles.bodyMedium,
                            decoration: InputDecoration(
                              hintText: '對訂單有任何備註請在此填寫...',
                              hintStyle: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textHint,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide:
                                    const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide:
                                    const BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Order summary
                        _SectionCard(
                          title: '訂單摘要',
                          child: Column(
                            children: [
                              _SummaryRow(
                                label: '商品小計',
                                value: 'NT\$ $subtotal',
                              ),
                              const SizedBox(height: 8),
                              _SummaryRow(
                                label:
                                    '台灣國內運費（${_shippingMethod.label}）',
                                value: isFreeShipping
                                    ? '免運'
                                    : 'NT\$ $shippingFee',
                                valueColor: isFreeShipping
                                    ? AppColors.success
                                    : null,
                              ),
                              if (isFreeShipping) ...[
                                const SizedBox(height: 4),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '已達免運門檻',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.success,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              const Divider(color: AppColors.divider),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('總計', style: AppTextStyles.titleLarge),
                                  Text(
                                    'NT\$ $total',
                                    style: AppTextStyles.price
                                        .copyWith(fontSize: 20),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.error),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: cartItems.isEmpty || _isSubmitting
                                ? null
                                : () => _placeOrder(
                                      subtotal: subtotal,
                                      shippingFee: shippingFee,
                                      total: total,
                                      addresses: addresses,
                                    ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.white,
                                    ),
                                  )
                                : const Text('確認下單'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section card
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: AppTextStyles.titleLarge),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cart items list — delegates to _CartItemRow per item
// ---------------------------------------------------------------------------

class _CartItemsList extends ConsumerWidget {
  const _CartItemsList({
    required this.cartItems,
    required this.intlRate,
  });

  final Map<String, CartItem> cartItems;
  final double intlRate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = cartItems.values.toList();
    if (items.isEmpty) {
      return Text(
        '購物車是空的',
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      );
    }

    return Column(
      children: List.generate(items.length, (i) {
        return Column(
          children: [
            if (i > 0)
              const Divider(color: AppColors.divider, height: 16),
            _CartItemRow(cartItem: items[i], intlRate: intlRate),
          ],
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Single cart item row — watches productByIdProvider directly
// ---------------------------------------------------------------------------

class _CartItemRow extends ConsumerWidget {
  const _CartItemRow({required this.cartItem, required this.intlRate});

  final CartItem cartItem;
  final double intlRate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productByIdProvider(cartItem.productId));

    return productAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 12),
            Text('商品載入中...'),
          ],
        ),
      ),
      error: (_, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          '商品資料載入失敗',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
        ),
      ),
      data: (product) {
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
        final variantLabel = cartItem.selectedVariants.values.join('・');
        final imageUrl =
            product.images.isNotEmpty ? product.images.first.url : null;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 56,
                  height: 56 * 4 / 3,
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
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: AppTextStyles.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (variantLabel.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        variantLabel,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      'x${cartItem.quantity}  ×  NT\$ $unitPrice',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Item total
              Text(
                'NT\$ $itemTotal',
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Address list (radio selection)
// ---------------------------------------------------------------------------

class _AddressList extends StatelessWidget {
  const _AddressList({
    required this.addresses,
    required this.selectedId,
    required this.onSelected,
  });

  final List<Address> addresses;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: addresses.map((addr) {
        final isSelected = addr.id == selectedId;
        return InkWell(
          onTap: () => onSelected(addr.id),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Radio<String>(
                  value: addr.id,
                  groupValue: selectedId,
                  onChanged: (v) => onSelected(v!),
                  activeColor: AppColors.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            addr.recipientName,
                            style: AppTextStyles.titleMedium,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            addr.phone,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textSecondary),
                          ),
                          if (addr.isDefault) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                '預設',
                                style: AppTextStyles.bodySmall
                                    .copyWith(fontSize: 10),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        addr.address,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Address form (add new)
// ---------------------------------------------------------------------------

class _AddressForm extends StatelessWidget {
  const _AddressForm({
    required this.formKey,
    required this.labelController,
    required this.nameController,
    required this.phoneController,
    required this.addressDetailController,
    required this.selectedCity,
    required this.onCityChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController labelController;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressDetailController;
  final String selectedCity;
  final ValueChanged<String> onCityChanged;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: '收件人姓名'),
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return '請輸入收件人姓名';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: phoneController,
            decoration: const InputDecoration(labelText: '手機號碼'),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return '請輸入手機號碼';
              return null;
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedCity,
            decoration: const InputDecoration(labelText: '縣市'),
            items: _kCities
                .map(
                  (c) => DropdownMenuItem(value: c, child: Text(c)),
                )
                .toList(),
            onChanged: (v) => onCityChanged(v!),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: addressDetailController,
            decoration: const InputDecoration(labelText: '詳細地址'),
            textInputAction: TextInputAction.done,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return '請輸入詳細地址';
              return null;
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Order summary row
// ---------------------------------------------------------------------------

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: valueColor ?? AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
