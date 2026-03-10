// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OrderStatusLog _$OrderStatusLogFromJson(Map<String, dynamic> json) {
  return _OrderStatusLog.fromJson(json);
}

/// @nodoc
mixin _$OrderStatusLog {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_id')
  String get orderId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at', fromJson: _dtFromJson)
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this OrderStatusLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderStatusLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderStatusLogCopyWith<OrderStatusLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderStatusLogCopyWith<$Res> {
  factory $OrderStatusLogCopyWith(
    OrderStatusLog value,
    $Res Function(OrderStatusLog) then,
  ) = _$OrderStatusLogCopyWithImpl<$Res, OrderStatusLog>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'order_id') String orderId,
    String status,
    String? note,
    @JsonKey(name: 'created_at', fromJson: _dtFromJson) DateTime createdAt,
  });
}

/// @nodoc
class _$OrderStatusLogCopyWithImpl<$Res, $Val extends OrderStatusLog>
    implements $OrderStatusLogCopyWith<$Res> {
  _$OrderStatusLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderStatusLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? status = null,
    Object? note = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            orderId: null == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrderStatusLogImplCopyWith<$Res>
    implements $OrderStatusLogCopyWith<$Res> {
  factory _$$OrderStatusLogImplCopyWith(
    _$OrderStatusLogImpl value,
    $Res Function(_$OrderStatusLogImpl) then,
  ) = __$$OrderStatusLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'order_id') String orderId,
    String status,
    String? note,
    @JsonKey(name: 'created_at', fromJson: _dtFromJson) DateTime createdAt,
  });
}

/// @nodoc
class __$$OrderStatusLogImplCopyWithImpl<$Res>
    extends _$OrderStatusLogCopyWithImpl<$Res, _$OrderStatusLogImpl>
    implements _$$OrderStatusLogImplCopyWith<$Res> {
  __$$OrderStatusLogImplCopyWithImpl(
    _$OrderStatusLogImpl _value,
    $Res Function(_$OrderStatusLogImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderStatusLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? status = null,
    Object? note = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$OrderStatusLogImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderStatusLogImpl implements _OrderStatusLog {
  const _$OrderStatusLogImpl({
    required this.id,
    @JsonKey(name: 'order_id') required this.orderId,
    required this.status,
    this.note,
    @JsonKey(name: 'created_at', fromJson: _dtFromJson) required this.createdAt,
  });

  factory _$OrderStatusLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderStatusLogImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'order_id')
  final String orderId;
  @override
  final String status;
  @override
  final String? note;
  @override
  @JsonKey(name: 'created_at', fromJson: _dtFromJson)
  final DateTime createdAt;

  @override
  String toString() {
    return 'OrderStatusLog(id: $id, orderId: $orderId, status: $status, note: $note, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderStatusLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, orderId, status, note, createdAt);

  /// Create a copy of OrderStatusLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderStatusLogImplCopyWith<_$OrderStatusLogImpl> get copyWith =>
      __$$OrderStatusLogImplCopyWithImpl<_$OrderStatusLogImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderStatusLogImplToJson(this);
  }
}

abstract class _OrderStatusLog implements OrderStatusLog {
  const factory _OrderStatusLog({
    required final String id,
    @JsonKey(name: 'order_id') required final String orderId,
    required final String status,
    final String? note,
    @JsonKey(name: 'created_at', fromJson: _dtFromJson)
    required final DateTime createdAt,
  }) = _$OrderStatusLogImpl;

  factory _OrderStatusLog.fromJson(Map<String, dynamic> json) =
      _$OrderStatusLogImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'order_id')
  String get orderId;
  @override
  String get status;
  @override
  String? get note;
  @override
  @JsonKey(name: 'created_at', fromJson: _dtFromJson)
  DateTime get createdAt;

  /// Create a copy of OrderStatusLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderStatusLogImplCopyWith<_$OrderStatusLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) {
  return _OrderItem.fromJson(json);
}

/// @nodoc
mixin _$OrderItem {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_id')
  String get orderId => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_id')
  String? get productId => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_snapshot')
  Map<String, dynamic> get productSnapshot =>
      throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  @JsonKey(name: 'unit_price')
  int get unitPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at', fromJson: _dtFromJson)
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this OrderItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderItemCopyWith<OrderItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderItemCopyWith<$Res> {
  factory $OrderItemCopyWith(OrderItem value, $Res Function(OrderItem) then) =
      _$OrderItemCopyWithImpl<$Res, OrderItem>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'order_id') String orderId,
    @JsonKey(name: 'product_id') String? productId,
    @JsonKey(name: 'product_snapshot') Map<String, dynamic> productSnapshot,
    int quantity,
    @JsonKey(name: 'unit_price') int unitPrice,
    @JsonKey(name: 'created_at', fromJson: _dtFromJson) DateTime createdAt,
  });
}

