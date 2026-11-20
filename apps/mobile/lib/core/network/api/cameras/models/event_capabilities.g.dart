// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_capabilities.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventCapabilities _$EventCapabilitiesFromJson(Map<String, dynamic> json) {
  $checkKeys(json, disallowNullValues: const ['kinds']);
  return EventCapabilities(
    kinds: EventCapabilities._presentValue(json, 'kinds') == null
        ? const []
        : EventCapabilities._read_kinds(EventCapabilities._presentValue(json, 'kinds') as Object),
    additionalProperties: EventCapabilities._extras(json, 'additionalProperties') == null
        ? const {}
        : EventCapabilities._readExtras(EventCapabilities._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$EventCapabilitiesToJson(EventCapabilities instance) => <String, dynamic>{
  'kinds': ?EventCapabilities._write_kinds(instance.kinds),
};
