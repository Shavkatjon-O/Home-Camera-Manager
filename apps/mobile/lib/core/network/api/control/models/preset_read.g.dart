// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preset_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PresetRead _$PresetReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['token', 'name'],
    disallowNullValues: const ['token', 'name'],
  );
  return PresetRead(
    token: json['token'] as String,
    name: json['name'] as String,
    additionalProperties: PresetRead._extras(json, 'additionalProperties') == null
        ? const {}
        : PresetRead._readExtras(PresetRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$PresetReadToJson(PresetRead instance) => <String, dynamic>{
  'token': instance.token,
  'name': instance.name,
};
