import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:smart_surveillance/app/demo/fake_store.dart';
import 'package:smart_surveillance/features/events/data/fake_event_repository.dart';
import 'package:smart_surveillance/features/events/domain/models.dart';
import 'package:smart_surveillance/features/investigation/domain/models.dart';
import 'package:smart_surveillance/features/investigation/domain/search_models.dart';
import 'package:smart_surveillance/features/investigation/domain/search_repository.dart';
class FakeSearchRepository implements SearchRepository {
  FakeSearchRepository(this.store, this.events);

  final FakeStore store;
  final FakeEventRepository events;

  @override
  Future<EventPage> search(String siteId, EventFilter filter, {int page = 1, int pageSize = 30}) =>
      events.events(siteId, filter, page: page, pageSize: pageSize);

  @override
  Future<SearchFacets> facets(String siteId) => store.delay(() {
    final siteViews = store.data.views.where((v) => store.data.camera(v.cameraId).camera.siteId == siteId);
    return SearchFacets(
      views: [for (final view in siteViews) FacetItem(id: view.id, name: view.name, detail: view.cameraName)],
      zones: [
        for (final view in siteViews)
          for (final zone in view.zones) FacetItem(id: zone.name, name: zone.name, detail: view.name),
      ],
      lines: [
        for (final view in siteViews)
          for (final line in view.lines) FacetItem(id: line.name, name: line.name, detail: view.name),
      ],
      people: [for (final person in store.data.people) FacetItem(id: person.id, name: person.name)],
      clusters: [for (final cluster in store.data.clusters) FacetItem(id: cluster.id, name: cluster.label)],
      labels: const ['person', 'car', 'truck', 'bicycle', 'dog', 'cat', 'backpack', 'handbag', 'suitcase'],
    );
  });

  @override
  Future<List<SimilarFace>> similarFaces(String organisationId, {String? sampleId, String? eventId, Uint8List? photo}) =>
      store.delay(() {
        final results = <SimilarFace>[];
        var score = 0.93;
        for (final person in store.data.people) {
          for (final sample in person.samples.take(2)) {
            results.add(
              SimilarFace(
                sampleId: sample.id,
                score: score,
                seenAt: sample.seenAt,
                personId: person.id,
                personName: person.name,
                cameraName: sample.cameraName,
                crop: sample.crop,
              ),
            );
            score -= 0.11;
          }
        }
        for (final cluster in store.data.clusters) {
          results.add(
            SimilarFace(
              sampleId: cluster.samples.first.id,
              score: max(0.2, score),
              seenAt: cluster.lastSeenAt,
              clusterId: cluster.id,
              clusterLabel: cluster.label,
              cameraName: 'Entrance',
              crop: cluster.samples.first.crop,
            ),
          );
          score -= 0.06;
        }
        results.sort((a, b) => b.score.compareTo(a.score));
        return results;
      });
}
