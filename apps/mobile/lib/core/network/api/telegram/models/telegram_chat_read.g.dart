// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telegram_chat_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TelegramChatRead _$TelegramChatReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['uuid', 'chat_type', 'title', 'enabled', 'blocked', 'created_at'],
    disallowNullValues: const ['uuid', 'chat_type', 'enabled', 'blocked', 'created_at'],
  );
  return TelegramChatRead(
    uuid: json['uuid'] as String,
    chatType: json['chat_type'] as String,
    title: json['title'] as String?,
    enabled: json['enabled'] as bool,
    blocked: json['blocked'] as bool,
    createdAt: TelegramChatRead._read_createdAt(json['created_at']),
    additionalProperties: TelegramChatRead._extras(json, 'additionalProperties') == null
        ? const {}
        : TelegramChatRead._readExtras(TelegramChatRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$TelegramChatReadToJson(TelegramChatRead instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'chat_type': instance.chatType,
  'title': instance.title,
  'enabled': instance.enabled,
  'blocked': instance.blocked,
  'created_at': ?TelegramChatRead._write_createdAt(instance.createdAt),
};
