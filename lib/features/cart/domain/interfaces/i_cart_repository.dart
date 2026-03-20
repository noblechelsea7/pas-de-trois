import '../models/cart_item.dart';

abstract interface class ICartRepository {
  Future<List<CartItem>> getCartItems();
  Future<void> upsertItem(CartItem item);
  Future<void> removeItem(CartItem item);
  Future<void> clearCart();
}
