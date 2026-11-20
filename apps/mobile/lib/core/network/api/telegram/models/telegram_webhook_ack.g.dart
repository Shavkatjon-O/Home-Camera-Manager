// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telegram_webhook_ack.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TelegramWebhookAck _$TelegramWebhookAckFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['ok', 'result'],
    disallowNullValues: const ['ok', 'result'],
  );
  return TelegramWebhookAck(
    ok: json['ok'] as bool,
    result: json['result'] as String,
    additionalProperties: TelegramWebhookAck._extras(json, 'additionalProperties') == null
        ? const {}
        : TelegramWebhookAck._readExtras(TelegramWebhookAck._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$TelegramWebhookAckToJson(TelegramWebhookAck instance) => <String, dynamic>{
  'ok': instance.ok,
  'result': instance.result,
};
