// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation_preview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvitationPreview _$InvitationPreviewFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'organisation',
      'role',
      'invited_by',
      'email',
      'status',
      'expires_at',
    ],
    disallowNullValues: const [
      'organisation',
      'role',
      'email',
      'status',
      'expires_at',
    ],
  );
  return InvitationPreview(
    organisation: json['organisation'] as String,
    role: InvitationPreview._read_role(json['role']),
    invitedBy: json['invited_by'] as String?,
    email: json['email'] as String,
    status: InvitationPreview._read_status(json['status']),
    expiresAt: InvitationPreview._read_expiresAt(json['expires_at']),
    additionalProperties:
        InvitationPreview._extras(json, 'additionalProperties') == null
        ? const {}
        : InvitationPreview._readExtras(
            InvitationPreview._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$InvitationPreviewToJson(InvitationPreview instance) =>
    <String, dynamic>{
      'organisation': instance.organisation,
      'role': ?InvitationPreview._write_role(instance.role),
      'invited_by': instance.invitedBy,
      'email': instance.email,
      'status': ?InvitationPreview._write_status(instance.status),
      'expires_at': ?InvitationPreview._write_expiresAt(instance.expiresAt),
    };
