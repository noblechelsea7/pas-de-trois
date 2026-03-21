import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/shipping_constants.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/price_calculator.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/shipping_calculator.dart';
import '../../../../shared/widgets/wishlist_heart_button.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../domain/models/product.dart';
import '../providers/product_providers.dart';

// ---------------------------------------------------------------------------
// Size reference data
// ---------------------------------------------------------------------------

const _kSizeLabels = ['XS', 'S', 'M', 'L', 'XL'];

const _kChestSizes = {'XS': '85', 'S': '90', 'M': '95', 'L': '100', 'XL': '105'};
const _kWaistSizes = {'XS': '24', 'S': '25', 'M': '26', 'L': '27', 'XL': '28'};

// ---------------------------------------------------------------------------
// Root screen
// ---------------------------------------------------------------------------

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

  /// Effective image list: prefers product_images, falls back to image_url.
  List<ProductImage> get _effectiveImages {
    if (widget.product.images.isNotEmpty) return widget.product.images;
    if (widget.product.imageUrl != null) {
      return [
        ProductImage(
          id: '',
          productId: widget.product.id,
          url: widget.product.imageUrl!,
        ),
      ];
    }
    return [];
  }

  Future<void> _copyUrl() async {
    await Clipboard.setData(ClipboardData(text: Uri.base.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已複製連結'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final settings = ref.watch(productSettingsProvider).valueOrNull ?? {};
    final intlRate =
        double.tryParse(settings[AppConstants.settingIntlShippingRate] ?? '') ??
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

    final selectedVariants = ref.watch(selectedVariantsProvider(product.id));
    final images = _effectiveImages;

    // Resolve category slug for size reference
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
    final category =
        categories.where((c) => c.id == product.categoryId).firstOrNull;

    if (AppBreakpoints.isWeb(context)) {
      return _buildWebLayout(
        context,
        product: product,
        displayPrice: displayPrice,
        selectedVariants: selectedVariants,
        images: images,
        category: category,
      );
    }

    return _buildMobileLayout(
      context,
      product: product,
      displayPrice: displayPrice,
      selectedVariants: selectedVariants,
      images: images,
      category: category,
    );
  }

  // ── Desktop two-column layout ──────────────────────────────────────────────

  Widget _buildWebLayout(
    BuildContext context, {
    required Product product,
    required int displayPrice,
    required Map<String, String> selectedVariants,
    required List<ProductImage> images,
    required dynamic category,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              height: constraints.maxHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Left column 55% — scrollable ──────────────────────────
                  Expanded(
                    flex: 55,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Main image — full viewport height, bg #F8F8F8
                          Container(
                            height: constraints.maxHeight,
                            color: const Color(0xFFF8F8F8),
                            child: _ImageGallery(
                              images: images,
                              currentIndex: _currentImageIndex,
                              pageController: _pageController,
                              onPageChanged: (i) =>
                                  setState(() => _currentImageIndex = i),
                            ),
                          ),

                          // Thumbnail strip
                          if (images.length > 1)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: _ThumbnailRow(
                                images: images,
                                currentIndex: _currentImageIndex,
                                onTap: (i) {
                                  _pageController.animateToPage(
                                    i,
                                    duration:
                                        const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                  );
                                  setState(() => _currentImageIndex = i);
                                },
                              ),
                            ),

                          // Description + info tiles
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(40, 40, 32, 80),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (product.sizeInfo != null) ...[
                                  Text('尺寸資訊',
                                      style: AppTextStyles.titleLarge),
                                  const SizedBox(height: 8),
                                  Text(
                                    product.sizeInfo!,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 32),
                                ],
                                if (product.description != null) ...[
                                  Text('商品說明',
                                      style: AppTextStyles.titleLarge),
                                  const SizedBox(height: 8),
                                  Text(
                                    product.description!,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                      height: 1.7,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                ],
                                const _InfoExpansionTiles(),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.scale_outlined,
                                          size: 16,
                                          color: AppColors.textSecondary),
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
                        ],
                      ),
                    ),
                  ),

                  // Divider
                  Container(width: 1, color: AppColors.border),

                  // ── Right column 45% — sticky ──────────────────────────────
                  Expanded(
                    flex: 45,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(40, 40, 40, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Brand name
                          if (product.brandName != null &&
                              product.brandName!.isNotEmpty) ...[
                            Text(
                              product.brandName!.toUpperCase(),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                          ],

                          // Name + share + wishlist
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: AppTextStyles.headlineMedium,
                                ),
                              ),
                              IconButton(
                                onPressed: _copyUrl,
                                icon: const Icon(Icons.link_rounded, size: 20),
                                color: AppColors.textSecondary,
                                tooltip: '複製連結',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                              ),
                              WishlistHeartButton(
                                productId: product.id,
                                size: 24,
                                withBackground: false,
                                padding:
                                    const EdgeInsets.fromLTRB(4, 0, 0, 0),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Price
                          Text(
                            'NT\$ $displayPrice',
                            style:
                                AppTextStyles.price.copyWith(fontSize: 24),
                          ),
                          const SizedBox(height: 4),
                          Text('含代購費、韓國及國際運費',
                              style: AppTextStyles.bodySmall),
                          const SizedBox(height: 12),

                          // Arrival time
                          Row(
                            children: [
                              const Icon(
                                Icons.local_shipping_outlined,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '預計到貨：下單後約 10-14 個工作天',
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),

                          // Variant selectors
                          if (product.variants.isNotEmpty) ...[
                            const SizedBox(height: 28),
                            ...product.variants.map(
                              (variant) => _VariantSelector(
                                productId: product.id,
                                variant: variant,
                                selectedOption:
                                    selectedVariants[variant.name],
                                onSelect: (option) => ref
                                    .read(selectedVariantsProvider(
                                            product.id)
                                        .notifier)
                                    .select(variant.name, option),
                              ),
                            ),
                          ],

                          // Size reference
                          if (category != null)
                            _SizeReferenceExpansionTile(
                                categorySlug: category.slug ?? ''),

                          // Quantity
                          const SizedBox(height: 8),
                          _QuantityRow(productId: product.id),
                          const SizedBox(height: 32),

                          // Action buttons
                          _CartActionButtons(product: product),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Mobile single-column layout (unchanged) ────────────────────────────────

  Widget _buildMobileLayout(
    BuildContext context, {
    required Product product,
    required int displayPrice,
    required Map<String, String> selectedVariants,
    required List<ProductImage> images,
    required dynamic category,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: CustomScrollView(
          slivers: [
            // ── Image gallery ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: 360,
                child: _ImageGallery(
                  images: images,
                  currentIndex: _currentImageIndex,
                  pageController: _pageController,
                  onPageChanged: (i) =>
                      setState(() => _currentImageIndex = i),
                ),
              ),
            ),

            // ── Thumbnail strip (only when > 1 image) ─────────────────────
            if (images.length > 1)
              SliverToBoxAdapter(
                child: _ThumbnailRow(
                  images: images,
                  currentIndex: _currentImageIndex,
                  onTap: (i) {
                    _pageController.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    );
                    setState(() => _currentImageIndex = i);
                  },
                ),
              ),

            // ── Content ───────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand name
                    if (product.brandName != null &&
                        product.brandName!.isNotEmpty) ...[
                      Text(
                        product.brandName!.toUpperCase(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],

                    // Name + share + wishlist
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: AppTextStyles.headlineMedium,
                          ),
                        ),
                        IconButton(
                          onPressed: _copyUrl,
                          icon: const Icon(Icons.link_rounded, size: 20),
                          color: AppColors.textSecondary,
                          tooltip: '複製連結',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                        WishlistHeartButton(
                          productId: product.id,
                          size: 24,
                          withBackground: false,
                          padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Price
                    Text(
                      'NT\$ $displayPrice',
                      style: AppTextStyles.price.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 4),
                    Text('含代購費、韓國及國際運費',
                        style: AppTextStyles.bodySmall),
                    const SizedBox(height: 8),

                    // Arrival time
                    Row(
                      children: [
                        const Icon(
                          Icons.local_shipping_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '預計到貨：下單後約 10-14 個工作天',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
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
                              .read(
                                  selectedVariantsProvider(product.id).notifier)
                              .select(variant.name, option),
                        ),
                      ),
                    ],

                    // Quantity
                    const SizedBox(height: 8),
                    _QuantityRow(productId: product.id),
                    const SizedBox(height: 24),

                    // Size reference table
                    if (category != null)
                      _SizeReferenceExpansionTile(
                          categorySlug: category.slug ?? ''),

                    // Size info
                    if (product.sizeInfo != null) ...[
                      const SizedBox(height: 8),
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
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Info expansion tiles
                    const _InfoExpansionTiles(),
                    const SizedBox(height: 16),

                    // Weight
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.scale_outlined,
                              size: 16, color: AppColors.textSecondary),
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
// Thumbnail strip
// ---------------------------------------------------------------------------

class _ThumbnailRow extends StatelessWidget {
  const _ThumbnailRow({
    required this.images,
    required this.currentIndex,
    required this.onTap,
  });

  final List<ProductImage> images;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: images.length,
        itemBuilder: (context, i) {
          final isSelected = i == currentIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            child: Container(
              width: 56,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: CachedNetworkImage(
                  imageUrl: images[i].url,
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      Container(color: AppColors.surface),
                  errorWidget: (_, _, _) =>
                      Container(color: AppColors.surface),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Size reference expansion tile
// ---------------------------------------------------------------------------

class _SizeReferenceExpansionTile extends StatelessWidget {
  const _SizeReferenceExpansionTile({required this.categorySlug});
  final String categorySlug;

  @override
  Widget build(BuildContext context) {
    // Only show for clothing categories
    if (categorySlug == 'best' ||
        categorySlug == 'new' ||
        categorySlug.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding:
              const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text('尺寸參考', style: AppTextStyles.titleMedium),
          children: [_buildSizeContent()],
        ),
      ),
    );
  }

  Widget _buildSizeContent() {
    if (categorySlug == 'accessories') {
      return Text(
        '此商品尺寸不限，無需選擇尺寸。',
        style: AppTextStyles.bodyMedium
            .copyWith(color: AppColors.textSecondary),
      );
    }

    final isTops =
        categorySlug == 'tops' || categorySlug == 'outerwear';
    final sizeData = isTops ? _kChestSizes : _kWaistSizes;
    final unitLabel = isTops ? '胸圍 (cm)' : '腰圍 (inch)';

    return Table(
      border: TableBorder.all(
        color: AppColors.border,
        width: 0.5,
        borderRadius: BorderRadius.circular(4),
      ),
      children: [
        // Header
        TableRow(
          decoration: const BoxDecoration(color: AppColors.surface),
          children: [
            _tableCell('尺寸', isHeader: true),
            _tableCell(unitLabel, isHeader: true),
          ],
        ),
        for (final size in _kSizeLabels)
          TableRow(
            children: [
              _tableCell(size),
              _tableCell(sizeData[size] ?? '-'),
            ],
          ),
      ],
    );
  }

  Widget _tableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        text,
        style: isHeader
            ? AppTextStyles.bodySmall
                .copyWith(fontWeight: FontWeight.w600)
            : AppTextStyles.bodySmall,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Info expansion tiles (配送、退換貨、注意事項)
// ---------------------------------------------------------------------------

class _InfoExpansionTiles extends StatelessWidget {
  const _InfoExpansionTiles();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _InfoTile(
          title: '配送說明',
          content:
              '採空運直送台灣，預計下單後 10-14 個工作天送達。\n'
              '運費已包含在商品價格中，結帳時不另收國際運費。\n'
              '台灣境內配送提供便利商店取貨或宅配兩種方式。',
        ),
        _InfoTile(
          title: '退換貨說明',
          content:
              '商品有明顯瑕疵（非人為損壞）可於收貨後 3 天內聯繫客服申請退換。\n'
              '人為損壞、使用後商品或主觀因素（尺寸、顏色偏差）恕不受理退換。\n'
              '退換處理時間約 7-14 個工作天。',
        ),
        _InfoTile(
          title: '注意事項',
          content:
              '代購商品以韓國當地庫存為準，售完即止，若缺貨將全額退款。\n'
              '商品圖片顏色可能因螢幕設定而略有差異，請以實物為準。\n'
              '如需確認尺寸或庫存，歡迎下單前先透過 LINE 與我們確認。',
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.title, required this.content});
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding:
              const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(title, style: AppTextStyles.titleMedium),
          children: [
            Text(
              content,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.7,
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.transparent,
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
    final notifier =
        ref.read(productDetailQuantityProvider(productId).notifier);
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
          style:
              AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Image gallery with PageView — BoxFit.contain + nav arrows
// ---------------------------------------------------------------------------

class _ImageGallery extends StatelessWidget {
  const _ImageGallery({
    required this.images,
    required this.currentIndex,
    required this.pageController,
    required this.onPageChanged,
  });

  final List<ProductImage> images;
  final int currentIndex;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;

  void _goTo(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(
        color: AppColors.surface,
        child: const Center(
          child:
              Icon(Icons.image_outlined, size: 80, color: AppColors.border),
        ),
      );
    }

    return Stack(
      children: [
        // PageView
        PageView.builder(
          controller: pageController,
          onPageChanged: onPageChanged,
          itemCount: images.length,
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: images[index].url,
              fit: BoxFit.contain,
              placeholder: (_, _) =>
                  Container(color: const Color(0xFFF8F8F8)),
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

        // Left arrow
        if (images.length > 1 && currentIndex > 0)
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: _NavArrow(
                icon: Icons.chevron_left_rounded,
                onTap: () => _goTo(currentIndex - 1),
              ),
            ),
          ),

        // Right arrow
        if (images.length > 1 && currentIndex < images.length - 1)
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: _NavArrow(
                icon: Icons.chevron_right_rounded,
                onTap: () => _goTo(currentIndex + 1),
              ),
            ),
          ),

        // Image counter (bottom right)
        if (images.length > 1)
          Positioned(
            bottom: 8,
            right: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${currentIndex + 1} / ${images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _NavArrow extends StatelessWidget {
  const _NavArrow({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 22, color: AppColors.textPrimary),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared cart action buttons (used in web right column + mobile bottom bar)
// ---------------------------------------------------------------------------

class _CartActionButtons extends ConsumerWidget {
  const _CartActionButtons({required this.product});
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

    return Row(
      children: [
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
    );
  }
}

// ---------------------------------------------------------------------------
// Add to cart bottom bar — mobile only
// ---------------------------------------------------------------------------

class ProductDetailBottomBar extends ConsumerWidget {
  const ProductDetailBottomBar({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: _CartActionButtons(product: product),
    );
  }
}
