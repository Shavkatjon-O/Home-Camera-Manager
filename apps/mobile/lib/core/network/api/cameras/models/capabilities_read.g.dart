// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capabilities_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CapabilitiesRead _$CapabilitiesReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'adapter',
      'version',
      'kind',
      'channels',
      'identify',
      'media',
      'control',
      'imaging',
      'events',
      'playback',
      'maintenance',
      'provisioning',
    ],
    disallowNullValues: const [
      'adapter',
      'version',
      'kind',
      'channels',
      'identify',
      'media',
      'control',
      'imaging',
      'events',
      'playback',
      'maintenance',
      'provisioning',
    ],
  );
  return CapabilitiesRead(
    adapter: json['adapter'] as String,
    version: CapabilitiesRead._read_version(json['version']),
    kind: json['kind'] as String,
    channels: CapabilitiesRead._read_channels(json['channels']),
    identify: json['identify'] as bool,
    media: MediaCapabilities.fromJson(json['media'] as Map<String, dynamic>),
    control: ControlCapabilities.fromJson(
      json['control'] as Map<String, dynamic>,
    ),
    imaging: ImagingCapabilities.fromJson(
      json['imaging'] as Map<String, dynamic>,
    ),
    events: EventCapabilities.fromJson(json['events'] as Map<String, dynamic>),
    playback: PlaybackCapabilities.fromJson(
      json['playback'] as Map<String, dynamic>,
    ),
    maintenance: MaintenanceCapabilities.fromJson(
      json['maintenance'] as Map<String, dynamic>,
    ),
    provisioning: ProvisioningCapabilities.fromJson(
      json['provisioning'] as Map<String, dynamic>,
    ),
    additionalProperties:
        CapabilitiesRead._extras(json, 'additionalProperties') == null
        ? const {}
        : CapabilitiesRead._readExtras(
            CapabilitiesRead._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$CapabilitiesReadToJson(CapabilitiesRead instance) =>
    <String, dynamic>{
      'adapter': instance.adapter,
      'version': ?CapabilitiesRead._write_version(instance.version),
      'kind': instance.kind,
      'channels': ?CapabilitiesRead._write_channels(instance.channels),
      'identify': instance.identify,
      'media': instance.media.toJson(),
      'control': instance.control.toJson(),
      'imaging': instance.imaging.toJson(),
      'events': instance.events.toJson(),
      'playback': instance.playback.toJson(),
      'maintenance': instance.maintenance.toJson(),
      'provisioning': instance.provisioning.toJson(),
    };
