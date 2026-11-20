// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connector_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConnectorRead _$ConnectorReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'uuid',
      'name',
      'version',
      'mode',
      'address',
      'online',
      'last_seen_at',
      'camera_count',
      'discovery_requested_at',
      'discovered_at',
      'health',
      'created_at',
    ],
    disallowNullValues: const [
      'uuid',
      'name',
      'mode',
      'online',
      'camera_count',
      'health',
      'created_at',
    ],
  );
  return ConnectorRead(
    uuid: json['uuid'] as String,
    name: json['name'] as String,
    version: json['version'] as String?,
    mode: ConnectorRead._read_mode(json['mode']),
    address: json['address'] as String?,
    online: json['online'] as bool,
    lastSeenAt: ConnectorRead._read_lastSeenAt(json['last_seen_at']),
    cameraCount: ConnectorRead._read_cameraCount(json['camera_count']),
    discoveryRequestedAt: ConnectorRead._read_discoveryRequestedAt(json['discovery_requested_at']),
    discoveredAt: ConnectorRead._read_discoveredAt(json['discovered_at']),
    health: json['health'] as Map<String, dynamic>,
    createdAt: ConnectorRead._read_createdAt(json['created_at']),
    additionalProperties: ConnectorRead._extras(json, 'additionalProperties') == null
        ? const {}
        : ConnectorRead._readExtras(ConnectorRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$ConnectorReadToJson(ConnectorRead instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'name': instance.name,
  'version': instance.version,
  'mode': ?ConnectorRead._write_mode(instance.mode),
  'address': instance.address,
  'online': instance.online,
  'last_seen_at': ConnectorRead._write_lastSeenAt(instance.lastSeenAt),
  'camera_count': ?ConnectorRead._write_cameraCount(instance.cameraCount),
  'discovery_requested_at': ConnectorRead._write_discoveryRequestedAt(
    instance.discoveryRequestedAt,
  ),
  'discovered_at': ConnectorRead._write_discoveredAt(instance.discoveredAt),
  'health': instance.health,
  'created_at': ?ConnectorRead._write_createdAt(instance.createdAt),
};
