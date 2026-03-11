import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/domain/models/user_profile.dart';
import '../../../orders/domain/models/order.dart';
import '../../../products/domain/models/product.dart';
import '../../data/datasources/supabase_admin_datasource.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../domain/interfaces/i_admin_repository.dart';

part 'admin_providers.g.dart';

@riverpod
IAdminRepository adminRepository(Ref ref) {
  final client = Supabase.instance.client;
  return AdminRepositoryImpl(SupabaseAdminDatasource(client));
}

// ---------------------------------------------------------------------------
// Dashboard stats
// ---------------------------------------------------------------------------

@riverpod
Future<int> todayOrderCount(Ref ref) =>
    ref.read(adminRepositoryProvider).getTodayOrderCount();

@riverpod
Future<int> pendingOrderCount(Ref ref) =>
    ref.read(adminRepositoryProvider).getPendingOrderCount();

@riverpod
Future<int> totalMemberCount(Ref ref) =>
    ref.read(adminRepositoryProvider).getTotalMemberCount();

// ---------------------------------------------------------------------------
// Admin orders
// ---------------------------------------------------------------------------

@riverpod
Future<List<Order>> adminOrders(Ref ref) =>
    ref.read(adminRepositoryProvider).getAllOrders();

// ---------------------------------------------------------------------------
// Admin products (includes inactive)
// ---------------------------------------------------------------------------

@riverpod
Future<List<Product>> adminProducts(Ref ref) =>
    ref.read(adminRepositoryProvider).getAllProducts();

// ---------------------------------------------------------------------------
// Admin members
// ---------------------------------------------------------------------------

@riverpod
Future<List<UserProfile>> adminMembers(Ref ref) =>
    ref.read(adminRepositoryProvider).getAllMembers();

@riverpod
Future<List<Order>> memberOrders(Ref ref, String userId) =>
    ref.read(adminRepositoryProvider).getMemberOrders(userId);

// ---------------------------------------------------------------------------
// Admin settings
// ---------------------------------------------------------------------------

@riverpod
Future<Map<String, String>> adminSettings(Ref ref) =>
    ref.read(adminRepositoryProvider).getAllSettings();
