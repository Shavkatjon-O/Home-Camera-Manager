import 'package:smart_surveillance/core/media/media_source.dart';
import 'package:smart_surveillance/core/network/api/surveillance_api.dart' as api;
import 'package:smart_surveillance/core/network/client/http.dart';
import 'package:smart_surveillance/features/devices/domain/models.dart';
import 'package:smart_surveillance/features/media/domain/media_repository.dart';

/// Plays cameras over WebRTC through the server and loads their still pictures.
class ApiLiveRepository implements LiveRepository {
  /// Creates the repository over [client]; [baseUrl] reads the server address for picture URLs.
  ApiLiveRepository(this.client, this.baseUrl);

  /// The generated API.
  final api.SurveillanceApi client;

  /// Reads the server address.
  final String Function() baseUrl;

  /// The ICE servers the server hands out, loaded once.
  Future<List<Map<String, Object?>>>? iceServers;

  /// Reads the ICE servers, or none when the server has no relay configured.
  Future<List<Map<String, Object?>>> loadIceServers() => iceServers ??= () async {
    try {
      final list = await guarded(() => client.live.getIceServers());
      return [
        for (final server in list.iceServers)
          {
            'urls': server.urls,
            if (server.username != null) 'username': server.username,
            if (server.credential != null) 'credential': server.credential,
          },
      ];
    } on Object {
      iceServers = null;
      return const <Map<String, Object?>>[];
    }
  }();

  @override
  LiveSource live(Camera camera, {required StreamQuality quality, bool audio = false}) =>
      WebRtcLive((offer) async {
        final answer = await guarded(
          () => client.live.createWebrtcSession(
            uuid: camera.id,
            xSite: camera.siteId,
            body: api.WebrtcOffer(sdp: offer, stream: api.ViewStream.fromJson(quality.name)),
          ),
        );
        return answer.sdp;
      }, iceServers: loadIceServers);

  @override
  Future<MediaSource> snapshot(Camera camera) async {
    final views = await guarded(
      () => client.analytics.listViews(cameraUuid: camera.id, xSite: camera.siteId),
    );
    if (views.items.isEmpty) throw StateError('no view');
    final view = views.items.first.uuid;
    final at = DateTime.now().millisecondsSinceEpoch ~/ 10000;
    return NetworkMedia(
      '${baseUrl()}/api/v1/analytics/views/$view/snapshot?t=$at',
      cacheKey: 'view-$view-$at',
    );
  }
}
