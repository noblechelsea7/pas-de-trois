import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/supabase_product_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/interfaces/i_product_repository.dart';
import '../../domain/models/category.dart';
import '../../domain/models/product.dart';

part 'product_providers.g.dart';

// ---------------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------------

@riverpod
IProductRepository productRepository(Ref ref) {
  final client = Supabase.instance.client;
  return ProductRepositoryImpl(SupabaseProductDatasource(client));
}

// ---------------------------------------------------------------------------
// Settings (exchange rate, intl shipping rate, free shipping threshold)
// ---------------------------------------------------------------------------

@riverpod
Future<Map<String, String>> productSettings(Ref ref) =>
    ref.read(productRepositoryProvider).getSettings();

// ---------------------------------------------------------------------------
// Categories
// ---------------------------------------------------------------------------

@riverpod
Future<List<Category>> categories(Ref ref) =>
    ref.read(productRepositoryProvider).getCategories();

// ---------------------------------------------------------------------------
// Filter state (not code-generated — use plain StateProvider for simplicity)
// ---------------------------------------------------------------------------

final selectedCategoryProvider = StateProvider<String?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');

// ---------------------------------------------------------------------------
// Products list (filtered by category + search)
// ---------------------------------------------------------------------------

@riverpod
Future<List<Product>> products(Ref ref) {
  final categoryId = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider);
  return ref
      .read(productRepositoryProvider)
      .getProducts(categoryId: categoryId, query: query.isEmpty ? null : query);
}

// ---------------------------------------------------------------------------
// Single product by ID
// ---------------------------------------------------------------------------

@riverpod
Future<Product> productById(Ref ref, String productId) =>
    ref.read(productRepositoryProvider).getProductById(productId);

// ---------------------------------------------------------------------------
// Selected variants for product detail page
// Map<variantName, selectedOption>  e.g. {"尺寸": "M", "顏色": "黑"}
// ---------------------------------------------------------------------------

@riverpod
class SelectedVariants extends _$SelectedVariants {
  @override
  Map<String, String> build(String productId) => {};

  void select(String variantName, String option) {
    state = {...state, variantName: option};
  }

  void reset() => state = {};
}

// ---------------------------------------------------------------------------
// Quantity selector for product detail page (shared with bottom bar)
// ---------------------------------------------------------------------------

@riverpod
class ProductDetailQuantity extends _$ProductDetailQuantity {
  @override
  int build(String productId) => 1;

  void increment() {
    if (state < 10) state = state + 1;
  }

  void decrement() {
    if (state > 1) state = state - 1;
  }

  void reset() => state = 1;
}
