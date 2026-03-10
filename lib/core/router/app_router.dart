// Re-export so all existing `import 'app_router.dart'` callers keep RoutePaths/RouteNames.
export 'route_paths.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../layout/web_nav_bar.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import 'route_paths.dart';
import '../../features/cart/presentation/providers/cart_providers.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/orders/presentation/screens/checkout_screen.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/orders/presentation/screens/order_success_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/products/presentation/providers/product_providers.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/products/presentation/screens/products_screen.dart';

part 'app_router.g.dart';

// ---------------------------------------------------------------------------
// Route access rules
// Public: no login required
// Protected: login required (all others default to public)
// ---------------------------------------------------------------------------

// '/' (home), '/products', '/search', '/announcements', '/pages', '/cart' are public.
const _protectedPrefixes = [
  '/checkout',
  '/orders',
  '/profile',
  '/wishlist',
  '/addresses',
  '/admin',
  // '/cart' is intentionally omitted — guests use localStorage
];

// ---------------------------------------------------------------------------
// Auth refresh notifier — triggers GoRouter redirect on auth change
// ---------------------------------------------------------------------------

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Placeholder screens (replace with real implementations later)
// ---------------------------------------------------------------------------

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}

// ---------------------------------------------------------------------------
// Product detail page — has its own Scaffold (outside shell)
// ---------------------------------------------------------------------------

class _ProductDetailPage extends StatelessWidget {
  const _ProductDetailPage({required this.productId});
  final String productId;

  @override
  Widget build(BuildContext context) {
    final isWeb = AppBreakpoints.isWeb(context);

    if (isWeb) {
      // Web: show WebNavBar at top, no back button
      return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            const WebNavBarStandalone(),
            Expanded(
              child: ProductDetailScreen(productId: productId),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: _ProductDetailBottomBarLoader(productId: productId),
        ),
      );
    }

    // Mobile: standard AppBar with back button
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
      ),
      body: ProductDetailScreen(productId: productId),
      bottomNavigationBar: SafeArea(
        child: _ProductDetailBottomBarLoader(productId: productId),
      ),
    );
  }
}

class _ProductDetailBottomBarLoader extends ConsumerWidget {
  const _ProductDetailBottomBarLoader({required this.productId});
  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(
      productByIdProvider(productId),
    );
    return productAsync.maybeWhen(
      data: (product) => ProductDetailBottomBar(product: product),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

// ---------------------------------------------------------------------------
// Shell scaffold (Web nav + App bottom nav handled separately inside shell)
// ---------------------------------------------------------------------------

class _AppShell extends StatelessWidget {
  const _AppShell({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    if (AppBreakpoints.isWeb(context)) {
      return _WebShell(navigationShell: navigationShell);
    }
    return _MobileShell(navigationShell: navigationShell);
  }
}

// Web: top nav + full-width body, no bottom nav.
// Pages apply their own horizontal padding (24px) internally.
class _WebShell extends StatelessWidget {
  const _WebShell({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          WebNavBar(navigationShell: navigationShell),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}

// Mobile: full-width body + bottom nav
class _MobileShell extends StatelessWidget {
  const _MobileShell({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _AppBottomNav(navigationShell: navigationShell),
    );
  }
}

class _AppBottomNav extends ConsumerWidget {
  const _AppBottomNav({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref
        .watch(cartItemsProvider)
        .length;

    return BottomNavigationBar(
      currentIndex: navigationShell.currentIndex,
      onTap: (index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      ),
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '首頁'),
        const BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), label: '商品'),
        const BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: '收藏'),
        BottomNavigationBarItem(
          label: '購物車',
          icon: Badge(
            isLabelVisible: cartCount > 0,
            label: Text(cartCount > 99 ? '99+' : '$cartCount'),
            child: const Icon(Icons.shopping_bag_outlined),
          ),
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '我的'),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Router provider
// ---------------------------------------------------------------------------

@riverpod
GoRouter appRouter(Ref ref) {
  final client = Supabase.instance.client;

  final refreshListenable = _GoRouterRefreshStream(client.auth.onAuthStateChange);
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    initialLocation: RoutePaths.home,
    debugLogDiagnostics: false,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final isLoggedIn = client.auth.currentSession != null;
      final loc = state.matchedLocation;

      final isAuthScreen = loc == RoutePaths.login ||
          loc == RoutePaths.register ||
          loc == RoutePaths.forgotPassword;

      // Already logged in → leave auth screens, honour redirect param
      if (isLoggedIn && isAuthScreen) {
        final redirect = state.uri.queryParameters['redirect'];
        if (redirect != null && redirect.startsWith('/')) return redirect;
        return RoutePaths.home;
      }

      // Not logged in → block protected routes, pass redirect param
      final isProtected = _protectedPrefixes.any((p) => loc.startsWith(p));
      if (!isLoggedIn && isProtected) {
        return '${RoutePaths.login}?redirect=${Uri.encodeComponent(loc)}';
      }

      return null;
    },
    routes: [
      // ---------------------------------------------------------------
      // Stateful shell — persistent navigation branches
      // ---------------------------------------------------------------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _AppShell(navigationShell: navigationShell),
        branches: [
          // Branch 0 — Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                name: RouteNames.home,
                builder: (context, state) =>
                    const _PlaceholderScreen(title: '首頁'),
              ),
            ],
          ),

          // Branch 1 — Products
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.products,
                name: RouteNames.products,
                builder: (context, state) => const ProductsScreen(),
              ),
            ],
          ),

