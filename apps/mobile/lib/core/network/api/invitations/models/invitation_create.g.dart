// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvitationCreate _$InvitationCreateFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['email'],
    disallowNullValues: const ['email', 'role', 'all_sites', 'sites'],
  );
  return InvitationCreate(
    email: json['email'] as String,
    role: InvitationCreate._presentValue(json, 'role') == null
        ? Role.viewer
        : InvitationCreate._read_role(InvitationCreate._presentValue(json, 'role') as Object),
    allSites: InvitationCreate._presentValue(json, 'all_sites') == null
        ? true
        : InvitationCreate._read_allSites(
            InvitationCreate._presentValue(json, 'all_sites') as Object,
          ),
    sites: (json['sites'] as List<dynamic>?)?.map((e) => e as String).toList(),
    additionalProperties: InvitationCreate._extras(json, 'additionalProperties') == null
        ? const {}
        : InvitationCreate._readExtras(InvitationCreate._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$InvitationCreateToJson(InvitationCreate instance) => <String, dynamic>{
  'email': instance.email,
  'role': ?InvitationCreate._write_role(instance.role),
  'all_sites': ?InvitationCreate._write_allSites(instance.allSites),
  'sites': ?instance.sites,
};
