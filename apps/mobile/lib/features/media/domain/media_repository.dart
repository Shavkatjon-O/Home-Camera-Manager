import 'package:smart_surveillance/core/media/media_source.dart';
import 'package:smart_surveillance/features/devices/domain/models.dart';
import 'package:smart_surveillance/features/events/domain/models.dart';

/// Where a camera's live picture comes from.
sealed class LiveSource {
  const LiveSource();
}

/// A live picture received over WebRTC.
class WebRtcLive extends LiveSource {
  /// Creates a source that exchanges an offer through [negotiate].
  const WebRtcLive(this.negotiate);

  /// Sends the local session description [offerSdp] and returns the answer.
  final Future<String> Function(String offerSdp) negotiate;
}

/// A live picture generated on the device for demos.
class SyntheticLive extends LiveSource {
  /// Creates a source with one generated scene per lens in [lenses].
  const SyntheticLive(this.lenses);

  /// The generated scene of each lens.
  final List<SyntheticMedia> lenses;
}

/// Where a recorded clip comes from.
sealed class ClipSource {
  const ClipSource();
}

/// A clip played from a network address.
class NetworkClip extends ClipSource {
  /// Creates a source that streams from [url].
  const NetworkClip(this.url);

  /// The address of the clip.
  final String url;
}

/// A clip generated on the device for demos.
class SyntheticClip extends ClipSource {
  /// Creates a clip of [length] that draws [media] with detection [boxes].
  const SyntheticClip(this.media, this.boxes, this.length);

  /// The generated picture of the clip.
  final SyntheticMedia media;

  /// The detection boxes drawn over the clip.
  final List<EventBox> boxes;

  /// The duration of the clip.
  final Duration length;
}

/// Provides live pictures and snapshots of cameras.
abstract interface class LiveRepository {
  /// Returns the live source of [camera] at [quality], with sound when [audio] is true.
  LiveSource live(Camera camera, {required StreamQuality quality, bool audio = false});

  /// Returns a still picture of [camera].
  Future<MediaSource> snapshot(Camera camera);
}
