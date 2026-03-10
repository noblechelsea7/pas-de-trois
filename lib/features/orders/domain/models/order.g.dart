// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderStatusLogImpl _$$OrderStatusLogImplFromJson(Map<String, dynamic> json) =>
    _$OrderStatusLogImpl(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      status: json['status'] as String,
      note: json['note'] as String?,
      createdAt: _dtFromJson(json['created_at'] as String),
    );

Map<String, dynamic> _$$OrderStatusLogImplToJson(
  _$OrderStatusLogImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'order_id': instance.orderId,
  'status': instance.status,
  'note': instance.note,
  'created_at': instance.createdAt.toIso8601String(),
};

_$OrderItemImpl _$$OrderItemImplFromJson(Map<String, dynamic> json) =>
    _$OrderItemImpl(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      productId: json['product_id'] as String?,
      productSnapshot:
          json['product_snapshot'] as Map<String, dynamic>? ?? const {},
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unit_price'] as num).toInt(),
      createdAt: _dtFromJson(json['created_at'] as String),
    );

Map<String, dynamic> _$$OrderItemImplToJson(_$OrderItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_id': instance.orderId,
      'product_id': instance.productId,
      'product_snapshot': instance.productSnapshot,
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
      'created_at': instance.createdAt.toIso8601String(),
    };

_$OrderImpl _$$OrderImplFromJson(Map<String, dynamic> json) => _$OrderImpl(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  orderNumber: json['order_number'] as String,
  status: json['status'] as String,
  shippingMethod: json['shipping_method'] as String,
  shippingFee: (json['shipping_fee'] as num).toInt(),
  totalAmount: (json['total_amount'] as num).toInt(),
  addressSnapshot: json['address_snapshot'] == null
      ? const {}
      : _addrFromJson(json['address_snapshot']),
  note: json['note'] as String?,
  createdAt: _dtFromJson(json['created_at'] as String),
  items: json['order_items'] == null
      ? const []
      : _itemsFromJson(json['order_items']),
  statusLogs: json['order_status_logs'] == null
      ? const []
      : _logsFromJson(json['order_status_logs']),
);

Map<String, dynamic> _$$OrderImplToJson(_$OrderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'order_number': instance.orderNumber,
      'status': instance.status,
      'shipping_method': instance.shippingMethod,
      'shipping_fee': instance.shippingFee,
      'total_amount': instance.totalAmount,
      'address_snapshot': instance.addressSnapshot,
      'note': instance.note,
      'created_at': instance.createdAt.toIso8601String(),
      'order_items': instance.items,
      'order_status_logs': instance.statusLogs,
    };