/// @nodoc
class _$OrderItemCopyWithImpl<$Res, $Val extends OrderItem>
    implements $OrderItemCopyWith<$Res> {
  _$OrderItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? productId = freezed,
    Object? productSnapshot = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            orderId: null == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                      as String,
            productId: freezed == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String?,
            productSnapshot: null == productSnapshot
                ? _value.productSnapshot
                : productSnapshot // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as int,
            unitPrice: null == unitPrice
                ? _value.unitPrice
                : unitPrice // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrderItemImplCopyWith<$Res>
    implements $OrderItemCopyWith<$Res> {
  factory _$$OrderItemImplCopyWith(
    _$OrderItemImpl value,
    $Res Function(_$OrderItemImpl) then,
  ) = __$$OrderItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'order_id') String orderId,
    @JsonKey(name: 'product_id') String? productId,
    @JsonKey(name: 'product_snapshot') Map<String, dynamic> productSnapshot,
    int quantity,
    @JsonKey(name: 'unit_price') int unitPrice,
    @JsonKey(name: 'created_at', fromJson: _dtFromJson) DateTime createdAt,
  });
}

/// @nodoc
class __$$OrderItemImplCopyWithImpl<$Res>
    extends _$OrderItemCopyWithImpl<$Res, _$OrderItemImpl>
    implements _$$OrderItemImplCopyWith<$Res> {
  __$$OrderItemImplCopyWithImpl(
    _$OrderItemImpl _value,
    $Res Function(_$OrderItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? productId = freezed,
    Object? productSnapshot = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$OrderItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        productId: freezed == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String?,
        productSnapshot: null == productSnapshot
            ? _value._productSnapshot
            : productSnapshot // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as int,
        unitPrice: null == unitPrice
            ? _value.unitPrice
            : unitPrice // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderItemImpl implements _OrderItem {
  const _$OrderItemImpl({
    required this.id,
    @JsonKey(name: 'order_id') required this.orderId,
    @JsonKey(name: 'product_id') this.productId,
    @JsonKey(name: 'product_snapshot')
    final Map<String, dynamic> productSnapshot = const {},
    required this.quantity,
    @JsonKey(name: 'unit_price') required this.unitPrice,
    @JsonKey(name: 'created_at', fromJson: _dtFromJson) required this.createdAt,
  }) : _productSnapshot = productSnapshot;

  factory _$OrderItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderItemImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'order_id')
  final String orderId;
  @override
  @JsonKey(name: 'product_id')
  final String? productId;
  final Map<String, dynamic> _productSnapshot;
  @override
  @JsonKey(name: 'product_snapshot')
  Map<String, dynamic> get productSnapshot {
    if (_productSnapshot is EqualUnmodifiableMapView) return _productSnapshot;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_productSnapshot);
  }

  @override
  final int quantity;
  @override
  @JsonKey(name: 'unit_price')
  final int unitPrice;
  @override
  @JsonKey(name: 'created_at', fromJson: _dtFromJson)
  final DateTime createdAt;

  @override
  String toString() {
    return 'OrderItem(id: $id, orderId: $orderId, productId: $productId, productSnapshot: $productSnapshot, quantity: $quantity, unitPrice: $unitPrice, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            const DeepCollectionEquality().equals(
              other._productSnapshot,
              _productSnapshot,
            ) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orderId,
    productId,
    const DeepCollectionEquality().hash(_productSnapshot),
    quantity,
    unitPrice,
    createdAt,
  );

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderItemImplCopyWith<_$OrderItemImpl> get copyWith =>
      __$$OrderItemImplCopyWithImpl<_$OrderItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderItemImplToJson(this);
  }
}

