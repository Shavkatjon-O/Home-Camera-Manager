// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemberUpdate _$MemberUpdateFromJson(Map<String, dynamic> json) => MemberUpdate(
  role: MemberUpdate._read_role(json['role']),
  allSites: json['all_sites'] as bool?,
  sites: (json['sites'] as List<dynamic>?)?.map((e) => e as String).toList(),
  additionalProperties:
      MemberUpdate._extras(json, 'additionalProperties') == null
      ? const {}
      : MemberUpdate._readExtras(
          MemberUpdate._extras(json, 'additionalProperties'),
        ),
);

Map<String, dynamic> _$MemberUpdateToJson(MemberUpdate instance) =>
    <String, dynamic>{
      'role': ?MemberUpdate._write_role(instance.role),
      'all_sites': ?instance.allSites,
      'sites': ?instance.sites,
    };
