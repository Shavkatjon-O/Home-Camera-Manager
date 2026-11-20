import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';

/// What kind of thing an event reports.
enum EventKind {
  /// Movement was detected in the view.
  motion,

  /// A person was detected.
  person,

  /// A vehicle was detected.
  vehicle,

  /// Something entered a watched zone.
  intrusion,

  /// Something crossed a watched line.
  lineCrossing,

  /// Someone stayed in a zone longer than allowed.
  loitering,

  /// A zone holds more people than allowed.
  crowd,

  /// A known person's face was recognized.
  faceKnown,

  /// An unrecognized face was seen.
  faceUnknown,

  /// The camera was covered, moved or lost its picture.
  tamper,

  /// The recording storage has a problem.
  storage,

  /// The camera restarted.
  reboot,

  /// An animal was detected.
  animal,

  /// An object was left behind in a zone.
  objectLeft,

  /// An object was taken from a zone.
  objectTaken,

  /// A person fell.
  fall;

  /// Whether the kind is still a beta feature.
  bool get beta => this == fall;

  /// Whether the kind belongs to the features planned for the second release.
  bool get release2 => const {faceKnown, faceUnknown, objectLeft, objectTaken, fall}.contains(this);
}

/// Where an event came from.
enum EventSource {
  /// The camera's own detection.
  camera,

  /// The app's analytics running on the camera's picture.
  analytics,
}

/// Whether a detected face matched a known person.
enum FaceStatus {
  /// The face matches a saved person.
  known,

  /// The face matches no saved person.
  unknown,
}

/// A bounding box of one object inside an event's snapshot or clip.
@freezed
abstract class EventBox with _$EventBox {
  /// Creates a box for [object] named [label] at [box], [at] seconds into the clip.
  const factory EventBox({
    required int object,
    required String label,
    required Rect box,
    @Default(0.0) double at,
  }) = _EventBox;
}

/// One possible reading of a license plate.
@freezed
abstract class PlateCandidate with _$PlateCandidate {
  /// Creates a candidate reading [text], shown as [display], seen in [reads] frames with [score].
  const factory PlateCandidate({
    required String text,
    required String display,
    String? format,
    required double score,
    required int reads,
  }) = _PlateCandidate;
}

/// What is known about the face in an event.
@freezed
abstract class FaceInfo with _$FaceInfo {
  /// Creates face information with the given [status] and the matched person or cluster, if any.
  const factory FaceInfo({
    required FaceStatus status,
    String? personId,
    String? personName,
    int? personColor,
    String? clusterId,
    String? clusterLabel,
    double? confidence,
    String? sampleId,
  }) = _FaceInfo;
}

/// One detected happening on a camera, such as a person or a tamper alert.
@freezed
abstract class CameraEvent with _$CameraEvent {
  const CameraEvent._();

  /// Creates an event [id] of the given [kind] that started at [startedAt] on camera [cameraId].
  const factory CameraEvent({
    required String id,
    required String siteId,
    required String cameraId,
    required String cameraName,
    String? viewId,
    String? viewName,
    required EventKind kind,
    required EventSource source,
    String? label,
    @Default(false) bool alert,
    @Default(false) bool acknowledged,
    required DateTime startedAt,
    DateTime? endedAt,
    @Default(false) bool ongoing,
    @Default(true) bool hasSnapshot,
    @Default(false) bool hasClip,
    String? zoneName,
    String? lineName,
    String? direction,
    @Default(<EventBox>[]) List<EventBox> boxes,
    int? count,
    String? profile,
    @Default(<PlateCandidate>[]) List<PlateCandidate> plates,
    String? plateStatus,
    FaceInfo? face,
    @Default(16 / 9) double aspect,
  }) = _CameraEvent;

  /// The time the event has lasted, up to now while it is still ongoing.
  Duration get duration => (endedAt ?? DateTime.now()).difference(startedAt);

  /// Whether a plate was read or a read is pending or failed.
  bool get hasPlates => plates.isNotEmpty || plateStatus != null;

  /// Whether the event concerns a person, by label or by a face kind.
  bool get personLike =>
      label == 'person' || kind == EventKind.faceKnown || kind == EventKind.faceUnknown;
}

/// The choices a user applied to narrow the event list.
@freezed
abstract class EventFilter with _$EventFilter {
  const EventFilter._();

  /// Creates a filter; every field left at its default does not narrow the list.
  const factory EventFilter({
    DateTime? day,
    @Default(<String>{}) Set<String> cameraIds,
    @Default(<String>{}) Set<String> viewIds,
    @Default(<EventKind>{}) Set<EventKind> kinds,
    @Default(<String>{}) Set<String> labels,
    @Default(<String>{}) Set<String> zones,
    @Default(<String>{}) Set<String> lines,
    String? personId,
    String? clusterId,
    String? plate,
    @Default(false) bool alertsOnly,
    DateTime? from,
    DateTime? until,
  }) = _EventFilter;

  /// The number of filter groups currently narrowing the list.
  int get activeCount =>
      (day != null ? 1 : 0) +
      (cameraIds.isNotEmpty ? 1 : 0) +
      (viewIds.isNotEmpty ? 1 : 0) +
      (kinds.isNotEmpty ? 1 : 0) +
      (labels.isNotEmpty ? 1 : 0) +
      (zones.isNotEmpty ? 1 : 0) +
      (lines.isNotEmpty ? 1 : 0) +
      (personId != null || clusterId != null ? 1 : 0) +
      (plate != null && plate!.isNotEmpty ? 1 : 0) +
      (alertsOnly ? 1 : 0) +
      (from != null || until != null ? 1 : 0);
}

/// One page of events from a paged list.
@freezed
abstract class EventPage with _$EventPage {
  /// Creates a page of [items] numbered [page], with [total] events overall in pages of [pageSize].
  const factory EventPage({
    required List<CameraEvent> items,
    required int total,
    required int page,
    required int pageSize,
  }) = _EventPage;
}

/// Totals of the events matching a filter.
@freezed
abstract class EventCounts with _$EventCounts {
  /// Creates counts of events, alerts and events not yet acknowledged, split by kind and label.
  const factory EventCounts({
    @Default(0) int total,
    @Default(0) int alerts,
    @Default(0) int unacknowledged,
    @Default(<EventKind, int>{}) Map<EventKind, int> kinds,
    @Default(<String, int>{}) Map<String, int> labels,
  }) = _EventCounts;
}

/// A change pushed from the server while the app is open.
sealed class LiveUpdate {
  const LiveUpdate();
}

/// An event was created or updated.
class EventChanged extends LiveUpdate {
  /// Creates an update for [event], with [created] set when it is new.
  const EventChanged(this.event, {this.created = false});

  /// The event that changed.
  final CameraEvent event;

  /// Whether the event is new rather than updated.
  final bool created;
}

/// The site's arm state changed.
class ArmChanged extends LiveUpdate {
  /// Creates an update for the site [siteId].
  const ArmChanged(this.siteId);

  /// The site whose arm state changed.
  final String siteId;
}

/// A camera went online or offline.
class CameraStatusChanged extends LiveUpdate {
  /// Creates an update saying camera [cameraId] is [online] or not.
  const CameraStatusChanged(this.cameraId, this.online);

  /// The camera whose status changed.
  final String cameraId;

  /// Whether the camera is now online.
  final bool online;
}