abstract class _OrderItem implements OrderItem {
  const factory _OrderItem({
    required final String id,
    @JsonKey(name: 'order_id') required final String orderId,
    @JsonKey(name: 'product_id') final String? productId,
    @JsonKey(name: 'product_snapshot')
    final Map<String, dynamic> productSnapshot,
    required final int quantity,
    @JsonKey(name: 'unit_price') required final int unitPrice,
    @JsonKey(name: 'created_at', fromJson: _dtFromJson)
    required final DateTime createdAt,
  }) = _$OrderItemImpl;

  factory _OrderItem.fromJson(Map<String, dynamic> json) =
      _$OrderItemImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'order_id')
  String get orderId;
  @override
  @JsonKey(name: 'product_id')
  String? get productId;
  @override
  @JsonKey(name: 'product_snapshot')
  Map<String, dynamic> get productSnapshot;
  @override
  int get quantity;
  @override
  @JsonKey(name: 'unit_price')
  int get unitPrice;
  @override
  @JsonKey(name: 'created_at', fromJson: _dtFromJson)
  DateTime get createdAt;

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderItemImplCopyWith<_$OrderItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Order _$OrderFromJson(Map<String, dynamic> json) {
  return _Order.fromJson(json);
}

/// @nodoc
mixin _$Order {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_number')
  String get orderNumber => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'shipping_method')
  String get shippingMethod => throw _privateConstructorUsedError;
  @JsonKey(name: 'shipping_fee')
  int get shippingFee => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_amount')
  int get totalAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'address_snapshot', fromJson: _addrFromJson)
  Map<String, dynamic> get addressSnapshot =>
      throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at', fromJson: _dtFromJson)
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_items', fromJson: _itemsFromJson)
  List<OrderItem> get items => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_status_logs', fromJson: _logsFromJson)
  List<OrderStatusLog> get statusLogs => throw _privateConstructorUsedError;

  /// Serializes this Order to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderCopyWith<Order> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderCopyWith<$Res> {
  factory $OrderCopyWith(Order value, $Res Function(Order) then) =
      _$OrderCopyWithImpl<$Res, Order>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'order_number') String orderNumber,
    String status,
    @JsonKey(name: 'shipping_method') String shippingMethod,
    @JsonKey(name: 'shipping_fee') int shippingFee,
    @JsonKey(name: 'total_amount') int totalAmount,
    @JsonKey(name: 'address_snapshot', fromJson: _addrFromJson)
    Map<String, dynamic> addressSnapshot,
    String? note,
    @JsonKey(name: 'created_at', fromJson: _dtFromJson) DateTime createdAt,
    @JsonKey(name: 'order_items', fromJson: _itemsFromJson)
    List<OrderItem> items,
    @JsonKey(name: 'order_status_logs', fromJson: _logsFromJson)
    List<OrderStatusLog> statusLogs,
  });
}

