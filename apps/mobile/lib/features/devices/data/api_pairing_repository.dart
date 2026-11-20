import 'dart:async';

import 'package:smart_surveillance/core/network/api/surveillance_api.dart' as api;
import 'package:smart_surveillance/core/network/client/http.dart';
import 'package:smart_surveillance/core/network/failure.dart';
import 'package:smart_surveillance/features/devices/data/api_device_repository.dart';
import 'package:smart_surveillance/features/devices/domain/models.dart';
import 'package:smart_surveillance/features/devices/domain/pairing_models.dart';
import 'package:smart_surveillance/features/devices/domain/pairing_repository.dart';

/// Pairs connectors and devices through the server's pairing catalog, the
/// adapters behind identify and the pairing telemetry.
class ApiPairingRepository implements PairingRepository {
  /// Creates the repository over [client], adding cameras through [devices].
  ApiPairingRepository(this.client, this.devices);

  /// The generated API.
  final api.SurveillanceApi client;

  /// The device repository, which lists the cameras a new device brought.
  final ApiDeviceRepository devices;

  /// How long a claimed connector code is followed before giving up.
  static const claimWait = Duration(seconds: 90);

  /// The brand an adapter id stands for.
  static CameraBrand brandOfAdapter(String? adapter) => switch (adapter) {
    'ezviz' => CameraBrand.ezviz,
    'v380' => CameraBrand.v380,
    'onvif' => CameraBrand.onvif,
    _ => CameraBrand.rtsp,
  };

  /// The adapter id for a camera of [brand].
  static String adapterOf(CameraBrand? brand) => (brand ?? CameraBrand.rtsp).name;

  /// The pairing method a discovered camera came from, by how it was found.
  static String methodOf(DiscoveredCamera camera) => switch (camera.foundBy) {
    'rtsp_url' => 'rtsp_url',
    'manual' || 'manual_host' => 'manual_host',
    'label' || 'label_qr' => 'label_qr',
    'nvr' || 'nvr_import' => 'nvr_import',
    _ => 'connector_discovery',
  };

  @override
  Future<List<PairingCatalogEntry>> catalog(
    String siteId, {
    String? label,
    String? discoveredId,
  }) async {
    final list = await guarded(
      () =>
          client.pairing.listPairingMethods(xSite: siteId, label: label, discovered: discoveredId),
    );
    return [
      for (final (index, method) in list.items.indexed)
        PairingCatalogEntry(id: method.id.toJson(), rank: index, recommended: method.recommended),
    ];
  }

