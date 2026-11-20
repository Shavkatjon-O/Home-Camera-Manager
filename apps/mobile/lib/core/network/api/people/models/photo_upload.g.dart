// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_upload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhotoUpload _$PhotoUploadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const ['name', 'data'],
    requiredKeys: const ['data'],
    disallowNullValues: const ['name', 'data'],
  );
  return PhotoUpload(
    name: PhotoUpload._presentValue(json, 'name') == null
        ? ""
        : PhotoUpload._read_name(PhotoUpload._presentValue(json, 'name') as Object),
    data: json['data'] as String,
  );
}

Map<String, dynamic> _$PhotoUploadToJson(PhotoUpload instance) => <String, dynamic>{
  'name': ?PhotoUpload._write_name(instance.name),
  'data': instance.data,
};
