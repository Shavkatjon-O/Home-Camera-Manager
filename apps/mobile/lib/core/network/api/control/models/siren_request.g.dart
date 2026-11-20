// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'siren_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SirenRequest _$SirenRequestFromJson(Map<String, dynamic> json) {
  $checkKeys(json, disallowNullValues: const ['seconds']);
  return SirenRequest(
    seconds: SirenRequest._presentValue(json, 'seconds') == null
        ? 0
        : SirenRequest._read_seconds(SirenRequest._presentValue(json, 'seconds') as Object),
    additionalProperties: SirenRequest._extras(json, 'additionalProperties') == null
        ? const {}
        : SirenRequest._readExtras(SirenRequest._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$SirenRequestToJson(SirenRequest instance) => <String, dynamic>{
  'seconds': ?SirenRequest._write_seconds(instance.seconds),
};
