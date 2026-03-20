// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cartItemsHash() => r'89c3c5923a36d423602ed6f1c49f55acdb101101';

/// In-memory + Supabase-backed cart.
/// - Logged-in users: synced to Supabase on every mutation; loaded on startup.
/// - Guest users: in-memory only; merged to Supabase on login.
///
/// Copied from [CartItems].
@ProviderFor(CartItems)
final cartItemsProvider =
    AutoDisposeNotifierProvider<CartItems, Map<String, CartItem>>.internal(
      CartItems.new,
      name: r'cartItemsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cartItemsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CartItems = AutoDisposeNotifier<Map<String, CartItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
