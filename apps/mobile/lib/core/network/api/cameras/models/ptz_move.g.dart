// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ptz_move.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PtzMove _$PtzMoveFromJson(Map<String, dynamic> json) {
  $checkKeys(json, disallowNullValues: const ['pan', 'tilt', 'zoom']);
  return PtzMove(
    pan: PtzMove._presentValue(json, 'pan') == null
        ? 0.0
        : PtzMove._read_pan(PtzMove._presentValue(json, 'pan') as Object),
    tilt: PtzMove._presentValue(json, 'tilt') == null
        ? 0.0
        : PtzMove._read_tilt(PtzMove._presentValue(json, 'tilt') as Object),
    zoom: PtzMove._presentValue(json, 'zoom') == null
        ? 0.0
        : PtzMove._read_zoom(PtzMove._presentValue(json, 'zoom') as Object),
    additionalProperties: PtzMove._extras(json, 'additionalProperties') == null
        ? const {}
        : PtzMove._readExtras(PtzMove._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$PtzMoveToJson(PtzMove instance) => <String, dynamic>{
  'pan': ?PtzMove._write_pan(instance.pan),
  'tilt': ?PtzMove._write_tilt(instance.tilt),
  'zoom': ?PtzMove._write_zoom(instance.zoom),
};
