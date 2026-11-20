// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_capabilities.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MaintenanceCapabilities _$MaintenanceCapabilitiesFromJson(
  Map<String, dynamic> json,
) {
  $checkKeys(json, disallowNullValues: const ['time', 'reboot']);
  return MaintenanceCapabilities(
    time: MaintenanceCapabilities._presentValue(json, 'time') == null
        ? false
        : MaintenanceCapabilities._read_time(
            MaintenanceCapabilities._presentValue(json, 'time') as Object,
          ),
    reboot: MaintenanceCapabilities._presentValue(json, 'reboot') == null
        ? false
        : MaintenanceCapabilities._read_reboot(
            MaintenanceCapabilities._presentValue(json, 'reboot') as Object,
          ),
    additionalProperties:
        MaintenanceCapabilities._extras(json, 'additionalProperties') == null
        ? const {}
        : MaintenanceCapabilities._readExtras(
            MaintenanceCapabilities._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$MaintenanceCapabilitiesToJson(
  MaintenanceCapabilities instance,
) => <String, dynamic>{
  'time': ?MaintenanceCapabilities._write_time(instance.time),
  'reboot': ?MaintenanceCapabilities._write_reboot(instance.reboot),
};
