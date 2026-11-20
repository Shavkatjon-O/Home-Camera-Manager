// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cluster_name.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClusterName _$ClusterNameFromJson(Map<String, dynamic> json) {
  $checkKeys(json, allowedKeys: const ['person', 'name', 'color']);
  return ClusterName(
    person: json['person'] as String?,
    name: json['name'] as String?,
    color: json['color'] as String?,
  );
}

Map<String, dynamic> _$ClusterNameToJson(ClusterName instance) =>
    <String, dynamic>{
      'person': ?instance.person,
      'name': ?instance.name,
      'color': ?instance.color,
    };
