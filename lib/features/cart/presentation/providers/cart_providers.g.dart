// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cartItemsHash() => r'4ee8f1ce69dcf7b6ce7a5e39f7bfa215e625c299';

/// In-memory cart: cartKey → CartItem.
/// The key uniquely identifies a product+variant combination.
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
