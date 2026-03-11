import '../../../products/domain/models/product.dart';

abstract interface class IWishlistRepository {
  Future<List<String>> getWishlistProductIds();
  Future<List<Product>> getWishlistProducts();
  Future<void> addToWishlist(String productId);
  Future<void> removeFromWishlist(String productId);
}
