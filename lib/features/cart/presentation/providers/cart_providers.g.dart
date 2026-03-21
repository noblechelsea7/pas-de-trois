// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cartItemsHash() => r'9715a63316a1a69d5d45c16292be0f17d0ee9718';

/// In-memory + Supabase-backed cart.
/// - keepAlive: true so the notifier persists across navigation (preserves
///   local guest cart items and keeps auth listener alive).
/// - Logged-in users: synced to Supabase on every mutation; loaded on startup.
/// - Guest users: in-memory only; merged to Supabase on login.
///
/// Copied from [CartItems].
@ProviderFor(CartItems)
final cartItemsProvider =
    NotifierProvider<CartItems, Map<String, CartItem>>.internal(
      CartItems.new,
      name: r'cartItemsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cartItemsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CartItems = Notifier<Map<String, CartItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
