// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LiveObject _$LiveObjectFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['track', 'label', 'confidence', 'box'],
    disallowNullValues: const ['track', 'label', 'confidence', 'box'],
  );
  return LiveObject(
    track: LiveObject._read_track(json['track']),
    label: json['label'] as String,
    confidence: json['confidence'] as num,
    box: (json['box'] as List<dynamic>).map((e) => e as num).toList(),
    additionalProperties:
        LiveObject._extras(json, 'additionalProperties') == null
        ? const {}
        : LiveObject._readExtras(
            LiveObject._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$LiveObjectToJson(LiveObject instance) =>
    <String, dynamic>{
      'track': ?LiveObject._write_track(instance.track),
      'label': instance.label,
      'confidence': instance.confidence,
      'box': instance.box,
    };
