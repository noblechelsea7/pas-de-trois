import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../products/domain/models/product.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../../products/presentation/widgets/product_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = AppBreakpoints.isWeb(context);
    final hPad = isWeb ? 48.0 : 20.0;

    return CustomScrollView(
      controller: _scrollCtrl,
      slivers: [
        SliverToBoxAdapter(child: _HeroBanner(onShopNow: () => context.go(RoutePaths.products))),
        SliverToBoxAdapter(child: _AnnouncementBanner()),
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: _NewArrivalsSection(hPad: hPad, isWeb: isWeb),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: _BrandFeatures(hPad: hPad),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 48)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Hero Banner
// ---------------------------------------------------------------------------

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.onShopNow});
  final VoidCallback onShopNow;

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;

    return Container(
      height: screenH * 0.60,
      width: double.infinity,
      color: AppColors.primary,
      child: Stack(
        children: [
          // subtle texture overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: Image.network(
                'https://www.transparenttextures.com/patterns/subtle-white-feathers.png',
                repeat: ImageRepeat.repeat,
                errorBuilder: (context2, err2, st2) => const SizedBox.shrink(),
              ),
            ),
          ),
          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'KOREAN LUXURY PROXY SHOPPING',
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 11,
                      fontWeight: FontWeight.w300,
                      color: Colors.white70,
                      letterSpacing: 4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'PAS DE TROIS',
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 52,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 8,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '韓國精品代購',
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      color: Colors.white54,
                      letterSpacing: 6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  _ShopNowButton(onTap: onShopNow),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopNowButton extends StatefulWidget {
  const _ShopNowButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_ShopNowButton> createState() => _ShopNowButtonState();
}

class _ShopNowButtonState extends State<_ShopNowButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          decoration: BoxDecoration(
            color: _hovered ? Colors.white : Colors.transparent,
            border: Border.all(color: Colors.white, width: 1),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _hovered ? AppColors.primary : Colors.white,
              letterSpacing: 4,
            ),
            child: const Text('SHOP NOW'),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Announcement Banner
// ---------------------------------------------------------------------------

class _AnnouncementBanner extends ConsumerWidget {
  const _AnnouncementBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(productSettingsProvider).valueOrNull ?? {};
    final text = settings['announcement_text'] ?? '';
    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          letterSpacing: 1.5,
          height: 1.6,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// New Arrivals
// ---------------------------------------------------------------------------

class _NewArrivalsSection extends ConsumerWidget {
  const _NewArrivalsSection({required this.hPad, required this.isWeb});
  final double hPad;
  final bool isWeb;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 64, hPad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            tag: 'NEW ARRIVALS',
            subtitle: '新品上架',
            onViewAll: () => context.go(RoutePaths.products),
          ),
          const SizedBox(height: 32),
          productsAsync.when(
            loading: () => const _ProductGridSkeleton(),
            error: (err, _) => const SizedBox.shrink(),
            data: (products) {
              final items = products.take(4).toList();
              if (items.isEmpty) return const SizedBox.shrink();
              return _ProductGrid(products: items, isWeb: isWeb);
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.tag,
    required this.subtitle,
    required this.onViewAll,
  });
  final String tag;
  final String subtitle;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tag,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: AppColors.textSecondary,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: onViewAll,
          child: Row(
            children: const [
              Text(
                'VIEW ALL',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 13, color: AppColors.textSecondary),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.products, required this.isWeb});
  final List<Product> products;
  final bool isWeb;

  @override
  Widget build(BuildContext context) {
    final columns = isWeb ? 4 : 2;
    const spacing = 16.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemW = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final p in products)
              SizedBox(width: itemW, child: ProductCard(product: p)),
          ],
        );
      },
    );
  }
}

class _ProductGridSkeleton extends StatelessWidget {
  const _ProductGridSkeleton();

  @override
  Widget build(BuildContext context) {
    final isWeb = AppBreakpoints.isWeb(context);
    final columns = isWeb ? 4 : 2;
    const spacing = 16.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemW = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(
            4,
            (_) => SizedBox(
              width: itemW,
              child: AspectRatio(
                aspectRatio: 0.62,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Brand Features
// ---------------------------------------------------------------------------

class _BrandFeatures extends StatelessWidget {
  const _BrandFeatures({required this.hPad});
  final double hPad;

  @override
  Widget build(BuildContext context) {
    final isWeb = AppBreakpoints.isWeb(context);

    const features = [
      (Icons.flight_takeoff_outlined, '韓國直送', 'Direct from Seoul'),
      (Icons.local_shipping_outlined, '快速到貨', 'Express Delivery'),
      (Icons.diamond_outlined, '精選品牌', 'Curated Brands'),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 72, hPad, 0),
      child: isWeb
          ? Row(
              children: [
                for (int i = 0; i < features.length; i++) ...[
                  if (i > 0) const SizedBox(width: 32),
                  Expanded(
                    child: _FeatureItem(
                      icon: features[i].$1,
                      title: features[i].$2,
                      subtitle: features[i].$3,
                    ),
                  ),
                ],
              ],
            )
          : Column(
              children: [
                for (final f in features) ...[
                  _FeatureItem(icon: f.$1, title: f.$2, subtitle: f.$3),
                  const SizedBox(height: 40),
                ],
              ],
            ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 28, color: AppColors.primary),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 11,
            fontWeight: FontWeight.w300,
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
