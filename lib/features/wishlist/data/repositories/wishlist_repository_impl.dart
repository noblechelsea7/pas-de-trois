import '../../../products/domain/models/product.dart';
import '../../domain/interfaces/i_wishlist_repository.dart';
import '../datasources/supabase_wishlist_datasource.dart';

class WishlistRepositoryImpl implements IWishlistRepository {
  const WishlistRepositoryImpl(this._datasource, this._userId);
  final SupabaseWishlistDataSource _datasource;
  final String _userId;

  @override
  Future<List<String>> getWishlistProductIds() =>
      _datasource.getWishlistProductIds(_userId);

  @override
  Future<List<Product>> getWishlistProducts() =>
      _datasource.getWishlistProducts(_userId);

  @override
  Future<void> addToWishlist(String productId) =>
      _datasource.addToWishlist(_userId, productId);

  @override
  Future<void> removeFromWishlist(String productId) =>
      _datasource.removeFromWishlist(_userId, productId);
}
