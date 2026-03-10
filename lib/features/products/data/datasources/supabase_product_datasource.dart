import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/category.dart';
import '../../domain/models/product.dart';

class SupabaseProductDatasource {
  const SupabaseProductDatasource(this._client);
  final SupabaseClient _client;

  Future<List<Category>> getCategories() async {
    final data = await _client
        .from('categories')
        .select()
        .eq('is_active', true)
        .order('sort_order');
    return (data as List)
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Product>> getProducts({
    String? categoryId,
    String? query,
  }) async {
    var builder = _client
        .from('products')
        .select('*, product_images(*)')
        .eq('is_active', true);

    if (categoryId != null) {
      builder = builder.eq('category_id', categoryId);
    }
    if (query != null && query.isNotEmpty) {
      builder = builder.ilike('name', '%$query%');
    }

    final data = await builder.order('created_at', ascending: false);
    return (data as List)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Product> getProductById(String id) async {
    final data = await _client
        .from('products')
        .select('*, product_images(*)')
        .eq('id', id)
        .single();
    return Product.fromJson(data);
  }

  Future<Map<String, String>> getSettings() async {
    final data = await _client.from('settings').select('key, value');
    return {
      for (final e in data as List)
        (e as Map<String, dynamic>)['key'] as String:
            e['value'] as String,
    };
  }
}
