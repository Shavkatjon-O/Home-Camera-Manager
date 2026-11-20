import 'dart:async';

import 'package:smart_surveillance/app/demo/fake_store.dart';
import 'package:smart_surveillance/core/network/failure.dart';
import 'package:smart_surveillance/features/devices/data/fake_device_repository.dart';
import 'package:smart_surveillance/features/devices/domain/models.dart';
import 'package:smart_surveillance/features/devices/domain/pairing_models.dart';
import 'package:smart_surveillance/features/devices/domain/pairing_repository.dart';
class FakePairingRepository implements PairingRepository {
  FakePairingRepository(this.store, this.devices);

  final FakeStore store;
  final FakeDeviceRepository devices;
  final reports = <PairingReport>[];

  @override
  Future<List<PairingCatalogEntry>> catalog(String siteId, {String? label, String? discoveredId}) => store.delay(() {
    final connectors = store.data.connectors.where((c) => c.siteId == siteId && c.state == ConnectorState.online);
    final online = connectors.isNotEmpty;
    final nvr = online && (store.data.discovered[connectors.first.id] ?? const []).any((d) => d.nvr && d.cameraId == null);
    return [
      PairingCatalogEntry(id: 'connector_discovery', rank: 1, available: online, recommended: online),
      const PairingCatalogEntry(id: 'label_qr', rank: 2),
      PairingCatalogEntry(id: 'manual_host', rank: 3, available: online),
      PairingCatalogEntry(id: 'nvr_import', rank: 4, available: nvr),
      PairingCatalogEntry(id: 'rtsp_url', rank: 5, available: online),
      const PairingCatalogEntry(id: 'connector_qr', rank: 10, recommended: true),
      const PairingCatalogEntry(id: 'connector_mdns', rank: 11),
      const PairingCatalogEntry(id: 'connector_code', rank: 12),
    ];
  });

  @override
  Future<Connector> claimConnector({required String siteId, required String code, String? name}) =>
      store.delay(() {
        final cleaned = code.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
        if (cleaned.length != 8) throw const ApiFailure(FailureKind.invalid);
        if (cleaned.toUpperCase() == 'EXPIRED0') throw const ApiFailure(FailureKind.expired);
        final connector = Connector(
          id: 'con-${store.sequence++}',
          siteId: siteId,
          name: name ?? 'Connector',
          state: ConnectorState.online,
          version: '0.1.0',
          lastSeenAt: store.clock(),
        );
        store.data.connectors.add(connector);
        store.data.discovered[connector.id] = List.of(store.data.discovered['con-home']!)
            .map((d) => d.copyWith(cameraId: null))
            .toList();
        return connector;
      });

  @override
  Future<LabelIdentity> identifyLabel(String siteId, String payload) => store.delay(() {
    final upper = payload.toUpperCase();
    if (upper.contains('EZVIZ') || upper.startsWith('SN')) {
      return const LabelIdentity(
        method: 'connector_discovery',
        brand: CameraBrand.ezviz,
        manufacturer: 'EZVIZ',
        model: 'CS-H3',
        serial: 'DEMO00001',
        discoveredId: 'disc-1',
      );
    }
    if (upper.contains('V380')) {
      return const LabelIdentity(
        method: 'manual_host',
        brand: CameraBrand.v380,
        manufacturer: 'V380',
        model: 'Dual lens PTZ',
        port: 8899,
      );
    }
    throw const ApiFailure(FailureKind.notFound, 'unknown_label');
  });

  @override
  Future<DiscoveredCamera> identifyHost({
    required String connectorId,
    required String host,
    int? port,
    String? username,
    String? password,
  }) async {
    if (store.latency > Duration.zero) await Future<void>.delayed(const Duration(milliseconds: 900));
    return store.delay(() {
      if (!RegExp(r'^[0-9A-Za-z.-]+$').hasMatch(host)) throw const ApiFailure(FailureKind.invalid, 'host');
      return DiscoveredCamera(
        id: 'manual-${host.hashCode}',
        host: host,
        ports: [port ?? 80, 554],
        brand: CameraBrand.onvif,
        manufacturer: 'Generic',
        model: 'IP camera',
        onvifPort: port ?? 80,
        foundBy: 'manual',
      );
    });
  }

  @override
  Future<List<NvrChannel>> nvrChannels({
    required String connectorId,
    required DiscoveredCamera nvr,
    String? username,
    String? password,
  }) => store.delay(() {
    if (password == null || password.isEmpty) throw const ApiFailure(FailureKind.unauthorised);
    return [for (var i = 1; i <= 8; i++) NvrChannel(index: i, name: 'Channel $i', online: i != 6)];
  });

  @override
  Future<List<Camera>> addChannels({
    required String siteId,
    required String connectorId,
    required DiscoveredCamera nvr,
    required List<NvrChannel> channels,
    String? username,
    String? password,
  }) async {
    final added = <Camera>[];
    for (final channel in channels) {
      added.add(
        await devices.addCamera(
          siteId: siteId,
          connectorId: connectorId,
          camera: nvr.copyWith(id: '${nvr.id}-${channel.index}', nvr: false),
          name: channel.name,
          username: username,
          password: password,
          lenses: 1,
        ),
      );
    }
    final list = store.data.discovered[connectorId];
    if (list != null) {
      final index = list.indexWhere((d) => d.id == nvr.id);
      if (index >= 0 && added.isNotEmpty) list[index] = list[index].copyWith(cameraId: added.first.id);
    }
    return added;
  }

  @override
  Future<void> report(PairingReport report) async => reports.add(report);
}
