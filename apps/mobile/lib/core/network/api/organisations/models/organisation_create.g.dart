// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organisation_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrganisationCreate _$OrganisationCreateFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['name'],
    disallowNullValues: const ['name'],
  );
  return OrganisationCreate(
    name: json['name'] as String,
    site: json['site'] == null
        ? null
        : SiteCreate.fromJson(json['site'] as Map<String, dynamic>),
    additionalProperties:
        OrganisationCreate._extras(json, 'additionalProperties') == null
        ? const {}
        : OrganisationCreate._readExtras(
            OrganisationCreate._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$OrganisationCreateToJson(OrganisationCreate instance) =>
    <String, dynamic>{'name': instance.name, 'site': ?instance.site?.toJson()};
