import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/app/routes.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/format.dart';
import 'package:smart_surveillance/core/media/media_source.dart';
import 'package:smart_surveillance/core/providers.dart';
import 'package:smart_surveillance/core/widgets/media_view.dart';
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/core/widgets/surfaces.dart';
import 'package:smart_surveillance/features/analytics/domain/models.dart';
import 'package:smart_surveillance/features/analytics/presentation/labels.dart';
import 'package:smart_surveillance/features/analytics/presentation/providers.dart';
import 'package:smart_surveillance/features/analytics/presentation/zone_editor_screen.dart';
import 'package:smart_surveillance/features/devices/domain/models.dart';
import 'package:smart_surveillance/features/events/presentation/labels.dart';
import 'package:smart_surveillance/features/tenancy/presentation/current_site.dart';
/// Loads the still image of the analytics view with the given id.
final viewSnapshotProvider = FutureProvider.autoDispose.family<MediaSource, String>(
  (ref, viewId) => ref.read(backendProvider).analytics.viewSnapshot(viewId),
);

/// The list of a site's cameras with their analytics status, opening each one's settings.
class AnalyticsScreen extends ConsumerWidget {
  /// Creates the analytics list screen.
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final site = ref.watch(currentSiteProvider).value;
    if (site == null) return const Scaffold();
    final views = ref.watch(viewsProvider(site.site.id));
    final format = Formats(context, ref.read(clockProvider)());
    return Scaffold(
      appBar: AppBar(title: Text(l10n.analyticsTitle)),
      body: AsyncBody(
        value: views,
        onRetry: () => ref.invalidate(viewsProvider(site.site.id)),
        loading: const ListSkeleton(),
        data: (views) => views.isEmpty
            ? EmptyState(icon: Icons.auto_awesome_outlined, title: l10n.liveNoCameras, body: l10n.liveNoCamerasBody)
            : ListView(
                padding: const EdgeInsets.only(bottom: Gaps.xxl),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(Gaps.page, 0, Gaps.page, Gaps.sm),
                    child: Text(l10n.analyticsViewsBody, style: context.text.bodyMedium?.copyWith(color: p.text2)),
                  ),
                  for (final view in views)
                    InkWell(
                      onTap: () => ViewRoute(viewId: view.id).go(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Gaps.page, vertical: 10),
                        child: Row(
                          children: [
                            SizedBox(width: 112, child: ViewThumb(view: view)),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(view.title, style: context.text.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(
                                    view.enabled
                                        ? '${l10n.profile(view.profile)}, ${l10n.analyticsZonesLines(view.zones.length, view.lines.length)}'
                                        : l10n.analyticsDisabled,
                                    style: context.text.bodySmall,
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      if (view.enabled && view.fpsMeasured != null)
                                        Tag(l10n.analyticsFps(format.number(view.fpsMeasured!, digits: 1)), dense: true),
                                      if (view.faces) Tag(l10n.featureFaces, dense: true, tone: TagTone.info),
                                      if (view.plates) Tag(l10n.featurePlates, dense: true, tone: TagTone.info),
                                      if (view.suspended) Tag(l10n.analyticsSuspended, dense: true, tone: TagTone.warning),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

/// A snapshot of an analytics view, optionally with its zones and lines drawn over it.
class ViewThumb extends ConsumerWidget {
  /// Creates a thumbnail of [view], drawing its zones and lines when [rules] is true.
  const ViewThumb({super.key, required this.view, this.rules = true});

  /// The view shown in the thumbnail.
  final AnalyticsView view;
  /// Whether the view's zones and lines are drawn over the snapshot.
  final bool rules;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(viewSnapshotProvider(view.id)).value;
    return Frame(
      aspect: 16 / 9,
      radius: 8,
      child: Stack(
        fit: StackFit.expand,
        children: [
          MediaView(source: snapshot, showStamp: false),
          if (rules)
            IgnorePointer(
              child: CustomPaint(painter: RulesPainter(zones: view.zones, lines: view.lines, palette: context.palette, thin: true)),
            ),
        ],
      ),
    );
  }
}

/// The settings screen of one analytics view: profile, stream, features and rules.
class ViewScreen extends ConsumerStatefulWidget {
  /// Creates the settings screen for the view [viewId].
  const ViewScreen({super.key, required this.viewId});

  /// The id of the analytics view being edited.
  final String viewId;

  @override
  ConsumerState<ViewScreen> createState() => _ViewScreenState();
}

class _ViewScreenState extends ConsumerState<ViewScreen> {
  AnalyticsView? draft;
  bool busy = false;

  Future<void> save(AnalyticsView view) async {
    setState(() {
      draft = view;
      busy = true;
    });
    try {
      final saved = await ref.read(backendProvider).analytics.updateView(view);
      final site = ref.read(currentSiteProvider).value;
      if (site != null) ref.invalidate(viewsProvider(site.site.id));
      if (mounted) setState(() => draft = saved);
    } catch (failure) {
      if (mounted) {
        showFailure(context, failure);
        setState(() => draft = null);
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final site = ref.watch(currentSiteProvider).value;
    if (site == null) return const Scaffold();
    final views = ref.watch(viewsProvider(site.site.id)).value ?? const [];
    final loaded = views.where((v) => v.id == widget.viewId).firstOrNull;
    final view = draft ?? loaded;
    if (view == null) return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator(strokeWidth: 2)));
    final faces = site.organisation.facesEnabled;
    SwitchListTile feature(String title, String body, bool value, AnalyticsView Function(bool) apply, {bool enabled = true, bool beta = false}) =>
        SwitchListTile(
          title: Row(
            children: [
              Flexible(child: Text(title)),
              if (beta) ...[const SizedBox(width: 8), Tag(l10n.commonBeta, tone: TagTone.info, dense: true)],
            ],
          ),
          subtitle: Text(body),
          value: value,
          onChanged: enabled && view.enabled && !busy ? (next) => save(apply(next)) : null,
        );
    return Scaffold(
      appBar: AppBar(
        title: Text(view.title),
        actions: [
          if (busy)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Gaps.xxl),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
            child: InkWell(
              borderRadius: BorderRadius.circular(Radii.medium),
              onTap: () => ZoneEditorRoute(viewId: view.id).push<void>(context),
              child: ViewThumb(view: view),
            ),
          ),
          const SizedBox(height: Gaps.md),
          TileGroup(
            children: [
              SwitchListTile(
                title: Text(l10n.analyticsEnabled),
                value: view.enabled,
                onChanged: busy ? null : (value) => save(view.copyWith(enabled: value)),
              ),
            ],
          ),
          SectionHeader(l10n.analyticsProfile),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final profile in Profile.values)
                  ChoiceChip(
                    label: Text(l10n.profile(profile)),
                    selected: view.profile == profile,
                    onSelected: view.enabled && !busy ? (_) => save(view.copyWith(profile: profile)) : null,
                  ),
              ],
            ),
          ),
          SectionHeader(l10n.analyticsStream),
          TileGroup(
            children: [
              RadioGroup<StreamQuality>(
                groupValue: view.stream,
                onChanged: (value) {
                  if (value != null && view.enabled && !busy) save(view.copyWith(stream: value));
                },
                child: Column(
                  children: [
                    RadioListTile<StreamQuality>(value: StreamQuality.sub, title: Text(l10n.analyticsStreamSub)),
                    RadioListTile<StreamQuality>(value: StreamQuality.main, title: Text(l10n.analyticsStreamMain)),
                  ],
                ),
              ),
            ],
          ),
          SectionHeader(l10n.analyticsFeatures),
          TileGroup(
            children: [
              feature(l10n.featureTamper, l10n.featureTamperBody, view.tamper, (v) => view.copyWith(tamper: v)),
              feature(
                l10n.featureFaces,
                faces ? l10n.featureFacesBody : l10n.featureFacesLocked,
                view.faces && faces,
                (v) => view.copyWith(faces: v),
                enabled: faces,
              ),
              feature(l10n.featureAppearance, l10n.featureAppearanceBody, view.appearance, (v) => view.copyWith(appearance: v), beta: true),
              feature(l10n.featureFalls, l10n.featureFallsBody, view.falls, (v) => view.copyWith(falls: v), beta: true),
              feature(l10n.featurePlates, l10n.featurePlatesBody, view.plates, (v) => view.copyWith(plates: v), beta: true),
              if (view.ptz) ...[
                feature(l10n.featureMoving, l10n.featureMovingBody, view.moving, (v) => view.copyWith(moving: v)),
                feature(l10n.featureFollow, l10n.featureFollowBody, view.follow, (v) => view.copyWith(follow: v)),
              ],
            ],
          ),
          SectionHeader(
            l10n.analyticsRules,
            padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.xl, Gaps.sm, Gaps.xs),
            action: TextButton.icon(
              onPressed: () => ZoneEditorRoute(viewId: view.id).push<void>(context),
              icon: const Icon(Icons.draw_outlined, size: 18),
              label: Text(l10n.analyticsEdit),
            ),
          ),
          if (view.zones.isEmpty && view.lines.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
              child: Text(l10n.analyticsNoRules, style: context.text.bodyMedium?.copyWith(color: p.text3)),
            )
          else
            TileGroup(
              children: [
                for (final zone in view.zones)
                  ListTile(
                    leading: const Icon(Icons.pentagon_outlined),
                    title: Text(zone.name),
                    subtitle: Text(
                      [
                        if (zone.wholeView) l10n.analyticsWholeView,
                        zone.labels.map(l10n.label).join(', '),
                        l10n.alertMode(zone.alert.mode),
                      ].where((s) => s.isNotEmpty).join(', '),
                    ),
                    trailing: zone.suspended ? Tag(l10n.analyticsSuspended, tone: TagTone.warning, dense: true) : null,
                    onTap: () => ZoneEditorRoute(viewId: view.id).push<void>(context),
                  ),
                for (final line in view.lines)
                  ListTile(
                    leading: const Icon(Icons.timeline_rounded),
                    title: Text(line.name),
                    subtitle: Text('${l10n.direction(line.direction)}, ${line.labels.map(l10n.label).join(', ')}'),
                    onTap: () => ZoneEditorRoute(viewId: view.id).push<void>(context),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
