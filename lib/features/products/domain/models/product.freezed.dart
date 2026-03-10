// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProductImage _$ProductImageFromJson(Map<String, dynamic> json) {
  return _ProductImage.fromJson(json);
}

/// @nodoc
mixin _$ProductImage {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_id')
  String get productId => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  @JsonKey(name: 'sort_order')
  int get sortOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_primary')
  bool get isPrimary => throw _privateConstructorUsedError;

  /// Serializes this ProductImage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductImage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductImageCopyWith<ProductImage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductImageCopyWith<$Res> {
  factory $ProductImageCopyWith(
    ProductImage value,
    $Res Function(ProductImage) then,
  ) = _$ProductImageCopyWithImpl<$Res, ProductImage>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'product_id') String productId,
    String url,
    @JsonKey(name: 'sort_order') int sortOrder,
    @JsonKey(name: 'is_primary') bool isPrimary,
  });
}

/// @nodoc
class _$ProductImageCopyWithImpl<$Res, $Val extends ProductImage>
    implements $ProductImageCopyWith<$Res> {
  _$ProductImageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductImage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? url = null,
    Object? sortOrder = null,
    Object? isPrimary = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String,
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            isPrimary: null == isPrimary
                ? _value.isPrimary
                : isPrimary // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductImageImplCopyWith<$Res>
    implements $ProductImageCopyWith<$Res> {
  factory _$$ProductImageImplCopyWith(
    _$ProductImageImpl value,
    $Res Function(_$ProductImageImpl) then,
  ) = __$$ProductImageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'product_id') String productId,
    String url,
    @JsonKey(name: 'sort_order') int sortOrder,
    @JsonKey(name: 'is_primary') bool isPrimary,
  });
}

/// @nodoc
class __$$ProductImageImplCopyWithImpl<$Res>
    extends _$ProductImageCopyWithImpl<$Res, _$ProductImageImpl>
    implements _$$ProductImageImplCopyWith<$Res> {
  __$$ProductImageImplCopyWithImpl(
    _$ProductImageImpl _value,
    $Res Function(_$ProductImageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductImage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? url = null,
    Object? sortOrder = null,
    Object? isPrimary = null,
  }) {
    return _then(
      _$ProductImageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        isPrimary: null == isPrimary
            ? _value.isPrimary
            : isPrimary // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductImageImpl implements _ProductImage {
  const _$ProductImageImpl({
    required this.id,
    @JsonKey(name: 'product_id') required this.productId,
    required this.url,
    @JsonKey(name: 'sort_order') this.sortOrder = 0,
    @JsonKey(name: 'is_primary') this.isPrimary = false,
  });

  factory _$ProductImageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductImageImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'product_id')
  final String productId;
  @override
  final String url;
  @override
  @JsonKey(name: 'sort_order')
  final int sortOrder;
  @override
  @JsonKey(name: 'is_primary')
  final bool isPrimary;

  @override
  String toString() {
    return 'ProductImage(id: $id, productId: $productId, url: $url, sortOrder: $sortOrder, isPrimary: $isPrimary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductImageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isPrimary, isPrimary) ||
                other.isPrimary == isPrimary));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, productId, url, sortOrder, isPrimary);

  /// Create a copy of ProductImage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductImageImplCopyWith<_$ProductImageImpl> get copyWith =>
      __$$ProductImageImplCopyWithImpl<_$ProductImageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductImageImplToJson(this);
  }
}

abstract class _ProductImage implements ProductImage {
  const factory _ProductImage({
    required final String id,
    @JsonKey(name: 'product_id') required final String productId,
    required final String url,
    @JsonKey(name: 'sort_order') final int sortOrder,
    @JsonKey(name: 'is_primary') final bool isPrimary,
  }) = _$ProductImageImpl;

  factory _ProductImage.fromJson(Map<String, dynamic> json) =
      _$ProductImageImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'product_id')
  String get productId;
  @override
  String get url;
  @override
  @JsonKey(name: 'sort_order')
  int get sortOrder;
  @override
  @JsonKey(name: 'is_primary')
  bool get isPrimary;

  /// Create a copy of ProductImage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductImageImplCopyWith<_$ProductImageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProductVariant _$ProductVariantFromJson(Map<String, dynamic> json) {
  return _ProductVariant.fromJson(json);
}

