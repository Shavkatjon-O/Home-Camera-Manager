import 'package:flutter_test/flutter_test.dart';
import 'package:smart_surveillance/core/network/api/surveillance_api.dart' as api;
import 'package:smart_surveillance/features/devices/data/api_device_repository.dart';
import 'package:smart_surveillance/features/devices/domain/models.dart';

/// A camera as the server writes it, with [capabilities] when given.
Map<String, Object?> cameraJson({
  String brand = 'onvif',
  bool ptz = false,
  Map<String, Object?>? capabilities,
}) => {
  'uuid': 'camera-1',
  'name': 'Front door',
  'brand': brand,
  'host': '192.168.1.20',
  'device_host': null,
  'rtsp_port': 554,
  'onvif_port': 80,
  'username': 'viewer',
  'has_password': true,
  'main_path': '/stream1',
  'sub_path': '/stream2',
  'lenses': 2,
  'ptz_enabled': ptz,
  'location': null,
  'position': 3,
  'enabled': true,
  'status': {'online': true, 'checked_at': '2026-03-14T10:00:00Z', 'error': null},
  'streams': {'main': 'camera-1', 'sub': 'camera-1-sub'},
  'capabilities': capabilities,
  'connector': 'connector-1',
  'created_at': '2026-03-01T08:00:00Z',
  'updated_at': '2026-03-02T08:00:00Z',
};

/// Runs the device mapping tests.
void main() {
  group('brandOf', () {
    test('maps known brands and falls back to rtsp', () {
      expect(ApiDeviceRepository.brandOf(api.CameraBrand.onvif), CameraBrand.onvif);
      expect(ApiDeviceRepository.brandOf(api.CameraBrand.ezviz), CameraBrand.ezviz);
      expect(ApiDeviceRepository.brandOf(null), CameraBrand.rtsp);
      expect(ApiDeviceRepository.brandOf(api.CameraBrand.fromJson('other')), CameraBrand.rtsp);
    });
  });

  group('capabilitiesOf', () {
    test('describes a camera without capabilities by its PTZ switch', () {
      final plain = ApiDeviceRepository.capabilitiesOf(null);
      expect(plain.ptz, isFalse);
      expect(plain.presets, isFalse);
      final moving = ApiDeviceRepository.capabilitiesOf(null, ptz: true);
      expect(moving.ptz, isTrue);
      expect(moving.presets, isTrue);
      expect(moving.home, isTrue);
    });

    test('flattens the capability groups', () {
      final caps = ApiDeviceRepository.capabilitiesOf(
        api.CapabilitiesRead.fromJson({
          'adapter': 'onvif',
          'version': 1,
          'kind': 'camera',
          'channels': 1,
          'identify': true,
          'media': {'audio': true},
          'control': {'ptz': true, 'zoom': true, 'siren': true},
          'imaging': {
            'settings': ['brightness'],
          },
          'events': <String, Object?>{},
          'playback': {'replay': true},
          'maintenance': {'reboot': true},
          'provisioning': <String, Object?>{},
        }),
      );
      expect(caps.ptz, isTrue);
      expect(caps.zoom, isTrue);
      expect(caps.siren, isTrue);
      expect(caps.light, isFalse);
      expect(caps.audio, isTrue);
      expect(caps.playback, isTrue);
      expect(caps.settings, isTrue);
      expect(caps.reboot, isTrue);
    });
  });

  group('cameraOf', () {
    test('maps a camera', () {
      final camera = ApiDeviceRepository.cameraOf(api.CameraRead.fromJson(cameraJson()), 'site-1');
      expect(camera.id, 'camera-1');
      expect(camera.siteId, 'site-1');
      expect(camera.name, 'Front door');
      expect(camera.brand, CameraBrand.onvif);
      expect(camera.connectorId, 'connector-1');
      expect(camera.lenses, 2);
      expect(camera.position, 3);
      expect(camera.enabled, isTrue);
      expect(camera.online, isTrue);
      expect(camera.checkedAt!.toUtc(), DateTime.utc(2026, 3, 14, 10));
      expect(camera.error, isNull);
      expect(camera.hasSub, isTrue);
      expect(camera.ptz, isFalse);
    });

    test('takes PTZ from the switch when capabilities are missing', () {
      final camera = ApiDeviceRepository.cameraOf(
        api.CameraRead.fromJson(cameraJson(ptz: true)),
        'site-1',
      );
      expect(camera.ptz, isTrue);
    });
  });

  group('connectorOf', () {
    test('maps an online connector', () {
      final connector = ApiDeviceRepository.connectorOf(
        api.ConnectorRead.fromJson({
          'uuid': 'connector-1',
          'name': 'Example connector',
          'version': '1.2.3',
          'mode': 'tunnel',
          'address': '192.168.1.10',
          'online': true,
          'last_seen_at': '2026-03-14T10:00:00Z',
          'camera_count': 4,
          'discovery_requested_at': null,
          'discovered_at': null,
          'health': <String, Object?>{},
          'created_at': '2026-03-01T08:00:00Z',
        }),
        'site-1',
      );
      expect(connector.id, 'connector-1');
      expect(connector.siteId, 'site-1');
      expect(connector.state, ConnectorState.online);
      expect(connector.version, '1.2.3');
      expect(connector.mode, 'tunnel');
      expect(connector.cameraCount, 4);
      expect(connector.lastSeenAt!.toUtc(), DateTime.utc(2026, 3, 14, 10));
    });
  });

  group('discoveredOf', () {
    test('maps a discovered camera and picks the RTSP port from the open ports', () {
      final found = ApiDeviceRepository.discoveredOf(
        api.DiscoveredRead.fromJson({
          'uuid': 'found-1',
          'host': '192.168.1.31',
          'open_ports': [80, 554],
          'brand': 'onvif',
          'manufacturer': 'Example Maker',
          'model': 'Model 1',
          'onvif_port': 80,
          'found_by': 'both',
          'seen_at': '2026-03-14T10:00:00Z',
          'camera': null,
        }),
      );
      expect(found.id, 'found-1');
      expect(found.host, '192.168.1.31');
      expect(found.ports, [80, 554]);
      expect(found.brand, CameraBrand.onvif);
      expect(found.rtspPort, 554);
      expect(found.onvifPort, 80);
      expect(found.foundBy, 'both');
      expect(found.cameraId, isNull);
    });

    test('leaves the RTSP port empty when it is closed', () {
      final found = ApiDeviceRepository.discoveredOf(
        api.DiscoveredRead.fromJson({
          'uuid': 'found-2',
          'host': '192.168.1.32',
          'open_ports': [80],
          'brand': null,
          'manufacturer': null,
          'model': null,
          'onvif_port': null,
          'found_by': 'sweep',
          'seen_at': '2026-03-14T10:00:00Z',
          'camera': 'camera-9',
        }),
      );
      expect(found.brand, isNull);
      expect(found.rtspPort, isNull);
      expect(found.cameraId, 'camera-9');
    });
  });
}
