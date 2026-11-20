// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuditRead _$AuditReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'uuid',
      'at',
      'action',
      'actor',
      'organisation',
      'site',
      'target_kind',
      'target_uuid',
      'details',
      'ip',
    ],
    disallowNullValues: const ['uuid', 'at', 'action', 'details'],
  );
  return AuditRead(
    uuid: json['uuid'] as String,
    at: AuditRead._read_at(json['at']),
    action: json['action'] as String,
    actor: json['actor'] as String?,
    organisation: json['organisation'] as String?,
    site: json['site'] as String?,
    targetKind: json['target_kind'] as String?,
    targetUuid: json['target_uuid'] as String?,
    details: json['details'] as Map<String, dynamic>,
    ip: json['ip'] as String?,
    additionalProperties:
        AuditRead._extras(json, 'additionalProperties') == null
        ? const {}
        : AuditRead._readExtras(
            AuditRead._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$AuditReadToJson(AuditRead instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'at': ?AuditRead._write_at(instance.at),
  'action': instance.action,
  'actor': instance.actor,
  'organisation': instance.organisation,
  'site': instance.site,
  'target_kind': instance.targetKind,
  'target_uuid': instance.targetUuid,
  'details': instance.details,
  'ip': instance.ip,
};
