// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productRepositoryHash() => r'e2363fea8bce1ce4bbef6d36f3db7c2403892d0e';

/// See also [productRepository].
@ProviderFor(productRepository)
final productRepositoryProvider =
    AutoDisposeProvider<IProductRepository>.internal(
      productRepository,
      name: r'productRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$productRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProductRepositoryRef = AutoDisposeProviderRef<IProductRepository>;
String _$productSettingsHash() => r'ebc5f8c9a1ff15e2e38aa3db2adf29c19ca71e2d';

/// See also [productSettings].
@ProviderFor(productSettings)
final productSettingsProvider =
    AutoDisposeFutureProvider<Map<String, String>>.internal(
      productSettings,
      name: r'productSettingsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$productSettingsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProductSettingsRef = AutoDisposeFutureProviderRef<Map<String, String>>;
String _$categoriesHash() => r'82f7f2d45dcbc63d237482a182960538ec286dd3';

/// See also [categories].
@ProviderFor(categories)
final categoriesProvider = AutoDisposeFutureProvider<List<Category>>.internal(
  categories,
  name: r'categoriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CategoriesRef = AutoDisposeFutureProviderRef<List<Category>>;
String _$productsHash() => r'e0e1313bb27150bae5369a87bcf5e3f8ecd375bf';

/// See also [products].
@ProviderFor(products)
final productsProvider = AutoDisposeFutureProvider<List<Product>>.internal(
  products,
  name: r'productsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProductsRef = AutoDisposeFutureProviderRef<List<Product>>;
String _$productByIdHash() => r'806dc53bb036e038cf26d998498a704e66123288';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [productById].
@ProviderFor(productById)
const productByIdProvider = ProductByIdFamily();

/// See also [productById].
class ProductByIdFamily extends Family<AsyncValue<Product>> {
  /// See also [productById].
  const ProductByIdFamily();

  /// See also [productById].
  ProductByIdProvider call(String productId) {
    return ProductByIdProvider(productId);
  }

  @override
  ProductByIdProvider getProviderOverride(
    covariant ProductByIdProvider provider,
  ) {
    return call(provider.productId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'productByIdProvider';
}

/// See also [productById].
class ProductByIdProvider extends AutoDisposeFutureProvider<Product> {
  /// See also [productById].
  ProductByIdProvider(String productId)
    : this._internal(
        (ref) => productById(ref as ProductByIdRef, productId),
        from: productByIdProvider,
        name: r'productByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$productByIdHash,
        dependencies: ProductByIdFamily._dependencies,
        allTransitiveDependencies: ProductByIdFamily._allTransitiveDependencies,
        productId: productId,
      );

  ProductByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.productId,
  }) : super.internal();

  final String productId;

  @override
  Override overrideWith(
    FutureOr<Product> Function(ProductByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProductByIdProvider._internal(
        (ref) => create(ref as ProductByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        productId: productId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Product> createElement() {
    return _ProductByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductByIdProvider && other.productId == productId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, productId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProductByIdRef on AutoDisposeFutureProviderRef<Product> {
  /// The parameter `productId` of this provider.
  String get productId;
}

class _ProductByIdProviderElement
    extends AutoDisposeFutureProviderElement<Product>
    with ProductByIdRef {
  _ProductByIdProviderElement(super.provider);

  @override
  String get productId => (origin as ProductByIdProvider).productId;
}

String _$selectedVariantsHash() => r'84cc04ef25b777369c2bbd6d70aea25695b83e28';

abstract class _$SelectedVariants
    extends BuildlessAutoDisposeNotifier<Map<String, String>> {
  late final String productId;

  Map<String, String> build(String productId);
}

/// See also [SelectedVariants].
@ProviderFor(SelectedVariants)
const selectedVariantsProvider = SelectedVariantsFamily();

/// See also [SelectedVariants].
class SelectedVariantsFamily extends Family<Map<String, String>> {
  /// See also [SelectedVariants].
  const SelectedVariantsFamily();

  /// See also [SelectedVariants].
  SelectedVariantsProvider call(String productId) {
    return SelectedVariantsProvider(productId);
  }

  @override
  SelectedVariantsProvider getProviderOverride(
    covariant SelectedVariantsProvider provider,
  ) {
    return call(provider.productId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'selectedVariantsProvider';
}

/// See also [SelectedVariants].
class SelectedVariantsProvider
    extends
        AutoDisposeNotifierProviderImpl<SelectedVariants, Map<String, String>> {
  /// See also [SelectedVariants].
  SelectedVariantsProvider(String productId)
    : this._internal(
        () => SelectedVariants()..productId = productId,
        from: selectedVariantsProvider,
        name: r'selectedVariantsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$selectedVariantsHash,
        dependencies: SelectedVariantsFamily._dependencies,
        allTransitiveDependencies:
            SelectedVariantsFamily._allTransitiveDependencies,
        productId: productId,
      );

  SelectedVariantsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.productId,
  }) : super.internal();

  final String productId;

  @override
  Map<String, String> runNotifierBuild(covariant SelectedVariants notifier) {
    return notifier.build(productId);
  }

  @override
  Override overrideWith(SelectedVariants Function() create) {
    return ProviderOverride(
      origin: this,
      override: SelectedVariantsProvider._internal(
        () => create()..productId = productId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        productId: productId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<SelectedVariants, Map<String, String>>
  createElement() {
    return _SelectedVariantsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SelectedVariantsProvider && other.productId == productId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, productId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SelectedVariantsRef
    on AutoDisposeNotifierProviderRef<Map<String, String>> {
  /// The parameter `productId` of this provider.
  String get productId;
}

class _SelectedVariantsProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          SelectedVariants,
          Map<String, String>
        >
    with SelectedVariantsRef {
  _SelectedVariantsProviderElement(super.provider);

  @override
  String get productId => (origin as SelectedVariantsProvider).productId;
}

String _$productDetailQuantityHash() =>
    r'2ea3d2407362ef7a2c637665933e638ba8bbd78e';

abstract class _$ProductDetailQuantity
    extends BuildlessAutoDisposeNotifier<int> {
  late final String productId;

  int build(String productId);
}

/// See also [ProductDetailQuantity].
@ProviderFor(ProductDetailQuantity)
const productDetailQuantityProvider = ProductDetailQuantityFamily();

/// See also [ProductDetailQuantity].
class ProductDetailQuantityFamily extends Family<int> {
  /// See also [ProductDetailQuantity].
  const ProductDetailQuantityFamily();

  /// See also [ProductDetailQuantity].
  ProductDetailQuantityProvider call(String productId) {
    return ProductDetailQuantityProvider(productId);
  }

  @override
  ProductDetailQuantityProvider getProviderOverride(
    covariant ProductDetailQuantityProvider provider,
  ) {
    return call(provider.productId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'productDetailQuantityProvider';
}

/// See also [ProductDetailQuantity].
class ProductDetailQuantityProvider
    extends AutoDisposeNotifierProviderImpl<ProductDetailQuantity, int> {
  /// See also [ProductDetailQuantity].
  ProductDetailQuantityProvider(String productId)
    : this._internal(
        () => ProductDetailQuantity()..productId = productId,
        from: productDetailQuantityProvider,
        name: r'productDetailQuantityProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$productDetailQuantityHash,
        dependencies: ProductDetailQuantityFamily._dependencies,
        allTransitiveDependencies:
            ProductDetailQuantityFamily._allTransitiveDependencies,
        productId: productId,
      );

  ProductDetailQuantityProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.productId,
  }) : super.internal();

  final String productId;

  @override
  int runNotifierBuild(covariant ProductDetailQuantity notifier) {
    return notifier.build(productId);
  }

  @override
  Override overrideWith(ProductDetailQuantity Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProductDetailQuantityProvider._internal(
        () => create()..productId = productId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        productId: productId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ProductDetailQuantity, int>
  createElement() {
    return _ProductDetailQuantityProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductDetailQuantityProvider &&
        other.productId == productId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, productId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProductDetailQuantityRef on AutoDisposeNotifierProviderRef<int> {
  /// The parameter `productId` of this provider.
  String get productId;
}

class _ProductDetailQuantityProviderElement
    extends AutoDisposeNotifierProviderElement<ProductDetailQuantity, int>
    with ProductDetailQuantityRef {
  _ProductDetailQuantityProviderElement(super.provider);

  @override
  String get productId => (origin as ProductDetailQuantityProvider).productId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
