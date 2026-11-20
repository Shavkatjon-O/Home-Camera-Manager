import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_surveillance/core/media/media_source.dart';
import 'package:smart_surveillance/core/network/api/surveillance_api.dart' as api;
import 'package:smart_surveillance/core/network/client/http.dart';
import 'package:smart_surveillance/features/events/domain/event_repository.dart';
import 'package:smart_surveillance/features/events/domain/models.dart';
import 'package:smart_surveillance/features/media/domain/media_repository.dart';

/// Reads events, their pictures and clips from the server and follows its live event stream.
class ApiEventRepository implements EventRepository {
  /// Creates the repository over [client] and [dio]; [baseUrl] reads the server address.
  ApiEventRepository(this.client, this.dio, this.baseUrl, this.currentSite);

  /// The generated API.
  final api.SurveillanceApi client;

  /// The HTTP client, used for the event stream and clip downloads.
  final Dio dio;

  /// Reads the server address.
  final String Function() baseUrl;

  /// Reads the selected site, which events read by id belong to.
  final String? Function() currentSite;

  /// Converts a snake case wire name such as line_crossing to the app's [EventKind].
  static EventKind? kindOf(String wire) {
    final camel = wire.replaceAllMapped(RegExp('_([a-z])'), (m) => m[1]!.toUpperCase());
    return EventKind.values.asNameMap()[camel];
  }

