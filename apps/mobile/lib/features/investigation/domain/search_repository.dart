import 'dart:typed_data';

import 'package:smart_surveillance/features/events/domain/models.dart';
import 'package:smart_surveillance/features/investigation/domain/models.dart';
import 'package:smart_surveillance/features/investigation/domain/search_models.dart';
abstract interface class SearchRepository {
  Future<EventPage> search(String siteId, EventFilter filter, {int page = 1, int pageSize = 30});

  Future<SearchFacets> facets(String siteId);

  Future<List<SimilarFace>> similarFaces(String organisationId, {String? sampleId, String? eventId, Uint8List? photo});
}
