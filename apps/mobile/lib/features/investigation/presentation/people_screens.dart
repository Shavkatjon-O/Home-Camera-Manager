import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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
import 'package:smart_surveillance/features/identity/presentation/validators.dart';
import 'package:smart_surveillance/features/investigation/domain/models.dart';
import 'package:smart_surveillance/features/tenancy/domain/models.dart';
import 'package:smart_surveillance/features/tenancy/presentation/current_site.dart';
/// Loads the saved people of the organisation with the given id.
final peopleProvider = FutureProvider.autoDispose.family<List<Person>, String>(
  (ref, organisationId) => ref.read(backendProvider).people.people(organisationId),
);

/// Loads the face clusters of the organisation with the given id.
final clustersProvider = FutureProvider.autoDispose.family<List<FaceCluster>, String>(
  (ref, organisationId) => ref.read(backendProvider).people.clusters(organisationId),
);

/// Loads the person with the given id.
final personProvider = FutureProvider.autoDispose.family<Person, String>(
  (ref, id) => ref.read(backendProvider).people.person(id),
);

/// Loads the face cluster with the given id.
final clusterProvider = FutureProvider.autoDispose.family<FaceCluster, String>(
  (ref, id) => ref.read(backendProvider).people.cluster(id),
);

/// A round face picture, or a colored placeholder when there is none.
class FaceAvatar extends StatelessWidget {
  /// Creates an avatar of [size] showing [source], with a placeholder tinted by [color].
  const FaceAvatar({super.key, required this.source, this.size = 48, this.color});

  /// The face image to show, or null for the placeholder.
  final MediaSource? source;
  /// The diameter of the avatar in logical pixels.
  final double size;
  /// The placeholder tint as an ARGB value, or null for the default.
  final int? color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color == null ? p.borderInput : Color(color!), width: 2),
      ),
      child: ClipOval(child: MediaView(source: source)),
    );
  }
}

/// The list of saved people and unnamed face clusters of an organisation.
class PeopleTab extends ConsumerWidget {
  /// Creates the tab for the organisation [organisationId].
  const PeopleTab({super.key, required this.organisationId});

  /// The id of the organisation whose people are listed.
  final String organisationId;

