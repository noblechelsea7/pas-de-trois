import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';
import '../router/route_paths.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/cart/presentation/providers/cart_providers.dart';
import '../../features/products/domain/models/category.dart';
import '../../features/products/presentation/providers/product_providers.dart';

class WebNavBar extends ConsumerWidget {
  const WebNavBar({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategoryId = ref.watch(selectedCategoryProvider);
    final cartCount = ref
        .watch(cartItemsProvider)
        .length;

    return Container(
      height: AppConstants.webNavHeight,
      color: AppColors.white,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppBreakpoints.maxContentWidth,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      // ---- Logo ----
                      GestureDetector(
                        onTap: () => navigationShell.goBranch(
                          0,
                          initialLocation: true,
                        ),
                        child: Text(
                          AppConstants.brandName.toUpperCase(),
                          style: AppTextStyles.logoStyle.copyWith(
                            fontSize: 15,
                            letterSpacing: 4,
                          ),
                        ),
                      ),

                      const SizedBox(width: 40),

                      // ---- Category nav (center, expands) ----
                      Expanded(
                        child: categoriesAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, _) => const SizedBox.shrink(),
                          data: (cats) => _CategoryNavRow(
                            categories: cats,
                            currentBranchIndex: navigationShell.currentIndex,
                            selectedCategoryId: selectedCategoryId,
                            onHome: () => navigationShell.goBranch(0),
                            onCategory: (cat) {
                              ref.read(selectedCategoryProvider.notifier).state =
                                  cat?.id;
                              navigationShell.goBranch(1);
                            },
                          ),
                        ),
                      ),

                      // ---- Right icons ----
                      const SizedBox(width: 16),
                      _NavIconButton(
                        icon: Icons.search_outlined,
                        tooltip: '搜尋',
                        onTap: () => navigationShell.goBranch(1),
                      ),
                      _MemberMenuButton(
                        onGoProfile: () => navigationShell.goBranch(4),
                        onGoOrders: () => context.go(RoutePaths.orders),
                        onGoAdmin: () => context.go(RoutePaths.adminDashboard),
                        onGoLogin: () => context.go(RoutePaths.login),
                        onLogout: () async {
                          await Supabase.instance.client.auth.signOut();
                          if (context.mounted) context.go(RoutePaths.home);
                        },
                      ),
                      _NavIconButton(
                        icon: Icons.favorite_border,
                        tooltip: '收藏',
                        onTap: () => navigationShell.goBranch(2),
                      ),
                      _CartNavButton(
                        count: cartCount,
                        onTap: () => navigationShell.goBranch(3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Bottom border
          Container(height: 1, color: AppColors.divider),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category navigation row
// ---------------------------------------------------------------------------

class _CategoryNavRow extends StatelessWidget {
  const _CategoryNavRow({
    required this.categories,
    required this.currentBranchIndex,
    required this.selectedCategoryId,
    required this.onHome,
    required this.onCategory,
  });

  final List<Category> categories;
  final int currentBranchIndex;
  final String? selectedCategoryId;
  final VoidCallback onHome;
  final ValueChanged<Category?> onCategory;

  @override
  Widget build(BuildContext context) {
    final isOnHome = currentBranchIndex == 0;
    final isOnProducts = currentBranchIndex == 1;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // 首頁
          _NavTextLink(
            label: '首頁',
            isActive: isOnHome,
            onTap: onHome,
          ),
          const SizedBox(width: 28),

          // All products (no category filter)
          _NavTextLink(
            label: '全部商品',
            isActive: isOnProducts && selectedCategoryId == null,
            onTap: () => onCategory(null),
          ),

          // Categories from DB
          ...categories.map((cat) {
            final isActive =
                isOnProducts && selectedCategoryId == cat.id;
            return Padding(
              padding: const EdgeInsets.only(left: 28),
              child: _NavTextLink(
                label: cat.name,
                isActive: isActive,
                onTap: () => onCategory(cat),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Single text nav link with underline indicator
// ---------------------------------------------------------------------------

class _NavTextLink extends StatelessWidget {
  const _NavTextLink({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            width: isActive ? 24 : 0,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Icon button (search / member / wishlist)
// ---------------------------------------------------------------------------

class _NavIconButton extends StatelessWidget {
  const _NavIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Icon(icon, size: 22, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Member hover menu (logged in: orders / profile / logout; guest: go login)
// ---------------------------------------------------------------------------

class _MemberMenuButton extends ConsumerStatefulWidget {
  const _MemberMenuButton({
    required this.onGoProfile,
    required this.onGoOrders,
    required this.onGoAdmin,
    required this.onGoLogin,
    required this.onLogout,
  });

  final VoidCallback onGoProfile;
  final VoidCallback onGoOrders;
  final VoidCallback onGoAdmin;
  final VoidCallback onGoLogin;
  final Future<void> Function() onLogout;

  @override
  ConsumerState<_MemberMenuButton> createState() => _MemberMenuButtonState();
}

class _MemberMenuButtonState extends ConsumerState<_MemberMenuButton> {
  OverlayEntry? _entry;
  Timer? _timer;
  final _key = GlobalKey();

  @override
  void dispose() {
    _timer?.cancel();
    _entry?.remove();
    _entry = null;
    super.dispose();
  }

  void _cancelHide() {
    _timer?.cancel();
    _timer = null;
  }

  void _scheduleHide() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 150), _hide);
  }

  void _showMenu() {
    _cancelHide();
    if (_entry != null) return;

    final box = _key.currentContext!.findRenderObject()! as RenderBox;
    final pos = box.localToGlobal(Offset.zero);
    final size = box.size;

    final isAdmin = ref
        .read(userProfileProvider)
        .valueOrNull
        ?.isAdmin ?? false;

    _entry = OverlayEntry(
      builder: (overlayCtx) {
        final sw = MediaQuery.of(overlayCtx).size.width;
        return Positioned(
          top: pos.dy + size.height + 4,
          right: sw - pos.dx - size.width,
          child: MouseRegion(
            onEnter: (_) => _cancelHide(),
            onExit: (_) => _scheduleHide(),
            child: Material(
              elevation: 6,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 160,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isAdmin) ...[
                      _HoverMenuItem(
                        icon: Icons.admin_panel_settings_outlined,
                        label: '管理後台',
                        color: AppColors.primary,
                        onTap: () { _hide(); widget.onGoAdmin(); },
                      ),
                      const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                    ],
                    _HoverMenuItem(
                      icon: Icons.receipt_long_outlined,
                      label: '我的訂單',
                      onTap: () { _hide(); widget.onGoOrders(); },
                    ),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                    _HoverMenuItem(
                      icon: Icons.settings_outlined,
                      label: '帳號設定',
                      onTap: () { _hide(); widget.onGoProfile(); },
                    ),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                    _HoverMenuItem(
                      icon: Icons.logout,
                      label: '登出',
                      color: Colors.red,
                      onTap: () { _hide(); widget.onLogout(); },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(_key.currentContext!).insert(_entry!);
  }

  void _hide() {
    _entry?.remove();
    _entry = null;
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn =
        Supabase.instance.client.auth.currentSession != null;

    if (!isLoggedIn) {
      return _NavIconButton(
        icon: Icons.person_outline,
        tooltip: '登入',
        onTap: widget.onGoLogin,
      );
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _showMenu(),
      onExit: (_) => _scheduleHide(),
      child: GestureDetector(
        onTap: widget.onGoProfile,
        child: Container(
          key: _key,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: const Icon(Icons.person_outline,
              size: 22, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hover menu item row
// ---------------------------------------------------------------------------

class _HoverMenuItem extends StatelessWidget {
  const _HoverMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color ?? AppColors.textPrimary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cart icon with item count badge
// ---------------------------------------------------------------------------

class _CartNavButton extends StatelessWidget {
  const _CartNavButton({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '購物車',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                size: 22,
                color: AppColors.textPrimary,
              ),
              if (count > 0)
                Positioned(
                  top: -4,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Standalone version — used on full-screen pages outside the shell (e.g. product
// detail on web).  Uses context.go instead of navigationShell.goBranch.
// ---------------------------------------------------------------------------

class WebNavBarStandalone extends ConsumerWidget {
  const WebNavBarStandalone({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategoryId = ref.watch(selectedCategoryProvider);
    final cartCount = ref
        .watch(cartItemsProvider)
        .length;

    return Container(
      height: AppConstants.webNavHeight,
      color: AppColors.white,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  // Logo
                  GestureDetector(
                    onTap: () => context.go(RoutePaths.home),
                    child: Text(
                      AppConstants.brandName.toUpperCase(),
                      style: AppTextStyles.logoStyle.copyWith(
                        fontSize: 15,
                        letterSpacing: 4,
                      ),
                    ),
                  ),

                  const SizedBox(width: 40),

                  // Categories (center)
                  Expanded(
                    child: categoriesAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                      data: (cats) => _CategoryNavRow(
                        categories: cats,
                        currentBranchIndex: 1, // products section is "active"
                        selectedCategoryId: selectedCategoryId,
                        onHome: () => context.go(RoutePaths.home),
                        onCategory: (cat) {
                          ref.read(selectedCategoryProvider.notifier).state =
                              cat?.id;
                          context.go(RoutePaths.products);
                        },
                      ),
                    ),
                  ),

                  // Right icons
                  const SizedBox(width: 16),
                  _NavIconButton(
                    icon: Icons.search_outlined,
                    tooltip: '搜尋',
                    onTap: () => context.go(RoutePaths.products),
                  ),
                  _MemberMenuButton(
                    onGoProfile: () => context.go(RoutePaths.profile),
                    onGoOrders: () => context.go(RoutePaths.orders),
                    onGoAdmin: () => context.go(RoutePaths.adminDashboard),
                    onGoLogin: () => context.go(RoutePaths.login),
                    onLogout: () async {
                      await Supabase.instance.client.auth.signOut();
                      if (context.mounted) context.go(RoutePaths.home);
                    },
                  ),
                  _NavIconButton(
                    icon: Icons.favorite_border,
                    tooltip: '收藏',
                    onTap: () => context.go(RoutePaths.wishlist),
                  ),
                  _CartNavButton(
                    count: cartCount,
                    onTap: () => context.go(RoutePaths.cart),
                  ),
                ],
              ),
            ),
          ),
          Container(height: 1, color: AppColors.divider),
        ],
      ),
    );
  }
}
