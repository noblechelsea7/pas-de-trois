// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'customer',
      isAdmin: json['is_admin'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      adminNotes: json['admin_notes'] as String?,
      points: (json['points'] as num?)?.toInt() ?? 0,
      createdAt: _dateTimeFromJson(json['created_at'] as String),
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'full_name': instance.fullName,
      'phone': instance.phone,
      'role': instance.role,
      'is_admin': instance.isAdmin,
      'is_active': instance.isActive,
      'admin_notes': instance.adminNotes,
      'points': instance.points,
      'created_at': instance.createdAt.toIso8601String(),
    };
