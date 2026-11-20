import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/app/routes.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/format.dart';
import 'package:smart_surveillance/core/providers.dart';
import 'package:smart_surveillance/core/widgets/media_view.dart';
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/core/widgets/surfaces.dart';
import 'package:smart_surveillance/features/events/domain/models.dart';
import 'package:smart_surveillance/features/events/presentation/event_feed.dart';
import 'package:smart_surveillance/features/events/presentation/labels.dart';
import 'package:smart_surveillance/features/events/presentation/providers.dart';
import 'package:smart_surveillance/features/investigation/domain/models.dart';
import 'package:smart_surveillance/features/media/presentation/clip_player.dart';
import 'package:smart_surveillance/features/tenancy/domain/models.dart';
import 'package:smart_surveillance/features/tenancy/presentation/current_site.dart';

/// Loads the event with the given id.
final eventProvider = FutureProvider.autoDispose.family<CameraEvent, String>(
  (ref, id) => ref.read(backendProvider).events.event(id),
);

/// Loads the cross-camera journey for the event with the given id, or null when none exists.
final journeyProvider = FutureProvider.autoDispose.family<Journey?, String>(
  (ref, id) => ref.read(backendProvider).analytics.journey(id),
);

/// The details of one event: media, facts and actions.
class EventScreen extends ConsumerStatefulWidget {
  /// Creates the screen for the event [eventId].
  const EventScreen({super.key, required this.eventId});

  /// The id of the event shown.
  final String eventId;

