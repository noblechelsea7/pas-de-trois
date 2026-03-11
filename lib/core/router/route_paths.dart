// Route path constants and route names — extracted to avoid circular imports.
// Both app_router.dart and web_nav_bar.dart import this file.

abstract final class RoutePaths {
  // Shell (persistent nav)
  static const String home = '/';
  static const String products = '/products';
  static const String productDetail = '/products/:productId';
  static const String cart = '/cart';
  static const String wishlist = '/wishlist';
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String profileAddress = '/profile/address';

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Orders
  static const String orders = '/orders';
  static const String orderDetail = '/orders/:orderId';
  static const String orderSuccess = '/order-success/:orderId';
  static const String checkout = '/checkout';

  // Addresses
  static const String addresses = '/addresses';

  // Announcements
  static const String announcements = '/announcements';

  // Static pages
  static const String page = '/pages/:pageKey';

  // Search
  static const String search = '/search';

  // Admin
  static const String adminDashboard = '/admin';
  static const String adminProducts = '/admin/products';
  static const String adminProductEdit = '/admin/products/:productId';
  static const String adminOrders = '/admin/orders';
  static const String adminOrderDetail = '/admin/orders/:orderId';
  static const String adminSettings = '/admin/settings';
  static const String adminMembers = '/admin/members';
  static const String adminAnnouncements = '/admin/announcements';
  static const String adminPages = '/admin/pages';
}

abstract final class RouteNames {
  static const String home = 'home';
  static const String products = 'products';
  static const String productDetail = 'productDetail';
  static const String cart = 'cart';
  static const String wishlist = 'wishlist';
  static const String profile = 'profile';
  static const String profileEdit = 'profileEdit';
  static const String profileAddress = 'profileAddress';
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgotPassword';
  static const String orders = 'orders';
  static const String orderDetail = 'orderDetail';
  static const String orderSuccess = 'orderSuccess';
  static const String checkout = 'checkout';
  static const String addresses = 'addresses';
  static const String announcements = 'announcements';
  static const String page = 'page';
  static const String search = 'search';
  static const String adminDashboard = 'adminDashboard';
  static const String adminProducts = 'adminProducts';
  static const String adminProductEdit = 'adminProductEdit';
  static const String adminOrders = 'adminOrders';
  static const String adminOrderDetail = 'adminOrderDetail';
  static const String adminSettings = 'adminSettings';
  static const String adminMembers = 'adminMembers';
  static const String adminAnnouncements = 'adminAnnouncements';
  static const String adminPages = 'adminPages';
}
