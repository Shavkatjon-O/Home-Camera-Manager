// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersonCreate _$PersonCreateFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const ['name', 'notes', 'color'],
    requiredKeys: const ['name'],
    disallowNullValues: const ['name'],
  );
  return PersonCreate(
    name: json['name'] as String,
    notes: json['notes'] as String?,
    color: json['color'] as String?,
  );
}

Map<String, dynamic> _$PersonCreateToJson(PersonCreate instance) => <String, dynamic>{
  'name': instance.name,
  'notes': ?instance.notes,
  'color': ?instance.color,
};
