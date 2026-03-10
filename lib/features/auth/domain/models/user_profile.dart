// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

/// 兼容 Supabase 回傳的 +00 與標準 +00:00 格式
DateTime _dateTimeFromJson(String value) {
  // +00 → +00:00
  final normalized = RegExp(r'[+-]\d{2}$').hasMatch(value)
      ? '$value:00'
      : value;
  return DateTime.parse(normalized);
}

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String email,
    @JsonKey(name: 'full_name') String? fullName,
    String? phone,
    @Default('customer') String role,
    @Default(0) int points,
    @JsonKey(name: 'created_at', fromJson: _dateTimeFromJson)
    required DateTime createdAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
