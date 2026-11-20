// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resolution_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResolutionRead _$ResolutionReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['width', 'height'],
    disallowNullValues: const ['width', 'height'],
  );
  return ResolutionRead(
    width: ResolutionRead._read_width(json['width']),
    height: ResolutionRead._read_height(json['height']),
    additionalProperties: ResolutionRead._extras(json, 'additionalProperties') == null
        ? const {}
        : ResolutionRead._readExtras(ResolutionRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$ResolutionReadToJson(ResolutionRead instance) => <String, dynamic>{
  'width': ?ResolutionRead._write_width(instance.width),
  'height': ?ResolutionRead._write_height(instance.height),
};
