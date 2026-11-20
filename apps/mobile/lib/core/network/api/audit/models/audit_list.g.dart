// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuditList _$AuditListFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['items', 'total', 'page', 'page_size'],
    disallowNullValues: const ['items', 'total', 'page', 'page_size'],
  );
  return AuditList(
    items: (json['items'] as List<dynamic>)
        .map((e) => AuditRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    total: AuditList._read_total(json['total']),
    page: AuditList._read_page(json['page']),
    pageSize: AuditList._read_pageSize(json['page_size']),
    additionalProperties: AuditList._extras(json, 'additionalProperties') == null
        ? const {}
        : AuditList._readExtras(AuditList._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$AuditListToJson(AuditList instance) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'total': ?AuditList._write_total(instance.total),
  'page': ?AuditList._write_page(instance.page),
  'page_size': ?AuditList._write_pageSize(instance.pageSize),
};
