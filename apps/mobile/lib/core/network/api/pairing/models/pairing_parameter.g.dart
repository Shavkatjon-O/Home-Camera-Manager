// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_parameter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PairingParameter _$PairingParameterFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['name', 'type', 'required', 'description'],
    disallowNullValues: const ['name', 'type', 'required', 'description'],
  );
  return PairingParameter(
    name: json['name'] as String,
    type: json['type'] as String,
    required2: json['required'] as bool,
    description: json['description'] as String,
    default2: !json.containsKey('default')
        ? null
        : PairingParameter._read_default2(json['default']),
    prefill: !json.containsKey('prefill')
        ? null
        : PairingParameter._read_prefill(json['prefill']),
    additionalProperties:
        PairingParameter._extras(json, 'additionalProperties') == null
        ? const {}
        : PairingParameter._readExtras(
            PairingParameter._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$PairingParameterToJson(PairingParameter instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'required': instance.required2,
      'description': instance.description,
      if (instance.default2 case final $value?)
        'default': PairingParameter._write_default2($value),
      if (instance.prefill case final $value?)
        'prefill': PairingParameter._write_prefill($value),
    };
