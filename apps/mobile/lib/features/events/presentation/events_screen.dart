import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/format.dart';
import 'package:smart_surveillance/core/providers.dart';
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/features/devices/presentation/providers.dart';
import 'package:smart_surveillance/features/events/domain/models.dart';
import 'package:smart_surveillance/features/events/presentation/event_feed.dart';
import 'package:smart_surveillance/features/events/presentation/event_tiles.dart';
import 'package:smart_surveillance/features/events/presentation/filter_sheet.dart';
import 'package:smart_surveillance/features/events/presentation/labels.dart';
import 'package:smart_surveillance/features/events/presentation/providers.dart';
import 'package:smart_surveillance/features/tenancy/domain/models.dart';
import 'package:smart_surveillance/features/tenancy/presentation/current_site.dart';
class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key, this.camera, this.kind, this.person, this.cluster, this.alertsOnly = false});

  final String? camera;
  final String? kind;
  final String? person;
  final String? cluster;
  final bool alertsOnly;

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  final scroll = ScrollController();
  String? appliedFor;

  @override
  void initState() {
    super.initState();
    scroll.addListener(() {
      final site = ref.read(currentSiteProvider).value;
      if (site == null) return;
      if (scroll.position.pixels > scroll.position.maxScrollExtent - 600) {
        ref.read(eventFeedProvider(site.site.id).notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  void applyRouteFilter(String siteId) {
    final key = '$siteId ${widget.camera} ${widget.kind} ${widget.person} ${widget.cluster} ${widget.alertsOnly}';
    if (appliedFor == key) return;
    appliedFor = key;
    final hasRoute =
        widget.camera != null || widget.kind != null || widget.person != null || widget.cluster != null || widget.alertsOnly;
    if (!hasRoute) return;
    final kind = EventKind.values.where((k) => k.name == widget.kind).firstOrNull;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(eventFilterStateProvider(siteId).notifier).set(
        EventFilter(
          cameraIds: widget.camera == null ? const {} : {widget.camera!},
          kinds: kind == null ? const {} : {kind},
          personId: widget.person,
          clusterId: widget.cluster,
          alertsOnly: widget.alertsOnly,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final site = ref.watch(currentSiteProvider).value;
    if (site == null) return const Scaffold();
    final id = site.site.id;
    applyRouteFilter(id);
    final filter = ref.watch(eventFilterStateProvider(id));
    final feed = ref.watch(eventFeedProvider(id));
    ref.listen(liveUpdatesProvider(id), (_, next) {
      final update = next.value;
      if (update is EventChanged) {
        final atTop = !scroll.hasClients || scroll.offset < 80;
        ref.read(eventFeedProvider(id).notifier).receive(update.event, created: update.created, atTop: atTop);
      }
    });
    final pending = feed.value?.pending.length ?? 0;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.eventsTitle),
        actions: [
          if (site.can(Role.operator))
            IconButton(
              tooltip: l10n.eventsAckAll,
              icon: const Icon(Icons.done_all_rounded),
              onPressed: () async {
                try {
                  final count = await ref.read(backendProvider).events.acknowledgeAll(id);
                  ref.invalidate(eventFeedProvider(id));
                  ref.refreshSite(id);
                  if (context.mounted) showMessage(context, l10n.eventsAckAllDone(count));
                } catch (failure) {
                  if (context.mounted) showFailure(context, failure);
                }
              },
            ),
          Badge(
            isLabelVisible: filter.activeCount > 0,
            label: Text('${filter.activeCount}'),
            offset: const Offset(-6, 6),
            child: IconButton(
              tooltip: l10n.eventsFilters,
              icon: const Icon(Icons.tune_rounded),
              onPressed: () async {
                final next = await showFilterSheet(context, siteId: id, filter: filter);
                if (next != null) ref.read(eventFilterStateProvider(id).notifier).set(next);
              },
            ),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(52), child: QuickFilters(siteId: id, filter: filter)),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(eventFeedProvider(id));
              await ref.read(eventFeedProvider(id).future);
            },
            child: AsyncBody(
              value: feed,
              loading: const ListSkeleton(),
              onRetry: () => ref.invalidate(eventFeedProvider(id)),
              data: (state) => EventList(state: state, scroll: scroll, filtered: filter.activeCount > 0),
            ),
          ),
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: pending == 0
                    ? const SizedBox.shrink()
                    : FilledButton.icon(
                        style: FilledButton.styleFrom(minimumSize: const Size(0, 40), shape: const StadiumBorder()),
                        onPressed: () {
                          ref.read(eventFeedProvider(id).notifier).showPending();
                          scroll.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
                        },
                        icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                        label: Text(l10n.eventsNew(pending)),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickFilters extends ConsumerWidget {
  const QuickFilters({super.key, required this.siteId, required this.filter});

  final String siteId;
  final EventFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final now = ref.read(clockProvider)();
    final today = startOfDay(now);
    final yesterday = today.subtract(const Duration(days: 1));
    final notifier = ref.read(eventFilterStateProvider(siteId).notifier);
    bool sameDay(DateTime? a, DateTime b) => a != null && a.year == b.year && a.month == b.month && a.day == b.day;
    final cameras = ref.watch(camerasProvider(siteId)).value ?? const [];
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(Gaps.page, 4, Gaps.page, 10),
        children: [
          FilterChip(
            label: Text(l10n.eventsAlertsOnly),
            avatar: const Icon(Icons.notifications_active_outlined, size: 16),
            selected: filter.alertsOnly,
            onSelected: (value) => notifier.set(filter.copyWith(alertsOnly: value)),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Text(l10n.commonToday),
            selected: sameDay(filter.day, today),
            onSelected: (value) => notifier.set(filter.copyWith(day: value ? today : null)),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Text(l10n.commonYesterday),
            selected: sameDay(filter.day, yesterday),
            onSelected: (value) => notifier.set(filter.copyWith(day: value ? yesterday : null)),
          ),
          for (final camera in cameras) ...[
            const SizedBox(width: 8),
            FilterChip(
              label: Text(camera.name),
              selected: filter.cameraIds.contains(camera.id),
              onSelected: (value) => notifier.set(
                filter.copyWith(
                  cameraIds: value ? {...filter.cameraIds, camera.id} : ({...filter.cameraIds}..remove(camera.id)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class EventList extends ConsumerWidget {
  const EventList({super.key, required this.state, required this.scroll, required this.filtered});

  final FeedState state;
  final ScrollController scroll;
  final bool filtered;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    if (state.items.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          EmptyState(
            icon: Icons.notifications_none_rounded,
            title: l10n.eventsEmpty,
            body: filtered ? l10n.eventsEmptyBody : l10n.eventsEmptyToday,
          ),
        ],
      );
    }
    final format = Formats(context, ref.read(clockProvider)());
    final rows = <Widget>[];
    final counts = state.counts;
    if (counts != null) {
      rows.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.sm, Gaps.page, 0),
          child: Text(
            [
              l10n.eventsTotal(counts.total),
              if (counts.alerts > 0) l10n.eventsAlertCount(counts.alerts),
              if (counts.unacknowledged > 0) l10n.homeUnacknowledged(counts.unacknowledged),
            ].join(', '),
            style: dataStyle(context, size: 12, color: p.text3),
          ),
        ),
      );
    }
    DateTime? day;
    for (final event in state.items) {
      final eventDay = DateTime(event.startedAt.year, event.startedAt.month, event.startedAt.day);
      if (day != eventDay) {
        day = eventDay;
        rows.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.lg, Gaps.page, Gaps.xs),
            child: Semantics(header: true, child: Text(format.dayHeader(eventDay), style: context.text.titleSmall)),
          ),
        );
      }
      rows.add(EventRow(key: ValueKey(event.id), event: event));
    }
    if (state.more) {
      rows.add(
        Padding(
          padding: const EdgeInsets.all(Gaps.lg),
          child: Center(
            child: state.loadingMore
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const SizedBox(height: 20),
          ),
        ),
      );
    }
    rows.add(const SizedBox(height: Gaps.xxl));
    return ListView(controller: scroll, physics: const AlwaysScrollableScrollPhysics(), children: rows);
  }
}

String eventKindName(AppLocalizations l10n, EventKind kind) => l10n.kind(kind);
