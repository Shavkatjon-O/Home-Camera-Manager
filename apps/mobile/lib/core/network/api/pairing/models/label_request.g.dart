// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'label_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LabelRequest _$LabelRequestFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['payload'],
    disallowNullValues: const ['payload'],
  );
  return LabelRequest(
    payload: json['payload'] as String,
    additionalProperties:
        LabelRequest._extras(json, 'additionalProperties') == null
        ? const {}
        : LabelRequest._readExtras(
            LabelRequest._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$LabelRequestToJson(LabelRequest instance) =>
    <String, dynamic>{'payload': instance.payload};
