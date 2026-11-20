import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_surveillance/core/media/media_source.dart';

part 'models.freezed.dart';
/// Where a face sample came from.
enum SampleSource {
  /// The sample was uploaded as a photo.
  upload,
  /// The sample was cut out of a camera event.
  event,
}

/// One face image of a person or cluster, used for matching.
@freezed
abstract class FaceSample with _$FaceSample {
  /// Creates a sample [id] from [source], graded [quality], seen at [seenAt].
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

/// One time a person or cluster was seen on a camera.
@freezed
abstract class Sighting with _$Sighting {
  /// Creates a sighting of sample [sampleId] at [seenAt], shown as [crop].
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

/// A person saved by name, with their face samples and sightings.
@freezed
abstract class Person with _$Person {
  /// Creates a person [name] with the given [id] and display [color].
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

/// A group of similar unnamed faces the system found by itself.
@freezed
abstract class FaceCluster with _$FaceCluster {
  /// Creates a cluster [id] numbered [number] and shown as [label], seen [seenCount] times.
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

/// A face that resembles a searched face, with how closely it matches.
@freezed
abstract class SimilarFace with _$SimilarFace {
  /// Creates a match for sample [sampleId] with similarity [score], seen at [seenAt].
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

/// The outcome of adding photos to a person.
@freezed
abstract class PhotoResult with _$PhotoResult {
  /// Creates a result with [added] accepted photos and the names of those [rejected].
  const factory PhotoResult({
    required int added,
    @Default(<String>[]) List<String> rejected,
  }) = _PhotoResult;
}

/// One stop of a person's journey, on one camera.
@freezed
abstract class JourneyStep with _$JourneyStep {
  /// Creates a step on camera [cameraName] from [startedAt] to [endedAt].
  const factory JourneyStep({
    required String cameraName,
    String? viewName,
    required DateTime startedAt,
    required DateTime endedAt,
    double? similarity,
    String? eventId,
  }) = _JourneyStep;
}

/// The path one person took across cameras, as an ordered list of steps.
@freezed
abstract class Journey with _$Journey {
  /// Creates a journey [id] described by [description], made of [steps].
  const factory Journey({
    required String id,
    required String description,
    required DateTime startedAt,
    required DateTime endedAt,
    required List<JourneyStep> steps,
  }) = _Journey;
}

/// A sighting of someone who looks like the person in a searched event.
@freezed
abstract class AppearanceMatch with _$AppearanceMatch {
  /// Creates a match [id] on [cameraName] from [startedAt] to [endedAt] with [similarity].
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
