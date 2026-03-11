import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../products/domain/models/product.dart';

class SupabaseWishlistDataSource {
  const SupabaseWishlistDataSource(this._client);
  final SupabaseClient _client;

  Future<List<String>> getWishlistProductIds(String userId) async {
    final data = await _client
        .from('wishlists')
        .select('product_id')
        .eq('user_id', userId);
    return (data as List)
        .map((e) => (e as Map<String, dynamic>)['product_id'] as String)
        .toList();
  }

  Future<List<Product>> getWishlistProducts(String userId) async {
    final data = await _client
        .from('wishlists')
        .select('products(*, product_images(*))')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) =>
            Product.fromJson((e as Map<String, dynamic>)['products']
                as Map<String, dynamic>))
        .toList();
  }

  Future<void> addToWishlist(String userId, String productId) async {
    await _client.from('wishlists').insert({
      'user_id': userId,
      'product_id': productId,
    });
  }

  Future<void> removeFromWishlist(String userId, String productId) async {
    await _client
        .from('wishlists')
        .delete()
        .eq('user_id', userId)
        .eq('product_id', productId);
  }
}
