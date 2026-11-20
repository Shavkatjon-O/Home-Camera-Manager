// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faces_consent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FacesConsent _$FacesConsentFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['version', 'text'],
    disallowNullValues: const ['version', 'text'],
  );
  return FacesConsent(
    version: json['version'] as String,
    text: json['text'] as String,
    additionalProperties: FacesConsent._extras(json, 'additionalProperties') == null
        ? const {}
        : FacesConsent._readExtras(FacesConsent._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$FacesConsentToJson(FacesConsent instance) => <String, dynamic>{
  'version': instance.version,
  'text': instance.text,
};
