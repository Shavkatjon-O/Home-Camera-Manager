// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CameraList _$CameraListFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['items', 'total', 'page', 'page_size'],
    disallowNullValues: const ['items', 'total', 'page', 'page_size'],
  );
  return CameraList(
    items: (json['items'] as List<dynamic>)
        .map((e) => CameraRead.fromJson(e as Map<String, dynamic>))
        .toList(),
    total: CameraList._read_total(json['total']),
    page: CameraList._read_page(json['page']),
    pageSize: CameraList._read_pageSize(json['page_size']),
    additionalProperties:
        CameraList._extras(json, 'additionalProperties') == null
        ? const {}
        : CameraList._readExtras(
            CameraList._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$CameraListToJson(CameraList instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'total': ?CameraList._write_total(instance.total),
      'page': ?CameraList._write_page(instance.page),
      'page_size': ?CameraList._write_pageSize(instance.pageSize),
    };
