import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/routes.dart';
import '../../core/format.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/theme.dart';
import '../../data/models/account.dart';
import '../../data/models/camera.dart';
import '../../data/models/insights.dart';
import '../../l10n/l10n.dart';
import '../../widgets/charts.dart';
import '../../widgets/event_tiles.dart';
import '../../widgets/labels.dart';
import '../../widgets/states.dart';
import '../../widgets/surfaces.dart';
import '../shell/site_switcher.dart';
import '../site_data.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(currentSiteProvider);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: const SiteSwitcherButton(),
        actions: [
          IconButton(
            tooltip: context.l10n.navLive,
            onPressed: () => const LiveRoute().go(context),
            icon: const Icon(Icons.grid_view_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: AsyncBody(
        value: current,
        onRetry: () => ref.invalidate(allSitesProvider),
        data: (site) => site == null
            ? EmptyState(
                icon: Icons.add_home_work_outlined,
                title: context.l10n.homeNoSite,
                body: context.l10n.homeNoSiteBody,
                action: FilledButton(
                  onPressed: () => const OnboardingSiteRoute(first: false).push<void>(context),
                  child: Text(context.l10n.homeSetUp),
                ),
              )
            : HomeBody(site: site),
      ),
    );
  }
}

class HomeBody extends ConsumerWidget {
  const HomeBody({super.key, required this.site});

  final SiteContext site;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = site.site.id;
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(camerasProvider(id));
        ref.invalidate(connectorsProvider(id));
        ref.invalidate(areasProvider(id));
        ref.invalidate(todayReportProvider(id));
        ref.refreshSite(id);
        await ref.read(todayCountsProvider(id).future);
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: Gaps.xxl),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.sm, Gaps.page, 0),
            child: ArmControl(site: site),
          ),
          const SizedBox(height: Gaps.md),
          Padding(padding: const EdgeInsets.symmetric(horizontal: Gaps.page), child: TodayMetrics(site: site)),
          AttentionSection(siteId: id),
          RecentStrip(siteId: id),
          VisitorsSection(siteId: id),
        ],
      ),
    );
  }
}

class ArmControl extends ConsumerStatefulWidget {
  const ArmControl({super.key, required this.site});

  final SiteContext site;

  @override
  ConsumerState<ArmControl> createState() => _ArmControlState();
}

class _ArmControlState extends ConsumerState<ArmControl> {
  ArmMode? pending;
  ArmMode? local;

  @override
  void didUpdateWidget(ArmControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.site.site.id != widget.site.site.id) local = null;
  }

  Future<void> change(ArmMode mode) async {
    final l10n = context.l10n;
    setState(() => pending = mode);
    try {
      await ref.read(backendProvider).tenancy.setArmMode(widget.site.site.id, mode);
      if (!mounted) return;
      setState(() => local = mode);
      ref.invalidate(allSitesProvider);
      showMessage(context, l10n.armChanged(l10n.arm(mode).toLowerCase()));
    } catch (failure) {
      if (mounted) showFailure(context, failure);
    } finally {
      if (mounted) setState(() => pending = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final mode = pending ?? local ?? widget.site.site.armMode;
    final allowed = widget.site.can(Role.operator);
    final armed = mode == ArmMode.away;
    return Panel(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: armed ? p.error.withValues(alpha: 0.14) : p.surface2,
                  borderRadius: BorderRadius.circular(Radii.medium),
                  border: Border.all(color: armed ? p.error.withValues(alpha: 0.4) : p.border),
                ),
                child: Icon(armIcon(mode), size: 19, color: armed ? p.dangerText : p.text),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.armTitle, style: context.text.labelMedium),
                    Text(l10n.arm(mode), style: context.text.titleMedium),
                  ],
                ),
              ),
              if (pending != null) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ArmMode>(
              showSelectedIcon: false,
              segments: [
                for (final value in ArmMode.values)
                  ButtonSegment(
                    value: value,
                    label: Text(l10n.arm(value), maxLines: 1, overflow: TextOverflow.ellipsis),
                    tooltip: l10n.armBody(value),
                  ),
              ],
              selected: {mode},
              onSelectionChanged: allowed && pending == null ? (value) => change(value.first) : null,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            allowed ? l10n.armBody(mode) : l10n.commonPermissionNeeded,
            style: context.text.bodySmall,
          ),
        ],
      ),
    );
  }
}

class TodayMetrics extends ConsumerWidget {
  const TodayMetrics({super.key, required this.site});

  final SiteContext site;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final id = site.site.id;
    final counts = ref.watch(todayCountsProvider(id)).value;
    final cameras = ref.watch(camerasProvider(id)).value;
    final areas = ref.watch(areasProvider(id)).value ?? const <Area>[];
    final enabled = cameras?.where((c) => c.enabled).toList() ?? const <Camera>[];
    final online = enabled.where((c) => c.online == true).length;
    final area = areas.isEmpty ? null : areas.first;
    final unreviewed = counts?.unacknowledged ?? 0;
    String value(int? number) => number == null ? '-' : '$number';
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.55,
      children: [
        MetricTile(
          icon: Icons.notifications_active_outlined,
          label: l10n.homeAlertsToday,
          value: value(counts?.alerts),
          tone: unreviewed > 0 ? p.dangerText : null,
          detail: counts == null ? null : (unreviewed > 0 ? l10n.homeUnacknowledged(unreviewed) : l10n.homeAllReviewed),
          onTap: () => const EventsRoute(alerts: true).go(context),
        ),
        MetricTile(
          icon: Icons.list_alt_rounded,
          label: l10n.homeEventsToday,
          value: value(counts?.total),
          detail: counts == null || counts.kinds.isEmpty ? null : topKinds(l10n, counts.kinds),
          onTap: () => const EventsRoute().go(context),
        ),
        MetricTile(
          icon: Icons.videocam_outlined,
          label: l10n.homeCamerasOnline,
          value: cameras == null ? '-' : l10n.homeCamerasValue(online, enabled.length),
          tone: cameras != null && online < enabled.length ? p.warning : null,
          onTap: () => const LiveRoute().go(context),
        ),
        MetricTile(
          icon: Icons.groups_2_outlined,
          label: area?.name ?? l10n.homeOccupancy,
          value: area == null ? '-' : '${area.occupancy}',
          detail: area?.capacity == null ? null : l10n.countsCapacity(area!.capacity!),
          onTap: () => const CountsRoute().go(context),
        ),
      ],
    );
  }

  String topKinds(AppLocalizations l10n, Map<dynamic, int> kinds) {
    final entries = kinds.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(2).map((e) => '${l10n.kind(e.key)} ${e.value}').join(', ');
  }
}

