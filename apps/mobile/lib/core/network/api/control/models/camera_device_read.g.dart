// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_device_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CameraDeviceRead _$CameraDeviceReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['camera_uuid', 'supported'],
    disallowNullValues: const ['camera_uuid', 'supported', 'can_reboot'],
  );
  return CameraDeviceRead(
    cameraUuid: json['camera_uuid'] as String,
    supported: json['supported'] as bool,
    reason: json['reason'] as String?,
    endpoint: json['endpoint'] as String?,
    manufacturer: json['manufacturer'] as String?,
    model: json['model'] as String?,
    firmware: json['firmware'] as String?,
    serial: json['serial'] as String?,
    hardwareId: json['hardware_id'] as String?,
    clock: json['clock'] == null
        ? null
        : ClockRead.fromJson(json['clock'] as Map<String, dynamic>),
    canReboot: CameraDeviceRead._presentValue(json, 'can_reboot') == null
        ? false
        : CameraDeviceRead._read_canReboot(
            CameraDeviceRead._presentValue(json, 'can_reboot') as Object,
          ),
    additionalProperties:
        CameraDeviceRead._extras(json, 'additionalProperties') == null
        ? const {}
        : CameraDeviceRead._readExtras(
            CameraDeviceRead._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$CameraDeviceReadToJson(CameraDeviceRead instance) =>
    <String, dynamic>{
      'camera_uuid': instance.cameraUuid,
      'supported': instance.supported,
      'reason': ?instance.reason,
      'endpoint': ?instance.endpoint,
      'manufacturer': ?instance.manufacturer,
      'model': ?instance.model,
      'firmware': ?instance.firmware,
      'serial': ?instance.serial,
      'hardware_id': ?instance.hardwareId,
      'clock': ?instance.clock?.toJson(),
      'can_reboot': ?CameraDeviceRead._write_canReboot(instance.canReboot),
    };
