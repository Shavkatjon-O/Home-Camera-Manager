import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_models.freezed.dart';

/// The values a search can be narrowed by at a site.
@freezed
abstract class SearchFacets with _$SearchFacets {
  /// Creates the facets, each list empty unless given.
  const factory SearchFacets({
    @Default(<FacetItem>[]) List<FacetItem> views,
    @Default(<FacetItem>[]) List<FacetItem> zones,
    @Default(<FacetItem>[]) List<FacetItem> lines,
    @Default(<FacetItem>[]) List<FacetItem> people,
    @Default(<FacetItem>[]) List<FacetItem> clusters,
    @Default(<String>[]) List<String> labels,
  }) = _SearchFacets;
}

/// One value offered as a filter choice.
@freezed
abstract class FacetItem with _$FacetItem {
  /// Creates a choice [name] with the given [id] and optional [detail].
  const factory FacetItem({required String id, required String name, String? detail}) = _FacetItem;
}
