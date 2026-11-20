import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_surveillance/features/devices/domain/models.dart';

part 'models.freezed.dart';
enum Profile { perimeter, vehicle, identity, tamper }

enum AnalyticsPreset { perimeter, entrance, counting, tamperOnly }

enum AlertMode { off, always, schedule }

enum AnimalMode { include, record, exclude }

enum LineDirection { inward, outward, both }

const detectionLabels = ['person', 'car', 'truck', 'bus', 'motorcycle', 'bicycle', 'dog', 'cat'];

const objectLabels = ['backpack', 'handbag', 'suitcase', 'bicycle', 'car'];

@freezed
abstract class TimeWindow with _$TimeWindow {
  const factory TimeWindow({
    required String start,
    required String end,
    @Default(<int>[0, 1, 2, 3, 4, 5, 6]) List<int> days,
  }) = _TimeWindow;
}

@freezed
abstract class AlertPolicy with _$AlertPolicy {
  const factory AlertPolicy({
    @Default(AlertMode.always) AlertMode mode,
    @Default(<TimeWindow>[]) List<TimeWindow> schedule,
    @Default(<String>['person']) List<String> labels,
  }) = _AlertPolicy;
}

@freezed
abstract class Zone with _$Zone {
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

@freezed
abstract class Line with _$Line {
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

@freezed
abstract class AnalyticsView with _$AnalyticsView {
  const AnalyticsView._();

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

  String get title => lenses > 1 ? '$cameraName, lens ${lens + 1}' : cameraName;
}

@freezed
abstract class LiveObject with _$LiveObject {
  const factory LiveObject({
    required int track,
    required String label,
    required Rect box,
    String? name,
  }) = _LiveObject;
}
