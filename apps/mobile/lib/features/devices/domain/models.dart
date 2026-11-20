import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_surveillance/core/media/media_source.dart';

part 'models.freezed.dart';
/// Whether a connector is reachable.
enum ConnectorState {
  /// The connector is reachable.
  online,
  /// The connector cannot be reached.
  offline,
  /// The connector is waiting to be paired.
  pairing,
}

/// The make of a camera, which decides how it is reached.
enum CameraBrand {
  /// An EZVIZ camera.
  ezviz,
  /// A V380 camera.
  v380,
  /// Any ONVIF-compatible camera.
  onvif,
  /// A camera reached by a plain RTSP address.
  rtsp,
}

/// Which of a camera's two streams is used.
enum StreamQuality {
  /// The full-resolution stream.
  main,
  /// The lighter, lower-resolution stream.
  sub,
}

/// A device on the site's network that bridges its cameras to the service.
@freezed
abstract class Connector with _$Connector {
  /// Creates the connector [id] named [name] for the site [siteId] in [state].
  const factory Connector({
    required String id,
    required String siteId,
    required String name,
    required ConnectorState state,
    String? version,
    DateTime? lastSeenAt,
    @Default('direct') String mode,
    @Default(0) int cameraCount,
  }) = _Connector;
}

/// The pairing code that a new connector shows during setup.
@freezed
abstract class ConnectorCode with _$ConnectorCode {
  /// Creates a code with the pairing [code] and the connector's name [connectorName].
  const factory ConnectorCode({required String code, String? connectorName}) = _ConnectorCode;
}

/// A camera a connector found on the network but that is not yet added.
@freezed
abstract class DiscoveredCamera with _$DiscoveredCamera {
  /// Creates a discovered camera [id] reachable at [host] on [ports].
  const factory DiscoveredCamera({
    required String id,
    required String host,
    required List<int> ports,
    CameraBrand? brand,
    String? manufacturer,
    String? model,
    int? onvifPort,
    @Default(false) bool ptz,
    @Default(false) bool nvr,
    @Default('probe') String foundBy,
    int? rtspPort,
    String? mainPath,
    String? cameraId,
  }) = _DiscoveredCamera;
}

/// The result of trying to open a camera's stream.
@freezed
abstract class StreamTest with _$StreamTest {
  /// Creates a result where [ok] tells whether the stream played.
  const factory StreamTest({
    required bool ok,
    String? error,
    String? codec,
    int? width,
    int? height,
    @Default(1) int lenses,
    MediaSource? preview,
  }) = _StreamTest;
}

/// The actions a camera supports.
@freezed
abstract class CameraCapabilities with _$CameraCapabilities {
  /// Creates capabilities with every action off unless given.
  const factory CameraCapabilities({
    @Default(false) bool ptz,
    @Default(false) bool zoom,
    @Default(false) bool presets,
    @Default(false) bool home,
    @Default(false) bool light,
    @Default(false) bool siren,
    @Default(false) bool audio,
    @Default(false) bool twoWayAudio,
    @Default(false) bool playback,
    @Default(false) bool settings,
    @Default(false) bool reboot,
  }) = _CameraCapabilities;
}

/// A camera that belongs to a site.
@freezed
abstract class Camera with _$Camera {
  const Camera._();

  /// Creates the camera [id] named [name] of [brand] in the site [siteId].
  const factory Camera({
    required String id,
    required String siteId,
    required String name,
    required CameraBrand brand,
    String? connectorId,
    String? model,
    @Default(1) int lenses,
    @Default(CameraCapabilities()) CameraCapabilities capabilities,
    @Default(true) bool enabled,
    @Default(0) int position,
    bool? online,
    DateTime? checkedAt,
    String? error,
    @Default(true) bool hasSub,
    @Default(16 / 9) double aspect,
  }) = _Camera;

  /// Whether the camera can pan and tilt.
  bool get ptz => capabilities.ptz;
}

/// One lens of a camera as shown in the camera grid.
@freezed
abstract class CameraTile with _$CameraTile {
  const CameraTile._();

  /// Creates the tile for [lens] of [camera], optionally with a saved view [viewId].
  const factory CameraTile({
    required Camera camera,
    required int lens,
    String? viewId,
  }) = _CameraTile;

  /// The unique key of the tile, made of the camera id and the lens.
  String get key => '${camera.id}:$lens';

  /// Whether the camera has several lenses shown as separate tiles.
  bool get split => camera.lenses > 1;

  /// The width to height ratio of the tile's picture.
  double get aspect => camera.aspect * camera.lenses;
}

/// A saved pan and tilt position of a camera.
@freezed
abstract class PtzPreset with _$PtzPreset {
  /// Creates a preset with the [token] that selects it and the display [name].
  const factory PtzPreset({required String token, required String name}) = _PtzPreset;
}

/// The preset positions and light state of a camera.
@freezed
abstract class CameraControls with _$CameraControls {
  /// Creates controls with the given presets.
  const factory CameraControls({
    @Default(<PtzPreset>[]) List<PtzPreset> presets,
    @Default(false) bool light,
  }) = _CameraControls;
}

/// The hardware details of a camera.
@freezed
abstract class CameraDevice with _$CameraDevice {
  /// Creates device details, all optional.
  const factory CameraDevice({
    String? manufacturer,
    String? model,
    String? firmware,
    double? clockOffsetSeconds,
    String? timezone,
    @Default(false) bool canReboot,
  }) = _CameraDevice;
}

/// One video encoding configuration of a camera.
@freezed
abstract class VideoEncoder with _$VideoEncoder {
  /// Creates an encoder with the [token] that identifies it and the display [name].
  const factory VideoEncoder({
    required String token,
    required String name,
    String? encoding,
    int? width,
    int? height,
    double? fps,
    int? bitrate,
  }) = _VideoEncoder;
}

/// The picture adjustments of a camera.
@freezed
abstract class ImageSettings with _$ImageSettings {
  /// Creates image settings, all optional.
  const factory ImageSettings({
    double? brightness,
    double? contrast,
    double? saturation,
    double? sharpness,
    String? irCut,
    @Default(<String>[]) List<String> irCutModes,
  }) = _ImageSettings;
}

/// The motion detection settings of a camera.
@freezed
abstract class MotionSettings with _$MotionSettings {
  /// Creates motion settings with a sensitivity range from [min] to [max].
  const factory MotionSettings({
    bool? enabled,
    int? sensitivity,
    @Default(0) int min,
    @Default(100) int max,
  }) = _MotionSettings;
}

/// The device, encoder, image and motion settings of a camera.
@freezed
abstract class CameraSettings with _$CameraSettings {
  /// Creates settings for the camera [device].
  const factory CameraSettings({
    required CameraDevice device,
    @Default(<VideoEncoder>[]) List<VideoEncoder> encoders,
    ImageSettings? image,
    MotionSettings? motion,
  }) = _CameraSettings;
}
