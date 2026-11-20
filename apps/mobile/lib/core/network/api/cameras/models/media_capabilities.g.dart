// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_capabilities.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaCapabilities _$MediaCapabilitiesFromJson(Map<String, dynamic> json) {
  $checkKeys(json, disallowNullValues: const ['main', 'sub', 'snapshot', 'audio', 'codecs']);
  return MediaCapabilities(
    main: MediaCapabilities._presentValue(json, 'main') == null
        ? true
        : MediaCapabilities._read_main(MediaCapabilities._presentValue(json, 'main') as Object),
    sub: MediaCapabilities._presentValue(json, 'sub') == null
        ? false
        : MediaCapabilities._read_sub(MediaCapabilities._presentValue(json, 'sub') as Object),
    snapshot: MediaCapabilities._presentValue(json, 'snapshot') == null
        ? false
        : MediaCapabilities._read_snapshot(
            MediaCapabilities._presentValue(json, 'snapshot') as Object,
          ),
    audio: MediaCapabilities._presentValue(json, 'audio') == null
        ? false
        : MediaCapabilities._read_audio(MediaCapabilities._presentValue(json, 'audio') as Object),
    codecs: MediaCapabilities._presentValue(json, 'codecs') == null
        ? const []
        : MediaCapabilities._read_codecs(MediaCapabilities._presentValue(json, 'codecs') as Object),
    additionalProperties: MediaCapabilities._extras(json, 'additionalProperties') == null
        ? const {}
        : MediaCapabilities._readExtras(MediaCapabilities._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$MediaCapabilitiesToJson(MediaCapabilities instance) => <String, dynamic>{
  'main': ?MediaCapabilities._write_main(instance.main),
  'sub': ?MediaCapabilities._write_sub(instance.sub),
  'snapshot': ?MediaCapabilities._write_snapshot(instance.snapshot),
  'audio': ?MediaCapabilities._write_audio(instance.audio),
  'codecs': ?MediaCapabilities._write_codecs(instance.codecs),
};
