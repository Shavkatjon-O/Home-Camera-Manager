// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlements_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntitlementsRead _$EntitlementsReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['plan', 'usage', 'suspended'],
    disallowNullValues: const ['plan', 'usage', 'suspended'],
  );
  return EntitlementsRead(
    plan: PlanRead.fromJson(json['plan'] as Map<String, dynamic>),
    usage: EntitlementsRead._read_usage(json['usage']),
    suspended: json['suspended'] as bool,
    additionalProperties: EntitlementsRead._extras(json, 'additionalProperties') == null
        ? const {}
        : EntitlementsRead._readExtras(EntitlementsRead._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$EntitlementsReadToJson(EntitlementsRead instance) => <String, dynamic>{
  'plan': instance.plan.toJson(),
  'usage': ?EntitlementsRead._write_usage(instance.usage),
  'suspended': instance.suspended,
};
