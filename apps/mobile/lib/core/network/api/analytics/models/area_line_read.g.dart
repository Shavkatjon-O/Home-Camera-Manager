// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'area_line_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AreaLineRead _$AreaLineReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['line_uuid', 'line_name', 'view_name', 'entering'],
    disallowNullValues: const ['line_uuid', 'entering'],
  );
  return AreaLineRead(
    lineUuid: json['line_uuid'] as String,
    lineName: json['line_name'] as String?,
    viewName: json['view_name'] as String?,
    entering: json['entering'] as String,
    additionalProperties:
        AreaLineRead._extras(json, 'additionalProperties') == null
        ? const {}
        : AreaLineRead._readExtras(
            AreaLineRead._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$AreaLineReadToJson(AreaLineRead instance) =>
    <String, dynamic>{
      'line_uuid': instance.lineUuid,
      'line_name': instance.lineName,
      'view_name': instance.viewName,
      'entering': instance.entering,
    };
