import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/format.dart';
import 'package:smart_surveillance/core/providers.dart';
import 'package:smart_surveillance/core/widgets/charts.dart';
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/core/widgets/surfaces.dart';
import 'package:smart_surveillance/features/events/presentation/providers.dart';
import 'package:smart_surveillance/features/insights/domain/models.dart';
import 'package:smart_surveillance/features/insights/presentation/providers.dart';
import 'package:smart_surveillance/features/tenancy/domain/models.dart';
import 'package:smart_surveillance/features/tenancy/presentation/current_site.dart';

/// Identifies a counts report by site, first day and bucket size.
typedef ReportKey = ({String siteId, DateTime start, Bucket bucket});

/// Loads the line crossing counts for a day or week, depending on the bucket size.
final reportProvider = FutureProvider.autoDispose.family<CountsReport, ReportKey>((ref, key) {
  final end = key.bucket == Bucket.hour
      ? key.start.add(const Duration(days: 1))
      : key.start.add(const Duration(days: 7));
  return ref
      .read(backendProvider)
      .analytics
      .counts(key.siteId, start: key.start, end: end, bucket: key.bucket);
});

/// Returns the in and out counts of line [lineId] in [report], ready to chart.
CountsSeries seriesFor(CountsReport report, String lineId, Formats format) {
  if (report.bucket == Bucket.hour) {
    final inward = List<int>.filled(24, 0);
    final outward = List<int>.filled(24, 0);
    for (final bucket in report.buckets.where((b) => b.lineId == lineId)) {
      inward[bucket.at.hour] += bucket.inward;
      outward[bucket.at.hour] += bucket.outward;
    }
    return CountsSeries(
      labels: [for (var h = 0; h < 24; h++) h.toString().padLeft(2, '0')],
      inward: inward,
      outward: outward,
    );
  }
  final days = [for (var i = 0; i < 7; i++) report.start.add(Duration(days: i))];
  final inward = List<int>.filled(7, 0);
  final outward = List<int>.filled(7, 0);
  for (final bucket in report.buckets.where((b) => b.lineId == lineId)) {
    final index = bucket.at.difference(report.start).inDays;
    if (index < 0 || index >= 7) continue;
    inward[index] += bucket.inward;
    outward[index] += bucket.outward;
  }
  return CountsSeries(
    labels: [for (final day in days) format.weekday(day)],
    inward: inward,
    outward: outward,
  );
}

/// The screen showing how many people crossed each count line and how many are in each area.
class CountsScreen extends ConsumerStatefulWidget {
  /// Creates the counts screen.
  const CountsScreen({super.key});

  @override
  ConsumerState<CountsScreen> createState() => _CountsScreenState();
}

class _CountsScreenState extends ConsumerState<CountsScreen> {
  Bucket bucket = Bucket.hour;
  late DateTime day = startOfDay(ref.read(clockProvider)());

  DateTime get start => bucket == Bucket.hour ? day : day.subtract(const Duration(days: 6));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final site = ref.watch(currentSiteProvider).value;
    if (site == null) return const Scaffold();
    final format = Formats(context, ref.read(clockProvider)());
    final today = startOfDay(ref.read(clockProvider)());
    final key = (siteId: site.site.id, start: start, bucket: bucket);
    final report = ref.watch(reportProvider(key));
    final areas = ref.watch(areasProvider(site.site.id));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.countsTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(reportProvider(key));
          ref.invalidate(areasProvider(site.site.id));
          await ref.read(reportProvider(key).future);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: Gaps.xxl),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
              child: SegmentedButton<Bucket>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(value: Bucket.hour, label: Text(l10n.countsHourly)),
                  ButtonSegment(value: Bucket.day, label: Text(l10n.countsDaily)),
                ],
                selected: {bucket},
                onSelectionChanged: (value) => setState(() => bucket = value.first),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Gaps.sm, Gaps.sm, Gaps.sm, 0),
              child: Row(
                children: [
                  IconButton(
                    tooltip: MaterialLocalizations.of(context).previousPageTooltip,
                    onPressed: () => setState(
                      () => day = day.subtract(Duration(days: bucket == Bucket.hour ? 1 : 7)),
                    ),
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  Expanded(
                    child: Text(
                      bucket == Bucket.hour
                          ? format.dayHeader(day)
                          : '${format.dayMonth(start)} - ${format.dayMonth(day)}',
                      textAlign: TextAlign.center,
                      style: context.text.titleSmall,
                    ),
                  ),
                  IconButton(
                    tooltip: MaterialLocalizations.of(context).nextPageTooltip,
                    onPressed: day.isBefore(today)
                        ? () => setState(() {
                            final next = day.add(Duration(days: bucket == Bucket.hour ? 1 : 7));
                            day = next.isAfter(today) ? today : next;
                          })
                        : null,
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
            ),
            report.when(
              skipLoadingOnReload: true,
              loading: () => Padding(
                padding: const EdgeInsets.all(Gaps.page),
                child: Skeleton(height: 260, radius: Radii.large),
              ),
              error: (error, _) => ErrorState(
                error: error,
                compact: true,
                onRetry: () => ref.invalidate(reportProvider(key)),
              ),
              data: (report) => report.lines.isEmpty
                  ? EmptyState(
                      icon: Icons.timeline_rounded,
                      title: l10n.countsNoLines,
                      body: l10n.countsNoLinesBody,
                    )
                  : Column(
                      children: [
                        for (final line in report.lines)
                          LineCard(
                            line: line,
                            series: seriesFor(report, line.id, format),
                            hourly: bucket == Bucket.hour,
                          ),
                      ],
                    ),
            ),
            areas.when(
              loading: () => const SizedBox.shrink(),
              error: (error, _) => const SizedBox.shrink(),
              data: (areas) => areas.isEmpty
                  ? const SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(l10n.countsAreas),
                        for (final area in areas)
                          AreaCard(area: area, canReset: site.can(Role.operator)),
                      ],
                    ),
            ),
            const SizedBox(height: Gaps.lg),
            Center(
              child: ChartLegend(inLabel: l10n.countsIn, outLabel: l10n.countsOut),
            ),
          ],
        ),
      ),
    );
  }
}

