// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organisation_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrganisationUpdate _$OrganisationUpdateFromJson(Map<String, dynamic> json) => OrganisationUpdate(
  name: json['name'] as String?,
  facesEnabled: json['faces_enabled'] as bool?,
  facesConsent: json['faces_consent'] as bool?,
  consentVersion: json['consent_version'] as String?,
  additionalProperties: OrganisationUpdate._extras(json, 'additionalProperties') == null
      ? const {}
      : OrganisationUpdate._readExtras(OrganisationUpdate._extras(json, 'additionalProperties')),
);

Map<String, dynamic> _$OrganisationUpdateToJson(OrganisationUpdate instance) => <String, dynamic>{
  'name': ?instance.name,
  'faces_enabled': ?instance.facesEnabled,
  'faces_consent': ?instance.facesConsent,
  'consent_version': ?instance.consentVersion,
};
