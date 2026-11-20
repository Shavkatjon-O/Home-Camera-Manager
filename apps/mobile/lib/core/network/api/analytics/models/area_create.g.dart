// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'area_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AreaCreate _$AreaCreateFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['name', 'lines'],
    disallowNullValues: const ['name', 'lines', 'labels'],
  );
  return AreaCreate(
    name: json['name'] as String,
    lines: (json['lines'] as List<dynamic>)
        .map((e) => AreaLineInput.fromJson(e as Map<String, dynamic>))
        .toList(),
    labels: (json['labels'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    resetAt: json['reset_at'] as String?,
    additionalProperties:
        AreaCreate._extras(json, 'additionalProperties') == null
        ? const {}
        : AreaCreate._readExtras(
            AreaCreate._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$AreaCreateToJson(AreaCreate instance) =>
    <String, dynamic>{
      'name': instance.name,
      'lines': instance.lines.map((e) => e.toJson()).toList(),
      'labels': ?instance.labels,
      'reset_at': ?instance.resetAt,
    };
