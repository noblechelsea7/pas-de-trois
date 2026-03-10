import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/cart_item.dart';

export '../../domain/models/cart_item.dart';

part 'cart_providers.g.dart';

/// In-memory cart: cartKey → CartItem.
/// The key uniquely identifies a product+variant combination.
@riverpod
class CartItems extends _$CartItems {
  @override
  Map<String, CartItem> build() => {};

  void add(
    String productId, {
    Map<String, String> selectedVariants = const {},
    int quantity = 1,
  }) {
    final item = CartItem(
      productId: productId,
      quantity: quantity,
      selectedVariants: selectedVariants,
    );
    final key = item.key;
    final existing = state[key];
    state = {
      ...state,
      key: existing != null
          ? existing.copyWith(quantity: existing.quantity + quantity)
          : item,
    };
  }

  void updateQuantity(String cartKey, int quantity) {
    if (quantity <= 0) {
      remove(cartKey);
    } else {
      final item = state[cartKey];
      if (item != null) {
        state = {...state, cartKey: item.copyWith(quantity: quantity)};
      }
    }
  }

  void remove(String cartKey) {
    final next = {...state}..remove(cartKey);
    state = next;
  }

  void clear() => state = {};

  int get totalItemCount =>
      state.values.fold(0, (sum, item) => sum + item.quantity);
}
