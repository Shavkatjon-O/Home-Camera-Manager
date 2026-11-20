import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/app/routes.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/format.dart';
import 'package:smart_surveillance/core/providers.dart';
import 'package:smart_surveillance/core/widgets/media_view.dart';
import 'package:smart_surveillance/core/widgets/surfaces.dart';
import 'package:smart_surveillance/features/events/domain/models.dart';
import 'package:smart_surveillance/features/events/presentation/labels.dart';
/// A small preview image of an event, with its object boxes drawn over it.
class EventThumb extends ConsumerWidget {
  /// Creates a preview of [event] that is [width] wide, with rounded corners of [radius].
  const EventThumb({super.key, required this.event, this.width = 104, this.boxes = true, this.radius = 8});

  /// The event to preview.
  final CameraEvent event;
  /// The width of the preview in logical pixels.
  final double width;
  /// Whether the detected objects are outlined on the image.
  final bool boxes;
  /// The corner radius of the preview.
  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final source = event.hasSnapshot ? ref.read(backendProvider).events.thumbnail(event) : null;
    return SizedBox(
      width: width,
      child: Frame(
        aspect: 16 / 9,
        radius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (source != null)
              MediaView(source: source, showStamp: false)
            else
              Center(child: Icon(kindIcon(event.kind), color: context.palette.text3)),
            if (boxes && event.boxes.isNotEmpty)
              BoxOverlay(boxes: [for (final box in event.boxes) (box: box.box, label: box.label, caption: null)]),
          ],
        ),
      ),
    );
  }
}

/// The status tags of an event, such as alert, reviewed, ongoing and beta.
class EventTags extends StatelessWidget {
  /// Creates the tags for [event], using the compact style when [dense] is true.
  const EventTags({super.key, required this.event, this.dense = true});

  /// The event the tags describe.
  final CameraEvent event;
  /// Whether the tags use the compact style.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        if (event.alert && !event.acknowledged) Tag(l10n.eventAlert, tone: TagTone.alert, dense: dense),
        if (event.alert && event.acknowledged) Tag(l10n.eventReviewed, tone: TagTone.muted, dense: dense),
        if (event.ongoing) Tag(l10n.eventOngoing, tone: TagTone.warning, dense: dense),
        if (event.kind.beta) Tag(l10n.commonBeta, tone: TagTone.info, dense: dense),
      ],
    );
  }
}

/// A list row summarizing one event, opening its details when tapped.
class EventRow extends ConsumerWidget {
  /// Creates a row for [event]; [onTap] replaces the default of opening the event.
  const EventRow({super.key, required this.event, this.onTap});

  /// The event shown in the row.
  final CameraEvent event;
  /// Called when the row is tapped, or null to open the event screen.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final format = Formats(context, ref.read(clockProvider)());
    final place = [event.cameraName, if (event.viewName != null && event.viewName != event.cameraName) event.viewName!];
    final unread = event.alert && !event.acknowledged;
    return InkWell(
      onTap: onTap ?? () => EventRoute(eventId: event.id).push<void>(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Gaps.page, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EventThumb(event: event),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          l10n.eventTitle(event),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodyLarge?.copyWith(
                            fontWeight: unread ? FontWeight.w600 : FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(format.time(event.startedAt), style: dataStyle(context, size: 12, color: p.text3)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(kindIcon(event.kind), size: 14, color: p.text3),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          place.join(', '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  if (event.alert || event.ongoing || event.kind.beta) ...[
                    const SizedBox(height: 6),
                    EventTags(event: event),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A card summarizing one event, for horizontal lists.
class EventCard extends ConsumerWidget {
  /// Creates a card for [event] that is [width] wide.
  const EventCard({super.key, required this.event, this.width = 220});

  /// The event shown on the card.
  final CameraEvent event;
  /// The width of the card in logical pixels.
  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final format = Formats(context, ref.read(clockProvider)());
    return SizedBox(
      width: width,
      child: Material(
        color: p.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.large), side: BorderSide(color: p.border)),
        child: InkWell(
          onTap: () => EventRoute(eventId: event.id).push<void>(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  EventThumb(event: event, width: width, radius: 0),
                  if (event.alert && !event.acknowledged)
                    Positioned(top: 8, left: 8, child: Tag(l10n.eventAlert, tone: TagTone.alert, dense: true)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.eventTitle(event),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${format.ago(event.startedAt)}, ${event.cameraName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
