// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facets.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Facets _$FacetsFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['kinds', 'labels', 'views', 'zones', 'lines', 'people', 'clusters'],
    disallowNullValues: const ['kinds', 'labels', 'views', 'zones', 'lines', 'people', 'clusters'],
  );
  return Facets(
    kinds: (json['kinds'] as List<dynamic>).map((e) => e as String).toList(),
    labels: (json['labels'] as List<dynamic>).map((e) => e as String).toList(),
    views: (json['views'] as List<dynamic>)
        .map((e) => ViewFacet.fromJson(e as Map<String, dynamic>))
        .toList(),
    zones: (json['zones'] as List<dynamic>)
        .map((e) => ZoneFacet.fromJson(e as Map<String, dynamic>))
        .toList(),
    lines: (json['lines'] as List<dynamic>)
        .map((e) => LineFacet.fromJson(e as Map<String, dynamic>))
        .toList(),
    people: (json['people'] as List<dynamic>)
        .map((e) => PersonFacet.fromJson(e as Map<String, dynamic>))
        .toList(),
    clusters: (json['clusters'] as List<dynamic>)
        .map((e) => ClusterFacet.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties: Facets._extras(json, 'additionalProperties') == null
        ? const {}
        : Facets._readExtras(Facets._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$FacetsToJson(Facets instance) => <String, dynamic>{
  'kinds': instance.kinds,
  'labels': instance.labels,
  'views': instance.views.map((e) => e.toJson()).toList(),
  'zones': instance.zones.map((e) => e.toJson()).toList(),
  'lines': instance.lines.map((e) => e.toJson()).toList(),
  'people': instance.people.map((e) => e.toJson()).toList(),
  'clusters': instance.clusters.map((e) => e.toJson()).toList(),
};
