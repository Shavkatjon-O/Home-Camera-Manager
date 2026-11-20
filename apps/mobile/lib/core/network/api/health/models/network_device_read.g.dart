// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_device_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetworkDeviceRead _$NetworkDeviceReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'uuid',
      'name',
      'kind',
      'host',
      'probe_port',
      'parent_uuid',
      'parent_name',
      'link',
      'notes',
      'enabled',
      'created_at',
      'updated_at',
    ],
    disallowNullValues: const [
      'uuid',
      'name',
      'kind',
      'host',
      'probe_port',
      'enabled',
      'created_at',
      'updated_at',
    ],
  );
  return NetworkDeviceRead(
    uuid: json['uuid'] as String,
    name: json['name'] as String,
    kind: NetworkDeviceRead._read_kind(json['kind']),
    host: json['host'] as String,
    probePort: NetworkDeviceRead._read_probePort(json['probe_port']),
    parentUuid: json['parent_uuid'] as String?,
    parentName: json['parent_name'] as String?,
    link: NetworkDeviceRead._read_link(json['link']),
    notes: json['notes'] as String?,
    enabled: json['enabled'] as bool,
    createdAt: NetworkDeviceRead._read_createdAt(json['created_at']),
    updatedAt: NetworkDeviceRead._read_updatedAt(json['updated_at']),
    additionalProperties: NetworkDeviceRead._extras(json, 'additionalProperties') == null
        ? const {}
        : NetworkDeviceRead._readExtras(NetworkDeviceRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$NetworkDeviceReadToJson(NetworkDeviceRead instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'name': instance.name,
  'kind': ?NetworkDeviceRead._write_kind(instance.kind),
  'host': instance.host,
  'probe_port': ?NetworkDeviceRead._write_probePort(instance.probePort),
  'parent_uuid': instance.parentUuid,
  'parent_name': instance.parentName,
  'link': NetworkDeviceRead._write_link(instance.link),
  'notes': instance.notes,
  'enabled': instance.enabled,
  'created_at': ?NetworkDeviceRead._write_createdAt(instance.createdAt),
  'updated_at': ?NetworkDeviceRead._write_updatedAt(instance.updatedAt),
};
