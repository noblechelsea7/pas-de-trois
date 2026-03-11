import '../../../auth/domain/models/user_profile.dart';
import '../../../orders/domain/models/order.dart';
import '../../../products/domain/models/product.dart';
import '../../domain/interfaces/i_admin_repository.dart';
import '../datasources/supabase_admin_datasource.dart';

class AdminRepositoryImpl implements IAdminRepository {
  const AdminRepositoryImpl(this._datasource);
  final SupabaseAdminDatasource _datasource;

  @override
  Future<int> getTodayOrderCount() => _datasource.getTodayOrderCount();

  @override
  Future<int> getPendingOrderCount() => _datasource.getPendingOrderCount();

  @override
  Future<int> getTotalMemberCount() => _datasource.getTotalMemberCount();

  @override
  Future<List<Order>> getAllOrders() => _datasource.getAllOrders();

  @override
  Future<void> updateOrderStatus(String orderId, String newStatus) =>
      _datasource.updateOrderStatus(orderId, newStatus);

  @override
  Future<List<Product>> getAllProducts({bool includeInactive = true}) =>
      _datasource.getAllProducts(includeInactive: includeInactive);

  @override
  Future<void> createProduct(Map<String, dynamic> data) =>
      _datasource.createProduct(data);

  @override
  Future<void> updateProduct(String productId, Map<String, dynamic> data) =>
      _datasource.updateProduct(productId, data);

  @override
  Future<void> toggleProductActive(String productId, bool isActive) =>
      _datasource.toggleProductActive(productId, isActive);

  @override
  Future<List<UserProfile>> getAllMembers() => _datasource.getAllMembers();

  @override
  Future<List<Order>> getMemberOrders(String userId) =>
      _datasource.getMemberOrders(userId);

  @override
  Future<void> toggleMemberAdmin(String userId, bool isAdmin) =>
      _datasource.toggleMemberAdmin(userId, isAdmin);

  @override
  Future<void> toggleMemberActive(String userId, bool isActive) =>
      _datasource.toggleMemberActive(userId, isActive);

  @override
  Future<void> updateAdminNotes(String userId, String notes) =>
      _datasource.updateAdminNotes(userId, notes);

  @override
  Future<Map<String, String>> getAllSettings() =>
      _datasource.getAllSettings();

  @override
  Future<void> updateSetting(String key, String value) =>
      _datasource.updateSetting(key, value);
}
