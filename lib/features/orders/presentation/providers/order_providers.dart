import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/address.dart';
import '../../domain/models/order.dart';

export '../../domain/models/address.dart';
export '../../domain/models/order.dart';

part 'order_providers.g.dart';

@riverpod
Future<List<Address>> userAddresses(Ref ref) async {
  final client = Supabase.instance.client;
  final userId = client.auth.currentUser?.id;
  if (userId == null) return [];

  final data = await client
      .from('addresses')
      .select()
      .eq('user_id', userId)
      .order('is_default', ascending: false)
      .order('created_at');

  return (data as List)
      .map((e) => Address.fromJson(e as Map<String, dynamic>))
      .toList();
}

@riverpod
Future<List<Order>> userOrders(Ref ref) async {
  final client = Supabase.instance.client;
  final data = await client
      .from('orders')
      .select(
        'id, user_id, order_number, status, shipping_method, shipping_fee, total_amount, address_snapshot, note, created_at',
      )
      .order('created_at', ascending: false);

  return (data as List)
      .map((e) => Order.fromJson(e as Map<String, dynamic>))
      .toList();
}

@riverpod
Future<Order> orderDetail(Ref ref, String orderId) async {
  final client = Supabase.instance.client;
  final data = await client
      .from('orders')
      .select('*, order_items(*), order_status_logs(*)')
      .eq('id', orderId)
      .single();

  return Order.fromJson(data);
}
