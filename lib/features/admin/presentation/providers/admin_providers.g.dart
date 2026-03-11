// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminRepositoryHash() => r'f27896f1b04ecf26dd8103ccd1f92bc140151beb';

/// See also [adminRepository].
@ProviderFor(adminRepository)
final adminRepositoryProvider = AutoDisposeProvider<IAdminRepository>.internal(
  adminRepository,
  name: r'adminRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminRepositoryRef = AutoDisposeProviderRef<IAdminRepository>;
String _$todayOrderCountHash() => r'ea4a89b43dd613d29e11347bf84850df30bbfe24';

/// See also [todayOrderCount].
@ProviderFor(todayOrderCount)
final todayOrderCountProvider = AutoDisposeFutureProvider<int>.internal(
  todayOrderCount,
  name: r'todayOrderCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayOrderCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayOrderCountRef = AutoDisposeFutureProviderRef<int>;
String _$pendingOrderCountHash() => r'214fa46bedabebf4bed63ebbd47e93700e0495c9';

/// See also [pendingOrderCount].
@ProviderFor(pendingOrderCount)
final pendingOrderCountProvider = AutoDisposeFutureProvider<int>.internal(
  pendingOrderCount,
  name: r'pendingOrderCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingOrderCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PendingOrderCountRef = AutoDisposeFutureProviderRef<int>;
String _$totalMemberCountHash() => r'1a5e01a81e1d126fdd8433cafbd0f4867e6de3a5';

/// See also [totalMemberCount].
@ProviderFor(totalMemberCount)
final totalMemberCountProvider = AutoDisposeFutureProvider<int>.internal(
  totalMemberCount,
  name: r'totalMemberCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalMemberCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalMemberCountRef = AutoDisposeFutureProviderRef<int>;
String _$adminOrdersHash() => r'b1df6bc196b9c884279b1bed008470468cfea38c';

/// See also [adminOrders].
@ProviderFor(adminOrders)
final adminOrdersProvider = AutoDisposeFutureProvider<List<Order>>.internal(
  adminOrders,
  name: r'adminOrdersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminOrdersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminOrdersRef = AutoDisposeFutureProviderRef<List<Order>>;
String _$adminProductsHash() => r'469f06a209cf8843e11978fc569584bc2c83cf6d';

/// See also [adminProducts].
@ProviderFor(adminProducts)
final adminProductsProvider = AutoDisposeFutureProvider<List<Product>>.internal(
  adminProducts,
  name: r'adminProductsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminProductsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminProductsRef = AutoDisposeFutureProviderRef<List<Product>>;
String _$adminMembersHash() => r'5bd5c88ead436bcfaf948ab7bb92952b72ec1753';

/// See also [adminMembers].
@ProviderFor(adminMembers)
final adminMembersProvider =
    AutoDisposeFutureProvider<List<UserProfile>>.internal(
      adminMembers,
      name: r'adminMembersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminMembersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminMembersRef = AutoDisposeFutureProviderRef<List<UserProfile>>;
String _$memberOrdersHash() => r'25eead368c446a02ce1d9c4f9f468c20565f3f86';

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

/// See also [memberOrders].
@ProviderFor(memberOrders)
const memberOrdersProvider = MemberOrdersFamily();

/// See also [memberOrders].
class MemberOrdersFamily extends Family<AsyncValue<List<Order>>> {
  /// See also [memberOrders].
  const MemberOrdersFamily();

  /// See also [memberOrders].
  MemberOrdersProvider call(String userId) {
    return MemberOrdersProvider(userId);
  }

  @override
  MemberOrdersProvider getProviderOverride(
    covariant MemberOrdersProvider provider,
  ) {
    return call(provider.userId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'memberOrdersProvider';
}

/// See also [memberOrders].
class MemberOrdersProvider extends AutoDisposeFutureProvider<List<Order>> {
  /// See also [memberOrders].
  MemberOrdersProvider(String userId)
    : this._internal(
        (ref) => memberOrders(ref as MemberOrdersRef, userId),
        from: memberOrdersProvider,
        name: r'memberOrdersProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$memberOrdersHash,
        dependencies: MemberOrdersFamily._dependencies,
        allTransitiveDependencies:
            MemberOrdersFamily._allTransitiveDependencies,
        userId: userId,
      );

  MemberOrdersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    FutureOr<List<Order>> Function(MemberOrdersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MemberOrdersProvider._internal(
        (ref) => create(ref as MemberOrdersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Order>> createElement() {
    return _MemberOrdersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MemberOrdersProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MemberOrdersRef on AutoDisposeFutureProviderRef<List<Order>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _MemberOrdersProviderElement
    extends AutoDisposeFutureProviderElement<List<Order>>
    with MemberOrdersRef {
  _MemberOrdersProviderElement(super.provider);

  @override
  String get userId => (origin as MemberOrdersProvider).userId;
}

String _$adminSettingsHash() => r'54200c5b321a1f51d4ba71e9c4536e70506eaa08';

/// See also [adminSettings].
@ProviderFor(adminSettings)
final adminSettingsProvider =
    AutoDisposeFutureProvider<Map<String, String>>.internal(
      adminSettings,
      name: r'adminSettingsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminSettingsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminSettingsRef = AutoDisposeFutureProviderRef<Map<String, String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
