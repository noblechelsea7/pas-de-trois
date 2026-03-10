// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

// Supabase numeric(6,3) can come back as String "0.500"
double _weightFromJson(dynamic v) =>
    v is num ? v.toDouble() : double.parse(v.toString());

DateTime _dateTimeFromJson(String v) {
  final normalized = RegExp(r'[+-]\d{2}$').hasMatch(v) ? '$v:00' : v;
  return DateTime.parse(normalized);
}

List<ProductImage> _imagesFromJson(dynamic v) {
  if (v == null) return [];
  return (v as List)
      .map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
      .toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
}

List<ProductVariant> _variantsFromJson(dynamic v) {
  if (v == null) return [];
  return (v as List)
      .map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
      .toList();
}

@freezed
class ProductImage with _$ProductImage {
  const factory ProductImage({
    required String id,
    @JsonKey(name: 'product_id') required String productId,
    required String url,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
    @JsonKey(name: 'is_primary') @Default(false) bool isPrimary,
  }) = _ProductImage;

  factory ProductImage.fromJson(Map<String, dynamic> json) =>
      _$ProductImageFromJson(json);
}

@freezed
class ProductVariant with _$ProductVariant {
  const factory ProductVariant({
    required String name,
    required List<String> options,
  }) = _ProductVariant;

  factory ProductVariant.fromJson(Map<String, dynamic> json) =>
      _$ProductVariantFromJson(json);
}

@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    @JsonKey(name: 'category_id') String? categoryId,
    required String name,
    String? description,
    @JsonKey(name: 'size_info') String? sizeInfo,
    @JsonKey(name: 'krw_price') required int krwPrice,
    @JsonKey(name: 'twd_price') required int twdPrice,
    @JsonKey(name: 'weight_kg', fromJson: _weightFromJson) required double weightKg,
    @JsonKey(name: 'domestic_shipping_fee') @Default(0) int domesticShippingFee,
    @JsonKey(name: 'purchase_count') @Default(0) int purchaseCount,
    @JsonKey(name: 'source_url') String? sourceUrl,
    @JsonKey(name: 'social_link') String? socialLink,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at', fromJson: _dateTimeFromJson) required DateTime createdAt,
    @JsonKey(name: 'product_images', fromJson: _imagesFromJson) @Default([]) List<ProductImage> images,
    @JsonKey(name: 'variants', fromJson: _variantsFromJson) @Default([]) List<ProductVariant> variants,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
