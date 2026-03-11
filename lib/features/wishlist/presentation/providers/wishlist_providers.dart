import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../products/domain/models/product.dart';
import '../../data/datasources/supabase_wishlist_datasource.dart';
import '../../data/repositories/wishlist_repository_impl.dart';
import '../../domain/interfaces/i_wishlist_repository.dart';

part 'wishlist_providers.g.dart';

// ---------------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------------

@riverpod
IWishlistRepository? wishlistRepository(Ref ref) {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return null;
  return WishlistRepositoryImpl(
    SupabaseWishlistDataSource(Supabase.instance.client),
    userId,
  );
}

// ---------------------------------------------------------------------------
// Wishlist product-id list (source of truth)
// ---------------------------------------------------------------------------

@riverpod
Future<List<String>> wishlist(Ref ref) async {
  final repo = ref.watch(wishlistRepositoryProvider);
  if (repo == null) return [];
  return repo.getWishlistProductIds();
}

// ---------------------------------------------------------------------------
// Per-product: is this product in the wishlist?
// ---------------------------------------------------------------------------

@riverpod
bool isWished(Ref ref, String productId) {
  final ids = ref.watch(wishlistProvider).valueOrNull ?? [];
  return ids.contains(productId);
}

// ---------------------------------------------------------------------------
// Full product data for wishlist screen
// ---------------------------------------------------------------------------

@riverpod
Future<List<Product>> wishlistProducts(Ref ref) async {
  final repo = ref.watch(wishlistRepositoryProvider);
  if (repo == null) return [];
  return repo.getWishlistProducts();
}

// ---------------------------------------------------------------------------
// Toggle helper (called from UI, invalidates providers after mutation)
// ---------------------------------------------------------------------------

Future<void> toggleWishlist(
  WidgetRef ref,
  String productId, {
  required bool currentlyWished,
}) async {
  final repo = ref.read(wishlistRepositoryProvider);
  if (repo == null) return;
  if (currentlyWished) {
    await repo.removeFromWishlist(productId);
  } else {
    await repo.addToWishlist(productId);
  }
  ref.invalidate(wishlistProvider);
  ref.invalidate(wishlistProductsProvider);
}
