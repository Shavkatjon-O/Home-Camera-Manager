// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_source_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventSourceRead _$EventSourceReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'camera_uuid',
      'camera_name',
      'state',
      'mode',
      'endpoint',
      'topics',
      'kinds',
      'conditions',
      'connected_at',
      'last_message_at',
      'error',
    ],
    disallowNullValues: const [
      'camera_uuid',
      'camera_name',
      'state',
      'mode',
      'topics',
      'kinds',
      'conditions',
    ],
  );
  return EventSourceRead(
    cameraUuid: json['camera_uuid'] as String,
    cameraName: json['camera_name'] as String,
    state: EventSourceRead._read_state(json['state']),
    mode: EventSourceRead._read_mode(json['mode']),
    endpoint: json['endpoint'] as String?,
    topics: (json['topics'] as List<dynamic>).map((e) => e as String).toList(),
    kinds: EventSourceRead._read_kinds(json['kinds']),
    conditions: Map<String, bool>.from(json['conditions'] as Map),
    connectedAt: EventSourceRead._read_connectedAt(json['connected_at']),
    lastMessageAt: EventSourceRead._read_lastMessageAt(json['last_message_at']),
    error: json['error'] as String?,
    additionalProperties:
        EventSourceRead._extras(json, 'additionalProperties') == null
        ? const {}
        : EventSourceRead._readExtras(
            EventSourceRead._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$EventSourceReadToJson(EventSourceRead instance) =>
    <String, dynamic>{
      'camera_uuid': instance.cameraUuid,
      'camera_name': instance.cameraName,
      'state': ?EventSourceRead._write_state(instance.state),
      'mode': ?EventSourceRead._write_mode(instance.mode),
      'endpoint': instance.endpoint,
      'topics': instance.topics,
      'kinds': ?EventSourceRead._write_kinds(instance.kinds),
      'conditions': instance.conditions,
      'connected_at': EventSourceRead._write_connectedAt(instance.connectedAt),
      'last_message_at': EventSourceRead._write_lastMessageAt(
        instance.lastMessageAt,
      ),
      'error': instance.error,
    };
