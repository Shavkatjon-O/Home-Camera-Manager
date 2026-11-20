// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rules_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RulesUpdate _$RulesUpdateFromJson(Map<String, dynamic> json) {
  $checkKeys(json, disallowNullValues: const ['zones', 'lines']);
  return RulesUpdate(
    zones: (json['zones'] as List<dynamic>?)
        ?.map((e) => ZoneInput.fromJson(e as Map<String, dynamic>))
        .toList(),
    lines: (json['lines'] as List<dynamic>?)
        ?.map((e) => LineInput.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties: RulesUpdate._extras(json, 'additionalProperties') == null
        ? const {}
        : RulesUpdate._readExtras(RulesUpdate._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$RulesUpdateToJson(RulesUpdate instance) => <String, dynamic>{
  'zones': ?instance.zones?.map((e) => e.toJson()).toList(),
  'lines': ?instance.lines?.map((e) => e.toJson()).toList(),
};
