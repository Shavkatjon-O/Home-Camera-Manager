// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connector_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConnectorList _$ConnectorListFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['items'],
    disallowNullValues: const ['items'],
  );
  return ConnectorList(
    items: (json['items'] as List<dynamic>)
        .map((e) => ConnectorRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties:
        ConnectorList._extras(json, 'additionalProperties') == null
        ? const {}
        : ConnectorList._readExtras(
            ConnectorList._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$ConnectorListToJson(ConnectorList instance) =>
    <String, dynamic>{'items': instance.items.map((e) => e.toJson()).toList()};
