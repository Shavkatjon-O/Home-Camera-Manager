// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organisation_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrganisationRead _$OrganisationReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'uuid',
      'name',
      'role',
      'faces_enabled',
      'faces_consent_at',
      'site_count',
      'member_count',
      'sites',
      'created_at',
    ],
    disallowNullValues: const [
      'uuid',
      'name',
      'role',
      'faces_enabled',
      'site_count',
      'member_count',
      'sites',
      'created_at',
    ],
  );
  return OrganisationRead(
    uuid: json['uuid'] as String,
    name: json['name'] as String,
    role: OrganisationRead._read_role(json['role']),
    facesEnabled: json['faces_enabled'] as bool,
    facesConsentAt: OrganisationRead._read_facesConsentAt(
      json['faces_consent_at'],
    ),
    siteCount: OrganisationRead._read_siteCount(json['site_count']),
    memberCount: OrganisationRead._read_memberCount(json['member_count']),
    sites: (json['sites'] as List<dynamic>)
        .map((e) => SiteRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    createdAt: OrganisationRead._read_createdAt(json['created_at']),
    additionalProperties:
        OrganisationRead._extras(json, 'additionalProperties') == null
        ? const {}
        : OrganisationRead._readExtras(
            OrganisationRead._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$OrganisationReadToJson(
  OrganisationRead instance,
) => <String, dynamic>{
  'uuid': instance.uuid,
  'name': instance.name,
  'role': ?OrganisationRead._write_role(instance.role),
  'faces_enabled': instance.facesEnabled,
  'faces_consent_at': OrganisationRead._write_facesConsentAt(
    instance.facesConsentAt,
  ),
  'site_count': ?OrganisationRead._write_siteCount(instance.siteCount),
  'member_count': ?OrganisationRead._write_memberCount(instance.memberCount),
  'sites': instance.sites.map((e) => e.toJson()).toList(),
  'created_at': ?OrganisationRead._write_createdAt(instance.createdAt),
};
