import 'dart:typed_data';

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
  Future<String> uploadProductImage(String productId, Uint8List bytes);

  // Members
  Future<List<UserProfile>> getAllMembers();
  Future<List<Order>> getMemberOrders(String userId);
  Future<void> toggleMemberAdmin(String userId, bool isAdmin);
  Future<void> toggleMemberActive(String userId, bool isActive);
  Future<void> updateAdminNotes(String userId, String notes);

  // Settings
  Future<Map<String, String>> getAllSettings();
  Future<void> updateSetting(String key, String value);
}
