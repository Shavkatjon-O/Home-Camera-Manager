import 'dart:async';
import 'dart:typed_data';

import 'package:smart_surveillance/app/demo/fake_store.dart';
import 'package:smart_surveillance/app/demo/fixtures.dart';
import 'package:smart_surveillance/core/media/media_source.dart';
import 'package:smart_surveillance/features/investigation/domain/models.dart';
import 'package:smart_surveillance/features/investigation/domain/people_repository.dart';
/// An in-memory [PeopleRepository] backed by demo data.
class FakePeopleRepository implements PeopleRepository {
  /// Creates a repository reading and writing [store].
  FakePeopleRepository(this.store);

  /// The demo data store this repository works on.
  final FakeStore store;

  @override
  Future<List<Person>> people(String organisationId) => store.delay(() => List.of(store.data.people));

  @override
  Future<Person> person(String personId) => store.delay(() => store.data.people.firstWhere((p) => p.id == personId));

  @override
  Future<Person> createPerson(String organisationId, {required String name, String? notes}) => store.delay(() {
    const colors = [0xFF0090FF, 0xFF45C25F, 0xFFF0A92E, 0xFFE5484D, 0xFFA07CFE];
    final person = Person(
      id: 'person-${store.sequence++}',
      name: name,
      notes: notes,
      color: colors[store.data.people.length % colors.length],
    );
    store.data.people.add(person);
    return person;
  });

  @override
  Future<Person> updatePerson(Person person) => store.delay(() {
    final index = store.data.people.indexWhere((p) => p.id == person.id);
    store.data.people[index] = person;
    return person;
  });

  @override
  Future<void> deletePerson(String personId) => store.delay(() => store.data.people.removeWhere((p) => p.id == personId));

  @override
  Future<PhotoResult> addPhotos(String personId, List<Uint8List> photos) => store.delay(() {
    final index = store.data.people.indexWhere((p) => p.id == personId);
    final person = store.data.people[index];
    final added = [
      for (var i = 0; i < photos.length; i++)
        FaceSample(
          id: 'sample-${store.sequence++}',
          source: SampleSource.upload,
          quality: 0.8,
          seenAt: store.clock(),
          crop: SyntheticMedia(SceneKind.face, seed: person.color),
        ),
    ];
    store.data.people[index] = person.copyWith(samples: [...person.samples, ...added]);
    return PhotoResult(added: added.length);
  });

  @override
  Future<void> deleteSample(String personId, String sampleId) => store.delay(() {
    final index = store.data.people.indexWhere((p) => p.id == personId);
    final person = store.data.people[index];
    store.data.people[index] = person.copyWith(samples: person.samples.where((s) => s.id != sampleId).toList());
  });

  @override
  Future<void> mergePerson(String personId, String intoId) => store.delay(() {
    final from = store.data.people.firstWhere((p) => p.id == personId);
    final index = store.data.people.indexWhere((p) => p.id == intoId);
    final into = store.data.people[index];
    store.data.people[index] = into.copyWith(
      samples: [...into.samples, ...from.samples],
      sightings: [...into.sightings, ...from.sightings],
    );
    store.data.people.removeWhere((p) => p.id == personId);
  });

  @override
  Future<List<FaceCluster>> clusters(String organisationId) => store.delay(() => List.of(store.data.clusters));

  @override
  Future<FaceCluster> cluster(String clusterId) =>
      store.delay(() => store.data.clusters.firstWhere((c) => c.id == clusterId));

  @override
  Future<Person> nameCluster(String clusterId, {String? personId, String? name}) async {
    final cluster = store.data.clusters.firstWhere((c) => c.id == clusterId);
    Person target;
    if (personId != null) {
      target = store.data.people.firstWhere((p) => p.id == personId);
    } else {
      target = await createPerson(Fixtures.demoOrg, name: name ?? cluster.label);
    }
    return store.delay(() {
      final index = store.data.people.indexWhere((p) => p.id == target.id);
      final merged = target.copyWith(
        samples: [...target.samples, ...cluster.samples],
        sightings: [...target.sightings, ...cluster.sightings],
        lastSeenAt: cluster.lastSeenAt,
      );
      store.data.people[index] = merged;
      store.data.clusters.removeWhere((c) => c.id == clusterId);
      return merged;
    });
  }

  @override
  Future<void> deleteCluster(String clusterId) =>
      store.delay(() => store.data.clusters.removeWhere((c) => c.id == clusterId));
}
