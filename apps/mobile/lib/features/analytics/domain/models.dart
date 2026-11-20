import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_surveillance/features/devices/domain/models.dart';

part 'models.freezed.dart';

/// The detection profile a camera view runs.
enum Profile {
  /// Watches for people and animals around the property.
  perimeter,

  /// Watches for vehicles.
  vehicle,

  /// Watches for a person's presence.
  identity,

  /// Watches only for camera tampering.
  tamper,
}

/// A ready-made analytics setup offered when a camera is first configured.
enum AnalyticsPreset {
  /// Raises alerts when people or vehicles appear in the view, mostly at night.
  perimeter,

  /// Counts who comes in and out through a door or gate.
  entrance,

  /// Counts people and occupancy without raising alerts.
  counting,

  /// Watches only for the camera being covered or moved.
  tamperOnly,
}

/// How a zone or line raises alerts.
enum AlertMode {
  /// Never alerts.
  off,

  /// Alerts at any time.
  always,

  /// Alerts only inside the configured time windows.
  schedule,
}

/// How a zone or line treats animals.
enum AnimalMode {
  /// Animals are detected and alerted on like any other object.
  include,

  /// Animals are recorded in the event history without alerts.
  record,

  /// Animals are ignored.
  exclude,
}

/// Which crossing direction of a line counts.
enum LineDirection {
  /// Only crossings into the property count.
  inward,

  /// Only crossings out of the property count.
  outward,

  /// Crossings in both directions count.
  both,
}

/// The object kinds a zone or line can be set to detect.
const detectionLabels = ['person', 'car', 'truck', 'bus', 'motorcycle', 'bicycle', 'dog', 'cat'];

/// The carried or left-behind object kinds a zone can watch for.
const objectLabels = ['backpack', 'handbag', 'suitcase', 'bicycle', 'car'];

/// A recurring period of the week during which alerts are active.
@freezed
abstract class TimeWindow with _$TimeWindow {
  /// Creates a window from [start] to [end] on the given [days].
  const factory TimeWindow({
    required String start,
    required String end,
    @Default(<int>[0, 1, 2, 3, 4, 5, 6]) List<int> days,
  }) = _TimeWindow;
}

/// The rules deciding when and for what an alert is raised.
@freezed
abstract class AlertPolicy with _$AlertPolicy {
  /// Creates an alert policy with a [mode], an optional [schedule] and the [labels] it covers.
  const factory AlertPolicy({
    @Default(AlertMode.always) AlertMode mode,
    @Default(<TimeWindow>[]) List<TimeWindow> schedule,
    @Default(<String>['person']) List<String> labels,
  }) = _AlertPolicy;
}

/// A polygon drawn on a camera view where detections are watched.
@freezed
abstract class Zone with _$Zone {
  /// Creates a zone named [name] covering [polygon] in normalized view coordinates.
  const factory Zone({
    String? id,
    required String name,
    required List<Offset> polygon,
    @Default(false) bool wholeView,
    @Default(<String>['person']) List<String> labels,
    @Default(1.0) double minDwell,
    @Default(0.0) double loiterSeconds,
    @Default(0) int crowdCount,
    @Default(AlertPolicy()) AlertPolicy alert,
    @Default(true) bool enabled,
    @Default(false) bool suspended,
    @Default(0.0) double leftSeconds,
    @Default(0.0) double takenSeconds,
    @Default(<String>[]) List<String> objectLabels,
    @Default(AnimalMode.record) AnimalMode animals,
  }) = _Zone;
}

/// A line drawn on a camera view that counts crossings.
@freezed
abstract class Line with _$Line {
  /// Creates a line named [name] running from point [a] to point [b].
  const factory Line({
    String? id,
    required String name,
    required Offset a,
    required Offset b,
    @Default(<String>['person']) List<String> labels,
    @Default(LineDirection.both) LineDirection direction,
    @Default(AlertPolicy(mode: AlertMode.off)) AlertPolicy alert,
    @Default(true) bool enabled,
    @Default(false) bool suspended,
    @Default(AnimalMode.record) AnimalMode animals,
  }) = _Line;
}

/// The analytics configuration of one camera lens, with its zones and lines.
@freezed
abstract class AnalyticsView with _$AnalyticsView {
  const AnalyticsView._();

  /// Creates a view of lens [lens] of camera [cameraId] with the given [profile] and feature flags.
  const factory AnalyticsView({
    required String id,
    required String cameraId,
    required String cameraName,
    required int lens,
    required int lenses,
    required String name,
    @Default(Profile.perimeter) Profile profile,
    @Default(true) bool enabled,
    @Default(StreamQuality.sub) StreamQuality stream,
    @Default(8.0) double fps,
    @Default(true) bool tamper,
    @Default(false) bool faces,
    @Default(false) bool moving,
    @Default(true) bool appearance,
    @Default(false) bool falls,
    @Default(false) bool plates,
    @Default(false) bool follow,
    @Default(false) bool ptz,
    @Default(<Zone>[]) List<Zone> zones,
    @Default(<Line>[]) List<Line> lines,
    @Default(false) bool suspended,
    double? fpsMeasured,
  }) = _AnalyticsView;

  /// The view's display name, including the lens number when the camera has several lenses.
  String get title => lenses > 1 ? '$cameraName, lens ${lens + 1}' : cameraName;
}

/// A detected object currently tracked in the live view.
@freezed
abstract class LiveObject with _$LiveObject {
  /// Creates a live object with tracker id [track], class [label] and bounding [box].
  const factory LiveObject({
    required int track,
    required String label,
    required Rect box,
    String? name,
  }) = _LiveObject;
}
