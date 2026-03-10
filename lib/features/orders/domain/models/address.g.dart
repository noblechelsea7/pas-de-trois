// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AddressImpl _$$AddressImplFromJson(Map<String, dynamic> json) =>
    _$AddressImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      label: json['label'] as String? ?? '預設',
      recipientName: json['recipient_name'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: _dtFromJson(json['created_at'] as String),
    );

Map<String, dynamic> _$$AddressImplToJson(_$AddressImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'label': instance.label,
      'recipient_name': instance.recipientName,
      'phone': instance.phone,
      'address': instance.address,
      'is_default': instance.isDefault,
      'created_at': instance.createdAt.toIso8601String(),
    };
