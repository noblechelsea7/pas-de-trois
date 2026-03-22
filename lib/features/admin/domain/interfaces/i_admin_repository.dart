import 'dart:typed_data';

import '../../../../core/models/site_page.dart';
import '../../../auth/domain/models/user_profile.dart';
import '../../../orders/domain/models/order.dart';
import '../../../products/domain/models/product.dart';

abstract interface class IAdminRepository {
  // Dashboard
  Future<int> getTodayOrderCount();
  Future<int> getPendingOrderCount();
  Future<int> getTotalMemberCount();

  // Orders
  Future<List<Order>> getAllOrders();
  Future<void> updateOrderStatus(String orderId, String newStatus);

  // Products
  Future<List<Product>> getAllProducts({bool includeInactive = true});
  Future<String> createProduct(Map<String, dynamic> data);
  Future<void> updateProduct(String productId, Map<String, dynamic> data);
  Future<void> toggleProductActive(String productId, bool isActive);

  /// Replaces all images for [productId]:
  /// - keeps [keptUrls] (in order, existing rows only),
  /// - uploads [newImages] bytes appended after kept,
  /// - updates products.image_url to first image.
  Future<void> replaceAllProductImages(
    String productId,
    List<String> keptUrls,
    List<Uint8List> newImages,
  );

  // Members
  Future<List<UserProfile>> getAllMembers();
  Future<List<Order>> getMemberOrders(String userId);
  Future<void> toggleMemberAdmin(String userId, bool isAdmin);
  Future<void> toggleMemberActive(String userId, bool isActive);
  Future<void> updateAdminNotes(String userId, String notes);

  // Settings
  Future<Map<String, String>> getAllSettings();
  Future<void> updateSetting(String key, String value);

  // Pages
  Future<List<SitePage>> getAllPages();
  Future<void> updatePage(String key, String title, String content);
}
