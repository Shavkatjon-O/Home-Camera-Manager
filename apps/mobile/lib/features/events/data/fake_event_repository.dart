import 'dart:async';
import 'dart:math';

import 'package:smart_surveillance/app/demo/fake_store.dart';
import 'package:smart_surveillance/core/media/media_source.dart';
import 'package:smart_surveillance/core/network/failure.dart';
import 'package:smart_surveillance/features/events/domain/event_repository.dart';
import 'package:smart_surveillance/features/events/domain/models.dart';
import 'package:smart_surveillance/features/media/domain/media_repository.dart';
class FakeEventRepository implements EventRepository {
  FakeEventRepository(this.store);

  final FakeStore store;

  bool matches(CameraEvent event, EventFilter filter) {
    if (filter.day != null) {
      final day = filter.day!;
      final start = DateTime(day.year, day.month, day.day);
      if (event.startedAt.isBefore(start) || !event.startedAt.isBefore(start.add(const Duration(days: 1)))) {
        return false;
      }
    }
    if (filter.from != null && event.startedAt.isBefore(filter.from!)) return false;
    if (filter.until != null && event.startedAt.isAfter(filter.until!)) return false;
    if (filter.cameraIds.isNotEmpty && !filter.cameraIds.contains(event.cameraId)) return false;
    if (filter.viewIds.isNotEmpty && !filter.viewIds.contains(event.viewId)) return false;
    if (filter.kinds.isNotEmpty && !filter.kinds.contains(event.kind)) return false;
    if (filter.labels.isNotEmpty && !filter.labels.contains(event.label)) return false;
    if (filter.zones.isNotEmpty && !filter.zones.contains(event.zoneName)) return false;
    if (filter.lines.isNotEmpty && !filter.lines.contains(event.lineName)) return false;
    if (filter.alertsOnly && !event.alert) return false;
    if (filter.personId != null && event.face?.personId != filter.personId) return false;
    if (filter.clusterId != null && event.face?.clusterId != filter.clusterId) return false;
    if (filter.plate != null && filter.plate!.isNotEmpty) {
      final query = filter.plate!.replaceAll(' ', '').toUpperCase();
      if (!event.plates.any((p) => p.text.contains(query))) return false;
    }
    return true;
  }

  @override
  Future<EventPage> events(String siteId, EventFilter filter, {int page = 1, int pageSize = 30}) => store.delay(() {
    final all = store.data.events.where((e) => e.siteId == siteId && matches(e, filter)).toList();
    final start = (page - 1) * pageSize;
    final items = start >= all.length ? <CameraEvent>[] : all.sublist(start, min(all.length, start + pageSize));
    return EventPage(items: items, total: all.length, page: page, pageSize: pageSize);
  });

  @override
  Future<EventCounts> counts(String siteId, EventFilter filter) => store.delay(() {
    final all = store.data.events.where((e) => e.siteId == siteId && matches(e, filter)).toList();
    final kinds = <EventKind, int>{};
    final labels = <String, int>{};
    for (final event in all) {
      kinds[event.kind] = (kinds[event.kind] ?? 0) + 1;
      if (event.label != null) labels[event.label!] = (labels[event.label!] ?? 0) + 1;
    }
    return EventCounts(
      total: all.length,
      alerts: all.where((e) => e.alert).length,
      unacknowledged: all.where((e) => e.alert && !e.acknowledged).length,
      kinds: kinds,
      labels: labels,
    );
  });

  @override
  Future<CameraEvent> event(String eventId) => store.delay(() {
    final event = store.data.events.where((e) => e.id == eventId).firstOrNull;
    if (event == null) throw const ApiFailure(FailureKind.notFound);
    return event;
  });

  @override
  Future<CameraEvent> acknowledge(String eventId) => store.delay(() {
    final index = store.data.events.indexWhere((e) => e.id == eventId);
    final event = store.data.events[index].copyWith(acknowledged: true);
    store.data.events[index] = event;
    store.controllers[event.siteId]?.add(EventChanged(event));
    return event;
  });

  @override
  Future<int> acknowledgeAll(String siteId) => store.delay(() {
    var changed = 0;
    for (var i = 0; i < store.data.events.length; i++) {
      final event = store.data.events[i];
      if (event.siteId == siteId && event.alert && !event.acknowledged) {
        store.data.events[i] = event.copyWith(acknowledged: true);
        changed++;
      }
    }
    return changed;
  });

  @override
  Stream<LiveUpdate> updates(String siteId) => store.channel(siteId).stream;

  @override
  MediaSource snapshot(CameraEvent event) => store.eventScene(event);

  @override
  MediaSource thumbnail(CameraEvent event) => store.eventScene(event);

  @override
  MediaSource? faceCrop(CameraEvent event) {
    final sampleId = event.face?.sampleId;
    if (sampleId == null) return null;
    for (final person in store.data.people) {
      for (final sample in person.samples) {
        if (sample.id == sampleId) return sample.crop;
      }
    }
    for (final cluster in store.data.clusters) {
      for (final sample in cluster.samples) {
        if (sample.id == sampleId) return sample.crop;
      }
    }
    return null;
  }

  @override
  ClipSource? clip(CameraEvent event) =>
      event.hasClip ? SyntheticClip(store.eventScene(event), event.boxes, const Duration(seconds: 12)) : null;

  @override
  Future<String> downloadClip(CameraEvent event) =>
      store.delay(() => throw const ApiFailure(FailureKind.notFound, 'demo'));
}
