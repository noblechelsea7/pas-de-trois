// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'address.freezed.dart';
part 'address.g.dart';

DateTime _dtFromJson(String v) {
  final n = RegExp(r'[+-]\d{2}$').hasMatch(v) ? '$v:00' : v;
  return DateTime.parse(n);
}

@freezed
class Address with _$Address {
  const factory Address({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @Default('預設') String label,
    @JsonKey(name: 'recipient_name') required String recipientName,
    required String phone,
    required String address,
    @JsonKey(name: 'is_default') @Default(false) bool isDefault,
    @JsonKey(name: 'created_at', fromJson: _dtFromJson) required DateTime createdAt,
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
}