  @override
  Future<Connector> claimConnector({
    required String siteId,
    required String code,
    String? name,
  }) async {
    var pairing = await guarded(
      () => client.connectors.claimConnector(
        xSite: siteId,
        body: api.ConnectorClaim(userCode: code, name: name),
      ),
    );
    final deadline = DateTime.now().add(claimWait);
    while (pairing.connector == null) {
      if (pairing.status.toJson() == 'expired') throw const ApiFailure(FailureKind.expired);
      if (DateTime.now().isAfter(deadline)) {
        throw const ApiFailure(FailureKind.network, 'claim_timeout');
      }
      await Future<void>.delayed(const Duration(seconds: 2));
      final uuid = pairing.uuid;
      pairing = await guarded(() => client.connectors.getPairing(uuid: uuid, xSite: siteId));
    }
    final connector = pairing.connector!;
    while (true) {
      try {
        final read = await guarded(
          () => client.connectors.getConnector(uuid: connector, xSite: siteId),
        );
        return ApiDeviceRepository.connectorOf(read, siteId);
      } on ApiFailure catch (failure) {
        if (failure.kind != FailureKind.notFound || DateTime.now().isAfter(deadline)) rethrow;
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }
  }

  @override
  Future<LabelIdentity> identifyLabel(String siteId, String payload) async {
    final label = await guarded(
      () => client.pairing.readLabel(
        xSite: siteId,
        body: api.LabelRequest(payload: payload),
      ),
    );
    final methods = [for (final method in label.methods) method.toJson()];
    return LabelIdentity(
      method: label.confirmed && methods.isNotEmpty ? methods.first : 'manual_host',
      brand: brandOfAdapter(label.adapter),
      manufacturer: label.vendor,
      model: label.model,
      serial: label.serial,
      host: label.host,
      port: label.port,
      url: label.url,
      adapter: label.adapter,
    );
  }

  /// Identifies the device described by [request] and remembers the result under its attempt id.
  Future<(String, api.IdentifyResult)> identify(api.IdentifyRequest request) async {
    final result = await guarded(() => client.pairing.identifyDevice(body: request));
    devices.identified[result.attempt] = Identified(request, result);
    return (result.attempt, result);
  }

  /// Converts an identify result to the camera or recorder the pairing screens show.
  static DiscoveredCamera discoveredOf(
    String attempt,
    api.IdentifyRequest request,
    api.IdentifyResult result,
    String foundBy,
  ) {
    final first = result.channels.isEmpty ? null : result.channels.first;
    final port = request.port ?? result.rtspPort ?? request.rtspPort;
    return DiscoveredCamera(
      id: attempt,
      host: request.host ?? '',
      ports: [?port],
      brand: brandOfAdapter(result.adapter),
      manufacturer: result.vendor,
      model: result.model,
      ptz: result.capabilities.control.ptz,
      nvr: result.kind == 'nvr' || result.channels.length > 1,
      foundBy: foundBy,
      rtspPort: result.rtspPort,
      mainPath: first?.mainPath,
    );
  }

  @override
  Future<DiscoveredCamera> identifyHost({
    required String connectorId,
    required String host,
    int? port,
    String? username,
    String? password,
  }) async {
    final request = api.IdentifyRequest(
      host: host,
      port: port,
      username: username,
      password: password,
      connector: connectorId,
    );
    try {
      final (attempt, result) = await identify(request);
      return discoveredOf(attempt, request, result, 'manual_host');
    } on ApiFailure catch (failure) {
      // Most cameras answer only with credentials, which the details step asks for.
      if (failure.kind == FailureKind.network || failure.kind == FailureKind.notFound) rethrow;
      return DiscoveredCamera(
        id: 'host-$host-${port ?? 0}',
        host: host,
        ports: [?port],
        foundBy: 'manual_host',
      );
    }
  }

  @override
  Future<List<NvrChannel>> nvrChannels({
    required String connectorId,
    required DiscoveredCamera nvr,
    String? username,
    String? password,
  }) async {
    final request = api.IdentifyRequest(
      host: nvr.host,
      port: nvr.onvifPort ?? (nvr.ports.isEmpty ? null : nvr.ports.first),
      rtspPort: nvr.rtspPort,
      username: username,
      password: password,
      adapter: nvr.brand == null ? null : adapterOf(nvr.brand),
      connector: connectorId,
    );
    final (attempt, result) = await identify(request);
    devices.identified[nvr.id] = devices.identified[attempt]!;
    return [
      for (final channel in result.channels)
        NvrChannel(index: channel.index, name: channel.name, online: channel.mainPath != null),
    ];
  }

  @override
  Future<List<Camera>> addChannels({
    required String siteId,
    required String connectorId,
    required DiscoveredCamera nvr,
    required List<NvrChannel> channels,
    String? username,
    String? password,
  }) async {
    final known = devices.identified[nvr.id];
    if (known == null) throw const ApiFailure(FailureKind.invalid, 'not_identified');
    final device = await devices.createDevice(
      siteId: siteId,
      known: known,
      method: 'nvr_import',
      name: nvr.model ?? nvr.manufacturer ?? nvr.host,
      channels: [for (final channel in channels) channel.index],
      discovered: nvr.foundBy == 'wsd' || nvr.foundBy == 'sweep' || nvr.foundBy == 'both'
          ? nvr.id
          : null,
    );
    final ids = {for (final channel in device.channels) channel.camera};
    final cameras = await devices.cameras(siteId);
    return [
      for (final camera in cameras)
        if (ids.contains(camera.id)) camera,
    ];
  }

  @override
  Future<void> report(PairingReport report) async {
    final outcome = switch (report.outcome) {
      PairingOutcome.success => 'succeeded',
      PairingOutcome.failure => 'failed',
      PairingOutcome.cancelled => 'abandoned',
    };
    try {
      await guarded(
        () => client.pairing.reportPairingAttempt(
          xSite: report.siteId,
          body: api.PairingAttemptCreate(
            method: api.PairingMethodId.fromJson(report.method),
            lastStep: report.step,
            outcome: api.AttemptOutcome.fromJson(outcome),
            errorCode: report.errorCode,
            durationMs: report.durationMs,
          ),
        ),
      );
    } on ApiFailure {
      // Telemetry never blocks pairing.
    }
  }
}
