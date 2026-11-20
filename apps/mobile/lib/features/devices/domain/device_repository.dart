
import 'package:smart_surveillance/features/devices/domain/models.dart';
abstract interface class DeviceRepository {
  Future<List<Connector>> connectors(String siteId);

  Future<void> removeConnector(String connectorId);

  Future<List<DiscoveredCamera>> discovered(String connectorId, {bool rescan = false});

  Future<StreamTest> testCamera({
    required String connectorId,
    required DiscoveredCamera camera,
    String? username,
    String? password,
  });

  Future<Camera> addCamera({
    required String siteId,
    required String connectorId,
    required DiscoveredCamera camera,
    required String name,
    String? username,
    String? password,
    required int lenses,
  });

  Future<List<Camera>> cameras(String siteId);

  Future<Camera> updateCamera(Camera camera);

  Future<void> deleteCamera(String cameraId);

  Future<void> orderCameras(String siteId, List<String> cameraIds);

  Future<CameraControls> controls(String cameraId);

  Future<void> move(String cameraId, {required double pan, required double tilt, required double zoom});

  Future<void> stop(String cameraId);

  Future<void> gotoPreset(String cameraId, String token);

  Future<PtzPreset> savePreset(String cameraId, String name);

  Future<void> gotoHome(String cameraId);

  Future<void> setLight(String cameraId, bool on);

  Future<void> sirenFor(String cameraId, Duration duration);

  Future<CameraSettings> settings(String cameraId);

  Future<void> updateMotion(String cameraId, MotionSettings motion);

  Future<void> updateImage(String cameraId, ImageSettings image);

  Future<void> syncClock(String cameraId);

  Future<void> reboot(String cameraId);
}
