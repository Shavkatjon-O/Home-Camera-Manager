import 'dart:async';
import 'dart:ui';

import 'package:smart_surveillance/core/media/media_source.dart';
import 'package:smart_surveillance/core/network/api/surveillance_api.dart' as api;
import 'package:smart_surveillance/core/network/client/http.dart';
import 'package:smart_surveillance/core/network/failure.dart';
import 'package:smart_surveillance/features/analytics/domain/analytics_repository.dart';
import 'package:smart_surveillance/features/analytics/domain/models.dart';
import 'package:smart_surveillance/features/devices/domain/models.dart';
import 'package:smart_surveillance/features/events/data/api_event_repository.dart';
import 'package:smart_surveillance/features/insights/domain/models.dart';
import 'package:smart_surveillance/features/investigation/domain/models.dart';

/// Reads and changes camera analytics on the server: views, rules, live objects, counts and journeys.
class ApiAnalyticsRepository implements AnalyticsRepository {
  /// Creates the repository over [client]; [baseUrl] reads the server address.
  ApiAnalyticsRepository(this.client, this.baseUrl);

  /// The generated API.
  final api.SurveillanceApi client;

  /// Reads the server address.
  final String Function() baseUrl;

  /// How often the live objects of a view are polled.
  static const livePoll = Duration(seconds: 1);

  /// The fields of zones and lines that the app does not model, kept by rule id so a save keeps them.
  final Map<String, Map<String, Object?>> kept = {};

  /// Reads a JSON object.
  static Map<String, Object?> objectOf(Object? value) =>
      value is Map ? value.cast<String, Object?>() : const <String, Object?>{};

  /// Reads a JSON list of strings.
  static List<String> stringsOf(Object? value) => value is List
      ? [
          for (final item in value)
            if (item is String) item,
        ]
      : const <String>[];

  /// Reads a normalised point written as [x, y].
  static Offset pointOf(Object? value) {
    if (value is List && value.length >= 2 && value[0] is num && value[1] is num) {
      return Offset((value[0]! as num).toDouble(), (value[1]! as num).toDouble());
    }
    return Offset.zero;
  }

  /// Writes [point] as [x, y].
  static List<double> pointJson(Offset point) => [point.dx, point.dy];

  /// Converts the server's time windows to the app's [TimeWindow] list.
  static List<TimeWindow> windowsOf(Object? value) => [
    if (value is List)
      for (final item in value.whereType<Map<Object?, Object?>>())
        TimeWindow(
          start: item['start'] as String? ?? '00:00',
          end: item['end'] as String? ?? '23:59',
          days: [
            if (item['days'] case final List<Object?> days)
              for (final day in days.whereType<num>()) day.toInt()
            else ...const [0, 1, 2, 3, 4, 5, 6],
          ],
        ),
  ];

  /// Writes the app's [windows] as the server expects them.
  static List<Map<String, Object?>> windowsJson(List<TimeWindow> windows) => [
    for (final window in windows) {'start': window.start, 'end': window.end, 'days': window.days},
  ];

  /// Converts the server's alert policy and legacy schedule to the app's [AlertPolicy].
  static AlertPolicy policyOf(Object? alert, Object? schedule) {
    final json = objectOf(alert);
    final windows = windowsOf(json['schedule']);
    return AlertPolicy(
      mode: AlertMode.values.asNameMap()[json['mode']] ?? AlertMode.always,
      schedule: windows.isEmpty ? windowsOf(schedule) : windows,
      labels: stringsOf(json['labels']),
    );
  }

  /// Writes [policy] as the server's alert policy.
  static Map<String, Object?> policyJson(AlertPolicy policy) => {
    'mode': policy.mode.name,
    'schedule': windowsJson(policy.schedule),
    'labels': policy.labels,
  };

  /// Converts a direction written by the server to the app's [LineDirection].
  static LineDirection directionOf(Object? wire) => switch (wire) {
    'in' => LineDirection.inward,
    'out' => LineDirection.outward,
    _ => LineDirection.both,
  };

  /// Converts the app's [direction] to the server's wire value.
  static String directionWire(LineDirection direction) => switch (direction) {
    LineDirection.inward => 'in',
    LineDirection.outward => 'out',
    LineDirection.both => 'both',
  };

