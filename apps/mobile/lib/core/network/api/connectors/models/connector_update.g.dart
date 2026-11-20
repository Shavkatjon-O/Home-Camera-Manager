// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connector_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConnectorUpdate _$ConnectorUpdateFromJson(Map<String, dynamic> json) => ConnectorUpdate(
  name: json['name'] as String?,
  address: json['address'] as String?,
  additionalProperties: ConnectorUpdate._extras(json, 'additionalProperties') == null
      ? const {}
      : ConnectorUpdate._readExtras(ConnectorUpdate._extras(json, 'additionalProperties')),
);

Map<String, dynamic> _$ConnectorUpdateToJson(ConnectorUpdate instance) => <String, dynamic>{
  'name': ?instance.name,
  'address': ?instance.address,
};
