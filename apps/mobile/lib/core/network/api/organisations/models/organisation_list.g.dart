// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organisation_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrganisationList _$OrganisationListFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['items'],
    disallowNullValues: const ['items'],
  );
  return OrganisationList(
    items: (json['items'] as List<dynamic>)
        .map((e) => OrganisationRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties:
        OrganisationList._extras(json, 'additionalProperties') == null
        ? const {}
        : OrganisationList._readExtras(
            OrganisationList._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$OrganisationListToJson(OrganisationList instance) =>
    <String, dynamic>{'items': instance.items.map((e) => e.toJson()).toList()};
