import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/providers.dart';
import '../../app/routes.dart';
import '../../core/format.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/theme.dart';
import '../../data/models/event.dart';
import '../../data/models/people.dart';
import '../../l10n/l10n.dart';
import '../../widgets/event_tiles.dart';
import '../../widgets/labels.dart';
import '../../widgets/media_view.dart';
import '../../widgets/states.dart';
import '../../widgets/surfaces.dart';
import '../events/filter_sheet.dart';
import 'people_screens.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.tab = 0});

  final int tab;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> with SingleTickerProviderStateMixin {
  late final TabController tabs = TabController(length: 4, vsync: this, initialIndex: widget.tab.clamp(0, 3));

  @override
  void didUpdateWidget(SearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tab != widget.tab) tabs.animateTo(widget.tab.clamp(0, 3));
  }

  @override
  void dispose() {
    tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final site = ref.watch(currentSiteProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.searchTitle),
        bottom: TabBar(
          controller: tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          tabs: [
            Tab(text: l10n.searchEvents),
            Tab(text: l10n.searchPeople),
            Tab(text: l10n.searchFaces),
            Tab(text: l10n.searchPlates),
          ],
        ),
      ),
      body: site == null
          ? const SizedBox.shrink()
          : TabBarView(
              controller: tabs,
              children: [
                EventSearch(siteId: site.site.id),
                site.organisation.facesEnabled ? PeopleTab(organisationId: site.organisation.id) : const FacesOff(),
                site.organisation.facesEnabled
                    ? FaceSearch(organisationId: site.organisation.id)
                    : const FacesOff(),
                PlateSearch(siteId: site.site.id),
              ],
            ),
    );
  }
}

class FacesOff extends StatelessWidget {
  const FacesOff({super.key});

  @override
  Widget build(BuildContext context) => EmptyState(
    icon: Icons.face_retouching_off_outlined,
    title: context.l10n.facesOffTitle,
    body: context.l10n.facesOffBody,
    action: OutlinedButton(onPressed: () => const FacesRoute().go(context), child: Text(context.l10n.facesTurnOn)),
  );
}

class EventSearch extends ConsumerStatefulWidget {
  const EventSearch({super.key, required this.siteId});

  final String siteId;

  @override
  ConsumerState<EventSearch> createState() => _EventSearchState();
}

class _EventSearchState extends ConsumerState<EventSearch> with AutomaticKeepAliveClientMixin {
  EventFilter filter = const EventFilter();
  int range = 1;
  Future<EventPage>? results;

  @override
  bool get wantKeepAlive => true;

  EventFilter withRange(EventFilter value) {
    final now = ref.read(clockProvider)();
    final from = switch (range) {
      0 => now.subtract(const Duration(hours: 24)),
      1 => now.subtract(const Duration(days: 7)),
      _ => now.subtract(const Duration(days: 30)),
    };
    return value.copyWith(from: from, until: now);
  }

