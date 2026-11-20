// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_objects.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LiveObjects _$LiveObjectsFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['view', 'at', 'objects'],
    disallowNullValues: const ['view', 'objects'],
  );
  return LiveObjects(
    view: json['view'] as String,
    at: json['at'] as num?,
    objects: (json['objects'] as List<dynamic>)
        .map((e) => LiveObject.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties: LiveObjects._extras(json, 'additionalProperties') == null
        ? const {}
        : LiveObjects._readExtras(LiveObjects._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$LiveObjectsToJson(LiveObjects instance) => <String, dynamic>{
  'view': instance.view,
  'at': instance.at,
  'objects': instance.objects.map((e) => e.toJson()).toList(),
};
