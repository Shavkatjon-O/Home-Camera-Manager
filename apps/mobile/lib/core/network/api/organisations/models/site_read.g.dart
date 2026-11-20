// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SiteRead _$SiteReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'uuid',
      'organisation',
      'organisation_name',
      'name',
      'kind',
      'timezone',
      'position',
      'role',
      'camera_count',
      'connector_count',
      'created_at',
      'updated_at',
    ],
    disallowNullValues: const [
      'uuid',
      'organisation',
      'organisation_name',
      'name',
      'kind',
      'timezone',
      'position',
      'role',
      'camera_count',
      'connector_count',
      'created_at',
      'updated_at',
    ],
  );
  return SiteRead(
    uuid: json['uuid'] as String,
    organisation: json['organisation'] as String,
    organisationName: json['organisation_name'] as String,
    name: json['name'] as String,
    kind: SiteRead._read_kind(json['kind']),
    timezone: json['timezone'] as String,
    position: SiteRead._read_position(json['position']),
    role: SiteRead._read_role(json['role']),
    cameraCount: SiteRead._read_cameraCount(json['camera_count']),
    connectorCount: SiteRead._read_connectorCount(json['connector_count']),
    createdAt: SiteRead._read_createdAt(json['created_at']),
    updatedAt: SiteRead._read_updatedAt(json['updated_at']),
    additionalProperties: SiteRead._extras(json, 'additionalProperties') == null
        ? const {}
        : SiteRead._readExtras(SiteRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$SiteReadToJson(SiteRead instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'organisation': instance.organisation,
  'organisation_name': instance.organisationName,
  'name': instance.name,
  'kind': ?SiteRead._write_kind(instance.kind),
  'timezone': instance.timezone,
  'position': ?SiteRead._write_position(instance.position),
  'role': ?SiteRead._write_role(instance.role),
  'camera_count': ?SiteRead._write_cameraCount(instance.cameraCount),
  'connector_count': ?SiteRead._write_connectorCount(instance.connectorCount),
  'created_at': ?SiteRead._write_createdAt(instance.createdAt),
  'updated_at': ?SiteRead._write_updatedAt(instance.updatedAt),
};
