// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recordings_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecordingsRead _$RecordingsReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['camera_uuid', 'supported'],
    disallowNullValues: const ['camera_uuid', 'supported', 'segments', 'playback'],
  );
  return RecordingsRead(
    cameraUuid: json['camera_uuid'] as String,
    supported: json['supported'] as bool,
    reason: json['reason'] as String?,
    recordings: RecordingsRead._read_recordings(json['recordings']),
    dataFrom: RecordingsRead._read_dataFrom(json['data_from']),
    dataUntil: RecordingsRead._read_dataUntil(json['data_until']),
    start: RecordingsRead._read_start(json['start']),
    end: RecordingsRead._read_end(json['end']),
    segments: RecordingsRead._presentValue(json, 'segments') == null
        ? const []
        : RecordingsRead._read_segments(RecordingsRead._presentValue(json, 'segments') as Object),
    playback: RecordingsRead._presentValue(json, 'playback') == null
        ? false
        : RecordingsRead._read_playback(RecordingsRead._presentValue(json, 'playback') as Object),
    playbackReason: json['playback_reason'] as String?,
    additionalProperties: RecordingsRead._extras(json, 'additionalProperties') == null
        ? const {}
        : RecordingsRead._readExtras(RecordingsRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$RecordingsReadToJson(RecordingsRead instance) => <String, dynamic>{
  'camera_uuid': instance.cameraUuid,
  'supported': instance.supported,
  'reason': ?instance.reason,
  'recordings': ?RecordingsRead._write_recordings(instance.recordings),
  'data_from': ?RecordingsRead._write_dataFrom(instance.dataFrom),
  'data_until': ?RecordingsRead._write_dataUntil(instance.dataUntil),
  'start': ?RecordingsRead._write_start(instance.start),
  'end': ?RecordingsRead._write_end(instance.end),
  'segments': ?RecordingsRead._write_segments(instance.segments),
  'playback': ?RecordingsRead._write_playback(instance.playback),
  'playback_reason': ?instance.playbackReason,
};
