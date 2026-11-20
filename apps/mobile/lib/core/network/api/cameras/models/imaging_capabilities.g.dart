// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'imaging_capabilities.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImagingCapabilities _$ImagingCapabilitiesFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    disallowNullValues: const ['settings', 'encoders', 'motion'],
  );
  return ImagingCapabilities(
    settings: ImagingCapabilities._presentValue(json, 'settings') == null
        ? const []
        : ImagingCapabilities._read_settings(
            ImagingCapabilities._presentValue(json, 'settings') as Object,
          ),
    encoders: ImagingCapabilities._presentValue(json, 'encoders') == null
        ? false
        : ImagingCapabilities._read_encoders(
            ImagingCapabilities._presentValue(json, 'encoders') as Object,
          ),
    motion: ImagingCapabilities._presentValue(json, 'motion') == null
        ? false
        : ImagingCapabilities._read_motion(
            ImagingCapabilities._presentValue(json, 'motion') as Object,
          ),
    additionalProperties:
        ImagingCapabilities._extras(json, 'additionalProperties') == null
        ? const {}
        : ImagingCapabilities._readExtras(
            ImagingCapabilities._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$ImagingCapabilitiesToJson(
  ImagingCapabilities instance,
) => <String, dynamic>{
  'settings': ?ImagingCapabilities._write_settings(instance.settings),
  'encoders': ?ImagingCapabilities._write_encoders(instance.encoders),
  'motion': ?ImagingCapabilities._write_motion(instance.motion),
};
