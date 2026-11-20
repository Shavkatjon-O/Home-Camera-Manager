// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'area_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AreaUpdate _$AreaUpdateFromJson(Map<String, dynamic> json) => AreaUpdate(
  name: json['name'] as String?,
  lines: (json['lines'] as List<dynamic>?)
      ?.map((e) => AreaLineInput.fromJson(e as Map<String, dynamic>))
      .toList(),
  labels: (json['labels'] as List<dynamic>?)?.map((e) => e as String).toList(),
  resetAt: json['reset_at'] as String?,
  additionalProperties: AreaUpdate._extras(json, 'additionalProperties') == null
      ? const {}
      : AreaUpdate._readExtras(
          AreaUpdate._extras(json, 'additionalProperties'),
        ),
);

Map<String, dynamic> _$AreaUpdateToJson(AreaUpdate instance) =>
    <String, dynamic>{
      'name': ?instance.name,
      'lines': ?instance.lines?.map((e) => e.toJson()).toList(),
      'labels': ?instance.labels,
      'reset_at': ?instance.resetAt,
    };
