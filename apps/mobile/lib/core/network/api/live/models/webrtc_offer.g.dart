// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webrtc_offer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WebrtcOffer _$WebrtcOfferFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['sdp'],
    disallowNullValues: const ['sdp', 'stream'],
  );
  return WebrtcOffer(
    sdp: json['sdp'] as String,
    stream: WebrtcOffer._presentValue(json, 'stream') == null
        ? ViewStream.sub
        : WebrtcOffer._read_stream(
            WebrtcOffer._presentValue(json, 'stream') as Object,
          ),
    additionalProperties:
        WebrtcOffer._extras(json, 'additionalProperties') == null
        ? const {}
        : WebrtcOffer._readExtras(
            WebrtcOffer._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$WebrtcOfferToJson(WebrtcOffer instance) =>
    <String, dynamic>{
      'sdp': instance.sdp,
      'stream': ?WebrtcOffer._write_stream(instance.stream),
    };