/// @nodoc
class _$OrderCopyWithImpl<$Res, $Val extends Order>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? orderNumber = null,
    Object? status = null,
    Object? shippingMethod = null,
    Object? shippingFee = null,
    Object? totalAmount = null,
    Object? addressSnapshot = null,
    Object? note = freezed,
    Object? createdAt = null,
    Object? items = null,
    Object? statusLogs = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            orderNumber: null == orderNumber
                ? _value.orderNumber
                : orderNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            shippingMethod: null == shippingMethod
                ? _value.shippingMethod
                : shippingMethod // ignore: cast_nullable_to_non_nullable
                      as String,
            shippingFee: null == shippingFee
                ? _value.shippingFee
                : shippingFee // ignore: cast_nullable_to_non_nullable
                      as int,
            totalAmount: null == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                      as int,
            addressSnapshot: null == addressSnapshot
                ? _value.addressSnapshot
                : addressSnapshot // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<OrderItem>,
            statusLogs: null == statusLogs
                ? _value.statusLogs
                : statusLogs // ignore: cast_nullable_to_non_nullable
                      as List<OrderStatusLog>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrderImplCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$$OrderImplCopyWith(
    _$OrderImpl value,
    $Res Function(_$OrderImpl) then,
  ) = __$$OrderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'order_number') String orderNumber,
    String status,
    @JsonKey(name: 'shipping_method') String shippingMethod,
    @JsonKey(name: 'shipping_fee') int shippingFee,
    @JsonKey(name: 'total_amount') int totalAmount,
    @JsonKey(name: 'address_snapshot', fromJson: _addrFromJson)
    Map<String, dynamic> addressSnapshot,
    String? note,
    @JsonKey(name: 'created_at', fromJson: _dtFromJson) DateTime createdAt,
    @JsonKey(name: 'order_items', fromJson: _itemsFromJson)
    List<OrderItem> items,
    @JsonKey(name: 'order_status_logs', fromJson: _logsFromJson)
    List<OrderStatusLog> statusLogs,
  });
}

/// @nodoc
class __$$OrderImplCopyWithImpl<$Res>
    extends _$OrderCopyWithImpl<$Res, _$OrderImpl>
    implements _$$OrderImplCopyWith<$Res> {
  __$$OrderImplCopyWithImpl(
    _$OrderImpl _value,
    $Res Function(_$OrderImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? orderNumber = null,
    Object? status = null,
    Object? shippingMethod = null,
    Object? shippingFee = null,
    Object? totalAmount = null,
    Object? addressSnapshot = null,
    Object? note = freezed,
    Object? createdAt = null,
    Object? items = null,
    Object? statusLogs = null,
  }) {
    return _then(
      _$OrderImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        orderNumber: null == orderNumber
            ? _value.orderNumber
            : orderNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        shippingMethod: null == shippingMethod
            ? _value.shippingMethod
            : shippingMethod // ignore: cast_nullable_to_non_nullable
                  as String,
        shippingFee: null == shippingFee
            ? _value.shippingFee
            : shippingFee // ignore: cast_nullable_to_non_nullable
                  as int,
        totalAmount: null == totalAmount
            ? _value.totalAmount
            : totalAmount // ignore: cast_nullable_to_non_nullable
                  as int,
        addressSnapshot: null == addressSnapshot
            ? _value._addressSnapshot
            : addressSnapshot // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<OrderItem>,
        statusLogs: null == statusLogs
            ? _value._statusLogs
            : statusLogs // ignore: cast_nullable_to_non_nullable
                  as List<OrderStatusLog>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderImpl implements _Order {
  const _$OrderImpl({
    required this.id,
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'order_number') required this.orderNumber,
    required this.status,
    @JsonKey(name: 'shipping_method') required this.shippingMethod,
    @JsonKey(name: 'shipping_fee') required this.shippingFee,
    @JsonKey(name: 'total_amount') required this.totalAmount,
    @JsonKey(name: 'address_snapshot', fromJson: _addrFromJson)
    final Map<String, dynamic> addressSnapshot = const {},
    this.note,
    @JsonKey(name: 'created_at', fromJson: _dtFromJson) required this.createdAt,
    @JsonKey(name: 'order_items', fromJson: _itemsFromJson)
    final List<OrderItem> items = const [],
    @JsonKey(name: 'order_status_logs', fromJson: _logsFromJson)
    final List<OrderStatusLog> statusLogs = const [],
  }) : _addressSnapshot = addressSnapshot,
       _items = items,
       _statusLogs = statusLogs;

  factory _$OrderImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'order_number')
  final String orderNumber;
  @override
  final String status;
  @override
  @JsonKey(name: 'shipping_method')
  final String shippingMethod;
  @override
  @JsonKey(name: 'shipping_fee')
  final int shippingFee;
  @override
  @JsonKey(name: 'total_amount')
  final int totalAmount;
  final Map<String, dynamic> _addressSnapshot;
  @override
  @JsonKey(name: 'address_snapshot', fromJson: _addrFromJson)
  Map<String, dynamic> get addressSnapshot {
    if (_addressSnapshot is EqualUnmodifiableMapView) return _addressSnapshot;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_addressSnapshot);
  }

  @override
  final String? note;
  @override
  @JsonKey(name: 'created_at', fromJson: _dtFromJson)
  final DateTime createdAt;
  final List<OrderItem> _items;
  @override
  @JsonKey(name: 'order_items', fromJson: _itemsFromJson)
  List<OrderItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  final List<OrderStatusLog> _statusLogs;
  @override
  @JsonKey(name: 'order_status_logs', fromJson: _logsFromJson)
  List<OrderStatusLog> get statusLogs {
    if (_statusLogs is EqualUnmodifiableListView) return _statusLogs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_statusLogs);
  }

  @override
  String toString() {
    return 'Order(id: $id, userId: $userId, orderNumber: $orderNumber, status: $status, shippingMethod: $shippingMethod, shippingFee: $shippingFee, totalAmount: $totalAmount, addressSnapshot: $addressSnapshot, note: $note, createdAt: $createdAt, items: $items, statusLogs: $statusLogs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.orderNumber, orderNumber) ||
                other.orderNumber == orderNumber) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.shippingMethod, shippingMethod) ||
                other.shippingMethod == shippingMethod) &&
            (identical(other.shippingFee, shippingFee) ||
                other.shippingFee == shippingFee) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            const DeepCollectionEquality().equals(
              other._addressSnapshot,
              _addressSnapshot,
            ) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            const DeepCollectionEquality().equals(
              other._statusLogs,
              _statusLogs,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    orderNumber,
    status,
    shippingMethod,
    shippingFee,
    totalAmount,
    const DeepCollectionEquality().hash(_addressSnapshot),
    note,
    createdAt,
    const DeepCollectionEquality().hash(_items),
    const DeepCollectionEquality().hash(_statusLogs),
  );

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderImplCopyWith<_$OrderImpl> get copyWith =>
      __$$OrderImplCopyWithImpl<_$OrderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderImplToJson(this);
  }
}

