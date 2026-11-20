// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_device_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetworkDeviceCreate _$NetworkDeviceCreateFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['name', 'kind', 'host'],
    disallowNullValues: const ['name', 'kind', 'host', 'probe_port', 'enabled'],
  );
  return NetworkDeviceCreate(
    name: json['name'] as String,
    kind: NetworkDeviceCreate._read_kind(json['kind']),
    host: json['host'] as String,
    probePort: NetworkDeviceCreate._presentValue(json, 'probe_port') == null
        ? 80
        : NetworkDeviceCreate._read_probePort(
            NetworkDeviceCreate._presentValue(json, 'probe_port') as Object,
          ),
    parentUuid: json['parent_uuid'] as String?,
    link: NetworkDeviceCreate._read_link(json['link']),
    notes: json['notes'] as String?,
    enabled: NetworkDeviceCreate._presentValue(json, 'enabled') == null
        ? true
        : NetworkDeviceCreate._read_enabled(
            NetworkDeviceCreate._presentValue(json, 'enabled') as Object,
          ),
    additionalProperties:
        NetworkDeviceCreate._extras(json, 'additionalProperties') == null
        ? const {}
        : NetworkDeviceCreate._readExtras(
            NetworkDeviceCreate._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$NetworkDeviceCreateToJson(
  NetworkDeviceCreate instance,
) => <String, dynamic>{
  'name': instance.name,
  'kind': ?NetworkDeviceCreate._write_kind(instance.kind),
  'host': instance.host,
  'probe_port': ?NetworkDeviceCreate._write_probePort(instance.probePort),
  'parent_uuid': ?instance.parentUuid,
  'link': ?NetworkDeviceCreate._write_link(instance.link),
  'notes': ?instance.notes,
  'enabled': ?NetworkDeviceCreate._write_enabled(instance.enabled),
};
