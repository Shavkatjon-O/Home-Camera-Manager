import 'dart:typed_data';

import 'package:smart_surveillance/features/events/domain/models.dart';
import 'package:smart_surveillance/features/investigation/domain/models.dart';
import 'package:smart_surveillance/features/investigation/domain/search_models.dart';

/// The source of event searches and face lookups.
abstract interface class SearchRepository {
  /// Returns page [page] of the events at [siteId] matching [filter], [pageSize] per page.
  Future<EventPage> search(String siteId, EventFilter filter, {int page = 1, int pageSize = 30});

  /// Returns the values at [siteId] that a search can be narrowed by.
  Future<SearchFacets> facets(String siteId);

  /// Returns faces resembling a stored sample, an event's face or an uploaded [photo].
  Future<List<SimilarFace>> similarFaces(
    String organisationId, {
    String? sampleId,
    String? eventId,
    Uint8List? photo,
  });
}