  @override
  ConsumerState<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends ConsumerState<EventScreen> {
  bool clip = false;
  bool boxes = true;
  bool busy = false;
  CameraEvent? updated;

  Future<void> acknowledge(CameraEvent event, SiteContext site) async {
    setState(() => busy = true);
    try {
      final result = await ref.read(backendProvider).events.acknowledge(event.id);
      setState(() => updated = result);
      ref.read(eventFeedProvider(site.site.id).notifier).replace(result);
      ref.refreshSite(site.site.id);
      if (mounted) showMessage(context, context.l10n.eventAcknowledged);
    } catch (failure) {
      if (mounted) showFailure(context, failure);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> share(CameraEvent event) async {
    try {
      final path = await ref.read(backendProvider).events.downloadClip(event);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(path, mimeType: 'video/mp4')],
          text: event.cameraName,
        ),
      );
    } catch (failure) {
      if (mounted) showFailure(context, failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final value = ref.watch(eventProvider(widget.eventId));
    final site = ref.watch(currentSiteProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          value.value == null ? l10n.eventsTitle : l10n.kind((updated ?? value.value!).kind),
        ),
        actions: [
          if (value.value?.hasClip == true && (site?.can(Role.operator) ?? false))
            IconButton(
              tooltip: l10n.eventShareClip,
              onPressed: () => share(updated ?? value.value!),
              icon: const Icon(Icons.ios_share_rounded),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: AsyncBody(
        value: value,
        onRetry: () => ref.invalidate(eventProvider(widget.eventId)),
        data: (loaded) => details(context, updated ?? loaded, site),
      ),
    );
  }

  Widget details(BuildContext context, CameraEvent event, SiteContext? site) {
    final l10n = context.l10n;
    final p = context.palette;
    final format = Formats(context, ref.read(clockProvider)());
    final events = ref.read(backendProvider).events;
    final clipSource = events.clip(event);
    final operator = site?.can(Role.operator) ?? false;
    final faces = site?.organisation.facesEnabled ?? false;
    return ListView(
      padding: const EdgeInsets.only(bottom: Gaps.xxl),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
          child: Column(
            children: [
              if (clipSource != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: Gaps.sm),
                  child: SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<bool>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: false,
                          label: Text(l10n.eventSnapshot),
                          icon: const Icon(Icons.image_outlined, size: 18),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text(l10n.eventClip),
                          icon: const Icon(Icons.movie_outlined, size: 18),
                        ),
                      ],
                      selected: {clip},
                      onSelectionChanged: (value) => setState(() => clip = value.first),
                    ),
                  ),
                ),
              if (clip && clipSource != null)
                ClipPlayer(key: ValueKey(event.id), clip: clipSource, aspect: event.aspect)
              else
                Semantics(
                  image: true,
                  label: l10n.eventTitle(event),
                  child: GestureDetector(
                    onTap: () => setState(() => boxes = !boxes),
                    child: Frame(
                      aspect: event.aspect,
                      radius: Radii.medium,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (event.hasSnapshot) MediaView(source: events.snapshot(event)),
                          if (boxes && event.boxes.isNotEmpty)
                            BoxOverlay(
                              boxes: [
                                for (final box in event.boxes)
                                  (box: box.box, label: box.label, caption: l10n.label(box.label)),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.lg, Gaps.page, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.eventTitle(event), style: context.text.headlineSmall),
              const SizedBox(height: 6),
              Text(
                '${format.dayHeader(event.startedAt)}, ${format.timeSeconds(event.startedAt)}',
                style: dataStyle(context, size: 13, color: p.text2),
              ),
              const SizedBox(height: Gaps.sm),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  Tag(l10n.kind(event.kind), icon: kindIcon(event.kind)),
                  if (event.alert && !event.acknowledged) Tag(l10n.eventAlert, tone: TagTone.alert),
                  if (event.acknowledged)
                    Tag(l10n.eventReviewed, tone: TagTone.ok, icon: Icons.check_rounded),
                  if (event.ongoing) Tag(l10n.eventOngoing, tone: TagTone.warning),
                  if (event.kind.beta) Tag(l10n.commonBeta, tone: TagTone.info),
                ],
              ),
            ],
          ),
        ),
        Builder(
          builder: (context) {
            final actions = <Widget>[
              if (event.alert && !event.acknowledged && operator)
                FilledButton.icon(
                  onPressed: busy || site == null ? null : () => acknowledge(event, site),
                  icon: const Icon(Icons.check_rounded, size: 19),
                  label: Text(l10n.eventAcknowledge),
                ),
              if (event.label == 'person' ||
                  event.kind == EventKind.faceKnown ||
                  event.kind == EventKind.faceUnknown)
                OutlinedButton.icon(
                  onPressed: () => FindPersonRoute(eventId: event.id).push<void>(context),
                  icon: const Icon(Icons.person_search_outlined, size: 19),
                  label: Text(l10n.eventFindPerson),
                ),
              if (faces &&
                  event.face?.status == FaceStatus.unknown &&
                  event.face?.clusterId != null)
                OutlinedButton.icon(
                  onPressed: () =>
                      ClusterRoute(clusterId: event.face!.clusterId!).push<void>(context),
                  icon: const Icon(Icons.badge_outlined, size: 19),
                  label: Text(l10n.eventWhoIsThis),
                ),
            ];
            if (actions.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.lg, Gaps.page, 0),
              child: Wrap(spacing: 8, runSpacing: 8, children: actions),
            );
          },
        ),
        if (event.face != null) FaceSection(event: event),
        SectionHeader(l10n.eventDetails),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
          child: Panel(
            padding: const EdgeInsets.symmetric(horizontal: Gaps.lg, vertical: Gaps.sm),
            child: Column(
              children: [
                ReadOut(label: l10n.eventCamera, value: event.cameraName),
                if (event.viewName != null) ReadOut(label: l10n.eventView, value: event.viewName!),
                if (event.zoneName != null) ReadOut(label: l10n.eventZone, value: event.zoneName!),
                if (event.lineName != null) ReadOut(label: l10n.eventLine, value: event.lineName!),
                if (event.direction != null)
                  ReadOut(
                    label: l10n.eventDirection,
                    value: event.direction == 'in' ? l10n.eventDirectionIn : l10n.eventDirectionOut,
                  ),
                if (event.count != null && event.count! > 0)
                  ReadOut(label: l10n.eventObjects, value: '${event.count}', mono: true),
                ReadOut(
                  label: l10n.eventStarted,
                  value: format.timeSeconds(event.startedAt),
                  mono: true,
                ),
                ReadOut(
                  label: l10n.eventDuration,
                  value: format.duration(event.duration),
                  mono: true,
                ),
                ReadOut(
                  label: l10n.eventSource,
                  value: event.source == EventSource.analytics
                      ? l10n.eventSourceAnalytics
                      : l10n.eventSourceCamera,
                ),
              ],
            ),
          ),
        ),
        if (event.hasPlates) PlatesSection(event: event),
        if (event.label == 'person' || event.face != null) JourneySection(eventId: event.id),
      ],
    );
  }
}

