import 'package:flutter_test/flutter_test.dart';
import 'package:smart_surveillance/features/devices/domain/models.dart';
import 'package:smart_surveillance/features/devices/domain/pairing_models.dart';
import 'package:smart_surveillance/features/devices/pairing/pairing_method.dart';
import 'package:smart_surveillance/features/devices/pairing/registry.dart';

const online = Connector(
  id: 'connector-1',
  siteId: 'site-1',
  name: 'Example connector',
  state: ConnectorState.online,
);

const withConnector = PairingContext(siteId: 'site-1', connectors: [online]);
const withoutConnector = PairingContext(siteId: 'site-1', connectors: []);

/// The ids of [ranked] in order.
List<String> ids(List<RankedMethod> ranked) => [for (final r in ranked) r.method.id];

/// Runs the pairing registry tests.
void main() {
  group('methodById', () {
    test('finds every implemented method', () {
      for (final method in pairingMethods) {
        expect(methodById(method.id), same(method));
      }
    });

    test('returns null for an unknown id', () {
      expect(methodById('telepathy'), isNull);
    });

    test('has unique ids', () {
      expect(pairingMethods.map((m) => m.id).toSet(), hasLength(pairingMethods.length));
    });
  });

  group('rankMethods', () {
    test('orders the methods by the catalog rank', () {
      const catalog = [
        PairingCatalogEntry(id: 'rtsp_url', rank: 3),
        PairingCatalogEntry(id: 'connector_discovery', rank: 1),
        PairingCatalogEntry(id: 'label_qr', rank: 2),
        PairingCatalogEntry(id: 'manual_host', rank: 4),
      ];
      final ranked = rankMethods(catalog, PairingTarget.camera, withConnector);
      expect(ids(ranked), ['connector_discovery', 'label_qr', 'rtsp_url', 'manual_host']);
      expect(ranked.first.entry.rank, 1);
    });

    test('does not offer methods the catalog leaves out', () {
      const catalog = [
        PairingCatalogEntry(id: 'label_qr', rank: 1),
        PairingCatalogEntry(id: 'future_method', rank: 2),
      ];
      expect(ids(rankMethods(catalog, PairingTarget.camera, withConnector)), ['label_qr']);
    });

    test('does not offer a method the catalog marks unavailable', () {
      const catalog = [
        PairingCatalogEntry(id: 'label_qr', rank: 1, available: false),
        PairingCatalogEntry(id: 'rtsp_url', rank: 2),
      ];
      expect(ids(rankMethods(catalog, PairingTarget.camera, withConnector)), ['rtsp_url']);
    });

    test('keeps only methods of the requested target', () {
      const catalog = [
        PairingCatalogEntry(id: 'connector_code', rank: 1),
        PairingCatalogEntry(id: 'label_qr', rank: 2),
        PairingCatalogEntry(id: 'connector_qr', rank: 3),
      ];
      expect(ids(rankMethods(catalog, PairingTarget.connector, withConnector)), [
        'connector_code',
        'connector_qr',
      ]);
      expect(ids(rankMethods(catalog, PairingTarget.camera, withConnector)), ['label_qr']);
    });

    test('drops methods that need a connector when the site has none', () {
      const catalog = [
        PairingCatalogEntry(id: 'connector_discovery', rank: 1),
        PairingCatalogEntry(id: 'manual_host', rank: 2),
        PairingCatalogEntry(id: 'nvr_import', rank: 3),
        PairingCatalogEntry(id: 'rtsp_url', rank: 4),
        PairingCatalogEntry(id: 'label_qr', rank: 5),
      ];
      expect(ids(rankMethods(catalog, PairingTarget.camera, withoutConnector)), ['label_qr']);
    });

    test('returns nothing for an empty catalog', () {
      expect(rankMethods(const [], PairingTarget.camera, withConnector), isEmpty);
    });
  });
}
