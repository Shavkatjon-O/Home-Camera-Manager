// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ice_server_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IceServerList _$IceServerListFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['ice_servers'], disallowNullValues: const ['ice_servers']);
  return IceServerList(
    iceServers: (json['ice_servers'] as List<dynamic>)
        .map((e) => IceServer.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties: IceServerList._extras(json, 'additionalProperties') == null
        ? const {}
        : IceServerList._readExtras(IceServerList._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$IceServerListToJson(IceServerList instance) => <String, dynamic>{
  'ice_servers': instance.iceServers.map((e) => e.toJson()).toList(),
};
