// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discovered_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiscoveredRead _$DiscoveredReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'uuid',
      'host',
      'open_ports',
      'brand',
      'manufacturer',
      'model',
      'onvif_port',
      'found_by',
      'seen_at',
      'camera',
    ],
    disallowNullValues: const [
      'uuid',
      'host',
      'open_ports',
      'found_by',
      'seen_at',
    ],
  );
  return DiscoveredRead(
    uuid: json['uuid'] as String,
    host: json['host'] as String,
    openPorts: DiscoveredRead._read_openPorts(json['open_ports']),
    brand: DiscoveredRead._read_brand(json['brand']),
    manufacturer: json['manufacturer'] as String?,
    model: json['model'] as String?,
    onvifPort: DiscoveredRead._read_onvifPort(json['onvif_port']),
    foundBy: DiscoveredRead._read_foundBy(json['found_by']),
    seenAt: DiscoveredRead._read_seenAt(json['seen_at']),
    camera: json['camera'] as String?,
    additionalProperties:
        DiscoveredRead._extras(json, 'additionalProperties') == null
        ? const {}
        : DiscoveredRead._readExtras(
            DiscoveredRead._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$DiscoveredReadToJson(DiscoveredRead instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'host': instance.host,
      'open_ports': ?DiscoveredRead._write_openPorts(instance.openPorts),
      'brand': DiscoveredRead._write_brand(instance.brand),
      'manufacturer': instance.manufacturer,
      'model': instance.model,
      'onvif_port': DiscoveredRead._write_onvifPort(instance.onvifPort),
      'found_by': ?DiscoveredRead._write_foundBy(instance.foundBy),
      'seen_at': ?DiscoveredRead._write_seenAt(instance.seenAt),
      'camera': instance.camera,
    };
