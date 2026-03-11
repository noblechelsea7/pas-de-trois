// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$wishlistRepositoryHash() =>
    r'5232360e0723101ce4f77eb7ca15c64657143f44';

/// See also [wishlistRepository].
@ProviderFor(wishlistRepository)
final wishlistRepositoryProvider =
    AutoDisposeProvider<IWishlistRepository?>.internal(
      wishlistRepository,
      name: r'wishlistRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$wishlistRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WishlistRepositoryRef = AutoDisposeProviderRef<IWishlistRepository?>;
String _$wishlistHash() => r'21d5b057850bc73c2ba338c95816834c8c385479';

/// See also [wishlist].
@ProviderFor(wishlist)
final wishlistProvider = AutoDisposeFutureProvider<List<String>>.internal(
  wishlist,
  name: r'wishlistProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$wishlistHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WishlistRef = AutoDisposeFutureProviderRef<List<String>>;
String _$isWishedHash() => r'be82a700b09e0af9dded6f052223bc2ffe292c27';

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

/// See also [isWished].
@ProviderFor(isWished)
const isWishedProvider = IsWishedFamily();

/// See also [isWished].
class IsWishedFamily extends Family<bool> {
  /// See also [isWished].
  const IsWishedFamily();

  /// See also [isWished].
  IsWishedProvider call(String productId) {
    return IsWishedProvider(productId);
  }

  @override
  IsWishedProvider getProviderOverride(covariant IsWishedProvider provider) {
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
  String? get name => r'isWishedProvider';
}

/// See also [isWished].
class IsWishedProvider extends AutoDisposeProvider<bool> {
  /// See also [isWished].
  IsWishedProvider(String productId)
    : this._internal(
        (ref) => isWished(ref as IsWishedRef, productId),
        from: isWishedProvider,
        name: r'isWishedProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$isWishedHash,
        dependencies: IsWishedFamily._dependencies,
        allTransitiveDependencies: IsWishedFamily._allTransitiveDependencies,
        productId: productId,
      );

  IsWishedProvider._internal(
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
  Override overrideWith(bool Function(IsWishedRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: IsWishedProvider._internal(
        (ref) => create(ref as IsWishedRef),
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
  AutoDisposeProviderElement<bool> createElement() {
    return _IsWishedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsWishedProvider && other.productId == productId;
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
mixin IsWishedRef on AutoDisposeProviderRef<bool> {
  /// The parameter `productId` of this provider.
  String get productId;
}

class _IsWishedProviderElement extends AutoDisposeProviderElement<bool>
    with IsWishedRef {
  _IsWishedProviderElement(super.provider);

  @override
  String get productId => (origin as IsWishedProvider).productId;
}

String _$wishlistProductsHash() => r'81b648a5658ba9a93fb4d82c3cec48df8388b257';

/// See also [wishlistProducts].
@ProviderFor(wishlistProducts)
final wishlistProductsProvider =
    AutoDisposeFutureProvider<List<Product>>.internal(
      wishlistProducts,
      name: r'wishlistProductsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$wishlistProductsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WishlistProductsRef = AutoDisposeFutureProviderRef<List<Product>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
