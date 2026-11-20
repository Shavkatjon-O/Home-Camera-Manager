// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PairingStats _$PairingStatsFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['since', 'methods'],
    disallowNullValues: const ['since', 'methods'],
  );
  return PairingStats(
    since: PairingStats._read_since(json['since']),
    methods: (json['methods'] as List<dynamic>)
        .map((e) => MethodStats.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties:
        PairingStats._extras(json, 'additionalProperties') == null
        ? const {}
        : PairingStats._readExtras(
            PairingStats._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$PairingStatsToJson(PairingStats instance) =>
    <String, dynamic>{
      'since': ?PairingStats._write_since(instance.since),
      'methods': instance.methods.map((e) => e.toJson()).toList(),
    };
