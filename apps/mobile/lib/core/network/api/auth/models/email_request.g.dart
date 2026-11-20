// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmailRequest _$EmailRequestFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['email'], disallowNullValues: const ['email']);
  return EmailRequest(
    email: json['email'] as String,
    additionalProperties: EmailRequest._extras(json, 'additionalProperties') == null
        ? const {}
        : EmailRequest._readExtras(EmailRequest._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$EmailRequestToJson(EmailRequest instance) => <String, dynamic>{
  'email': instance.email,
};