class AttentionSection extends ConsumerWidget {
  const AttentionSection({super.key, required this.siteId});

  final String siteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final cameras = ref.watch(camerasProvider(siteId)).value;
    final connectors = ref.watch(connectorsProvider(siteId)).value;
    if (cameras == null || connectors == null) return const SizedBox.shrink();
    final format = Formats(context, ref.read(clockProvider)());
    final offline = cameras.where((c) => c.enabled && c.online == false).toList();
    final downConnectors = connectors.where((c) => c.state == ConnectorState.offline).toList();
    final items = <Widget>[
      for (final connector in downConnectors)
        ListTile(
          leading: Icon(Icons.router_outlined, color: p.dangerText),
          title: Text(
            l10n.homeConnectorOffline(
              connector.name,
              connector.lastSeenAt == null ? l10n.commonUnknown : format.ago(connector.lastSeenAt!),
            ),
          ),
          onTap: () => const ConnectorsRoute().go(context),
        ),
      for (final camera in offline)
        ListTile(
          leading: Icon(Icons.videocam_off_outlined, color: p.dangerText),
          title: Text(l10n.homeCameraOffline(camera.name)),
          subtitle: camera.error == null ? null : Text(camera.error!),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => const HealthRoute().go(context),
        ),
    ];
    final online = connectors.where((c) => c.state == ConnectorState.online).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(l10n.homeAttention),
        if (items.isEmpty)
          TileGroup(
            children: [
              ListTile(
                leading: Icon(Icons.check_circle_outline_rounded, color: p.ok),
                title: Text(l10n.homeAllGood),
                subtitle: online.isEmpty
                    ? null
                    : Text(online.map((c) => l10n.homeConnectorOnline(c.name, c.version ?? '-')).join(', ')),
              ),
            ],
          )
        else
          TileGroup(children: items),
      ],
    );
  }
}

class RecentStrip extends ConsumerWidget {
  const RecentStrip({super.key, required this.siteId});

  final String siteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final value = ref.watch(recentEventsProvider(siteId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          l10n.homeRecent,
          action: TextButton(onPressed: () => const EventsRoute().go(context), child: Text(l10n.commonSeeAll)),
          padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.lg, Gaps.sm, 0),
        ),
        SizedBox(
          height: 194,
          child: value.when(
            skipLoadingOnReload: true,
            loading: () => ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
              itemCount: 3,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, _) => const Skeleton(width: 220, height: 190, radius: Radii.large),
            ),
            error: (error, _) =>
                ErrorState(error: error, compact: true, onRetry: () => ref.invalidate(recentEventsProvider(siteId))),
            data: (events) => events.isEmpty
                ? Center(child: Text(l10n.homeNoEvents, style: context.text.bodyMedium?.copyWith(color: context.palette.text3)))
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
                    itemCount: events.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) => EventCard(event: events[index]),
                  ),
          ),
        ),
      ],
    );
  }
}

CountsSeries hourlySeries(CountsReport report, {String? lineId}) {
  final inward = List<int>.filled(24, 0);
  final outward = List<int>.filled(24, 0);
  for (final bucket in report.buckets) {
    if (lineId != null && bucket.lineId != lineId) continue;
    inward[bucket.at.hour] += bucket.inward;
    outward[bucket.at.hour] += bucket.outward;
  }
  return CountsSeries(labels: [for (var h = 0; h < 24; h++) h.toString().padLeft(2, '0')], inward: inward, outward: outward);
}

class VisitorsSection extends ConsumerWidget {
  const VisitorsSection({super.key, required this.siteId});

  final String siteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final report = ref.watch(todayReportProvider(siteId)).value;
    if (report == null || report.lines.isEmpty) return const SizedBox.shrink();
    final line = report.lines.first;
    final series = hourlySeries(report, lineId: line.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          l10n.homeCountsToday,
          action: TextButton(onPressed: () => const CountsRoute().go(context), child: Text(l10n.commonSeeAll)),
          padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.lg, Gaps.sm, 0),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
          child: Panel(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${series.totalIn}', style: dataStyle(context, size: 26, weight: FontWeight.w500)),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(l10n.homeCountsIn.toLowerCase(), style: context.text.bodySmall),
                    ),
                    const SizedBox(width: 16),
                    Text('${series.totalOut}', style: dataStyle(context, size: 26, weight: FontWeight.w500, color: p.text2)),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(l10n.homeCountsOut.toLowerCase(), style: context.text.bodySmall),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        '${line.name}, ${line.cameraName}',
                        style: context.text.labelSmall,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CountsChart(
                  series: series,
                  height: 150,
                  labelEvery: 6,
                  semanticLabel: '${l10n.homeCountsToday}: ${l10n.countsTotalIn(series.totalIn)}, ${l10n.countsTotalOut(series.totalOut)}',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
