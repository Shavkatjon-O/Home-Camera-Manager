// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_options_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageOptionsRead _$ImageOptionsReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'levels',
      'ir_cut_filter_modes',
      'wdr_modes',
      'wdr_level',
      'backlight_modes',
      'backlight_level',
    ],
    disallowNullValues: const ['levels', 'ir_cut_filter_modes', 'wdr_modes', 'backlight_modes'],
  );
  return ImageOptionsRead(
    levels: (json['levels'] as Map<String, dynamic>).map(
      (k, e) => MapEntry(k, RangeRead.fromJson(e as Map<String, dynamic>)),
    ),
    irCutFilterModes: (json['ir_cut_filter_modes'] as List<dynamic>)
        .map((e) => e as String)
        .toList(),
    wdrModes: (json['wdr_modes'] as List<dynamic>).map((e) => e as String).toList(),
    wdrLevel: json['wdr_level'] == null
        ? null
        : RangeRead.fromJson(json['wdr_level'] as Map<String, dynamic>),
    backlightModes: (json['backlight_modes'] as List<dynamic>).map((e) => e as String).toList(),
    backlightLevel: json['backlight_level'] == null
        ? null
        : RangeRead.fromJson(json['backlight_level'] as Map<String, dynamic>),
    additionalProperties: ImageOptionsRead._extras(json, 'additionalProperties') == null
        ? const {}
        : ImageOptionsRead._readExtras(ImageOptionsRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$ImageOptionsReadToJson(ImageOptionsRead instance) => <String, dynamic>{
  'levels': instance.levels.map((k, e) => MapEntry(k, e.toJson())),
  'ir_cut_filter_modes': instance.irCutFilterModes,
  'wdr_modes': instance.wdrModes,
  'wdr_level': instance.wdrLevel?.toJson(),
  'backlight_modes': instance.backlightModes,
  'backlight_level': instance.backlightLevel?.toJson(),
};