/// @nodoc
mixin _$ProductVariant {
  String get name => throw _privateConstructorUsedError;
  List<String> get options => throw _privateConstructorUsedError;

  /// Serializes this ProductVariant to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductVariant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductVariantCopyWith<ProductVariant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductVariantCopyWith<$Res> {
  factory $ProductVariantCopyWith(
    ProductVariant value,
    $Res Function(ProductVariant) then,
  ) = _$ProductVariantCopyWithImpl<$Res, ProductVariant>;
  @useResult
  $Res call({String name, List<String> options});
}

/// @nodoc
class _$ProductVariantCopyWithImpl<$Res, $Val extends ProductVariant>
    implements $ProductVariantCopyWith<$Res> {
  _$ProductVariantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductVariant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? options = null}) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            options: null == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductVariantImplCopyWith<$Res>
    implements $ProductVariantCopyWith<$Res> {
  factory _$$ProductVariantImplCopyWith(
    _$ProductVariantImpl value,
    $Res Function(_$ProductVariantImpl) then,
  ) = __$$ProductVariantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, List<String> options});
}

/// @nodoc
class __$$ProductVariantImplCopyWithImpl<$Res>
    extends _$ProductVariantCopyWithImpl<$Res, _$ProductVariantImpl>
    implements _$$ProductVariantImplCopyWith<$Res> {
  __$$ProductVariantImplCopyWithImpl(
    _$ProductVariantImpl _value,
    $Res Function(_$ProductVariantImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductVariant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? options = null}) {
    return _then(
      _$ProductVariantImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        options: null == options
            ? _value._options
            : options // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductVariantImpl implements _ProductVariant {
  const _$ProductVariantImpl({
    required this.name,
    required final List<String> options,
  }) : _options = options;

  factory _$ProductVariantImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductVariantImplFromJson(json);

  @override
  final String name;
  final List<String> _options;
  @override
  List<String> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  String toString() {
    return 'ProductVariant(name: $name, options: $options)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductVariantImpl &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._options, _options));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    const DeepCollectionEquality().hash(_options),
  );

  /// Create a copy of ProductVariant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductVariantImplCopyWith<_$ProductVariantImpl> get copyWith =>
      __$$ProductVariantImplCopyWithImpl<_$ProductVariantImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductVariantImplToJson(this);
  }
}

abstract class _ProductVariant implements ProductVariant {
  const factory _ProductVariant({
    required final String name,
    required final List<String> options,
  }) = _$ProductVariantImpl;

  factory _ProductVariant.fromJson(Map<String, dynamic> json) =
      _$ProductVariantImpl.fromJson;

  @override
  String get name;
  @override
  List<String> get options;

  /// Create a copy of ProductVariant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductVariantImplCopyWith<_$ProductVariantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Product _$ProductFromJson(Map<String, dynamic> json) {
  return _Product.fromJson(json);
}

/// @nodoc
mixin _$Product {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_id')
  String? get categoryId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'size_info')
  String? get sizeInfo => throw _privateConstructorUsedError;
  @JsonKey(name: 'krw_price')
  int get krwPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'twd_price')
  int get twdPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'weight_kg', fromJson: _weightFromJson)
  double get weightKg => throw _privateConstructorUsedError;
  @JsonKey(name: 'domestic_shipping_fee')
  int get domesticShippingFee => throw _privateConstructorUsedError;
  @JsonKey(name: 'purchase_count')
  int get purchaseCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'source_url')
  String? get sourceUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'social_link')
  String? get socialLink => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at', fromJson: _dateTimeFromJson)
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_images', fromJson: _imagesFromJson)
  List<ProductImage> get images => throw _privateConstructorUsedError;
  @JsonKey(name: 'variants', fromJson: _variantsFromJson)
  List<ProductVariant> get variants => throw _privateConstructorUsedError;

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductCopyWith<Product> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductCopyWith<$Res> {
  factory $ProductCopyWith(Product value, $Res Function(Product) then) =
      _$ProductCopyWithImpl<$Res, Product>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'category_id') String? categoryId,
    String name,
    String? description,
    @JsonKey(name: 'size_info') String? sizeInfo,
    @JsonKey(name: 'krw_price') int krwPrice,
    @JsonKey(name: 'twd_price') int twdPrice,
    @JsonKey(name: 'weight_kg', fromJson: _weightFromJson) double weightKg,
    @JsonKey(name: 'domestic_shipping_fee') int domesticShippingFee,
    @JsonKey(name: 'purchase_count') int purchaseCount,
    @JsonKey(name: 'source_url') String? sourceUrl,
    @JsonKey(name: 'social_link') String? socialLink,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'created_at', fromJson: _dateTimeFromJson)
    DateTime createdAt,
    @JsonKey(name: 'product_images', fromJson: _imagesFromJson)
    List<ProductImage> images,
    @JsonKey(name: 'variants', fromJson: _variantsFromJson)
    List<ProductVariant> variants,
  });
}