          // Branch 2 — Wishlist
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.wishlist,
                name: RouteNames.wishlist,
                builder: (context, state) =>
                    const _PlaceholderScreen(title: '收藏清單'),
              ),
            ],
          ),

          // Branch 3 — Cart
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.cart,
                name: RouteNames.cart,
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),

          // Branch 4 — Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                name: RouteNames.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // ---------------------------------------------------------------
      // Auth routes (outside shell — full screen)
      // ---------------------------------------------------------------
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => LoginScreen(
          redirect: state.uri.queryParameters['redirect'],
        ),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ---------------------------------------------------------------
      // Product detail (outside shell — full screen with bottom bar)
      // ---------------------------------------------------------------
      GoRoute(
        path: RoutePaths.productDetail,
        name: RouteNames.productDetail,
        builder: (context, state) {
          final productId = state.pathParameters['productId']!;
          return _ProductDetailPage(productId: productId);
        },
      ),

      // ---------------------------------------------------------------
      // Orders
      // ---------------------------------------------------------------
      GoRoute(
        path: RoutePaths.orders,
        name: RouteNames.orders,
        builder: (context, state) => const OrdersScreen(),
        routes: [
          GoRoute(
            path: ':orderId',
            name: RouteNames.orderDetail,
            builder: (context, state) => OrderDetailScreen(
              orderId: state.pathParameters['orderId']!,
            ),
          ),
        ],
      ),

      GoRoute(
        path: '/order-success/:orderId',
        name: RouteNames.orderSuccess,
        builder: (context, state) => OrderSuccessScreen(
          orderId: state.pathParameters['orderId']!,
        ),
      ),

      GoRoute(
        path: RoutePaths.checkout,
        name: RouteNames.checkout,
        builder: (context, state) => const CheckoutScreen(),
      ),

      // ---------------------------------------------------------------
      // Addresses
      // ---------------------------------------------------------------
      GoRoute(
        path: RoutePaths.addresses,
        name: RouteNames.addresses,
        builder: (context, state) =>
            const _PlaceholderScreen(title: '收件地址管理'),
      ),

      // ---------------------------------------------------------------
      // Announcements & static pages
      // ---------------------------------------------------------------
      GoRoute(
        path: RoutePaths.announcements,
        name: RouteNames.announcements,
        builder: (context, state) => const _PlaceholderScreen(title: '公告欄'),
      ),
      GoRoute(
        path: RoutePaths.page,
        name: RouteNames.page,
        builder: (context, state) => _PlaceholderScreen(
          title: '說明頁 ${state.pathParameters['pageKey']}',
        ),
      ),

      // ---------------------------------------------------------------
      // Search
      // ---------------------------------------------------------------
      GoRoute(
        path: RoutePaths.search,
        name: RouteNames.search,
        builder: (context, state) => const _PlaceholderScreen(title: '搜尋'),
      ),

      // ---------------------------------------------------------------
      // Admin routes
      // ---------------------------------------------------------------
      GoRoute(
        path: RoutePaths.adminDashboard,
        name: RouteNames.adminDashboard,
        builder: (context, state) => const _PlaceholderScreen(title: '後台首頁'),
        routes: [
          GoRoute(
            path: 'products',
            name: RouteNames.adminProducts,
            builder: (context, state) =>
                const _PlaceholderScreen(title: '商品管理'),
            routes: [
              GoRoute(
                path: ':productId',
                name: RouteNames.adminProductEdit,
                builder: (context, state) => _PlaceholderScreen(
                  title: '編輯商品 ${state.pathParameters['productId']}',
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'orders',
            name: RouteNames.adminOrders,
            builder: (context, state) =>
                const _PlaceholderScreen(title: '訂單管理'),
            routes: [
              GoRoute(
                path: ':orderId',
                name: RouteNames.adminOrderDetail,
                builder: (context, state) => _PlaceholderScreen(
                  title: '訂單詳情 ${state.pathParameters['orderId']}',
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'settings',
            name: RouteNames.adminSettings,
            builder: (context, state) =>
                const _PlaceholderScreen(title: '系統設定'),
          ),
          GoRoute(
            path: 'members',
            name: RouteNames.adminMembers,
            builder: (context, state) =>
                const _PlaceholderScreen(title: '會員管理'),
          ),
          GoRoute(
            path: 'announcements',
            name: RouteNames.adminAnnouncements,
            builder: (context, state) =>
                const _PlaceholderScreen(title: '公告管理'),
          ),
          GoRoute(
            path: 'pages',
            name: RouteNames.adminPages,
            builder: (context, state) =>
                const _PlaceholderScreen(title: '說明頁管理'),
          ),
        ],
      ),
    ],
  );
}
