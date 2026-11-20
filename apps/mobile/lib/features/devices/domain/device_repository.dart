import 'package:smart_surveillance/features/devices/domain/models.dart';

/// Manages connectors and cameras of a site and controls camera hardware.
abstract interface class DeviceRepository {
  /// Returns the connectors of the site [siteId].
  Future<List<Connector>> connectors(String siteId);

  /// Removes the connector [connectorId].
  Future<void> removeConnector(String connectorId);

  /// Returns the cameras a connector found on its network, scanning again when [rescan] is true.
  Future<List<DiscoveredCamera>> discovered(String connectorId, {bool rescan = false});

  /// Tests whether [camera] streams through [connectorId], optionally with [username] and
  /// [password].
  Future<StreamTest> testCamera({
    required String connectorId,
    required DiscoveredCamera camera,
    String? username,
    String? password,
  });

  /// Adds [camera] found by [connectorId] to the site [siteId] as [name] with [lenses] lenses.
  Future<Camera> addCamera({
    required String siteId,
    required String connectorId,
    required DiscoveredCamera camera,
    required String name,
    String? username,
    String? password,
    required int lenses,
  });

  /// Returns the cameras of the site [siteId].
  Future<List<Camera>> cameras(String siteId);

  /// Saves [camera] and returns the stored camera.
  Future<Camera> updateCamera(Camera camera);

  /// Deletes the camera [cameraId].
  Future<void> deleteCamera(String cameraId);

  /// Saves the display order of the site's cameras as the ids in [cameraIds].
  Future<void> orderCameras(String siteId, List<String> cameraIds);

  /// Returns what the camera [cameraId] can do, such as pan, tilt, light and siren.
  Future<CameraControls> controls(String cameraId);

  /// Moves the camera [cameraId] by [pan], [tilt] and [zoom] speeds until [stop] is called.
  Future<void> move(
    String cameraId, {
    required double pan,
    required double tilt,
    required double zoom,
  });

  /// Stops any movement of the camera [cameraId].
  Future<void> stop(String cameraId);

  /// Points the camera [cameraId] at the saved preset identified by [token].
  Future<void> gotoPreset(String cameraId, String token);

  /// Saves the current view of the camera [cameraId] as a preset called [name].
  Future<PtzPreset> savePreset(String cameraId, String name);

  /// Returns the camera [cameraId] to its home position.
  Future<void> gotoHome(String cameraId);

  /// Turns the light of the camera [cameraId] on or off according to [on].
  Future<void> setLight(String cameraId, bool on);

  /// Sounds the siren of the camera [cameraId] for [duration].
  Future<void> sirenFor(String cameraId, Duration duration);

  /// Returns the motion and image settings of the camera [cameraId].
  Future<CameraSettings> settings(String cameraId);

  /// Saves the motion detection settings [motion] of the camera [cameraId].
  Future<void> updateMotion(String cameraId, MotionSettings motion);

  /// Saves the image settings [image] of the camera [cameraId].
  Future<void> updateImage(String cameraId, ImageSettings image);

  /// Sets the clock of the camera [cameraId] to the current time.
  Future<void> syncClock(String cameraId);

  /// Restarts the camera [cameraId].
  Future<void> reboot(String cameraId);
}
