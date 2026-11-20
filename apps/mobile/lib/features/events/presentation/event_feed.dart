import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/features/events/domain/models.dart';

part 'event_feed.g.dart';
class FeedState {
  const FeedState({
    required this.items,
    required this.total,
    required this.page,
    this.loadingMore = false,
    this.pending = const [],
    this.counts,
  });

  final List<CameraEvent> items;
  final int total;
  final int page;
  final bool loadingMore;
  final List<CameraEvent> pending;
  final EventCounts? counts;

  bool get more => items.length < total;

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

@riverpod
class EventFilterState extends _$EventFilterState {
  @override
  EventFilter build(String siteId) => const EventFilter();

  void set(EventFilter filter) => state = filter;
}

bool matches(CameraEvent event, EventFilter filter) {
  if (filter.alertsOnly && !event.alert) return false;
  if (filter.cameraIds.isNotEmpty && !filter.cameraIds.contains(event.cameraId)) return false;
  if (filter.kinds.isNotEmpty && !filter.kinds.contains(event.kind)) return false;
  if (filter.labels.isNotEmpty && !filter.labels.contains(event.label)) return false;
  if (filter.day != null) {
    final day = filter.day!;
    if (event.startedAt.year != day.year || event.startedAt.month != day.month || event.startedAt.day != day.day) {
      return false;
    }
  }
  return filter.zones.isEmpty && filter.lines.isEmpty && filter.personId == null && filter.clusterId == null;
}

@riverpod
class EventFeed extends _$EventFeed {
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
    return FeedState(items: page.items, total: page.total, page: 1, counts: results[1] as EventCounts);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.loadingMore || !current.more) return;
    state = AsyncData(current.copyWith(loadingMore: true));
    final filter = ref.read(eventFilterStateProvider(siteId));
    try {
      final page = await ref.read(backendProvider).events.events(siteId, filter, page: current.page + 1, pageSize: pageSize);
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
      state = AsyncData(current.copyWith(items: [event, ...current.items], total: current.total + 1));
    } else {
      state = AsyncData(current.copyWith(pending: [event, ...current.pending]));
    }
  }

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

  void replace(CameraEvent event) => receive(event, created: false, atTop: false);
}
