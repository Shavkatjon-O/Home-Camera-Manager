import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
/// The time span one count is grouped into.
enum Bucket {
  /// One count per hour.
  hour,
  /// One count per day.
  day,
}

/// A line whose crossings are counted, with the view and camera it belongs to.
@freezed
abstract class CountLine with _$CountLine {
  /// Creates a count line [name] with the given [id], on view [viewName] of camera [cameraName].
  const factory CountLine({
    required String id,
    required String name,
    required String viewName,
    required String cameraName,
  }) = _CountLine;
}

/// The crossings of one line during one time bucket.
@freezed
abstract class CountBucket with _$CountBucket {
  /// Creates a count of [inward] and [outward] crossings of line [lineId] from time [at].
  const factory CountBucket({
    required String lineId,
    required DateTime at,
    required String label,
    required int inward,
    required int outward,
  }) = _CountBucket;
}

/// The line crossing counts for a period, grouped into buckets.
@freezed
abstract class CountsReport with _$CountsReport {
  /// Creates a report from [start] to [end] with [buckets] of size [bucket] for the given [lines].
  const factory CountsReport({
    required DateTime start,
    required DateTime end,
    required Bucket bucket,
    required List<CountLine> lines,
    required List<CountBucket> buckets,
  }) = _CountsReport;
}

/// A counted place with its current occupancy and entry and exit totals.
@freezed
abstract class Area with _$Area {
  /// Creates an area [name] with [occupancy] people inside, [entered] and [exited] since [since].
  const factory Area({
    required String id,
    required String name,
    required int occupancy,
    required int entered,
    required int exited,
    required DateTime since,
    String? resetAt,
    @Default(<String>['person']) List<String> labels,
    @Default(<String>[]) List<String> lineNames,
    int? capacity,
  }) = _Area;
}