/// A card charting the crossings of one count line.
class LineCard extends StatelessWidget {
  /// Creates a card for [line] charting [series], by hour when [hourly] is true.
  const LineCard({super.key, required this.line, required this.series, required this.hourly});

  /// The count line shown.
  final CountLine line;

  /// The in and out counts to chart.
  final CountsSeries series;

  /// Whether the series is grouped by hour rather than by day.
  final bool hourly;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final peak = series.labels[series.peak];
    return Padding(
      padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.md, Gaps.page, 0),
      child: Panel(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.timeline_rounded, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(line.name, style: context.text.titleMedium)),
                Text(line.cameraName, style: context.text.labelSmall),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  l10n.countsTotalIn(series.totalIn),
                  style: dataStyle(context, size: 15, weight: FontWeight.w500),
                ),
                const SizedBox(width: 14),
                Text(
                  l10n.countsTotalOut(series.totalOut),
                  style: dataStyle(context, size: 15, color: p.text2),
                ),
                const Spacer(),
                if (series.totalIn + series.totalOut > 0 && hourly)
                  Text(l10n.countsPeak('$peak:00'), style: context.text.labelSmall),
              ],
            ),
            const SizedBox(height: 12),
            CountsChart(
              series: series,
              labelEvery: hourly ? 4 : 1,
              semanticLabel:
                  '${line.name}: ${l10n.countsTotalIn(series.totalIn)}, ${l10n.countsTotalOut(series.totalOut)}',
            ),
          ],
        ),
      ),
    );
  }
}

/// A card showing the occupancy of one area, with an option to reset it.
class AreaCard extends ConsumerWidget {
  /// Creates a card for [area]; [canReset] allows the user to correct the occupancy.
  const AreaCard({super.key, required this.area, required this.canReset});

  /// The area shown.
  final Area area;

  /// Whether the user may reset the occupancy.
  final bool canReset;

  /// Asks for a new occupancy and sets the area to it.
  Future<void> reset(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final controller = TextEditingController(text: '${area.occupancy}');
    final value = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.countsResetTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: dataStyle(context, size: 20),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(int.tryParse(controller.text) ?? 0),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null) return;
    try {
      await ref.read(backendProvider).analytics.resetArea(area.id, value);
      final site = ref.read(currentSiteProvider).value;
      if (site != null) ref.invalidate(areasProvider(site.site.id));
      if (context.mounted) showMessage(context, l10n.countsResetDone(value));
    } catch (failure) {
      if (context.mounted) showFailure(context, failure);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final format = Formats(context, ref.read(clockProvider)());
    final capacity = area.capacity;
    final fill = capacity == null || capacity == 0
        ? null
        : (area.occupancy / capacity).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.fromLTRB(Gaps.page, 0, Gaps.page, Gaps.md),
      child: Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(area.name, style: context.text.titleMedium),
                      const SizedBox(height: 2),
                      Text(area.lineNames.join(', '), style: context.text.labelSmall),
                    ],
                  ),
                ),
                if (canReset)
                  TextButton(onPressed: () => reset(context, ref), child: Text(l10n.countsReset)),
              ],
            ),
            const SizedBox(height: Gaps.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${area.occupancy}',
                  style: dataStyle(context, size: 34, weight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    capacity == null ? l10n.countsInside : l10n.countsCapacity(capacity),
                    style: context.text.bodyMedium?.copyWith(color: p.text2),
                  ),
                ),
              ],
            ),
            if (fill != null) ...[
              const SizedBox(height: Gaps.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: fill,
                  minHeight: 6,
                  backgroundColor: p.surface3,
                  color: fill > 0.9 ? p.error : (fill > 0.7 ? p.warning : p.text),
                ),
              ),
            ],
            const SizedBox(height: Gaps.sm),
            Text(
              l10n.countsSince(area.entered, area.exited, format.time(area.since)),
              style: context.text.bodySmall,
            ),
            if (area.resetAt != null)
              Text(l10n.countsDailyReset(area.resetAt!), style: context.text.bodySmall),
          ],
        ),
      ),
    );
  }
}
