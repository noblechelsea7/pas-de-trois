// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductImageImpl _$$ProductImageImplFromJson(Map<String, dynamic> json) =>
    _$ProductImageImpl(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      url: json['url'] as String,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isPrimary: json['is_primary'] as bool? ?? false,
    );

Map<String, dynamic> _$$ProductImageImplToJson(_$ProductImageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_id': instance.productId,
      'url': instance.url,
      'sort_order': instance.sortOrder,
      'is_primary': instance.isPrimary,
    };

_$ProductVariantImpl _$$ProductVariantImplFromJson(Map<String, dynamic> json) =>
    _$ProductVariantImpl(
      name: json['name'] as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$ProductVariantImplToJson(
  _$ProductVariantImpl instance,
) => <String, dynamic>{'name': instance.name, 'options': instance.options};

_$ProductImpl _$$ProductImplFromJson(Map<String, dynamic> json) =>
    _$ProductImpl(
      id: json['id'] as String,
      categoryId: json['category_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      sizeInfo: json['size_info'] as String?,
      krwPrice: (json['krw_price'] as num).toInt(),
      twdPrice: (json['twd_price'] as num).toInt(),
      weightKg: _weightFromJson(json['weight_kg']),
      domesticShippingFee:
          (json['domestic_shipping_fee'] as num?)?.toInt() ?? 0,
      purchaseCount: (json['purchase_count'] as num?)?.toInt() ?? 0,
      sourceUrl: json['source_url'] as String?,
      socialLink: json['social_link'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: _dateTimeFromJson(json['created_at'] as String),
      images: json['product_images'] == null
          ? const []
          : _imagesFromJson(json['product_images']),
      variants: json['variants'] == null
          ? const []
          : _variantsFromJson(json['variants']),
    );

Map<String, dynamic> _$$ProductImplToJson(_$ProductImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category_id': instance.categoryId,
      'name': instance.name,
      'description': instance.description,
      'size_info': instance.sizeInfo,
      'krw_price': instance.krwPrice,
      'twd_price': instance.twdPrice,
      'weight_kg': instance.weightKg,
      'domestic_shipping_fee': instance.domesticShippingFee,
      'purchase_count': instance.purchaseCount,
      'source_url': instance.sourceUrl,
      'social_link': instance.socialLink,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'product_images': instance.images,
      'variants': instance.variants,
    };
