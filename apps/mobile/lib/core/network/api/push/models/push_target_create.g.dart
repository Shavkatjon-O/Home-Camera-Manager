// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_target_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushTargetCreate _$PushTargetCreateFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['provider', 'token'],
    disallowNullValues: const ['provider', 'token'],
  );
  return PushTargetCreate(
    provider: PushTargetCreate._read_provider(json['provider']),
    token: json['token'] as String,
    additionalProperties:
        PushTargetCreate._extras(json, 'additionalProperties') == null
        ? const {}
        : PushTargetCreate._readExtras(
            PushTargetCreate._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$PushTargetCreateToJson(PushTargetCreate instance) =>
    <String, dynamic>{
      'provider': ?PushTargetCreate._write_provider(instance.provider),
      'token': instance.token,
    };
