import 'dart:async';

import 'package:smart_surveillance/core/network/api/surveillance_api.dart' as api;
import 'package:smart_surveillance/core/network/client/http.dart';
import 'package:smart_surveillance/core/network/failure.dart';
import 'package:smart_surveillance/features/devices/domain/device_repository.dart';
import 'package:smart_surveillance/features/devices/domain/models.dart';

/// What the server identified for a camera or recorder, kept until it is added.
class Identified {
  /// Creates the record of [result] for the request [request].
  const Identified(this.request, this.result);

  /// The address and credentials that were identified.
  final api.IdentifyRequest request;

  /// What the server found there.
  final api.IdentifyResult result;
}

/// Reads and controls connectors and cameras on the server.
class ApiDeviceRepository implements DeviceRepository {
  /// Creates the repository over [client].
  ApiDeviceRepository(this.client);

  /// The generated API.
  final api.SurveillanceApi client;

  /// How long a rescan waits for the connector to report back.
  static const discoveryWait = Duration(seconds: 30);

  /// Converts the server's brand to the app's [CameraBrand].
  static CameraBrand brandOf(api.CameraBrand? brand) =>
      CameraBrand.values.asNameMap()[brand?.toJson()] ?? CameraBrand.rtsp;

  /// Converts the server's capability groups to the app's flat [CameraCapabilities];
  /// a camera without them is described by its PTZ switch alone.
  static CameraCapabilities capabilitiesOf(api.CapabilitiesRead? caps, {bool ptz = false}) {
    if (caps == null) return CameraCapabilities(ptz: ptz, presets: ptz, home: ptz);
    return CameraCapabilities(
      ptz: caps.control.ptz,
      zoom: caps.control.zoom,
      presets: caps.control.presets,
      home: caps.control.home,
      light: caps.control.light,
      siren: caps.control.siren,
      audio: caps.media.audio,
      playback: caps.playback.recordings || caps.playback.replay,
      settings: caps.imaging.settings.isNotEmpty || caps.imaging.encoders || caps.imaging.motion,
      reboot: caps.maintenance.reboot,
    );
  }

  /// Converts the server's camera in [siteId] to the app's [Camera].
  static Camera cameraOf(api.CameraRead camera, String siteId) => Camera(
    id: camera.uuid,
    siteId: siteId,
    name: camera.name,
    brand: brandOf(camera.brand),
    connectorId: camera.connector,
    lenses: camera.lenses,
    capabilities: capabilitiesOf(camera.capabilities, ptz: camera.ptzEnabled),
    enabled: camera.enabled,
    position: camera.position,
    online: camera.status.online,
    checkedAt: camera.status.checkedAt,
    error: camera.status.error,
    hasSub: camera.subPath != null || camera.streams.sub != null,
  );

  /// Converts the server's connector in [siteId] to the app's [Connector].
  static Connector connectorOf(api.ConnectorRead connector, String siteId) => Connector(
    id: connector.uuid,
    siteId: siteId,
    name: connector.name,
    state: connector.online ? ConnectorState.online : ConnectorState.offline,
    version: connector.version,
    lastSeenAt: connector.lastSeenAt,
    mode: connector.mode.toJson(),
    cameraCount: connector.cameraCount,
  );

  /// Converts a camera the connector found to the app's [DiscoveredCamera].
  static DiscoveredCamera discoveredOf(api.DiscoveredRead found) => DiscoveredCamera(
    id: found.uuid,
    host: found.host,
    ports: found.openPorts,
    brand: found.brand == null ? null : brandOf(found.brand),
    manufacturer: found.manufacturer,
    model: found.model,
    onvifPort: found.onvifPort,
    foundBy: found.foundBy.toJson(),
    rtspPort: found.openPorts.contains(554) ? 554 : null,
    cameraId: found.camera,
  );

  @override
  Future<List<Connector>> connectors(String siteId) async {
    final list = await guarded(() => client.connectors.listConnectors(xSite: siteId));
    return [for (final connector in list.items) connectorOf(connector, siteId)];
  }

  @override
  Future<void> removeConnector(String connectorId) =>
      guarded(() => client.connectors.removeConnector(uuid: connectorId));

