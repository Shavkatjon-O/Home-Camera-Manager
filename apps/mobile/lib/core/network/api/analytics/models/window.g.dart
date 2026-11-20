// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'window.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Window _$WindowFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['start', 'end'],
    disallowNullValues: const ['start', 'end', 'days'],
  );
  return Window(
    start: json['start'] as String,
    end: json['end'] as String,
    days: Window._read_days(json['days']),
    additionalProperties: Window._extras(json, 'additionalProperties') == null
        ? const {}
        : Window._readExtras(Window._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$WindowToJson(Window instance) => <String, dynamic>{
  'start': instance.start,
  'end': instance.end,
  'days': ?Window._write_days(instance.days),
};
