// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cluster_facet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClusterFacet _$ClusterFacetFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['uuid', 'label'],
    disallowNullValues: const ['uuid', 'label'],
  );
  return ClusterFacet(
    uuid: json['uuid'] as String,
    label: json['label'] as String,
    additionalProperties:
        ClusterFacet._extras(json, 'additionalProperties') == null
        ? const {}
        : ClusterFacet._readExtras(
            ClusterFacet._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$ClusterFacetToJson(ClusterFacet instance) =>
    <String, dynamic>{'uuid': instance.uuid, 'label': instance.label};