  /// Converts the app's [kind] to its snake case wire name.
  static String wireKind(EventKind kind) =>
      kind.name.replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]!.toLowerCase()}');

  /// Reads a text field of a JSON object.
  static String? text(Object? value) => value is String && value.isNotEmpty ? value : null;

  /// Reads a colour written as #RRGGBB.
  static int? colorOf(Object? value) {
    if (value is! String || !value.startsWith('#') || value.length != 7) return null;
    final rgb = int.tryParse(value.substring(1), radix: 16);
    return rgb == null ? null : 0xFF000000 | rgb;
  }

  /// Converts an event as the server writes it in JSON to the app's [CameraEvent].
  static CameraEvent eventOf(Map<String, Object?> json, String siteId) {
    final details = json['details'] is Map
        ? (json['details']! as Map).cast<String, Object?>()
        : const <String, Object?>{};
    final face = json['face'] is Map ? (json['face']! as Map).cast<String, Object?>() : null;
    final boxes = <EventBox>[];
    if (details['boxes'] case final List<Object?> list) {
      for (final item in list.whereType<Map<Object?, Object?>>()) {
        final box = item['box'];
        if (box is! List || box.length != 4 || box.any((v) => v is! num)) continue;
        final b = [for (final v in box) (v! as num).toDouble()];
        boxes.add(
          EventBox(
            object: (item['object'] as num?)?.toInt() ?? 0,
            label: item['label'] as String? ?? '',
            box: Rect.fromLTRB(min(b[0], b[2]), min(b[1], b[3]), max(b[0], b[2]), max(b[1], b[3])),
            at: (item['at'] as num?)?.toDouble() ?? 0,
          ),
        );
      }
    }
    final plates = <PlateCandidate>[
      if (details['plates'] case final List<Object?> list)
        for (final item in list.whereType<Map<Object?, Object?>>())
          if (item['text'] is String)
            PlateCandidate(
              text: item['text']! as String,
              display: text(item['display']) ?? item['text']! as String,
              format: text(item['format']),
              score: (item['score'] as num?)?.toDouble() ?? 0,
              reads: (item['reads'] as num?)?.toInt() ?? 1,
            ),
    ]..sort((a, b) => b.score.compareTo(a.score));
    final ended = text(json['ended_at']);
    return CameraEvent(
      id: json['uuid']! as String,
      siteId: siteId,
      cameraId: json['camera_uuid']! as String,
      cameraName: text(json['camera_name']) ?? '',
      viewId: text(json['view_uuid']),
      viewName: text(details['view_name']),
      kind: kindOf(json['kind']! as String) ?? EventKind.motion,
      source: json['source'] == 'analytics' ? EventSource.analytics : EventSource.camera,
      label: text(json['label']),
      alert: json['alert'] == true,
      acknowledged: json['acknowledged_at'] != null,
      startedAt: DateTime.parse(json['started_at']! as String).toLocal(),
      endedAt: ended == null ? null : DateTime.parse(ended).toLocal(),
      ongoing: json['ongoing'] == true,
      hasSnapshot: json['has_snapshot'] == true,
      hasClip: json['has_clip'] == true,
      zoneName: text(details['zone_name']),
      lineName: text(details['line_name']),
      direction: text(details['direction']),
      boxes: boxes,
      count: (details['count'] as num?)?.toInt(),
      profile: text(details['profile']),
      plates: plates,
      plateStatus: text(details['plate_status']),
      face: face == null
          ? null
          : FaceInfo(
              status: face['status'] == 'known' ? FaceStatus.known : FaceStatus.unknown,
              personId: text(face['person_uuid']),
              personName: text(face['person_name']),
              personColor: colorOf(face['person_color']),
              clusterId: text(face['cluster_uuid']),
              clusterLabel: text(face['cluster_label']),
              confidence: (face['confidence'] as num?)?.toDouble(),
              sampleId: face['has_crop'] == true ? text(face['sample_uuid']) : null,
            ),
    );
  }

  /// Writes [time] as the server expects it, in UTC.
  static String? iso(DateTime? time) => time?.toUtc().toIso8601String();

  /// The day [filter] covers, or its own range.
  static (DateTime?, DateTime?) rangeOf(EventFilter filter) {
    final day = filter.day;
    if (day != null) {
      final start = DateTime(day.year, day.month, day.day);
      return (start, start.add(const Duration(days: 1)));
    }
    return (filter.from, filter.until);
  }

  @override
  Future<EventPage> events(
    String siteId,
    EventFilter filter, {
    int page = 1,
    int pageSize = 30,
  }) async {
    final (from, to) = rangeOf(filter);
    final plate = filter.plate;
    if (plate != null && plate.isNotEmpty) {
      final list = await guarded(
        () => client.events.listEvents(
          xSite: siteId,
          page: page,
          pageSize: pageSize,
          plate: plate,
          cameraUuid: filter.cameraIds.length == 1 ? filter.cameraIds.first : null,
          from: iso(from),
          to: iso(to),
        ),
      );
      return EventPage(
        items: [for (final event in list.items) eventOf(event.toJson(), siteId)],
        total: list.total,
        page: list.page,
        pageSize: list.pageSize,
      );
    }
    final result = await guarded(
      () => client.search.searchEvents(
        xSite: siteId,
        page: page,
        pageSize: pageSize,
        from: iso(from),
        to: iso(to),
        camera: filter.cameraIds.isEmpty ? null : filter.cameraIds.toList(),
        view: filter.viewIds.isEmpty ? null : filter.viewIds.toList(),
        kind: filter.kinds.isEmpty ? null : [for (final kind in filter.kinds) wireKind(kind)],
        label: filter.labels.isEmpty ? null : filter.labels.toList(),
        zone: filter.zones.isEmpty ? null : filter.zones.toList(),
        line: filter.lines.isEmpty ? null : filter.lines.toList(),
        person: filter.personId,
        cluster: filter.clusterId,
        alert: filter.alertsOnly,
      ),
    );
    return EventPage(
      items: [for (final event in result.items) eventOf(event.toJson(), siteId)],
      total: result.total,
      page: result.page,
      pageSize: result.pageSize,
    );
  }

  @override
  Future<EventCounts> counts(String siteId, EventFilter filter) async {
    final (from, to) = rangeOf(filter);
    final counts = await guarded(
      () => client.events.countEvents(
        xSite: siteId,
        cameraUuid: filter.cameraIds.length == 1 ? filter.cameraIds.first : null,
        from: iso(from),
        to: iso(to),
      ),
    );
    final kinds = <EventKind, int>{};
    for (final entry in counts.kinds.entries) {
      final kind = kindOf(entry.key);
      if (kind != null) kinds[kind] = entry.value;
    }
    final review = await guarded(
      () => client.search.searchEvents(
        xSite: siteId,
        alert: true,
        from: iso(from),
        to: iso(to),
        pageSize: 200,
      ),
    );
    return EventCounts(
      total: counts.total,
      alerts: counts.alerts,
      unacknowledged: review.items
          .where((event) => event.toJson()['acknowledged_at'] == null)
          .length,
      kinds: kinds,
      labels: counts.labels,
    );
  }

  /// The site an event belongs to, which the server does not repeat in the event itself.
  String get site => currentSite() ?? '';

  @override
  Future<CameraEvent> event(String eventId) async =>
      eventOf((await guarded(() => client.events.getEvent(uuid: eventId))).toJson(), site);

  @override
  Future<CameraEvent> acknowledge(String eventId) async =>
      eventOf((await guarded(() => client.events.acknowledgeEvent(uuid: eventId))).toJson(), site);

  @override
  Future<int> acknowledgeAll(String siteId) async {
    final result = await guarded(
      () => client.search.searchEvents(xSite: siteId, alert: true, pageSize: 200),
    );
    var count = 0;
    for (final event in result.items) {
      if (event.toJson()['acknowledged_at'] != null) continue;
      await guarded(() => client.events.acknowledgeEvent(uuid: event.uuid, xSite: siteId));
      count++;
    }
    return count;
  }

  @override
  Stream<LiveUpdate> updates(String siteId) {
    late final StreamController<LiveUpdate> controller;
    CancelToken? cancel;
    var closed = false;
    final seen = <String>{};

    Future<void> run() async {
      var delay = const Duration(seconds: 1);
      while (!closed) {
        cancel = CancelToken();
        try {
          final response = await dio.get<ResponseBody>(
            '/api/v1/events/stream',
            cancelToken: cancel,
            options: Options(
              responseType: ResponseType.stream,
              receiveTimeout: Duration.zero,
              headers: {'Accept': 'text/event-stream', 'X-Site': siteId},
            ),
          );
          delay = const Duration(seconds: 1);
          var name = 'message';
          final data = StringBuffer();
          final lines = response.data!.stream
              .cast<List<int>>()
              .transform(utf8.decoder)
              .transform(const LineSplitter());
          await for (final line in lines) {
            if (line.isEmpty) {
              if (data.isNotEmpty) handle(controller, name, data.toString(), siteId, seen);
              name = 'message';
              data.clear();
            } else if (line.startsWith('event:')) {
              name = line.substring(6).trim();
            } else if (line.startsWith('data:')) {
              if (data.isNotEmpty) data.write('\n');
              data.write(line.substring(5).trimLeft());
            }
          }
        } on DioException catch (error) {
          if (CancelToken.isCancel(error)) return;
        } on Object {
          // A broken stream reconnects below.
        }
        if (closed) return;
        await Future<void>.delayed(delay);
        delay = Duration(seconds: min(delay.inSeconds * 2, 30));
      }
    }

    controller = StreamController<LiveUpdate>.broadcast(
      onListen: () => unawaited(run()),
      onCancel: () {
        closed = true;
        cancel?.cancel();
      },
    );
    return controller.stream;
  }

  /// Turns one server-sent event into app updates on [controller].
  static void handle(
    StreamController<LiveUpdate> controller,
    String name,
    String data,
    String siteId,
    Set<String> seen,
  ) {
    final Object? json;
    try {
      json = jsonDecode(data);
    } on FormatException {
      return;
    }
    if (json is! Map) return;
    switch (name) {
      case 'event':
        final event = eventOf(json.cast<String, Object?>(), siteId);
        controller.add(EventChanged(event, created: seen.add(event.id)));
      case 'hello':
        for (final open
            in (json['open'] as List<Object?>? ?? const []).whereType<Map<Object?, Object?>>()) {
          seen.add(open['uuid']! as String);
        }
      case 'source':
        final camera = json['camera_uuid'];
        final state = json['state'];
        if (camera is String && state is String) {
          controller.add(CameraStatusChanged(camera, state != 'offline'));
        }
    }
  }

  @override
  MediaSource snapshot(CameraEvent event) => NetworkMedia(
    '${baseUrl()}/api/v1/events/${event.id}/snapshot',
    cacheKey: 'event-${event.id}',
  );

  @override
  MediaSource thumbnail(CameraEvent event) => NetworkMedia(
    '${baseUrl()}/api/v1/events/${event.id}/thumbnail',
    cacheKey: 'thumb-${event.id}',
  );

  @override
  MediaSource? faceCrop(CameraEvent event) {
    final sample = event.face?.sampleId;
    if (sample == null) return null;
    return NetworkMedia(
      '${baseUrl()}/api/v1/people/samples/$sample/crop',
      cacheKey: 'sample-$sample',
    );
  }

  @override
  ClipSource? clip(CameraEvent event) =>
      event.hasClip ? NetworkClip('${baseUrl()}/api/v1/events/${event.id}/clip') : null;

  @override
  Future<String> downloadClip(CameraEvent event) async {
    final folder = await getTemporaryDirectory();
    final path = '${folder.path}/event-${event.id}.mp4';
    await guarded(() => dio.download('/api/v1/events/${event.id}/clip', path));
    return path;
  }

  /// Loads the bytes of [url] with the session's headers, for pictures drawn in code.
  Future<Uint8List> bytes(String url) async {
    final response = await guarded(
      () => dio.get<List<int>>(url, options: Options(responseType: ResponseType.bytes)),
    );
    return Uint8List.fromList(response.data ?? const []);
  }

  /// Whether [path] is a downloaded clip that still exists.
  static bool exists(String path) => File(path).existsSync();
}