  @override
  Future<List<DiscoveredCamera>> discovered(String connectorId, {bool rescan = false}) async {
    if (rescan) {
      final before = await guarded(
        () => client.connectors.listDiscoveredCameras(uuid: connectorId),
      );
      await guarded(() => client.connectors.requestDiscovery(uuid: connectorId));
      final deadline = DateTime.now().add(discoveryWait);
      while (DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(seconds: 2));
        final list = await guarded(
          () => client.connectors.listDiscoveredCameras(uuid: connectorId),
        );
        if (list.discoveredAt != null && list.discoveredAt != before.discoveredAt) {
          return [for (final found in list.items) discoveredOf(found)];
        }
      }
    }
    final list = await guarded(() => client.connectors.listDiscoveredCameras(uuid: connectorId));
    return [for (final found in list.items) discoveredOf(found)];
  }

  /// What identify found for each attempt and pairing screen camera id, kept until it is added.
  final Map<String, Identified> identified = {};

  /// The identify request for [camera] with [username] and [password], through [connectorId].
  static api.IdentifyRequest requestFor(
    DiscoveredCamera camera,
    String connectorId,
    String? username,
    String? password,
  ) {
    final rtsp = camera.foundBy == 'rtsp_url';
    final path = camera.mainPath ?? '';
    return api.IdentifyRequest(
      host: rtsp ? null : camera.host,
      port: rtsp ? null : (camera.onvifPort ?? (camera.ports.isEmpty ? null : camera.ports.first)),
      rtspPort: camera.rtspPort,
      username: username,
      password: password,
      adapter: rtsp ? 'rtsp' : camera.brand?.name,
      rtspUrl: rtsp
          ? 'rtsp://${camera.host}:${camera.rtspPort ?? 554}${path.startsWith('/') ? path : '/$path'}'
          : null,
      connector: connectorId,
    );
  }

  @override
  Future<StreamTest> testCamera({
    required String connectorId,
    required DiscoveredCamera camera,
    String? username,
    String? password,
  }) async {
    final request = requestFor(camera, connectorId, username, password);
    try {
      final result = await guarded(() => client.pairing.identifyDevice(body: request));
      identified[camera.id] = identified[result.attempt] = Identified(request, result);
      final first = result.channels.isEmpty ? null : result.channels.first;
      return StreamTest(
        ok: true,
        codec: first?.encoding,
        width: first?.width,
        height: first?.height,
      );
    } on ApiFailure catch (failure) {
      return StreamTest(ok: false, error: failure.detail ?? failure.kind.name);
    }
  }

  /// Creates the device [known] describes in [siteId] with the chosen [channels].
  Future<api.DeviceRead> createDevice({
    required String siteId,
    required Identified known,
    required String method,
    required String name,
    required List<int> channels,
    String? discovered,
  }) {
    final request = known.request;
    return guarded(
      () => client.pairing.createPairedDevice(
        xSite: siteId,
        body: api.PairingDeviceCreate(
          host: request.host,
          port: request.port,
          rtspPort: request.rtspPort ?? known.result.rtspPort,
          username: request.username,
          password: request.password,
          adapter: known.result.adapter,
          rtspUrl: request.rtspUrl,
          deviceId: request.deviceId,
          connector: request.connector,
          method: api.PairingMethodId.fromJson(method),
          name: name,
          channels: channels,
          discovered: discovered,
          attempt: known.result.attempt,
        ),
      ),
    );
  }

  @override
  Future<Camera> addCamera({
    required String siteId,
    required String connectorId,
    required DiscoveredCamera camera,
    required String name,
    String? username,
    String? password,
    required int lenses,
  }) async {
    var known = identified[camera.id];
    if (known == null || known.request.username != username || known.request.password != password) {
      final request = requestFor(camera, connectorId, username, password);
      final result = await guarded(() => client.pairing.identifyDevice(body: request));
      known = identified[camera.id] = Identified(request, result);
    }
    final method = switch (camera.foundBy) {
      'rtsp_url' => 'rtsp_url',
      'manual' || 'manual_host' => 'manual_host',
      'label' || 'label_qr' => 'label_qr',
      _ => 'connector_discovery',
    };
    final device = await createDevice(
      siteId: siteId,
      known: known,
      method: method,
      name: name,
      channels: [if (known.result.channels.isNotEmpty) known.result.channels.first.index],
      discovered: method == 'connector_discovery' ? camera.id : null,
    );
    identified.remove(camera.id);
    final id = device.channels.isEmpty ? null : device.channels.first.camera;
    if (id == null) throw const ApiFailure(FailureKind.server, 'no_camera');
    var created = await guarded(() => client.cameras.getCamera(uuid: id, xSite: siteId));
    if (lenses != created.lenses) {
      created = await guarded(
        () => client.cameras.updateCamera(
          uuid: id,
          xSite: siteId,
          body: api.CameraUpdate(lenses: lenses),
        ),
      );
    }
    return cameraOf(created, siteId);
  }

  @override
  Future<List<Camera>> cameras(String siteId) async {
    final list = await guarded(() => client.cameras.listCameras(xSite: siteId, pageSize: 100));
    final cameras = [for (final camera in list.items) cameraOf(camera, siteId)];
    return cameras..sort((a, b) => a.position.compareTo(b.position));
  }

  @override
  Future<Camera> updateCamera(Camera camera) async {
    final updated = await guarded(
      () => client.cameras.updateCamera(
        uuid: camera.id,
        xSite: camera.siteId,
        body: api.CameraUpdate(name: camera.name, enabled: camera.enabled, lenses: camera.lenses),
      ),
    );
    return cameraOf(updated, camera.siteId);
  }

  @override
  Future<void> deleteCamera(String cameraId) =>
      guarded(() => client.cameras.deleteCamera(uuid: cameraId));

  @override
  Future<void> orderCameras(String siteId, List<String> cameraIds) => guarded(
    () => client.cameras.orderCameras(
      xSite: siteId,
      body: api.CameraOrder(uuids: cameraIds),
    ),
  );

  @override
  Future<CameraControls> controls(String cameraId) async {
    final presets = await guarded(() => client.control.listPresets(uuid: cameraId));
    return CameraControls(
      presets: [
        for (final preset in presets.presets) PtzPreset(token: preset.token, name: preset.name),
      ],
    );
  }

  @override
  Future<void> move(
    String cameraId, {
    required double pan,
    required double tilt,
    required double zoom,
  }) => guarded(
    () => client.cameras.moveCamera(
      uuid: cameraId,
      body: api.PtzMove(pan: pan, tilt: tilt, zoom: zoom),
    ),
  );

  @override
  Future<void> stop(String cameraId) => guarded(() => client.cameras.stopCamera(uuid: cameraId));

  @override
  Future<void> gotoPreset(String cameraId, String token) =>
      guarded(() => client.control.gotoPreset(uuid: cameraId, token: token));

  @override
  Future<PtzPreset> savePreset(String cameraId, String name) async {
    final presets = await guarded(
      () => client.control.createPreset(
        uuid: cameraId,
        body: api.PresetName(name: name),
      ),
    );
    final saved = presets.presets.lastWhere(
      (preset) => preset.name == name,
      orElse: () => throw const ApiFailure(FailureKind.server),
    );
    return PtzPreset(token: saved.token, name: saved.name);
  }

  @override
  Future<void> gotoHome(String cameraId) => guarded(() => client.control.gotoHome(uuid: cameraId));

  @override
  Future<void> setLight(String cameraId, bool on) => guarded(
    () => client.control.setLight(
      uuid: cameraId,
      body: api.LightRequest(mode: on ? 'on' : 'off'),
    ),
  );

  @override
  Future<void> sirenFor(String cameraId, Duration duration) => guarded(
    () => client.control.setSiren(
      uuid: cameraId,
      body: api.SirenRequest(seconds: duration.inSeconds),
    ),
  );

  /// Runs [read] and returns null when the camera does not support it or it fails.
  Future<T?> optional<T>(Future<T> Function() read) async {
    try {
      return await guarded(read);
    } on ApiFailure {
      return null;
    }
  }

  @override
  Future<CameraSettings> settings(String cameraId) async {
    final results = await (
      optional(() => client.control.getCameraDevice(uuid: cameraId)),
      optional(() => client.control.getVideoSettings(uuid: cameraId)),
      optional(() => client.control.getImageSettings(uuid: cameraId)),
      optional(() => client.control.getMotionSettings(uuid: cameraId)),
    ).wait;
    final (device, video, image, motion) = results;
    final settings = image?.settings;
    return CameraSettings(
      device: CameraDevice(
        manufacturer: device?.vendor,
        model: device?.model,
        canReboot: device?.capabilities.maintenance.reboot ?? false,
      ),
      encoders: [
        if (video != null && video.supported)
          for (final encoder in video.encoders)
            VideoEncoder(
              token: encoder.token,
              name: encoder.name,
              encoding: encoder.encoding,
              width: encoder.width,
              height: encoder.height,
              fps: encoder.fps?.toDouble(),
              bitrate: encoder.bitrate,
            ),
      ],
      image: image == null || !image.supported || settings == null
          ? null
          : ImageSettings(
              brightness: settings.brightness?.toDouble(),
              contrast: settings.contrast?.toDouble(),
              saturation: settings.saturation?.toDouble(),
              sharpness: settings.sharpness?.toDouble(),
              irCut: settings.irCutFilter,
              irCutModes: image.options?.irCutFilterModes ?? const [],
            ),
      motion: motion == null || !motion.supported
          ? null
          : MotionSettings(
              enabled: motion.enabled,
              sensitivity: motion.sensitivity,
              min: motion.sensitivityRange?.min.round() ?? 0,
              max: motion.sensitivityRange?.max.round() ?? 100,
            ),
    );
  }

  @override
  Future<void> updateMotion(String cameraId, MotionSettings motion) => guarded(
    () => client.control.updateMotionSettings(
      uuid: cameraId,
      body: api.MotionUpdate(sensitivity: motion.sensitivity, enabled: motion.enabled),
    ),
  );

  @override
  Future<void> updateImage(String cameraId, ImageSettings image) => guarded(
    () => client.control.updateImageSettings(
      uuid: cameraId,
      body: api.ImageSettings(
        brightness: image.brightness,
        contrast: image.contrast,
        saturation: image.saturation,
        sharpness: image.sharpness,
        irCutFilter: image.irCut,
      ),
    ),
  );

  @override
  Future<void> syncClock(String cameraId) =>
      guarded(() => client.control.syncCameraTime(uuid: cameraId));

  @override
  Future<void> reboot(String cameraId) =>
      guarded(() => client.control.rebootCamera(uuid: cameraId));
}
