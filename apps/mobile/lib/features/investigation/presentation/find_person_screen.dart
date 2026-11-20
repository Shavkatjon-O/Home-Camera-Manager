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
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/core/widgets/surfaces.dart';
import 'package:smart_surveillance/features/investigation/domain/models.dart';
final findPersonProvider = FutureProvider.autoDispose.family<List<AppearanceMatch>, String>(
  (ref, eventId) => ref.read(backendProvider).analytics.findPerson(eventId),
);

class FindPersonScreen extends ConsumerWidget {
  const FindPersonScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final value = ref.watch(findPersonProvider(eventId));
    final format = Formats(context, ref.read(clockProvider)());
    return Scaffold(
      appBar: AppBar(title: Text(l10n.findPersonTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Gaps.xxl),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Gaps.page, 0, Gaps.page, Gaps.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(l10n.findPersonBody, style: context.text.bodyMedium?.copyWith(color: p.text2))),
                const SizedBox(width: 8),
                Tag(l10n.commonBeta, tone: TagTone.info, dense: true),
              ],
            ),
          ),
          value.when(
            loading: () => const SizedBox(height: 400, child: ListSkeleton(rows: 5)),
            error: (error, _) => ErrorState(error: error, onRetry: () => ref.invalidate(findPersonProvider(eventId))),
            data: (matches) => matches.isEmpty
                ? EmptyState(icon: Icons.person_search_outlined, title: l10n.findPersonEmpty)
                : Column(
                    children: [
                      for (final match in matches)
                        InkWell(
                          onTap: match.eventId == null
                              ? null
                              : () => EventRoute(eventId: match.eventId!).push<void>(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Gaps.page, vertical: 10),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 104,
                                  child: Frame(aspect: 16 / 9, radius: 8, child: MediaView(source: match.thumbnail, showStamp: false)),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(match.cameraName, style: context.text.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                                      Text(format.when(match.startedAt), style: context.text.bodySmall),
                                    ],
                                  ),
                                ),
                                SimilarityMeter(value: match.similarity),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class SimilarityMeter extends StatelessWidget {
  const SimilarityMeter({super.key, required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final percent = (value * 100).round();
    return Semantics(
      label: context.l10n.findPersonMatch(percent),
      child: SizedBox(
        width: 64,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('$percent%', style: dataStyle(context, size: 13, weight: FontWeight.w500)),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(value: value.clamp(0, 1), minHeight: 4, color: p.text, backgroundColor: p.surface3),
            ),
          ],
        ),
      ),
    );
  }
}
