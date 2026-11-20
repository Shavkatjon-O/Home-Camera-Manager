import 'package:freezed_annotation/freezed_annotation.dart';

import 'media.dart';

part 'camera.freezed.dart';

enum ConnectorState { online, offline, pairing }

enum CameraBrand { ezviz, v380, onvif, rtsp }

enum StreamQuality { main, sub }

@freezed
abstract class Connector with _$Connector {
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

@freezed
abstract class ConnectorCode with _$ConnectorCode {
  const factory ConnectorCode({required String code, String? connectorName}) = _ConnectorCode;
}

@freezed
abstract class DiscoveredCamera with _$DiscoveredCamera {
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

@freezed
abstract class StreamTest with _$StreamTest {
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

@freezed
abstract class CameraCapabilities with _$CameraCapabilities {
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

@freezed
abstract class Camera with _$Camera {
  const Camera._();

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

  bool get ptz => capabilities.ptz;
}

@freezed
abstract class CameraTile with _$CameraTile {
  const CameraTile._();

  const factory CameraTile({
    required Camera camera,
    required int lens,
    String? viewId,
  }) = _CameraTile;

  String get key => '${camera.id}:$lens';

  bool get split => camera.lenses > 1;

  double get aspect => camera.aspect * camera.lenses;
}

@freezed
abstract class PtzPreset with _$PtzPreset {
  const factory PtzPreset({required String token, required String name}) = _PtzPreset;
}

@freezed
abstract class CameraControls with _$CameraControls {
  const factory CameraControls({
    @Default(<PtzPreset>[]) List<PtzPreset> presets,
    @Default(false) bool light,
  }) = _CameraControls;
}

@freezed
abstract class CameraDevice with _$CameraDevice {
  const factory CameraDevice({
    String? manufacturer,
    String? model,
    String? firmware,
    double? clockOffsetSeconds,
    String? timezone,
    @Default(false) bool canReboot,
  }) = _CameraDevice;
}

@freezed
abstract class VideoEncoder with _$VideoEncoder {
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

@freezed
abstract class ImageSettings with _$ImageSettings {
  const factory ImageSettings({
    double? brightness,
    double? contrast,
    double? saturation,
    double? sharpness,
    String? irCut,
    @Default(<String>[]) List<String> irCutModes,
  }) = _ImageSettings;
}

@freezed
abstract class MotionSettings with _$MotionSettings {
  const factory MotionSettings({
    bool? enabled,
    int? sensitivity,
    @Default(0) int min,
    @Default(100) int max,
  }) = _MotionSettings;
}

@freezed
abstract class CameraSettings with _$CameraSettings {
  const factory CameraSettings({
    required CameraDevice device,
    @Default(<VideoEncoder>[]) List<VideoEncoder> encoders,
    ImageSettings? image,
    MotionSettings? motion,
  }) = _CameraSettings;
}
