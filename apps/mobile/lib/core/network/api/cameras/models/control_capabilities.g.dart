// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'control_capabilities.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ControlCapabilities _$ControlCapabilitiesFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    disallowNullValues: const [
      'ptz',
      'zoom',
      'presets',
      'home',
      'light',
      'siren',
    ],
  );
  return ControlCapabilities(
    ptz: ControlCapabilities._presentValue(json, 'ptz') == null
        ? false
        : ControlCapabilities._read_ptz(
            ControlCapabilities._presentValue(json, 'ptz') as Object,
          ),
    zoom: ControlCapabilities._presentValue(json, 'zoom') == null
        ? false
        : ControlCapabilities._read_zoom(
            ControlCapabilities._presentValue(json, 'zoom') as Object,
          ),
    presets: ControlCapabilities._presentValue(json, 'presets') == null
        ? false
        : ControlCapabilities._read_presets(
            ControlCapabilities._presentValue(json, 'presets') as Object,
          ),
    home: ControlCapabilities._presentValue(json, 'home') == null
        ? false
        : ControlCapabilities._read_home(
            ControlCapabilities._presentValue(json, 'home') as Object,
          ),
    light: ControlCapabilities._presentValue(json, 'light') == null
        ? false
        : ControlCapabilities._read_light(
            ControlCapabilities._presentValue(json, 'light') as Object,
          ),
    siren: ControlCapabilities._presentValue(json, 'siren') == null
        ? false
        : ControlCapabilities._read_siren(
            ControlCapabilities._presentValue(json, 'siren') as Object,
          ),
    additionalProperties:
        ControlCapabilities._extras(json, 'additionalProperties') == null
        ? const {}
        : ControlCapabilities._readExtras(
            ControlCapabilities._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$ControlCapabilitiesToJson(
  ControlCapabilities instance,
) => <String, dynamic>{
  'ptz': ?ControlCapabilities._write_ptz(instance.ptz),
  'zoom': ?ControlCapabilities._write_zoom(instance.zoom),
  'presets': ?ControlCapabilities._write_presets(instance.presets),
  'home': ?ControlCapabilities._write_home(instance.home),
  'light': ?ControlCapabilities._write_light(instance.light),
  'siren': ?ControlCapabilities._write_siren(instance.siren),
};