  /// Converts a zone as the server writes it in JSON to the app's [Zone].
  static Zone zoneOf(Map<String, Object?> json) => Zone(
    id: json['uuid'] as String?,
    name: json['name'] as String? ?? '',
    polygon: [
      if (json['polygon'] case final List<Object?> points)
        for (final p in points) pointOf(p),
    ],
    wholeView: json['whole_view'] == true,
    labels: stringsOf(json['labels']),
    minDwell: (json['min_dwell'] as num?)?.toDouble() ?? 1,
    loiterSeconds: (json['loiter_seconds'] as num?)?.toDouble() ?? 0,
    crowdCount: (json['crowd_count'] as num?)?.toInt() ?? 0,
    alert: policyOf(json['alert'], json['schedule']),
    enabled: json['enabled'] != false,
    suspended: json['suspended'] == true,
    leftSeconds: (json['left_seconds'] as num?)?.toDouble() ?? 0,
    takenSeconds: (json['taken_seconds'] as num?)?.toDouble() ?? 0,
    objectLabels: stringsOf(json['object_labels']),
    animals: AnimalMode.values.asNameMap()[json['animals']] ?? AnimalMode.record,
  );

  /// Converts a line as the server writes it in JSON to the app's [Line].
  static Line lineOf(Map<String, Object?> json) {
    final points = json['points'] is List ? json['points']! as List<Object?> : const <Object?>[];
    return Line(
      id: json['uuid'] as String?,
      name: json['name'] as String? ?? '',
      a: points.isNotEmpty ? pointOf(points[0]) : Offset.zero,
      b: points.length > 1 ? pointOf(points[1]) : Offset.zero,
      labels: stringsOf(json['labels']),
      direction: directionOf(json['direction']),
      alert: policyOf(json['alert'], json['schedule']),
      enabled: json['enabled'] != false,
      suspended: json['suspended'] == true,
      animals: AnimalMode.values.asNameMap()[json['animals']] ?? AnimalMode.record,
    );
  }

  /// Converts a view as the server writes it in JSON to the app's [AnalyticsView].
  static AnalyticsView viewOf(Map<String, Object?> json) {
    final status = objectOf(json['status']);
    final fps = (status['fps'] as num?)?.toDouble();
    return AnalyticsView(
      id: json['uuid']! as String,
      cameraId: json['camera_uuid']! as String,
      cameraName: json['camera_name'] as String? ?? '',
      lens: (json['lens'] as num?)?.toInt() ?? 0,
      lenses: (json['lenses'] as num?)?.toInt() ?? 1,
      name: json['name'] as String? ?? '',
      profile: Profile.values.asNameMap()[json['profile']] ?? Profile.perimeter,
      enabled: json['enabled'] != false,
      stream: json['stream'] == 'main' ? StreamQuality.main : StreamQuality.sub,
      fps: (json['fps'] as num?)?.toDouble() ?? 8,
      tamper: json['tamper'] != false,
      faces: json['faces'] == true,
      moving: json['moving'] == true,
      appearance: json['appearance'] != false,
      falls: json['falls'] == true,
      plates: json['plates'] == true,
      follow: json['follow'] == true,
      zones: [
        if (json['zones'] case final List<Object?> list)
          for (final zone in list) zoneOf(objectOf(zone)),
      ],
      lines: [
        if (json['lines'] case final List<Object?> list)
          for (final line in list) lineOf(objectOf(line)),
      ],
      suspended: status['suspended'] is List && (status['suspended']! as List).isNotEmpty,
      fpsMeasured: status['state'] == 'live' ? fps : null,
    );
  }

  /// Remembers the fields of the rules in [json] that the app does not model.
  void remember(Map<String, Object?> json) {
    for (final key in const ['zones', 'lines']) {
      if (json[key] case final List<Object?> list) {
        for (final item in list) {
          final rule = objectOf(item);
          final id = rule['uuid'];
          if (id is String) {
            kept[id] = {'reference': rule['reference'], 'background': rule['background']};
          }
        }
      }
    }
  }

  /// Converts [zone] to the server's zone input, restoring the fields the app does not model.
  Map<String, Object?> zoneJson(Zone zone) {
    final extra = kept[zone.id] ?? const <String, Object?>{};
    return {
      if (zone.id != null) 'uuid': zone.id,
      'name': zone.name,
      'polygon': [for (final point in zone.polygon) pointJson(point)],
      'whole_view': zone.wholeView,
      'labels': zone.labels,
      'min_dwell': zone.minDwell,
      'loiter_seconds': zone.loiterSeconds,
      'crowd_count': zone.crowdCount,
      'alert': policyJson(zone.alert),
      'enabled': zone.enabled,
      'left_seconds': zone.leftSeconds,
      'taken_seconds': zone.takenSeconds,
      'object_labels': zone.objectLabels,
      'animals': zone.animals.name,
      if (extra['reference'] != null) 'reference': extra['reference'],
      if (extra['background'] != null) 'background': extra['background'],
    };
  }

