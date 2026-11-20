// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_upload_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhotoUploadResult _$PhotoUploadResultFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['person', 'added', 'rejected'],
    disallowNullValues: const ['person', 'added', 'rejected'],
  );
  return PhotoUploadResult(
    person: PersonRead.fromJson(json['person'] as Map<String, dynamic>),
    added: (json['added'] as List<dynamic>)
        .map((e) => SampleRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    rejected: (json['rejected'] as List<dynamic>)
        .map((e) => PhotoRejection.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties: PhotoUploadResult._extras(json, 'additionalProperties') == null
        ? const {}
        : PhotoUploadResult._readExtras(PhotoUploadResult._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$PhotoUploadResultToJson(PhotoUploadResult instance) => <String, dynamic>{
  'person': instance.person.toJson(),
  'added': instance.added.map((e) => e.toJson()).toList(),
  'rejected': instance.rejected.map((e) => e.toJson()).toList(),
};
