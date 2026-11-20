// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jwk_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JwkSet _$JwkSetFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['keys'], disallowNullValues: const ['keys']);
  return JwkSet(
    keys: (json['keys'] as List<dynamic>)
        .map((e) => Jwk.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties: JwkSet._extras(json, 'additionalProperties') == null
        ? const {}
        : JwkSet._readExtras(JwkSet._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$JwkSetToJson(JwkSet instance) => <String, dynamic>{
  'keys': instance.keys.map((e) => e.toJson()).toList(),
};
