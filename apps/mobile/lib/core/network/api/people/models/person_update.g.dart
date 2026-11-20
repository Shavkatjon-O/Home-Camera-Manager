// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersonUpdate _$PersonUpdateFromJson(Map<String, dynamic> json) {
  $checkKeys(json, allowedKeys: const ['name', 'notes', 'color']);
  return PersonUpdate(
    name: json['name'] as String?,
    notes: json['notes'] as String?,
    color: json['color'] as String?,
  );
}

Map<String, dynamic> _$PersonUpdateToJson(PersonUpdate instance) => <String, dynamic>{
  'name': ?instance.name,
  'notes': ?instance.notes,
  'color': ?instance.color,
};
