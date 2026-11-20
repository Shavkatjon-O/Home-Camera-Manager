// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'area_reset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AreaReset _$AreaResetFromJson(Map<String, dynamic> json) {
  $checkKeys(json, disallowNullValues: const ['occupancy']);
  return AreaReset(
    occupancy: AreaReset._presentValue(json, 'occupancy') == null
        ? 0
        : AreaReset._read_occupancy(
            AreaReset._presentValue(json, 'occupancy') as Object,
          ),
    additionalProperties:
        AreaReset._extras(json, 'additionalProperties') == null
        ? const {}
        : AreaReset._readExtras(
            AreaReset._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$AreaResetToJson(AreaReset instance) => <String, dynamic>{
  'occupancy': ?AreaReset._write_occupancy(instance.occupancy),
};
