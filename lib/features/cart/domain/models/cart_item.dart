/// A single item in the shopping cart.
/// The [key] uniquely identifies a product+variant combination,
/// so the same product with different variants are separate cart items.
class CartItem {
  const CartItem({
    required this.productId,
    required this.quantity,
    this.selectedVariants = const {},
  });

  final String productId;
  final int quantity;

  /// e.g. {"尺寸": "M", "顏色": "黑"}
  final Map<String, String> selectedVariants;

  /// Stable, unique key derived from productId + sorted variants.
  String get key {
    if (selectedVariants.isEmpty) return productId;
    final sorted = selectedVariants.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final variantStr = sorted.map((e) => '${e.key}:${e.value}').join('|');
    return '$productId|$variantStr';
  }

  CartItem copyWith({int? quantity}) => CartItem(
        productId: productId,
        quantity: quantity ?? this.quantity,
        selectedVariants: selectedVariants,
      );
}
