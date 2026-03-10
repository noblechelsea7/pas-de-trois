// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_success_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$orderNumberHash() => r'2d72dda73b78fd50dce3f1e205817ceff1f52494';

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

/// See also [orderNumber].
@ProviderFor(orderNumber)
const orderNumberProvider = OrderNumberFamily();

/// See also [orderNumber].
class OrderNumberFamily extends Family<AsyncValue<String?>> {
  /// See also [orderNumber].
  const OrderNumberFamily();

  /// See also [orderNumber].
  OrderNumberProvider call(String orderId) {
    return OrderNumberProvider(orderId);
  }

  @override
  OrderNumberProvider getProviderOverride(
    covariant OrderNumberProvider provider,
  ) {
    return call(provider.orderId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'orderNumberProvider';
}

/// See also [orderNumber].
class OrderNumberProvider extends AutoDisposeFutureProvider<String?> {
  /// See also [orderNumber].
  OrderNumberProvider(String orderId)
    : this._internal(
        (ref) => orderNumber(ref as OrderNumberRef, orderId),
        from: orderNumberProvider,
        name: r'orderNumberProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$orderNumberHash,
        dependencies: OrderNumberFamily._dependencies,
        allTransitiveDependencies: OrderNumberFamily._allTransitiveDependencies,
        orderId: orderId,
      );

  OrderNumberProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orderId,
  }) : super.internal();

  final String orderId;

  @override
  Override overrideWith(
    FutureOr<String?> Function(OrderNumberRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OrderNumberProvider._internal(
        (ref) => create(ref as OrderNumberRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orderId: orderId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String?> createElement() {
    return _OrderNumberProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderNumberProvider && other.orderId == orderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OrderNumberRef on AutoDisposeFutureProviderRef<String?> {
  /// The parameter `orderId` of this provider.
  String get orderId;
}

class _OrderNumberProviderElement
    extends AutoDisposeFutureProviderElement<String?>
    with OrderNumberRef {
  _OrderNumberProviderElement(super.provider);

  @override
  String get orderId => (origin as OrderNumberProvider).orderId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
