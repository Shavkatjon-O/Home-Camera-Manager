import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'event.freezed.dart';

enum EventKind {
  motion,
  person,
  vehicle,
  intrusion,
  lineCrossing,
  loitering,
  crowd,
  faceKnown,
  faceUnknown,
  tamper,
  storage,
  reboot,
  animal,
  objectLeft,
  objectTaken,
  fall;

  bool get beta => this == fall;

  bool get release2 => const {faceKnown, faceUnknown, objectLeft, objectTaken, fall}.contains(this);
}

enum EventSource { camera, analytics }

enum FaceStatus { known, unknown }

@freezed
abstract class EventBox with _$EventBox {
  const factory EventBox({
    required int object,
    required String label,
    required Rect box,
    @Default(0.0) double at,
  }) = _EventBox;
}

@freezed
abstract class PlateCandidate with _$PlateCandidate {
  const factory PlateCandidate({
    required String text,
    required String display,
    String? format,
    required double score,
    required int reads,
  }) = _PlateCandidate;
}

@freezed
abstract class FaceInfo with _$FaceInfo {
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

@freezed
abstract class CameraEvent with _$CameraEvent {
  const CameraEvent._();

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

  Duration get duration => (endedAt ?? DateTime.now()).difference(startedAt);

  bool get hasPlates => plates.isNotEmpty || plateStatus != null;

  bool get personLike => label == 'person' || kind == EventKind.faceKnown || kind == EventKind.faceUnknown;
}

@freezed
abstract class EventFilter with _$EventFilter {
  const EventFilter._();

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

@freezed
abstract class EventPage with _$EventPage {
  const factory EventPage({
    required List<CameraEvent> items,
    required int total,
    required int page,
    required int pageSize,
  }) = _EventPage;
}

@freezed
abstract class EventCounts with _$EventCounts {
  const factory EventCounts({
    @Default(0) int total,
    @Default(0) int alerts,
    @Default(0) int unacknowledged,
    @Default(<EventKind, int>{}) Map<EventKind, int> kinds,
    @Default(<String, int>{}) Map<String, int> labels,
  }) = _EventCounts;
}

@freezed
abstract class SearchFacets with _$SearchFacets {
  const factory SearchFacets({
    @Default(<FacetItem>[]) List<FacetItem> views,
    @Default(<FacetItem>[]) List<FacetItem> zones,
    @Default(<FacetItem>[]) List<FacetItem> lines,
    @Default(<FacetItem>[]) List<FacetItem> people,
    @Default(<FacetItem>[]) List<FacetItem> clusters,
    @Default(<String>[]) List<String> labels,
  }) = _SearchFacets;
}

@freezed
abstract class FacetItem with _$FacetItem {
  const factory FacetItem({required String id, required String name, String? detail}) = _FacetItem;
}

sealed class LiveUpdate {
  const LiveUpdate();
}

class EventChanged extends LiveUpdate {
  const EventChanged(this.event, {this.created = false});

  final CameraEvent event;
  final bool created;
}

class ArmChanged extends LiveUpdate {
  const ArmChanged(this.siteId);

  final String siteId;
}

class CameraStatusChanged extends LiveUpdate {
  const CameraStatusChanged(this.cameraId, this.online);

  final String cameraId;
  final bool online;
}