  /// Asks for a name and notes and creates a new person.
  Future<void> add(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final name = TextEditingController();
    final notes = TextEditingController();
    final key = GlobalKey<FormState>();
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.peopleAdd),
        content: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: name,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: l10n.peopleName),
                validator: (value) => validateRequired(l10n, value),
              ),
              const SizedBox(height: Gaps.md),
              TextFormField(controller: notes, decoration: InputDecoration(labelText: l10n.peopleNotes)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
          FilledButton(
            onPressed: () {
              if (key.currentState!.validate()) Navigator.of(context).pop(true);
            },
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
    if (created != true) return;
    try {
      final person = await ref
          .read(backendProvider)
          .people
          .createPerson(organisationId, name: name.text.trim(), notes: notes.text.trim().isEmpty ? null : notes.text.trim());
      ref.invalidate(peopleProvider(organisationId));
      if (context.mounted) await PersonRoute(personId: person.id).push<void>(context);
    } catch (failure) {
      if (context.mounted) showFailure(context, failure);
    } finally {
      name.dispose();
      notes.dispose();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final people = ref.watch(peopleProvider(organisationId));
    final clusters = ref.watch(clustersProvider(organisationId));
    final admin = ref.watch(currentSiteProvider).value?.can(Role.admin) ?? false;
    final format = Formats(context, ref.read(clockProvider)());
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(peopleProvider(organisationId));
        ref.invalidate(clustersProvider(organisationId));
        await ref.read(peopleProvider(organisationId).future);
      },
      child: AsyncBody(
        value: people,
        onRetry: () => ref.invalidate(peopleProvider(organisationId)),
        loading: const ListSkeleton(),
        data: (list) => ListView(
          padding: const EdgeInsets.only(bottom: Gaps.xxl),
          children: [
            SectionHeader(
              l10n.peopleKnown,
              padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.lg, Gaps.sm, Gaps.xs),
              action: admin
                  ? TextButton.icon(
                      onPressed: () => add(context, ref),
                      icon: const Icon(Icons.person_add_alt_outlined, size: 18),
                      label: Text(l10n.peopleAdd),
                    )
                  : null,
            ),
            if (list.isEmpty)
              EmptyState(icon: Icons.people_outline_rounded, title: l10n.peopleEmpty, body: l10n.peopleEmptyBody, compact: true)
            else
              TileGroup(
                children: [
                  for (final person in list)
                    ListTile(
                      leading: FaceAvatar(source: person.samples.isEmpty ? null : person.samples.first.crop, color: person.color),
                      title: Text(person.name),
                      subtitle: Text(
                        person.lastSeenAt == null ? l10n.peopleNeverSeen : l10n.peopleLastSeen(format.ago(person.lastSeenAt!)),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => PersonRoute(personId: person.id).push<void>(context),
                    ),
                ],
              ),
            SectionHeader(l10n.peopleUnknown),
            clusters.when(
              loading: () => const SizedBox(height: 120, child: ListSkeleton(rows: 2)),
              error: (error, _) => ErrorState(error: error, compact: true),
              data: (clusters) => clusters.isEmpty
                  ? const SizedBox.shrink()
                  : TileGroup(
                      children: [
                        for (final cluster in clusters)
                          ListTile(
                            leading: FaceAvatar(source: cluster.samples.isEmpty ? null : cluster.samples.first.crop),
                            title: Text(cluster.label),
                            subtitle: Text('${l10n.peopleSeen(cluster.seenCount)}, ${format.ago(cluster.lastSeenAt)}'),
                            trailing: admin
                                ? TextButton(
                                    onPressed: () => ClusterRoute(clusterId: cluster.id).push<void>(context),
                                    child: Text(l10n.clusterWhoTitle),
                                  )
                                : null,
                            onTap: () => ClusterRoute(clusterId: cluster.id).push<void>(context),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A grid of face samples, each with an optional delete action.
class SampleGrid extends StatelessWidget {
  /// Creates a grid of [samples]; [onDelete] adds a delete button to each.
  const SampleGrid({super.key, required this.samples, this.onDelete});

  /// The face samples shown.
  final List<FaceSample> samples;
  /// Called with the sample the user chooses to delete, or null to hide the delete buttons.
  final ValueChanged<FaceSample>? onDelete;

  @override
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: 4,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
    children: [
      for (final sample in samples)
        GestureDetector(
          onLongPress: onDelete == null ? null : () => onDelete!(sample),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Radii.medium),
            child: Stack(
              fit: StackFit.expand,
              children: [
                MediaView(source: sample.crop),
                if (sample.source == SampleSource.upload)
                  const Positioned(
                    right: 4,
                    top: 4,
                    child: Icon(Icons.upload_rounded, size: 14, color: Color(0xE6FFFFFF)),
                  ),
              ],
            ),
          ),
        ),
    ],
  );
}

/// A list of the places and times a person or cluster was seen.
class SightingList extends ConsumerWidget {
  /// Creates a list of [sightings].
  const SightingList({super.key, required this.sightings});

  /// The sightings shown.
  final List<Sighting> sightings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final format = Formats(context, ref.read(clockProvider)());
    if (sightings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
        child: Text(l10n.peopleNoSightings, style: context.text.bodyMedium?.copyWith(color: context.palette.text3)),
      );
    }
    return TileGroup(
      children: [
        for (final sighting in sightings)
          ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(width: 44, height: 44, child: MediaView(source: sighting.crop)),
            ),
            title: Text(sighting.cameraName ?? l10n.commonUnknown),
            subtitle: Text(
              [
                format.when(sighting.seenAt),
                if (sighting.confidence != null) l10n.eventConfidence((sighting.confidence! * 100).round()),
              ].join(', '),
            ),
            trailing: sighting.eventId == null ? null : const Icon(Icons.chevron_right_rounded),
            onTap: sighting.eventId == null ? null : () => EventRoute(eventId: sighting.eventId!).push<void>(context),
          ),
      ],
    );
  }
}

/// The details of one saved person: samples, sightings and actions.
class PersonScreen extends ConsumerWidget {
  /// Creates the screen for the person [personId].
  const PersonScreen({super.key, required this.personId});

  /// The id of the person shown.
  final String personId;

  /// Lets the user pick photos and adds them as face samples of the person.
  Future<void> addPhotos(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final files = await ImagePicker().pickMultiImage(maxWidth: 1600, imageQuality: 90);
    if (files.isEmpty) return;
    try {
      final bytes = [for (final file in files) await file.readAsBytes()];
      final result = await ref.read(backendProvider).people.addPhotos(personId, bytes);
      ref.invalidate(personProvider(personId));
      if (!context.mounted) return;
      final message = [
        l10n.peoplePhotosAdded(result.added),
        if (result.rejected.isNotEmpty) l10n.peoplePhotosRejected(result.rejected.length),
      ].join('. ');
      showMessage(context, message);
    } catch (failure) {
      if (context.mounted) showFailure(context, failure);
    }
  }

  /// Asks which person to merge [person] into and merges them.
  Future<void> merge(BuildContext context, WidgetRef ref, Person person, String organisationId) async {
    final l10n = context.l10n;
    final others = (await ref.read(peopleProvider(organisationId).future)).where((p) => p.id != person.id).toList();
    if (!context.mounted) return;
    final target = await showModalBottomSheet<Person>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Gaps.page + 4, 0, Gaps.page, Gaps.sm),
              child: Text(l10n.peopleMergeTitle(person.name), style: context.text.titleLarge),
            ),
            for (final other in others)
              ListTile(
                leading: FaceAvatar(source: other.samples.isEmpty ? null : other.samples.first.crop, color: other.color, size: 40),
                title: Text(other.name),
                onTap: () => Navigator.of(context).pop(other),
              ),
          ],
        ),
      ),
    );
    if (target == null) return;
    try {
      await ref.read(backendProvider).people.mergePerson(person.id, target.id);
      ref.invalidate(peopleProvider(organisationId));
      if (context.mounted) PersonRoute(personId: target.id).pushReplacement(context);
    } catch (failure) {
      if (context.mounted) showFailure(context, failure);
    }
  }

  /// Asks for confirmation and deletes [person].
  Future<void> delete(BuildContext context, WidgetRef ref, Person person, String organisationId) async {
    final l10n = context.l10n;
    final ok = await confirm(
      context,
      title: l10n.peopleDelete,
      body: l10n.peopleDeleteBody(person.name),
      action: l10n.commonDelete,
      destructive: true,
    );
    if (!ok) return;
    try {
      await ref.read(backendProvider).people.deletePerson(person.id);
      ref.invalidate(peopleProvider(organisationId));
      if (context.mounted) Navigator.of(context).pop();
    } catch (failure) {
      if (context.mounted) showFailure(context, failure);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final value = ref.watch(personProvider(personId));
    final site = ref.watch(currentSiteProvider).value;
    final admin = site?.can(Role.admin) ?? false;
    final organisationId = site?.organisation.id ?? '';
    final format = Formats(context, ref.read(clockProvider)());
    return Scaffold(
      appBar: AppBar(
        title: Text(value.value?.name ?? ''),
        actions: [
          if (admin && value.value != null)
            PopupMenuButton<String>(
              onSelected: (action) {
                final person = value.value!;
                if (action == 'merge') merge(context, ref, person, organisationId);
                if (action == 'delete') delete(context, ref, person, organisationId);
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'merge', child: Text(l10n.peopleMerge)),
                PopupMenuItem(value: 'delete', child: Text(l10n.peopleDelete, style: TextStyle(color: p.dangerText))),
              ],
            ),
        ],
      ),
      body: AsyncBody(
        value: value,
        onRetry: () => ref.invalidate(personProvider(personId)),
        data: (person) => ListView(
          padding: const EdgeInsets.only(bottom: Gaps.xxl),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.sm, Gaps.page, 0),
              child: Row(
                children: [
                  FaceAvatar(source: person.samples.isEmpty ? null : person.samples.first.crop, color: person.color, size: 72),
                  const SizedBox(width: Gaps.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(person.name, style: context.text.headlineSmall),
                        if (person.notes != null) Text(person.notes!, style: context.text.bodyMedium?.copyWith(color: p.text2)),
                        const SizedBox(height: 4),
                        Text(
                          person.lastSeenAt == null ? l10n.peopleNeverSeen : l10n.peopleLastSeen(format.ago(person.lastSeenAt!)),
                          style: context.text.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.lg, Gaps.page, 0),
              child: Row(
                children: [
                  if (admin)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => addPhotos(context, ref),
                        icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                        label: Text(l10n.peopleAddPhotos),
                      ),
                    ),
                  if (admin) const SizedBox(width: Gaps.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => EventsRoute(person: person.id).go(context),
                      icon: const Icon(Icons.list_alt_rounded, size: 18),
                      label: Text(l10n.eventsTitle),
                    ),
                  ),
                ],
              ),
            ),
            SectionHeader('${l10n.peopleSamples} ${person.samples.length}'),
            SampleGrid(
              samples: person.samples,
              onDelete: !admin
                  ? null
                  : (sample) async {
                      final ok = await confirm(context, title: l10n.commonDelete, action: l10n.commonDelete, destructive: true);
                      if (!ok) return;
                      await ref.read(backendProvider).people.deleteSample(person.id, sample.id);
                      ref.invalidate(personProvider(personId));
                    },
            ),
            SectionHeader(l10n.peopleSightings),
            SightingList(sightings: person.sightings),
          ],
        ),
      ),
    );
  }
}

