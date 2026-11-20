import 'dart:async';

import 'package:smart_surveillance/app/demo/fake_store.dart';
import 'package:smart_surveillance/app/demo/fixtures.dart';
import 'package:smart_surveillance/core/media/media_source.dart';
import 'package:smart_surveillance/features/analytics/domain/models.dart';
import 'package:smart_surveillance/features/devices/domain/device_repository.dart';
import 'package:smart_surveillance/features/devices/domain/models.dart';
class FakeDeviceRepository implements DeviceRepository {
  FakeDeviceRepository(this.store);

  final FakeStore store;

  @override
  Future<List<Connector>> connectors(String siteId) =>
      store.delay(() => store.data.connectors.where((c) => c.siteId == siteId).toList());

  @override
  Future<void> removeConnector(String connectorId) =>
      store.delay(() => store.data.connectors.removeWhere((c) => c.id == connectorId));

  @override
  Future<List<DiscoveredCamera>> discovered(String connectorId, {bool rescan = false}) async {
    if (rescan && store.latency > Duration.zero) await Future<void>.delayed(const Duration(milliseconds: 1400));
    return store.delay(() => List.of(store.data.discovered[connectorId] ?? const []));
  }

  @override
  Future<StreamTest> testCamera({
    required String connectorId,
    required DiscoveredCamera camera,
    String? username,
    String? password,
  }) async {
    if (store.latency > Duration.zero) await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (camera.brand != CameraBrand.rtsp && (password == null || password.isEmpty)) {
      return const StreamTest(ok: false, error: 'unauthorised');
    }
    final dual = camera.brand == CameraBrand.v380;
    return StreamTest(
      ok: true,
      codec: 'H.265',
      width: dual ? 2304 : 2560,
      height: dual ? 2592 : 1440,
      lenses: dual ? 2 : 1,
      preview: SyntheticMedia(dual ? SceneKind.yard : SceneKind.street, seed: camera.id.hashCode),
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
  }) => store.delay(() {
    final created = Camera(
      id: 'cam-${store.sequence++}',
      siteId: siteId,
      connectorId: connectorId,
      name: name,
      brand: camera.brand ?? CameraBrand.onvif,
      model: camera.model,
      lenses: lenses,
      capabilities: CameraCapabilities(
        ptz: camera.ptz,
        presets: camera.ptz,
        home: camera.ptz,
        light: camera.brand == CameraBrand.v380,
        siren: camera.brand == CameraBrand.v380,
        settings: camera.brand != CameraBrand.rtsp,
        reboot: camera.brand != CameraBrand.rtsp,
      ),
      online: true,
      position: store.data.cameras.where((c) => c.camera.siteId == siteId).length,
      aspect: lenses == 2 ? 16 / 18 : 16 / 9,
      checkedAt: store.clock(),
    );
    store.data.cameras.add(
      CameraFixture(created, lenses == 2 ? [SceneKind.yard, SceneKind.entrance] : [SceneKind.street]),
    );
    for (var lens = 0; lens < lenses; lens++) {
      store.data.views.add(
        AnalyticsView(
          id: 'view-${created.id}-$lens',
          cameraId: created.id,
          cameraName: name,
          lens: lens,
          lenses: lenses,
          name: lenses > 1 ? '$name lens ${lens + 1}' : name,
        ),
      );
    }
    final list = store.data.discovered[connectorId];
    if (list != null) {
      final index = list.indexWhere((d) => d.id == camera.id);
      if (index >= 0) list[index] = list[index].copyWith(cameraId: created.id);
    }
    return created;
  });

  @override
  Future<List<Camera>> cameras(String siteId) => store.delay(
    () =>
        store.data.cameras.map((c) => c.camera).where((c) => c.siteId == siteId).toList()
          ..sort((a, b) => a.position.compareTo(b.position)),
  );

  @override
  Future<Camera> updateCamera(Camera camera) => store.delay(() {
    final index = store.data.cameras.indexWhere((c) => c.camera.id == camera.id);
    store.data.cameras[index] = CameraFixture(camera, store.data.cameras[index].scenes);
    return camera;
  });

  @override
  Future<void> deleteCamera(String cameraId) => store.delay(() {
    store.data.cameras.removeWhere((c) => c.camera.id == cameraId);
    store.data.views.removeWhere((v) => v.cameraId == cameraId);
  });

  @override
  Future<void> orderCameras(String siteId, List<String> cameraIds) => store.delay(() {
    for (var i = 0; i < cameraIds.length; i++) {
      final index = store.data.cameras.indexWhere((c) => c.camera.id == cameraIds[i]);
      final fixture = store.data.cameras[index];
      store.data.cameras[index] = CameraFixture(fixture.camera.copyWith(position: i), fixture.scenes);
    }
  });

  @override
  Future<CameraControls> controls(String cameraId) =>
      store.delay(() => CameraControls(presets: store.data.presets[cameraId] ?? const []));

  @override
  Future<void> move(String cameraId, {required double pan, required double tilt, required double zoom}) async {}

  @override
  Future<void> stop(String cameraId) async {}

  @override
  Future<void> gotoPreset(String cameraId, String token) => store.delay(() {});

  @override
  Future<PtzPreset> savePreset(String cameraId, String name) => store.delay(() {
    final list = store.data.presets[cameraId] ??= [];
    final preset = PtzPreset(token: '${list.length + 1}', name: name);
    list.add(preset);
    return preset;
  });

  @override
  Future<void> gotoHome(String cameraId) => store.delay(() {});

  @override
  Future<void> setLight(String cameraId, bool on) => store.delay(() {});

  @override
  Future<void> sirenFor(String cameraId, Duration duration) => store.delay(() {});

  @override
  Future<CameraSettings> settings(String cameraId) => store.delay(() {
    final camera = store.data.camera(cameraId).camera;
    return CameraSettings(
      device: CameraDevice(
        manufacturer: camera.brand == CameraBrand.ezviz ? 'EZVIZ' : 'Generic',
        model: camera.model ?? 'IP camera',
        firmware: 'V5.3.8 build 241104',
        clockOffsetSeconds: 1.4,
        timezone: 'UTC+05:00',
        canReboot: true,
      ),
      encoders: const [
        VideoEncoder(token: 'main', name: 'Main stream', encoding: 'H.265', width: 2560, height: 1440, fps: 15, bitrate: 2048),
        VideoEncoder(token: 'sub', name: 'Sub stream', encoding: 'H.264', width: 768, height: 432, fps: 15, bitrate: 512),
      ],
      image: const ImageSettings(
        brightness: 50,
        contrast: 50,
        saturation: 50,
        sharpness: 50,
        irCut: 'AUTO',
        irCutModes: ['AUTO', 'ON', 'OFF'],
      ),
      motion: const MotionSettings(enabled: true, sensitivity: 60),
    );
  });

  @override
  Future<void> updateMotion(String cameraId, MotionSettings motion) => store.delay(() {});

  @override
  Future<void> updateImage(String cameraId, ImageSettings image) => store.delay(() {});

  @override
  Future<void> syncClock(String cameraId) => store.delay(() {});

  @override
  Future<void> reboot(String cameraId) => store.delay(() {});
}
