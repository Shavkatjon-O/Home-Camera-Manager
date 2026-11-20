// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telegram_chat_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TelegramChatList _$TelegramChatListFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['items', 'available'],
    disallowNullValues: const ['items', 'available'],
  );
  return TelegramChatList(
    items: (json['items'] as List<dynamic>)
        .map((e) => TelegramChatRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    available: json['available'] as bool,
    additionalProperties:
        TelegramChatList._extras(json, 'additionalProperties') == null
        ? const {}
        : TelegramChatList._readExtras(
            TelegramChatList._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$TelegramChatListToJson(TelegramChatList instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'available': instance.available,
    };
