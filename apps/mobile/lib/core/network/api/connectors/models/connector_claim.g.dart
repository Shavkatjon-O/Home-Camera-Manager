// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connector_claim.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConnectorClaim _$ConnectorClaimFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['user_code'],
    disallowNullValues: const ['user_code'],
  );
  return ConnectorClaim(
    userCode: json['user_code'] as String,
    name: json['name'] as String?,
    additionalProperties:
        ConnectorClaim._extras(json, 'additionalProperties') == null
        ? const {}
        : ConnectorClaim._readExtras(
            ConnectorClaim._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$ConnectorClaimToJson(ConnectorClaim instance) =>
    <String, dynamic>{'user_code': instance.userCode, 'name': ?instance.name};