  void run() => setState(() => results = ref.read(backendProvider).search.search(widget.siteId, withRange(filter), pageSize: 60));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => run());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = context.l10n;
    final p = context.palette;
    final ranges = [l10n.searchLast24h, l10n.searchLast7d, l10n.searchLast30d];
    final parts = <String>[
      ...filter.kinds.map(l10n.kind),
      ...filter.labels.map(l10n.label),
      ...filter.zones,
      ...filter.lines,
      if (filter.alertsOnly) l10n.eventsAlertsOnly,
    ];
    return ListView(
      padding: const EdgeInsets.only(bottom: Gaps.xxl),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.lg, Gaps.page, 0),
          child: Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.searchHint, style: context.text.bodyMedium?.copyWith(color: p.text2)),
                const SizedBox(height: Gaps.md),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<int>(
                    showSelectedIcon: false,
                    segments: [for (var i = 0; i < 3; i++) ButtonSegment(value: i, label: Text(ranges[i], maxLines: 1))],
                    selected: {range},
                    onSelectionChanged: (value) {
                      setState(() => range = value.first);
                      run();
                    },
                  ),
                ),
                const SizedBox(height: Gaps.md),
                OutlinedButton.icon(
                  onPressed: () async {
                    final next = await showFilterSheet(context, siteId: widget.siteId, filter: filter, extended: true);
                    if (next == null) return;
                    setState(() => filter = next);
                    run();
                  },
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: Text(
                    filter.activeCount == 0 ? l10n.eventsFilters : l10n.eventsFilterCount(filter.activeCount),
                  ),
                ),
                if (parts.isNotEmpty) ...[
                  const SizedBox(height: Gaps.sm),
                  Wrap(spacing: 6, runSpacing: 6, children: [for (final part in parts) Tag(part)]),
                ],
              ],
            ),
          ),
        ),
        FutureBuilder<EventPage>(
          future: results,
          builder: (context, snapshot) {
            if (snapshot.hasError) return ErrorState(error: snapshot.error!, onRetry: run, compact: true);
            if (!snapshot.hasData) {
              return const SizedBox(height: 320, child: ListSkeleton(rows: 4));
            }
            final page = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(l10n.searchResults(page.total)),
                if (page.items.isEmpty)
                  EmptyState(icon: Icons.search_off_rounded, title: l10n.eventsEmpty, body: l10n.eventsEmptyBody, compact: true)
                else
                  for (final event in page.items) EventRow(event: event),
              ],
            );
          },
        ),
      ],
    );
  }
}

class FaceSearch extends ConsumerStatefulWidget {
  const FaceSearch({super.key, required this.organisationId});

  final String organisationId;

  @override
  ConsumerState<FaceSearch> createState() => _FaceSearchState();
}

class _FaceSearchState extends ConsumerState<FaceSearch> with AutomaticKeepAliveClientMixin {
  Uint8List? photo;
  Future<List<SimilarFace>>? results;

  @override
  bool get wantKeepAlive => true;

