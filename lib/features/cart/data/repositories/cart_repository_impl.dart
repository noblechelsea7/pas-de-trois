import '../../domain/interfaces/i_cart_repository.dart';
import '../../domain/models/cart_item.dart';
import '../datasources/supabase_cart_datasource.dart';

class CartRepositoryImpl implements ICartRepository {
  const CartRepositoryImpl(this._datasource);
  final SupabaseCartDataSource _datasource;

  @override
  Future<List<CartItem>> getCartItems() => _datasource.getCartItems();

  @override
  Future<void> upsertItem(CartItem item) => _datasource.upsertItem(item);

  @override
  Future<void> removeItem(CartItem item) => _datasource.removeItem(item);

  @override
  Future<void> clearCart() => _datasource.clearCart();
}
