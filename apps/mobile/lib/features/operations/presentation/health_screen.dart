import 'package:flutter/material.dart';
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
import 'package:smart_surveillance/features/operations/domain/models.dart';
import 'package:smart_surveillance/features/tenancy/presentation/current_site.dart';

/// The health report of a site, loaded by site id.
final healthProvider = FutureProvider.autoDispose.family<HealthReport, String>(
  (ref, siteId) => ref.read(backendProvider).health.health(siteId),
);

/// The page that shows uptime, latency and outages of the site's devices.
class HealthScreen extends ConsumerWidget {
  /// Creates the screen.
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final site = ref.watch(currentSiteProvider).value;
    if (site == null) return const Scaffold();
    final value = ref.watch(healthProvider(site.site.id));
    final format = Formats(context, ref.read(clockProvider)());
    String status(HealthStatus status) => switch (status) {
      HealthStatus.up => l10n.healthUp,
      HealthStatus.degraded => l10n.healthDegraded,
      HealthStatus.down => l10n.healthDown,
      HealthStatus.unknown => l10n.commonUnknown,
      HealthStatus.disabled => l10n.commonOff,
    };
    return Scaffold(
      appBar: AppBar(title: Text(l10n.healthTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(healthProvider(site.site.id));
          await ref.read(healthProvider(site.site.id).future);
        },
        child: AsyncBody(
          value: value,
          loading: const ListSkeleton(thumbnail: false),
          onRetry: () => ref.invalidate(healthProvider(site.site.id)),
          data: (report) => ListView(
            padding: const EdgeInsets.only(bottom: Gaps.xxl),
            children: [
              SectionHeader(
                l10n.healthLast24h,
                padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.sm, Gaps.page, Gaps.sm),
              ),
              TileGroup(
                children: [
                  for (final target in report.targets)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(Gaps.page, 12, Gaps.page, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              StatusDot(
                                online: target.status == HealthStatus.up
                                    ? true
                                    : (target.status == HealthStatus.down ? false : null),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                target.kind == 'camera'
                                    ? Icons.videocam_outlined
                                    : Icons.router_outlined,
                                size: 18,
                                color: p.text3,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  target.name,
                                  style: context.text.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                status(target.status),
                                style: dataStyle(
                                  context,
                                  size: 12,
                                  color: target.status == HealthStatus.down
                                      ? p.dangerText
                                      : p.text2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Sparkline(
                            values: [for (final bucket in target.buckets) bucket.availability],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (target.uptimePercent != null)
                                Text(
                                  l10n.healthUptime(
                                    format.number(target.uptimePercent!, digits: 1),
                                  ),
                                  style: dataStyle(context, size: 12, color: p.text2),
                                ),
                              const SizedBox(width: 14),
                              if (target.latencyMs != null)
                                Text(
                                  l10n.healthLatency(format.number(target.latencyMs!, digits: 1)),
                                  style: dataStyle(context, size: 12, color: p.text3),
                                ),
                              const Spacer(),
                              if (target.parentName != null)
                                Text(target.parentName!, style: context.text.labelSmall),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SectionHeader(l10n.healthOutages),
              if (report.outages.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
                  child: Text(
                    l10n.healthNoOutages,
                    style: context.text.bodyMedium?.copyWith(color: p.text3),
                  ),
                )
              else
                TileGroup(
                  children: [
                    for (final outage in report.outages)
                      ListTile(
                        leading: Icon(
                          outage.ongoing ? Icons.error_outline_rounded : Icons.history_rounded,
                          color: outage.ongoing ? p.dangerText : p.text3,
                        ),
                        title: Text(outage.targetName),
                        subtitle: Text(
                          [
                            outage.ongoing
                                ? l10n.healthOngoing(
                                    format.duration(
                                      ref.read(clockProvider)().difference(outage.startedAt),
                                    ),
                                  )
                                : l10n.healthLasted(
                                    format.duration(outage.endedAt!.difference(outage.startedAt)),
                                  ),
                            if (outage.causeName != null) l10n.healthCause(outage.causeName!),
                          ].join('. '),
                        ),
                        trailing: Text(
                          format.when(outage.startedAt),
                          style: dataStyle(context, size: 11.5, color: p.text3),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
