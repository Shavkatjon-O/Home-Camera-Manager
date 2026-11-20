// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CameraStatus _$CameraStatusFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['online', 'checked_at', 'error']);
  return CameraStatus(
    online: json['online'] as bool?,
    checkedAt: CameraStatus._read_checkedAt(json['checked_at']),
    error: json['error'] as String?,
    additionalProperties:
        CameraStatus._extras(json, 'additionalProperties') == null
        ? const {}
        : CameraStatus._readExtras(
            CameraStatus._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$CameraStatusToJson(CameraStatus instance) =>
    <String, dynamic>{
      'online': instance.online,
      'checked_at': CameraStatus._write_checkedAt(instance.checkedAt),
      'error': instance.error,
    };
