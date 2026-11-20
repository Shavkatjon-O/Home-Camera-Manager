// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_change.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PasswordChange _$PasswordChangeFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['current_password', 'new_password'],
    disallowNullValues: const ['current_password', 'new_password'],
  );
  return PasswordChange(
    currentPassword: json['current_password'] as String,
    newPassword: json['new_password'] as String,
    additionalProperties: PasswordChange._extras(json, 'additionalProperties') == null
        ? const {}
        : PasswordChange._readExtras(PasswordChange._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$PasswordChangeToJson(PasswordChange instance) => <String, dynamic>{
  'current_password': instance.currentPassword,
  'new_password': instance.newPassword,
};