/// The section of an event screen describing the recognized or unknown face.
class FaceSection extends ConsumerWidget {
  /// Creates the section for the face of [event].
  const FaceSection({super.key, required this.event});

  /// The event whose face is shown; it must have face information.
  final CameraEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final face = event.face!;
    final known = face.status == FaceStatus.known;
    final source = ref.read(backendProvider).events.faceCrop(event);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(l10n.eventFace),
        TileGroup(
          children: [
            ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(width: 44, height: 44, child: MediaView(source: source)),
              ),
              title: Text(
                known
                    ? (face.personName ?? l10n.kindFaceKnown)
                    : (face.clusterLabel ?? l10n.kindFaceUnknown),
              ),
              subtitle: face.confidence == null
                  ? null
                  : Text(l10n.eventConfidence((face.confidence! * 100).round())),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                if (known && face.personId != null) {
                  PersonRoute(personId: face.personId!).push<void>(context);
                }
                if (!known && face.clusterId != null) {
                  ClusterRoute(clusterId: face.clusterId!).push<void>(context);
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

/// The section of an event screen listing the license plate readings.
class PlatesSection extends StatelessWidget {
  /// Creates the section for the plates of [event].
  const PlatesSection({super.key, required this.event});

  /// The event whose plates are shown.
  final CameraEvent event;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final status = switch (event.plateStatus) {
      'infrared' => l10n.plateInfrared,
      'no_plate' => l10n.plateNone,
      'too_small' => l10n.plateSmall,
      'pending' => l10n.platePending,
      null => null,
      _ => l10n.plateUnreadable,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          l10n.eventPlate,
          action: Tag(l10n.commonBeta, tone: TagTone.info, dense: true),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
          child: Panel(
            child: event.plates.isEmpty
                ? Text(
                    status ?? l10n.plateUnreadable,
                    style: context.text.bodyMedium?.copyWith(color: p.text2),
                  )
                : Column(
                    children: [
                      for (final plate in event.plates)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: p.surface2,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: p.borderStrong),
                                ),
                                child: Text(
                                  plate.display,
                                  style: dataStyle(context, size: 16, weight: FontWeight.w600),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${(plate.score * 100).round()}%',
                                style: dataStyle(context, size: 13, color: p.text2),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                l10n.eventPlateReads(plate.reads),
                                style: context.text.bodySmall,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

/// The section of an event screen showing where the person was seen on other cameras.
class JourneySection extends ConsumerWidget {
  /// Creates the section for the journey of event [eventId].
  const JourneySection({super.key, required this.eventId});

  /// The id of the event whose journey is shown.
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final journey = ref.watch(journeyProvider(eventId)).value;
    if (journey == null) return const SizedBox.shrink();
    final format = Formats(context, ref.read(clockProvider)());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          l10n.eventJourney,
          action: Tag(l10n.commonBeta, tone: TagTone.info, dense: true),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
          child: Panel(
            child: Column(
              children: [
                for (var i = 0; i < journey.steps.length; i++)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: 20,
                          child: Column(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                margin: const EdgeInsets.only(top: 5),
                                decoration: BoxDecoration(
                                  color: journey.steps[i].eventId == eventId ? p.text : p.surface3,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: p.borderStrong),
                                ),
                              ),
                              if (i < journey.steps.length - 1)
                                Expanded(child: Container(width: 1.5, color: p.borderInput)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  journey.steps[i].cameraName,
                                  style: context.text.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  [
                                    format.timeSeconds(journey.steps[i].startedAt),
                                    if (journey.steps[i].similarity != null)
                                      l10n.findPersonMatch(
                                        (journey.steps[i].similarity! * 100).round(),
                                      ),
                                  ].join(', '),
                                  style: dataStyle(context, size: 12, color: p.text3),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (journey.steps[i].eventId != null && journey.steps[i].eventId != eventId)
                          IconButton(
                            onPressed: () =>
                                EventRoute(eventId: journey.steps[i].eventId!).push<void>(context),
                            icon: const Icon(Icons.chevron_right_rounded),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
