// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_capabilities.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaybackCapabilities _$PlaybackCapabilitiesFromJson(Map<String, dynamic> json) {
  $checkKeys(json, disallowNullValues: const ['recordings', 'replay']);
  return PlaybackCapabilities(
    recordings: PlaybackCapabilities._presentValue(json, 'recordings') == null
        ? false
        : PlaybackCapabilities._read_recordings(
            PlaybackCapabilities._presentValue(json, 'recordings') as Object,
          ),
    replay: PlaybackCapabilities._presentValue(json, 'replay') == null
        ? false
        : PlaybackCapabilities._read_replay(
            PlaybackCapabilities._presentValue(json, 'replay') as Object,
          ),
    additionalProperties:
        PlaybackCapabilities._extras(json, 'additionalProperties') == null
        ? const {}
        : PlaybackCapabilities._readExtras(
            PlaybackCapabilities._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$PlaybackCapabilitiesToJson(
  PlaybackCapabilities instance,
) => <String, dynamic>{
  'recordings': ?PlaybackCapabilities._write_recordings(instance.recordings),
  'replay': ?PlaybackCapabilities._write_replay(instance.replay),
};
