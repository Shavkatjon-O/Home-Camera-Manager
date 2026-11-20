import 'dart:ui';
sealed class MediaSource {
  const MediaSource();
}

class NetworkMedia extends MediaSource {
  const NetworkMedia(this.url, {this.cacheKey});

  final String url;
  final String? cacheKey;

  @override
  bool operator ==(Object other) => other is NetworkMedia && other.url == url;

  @override
  int get hashCode => url.hashCode;
}

enum SceneKind { street, yard, driveway, hallway, entrance, checkout, aisle, stockroom, face }

class SceneFigure {
  const SceneFigure(this.label, this.box);

  final String label;
  final Rect box;
}

class SyntheticMedia extends MediaSource {
  const SyntheticMedia(
    this.scene, {
    this.seed = 0,
    this.night = false,
    this.figures = const [],
    this.at,
  });

  final SceneKind scene;
  final int seed;
  final bool night;
  final List<SceneFigure> figures;
  final DateTime? at;

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

class MemoryMedia extends MediaSource {
  const MemoryMedia(this.bytes);

  final List<int> bytes;
}
