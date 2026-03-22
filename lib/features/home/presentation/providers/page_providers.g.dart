// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pageByKeyHash() => r'4ebd91868ad352f873f9511ab955519c318e698a';

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

/// See also [pageByKey].
@ProviderFor(pageByKey)
const pageByKeyProvider = PageByKeyFamily();

/// See also [pageByKey].
class PageByKeyFamily extends Family<AsyncValue<SitePage?>> {
  /// See also [pageByKey].
  const PageByKeyFamily();

  /// See also [pageByKey].
  PageByKeyProvider call(String key) {
    return PageByKeyProvider(key);
  }

  @override
  PageByKeyProvider getProviderOverride(covariant PageByKeyProvider provider) {
    return call(provider.key);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'pageByKeyProvider';
}

/// See also [pageByKey].
class PageByKeyProvider extends AutoDisposeFutureProvider<SitePage?> {
  /// See also [pageByKey].
  PageByKeyProvider(String key)
    : this._internal(
        (ref) => pageByKey(ref as PageByKeyRef, key),
        from: pageByKeyProvider,
        name: r'pageByKeyProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$pageByKeyHash,
        dependencies: PageByKeyFamily._dependencies,
        allTransitiveDependencies: PageByKeyFamily._allTransitiveDependencies,
        key: key,
      );

  PageByKeyProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.key,
  }) : super.internal();

  final String key;

  @override
  Override overrideWith(
    FutureOr<SitePage?> Function(PageByKeyRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PageByKeyProvider._internal(
        (ref) => create(ref as PageByKeyRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        key: key,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SitePage?> createElement() {
    return _PageByKeyProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PageByKeyProvider && other.key == key;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, key.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PageByKeyRef on AutoDisposeFutureProviderRef<SitePage?> {
  /// The parameter `key` of this provider.
  String get key;
}

class _PageByKeyProviderElement
    extends AutoDisposeFutureProviderElement<SitePage?>
    with PageByKeyRef {
  _PageByKeyProviderElement(super.provider);

  @override
  String get key => (origin as PageByKeyProvider).key;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
