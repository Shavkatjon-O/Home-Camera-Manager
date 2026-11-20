// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CameraRead _$CameraReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'uuid',
      'name',
      'brand',
      'host',
      'device_host',
      'rtsp_port',
      'onvif_port',
      'username',
      'has_password',
      'main_path',
      'sub_path',
      'lenses',
      'ptz_enabled',
      'location',
      'position',
      'enabled',
      'status',
      'streams',
      'created_at',
      'updated_at',
    ],
    disallowNullValues: const [
      'uuid',
      'name',
      'brand',
      'host',
      'rtsp_port',
      'has_password',
      'main_path',
      'lenses',
      'ptz_enabled',
      'position',
      'enabled',
      'status',
      'streams',
      'created_at',
      'updated_at',
    ],
  );
  return CameraRead(
    uuid: json['uuid'] as String,
    name: json['name'] as String,
    brand: CameraRead._read_brand(json['brand']),
    host: json['host'] as String,
    deviceHost: json['device_host'] as String?,
    rtspPort: CameraRead._read_rtspPort(json['rtsp_port']),
    onvifPort: CameraRead._read_onvifPort(json['onvif_port']),
    username: json['username'] as String?,
    hasPassword: json['has_password'] as bool,
    mainPath: json['main_path'] as String,
    subPath: json['sub_path'] as String?,
    lenses: CameraRead._read_lenses(json['lenses']),
    ptzEnabled: json['ptz_enabled'] as bool,
    location: json['location'] as String?,
    position: CameraRead._read_position(json['position']),
    enabled: json['enabled'] as bool,
    status: CameraStatus.fromJson(json['status'] as Map<String, dynamic>),
    streams: CameraStreams.fromJson(json['streams'] as Map<String, dynamic>),
    createdAt: CameraRead._read_createdAt(json['created_at']),
    updatedAt: CameraRead._read_updatedAt(json['updated_at']),
    connector: json['connector'] as String?,
    device: json['device'] as String?,
    channel: CameraRead._read_channel(json['channel']),
    capabilities: json['capabilities'] == null
        ? null
        : CapabilitiesRead.fromJson(
            json['capabilities'] as Map<String, dynamic>,
          ),
    additionalProperties:
        CameraRead._extras(json, 'additionalProperties') == null
        ? const {}
        : CameraRead._readExtras(
            CameraRead._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$CameraReadToJson(CameraRead instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'name': instance.name,
      'brand': ?CameraRead._write_brand(instance.brand),
      'host': instance.host,
      'device_host': instance.deviceHost,
      'rtsp_port': ?CameraRead._write_rtspPort(instance.rtspPort),
      'onvif_port': CameraRead._write_onvifPort(instance.onvifPort),
      'username': instance.username,
      'has_password': instance.hasPassword,
      'main_path': instance.mainPath,
      'sub_path': instance.subPath,
      'lenses': ?CameraRead._write_lenses(instance.lenses),
      'ptz_enabled': instance.ptzEnabled,
      'location': instance.location,
      'position': ?CameraRead._write_position(instance.position),
      'enabled': instance.enabled,
      'status': instance.status.toJson(),
      'streams': instance.streams.toJson(),
      'created_at': ?CameraRead._write_createdAt(instance.createdAt),
      'updated_at': ?CameraRead._write_updatedAt(instance.updatedAt),
      'connector': ?instance.connector,
      'device': ?instance.device,
      'channel': ?CameraRead._write_channel(instance.channel),
      'capabilities': ?instance.capabilities?.toJson(),
    };
