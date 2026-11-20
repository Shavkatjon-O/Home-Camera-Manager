// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_rejection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhotoRejection _$PhotoRejectionFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['name', 'reason'],
    disallowNullValues: const ['name', 'reason'],
  );
  return PhotoRejection(
    name: json['name'] as String,
    reason: json['reason'] as String,
    additionalProperties:
        PhotoRejection._extras(json, 'additionalProperties') == null
        ? const {}
        : PhotoRejection._readExtras(
            PhotoRejection._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$PhotoRejectionToJson(PhotoRejection instance) =>
    <String, dynamic>{'name': instance.name, 'reason': instance.reason};
