// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preset_name.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PresetName _$PresetNameFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['name'], disallowNullValues: const ['name']);
  return PresetName(
    name: json['name'] as String,
    additionalProperties: PresetName._extras(json, 'additionalProperties') == null
        ? const {}
        : PresetName._readExtras(PresetName._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$PresetNameToJson(PresetName instance) => <String, dynamic>{
  'name': instance.name,
};
