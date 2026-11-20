// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionUser _$SessionUserFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['uuid', 'username'],
    disallowNullValues: const ['uuid', 'username'],
  );
  return SessionUser(
    uuid: json['uuid'] as String,
    username: json['username'] as String,
    additionalProperties:
        SessionUser._extras(json, 'additionalProperties') == null
        ? const {}
        : SessionUser._readExtras(
            SessionUser._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$SessionUserToJson(SessionUser instance) =>
    <String, dynamic>{'uuid': instance.uuid, 'username': instance.username};
