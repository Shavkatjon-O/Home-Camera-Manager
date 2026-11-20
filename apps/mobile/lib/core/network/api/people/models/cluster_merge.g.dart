// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cluster_merge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClusterMerge _$ClusterMergeFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    allowedKeys: const ['into'],
    requiredKeys: const ['into'],
    disallowNullValues: const ['into'],
  );
  return ClusterMerge(into: json['into'] as String);
}

Map<String, dynamic> _$ClusterMergeToJson(ClusterMerge instance) =>
    <String, dynamic>{'into': instance.into};
