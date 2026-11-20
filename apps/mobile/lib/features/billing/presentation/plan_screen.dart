import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/format.dart';
import 'package:smart_surveillance/core/providers.dart';
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/core/widgets/surfaces.dart';
import 'package:smart_surveillance/features/billing/domain/models.dart';
import 'package:smart_surveillance/features/tenancy/presentation/current_site.dart';

/// The plan, limits and usage of an organisation.
final planProvider = FutureProvider.family<PlanReport, String>(
  (ref, organisationId) => ref.read(backendProvider).business.plan(organisationId),
);

/// Whether the current organisation's plan includes [feature], true until the plan is known.
bool planIncludes(WidgetRef ref, PlanFeature feature) {
  final site = ref.watch(currentSiteProvider).value;
  if (site == null) return true;
  final plan = ref.watch(planProvider(site.organisation.id)).value?.plan;
  return plan == null || plan.has(feature);
}

/// The name of [feature].
String featureName(AppLocalizations l10n, PlanFeature feature) => switch (feature) {
  PlanFeature.faces => l10n.featureFaces,
  PlanFeature.plates => l10n.featurePlates,
  PlanFeature.appearance => l10n.featureAppearanceSearch,
  PlanFeature.journeys => l10n.featureJourneys,
  PlanFeature.falls => l10n.featureFalls,
  PlanFeature.objects => l10n.featureObjects,
  PlanFeature.follow => l10n.featureFollow,
  PlanFeature.telegram => l10n.featureTelegram,
};

/// Shows the organisation's plan, its limits, this month's usage and its features.
class PlanScreen extends ConsumerWidget {
  /// Creates the screen.
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final site = ref.watch(currentSiteProvider).value;
    if (site == null) return const Scaffold();
    final value = ref.watch(planProvider(site.organisation.id));
    final format = Formats(context, ref.read(clockProvider)());
    String days(int? value) => value == null ? l10n.planUnlimited : l10n.siteRetentionDays(value);
    Widget meter(String label, int used, int? max) {
      final share = max == null || max == 0 ? null : (used / max).clamp(0.0, 1.0);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: Gaps.page, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(label, style: context.text.bodyLarge)),
                Text(
                  max == null
                      ? format.number(used)
                      : l10n.planOf(format.number(used), format.number(max)),
                  style: dataStyle(context, size: 13, color: p.text2),
                ),
              ],
            ),
            if (share != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: share,
                  minHeight: 6,
                  backgroundColor: p.surface3,
                  color: share >= 1 ? p.error : (share > 0.8 ? p.warning : p.text),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.planTitle)),
      body: AsyncBody(
        value: value,
        onRetry: () => ref.invalidate(planProvider(site.organisation.id)),
        data: (report) {
          final plan = report.plan;
          final usage = report.usage;
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(planProvider(site.organisation.id)),
            child: ListView(
              padding: const EdgeInsets.only(bottom: Gaps.xxl),
              children: [
                if (report.suspended)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(Gaps.page, 0, Gaps.page, Gaps.md),
                    child: Panel(
                      color: p.error.withValues(alpha: 0.07),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.pause_circle_outline_rounded, color: p.error),
                          const SizedBox(width: Gaps.md),
                          Expanded(child: Text(l10n.planSuspended)),
                        ],
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
                  child: Panel(
                    child: Row(
                      children: [
                        const IconBadge(icon: Icons.workspace_premium_outlined, size: 44),
                        const SizedBox(width: Gaps.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(plan.name, style: context.text.titleLarge),
                              Text(
                                plan.internal ? l10n.planInternal : site.organisation.name,
                                style: context.text.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SectionHeader(l10n.planLimits),
                TileGroup(
                  children: [
                    meter(l10n.planSites, usage.sites, plan.limits.sites),
                    meter(l10n.planCameras, usage.cameras, plan.limits.cameras),
                    meter(l10n.planMembers, usage.members, plan.limits.members),
                    ListTile(
                      title: Text(l10n.planEventRetention),
                      trailing: Text(days(plan.limits.eventRetentionDays)),
                    ),
                    ListTile(
                      title: Text(l10n.planClipRetention),
                      trailing: Text(days(plan.limits.clipRetentionDays)),
                    ),
                  ],
                ),
                if (usage.metered) ...[
                  SectionHeader(
                    '${l10n.planUsage}, ${l10n.planSince(format.date(usage.periodStart))}',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.6,
                      children: [
                        MetricTile(
                          label: l10n.planCameraHours,
                          value: format.number(usage.cameraHours),
                          icon: Icons.videocam_outlined,
                        ),
                        MetricTile(
                          label: l10n.planAnalyticsHours,
                          value: format.number(usage.analyticsHours),
                          icon: Icons.auto_awesome_outlined,
                        ),
                        MetricTile(
                          label: l10n.planEvents,
                          value: format.number(usage.events),
                          icon: Icons.list_alt_rounded,
                        ),
                        MetricTile(
                          label: l10n.planClipStorage,
                          value: l10n.planGigabytes(
                            format.number(usage.clipBytes / 1e9, digits: 1),
                          ),
                          icon: Icons.sd_storage_outlined,
                        ),
                        MetricTile(
                          label: l10n.planNotifications,
                          value: format.number(usage.notifications),
                          icon: Icons.notifications_outlined,
                        ),
                      ],
                    ),
                  ),
                ],
                SectionHeader(l10n.planFeatures),
                TileGroup(
                  children: [
                    for (final feature in PlanFeature.values)
                      ListTile(
                        leading: Icon(
                          plan.has(feature)
                              ? Icons.check_circle_outline_rounded
                              : Icons.remove_circle_outline_rounded,
                          color: plan.has(feature) ? p.ok : p.text3,
                        ),
                        title: Text(
                          featureName(l10n, feature),
                          style: TextStyle(color: plan.has(feature) ? p.text : p.text2),
                        ),
                        trailing: Text(
                          plan.has(feature) ? l10n.planIncluded : l10n.planNotIncluded,
                          style: context.text.labelMedium,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
