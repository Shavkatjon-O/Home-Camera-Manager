// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_providers.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushProviders _$PushProvidersFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['fcm', 'ntfy', 'ntfy_url'],
    disallowNullValues: const ['fcm', 'ntfy'],
  );
  return PushProviders(
    fcm: json['fcm'] as bool,
    ntfy: json['ntfy'] as bool,
    ntfyUrl: json['ntfy_url'] as String?,
    additionalProperties: PushProviders._extras(json, 'additionalProperties') == null
        ? const {}
        : PushProviders._readExtras(PushProviders._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$PushProvidersToJson(PushProviders instance) => <String, dynamic>{
  'fcm': instance.fcm,
  'ntfy': instance.ntfy,
  'ntfy_url': instance.ntfyUrl,
};
