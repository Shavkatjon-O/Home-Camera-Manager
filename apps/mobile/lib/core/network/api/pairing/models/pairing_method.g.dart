// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_method.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PairingMethod _$PairingMethodFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'title',
      'description',
      'requires',
      'parameters',
      'endpoint',
    ],
    disallowNullValues: const [
      'id',
      'title',
      'description',
      'requires',
      'parameters',
      'endpoint',
      'recommended',
    ],
  );
  return PairingMethod(
    id: PairingMethod._read_id(json['id']),
    title: json['title'] as String,
    description: json['description'] as String,
    requires: (json['requires'] as List<dynamic>)
        .map((e) => e as String)
        .toList(),
    parameters: (json['parameters'] as List<dynamic>)
        .map((e) => PairingParameter.fromJson(e as Map<String, dynamic>))
        .toList(),
    endpoint: json['endpoint'] as String,
    adapter: json['adapter'] as String?,
    recommended: PairingMethod._presentValue(json, 'recommended') == null
        ? false
        : PairingMethod._read_recommended(
            PairingMethod._presentValue(json, 'recommended') as Object,
          ),
    additionalProperties:
        PairingMethod._extras(json, 'additionalProperties') == null
        ? const {}
        : PairingMethod._readExtras(
            PairingMethod._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$PairingMethodToJson(PairingMethod instance) =>
    <String, dynamic>{
      'id': ?PairingMethod._write_id(instance.id),
      'title': instance.title,
      'description': instance.description,
      'requires': instance.requires,
      'parameters': instance.parameters.map((e) => e.toJson()).toList(),
      'endpoint': instance.endpoint,
      'adapter': ?instance.adapter,
      'recommended': ?PairingMethod._write_recommended(instance.recommended),
    };
