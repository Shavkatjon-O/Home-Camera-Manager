// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ownership_transfer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OwnershipTransfer _$OwnershipTransferFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['member'],
    disallowNullValues: const ['member'],
  );
  return OwnershipTransfer(
    member: json['member'] as String,
    additionalProperties:
        OwnershipTransfer._extras(json, 'additionalProperties') == null
        ? const {}
        : OwnershipTransfer._readExtras(
            OwnershipTransfer._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$OwnershipTransferToJson(OwnershipTransfer instance) =>
    <String, dynamic>{'member': instance.member};
