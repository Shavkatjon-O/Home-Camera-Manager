import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/features/events/domain/models.dart';

part 'event_feed.g.dart';

/// The loaded part of the event list together with its paging and pending state.
class FeedState {
  /// Creates a state holding [items] out of [total] events, with [page] pages loaded.
  const FeedState({
    required this.items,
    required this.total,
    required this.page,
    this.loadingMore = false,
    this.pending = const [],
    this.counts,
  });

  /// The events loaded so far, newest first.
  final List<CameraEvent> items;

  /// The number of events matching the filter on the server.
  final int total;

  /// The number of the last page loaded.
  final int page;

  /// Whether the next page is being loaded.
  final bool loadingMore;

  /// New events held back so the list does not jump while the user is scrolled down.
  final List<CameraEvent> pending;

  /// The totals for the current filter, or null while unknown.
  final EventCounts? counts;

  /// Whether more events remain on the server.
  bool get more => items.length < total;

  /// Returns a copy with the given fields replaced.
  FeedState copyWith({
    List<CameraEvent>? items,
    int? total,
    int? page,
    bool? loadingMore,
    List<CameraEvent>? pending,
    EventCounts? counts,
  }) => FeedState(
    items: items ?? this.items,
    total: total ?? this.total,
    page: page ?? this.page,
    loadingMore: loadingMore ?? this.loadingMore,
    pending: pending ?? this.pending,
    counts: counts ?? this.counts,
  );
}

/// Holds the event filter chosen for a site.
@riverpod
class EventFilterState extends _$EventFilterState {
  @override
  EventFilter build(String siteId) => const EventFilter();

  /// Replaces the current filter with [filter].
  void set(EventFilter filter) => state = filter;
}

/// Returns whether [event] passes the parts of [filter] that can be checked on the device.
bool matches(CameraEvent event, EventFilter filter) {
  if (filter.alertsOnly && !event.alert) return false;
  if (filter.cameraIds.isNotEmpty && !filter.cameraIds.contains(event.cameraId)) return false;
  if (filter.kinds.isNotEmpty && !filter.kinds.contains(event.kind)) return false;
  if (filter.labels.isNotEmpty && !filter.labels.contains(event.label)) return false;
  if (filter.day != null) {
    final day = filter.day!;
    if (event.startedAt.year != day.year ||
        event.startedAt.month != day.month ||
        event.startedAt.day != day.day) {
      return false;
    }
  }
  return filter.zones.isEmpty &&
      filter.lines.isEmpty &&
      filter.personId == null &&
      filter.clusterId == null;
}

/// Loads and updates the paged list of events at a site for the current filter.
@riverpod
class EventFeed extends _$EventFeed {
  /// The number of events requested per page.
  static const pageSize = 30;

  @override
  Future<FeedState> build(String siteId) async {
    final filter = ref.watch(eventFilterStateProvider(siteId));
    final events = ref.read(backendProvider).events;
    final results = await Future.wait([
      events.events(siteId, filter, pageSize: pageSize),
      events.counts(siteId, filter),
    ]);
    final page = results[0] as EventPage;
    return FeedState(
      items: page.items,
      total: page.total,
      page: 1,
      counts: results[1] as EventCounts,
    );
  }

  /// Loads the next page and appends it, unless one is loading or everything is loaded.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.loadingMore || !current.more) return;
    state = AsyncData(current.copyWith(loadingMore: true));
    final filter = ref.read(eventFilterStateProvider(siteId));
    try {
      final page = await ref
          .read(backendProvider)
          .events
          .events(siteId, filter, page: current.page + 1, pageSize: pageSize);
      final known = current.items.map((e) => e.id).toSet();
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...page.items.where((e) => !known.contains(e.id))],
          total: page.total,
          page: current.page + 1,
          loadingMore: false,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(loadingMore: false));
    }
  }

  /// Applies a live change to [event], inserting a new one at the top or holding it as pending.
  void receive(CameraEvent event, {required bool created, required bool atTop}) {
    final current = state.value;
    if (current == null) return;
    final index = current.items.indexWhere((e) => e.id == event.id);
    if (index >= 0) {
      final items = List.of(current.items)..[index] = event;
      state = AsyncData(current.copyWith(items: items));
      return;
    }
    if (!created || !matches(event, ref.read(eventFilterStateProvider(siteId)))) return;
    if (atTop) {
      state = AsyncData(
        current.copyWith(items: [event, ...current.items], total: current.total + 1),
      );
    } else {
      state = AsyncData(current.copyWith(pending: [event, ...current.pending]));
    }
  }

  /// Moves the pending events to the top of the list.
  void showPending() {
    final current = state.value;
    if (current == null || current.pending.isEmpty) return;
    state = AsyncData(
      current.copyWith(
        items: [...current.pending, ...current.items],
        total: current.total + current.pending.length,
        pending: const [],
      ),
    );
  }

  /// Replaces the loaded copy of [event] with the given one.
  void replace(CameraEvent event) => receive(event, created: false, atTop: false);
}
