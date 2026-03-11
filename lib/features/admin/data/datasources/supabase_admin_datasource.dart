import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/domain/models/user_profile.dart';
import '../../../orders/domain/models/order.dart';
import '../../../products/domain/models/product.dart';

class SupabaseAdminDatasource {
  const SupabaseAdminDatasource(this._client);
  final SupabaseClient _client;

  // ---------------------------------------------------------------------------
  // Dashboard
  // ---------------------------------------------------------------------------

  Future<int> getTodayOrderCount() async {
    final now = DateTime.now();
    final todayStart =
        DateTime(now.year, now.month, now.day).toIso8601String();
    final data =
        await _client.from('orders').select('id').gte('created_at', todayStart);
    return (data as List).length;
  }

  Future<int> getPendingOrderCount() async {
    final data =
        await _client.from('orders').select('id').eq('status', '待付款');
    return (data as List).length;
  }

  Future<int> getTotalMemberCount() async {
    final data = await _client.from('profiles').select('id');
    return (data as List).length;
  }

  // ---------------------------------------------------------------------------
  // Orders
  // ---------------------------------------------------------------------------

  Future<List<Order>> getAllOrders() async {
    final data = await _client
        .from('orders')
        .select('*, order_items(*), order_status_logs(*)')
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _client
        .from('orders')
        .update({'status': newStatus}).eq('id', orderId);

    await _client.from('order_status_logs').insert({
      'order_id': orderId,
      'status': newStatus,
    });
  }

  // ---------------------------------------------------------------------------
  // Products
  // ---------------------------------------------------------------------------

  Future<List<Product>> getAllProducts({bool includeInactive = true}) async {
    var builder = _client.from('products').select('*, product_images(*)');
    if (!includeInactive) {
      builder = builder.eq('is_active', true);
    }
    final data = await builder.order('created_at', ascending: false);
    return (data as List)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createProduct(Map<String, dynamic> data) async {
    await _client.from('products').insert(data);
  }

  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> data,
  ) async {
    await _client.from('products').update(data).eq('id', productId);
  }

  Future<void> toggleProductActive(String productId, bool isActive) async {
    await _client
        .from('products')
        .update({'is_active': isActive}).eq('id', productId);
  }

  // ---------------------------------------------------------------------------
  // Members
  // ---------------------------------------------------------------------------

  Future<List<UserProfile>> getAllMembers() async {
    final data = await _client
        .from('profiles')
        .select()
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => UserProfile.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Order>> getMemberOrders(String userId) async {
    final data = await _client
        .from('orders')
        .select('*, order_items(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> toggleMemberAdmin(String userId, bool isAdmin) async {
    await _client
        .from('profiles')
        .update({'role': isAdmin ? 'admin' : 'customer'}).eq('id', userId);
  }

  Future<void> toggleMemberActive(String userId, bool isActive) async {
    await _client
        .from('profiles')
        .update({'is_active': isActive}).eq('id', userId);
  }

  Future<void> updateAdminNotes(String userId, String notes) async {
    await _client
        .from('profiles')
        .update({'admin_notes': notes}).eq('id', userId);
  }

  // ---------------------------------------------------------------------------
  // Settings
  // ---------------------------------------------------------------------------

  Future<Map<String, String>> getAllSettings() async {
    final data = await _client.from('settings').select();
    final map = <String, String>{};
    for (final row in data as List) {
      map[row['key'] as String] = row['value'] as String;
    }
    return map;
  }

  Future<void> updateSetting(String key, String value) async {
    await _client
        .from('settings')
        .upsert({'key': key, 'value': value}, onConflict: 'key');
  }
}
