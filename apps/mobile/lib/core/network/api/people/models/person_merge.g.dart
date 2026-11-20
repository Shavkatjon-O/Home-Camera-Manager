// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_merge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersonMerge _$PersonMergeFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const ['into'],
    requiredKeys: const ['into'],
    disallowNullValues: const ['into'],
  );
  return PersonMerge(into: json['into'] as String);
}

Map<String, dynamic> _$PersonMergeToJson(PersonMerge instance) => <String, dynamic>{
  'into': instance.into,
};
