// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webrtc_answer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WebrtcAnswer _$WebrtcAnswerFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['sdp', 'stream'],
    disallowNullValues: const ['type', 'sdp', 'stream'],
  );
  return WebrtcAnswer(
    type: WebrtcAnswer._presentValue(json, 'type') == null
        ? "answer"
        : WebrtcAnswer._read_type(WebrtcAnswer._presentValue(json, 'type') as Object),
    sdp: json['sdp'] as String,
    stream: WebrtcAnswer._read_stream(json['stream']),
    additionalProperties: WebrtcAnswer._extras(json, 'additionalProperties') == null
        ? const {}
        : WebrtcAnswer._readExtras(WebrtcAnswer._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$WebrtcAnswerToJson(WebrtcAnswer instance) => <String, dynamic>{
  'type': ?WebrtcAnswer._write_type(instance.type),
  'sdp': instance.sdp,
  'stream': ?WebrtcAnswer._write_stream(instance.stream),
};
