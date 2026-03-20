import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/cart_item.dart';

class SupabaseCartDataSource {
  const SupabaseCartDataSource(this._client, this._userId);
  final SupabaseClient _client;
  final String _userId;

  Future<List<CartItem>> getCartItems() async {
    final data = await _client
        .from('cart_items')
        .select()
        .eq('user_id', _userId);
    return (data as List)
        .map((e) => CartItem.fromRemote(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> upsertItem(CartItem item) async {
    await _client.from('cart_items').upsert(
      {
        'user_id': _userId,
        'product_id': item.productId,
        'variant_label': item.variantLabel,
        'quantity': item.quantity,
      },
      onConflict: 'user_id,product_id,variant_label',
    );
  }

  Future<void> removeItem(CartItem item) async {
    await _client
        .from('cart_items')
        .delete()
        .eq('user_id', _userId)
        .eq('product_id', item.productId)
        .eq('variant_label', item.variantLabel);
  }

  Future<void> clearCart() async {
    await _client.from('cart_items').delete().eq('user_id', _userId);
  }
}
