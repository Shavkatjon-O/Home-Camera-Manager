// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'label_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LabelRead _$LabelReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'adapter',
      'format',
      'confirmed',
      'kind',
      'vendor',
      'model',
      'serial',
      'code',
      'device_id',
      'host',
      'port',
      'url',
      'methods',
    ],
    disallowNullValues: const [
      'adapter',
      'format',
      'confirmed',
      'kind',
      'methods',
    ],
  );
  return LabelRead(
    adapter: json['adapter'] as String,
    format: json['format'] as String,
    confirmed: json['confirmed'] as bool,
    kind: json['kind'] as String,
    vendor: json['vendor'] as String?,
    model: json['model'] as String?,
    serial: json['serial'] as String?,
    code: json['code'] as String?,
    deviceId: json['device_id'] as String?,
    host: json['host'] as String?,
    port: LabelRead._read_port(json['port']),
    url: json['url'] as String?,
    methods: LabelRead._read_methods(json['methods']),
    additionalProperties:
        LabelRead._extras(json, 'additionalProperties') == null
        ? const {}
        : LabelRead._readExtras(
            LabelRead._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$LabelReadToJson(LabelRead instance) => <String, dynamic>{
  'adapter': instance.adapter,
  'format': instance.format,
  'confirmed': instance.confirmed,
  'kind': instance.kind,
  'vendor': instance.vendor,
  'model': instance.model,
  'serial': instance.serial,
  'code': instance.code,
  'device_id': instance.deviceId,
  'host': instance.host,
  'port': LabelRead._write_port(instance.port),
  'url': instance.url,
  'methods': ?LabelRead._write_methods(instance.methods),
};