  Future<void> pick(ImageSource source) async {
    final file = await ImagePicker().pickImage(source: source, maxWidth: 1600, imageQuality: 88);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      photo = bytes;
      results = ref.read(backendProvider).search.similarFaces(widget.organisationId, photo: bytes);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = context.l10n;
    final p = context.palette;
    final demo = ref.read(backendProvider).demo;
    return ListView(
      padding: const EdgeInsets.only(bottom: Gaps.xxl),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.lg, Gaps.page, 0),
          child: Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (photo != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(Radii.medium),
                        child: Image.memory(photo!, width: 56, height: 56, fit: BoxFit.cover),
                      )
                    else
                      const IconBadge(icon: Icons.face_outlined, size: 56),
                    const SizedBox(width: Gaps.md),
                    Expanded(child: Text(l10n.searchFacesTitle, style: context.text.titleMedium)),
                  ],
                ),
                const SizedBox(height: Gaps.md),
                Text(l10n.searchFacesBody, style: context.text.bodyMedium?.copyWith(color: p.text2)),
                const SizedBox(height: Gaps.lg),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => pick(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined, size: 18),
                        label: Text(l10n.searchFacesPhoto),
                      ),
                    ),
                    const SizedBox(width: Gaps.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => pick(ImageSource.camera),
                        icon: const Icon(Icons.photo_camera_outlined, size: 18),
                        label: Text(l10n.searchFacesCamera),
                      ),
                    ),
                  ],
                ),
                if (demo && results == null) ...[
                  const SizedBox(height: Gaps.sm),
                  TextButton(
                    onPressed: () => setState(
                      () => results = ref.read(backendProvider).search.similarFaces(widget.organisationId, sampleId: 's-a3'),
                    ),
                    child: Text(l10n.commonDemo),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (results != null)
          FutureBuilder<List<SimilarFace>>(
            future: results,
            builder: (context, snapshot) {
              if (snapshot.hasError) return ErrorState(error: snapshot.error!, compact: true);
              if (!snapshot.hasData) return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
              final faces = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(l10n.searchFacesResults),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.72,
                    children: [for (final face in faces) SimilarFaceTile(face: face)],
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}

class SimilarFaceTile extends ConsumerWidget {
  const SimilarFaceTile({super.key, required this.face});

  final SimilarFace face;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final format = Formats(context, ref.read(clockProvider)());
    final name = face.personName ?? face.clusterLabel ?? '';
    return InkWell(
      borderRadius: BorderRadius.circular(Radii.medium),
      onTap: () {
        if (face.personId != null) {
          PersonRoute(personId: face.personId!).push<void>(context);
        } else if (face.clusterId != null) {
          ClusterRoute(clusterId: face.clusterId!).push<void>(context);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Radii.medium),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MediaView(source: face.crop),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(color: const Color(0xB3000000), borderRadius: BorderRadius.circular(4)),
                      child: Text(
                        '${(face.score * 100).round()}%',
                        style: dataStyle(context, size: 11, color: const Color(0xFFFFFFFF)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.labelMedium?.copyWith(color: p.text)),
          Text(format.ago(face.seenAt), style: context.text.labelSmall),
        ],
      ),
    );
  }
}

class PlateSearch extends ConsumerStatefulWidget {
  const PlateSearch({super.key, required this.siteId});

  final String siteId;

  @override
  ConsumerState<PlateSearch> createState() => _PlateSearchState();
}

class _PlateSearchState extends ConsumerState<PlateSearch> with AutomaticKeepAliveClientMixin {
  final query = TextEditingController();
  Future<EventPage>? results;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  void run() {
    final text = query.text.trim();
    setState(
      () => results = ref
          .read(backendProvider)
          .search
          .search(widget.siteId, EventFilter(kinds: const {EventKind.vehicle}, plate: text.isEmpty ? null : text), pageSize: 50),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => run());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.only(bottom: Gaps.xxl),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.lg, Gaps.page, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(l10n.searchPlatesTitle, style: context.text.titleMedium)),
                  Tag(l10n.commonBeta, tone: TagTone.info, dense: true),
                ],
              ),
              const SizedBox(height: Gaps.md),
              TextField(
                controller: query,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9 ]'))],
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => run(),
                style: dataStyle(context, size: 16),
                decoration: InputDecoration(
                  hintText: l10n.searchPlatesHint,
                  prefixIcon: const Icon(Icons.directions_car_outlined),
                  suffixIcon: IconButton(tooltip: l10n.searchRun, onPressed: run, icon: const Icon(Icons.search_rounded)),
                ),
              ),
              const SizedBox(height: Gaps.sm),
              Text(l10n.searchPlatesBody, style: context.text.bodySmall),
            ],
          ),
        ),
        if (results != null)
          FutureBuilder<EventPage>(
            future: results,
            builder: (context, snapshot) {
              if (snapshot.hasError) return ErrorState(error: snapshot.error!, compact: true, onRetry: run);
              if (!snapshot.hasData) return const SizedBox(height: 240, child: ListSkeleton(rows: 3));
              final page = snapshot.data!;
              final items = page.items.where((e) => e.hasPlates).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(l10n.searchResults(items.length)),
                  for (final event in items) PlateResult(event: event),
                ],
              );
            },
          ),
      ],
    );
  }
}

class PlateResult extends StatelessWidget {
  const PlateResult({super.key, required this.event});

  final CameraEvent event;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final best = event.plates.isEmpty ? null : event.plates.first;
    return Column(
      children: [
        EventRow(event: event),
        if (best != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(Gaps.page + 118, 0, Gaps.page, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: p.surface2,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: p.borderStrong),
                  ),
                  child: Text(best.display, style: dataStyle(context, size: 13, weight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                Text('${(best.score * 100).round()}%', style: dataStyle(context, size: 12, color: p.text3)),
              ],
            ),
          ),
      ],
    );
  }
}
