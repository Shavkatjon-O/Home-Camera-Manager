// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telegram_link_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TelegramLinkRead _$TelegramLinkReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['url', 'group_url', 'bot', 'expires_at'],
    disallowNullValues: const ['url', 'group_url', 'bot', 'expires_at'],
  );
  return TelegramLinkRead(
    url: json['url'] as String,
    groupUrl: json['group_url'] as String,
    bot: json['bot'] as String,
    expiresAt: TelegramLinkRead._read_expiresAt(json['expires_at']),
    additionalProperties: TelegramLinkRead._extras(json, 'additionalProperties') == null
        ? const {}
        : TelegramLinkRead._readExtras(TelegramLinkRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$TelegramLinkReadToJson(TelegramLinkRead instance) => <String, dynamic>{
  'url': instance.url,
  'group_url': instance.groupUrl,
  'bot': instance.bot,
  'expires_at': ?TelegramLinkRead._write_expiresAt(instance.expiresAt),
};
