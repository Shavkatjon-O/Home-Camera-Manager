// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_email.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyEmail _$VerifyEmailFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['token'], disallowNullValues: const ['token']);
  return VerifyEmail(
    token: json['token'] as String,
    additionalProperties: VerifyEmail._extras(json, 'additionalProperties') == null
        ? const {}
        : VerifyEmail._readExtras(VerifyEmail._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$VerifyEmailToJson(VerifyEmail instance) => <String, dynamic>{
  'token': instance.token,
};
