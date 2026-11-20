
import 'package:smart_surveillance/core/media/media_source.dart';
import 'package:smart_surveillance/features/devices/domain/models.dart';
import 'package:smart_surveillance/features/events/domain/models.dart';
sealed class LiveSource {
  const LiveSource();
}

class WebRtcLive extends LiveSource {
  const WebRtcLive(this.negotiate);

  final Future<String> Function(String offerSdp) negotiate;
}

class SyntheticLive extends LiveSource {
  const SyntheticLive(this.lenses);

  final List<SyntheticMedia> lenses;
}

sealed class ClipSource {
  const ClipSource();
}

class NetworkClip extends ClipSource {
  const NetworkClip(this.url);

  final String url;
}

class SyntheticClip extends ClipSource {
  const SyntheticClip(this.media, this.boxes, this.length);

  final SyntheticMedia media;
  final List<EventBox> boxes;
  final Duration length;
}

abstract interface class LiveRepository {
  LiveSource live(Camera camera, {required StreamQuality quality, bool audio = false});

  Future<MediaSource> snapshot(Camera camera);
}
