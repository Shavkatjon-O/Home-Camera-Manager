import 'dart:ui';

/// A picture or video frame to show: from the network, generated, or held in memory.
sealed class MediaSource {
  /// Creates a media source.
  const MediaSource();
}

/// Media loaded from a network address.
class NetworkMedia extends MediaSource {
  /// Creates media at [url], cached under [cacheKey] when one is given.
  const NetworkMedia(this.url, {this.cacheKey});

  /// The address of the image or video.
  final String url;

  /// The key to cache the downloaded image under, when it differs from [url].
  final String? cacheKey;

  @override
  bool operator ==(Object other) => other is NetworkMedia && other.url == url;

  @override
  int get hashCode => url.hashCode;
}

/// The kind of place a synthetic demo scene depicts.
enum SceneKind {
  /// A street scene.
  street,

  /// A yard scene.
  yard,

  /// A driveway.
  driveway,

  /// An indoor hallway.
  hallway,

  /// A building entrance.
  entrance,

  /// A shop checkout counter.
  checkout,

  /// A shop aisle.
  aisle,

  /// A stockroom.
  stockroom,

  /// A close-up of a face, used for face samples.
  face,
}

/// A figure drawn on a synthetic scene, such as a detected person.
class SceneFigure {
  /// Creates a figure with [label] occupying [box].
  const SceneFigure(this.label, this.box);

  /// The kind of object the figure represents, such as person.
  final String label;

  /// The area of the figure as fractions of the frame, from 0 to 1.
  final Rect box;
}

/// Media drawn on the device instead of loaded, used for the demo cameras.
class SyntheticMedia extends MediaSource {
  /// Creates a scene of kind [scene] drawn from [seed], at night or day, with the given [figures].
  const SyntheticMedia(
    this.scene, {
    this.seed = 0,
    this.night = false,
    this.figures = const [],
    this.at,
  });

  /// The kind of place that is drawn.
  final SceneKind scene;

  /// The number that makes the scene's details differ from other scenes of the same kind.
  final int seed;

  /// Whether the scene is drawn as at night.
  final bool night;

  /// The figures drawn over the scene.
  final List<SceneFigure> figures;

  /// The time shown in the camera stamp, or null to use the current time.
  final DateTime? at;

  /// Returns a copy with [value] as the figures and, when given, [at] as the stamp time.
  SyntheticMedia withFigures(List<SceneFigure> value, {DateTime? at}) =>
      SyntheticMedia(scene, seed: seed, night: night, figures: value, at: at ?? this.at);

  @override
  bool operator ==(Object other) =>
      other is SyntheticMedia &&
      other.scene == scene &&
      other.seed == seed &&
      other.night == night &&
      other.figures.length == figures.length &&
      other.at == at;

  @override
  int get hashCode => Object.hash(scene, seed, night, figures.length, at);
}

/// Media held in memory as encoded image bytes.
class MemoryMedia extends MediaSource {
  /// Creates media from the encoded image [bytes].
  const MemoryMedia(this.bytes);

  /// The encoded image data.
  final List<int> bytes;
}
