import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/supabase_cart_datasource.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../domain/interfaces/i_cart_repository.dart';
import '../../domain/models/cart_item.dart';

export '../../domain/models/cart_item.dart';

part 'cart_providers.g.dart';

/// In-memory + Supabase-backed cart.
/// - Logged-in users: synced to Supabase on every mutation; loaded on startup.
/// - Guest users: in-memory only; merged to Supabase on login.
@riverpod
class CartItems extends _$CartItems {
  @override
  Map<String, CartItem> build() {
    // React to login/logout events
    ref.listen(currentAuthUserProvider, (prev, next) {
      if (prev?.id != next?.id) {
        _onAuthChanged(prevId: prev?.id, newId: next?.id);
      }
    });

    // Load from Supabase if already logged in at startup
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      Future.microtask(() => _loadFromRemote(userId));
    }

    return {};
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  ICartRepository _makeRepo(String userId) => CartRepositoryImpl(
        SupabaseCartDataSource(Supabase.instance.client, userId),
      );

  ICartRepository? get _currentRepo {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return null;
    return _makeRepo(userId);
  }

  Future<void> _loadFromRemote(String userId) async {
    try {
      final items = await _makeRepo(userId).getCartItems();
      state = {for (final item in items) item.key: item};
    } catch (_) {
      // Keep local state on error
    }
  }

  /// Called when auth state changes (login or logout).
  Future<void> _onAuthChanged({
    required String? prevId,
    required String? newId,
  }) async {
    if (newId != null) {
      // User just logged in: merge local items into Supabase, then reload.
      final localItems = Map<String, CartItem>.from(state);
      final repo = _makeRepo(newId);

      try {
        final remoteItems = await repo.getCartItems();
        final merged = {for (final item in remoteItems) item.key: item};

        // Push local-only items to Supabase
        for (final local in localItems.values) {
          if (!merged.containsKey(local.key)) {
            merged[local.key] = local;
            await repo.upsertItem(local);
          }
        }
        state = merged;
      } catch (_) {
        // Fallback: just load remote without merging
        await _loadFromRemote(newId);
      }
    } else {
      // User logged out: clear cart
      state = {};
    }
  }

  // ---------------------------------------------------------------------------
  // Mutations
  // ---------------------------------------------------------------------------

  Future<void> add(
    String productId, {
    Map<String, String> selectedVariants = const {},
    int quantity = 1,
  }) async {
    final item = CartItem(
      productId: productId,
      quantity: quantity,
      selectedVariants: selectedVariants,
    );
    final key = item.key;
    final existing = state[key];
    final updated = existing != null
        ? existing.copyWith(quantity: existing.quantity + quantity)
        : item;
    state = {...state, key: updated};
    await _currentRepo?.upsertItem(updated);
  }

  Future<void> updateQuantity(String cartKey, int quantity) async {
    if (quantity <= 0) {
      await remove(cartKey);
      return;
    }
    final item = state[cartKey];
    if (item == null) return;
    final updated = item.copyWith(quantity: quantity);
    state = {...state, cartKey: updated};
    await _currentRepo?.upsertItem(updated);
  }

  Future<void> remove(String cartKey) async {
    final item = state[cartKey];
    if (item == null) return;
    state = {...state}..remove(cartKey);
    await _currentRepo?.removeItem(item);
  }

  Future<void> clear() async {
    state = {};
    await _currentRepo?.clearCart();
  }

  int get totalItemCount =>
      state.values.fold(0, (sum, item) => sum + item.quantity);
}
