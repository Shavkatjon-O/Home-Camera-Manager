// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ice_server.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IceServer _$IceServerFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['urls'], disallowNullValues: const ['urls']);
  return IceServer(
    urls: (json['urls'] as List<dynamic>).map((e) => e as String).toList(),
    username: json['username'] as String?,
    credential: json['credential'] as String?,
    additionalProperties: IceServer._extras(json, 'additionalProperties') == null
        ? const {}
        : IceServer._readExtras(IceServer._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$IceServerToJson(IceServer instance) => <String, dynamic>{
  'urls': instance.urls,
  'username': ?instance.username,
  'credential': ?instance.credential,
};
