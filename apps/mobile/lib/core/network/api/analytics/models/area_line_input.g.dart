// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'area_line_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AreaLineInput _$AreaLineInputFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['line_uuid', 'entering'],
    disallowNullValues: const ['line_uuid', 'entering'],
  );
  return AreaLineInput(
    lineUuid: json['line_uuid'] as String,
    entering: AreaLineInput._read_entering(json['entering']),
    additionalProperties:
        AreaLineInput._extras(json, 'additionalProperties') == null
        ? const {}
        : AreaLineInput._readExtras(
            AreaLineInput._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$AreaLineInputToJson(AreaLineInput instance) =>
    <String, dynamic>{
      'line_uuid': instance.lineUuid,
      'entering': ?AreaLineInput._write_entering(instance.entering),
    };
