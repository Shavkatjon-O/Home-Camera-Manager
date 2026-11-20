import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:smart_surveillance/app/demo/fake_store.dart';
import 'package:smart_surveillance/core/media/media_source.dart';
import 'package:smart_surveillance/core/network/failure.dart';
import 'package:smart_surveillance/features/analytics/domain/analytics_repository.dart';
import 'package:smart_surveillance/features/analytics/domain/models.dart';
import 'package:smart_surveillance/features/insights/domain/models.dart';
import 'package:smart_surveillance/features/investigation/domain/models.dart';

/// An in-memory [AnalyticsRepository] backed by demo data.
class FakeAnalyticsRepository implements AnalyticsRepository {
  /// Creates a repository reading and writing [store].
  FakeAnalyticsRepository(this.store);

  /// The demo data store this repository works on.
  final FakeStore store;

  @override
  Future<List<AnalyticsView>> views(String siteId) => store.delay(
    () => store.data.views
        .where((v) => store.data.camera(v.cameraId).camera.siteId == siteId)
        .toList(),
  );

  @override
  Future<AnalyticsView> view(String viewId) =>
      store.delay(() => store.data.views.firstWhere((v) => v.id == viewId));

  @override
  Future<AnalyticsView> updateView(AnalyticsView view) => store.delay(() {
    final index = store.data.views.indexWhere((v) => v.id == view.id);
    store.data.views[index] = view;
    return view;
  });

  @override
  Future<AnalyticsView> saveRules(
    String viewId, {
    required List<Zone> zones,
    required List<Line> lines,
  }) => store.delay(() {
    final index = store.data.views.indexWhere((v) => v.id == viewId);
    var next = 0;
    final view = store.data.views[index].copyWith(
      zones: [
        for (final zone in zones) zone.id == null ? zone.copyWith(id: 'zone-new-${next++}') : zone,
      ],
      lines: [
        for (final line in lines) line.id == null ? line.copyWith(id: 'line-new-${next++}') : line,
      ],
    );
    store.data.views[index] = view;
    return view;
  });

  @override
  Future<MediaSource> viewSnapshot(String viewId) => store.delay(() {
    final view = store.data.views.firstWhere((v) => v.id == viewId);
    return store.sceneFor(view.cameraId, view.lens);
  });

  @override
  Stream<List<LiveObject>> liveObjects(String viewId) async* {
    final view = store.data.views.firstWhere((v) => v.id == viewId);
    var t = 0.0;
    while (true) {
      final x = 0.2 + 0.5 * (0.5 + 0.5 * sin(t));
      yield [
        LiveObject(
          track: 41,
          label: 'person',
          box: Rect.fromLTWH(x, 0.4, 0.1, 0.38),
          name: view.faces ? 'Alex' : null,
        ),
        if (view.profile == Profile.vehicle)
          const LiveObject(track: 12, label: 'car', box: Rect.fromLTWH(0.56, 0.52, 0.3, 0.24)),
      ];
      if (!store.live) return;
      await Future<void>.delayed(const Duration(milliseconds: 400));
      t += 0.12;
    }
  }

  @override
  Future<CountsReport> counts(
    String siteId, {
    required DateTime start,
    required DateTime end,
    required Bucket bucket,
  }) => store.delay(() => store.data.counts(siteId, start, end, bucket));

  @override
  Future<List<Area>> areas(String siteId) =>
      store.delay(() => List.of(store.data.areas[siteId] ?? const []));

  @override
  Future<Area> resetArea(String areaId, int occupancy) => store.delay(() {
    for (final list in store.data.areas.values) {
      final index = list.indexWhere((a) => a.id == areaId);
      if (index >= 0) {
        final area = list[index].copyWith(
          occupancy: occupancy,
          entered: 0,
          exited: 0,
          since: store.clock(),
        );
        list[index] = area;
        return area;
      }
    }
    throw const ApiFailure(FailureKind.notFound);
  });

  @override
  Future<Journey?> journey(String eventId) => store.delay(() {
    final event = store.data.events.firstWhere((e) => e.id == eventId);
    if (!event.personLike) return null;
    final at = event.startedAt;
    return Journey(
      id: 'journey-$eventId',
      description: 'Front gate, then Driveway, then ${event.cameraName}',
      startedAt: at.subtract(const Duration(minutes: 2, seconds: 40)),
      endedAt: at.add(const Duration(seconds: 20)),
      steps: [
        JourneyStep(
          cameraName: 'Front gate',
          viewName: 'Front gate',
          startedAt: at.subtract(const Duration(minutes: 2, seconds: 40)),
          endedAt: at.subtract(const Duration(minutes: 2, seconds: 5)),
          similarity: 0.71,
        ),
        JourneyStep(
          cameraName: 'Driveway',
          viewName: 'Driveway',
          startedAt: at.subtract(const Duration(minutes: 1, seconds: 50)),
          endedAt: at.subtract(const Duration(minutes: 1, seconds: 12)),
          similarity: 0.58,
        ),
        JourneyStep(
          cameraName: event.cameraName,
          viewName: event.viewName,
          startedAt: at,
          endedAt: at.add(const Duration(seconds: 20)),
          eventId: event.id,
        ),
      ],
    );
  });

  @override
  Future<List<AppearanceMatch>> findPerson(String eventId) => store.delay(() {
    final event = store.data.events.firstWhere((e) => e.id == eventId);
    final others = store.data.events
        .where((e) => e.id != eventId && e.label == 'person' && e.siteId == event.siteId)
        .take(5)
        .toList();
    var score = 0.74;
    return [
      for (final other in others)
        AppearanceMatch(
          id: 'match-${other.id}',
          cameraName: other.cameraName,
          viewName: other.viewName,
          startedAt: other.startedAt,
          endedAt: other.endedAt ?? other.startedAt,
          similarity: score -= 0.07,
          eventId: other.id,
          thumbnail: store.eventScene(other),
        ),
    ];
  });
}