/// The details of one unnamed face cluster, with options to name or delete it.
class ClusterScreen extends ConsumerStatefulWidget {
  /// Creates the screen for the cluster [clusterId].
  const ClusterScreen({super.key, required this.clusterId});

  /// The id of the cluster shown.
  final String clusterId;

  @override
  ConsumerState<ClusterScreen> createState() => _ClusterScreenState();
}

class _ClusterScreenState extends ConsumerState<ClusterScreen> {
  final name = TextEditingController();
  bool existing = false;
  String? personId;
  bool busy = false;

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  Future<void> save(String organisationId) async {
    final l10n = context.l10n;
    if (!existing && name.text.trim().isEmpty) return;
    if (existing && personId == null) return;
    setState(() => busy = true);
    try {
      final person = await ref
          .read(backendProvider)
          .people
          .nameCluster(widget.clusterId, personId: existing ? personId : null, name: existing ? null : name.text.trim());
      ref.invalidate(clustersProvider(organisationId));
      ref.invalidate(peopleProvider(organisationId));
      if (!mounted) return;
      showMessage(context, l10n.clusterNamed(person.name));
      PersonRoute(personId: person.id).pushReplacement(context);
    } catch (failure) {
      if (mounted) showFailure(context, failure);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final value = ref.watch(clusterProvider(widget.clusterId));
    final site = ref.watch(currentSiteProvider).value;
    final organisationId = site?.organisation.id ?? '';
    final admin = site?.can(Role.admin) ?? false;
    final people = ref.watch(peopleProvider(organisationId)).value ?? const [];
    final format = Formats(context, ref.read(clockProvider)());
    return Scaffold(
      appBar: AppBar(
        title: Text(value.value?.label ?? ''),
        actions: [
          if (admin)
            IconButton(
              tooltip: l10n.clusterDelete,
              onPressed: () async {
                final ok = await confirm(
                  context,
                  title: l10n.clusterDelete,
                  body: l10n.clusterDeleteBody,
                  action: l10n.commonDelete,
                  destructive: true,
                );
                if (!ok) return;
                await ref.read(backendProvider).people.deleteCluster(widget.clusterId);
                ref.invalidate(clustersProvider(organisationId));
                if (context.mounted) Navigator.of(context).pop();
              },
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: AsyncBody(
        value: value,
        onRetry: () => ref.invalidate(clusterProvider(widget.clusterId)),
        data: (cluster) => ListView(
          padding: const EdgeInsets.only(bottom: Gaps.xxl),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.sm, Gaps.page, 0),
              child: Text(
                '${l10n.peopleSeen(cluster.seenCount)}, ${format.ago(cluster.lastSeenAt)}',
                style: context.text.bodyMedium?.copyWith(color: p.text2),
              ),
            ),
            SectionHeader(l10n.peopleSamples),
            SampleGrid(samples: cluster.samples),
            if (admin) ...[
              SectionHeader(l10n.clusterWhoTitle),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
                child: Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.clusterWhoBody, style: context.text.bodyMedium?.copyWith(color: p.text2)),
                      const SizedBox(height: Gaps.md),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<bool>(
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment(value: false, label: Text(l10n.clusterNewPerson)),
                            ButtonSegment(value: true, label: Text(l10n.clusterExisting), enabled: people.isNotEmpty),
                          ],
                          selected: {existing},
                          onSelectionChanged: (value) => setState(() => existing = value.first),
                        ),
                      ),
                      const SizedBox(height: Gaps.md),
                      if (!existing)
                        TextField(
                          controller: name,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(labelText: l10n.peopleName),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final person in people)
                              ChoiceChip(
                                label: Text(person.name),
                                selected: personId == person.id,
                                onSelected: (_) => setState(() => personId = person.id),
                              ),
                          ],
                        ),
                      const SizedBox(height: Gaps.lg),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: busy ? null : () => save(organisationId),
                          child: Text(l10n.commonSave),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            SectionHeader(l10n.peopleSightings),
            SightingList(sightings: cluster.sightings),
          ],
        ),
      ),
    );
  }
}