/// @nodoc
class _$ProductCopyWithImpl<$Res, $Val extends Product>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? categoryId = freezed,
    Object? name = null,
    Object? description = freezed,
    Object? sizeInfo = freezed,
    Object? krwPrice = null,
    Object? twdPrice = null,
    Object? weightKg = null,
    Object? domesticShippingFee = null,
    Object? purchaseCount = null,
    Object? sourceUrl = freezed,
    Object? socialLink = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? images = null,
    Object? variants = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            categoryId: freezed == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String?,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            sizeInfo: freezed == sizeInfo
                ? _value.sizeInfo
                : sizeInfo // ignore: cast_nullable_to_non_nullable
                      as String?,
            krwPrice: null == krwPrice
                ? _value.krwPrice
                : krwPrice // ignore: cast_nullable_to_non_nullable
                      as int,
            twdPrice: null == twdPrice
                ? _value.twdPrice
                : twdPrice // ignore: cast_nullable_to_non_nullable
                      as int,
            weightKg: null == weightKg
                ? _value.weightKg
                : weightKg // ignore: cast_nullable_to_non_nullable
                      as double,
            domesticShippingFee: null == domesticShippingFee
                ? _value.domesticShippingFee
                : domesticShippingFee // ignore: cast_nullable_to_non_nullable
                      as int,
            purchaseCount: null == purchaseCount
                ? _value.purchaseCount
                : purchaseCount // ignore: cast_nullable_to_non_nullable
                      as int,
            sourceUrl: freezed == sourceUrl
                ? _value.sourceUrl
                : sourceUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            socialLink: freezed == socialLink
                ? _value.socialLink
                : socialLink // ignore: cast_nullable_to_non_nullable
                      as String?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            images: null == images
                ? _value.images
                : images // ignore: cast_nullable_to_non_nullable
                      as List<ProductImage>,
            variants: null == variants
                ? _value.variants
                : variants // ignore: cast_nullable_to_non_nullable
                      as List<ProductVariant>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductImplCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$$ProductImplCopyWith(
    _$ProductImpl value,
    $Res Function(_$ProductImpl) then,
  ) = __$$ProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'category_id') String? categoryId,
    String name,
    String? description,
    @JsonKey(name: 'size_info') String? sizeInfo,
    @JsonKey(name: 'krw_price') int krwPrice,
    @JsonKey(name: 'twd_price') int twdPrice,
    @JsonKey(name: 'weight_kg', fromJson: _weightFromJson) double weightKg,
    @JsonKey(name: 'domestic_shipping_fee') int domesticShippingFee,
    @JsonKey(name: 'purchase_count') int purchaseCount,
    @JsonKey(name: 'source_url') String? sourceUrl,
    @JsonKey(name: 'social_link') String? socialLink,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'created_at', fromJson: _dateTimeFromJson)
    DateTime createdAt,
    @JsonKey(name: 'product_images', fromJson: _imagesFromJson)
    List<ProductImage> images,
    @JsonKey(name: 'variants', fromJson: _variantsFromJson)
    List<ProductVariant> variants,
  });
}

