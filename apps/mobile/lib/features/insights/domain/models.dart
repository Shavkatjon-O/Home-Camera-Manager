import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
enum Bucket { hour, day }

@freezed
abstract class CountLine with _$CountLine {
  const factory CountLine({
    required String id,
    required String name,
    required String viewName,
    required String cameraName,
  }) = _CountLine;
}

@freezed
abstract class CountBucket with _$CountBucket {
  const factory CountBucket({
    required String lineId,
    required DateTime at,
    required String label,
    required int inward,
    required int outward,
  }) = _CountBucket;
}

@freezed
abstract class CountsReport with _$CountsReport {
  const factory CountsReport({
    required DateTime start,
    required DateTime end,
    required Bucket bucket,
    required List<CountLine> lines,
    required List<CountBucket> buckets,
  }) = _CountsReport;
}

@freezed
abstract class Area with _$Area {
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
