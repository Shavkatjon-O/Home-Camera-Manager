// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provisioning_capabilities.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProvisioningCapabilities _$ProvisioningCapabilitiesFromJson(Map<String, dynamic> json) {
  $checkKeys(json, disallowNullValues: const ['methods']);
  return ProvisioningCapabilities(
    methods: ProvisioningCapabilities._presentValue(json, 'methods') == null
        ? const []
        : ProvisioningCapabilities._read_methods(
            ProvisioningCapabilities._presentValue(json, 'methods') as Object,
          ),
    additionalProperties: ProvisioningCapabilities._extras(json, 'additionalProperties') == null
        ? const {}
        : ProvisioningCapabilities._readExtras(
            ProvisioningCapabilities._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$ProvisioningCapabilitiesToJson(ProvisioningCapabilities instance) =>
    <String, dynamic>{'methods': ?ProvisioningCapabilities._write_methods(instance.methods)};
