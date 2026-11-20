
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_models.freezed.dart';
@freezed
abstract class SearchFacets with _$SearchFacets {
  const factory SearchFacets({
    @Default(<FacetItem>[]) List<FacetItem> views,
    @Default(<FacetItem>[]) List<FacetItem> zones,
    @Default(<FacetItem>[]) List<FacetItem> lines,
    @Default(<FacetItem>[]) List<FacetItem> people,
    @Default(<FacetItem>[]) List<FacetItem> clusters,
    @Default(<String>[]) List<String> labels,
  }) = _SearchFacets;
}

@freezed
abstract class FacetItem with _$FacetItem {
  const factory FacetItem({required String id, required String name, String? detail}) = _FacetItem;
}
