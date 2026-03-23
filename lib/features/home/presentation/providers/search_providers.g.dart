// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$searchProductsHash() => r'c7a24683af5d5f611bc3f4f62be1b1787602bec0';

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

/// See also [searchProducts].
@ProviderFor(searchProducts)
const searchProductsProvider = SearchProductsFamily();

/// See also [searchProducts].
class SearchProductsFamily extends Family<AsyncValue<List<Product>>> {
  /// See also [searchProducts].
  const SearchProductsFamily();

  /// See also [searchProducts].
  SearchProductsProvider call(String query) {
    return SearchProductsProvider(query);
  }

  @override
  SearchProductsProvider getProviderOverride(
    covariant SearchProductsProvider provider,
  ) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'searchProductsProvider';
}

/// See also [searchProducts].
class SearchProductsProvider extends AutoDisposeFutureProvider<List<Product>> {
  /// See also [searchProducts].
  SearchProductsProvider(String query)
    : this._internal(
        (ref) => searchProducts(ref as SearchProductsRef, query),
        from: searchProductsProvider,
        name: r'searchProductsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$searchProductsHash,
        dependencies: SearchProductsFamily._dependencies,
        allTransitiveDependencies:
            SearchProductsFamily._allTransitiveDependencies,
        query: query,
      );

  SearchProductsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<Product>> Function(SearchProductsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchProductsProvider._internal(
        (ref) => create(ref as SearchProductsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Product>> createElement() {
    return _SearchProductsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchProductsProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchProductsRef on AutoDisposeFutureProviderRef<List<Product>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _SearchProductsProviderElement
    extends AutoDisposeFutureProviderElement<List<Product>>
    with SearchProductsRef {
  _SearchProductsProviderElement(super.provider);

  @override
  String get query => (origin as SearchProductsProvider).query;
}

String _$searchHistoryHash() => r'7c76694e923fbad653422862357acb1fd1022152';

/// See also [SearchHistory].
@ProviderFor(SearchHistory)
final searchHistoryProvider =
    AsyncNotifierProvider<SearchHistory, List<String>>.internal(
      SearchHistory.new,
      name: r'searchHistoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$searchHistoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SearchHistory = AsyncNotifier<List<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
