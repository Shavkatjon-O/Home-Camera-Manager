// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResult _$SearchResultFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'uuid',
      'camera_uuid',
      'camera_name',
      'kind',
      'source_topic',
      'started_at',
      'ended_at',
      'ongoing',
      'duration_seconds',
      'camera_time',
      'has_snapshot',
      'has_thumbnail',
      'details',
      'created_at',
      'updated_at',
      'face',
    ],
    disallowNullValues: const [
      'uuid',
      'camera_uuid',
      'kind',
      'source',
      'source_topic',
      'alert',
      'started_at',
      'ongoing',
      'duration_seconds',
      'has_snapshot',
      'has_thumbnail',
      'has_clip',
      'details',
      'created_at',
      'updated_at',
    ],
  );
  return SearchResult(
    uuid: json['uuid'] as String,
    cameraUuid: json['camera_uuid'] as String,
    cameraName: json['camera_name'] as String?,
    kind: json['kind'] as String,
    source: SearchResult._presentValue(json, 'source') == null
        ? "camera"
        : SearchResult._read_source(
            SearchResult._presentValue(json, 'source') as Object,
          ),
    sourceTopic: json['source_topic'] as String,
    label: json['label'] as String?,
    alert: SearchResult._presentValue(json, 'alert') == null
        ? false
        : SearchResult._read_alert(
            SearchResult._presentValue(json, 'alert') as Object,
          ),
    viewUuid: json['view_uuid'] as String?,
    startedAt: SearchResult._read_startedAt(json['started_at']),
    endedAt: SearchResult._read_endedAt(json['ended_at']),
    ongoing: json['ongoing'] as bool,
    durationSeconds: json['duration_seconds'] as num,
    cameraTime: SearchResult._read_cameraTime(json['camera_time']),
    hasSnapshot: json['has_snapshot'] as bool,
    hasThumbnail: json['has_thumbnail'] as bool,
    hasClip: SearchResult._presentValue(json, 'has_clip') == null
        ? false
        : SearchResult._read_hasClip(
            SearchResult._presentValue(json, 'has_clip') as Object,
          ),
    details: json['details'] as Map<String, dynamic>,
    createdAt: SearchResult._read_createdAt(json['created_at']),
    updatedAt: SearchResult._read_updatedAt(json['updated_at']),
    face: json['face'] == null
        ? null
        : FaceRead.fromJson(json['face'] as Map<String, dynamic>),
    additionalProperties:
        SearchResult._extras(json, 'additionalProperties') == null
        ? const {}
        : SearchResult._readExtras(
            SearchResult._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$SearchResultToJson(SearchResult instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'camera_uuid': instance.cameraUuid,
      'camera_name': instance.cameraName,
      'kind': instance.kind,
      'source': ?SearchResult._write_source(instance.source),
      'source_topic': instance.sourceTopic,
      'label': ?instance.label,
      'alert': ?SearchResult._write_alert(instance.alert),
      'view_uuid': ?instance.viewUuid,
      'started_at': ?SearchResult._write_startedAt(instance.startedAt),
      'ended_at': SearchResult._write_endedAt(instance.endedAt),
      'ongoing': instance.ongoing,
      'duration_seconds': instance.durationSeconds,
      'camera_time': SearchResult._write_cameraTime(instance.cameraTime),
      'has_snapshot': instance.hasSnapshot,
      'has_thumbnail': instance.hasThumbnail,
      'has_clip': ?SearchResult._write_hasClip(instance.hasClip),
      'details': instance.details,
      'created_at': ?SearchResult._write_createdAt(instance.createdAt),
      'updated_at': ?SearchResult._write_updatedAt(instance.updatedAt),
      'face': instance.face?.toJson(),
    };
