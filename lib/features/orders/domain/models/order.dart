// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order.freezed.dart';
part 'order.g.dart';

DateTime _dtFromJson(String v) {
  final n = RegExp(r'[+-]\d{2}$').hasMatch(v) ? '$v:00' : v;
  return DateTime.parse(n);
}

// ---------------------------------------------------------------------------
// Order status helpers
// ---------------------------------------------------------------------------

const kOrderStatuses = [
  '待付款',
  '備貨中',
  '韓國處理中',
  '空運回台中',
  '台灣配送中',
  '已完成',
];

// ---------------------------------------------------------------------------
// OrderStatusLog
// ---------------------------------------------------------------------------

@freezed
class OrderStatusLog with _$OrderStatusLog {
  const factory OrderStatusLog({
    required String id,
    @JsonKey(name: 'order_id') required String orderId,
    required String status,
    String? note,
    @JsonKey(name: 'created_at', fromJson: _dtFromJson) required DateTime createdAt,
  }) = _OrderStatusLog;

  factory OrderStatusLog.fromJson(Map<String, dynamic> json) =>
      _$OrderStatusLogFromJson(json);
}

// ---------------------------------------------------------------------------
// OrderItem
// ---------------------------------------------------------------------------

List<OrderStatusLog> _logsFromJson(dynamic v) {
  if (v == null) return [];
  return (v as List)
      .map((e) => OrderStatusLog.fromJson(e as Map<String, dynamic>))
      .toList()
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
}

List<OrderItem> _itemsFromJson(dynamic v) {
  if (v == null) return [];
  return (v as List)
      .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
      .toList();
}

Map<String, dynamic> _addrFromJson(dynamic v) =>
    (v as Map<String, dynamic>?) ?? {};

@freezed
class OrderItem with _$OrderItem {
  const factory OrderItem({
    required String id,
    @JsonKey(name: 'order_id') required String orderId,
    @JsonKey(name: 'product_id') String? productId,
    @JsonKey(name: 'product_snapshot') @Default({}) Map<String, dynamic> productSnapshot,
    required int quantity,
    @JsonKey(name: 'unit_price') required int unitPrice,
    @JsonKey(name: 'created_at', fromJson: _dtFromJson) required DateTime createdAt,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
}

// ---------------------------------------------------------------------------
// Order
// ---------------------------------------------------------------------------

@freezed
class Order with _$Order {
  const factory Order({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'order_number') required String orderNumber,
    required String status,
    @JsonKey(name: 'shipping_method') required String shippingMethod,
    @JsonKey(name: 'shipping_fee') required int shippingFee,
    @JsonKey(name: 'total_amount') required int totalAmount,
    @JsonKey(name: 'address_snapshot', fromJson: _addrFromJson) @Default({}) Map<String, dynamic> addressSnapshot,
    String? note,
    @JsonKey(name: 'created_at', fromJson: _dtFromJson) required DateTime createdAt,
    @JsonKey(name: 'order_items', fromJson: _itemsFromJson) @Default([]) List<OrderItem> items,
    @JsonKey(name: 'order_status_logs', fromJson: _logsFromJson) @Default([]) List<OrderStatusLog> statusLogs,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) =>
      _$OrderFromJson(json);
}