  /// Converts [line] to the server's line input, restoring the fields the app does not model.
  Map<String, Object?> lineJson(Line line) {
    final extra = kept[line.id] ?? const <String, Object?>{};
    return {
      if (line.id != null) 'uuid': line.id,
      'name': line.name,
      'points': [pointJson(line.a), pointJson(line.b)],
      'labels': line.labels,
      'direction': directionWire(line.direction),
      'alert': policyJson(line.alert),
      'enabled': line.enabled,
      'animals': line.animals.name,
      if (extra['reference'] != null) 'reference': extra['reference'],
    };
  }

  /// Converts the server's area to the app's [Area].
  static Area areaOf(api.AreaRead area) {
    final json = area.toJson();
    return Area(
      id: area.uuid,
      name: area.name,
      occupancy: area.occupancy,
      entered: area.entered,
      exited: area.exited,
      since: area.since.toLocal(),
      resetAt: json['reset_at'] as String?,
      labels: stringsOf(json['labels']),
      lineNames: [
        if (json['lines'] case final List<Object?> lines)
          for (final line in lines)
            if (objectOf(line)['line_name'] case final String name) name,
      ],
    );
  }

  /// Reads the time of a JSON field as local time.
  static DateTime timeOf(Object? value) =>
      DateTime.tryParse(value as String? ?? '')?.toLocal() ??
      DateTime.fromMillisecondsSinceEpoch(0);

  @override
  Future<List<AnalyticsView>> views(String siteId) async {
    final list = await guarded(() => client.analytics.listViews(xSite: siteId));
    final json = list.toJson();
    remember(json);
    return [
      if (json['items'] case final List<Object?> items)
        for (final item in items) viewOf(objectOf(item)),
    ];
  }

  @override
  Future<AnalyticsView> view(String viewId) async {
    final list = await guarded(() => client.analytics.listViews());
    final json = list.toJson();
    remember(json);
    for (final item in json['items'] as List<Object?>? ?? const <Object?>[]) {
      if (objectOf(item)['uuid'] == viewId) return viewOf(objectOf(item));
    }
    throw const ApiFailure(FailureKind.notFound, 'view');
  }

  @override
  Future<AnalyticsView> updateView(AnalyticsView view) async {
    final body = api.ViewUpdate.fromJson({
      'name': view.name,
      'profile': view.profile.name,
      'enabled': view.enabled,
      'fps': view.fps,
      'tamper': view.tamper,
      'faces': view.faces,
      'moving': view.moving,
      'appearance': view.appearance,
      'falls': view.falls,
      'plates': view.plates,
      'follow': view.follow,
      'stream': view.stream.name,
    });
    final stored = await guarded(() => client.analytics.updateView(uuid: view.id, body: body));
    final json = stored.toJson();
    remember(json);
    return viewOf(json);
  }

  @override
  Future<AnalyticsView> saveRules(
    String viewId, {
    required List<Zone> zones,
    required List<Line> lines,
  }) async {
    final body = api.RulesUpdate(
      zones: [for (final zone in zones) api.ZoneInput.fromJson(zoneJson(zone))],
      lines: [for (final line in lines) api.LineInput.fromJson(lineJson(line))],
    );
    final stored = await guarded(() => client.analytics.replaceRules(uuid: viewId, body: body));
    final json = stored.toJson();
    remember(json);
    return viewOf(json);
  }

  @override
  Future<MediaSource> viewSnapshot(String viewId) async => NetworkMedia(
    '${baseUrl()}/api/v1/analytics/views/$viewId/snapshot',
    cacheKey: 'view-$viewId',
  );

  @override
  Stream<List<LiveObject>> liveObjects(String viewId) {
    late final StreamController<List<LiveObject>> controller;
    Timer? timer;
    var busy = false;

    Future<void> poll() async {
      if (busy) return;
      busy = true;
      try {
        final live = await guarded(() => client.analytics.getViewObjects(uuid: viewId));
        if (controller.isClosed || !controller.hasListener) return;
        controller.add([
          for (final item in (live.toJson()['objects'] as List<Object?>? ?? const <Object?>[]))
            if (liveOf(objectOf(item)) case final LiveObject object) object,
        ]);
      } on ApiFailure {
        return;
      } finally {
        busy = false;
      }
    }

    controller = StreamController<List<LiveObject>>.broadcast(
      onListen: () {
        unawaited(poll());
        timer = Timer.periodic(livePoll, (_) => unawaited(poll()));
      },
      onCancel: () {
        timer?.cancel();
        timer = null;
      },
    );
    return controller.stream;
  }

