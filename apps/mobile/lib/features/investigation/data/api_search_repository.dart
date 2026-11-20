import 'dart:convert';
import 'dart:typed_data';

import 'package:smart_surveillance/core/media/media_source.dart';
import 'package:smart_surveillance/core/network/api/surveillance_api.dart' as api;
import 'package:smart_surveillance/core/network/client/http.dart';
import 'package:smart_surveillance/features/events/data/api_event_repository.dart';
import 'package:smart_surveillance/features/events/domain/models.dart';
import 'package:smart_surveillance/features/investigation/data/api_people_repository.dart';
import 'package:smart_surveillance/features/investigation/domain/models.dart';
import 'package:smart_surveillance/features/investigation/domain/search_models.dart';
import 'package:smart_surveillance/features/investigation/domain/search_repository.dart';

/// Searches events and looks up similar faces on the server.
class ApiSearchRepository implements SearchRepository {
  /// Creates the repository over [client]; [baseUrl] reads the server address.
  ApiSearchRepository(this.client, this.baseUrl);

  /// The generated API.
  final api.SurveillanceApi client;

  /// Reads the server address.
  final String Function() baseUrl;

  /// The number of similar faces asked for.
  static const similarLimit = 50;

  @override
  Future<EventPage> search(
    String siteId,
    EventFilter filter, {
    int page = 1,
    int pageSize = 30,
  }) async {
    final (from, to) = ApiEventRepository.rangeOf(filter);
    final result = await guarded(
      () => client.search.searchEvents(
        xSite: siteId,
        page: page,
        pageSize: pageSize,
        from: ApiEventRepository.iso(from),
        to: ApiEventRepository.iso(to),
        camera: filter.cameraIds.isEmpty ? null : filter.cameraIds.toList(),
        view: filter.viewIds.isEmpty ? null : filter.viewIds.toList(),
        kind: filter.kinds.isEmpty
            ? null
            : [for (final kind in filter.kinds) ApiEventRepository.wireKind(kind)],
        label: filter.labels.isEmpty ? null : filter.labels.toList(),
        zone: filter.zones.isEmpty ? null : filter.zones.toList(),
        line: filter.lines.isEmpty ? null : filter.lines.toList(),
        person: filter.personId,
        cluster: filter.clusterId,
        alert: filter.alertsOnly,
      ),
    );
    return EventPage(
      items: [for (final event in result.items) ApiEventRepository.eventOf(event.toJson(), siteId)],
      total: result.total,
      page: result.page,
      pageSize: result.pageSize,
    );
  }

  @override
  Future<SearchFacets> facets(String siteId) async {
    final json = (await guarded(() => client.search.getFacets(xSite: siteId))).toJson();
    final views = <String, String>{};
    final viewItems = <FacetItem>[];
    for (final item in json['views'] as List<Object?>? ?? const <Object?>[]) {
      final view = ApiPeopleRepository.objectOf(item);
      views[view['id']! as String] = view['name'] as String? ?? '';
      viewItems.add(FacetItem(id: view['id']! as String, name: view['name'] as String? ?? ''));
    }
    List<FacetItem> inViews(Object? list) => [
      for (final item in list as List<Object?>? ?? const <Object?>[])
        FacetItem(
          id: ApiPeopleRepository.objectOf(item)['id']! as String,
          name: ApiPeopleRepository.objectOf(item)['name'] as String? ?? '',
          detail: views[ApiPeopleRepository.objectOf(item)['view']],
        ),
    ];
    return SearchFacets(
      views: viewItems,
      zones: inViews(json['zones']),
      lines: inViews(json['lines']),
      people: [
        for (final item in json['people'] as List<Object?>? ?? const <Object?>[])
          FacetItem(
            id: ApiPeopleRepository.objectOf(item)['uuid']! as String,
            name: ApiPeopleRepository.objectOf(item)['name'] as String? ?? '',
          ),
      ],
      clusters: [
        for (final item in json['clusters'] as List<Object?>? ?? const <Object?>[])
          FacetItem(
            id: ApiPeopleRepository.objectOf(item)['uuid']! as String,
            name: ApiPeopleRepository.objectOf(item)['label'] as String? ?? '',
          ),
      ],
      labels: ApiPeopleRepository.objectOf(json)['labels'] is List
          ? [for (final label in json['labels']! as List<Object?>) label! as String]
          : const [],
    );
  }

  @override
  Future<List<SimilarFace>> similarFaces(
    String organisationId, {
    String? sampleId,
    String? eventId,
    Uint8List? photo,
  }) async {
    final query = {
      'page_size': similarLimit,
      if (sampleId != null)
        'sample': sampleId
      else if (eventId != null)
        'event': eventId
      else if (photo != null)
        'photo': 'data:${ApiPeopleRepository.mimeOf(photo)};base64,${base64Encode(photo)}',
    };
    final page = await guarded(
      () => client.search.searchSimilar(body: api.SimilarQuery.fromJson(query)),
    );
    return [
      for (final item in page.toJson()['items'] as List<Object?>? ?? const <Object?>[])
        similarOf(ApiPeopleRepository.objectOf(item)),
    ];
  }

  /// Converts a match as the server writes it in JSON to the app's [SimilarFace].
  SimilarFace similarOf(Map<String, Object?> json) {
    final sample = json['sample_uuid']! as String;
    return SimilarFace(
      sampleId: sample,
      score: (json['score'] as num?)?.toDouble() ?? 0,
      seenAt: ApiPeopleRepository.timeOf(json['seen_at']),
      personId: json['person_uuid'] as String?,
      personName: json['person_name'] as String?,
      clusterId: json['cluster_uuid'] as String?,
      clusterLabel: json['cluster_label'] as String?,
      eventId: json['event_uuid'] as String?,
      cameraName: json['camera_name'] as String?,
      crop: NetworkMedia(
        '${baseUrl()}/api/v1/people/samples/$sample/crop',
        cacheKey: 'sample-$sample',
      ),
    );
  }
}
