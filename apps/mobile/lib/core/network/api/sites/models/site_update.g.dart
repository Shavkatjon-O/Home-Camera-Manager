// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SiteUpdate _$SiteUpdateFromJson(Map<String, dynamic> json) => SiteUpdate(
  name: json['name'] as String?,
  kind: SiteUpdate._read_kind(json['kind']),
  timezone: json['timezone'] as String?,
  position: SiteUpdate._read_position(json['position']),
  additionalProperties: SiteUpdate._extras(json, 'additionalProperties') == null
      ? const {}
      : SiteUpdate._readExtras(
          SiteUpdate._extras(json, 'additionalProperties'),
        ),
);

Map<String, dynamic> _$SiteUpdateToJson(SiteUpdate instance) =>
    <String, dynamic>{
      'name': ?instance.name,
      'kind': ?SiteUpdate._write_kind(instance.kind),
      'timezone': ?instance.timezone,
      'position': ?SiteUpdate._write_position(instance.position),
    };