  /// Converts a tracked object as the server writes it in JSON to the app's [LiveObject].
  static LiveObject? liveOf(Map<String, Object?> json) {
    final box = json['box'];
    if (box is! List || box.length != 4 || box.any((v) => v is! num)) return null;
    final b = [for (final v in box) (v! as num).toDouble()];
    return LiveObject(
      track: (json['track'] as num?)?.toInt() ?? 0,
      label: json['label'] as String? ?? '',
      box: Rect.fromLTRB(b[0], b[1], b[2], b[3]),
    );
  }

  @override
  Future<CountsReport> counts(
    String siteId, {
    required DateTime start,
    required DateTime end,
    required Bucket bucket,
  }) async {
    final read = await guarded(
      () => client.analytics.readCounts(
        xSite: siteId,
        start: ApiEventRepository.iso(start)!,
        end: ApiEventRepository.iso(end)!,
        bucket: api.ReadCountsBucket.fromJson(bucket.name),
      ),
    );
    final json = read.toJson();
    return CountsReport(
      start: timeOf(json['start']),
      end: timeOf(json['end']),
      bucket: bucket,
      lines: [
        for (final item in json['lines'] as List<Object?>? ?? const <Object?>[])
          CountLine(
            id: objectOf(item)['uuid']! as String,
            name: objectOf(item)['name'] as String? ?? '',
            viewName: objectOf(item)['view_name'] as String? ?? '',
            cameraName: objectOf(item)['camera_name'] as String? ?? '',
          ),
      ],
      buckets: [
        for (final item in json['buckets'] as List<Object?>? ?? const <Object?>[])
          CountBucket(
            lineId: objectOf(item)['line_uuid']! as String,
            at: timeOf(objectOf(item)['at']),
            label: objectOf(item)['label'] as String? ?? '',
            inward: (objectOf(item)['in'] as num?)?.toInt() ?? 0,
            outward: (objectOf(item)['out'] as num?)?.toInt() ?? 0,
          ),
      ],
    );
  }

  @override
  Future<List<Area>> areas(String siteId) async {
    final list = await guarded(() => client.analytics.listAreas(xSite: siteId));
    return [for (final area in list.items) areaOf(area)];
  }

  @override
  Future<Area> resetArea(String areaId, int occupancy) async => areaOf(
    await guarded(
      () => client.analytics.resetArea(
        uuid: areaId,
        body: api.AreaReset.fromJson({'occupancy': occupancy}),
      ),
    ),
  );

  @override
  Future<Journey?> journey(String eventId) async {
    final api.JourneyRead read;
    try {
      read = await guarded(() => client.analytics.readEventJourney(uuid: eventId));
    } on ApiFailure catch (failure) {
      if (failure.kind == FailureKind.notFound) return null;
      rethrow;
    }
    final json = read.toJson();
    return Journey(
      id: read.uuid,
      description: json['description'] as String? ?? '',
      startedAt: timeOf(json['started_at']),
      endedAt: timeOf(json['ended_at']),
      steps: [
        for (final item in json['steps'] as List<Object?>? ?? const <Object?>[])
          JourneyStep(
            cameraName: objectOf(item)['camera_name'] as String? ?? '',
            viewName: objectOf(item)['view_name'] as String?,
            startedAt: timeOf(objectOf(item)['started_at']),
            endedAt: timeOf(objectOf(item)['ended_at']),
            similarity: (objectOf(item)['similarity'] as num?)?.toDouble(),
            eventId: objectOf(item)['event_uuid'] as String?,
          ),
      ],
    );
  }

  @override
  Future<List<AppearanceMatch>> findPerson(String eventId) async {
    final found = await guarded(
      () => client.analytics.findPerson(
        body: api.SimilarAppearanceQuery.fromJson({'event_uuid': eventId}),
      ),
    );
    return [
      for (final item in found.toJson()['items'] as List<Object?>? ?? const <Object?>[])
        AppearanceMatch(
          id: objectOf(item)['uuid']! as String,
          cameraName: objectOf(item)['camera_name'] as String? ?? '',
          viewName: objectOf(item)['view_name'] as String?,
          startedAt: timeOf(objectOf(item)['started_at']),
          endedAt: timeOf(objectOf(item)['ended_at']),
          similarity: (objectOf(item)['similarity'] as num?)?.toDouble() ?? 0,
          eventId: objectOf(item)['event_uuid'] as String?,
          journeyId: objectOf(item)['journey_uuid'] as String?,
          thumbnail: objectOf(item)['event_uuid'] is String
              ? NetworkMedia(
                  '${baseUrl()}/api/v1/events/${objectOf(item)['event_uuid']}/thumbnail',
                  cacheKey: 'thumb-${objectOf(item)['event_uuid']}',
                )
              : null,
        ),
    ];
  }
}
