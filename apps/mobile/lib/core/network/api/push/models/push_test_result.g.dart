// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_test_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushTestResult _$PushTestResultFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['sent', 'failed'],
    disallowNullValues: const ['sent', 'failed'],
  );
  return PushTestResult(
    sent: PushTestResult._read_sent(json['sent']),
    failed: PushTestResult._read_failed(json['failed']),
    additionalProperties:
        PushTestResult._extras(json, 'additionalProperties') == null
        ? const {}
        : PushTestResult._readExtras(
            PushTestResult._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$PushTestResultToJson(PushTestResult instance) =>
    <String, dynamic>{
      'sent': ?PushTestResult._write_sent(instance.sent),
      'failed': ?PushTestResult._write_failed(instance.failed),
    };
