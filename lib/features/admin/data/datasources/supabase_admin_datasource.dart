import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/models/announcement.dart';
import '../../../../core/models/site_page.dart';
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

  Future<String> createProduct(Map<String, dynamic> data) async {
    final result =
        await _client.from('products').insert(data).select('id').single();
    return result['id'] as String;
  }

  /// Replaces all images for [productId]:
  /// 1. Deletes all existing product_images rows.
  /// 2. Keeps [keptUrls] as-is (in order).
  /// 3. Uploads [newImages] bytes to storage, appended after kept.
  /// 4. Re-inserts product_images with sort_order 0,1,2...
  /// 5. Updates products.image_url to the first image URL.
  Future<void> replaceAllProductImages(
    String productId,
    List<String> keptUrls,
    List<Uint8List> newImages,
  ) async {
    // 1. Clear existing rows
    await _client
        .from('product_images')
        .delete()
        .eq('product_id', productId);

    // 2. Build final ordered URL list
    final allUrls = <String>[...keptUrls];

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < newImages.length; i++) {
      final path = '$productId/${timestamp}_$i.jpg';
      await _client.storage.from('product-images').uploadBinary(
            path,
            newImages[i],
            fileOptions:
                const FileOptions(contentType: 'image/jpeg', upsert: true),
          );
      allUrls.add(
          _client.storage.from('product-images').getPublicUrl(path));
    }

    // 3. Insert fresh rows
    for (int i = 0; i < allUrls.length; i++) {
      await _client.from('product_images').insert({
        'product_id': productId,
        'url': allUrls[i],
        'sort_order': i,
        'is_primary': i == 0,
      });
    }

    // 4. Update cover image
    await _client.from('products').update({
      'image_url': allUrls.isNotEmpty ? allUrls.first : null,
    }).eq('id', productId);
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

  // ---------------------------------------------------------------------------
  // Pages
  // ---------------------------------------------------------------------------

  Future<List<SitePage>> getAllPages() async {
    final data = await _client.from('pages').select().order('key');
    return (data as List)
        .map((e) => SitePage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> updatePage(String key, String title, String content) async {
    await _client.from('pages').update({
      'title': title,
      'content': content,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('key', key);
  }

  // ---------------------------------------------------------------------------
  // Announcements
  // ---------------------------------------------------------------------------

  Future<List<Announcement>> getAllAnnouncements() async {
    final data = await _client
        .from('announcements')
        .select()
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => Announcement.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String> createAnnouncement(Map<String, dynamic> data) async {
    final result = await _client
        .from('announcements')
        .insert(data)
        .select('id')
        .single();
    return result['id'] as String;
  }

  Future<void> updateAnnouncement(
      String id, Map<String, dynamic> data) async {
    await _client.from('announcements').update(data).eq('id', id);
  }

  Future<void> deleteAnnouncement(String id) async {
    await _client.from('announcements').delete().eq('id', id);
  }

  Future<void> toggleAnnouncementPublished(
      String id, bool isPublished) async {
    await _client
        .from('announcements')
        .update({'is_published': isPublished}).eq('id', id);
  }
}
