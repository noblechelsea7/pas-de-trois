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
    return '$productId|$variantLabel';
  }

  /// Variant string stored in Supabase: "尺寸:M|顏色:黑" or "" if no variants.
  String get variantLabel {
    if (selectedVariants.isEmpty) return '';
    final sorted = selectedVariants.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return sorted.map((e) => '${e.key}:${e.value}').join('|');
  }

  /// Reconstruct CartItem from a Supabase cart_items row.
  factory CartItem.fromRemote(Map<String, dynamic> json) {
    final label = json['variant_label'] as String? ?? '';
    return CartItem(
      productId: json['product_id'] as String,
      quantity: json['quantity'] as int,
      selectedVariants: _parseVariantLabel(label),
    );
  }

  /// Parse "尺寸:M|顏色:黑" → {"尺寸": "M", "顏色": "黑"}
  static Map<String, String> _parseVariantLabel(String label) {
    if (label.isEmpty) return {};
    return Map.fromEntries(
      label.split('|').map((pair) {
        final colonIndex = pair.indexOf(':');
        if (colonIndex == -1) return MapEntry(pair, '');
        return MapEntry(
          pair.substring(0, colonIndex),
          pair.substring(colonIndex + 1),
        );
      }),
    );
  }

  CartItem copyWith({int? quantity}) => CartItem(
        productId: productId,
        quantity: quantity ?? this.quantity,
        selectedVariants: selectedVariants,
      );
}
