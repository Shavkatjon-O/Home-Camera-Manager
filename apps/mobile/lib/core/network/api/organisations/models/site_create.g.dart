// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SiteCreate _$SiteCreateFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['name'],
    disallowNullValues: const ['name', 'kind', 'timezone'],
  );
  return SiteCreate(
    name: json['name'] as String,
    kind: SiteCreate._presentValue(json, 'kind') == null
        ? SiteKind.home
        : SiteCreate._read_kind(SiteCreate._presentValue(json, 'kind') as Object),
    timezone: SiteCreate._presentValue(json, 'timezone') == null
        ? "UTC"
        : SiteCreate._read_timezone(SiteCreate._presentValue(json, 'timezone') as Object),
    additionalProperties: SiteCreate._extras(json, 'additionalProperties') == null
        ? const {}
        : SiteCreate._readExtras(SiteCreate._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$SiteCreateToJson(SiteCreate instance) => <String, dynamic>{
  'name': instance.name,
  'kind': ?SiteCreate._write_kind(instance.kind),
  'timezone': ?SiteCreate._write_timezone(instance.timezone),
};