abstract class _Order implements Order {
  const factory _Order({
    required final String id,
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'order_number') required final String orderNumber,
    required final String status,
    @JsonKey(name: 'shipping_method') required final String shippingMethod,
    @JsonKey(name: 'shipping_fee') required final int shippingFee,
    @JsonKey(name: 'total_amount') required final int totalAmount,
    @JsonKey(name: 'address_snapshot', fromJson: _addrFromJson)
    final Map<String, dynamic> addressSnapshot,
    final String? note,
    @JsonKey(name: 'created_at', fromJson: _dtFromJson)
    required final DateTime createdAt,
    @JsonKey(name: 'order_items', fromJson: _itemsFromJson)
    final List<OrderItem> items,
    @JsonKey(name: 'order_status_logs', fromJson: _logsFromJson)
    final List<OrderStatusLog> statusLogs,
  }) = _$OrderImpl;

  factory _Order.fromJson(Map<String, dynamic> json) = _$OrderImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'order_number')
  String get orderNumber;
  @override
  String get status;
  @override
  @JsonKey(name: 'shipping_method')
  String get shippingMethod;
  @override
  @JsonKey(name: 'shipping_fee')
  int get shippingFee;
  @override
  @JsonKey(name: 'total_amount')
  int get totalAmount;
  @override
  @JsonKey(name: 'address_snapshot', fromJson: _addrFromJson)
  Map<String, dynamic> get addressSnapshot;
  @override
  String? get note;
  @override
  @JsonKey(name: 'created_at', fromJson: _dtFromJson)
  DateTime get createdAt;
  @override
  @JsonKey(name: 'order_items', fromJson: _itemsFromJson)
  List<OrderItem> get items;
  @override
  @JsonKey(name: 'order_status_logs', fromJson: _logsFromJson)
  List<OrderStatusLog> get statusLogs;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderImplCopyWith<_$OrderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
