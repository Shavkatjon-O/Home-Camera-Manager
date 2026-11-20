// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jwk.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Jwk _$JwkFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['kty', 'crv', 'x', 'y', 'kid', 'use', 'alg'],
    disallowNullValues: const ['kty', 'crv', 'x', 'y', 'kid', 'use', 'alg'],
  );
  return Jwk(
    kty: json['kty'] as String,
    crv: json['crv'] as String,
    x: json['x'] as String,
    y: json['y'] as String,
    kid: json['kid'] as String,
    use: json['use'] as String,
    alg: json['alg'] as String,
    additionalProperties: Jwk._extras(json, 'additionalProperties') == null
        ? const {}
        : Jwk._readExtras(Jwk._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$JwkToJson(Jwk instance) => <String, dynamic>{
  'kty': instance.kty,
  'crv': instance.crv,
  'x': instance.x,
  'y': instance.y,
  'kid': instance.kid,
  'use': instance.use,
  'alg': instance.alg,
};
