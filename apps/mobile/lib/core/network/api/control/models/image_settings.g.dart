// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageSettings _$ImageSettingsFromJson(Map<String, dynamic> json) =>
    ImageSettings(
      brightness: json['brightness'] as num?,
      contrast: json['contrast'] as num?,
      saturation: json['saturation'] as num?,
      sharpness: json['sharpness'] as num?,
      irCutFilter: json['ir_cut_filter'] as String?,
      wdrMode: json['wdr_mode'] as String?,
      wdrLevel: json['wdr_level'] as num?,
      backlightMode: json['backlight_mode'] as String?,
      backlightLevel: json['backlight_level'] as num?,
      additionalProperties:
          ImageSettings._extras(json, 'additionalProperties') == null
          ? const {}
          : ImageSettings._readExtras(
              ImageSettings._extras(json, 'additionalProperties'),
            ),
    );

Map<String, dynamic> _$ImageSettingsToJson(ImageSettings instance) =>
    <String, dynamic>{
      'brightness': ?instance.brightness,
      'contrast': ?instance.contrast,
      'saturation': ?instance.saturation,
      'sharpness': ?instance.sharpness,
      'ir_cut_filter': ?instance.irCutFilter,
      'wdr_mode': ?instance.wdrMode,
      'wdr_level': ?instance.wdrLevel,
      'backlight_mode': ?instance.backlightMode,
      'backlight_level': ?instance.backlightLevel,
    };
