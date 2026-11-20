import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/format.dart';
import 'package:smart_surveillance/core/providers.dart';
import 'package:smart_surveillance/features/devices/presentation/providers.dart';
import 'package:smart_surveillance/features/events/domain/models.dart';
import 'package:smart_surveillance/features/events/presentation/labels.dart';
final facetsProvider = FutureProvider.autoDispose.family(
  (ref, String siteId) => ref.read(backendProvider).search.facets(siteId),
);

Future<EventFilter?> showFilterSheet(
  BuildContext context, {
  required String siteId,
  required EventFilter filter,
  bool extended = false,
}) => showModalBottomSheet<EventFilter>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (context) => FilterSheet(siteId: siteId, initial: filter, extended: extended),
);

class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({super.key, required this.siteId, required this.initial, this.extended = false});

  final String siteId;
  final EventFilter initial;
  final bool extended;

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late EventFilter filter = widget.initial;

  Set<T> toggle<T>(Set<T> set, T value) => set.contains(value) ? ({...set}..remove(value)) : {...set, value};

  Future<void> pickDay() async {
    final now = ref.read(clockProvider)();
    final day = await showDatePicker(
      context: context,
      initialDate: filter.day ?? now,
      firstDate: now.subtract(const Duration(days: 400)),
      lastDate: now,
    );
    if (day != null) setState(() => filter = filter.copyWith(day: day));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final cameras = ref.watch(camerasProvider(widget.siteId)).value ?? const [];
    final facets = widget.extended ? ref.watch(facetsProvider(widget.siteId)).value : null;
    final format = Formats(context, ref.read(clockProvider)());
    Widget group(String title, List<Widget> chips) => Padding(
      padding: const EdgeInsets.only(bottom: Gaps.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.text.titleSmall?.copyWith(color: p.text2)),
          const SizedBox(height: Gaps.sm),
          Wrap(spacing: 8, runSpacing: 8, children: chips),
        ],
      ),
    );
    FilterChip chip(String label, bool selected, VoidCallback onTap) => FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
    final labels = facets?.labels ?? const ['person', 'car', 'truck', 'bicycle', 'dog', 'cat', 'backpack', 'handbag', 'suitcase'];
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.86,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Gaps.page + 4, 0, Gaps.sm, Gaps.sm),
            child: Row(
              children: [
                Expanded(child: Text(l10n.eventsFilters, style: context.text.titleLarge)),
                TextButton(
                  onPressed: () => setState(() => filter = const EventFilter()),
                  child: Text(l10n.commonClear),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(Gaps.page + 4, Gaps.sm, Gaps.page + 4, Gaps.lg),
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.eventsAlertsOnly),
                  value: filter.alertsOnly,
                  onChanged: (value) => setState(() => filter = filter.copyWith(alertsOnly: value)),
                ),
                const SizedBox(height: Gaps.sm),
                group(l10n.filterDay, [
                  chip(l10n.filterAnyDay, filter.day == null, () => setState(() => filter = filter.copyWith(day: null))),
                  chip(
                    filter.day == null ? l10n.commonToday : format.dayHeader(filter.day!),
                    filter.day != null,
                    pickDay,
                  ),
                ]),
                group(l10n.filterCameras, [
                  for (final camera in cameras)
                    chip(
                      camera.name,
                      filter.cameraIds.contains(camera.id),
                      () => setState(() => filter = filter.copyWith(cameraIds: toggle(filter.cameraIds, camera.id))),
                    ),
                ]),
                group(l10n.filterKinds, [
                  for (final kind in EventKind.values)
                    FilterChip(
                      avatar: Icon(kindIcon(kind), size: 16),
                      label: Text(l10n.kind(kind)),
                      selected: filter.kinds.contains(kind),
                      onSelected: (_) => setState(() => filter = filter.copyWith(kinds: toggle(filter.kinds, kind))),
                    ),
                ]),
                group(l10n.filterLabels, [
                  for (final label in labels)
                    chip(
                      l10n.label(label),
                      filter.labels.contains(label),
                      () => setState(() => filter = filter.copyWith(labels: toggle(filter.labels, label))),
                    ),
                ]),
                if (facets != null) ...[
                  if (facets.views.isNotEmpty)
                    group(l10n.filterViews, [
                      for (final view in facets.views)
                        chip(
                          view.name,
                          filter.viewIds.contains(view.id),
                          () => setState(() => filter = filter.copyWith(viewIds: toggle(filter.viewIds, view.id))),
                        ),
                    ]),
                  if (facets.zones.isNotEmpty)
                    group(l10n.filterZones, [
                      for (final zone in facets.zones)
                        chip(
                          zone.name,
                          filter.zones.contains(zone.id),
                          () => setState(() => filter = filter.copyWith(zones: toggle(filter.zones, zone.id))),
                        ),
                    ]),
                  if (facets.lines.isNotEmpty)
                    group(l10n.filterLines, [
                      for (final line in facets.lines)
                        chip(
                          line.name,
                          filter.lines.contains(line.id),
                          () => setState(() => filter = filter.copyWith(lines: toggle(filter.lines, line.id))),
                        ),
                    ]),
                  if (facets.people.isNotEmpty || facets.clusters.isNotEmpty)
                    group(l10n.filterPerson, [
                      for (final person in facets.people)
                        chip(
                          person.name,
                          filter.personId == person.id,
                          () => setState(
                            () => filter = filter.copyWith(
                              personId: filter.personId == person.id ? null : person.id,
                              clusterId: null,
                            ),
                          ),
                        ),
                      for (final cluster in facets.clusters)
                        chip(
                          cluster.name,
                          filter.clusterId == cluster.id,
                          () => setState(
                            () => filter = filter.copyWith(
                              clusterId: filter.clusterId == cluster.id ? null : cluster.id,
                              personId: null,
                            ),
                          ),
                        ),
                    ]),
                ],
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Gaps.page + 4, Gaps.sm, Gaps.page + 4, Gaps.md),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(onPressed: () => Navigator.of(context).pop(filter), child: Text(l10n.filterShow)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
