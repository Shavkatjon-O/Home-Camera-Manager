// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_device_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetworkDeviceUpdate _$NetworkDeviceUpdateFromJson(Map<String, dynamic> json) =>
    NetworkDeviceUpdate(
      name: json['name'] as String?,
      kind: NetworkDeviceUpdate._read_kind(json['kind']),
      host: json['host'] as String?,
      probePort: NetworkDeviceUpdate._read_probePort(json['probe_port']),
      parentUuid: json['parent_uuid'] as String?,
      link: NetworkDeviceUpdate._read_link(json['link']),
      notes: json['notes'] as String?,
      enabled: json['enabled'] as bool?,
      additionalProperties:
          NetworkDeviceUpdate._extras(json, 'additionalProperties') == null
          ? const {}
          : NetworkDeviceUpdate._readExtras(
              NetworkDeviceUpdate._extras(json, 'additionalProperties'),
            ),
    );

Map<String, dynamic> _$NetworkDeviceUpdateToJson(
  NetworkDeviceUpdate instance,
) => <String, dynamic>{
  'name': ?instance.name,
  'kind': ?NetworkDeviceUpdate._write_kind(instance.kind),
  'host': ?instance.host,
  'probe_port': ?NetworkDeviceUpdate._write_probePort(instance.probePort),
  'parent_uuid': ?instance.parentUuid,
  'link': ?NetworkDeviceUpdate._write_link(instance.link),
  'notes': ?instance.notes,
  'enabled': ?instance.enabled,
};
