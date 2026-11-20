import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:smart_surveillance/app/demo/fixtures.dart';
import 'package:smart_surveillance/core/media/media_source.dart';
import 'package:smart_surveillance/features/events/domain/models.dart';
import 'package:smart_surveillance/features/tenancy/domain/models.dart';
class FakeStore {
  FakeStore({DateTime Function()? clock, this.latency = const Duration(milliseconds: 280), this.live = true})
    : clock = clock ?? DateTime.now {
    data = Fixtures(this.clock());
  }

  final DateTime Function() clock;
  final Duration latency;
  final bool live;
  late Fixtures data;
  bool signedIn = false;
  bool fresh = false;
  final createdOrganisations = <String>{};
  final controllers = <String, StreamController<LiveUpdate>>{};
  Timer? ticker;
  int sequence = 1000;

  Future<T> delay<T>(T Function() action) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    return action();
  }

  Organisation organisation(String id) => data.organisations.firstWhere((o) => o.id == id);

  Site site(String id) => data.sites.firstWhere((s) => s.id == id);

  StreamController<LiveUpdate> channel(String siteId) {
    final existing = controllers[siteId];
    if (existing != null) return existing;
    final controller = StreamController<LiveUpdate>.broadcast();
    controllers[siteId] = controller;
    if (live) {
      ticker ??= Timer.periodic(const Duration(seconds: 35), (_) => tick());
    }
    return controller;
  }

  void tick() {
    for (final entry in controllers.entries) {
      final siteCameras = data.cameras.where((c) => c.camera.siteId == entry.key && c.camera.online == true);
      if (siteCameras.isEmpty) continue;
      final random = Random(sequence);
      final fixture = siteCameras.elementAt(random.nextInt(siteCameras.length));
      final view = data.viewFor(fixture.camera.id);
      final zone = view.zones.isNotEmpty ? view.zones.first.name : null;
      final event = CameraEvent(
        id: 'event-live-${sequence++}',
        siteId: entry.key,
        cameraId: fixture.camera.id,
        cameraName: fixture.camera.name,
        viewId: view.id,
        viewName: view.name,
        kind: zone != null ? EventKind.intrusion : EventKind.person,
        source: EventSource.analytics,
        label: 'person',
        alert: random.nextBool(),
        startedAt: clock(),
        ongoing: true,
        hasClip: false,
        zoneName: zone,
        boxes: [
          EventBox(object: sequence, label: 'person', box: Rect.fromLTWH(0.3 + random.nextDouble() * 0.3, 0.42, 0.1, 0.36)),
        ],
        count: 1,
        aspect: fixture.camera.aspect * fixture.camera.lenses,
      );
      data.events.insert(0, event);
      entry.value.add(EventChanged(event, created: true));
    }
  }

  void dispose() {
    ticker?.cancel();
    for (final controller in controllers.values) {
      unawaited(controller.close());
    }
  }

  SyntheticMedia sceneFor(String cameraId, int lens) {
    final fixture = data.camera(cameraId);
    final scene = fixture.scenes[lens.clamp(0, fixture.scenes.length - 1)];
    final hour = clock().hour;
    return SyntheticMedia(scene, seed: cameraId.hashCode + lens, night: hour < 6 || hour >= 20);
  }

  SyntheticMedia eventScene(CameraEvent event) {
    final view = data.views.where((v) => v.id == event.viewId).firstOrNull;
    final base = sceneFor(event.cameraId, view?.lens ?? 0);
    final hour = event.startedAt.hour;
    return SyntheticMedia(
      base.scene,
      seed: base.seed,
      night: hour < 6 || hour >= 20,
      figures: [for (final box in event.boxes) SceneFigure(box.label, box.box)],
      at: event.startedAt,
    );
  }
}