/// @nodoc
class __$$ProductImplCopyWithImpl<$Res>
    extends _$ProductCopyWithImpl<$Res, _$ProductImpl>
    implements _$$ProductImplCopyWith<$Res> {
  __$$ProductImplCopyWithImpl(
    _$ProductImpl _value,
    $Res Function(_$ProductImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? categoryId = freezed,
    Object? name = null,
    Object? description = freezed,
    Object? sizeInfo = freezed,
    Object? krwPrice = null,
    Object? twdPrice = null,
    Object? weightKg = null,
    Object? domesticShippingFee = null,
    Object? purchaseCount = null,
    Object? sourceUrl = freezed,
    Object? socialLink = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? images = null,
    Object? variants = null,
  }) {
    return _then(
      _$ProductImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        categoryId: freezed == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        sizeInfo: freezed == sizeInfo
            ? _value.sizeInfo
            : sizeInfo // ignore: cast_nullable_to_non_nullable
                  as String?,
        krwPrice: null == krwPrice
            ? _value.krwPrice
            : krwPrice // ignore: cast_nullable_to_non_nullable
                  as int,
        twdPrice: null == twdPrice
            ? _value.twdPrice
            : twdPrice // ignore: cast_nullable_to_non_nullable
                  as int,
        weightKg: null == weightKg
            ? _value.weightKg
            : weightKg // ignore: cast_nullable_to_non_nullable
                  as double,
        domesticShippingFee: null == domesticShippingFee
            ? _value.domesticShippingFee
            : domesticShippingFee // ignore: cast_nullable_to_non_nullable
                  as int,
        purchaseCount: null == purchaseCount
            ? _value.purchaseCount
            : purchaseCount // ignore: cast_nullable_to_non_nullable
                  as int,
        sourceUrl: freezed == sourceUrl
            ? _value.sourceUrl
            : sourceUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        socialLink: freezed == socialLink
            ? _value.socialLink
            : socialLink // ignore: cast_nullable_to_non_nullable
                  as String?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        images: null == images
            ? _value._images
            : images // ignore: cast_nullable_to_non_nullable
                  as List<ProductImage>,
        variants: null == variants
            ? _value._variants
            : variants // ignore: cast_nullable_to_non_nullable
                  as List<ProductVariant>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductImpl implements _Product {
  const _$ProductImpl({
    required this.id,
    @JsonKey(name: 'category_id') this.categoryId,
    required this.name,
    this.description,
    @JsonKey(name: 'size_info') this.sizeInfo,
    @JsonKey(name: 'krw_price') required this.krwPrice,
    @JsonKey(name: 'twd_price') required this.twdPrice,
    @JsonKey(name: 'weight_kg', fromJson: _weightFromJson)
    required this.weightKg,
    @JsonKey(name: 'domestic_shipping_fee') this.domesticShippingFee = 0,
    @JsonKey(name: 'purchase_count') this.purchaseCount = 0,
    @JsonKey(name: 'source_url') this.sourceUrl,
    @JsonKey(name: 'social_link') this.socialLink,
    @JsonKey(name: 'is_active') this.isActive = true,
    @JsonKey(name: 'created_at', fromJson: _dateTimeFromJson)
    required this.createdAt,
    @JsonKey(name: 'product_images', fromJson: _imagesFromJson)
    final List<ProductImage> images = const [],
    @JsonKey(name: 'variants', fromJson: _variantsFromJson)
    final List<ProductVariant> variants = const [],
  }) : _images = images,
       _variants = variants;

  factory _$ProductImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'category_id')
  final String? categoryId;
  @override
  final String name;
  @override
  final String? description;
  @override
  @JsonKey(name: 'size_info')
  final String? sizeInfo;
  @override
  @JsonKey(name: 'krw_price')
  final int krwPrice;
  @override
  @JsonKey(name: 'twd_price')
  final int twdPrice;
  @override
  @JsonKey(name: 'weight_kg', fromJson: _weightFromJson)
  final double weightKg;
  @override
  @JsonKey(name: 'domestic_shipping_fee')
  final int domesticShippingFee;
  @override
  @JsonKey(name: 'purchase_count')
  final int purchaseCount;
  @override
  @JsonKey(name: 'source_url')
  final String? sourceUrl;
  @override
  @JsonKey(name: 'social_link')
  final String? socialLink;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'created_at', fromJson: _dateTimeFromJson)
  final DateTime createdAt;
  final List<ProductImage> _images;
  @override
  @JsonKey(name: 'product_images', fromJson: _imagesFromJson)
  List<ProductImage> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  final List<ProductVariant> _variants;
  @override
  @JsonKey(name: 'variants', fromJson: _variantsFromJson)
  List<ProductVariant> get variants {
    if (_variants is EqualUnmodifiableListView) return _variants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_variants);
  }

  @override
  String toString() {
    return 'Product(id: $id, categoryId: $categoryId, name: $name, description: $description, sizeInfo: $sizeInfo, krwPrice: $krwPrice, twdPrice: $twdPrice, weightKg: $weightKg, domesticShippingFee: $domesticShippingFee, purchaseCount: $purchaseCount, sourceUrl: $sourceUrl, socialLink: $socialLink, isActive: $isActive, createdAt: $createdAt, images: $images, variants: $variants)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.sizeInfo, sizeInfo) ||
                other.sizeInfo == sizeInfo) &&
            (identical(other.krwPrice, krwPrice) ||
                other.krwPrice == krwPrice) &&
            (identical(other.twdPrice, twdPrice) ||
                other.twdPrice == twdPrice) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.domesticShippingFee, domesticShippingFee) ||
                other.domesticShippingFee == domesticShippingFee) &&
            (identical(other.purchaseCount, purchaseCount) ||
                other.purchaseCount == purchaseCount) &&
            (identical(other.sourceUrl, sourceUrl) ||
                other.sourceUrl == sourceUrl) &&
            (identical(other.socialLink, socialLink) ||
                other.socialLink == socialLink) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            const DeepCollectionEquality().equals(other._variants, _variants));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    categoryId,
    name,
    description,
    sizeInfo,
    krwPrice,
    twdPrice,
    weightKg,
    domesticShippingFee,
    purchaseCount,
    sourceUrl,
    socialLink,
    isActive,
    createdAt,
    const DeepCollectionEquality().hash(_images),
    const DeepCollectionEquality().hash(_variants),
  );

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      __$$ProductImplCopyWithImpl<_$ProductImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductImplToJson(this);
  }
}

