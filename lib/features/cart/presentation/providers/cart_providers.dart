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
/// - keepAlive: true so the notifier persists across navigation (preserves
///   local guest cart items and keeps auth listener alive).
/// - Logged-in users: synced to Supabase on every mutation; loaded on startup.
/// - Guest users: in-memory only; merged to Supabase on login.
@Riverpod(keepAlive: true)
class CartItems extends _$CartItems {
  @override
  Map<String, CartItem> build() {
    // Listen directly to Supabase auth stream for reliable sign-in/sign-out
    // detection regardless of widget tree state.
    ref.listen(authStateChangesProvider, (prev, next) {
      final event = next.valueOrNull;
      if (event == null) return;
      switch (event.event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.tokenRefreshed:
          final newId = event.session?.user.id;
          final prevId = prev?.valueOrNull?.session?.user.id;
          if (newId != null && newId != prevId) {
            _onLogin(newId);
          }
        case AuthChangeEvent.signedOut:
          state = {};
        default:
          break;
      }
    });

    // Already logged in at startup — load remote cart immediately.
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

  /// Called when the user signs in.
  /// Merges any local (guest) items into Supabase, then reloads.
  Future<void> _onLogin(String userId) async {
    final localItems = Map<String, CartItem>.from(state);
    final repo = _makeRepo(userId);

    try {
      // Push each local item to Supabase (upsert = add if missing)
      for (final local in localItems.values) {
        await repo.upsertItem(local);
      }
      // Reload the authoritative list from Supabase
      final remoteItems = await repo.getCartItems();
      state = {for (final item in remoteItems) item.key: item};
    } catch (_) {
      // Fallback: load remote without merging
      await _loadFromRemote(userId);
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
