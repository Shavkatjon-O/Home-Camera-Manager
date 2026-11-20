// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemberRead _$MemberReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'uuid',
      'user',
      'email',
      'name',
      'role',
      'all_sites',
      'sites',
      'joined_at',
      'you',
    ],
    disallowNullValues: const ['uuid', 'user', 'role', 'all_sites', 'sites', 'joined_at', 'you'],
  );
  return MemberRead(
    uuid: json['uuid'] as String,
    user: json['user'] as String,
    email: json['email'] as String?,
    name: json['name'] as String?,
    role: MemberRead._read_role(json['role']),
    allSites: json['all_sites'] as bool,
    sites: (json['sites'] as List<dynamic>).map((e) => e as String).toList(),
    joinedAt: MemberRead._read_joinedAt(json['joined_at']),
    you: json['you'] as bool,
    additionalProperties: MemberRead._extras(json, 'additionalProperties') == null
        ? const {}
        : MemberRead._readExtras(MemberRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$MemberReadToJson(MemberRead instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'user': instance.user,
  'email': instance.email,
  'name': instance.name,
  'role': ?MemberRead._write_role(instance.role),
  'all_sites': instance.allSites,
  'sites': instance.sites,
  'joined_at': ?MemberRead._write_joinedAt(instance.joinedAt),
  'you': instance.you,
};
