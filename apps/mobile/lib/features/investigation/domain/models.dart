import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_surveillance/core/media/media_source.dart';

part 'models.freezed.dart';
enum SampleSource { upload, event }

@freezed
abstract class FaceSample with _$FaceSample {
  const factory FaceSample({
    required String id,
    required SampleSource source,
    required double quality,
    required DateTime seenAt,
    String? cameraName,
    String? viewName,
    String? eventId,
    required MediaSource crop,
  }) = _FaceSample;
}

@freezed
abstract class Sighting with _$Sighting {
  const factory Sighting({
    String? eventId,
    required String sampleId,
    String? cameraName,
    String? viewName,
    required DateTime seenAt,
    double? confidence,
    required MediaSource crop,
  }) = _Sighting;
}

@freezed
abstract class Person with _$Person {
  const factory Person({
    required String id,
    required String name,
    String? notes,
    required int color,
    @Default(<FaceSample>[]) List<FaceSample> samples,
    DateTime? lastSeenAt,
    @Default(<Sighting>[]) List<Sighting> sightings,
  }) = _Person;
}

@freezed
abstract class FaceCluster with _$FaceCluster {
  const factory FaceCluster({
    required String id,
    required int number,
    required String label,
    required int seenCount,
    required DateTime firstSeenAt,
    required DateTime lastSeenAt,
    @Default(<FaceSample>[]) List<FaceSample> samples,
    @Default(<Sighting>[]) List<Sighting> sightings,
  }) = _FaceCluster;
}

@freezed
abstract class SimilarFace with _$SimilarFace {
  const factory SimilarFace({
    required String sampleId,
    required double score,
    required DateTime seenAt,
    String? personId,
    String? personName,
    String? clusterId,
    String? clusterLabel,
    String? eventId,
    String? cameraName,
    required MediaSource crop,
  }) = _SimilarFace;
}

@freezed
abstract class PhotoResult with _$PhotoResult {
  const factory PhotoResult({
    required int added,
    @Default(<String>[]) List<String> rejected,
  }) = _PhotoResult;
}

@freezed
abstract class JourneyStep with _$JourneyStep {
  const factory JourneyStep({
    required String cameraName,
    String? viewName,
    required DateTime startedAt,
    required DateTime endedAt,
    double? similarity,
    String? eventId,
  }) = _JourneyStep;
}

@freezed
abstract class Journey with _$Journey {
  const factory Journey({
    required String id,
    required String description,
    required DateTime startedAt,
    required DateTime endedAt,
    required List<JourneyStep> steps,
  }) = _Journey;
}

@freezed
abstract class AppearanceMatch with _$AppearanceMatch {
  const factory AppearanceMatch({
    required String id,
    required String cameraName,
    String? viewName,
    required DateTime startedAt,
    required DateTime endedAt,
    required double similarity,
    String? eventId,
    String? journeyId,
    MediaSource? thumbnail,
  }) = _AppearanceMatch;
}