abstract class _Product implements Product {
  const factory _Product({
    required final String id,
    @JsonKey(name: 'category_id') final String? categoryId,
    required final String name,
    final String? description,
    @JsonKey(name: 'size_info') final String? sizeInfo,
    @JsonKey(name: 'krw_price') required final int krwPrice,
    @JsonKey(name: 'twd_price') required final int twdPrice,
    @JsonKey(name: 'weight_kg', fromJson: _weightFromJson)
    required final double weightKg,
    @JsonKey(name: 'domestic_shipping_fee') final int domesticShippingFee,
    @JsonKey(name: 'purchase_count') final int purchaseCount,
    @JsonKey(name: 'source_url') final String? sourceUrl,
    @JsonKey(name: 'social_link') final String? socialLink,
    @JsonKey(name: 'is_active') final bool isActive,
    @JsonKey(name: 'created_at', fromJson: _dateTimeFromJson)
    required final DateTime createdAt,
    @JsonKey(name: 'product_images', fromJson: _imagesFromJson)
    final List<ProductImage> images,
    @JsonKey(name: 'variants', fromJson: _variantsFromJson)
    final List<ProductVariant> variants,
  }) = _$ProductImpl;

  factory _Product.fromJson(Map<String, dynamic> json) = _$ProductImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'category_id')
  String? get categoryId;
  @override
  String get name;
  @override
  String? get description;
  @override
  @JsonKey(name: 'size_info')
  String? get sizeInfo;
  @override
  @JsonKey(name: 'krw_price')
  int get krwPrice;
  @override
  @JsonKey(name: 'twd_price')
  int get twdPrice;
  @override
  @JsonKey(name: 'weight_kg', fromJson: _weightFromJson)
  double get weightKg;
  @override
  @JsonKey(name: 'domestic_shipping_fee')
  int get domesticShippingFee;
  @override
  @JsonKey(name: 'purchase_count')
  int get purchaseCount;
  @override
  @JsonKey(name: 'source_url')
  String? get sourceUrl;
  @override
  @JsonKey(name: 'social_link')
  String? get socialLink;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'created_at', fromJson: _dateTimeFromJson)
  DateTime get createdAt;
  @override
  @JsonKey(name: 'product_images', fromJson: _imagesFromJson)
  List<ProductImage> get images;
  @override
  @JsonKey(name: 'variants', fromJson: _variantsFromJson)
  List<ProductVariant> get variants;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
