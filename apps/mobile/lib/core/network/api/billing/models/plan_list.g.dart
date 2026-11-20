// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlanList _$PlanListFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['items'], disallowNullValues: const ['items']);
  return PlanList(
    items: (json['items'] as List<dynamic>)
        .map((e) => PlanRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties: PlanList._extras(json, 'additionalProperties') == null
        ? const {}
        : PlanList._readExtras(PlanList._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$PlanListToJson(PlanList instance) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
};
