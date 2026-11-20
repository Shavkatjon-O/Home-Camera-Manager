// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvitationRead _$InvitationReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'uuid',
      'email',
      'role',
      'all_sites',
      'sites',
      'status',
      'expires_at',
      'invited_by',
      'created_at',
      'accepted_at',
    ],
    disallowNullValues: const [
      'uuid',
      'email',
      'role',
      'all_sites',
      'sites',
      'status',
      'expires_at',
      'created_at',
    ],
  );
  return InvitationRead(
    uuid: json['uuid'] as String,
    email: json['email'] as String,
    role: InvitationRead._read_role(json['role']),
    allSites: json['all_sites'] as bool,
    sites: (json['sites'] as List<dynamic>).map((e) => e as String).toList(),
    status: InvitationRead._read_status(json['status']),
    expiresAt: InvitationRead._read_expiresAt(json['expires_at']),
    invitedBy: json['invited_by'] as String?,
    createdAt: InvitationRead._read_createdAt(json['created_at']),
    acceptedAt: InvitationRead._read_acceptedAt(json['accepted_at']),
    additionalProperties: InvitationRead._extras(json, 'additionalProperties') == null
        ? const {}
        : InvitationRead._readExtras(InvitationRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$InvitationReadToJson(InvitationRead instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'email': instance.email,
  'role': ?InvitationRead._write_role(instance.role),
  'all_sites': instance.allSites,
  'sites': instance.sites,
  'status': ?InvitationRead._write_status(instance.status),
  'expires_at': ?InvitationRead._write_expiresAt(instance.expiresAt),
  'invited_by': instance.invitedBy,
  'created_at': ?InvitationRead._write_createdAt(instance.createdAt),
  'accepted_at': InvitationRead._write_acceptedAt(instance.acceptedAt),
};
