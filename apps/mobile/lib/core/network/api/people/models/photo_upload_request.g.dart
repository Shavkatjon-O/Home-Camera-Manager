// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_upload_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhotoUploadRequest _$PhotoUploadRequestFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const ['photos'],
    requiredKeys: const ['photos'],
    disallowNullValues: const ['photos'],
  );
  return PhotoUploadRequest(
    photos: (json['photos'] as List<dynamic>)
        .map((e) => PhotoUpload.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$PhotoUploadRequestToJson(PhotoUploadRequest instance) =>
    <String, dynamic>{
      'photos': instance.photos.map((e) => e.toJson()).toList(),
    };
