// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_counts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventCounts _$EventCountsFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['total', 'kinds', 'labels', 'alerts'],
    disallowNullValues: const ['total', 'kinds', 'labels', 'alerts'],
  );
  return EventCounts(
    total: EventCounts._read_total(json['total']),
    kinds: EventCounts._read_kinds(json['kinds']),
    labels: EventCounts._read_labels(json['labels']),
    alerts: EventCounts._read_alerts(json['alerts']),
    additionalProperties: EventCounts._extras(json, 'additionalProperties') == null
        ? const {}
        : EventCounts._readExtras(EventCounts._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$EventCountsToJson(EventCounts instance) => <String, dynamic>{
  'total': ?EventCounts._write_total(instance.total),
  'kinds': ?EventCounts._write_kinds(instance.kinds),
  'labels': ?EventCounts._write_labels(instance.labels),
  'alerts': ?EventCounts._write_alerts(instance.alerts),
};
