import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import '../models/account.dart';
import '../models/analytics.dart';
import '../models/business.dart';
import '../models/camera.dart';
import '../models/event.dart';
import '../models/insights.dart';
import '../models/media.dart';
import '../models/pairing.dart';
import '../models/people.dart';
import '../repositories.dart';
import 'fixtures.dart';

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

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository(this.store);

  final FakeStore store;

  @override
  Future<User?> restore() => store.delay(() => store.signedIn ? store.data.user : null);

  @override
  Future<User> signIn({required String email, required String password}) => store.delay(() {
    if (password.length < 4) throw const ApiFailure(FailureKind.unauthorised);
    store.signedIn = true;
    return store.data.user;
  });

  @override
  Future<SignUpResult> signUp({required String name, required String email, required String password}) =>
      store.delay(() {
        if (email.startsWith('taken@')) throw const ApiFailure(FailureKind.conflict);
        store.data.user = User(id: 'user-new', name: name, email: email, verified: false);
        store.fresh = true;
        return SignUpResult(email: email, needsVerification: true);
      });

  @override
  Future<void> resendVerification(String email) => store.delay(() {});

  @override
  Future<User> verifyEmail({required String token}) => store.delay(() {
    if (token.length < 6) throw const ApiFailure(FailureKind.invalid);
    store.data.user = store.data.user.copyWith(verified: true);
    return store.data.user;
  });

  @override
  Future<void> requestPasswordReset(String email) => store.delay(() {});

  @override
  Future<void> resetPassword({required String token, required String password}) => store.delay(() {
    if (token.length < 6) throw const ApiFailure(FailureKind.invalid);
  });

  @override
  Future<void> signOut() => store.delay(() => store.signedIn = false);

  @override
  Future<void> deleteAccount(String password) => store.delay(() {
    if (password.isEmpty) throw const ApiFailure(FailureKind.unauthorised);
    store.signedIn = false;
  });

  @override
  Future<List<DeviceSession>> sessions() => store.delay(() => List.of(store.data.sessions));

  @override
  Future<void> revokeSession(String id) => store.delay(() => store.data.sessions.removeWhere((s) => s.id == id));

  @override
  Future<User> updateProfile({required String name}) => store.delay(() {
    store.data.user = store.data.user.copyWith(name: name);
    return store.data.user;
  });
}

class FakeTenancyRepository implements TenancyRepository {
  FakeTenancyRepository(this.store);

  final FakeStore store;

  @override
  Future<List<Organisation>> organisations() => store.delay(
    () => store.fresh
        ? store.data.organisations.where((o) => store.createdOrganisations.contains(o.id)).toList()
        : List.of(store.data.organisations),
  );

  @override
  Future<Organisation> createOrganisation(String name) => store.delay(() {
    final organisation = Organisation(
      id: 'org-${store.sequence++}',
      name: name,
      role: Role.owner,
      facesEnabled: false,
    );
    store.data.organisations.add(organisation);
    store.createdOrganisations.add(organisation.id);
    store.data.members[organisation.id] = [
      Member(
        userId: store.data.user.id,
        name: store.data.user.name,
        email: store.data.user.email,
        role: Role.owner,
        you: true,
        lastActiveAt: store.clock(),
      ),
    ];
    return organisation;
  });

  @override
  Future<List<Site>> sites(String organisationId) =>
      store.delay(() => store.data.sites.where((s) => s.organisationId == organisationId).toList());

  @override
  Future<Site> createSite({
    required String organisationId,
    required String name,
    required SiteKind kind,
    required String timezone,
  }) => store.delay(() {
    final site = Site(
      id: 'site-${store.sequence++}',
      organisationId: organisationId,
      name: name,
      kind: kind,
      timezone: timezone,
    );
    store.data.sites.add(site);
    store.data.prefs[site.id] = NotificationPrefs(siteId: site.id);
    return site;
  });

  @override
  Future<Site> updateSite(Site site) => store.delay(() {
    final index = store.data.sites.indexWhere((s) => s.id == site.id);
    store.data.sites[index] = site;
    return site;
  });

  @override
  Future<Site> setArmMode(String siteId, ArmMode mode) => store.delay(() {
    final index = store.data.sites.indexWhere((s) => s.id == siteId);
    final site = store.data.sites[index].copyWith(armMode: mode);
    store.data.sites[index] = site;
    store.controllers[siteId]?.add(ArmChanged(siteId));
    return site;
  });

  @override
  Future<({String version, String? text})> facesConsent() => store.delay(() => (version: 'demo-1', text: null));

  @override
  Future<Organisation> setFaces(String organisationId, bool enabled, {String? consentVersion}) => store.delay(() {
    final index = store.data.organisations.indexWhere((o) => o.id == organisationId);
    final organisation = store.data.organisations[index].copyWith(facesEnabled: enabled);
    store.data.organisations[index] = organisation;
    return organisation;
  });

  @override
  Future<List<Member>> members(String organisationId) =>
      store.delay(() => List.of(store.data.members[organisationId] ?? const []));

  @override
  Future<List<Invitation>> invitations(String organisationId) =>
      store.delay(() => List.of(store.data.invitations[organisationId] ?? const []));

  @override
  Future<Invitation> invite({
    required String organisationId,
    required String email,
    required Role role,
    List<String>? siteIds,
  }) => store.delay(() {
    final invitation = Invitation(
      id: 'inv-${store.sequence++}',
      email: email,
      role: role,
      siteIds: siteIds,
      expiresAt: store.clock().add(const Duration(days: 7)),
      invitedBy: store.data.user.name,
    );
    (store.data.invitations[organisationId] ??= []).insert(0, invitation);
    return invitation;
  });

  @override
  Future<void> revokeInvitation(String organisationId, String invitationId) =>
      store.delay(() => store.data.invitations[organisationId]?.removeWhere((i) => i.id == invitationId));

  @override
  Future<Member> updateMember(String organisationId, String userId, {required Role role, List<String>? siteIds}) =>
      store.delay(() {
        final list = store.data.members[organisationId]!;
        final index = list.indexWhere((m) => m.userId == userId);
        final member = list[index].copyWith(role: role, siteIds: siteIds);
        list[index] = member;
        return member;
      });

  @override
  Future<void> removeMember(String organisationId, String userId) =>
      store.delay(() => store.data.members[organisationId]?.removeWhere((m) => m.userId == userId));

  @override
  Future<InvitationPreview> previewInvitation(String token) => store.delay(() {
    if (token == 'expired') throw const ApiFailure(FailureKind.expired);
    return InvitationPreview(
      token: token,
      organisationName: 'Demo organisation',
      invitedBy: 'Demo owner',
      role: Role.operator,
      siteNames: const ['Demo store'],
      expiresAt: store.clock().add(const Duration(days: 5)),
    );
  });

  @override
  Future<Organisation> acceptInvitation(String token) => store.delay(() {
    store.fresh = false;
    return store.organisation(Fixtures.demoOrg);
  });
}

class FakeDeviceRepository implements DeviceRepository {
  FakeDeviceRepository(this.store);

  final FakeStore store;

  @override
  Future<List<Connector>> connectors(String siteId) =>
      store.delay(() => store.data.connectors.where((c) => c.siteId == siteId).toList());

  @override
  Future<void> removeConnector(String connectorId) =>
      store.delay(() => store.data.connectors.removeWhere((c) => c.id == connectorId));

  @override
  Future<List<DiscoveredCamera>> discovered(String connectorId, {bool rescan = false}) async {
    if (rescan && store.latency > Duration.zero) await Future<void>.delayed(const Duration(milliseconds: 1400));
    return store.delay(() => List.of(store.data.discovered[connectorId] ?? const []));
  }

  @override
  Future<StreamTest> testCamera({
    required String connectorId,
    required DiscoveredCamera camera,
    String? username,
    String? password,
  }) async {
    if (store.latency > Duration.zero) await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (camera.brand != CameraBrand.rtsp && (password == null || password.isEmpty)) {
      return const StreamTest(ok: false, error: 'unauthorised');
    }
    final dual = camera.brand == CameraBrand.v380;
    return StreamTest(
      ok: true,
      codec: 'H.265',
      width: dual ? 2304 : 2560,
      height: dual ? 2592 : 1440,
      lenses: dual ? 2 : 1,
      preview: SyntheticMedia(dual ? SceneKind.yard : SceneKind.street, seed: camera.id.hashCode),
    );
  }

  @override
  Future<Camera> addCamera({
    required String siteId,
    required String connectorId,
    required DiscoveredCamera camera,
    required String name,
    String? username,
    String? password,
    required int lenses,
  }) => store.delay(() {
    final created = Camera(
      id: 'cam-${store.sequence++}',
      siteId: siteId,
      connectorId: connectorId,
      name: name,
      brand: camera.brand ?? CameraBrand.onvif,
      model: camera.model,
      lenses: lenses,
      capabilities: CameraCapabilities(
        ptz: camera.ptz,
        presets: camera.ptz,
        home: camera.ptz,
        light: camera.brand == CameraBrand.v380,
        siren: camera.brand == CameraBrand.v380,
        settings: camera.brand != CameraBrand.rtsp,
        reboot: camera.brand != CameraBrand.rtsp,
      ),
      online: true,
      position: store.data.cameras.where((c) => c.camera.siteId == siteId).length,
      aspect: lenses == 2 ? 16 / 18 : 16 / 9,
      checkedAt: store.clock(),
    );
    store.data.cameras.add(
      CameraFixture(created, lenses == 2 ? [SceneKind.yard, SceneKind.entrance] : [SceneKind.street]),
    );
    for (var lens = 0; lens < lenses; lens++) {
      store.data.views.add(
        AnalyticsView(
          id: 'view-${created.id}-$lens',
          cameraId: created.id,
          cameraName: name,
          lens: lens,
          lenses: lenses,
          name: lenses > 1 ? '$name lens ${lens + 1}' : name,
        ),
      );
    }
    final list = store.data.discovered[connectorId];
    if (list != null) {
      final index = list.indexWhere((d) => d.id == camera.id);
      if (index >= 0) list[index] = list[index].copyWith(cameraId: created.id);
    }
    return created;
  });

  @override
  Future<List<Camera>> cameras(String siteId) => store.delay(
    () =>
        store.data.cameras.map((c) => c.camera).where((c) => c.siteId == siteId).toList()
          ..sort((a, b) => a.position.compareTo(b.position)),
  );

  @override
  Future<Camera> updateCamera(Camera camera) => store.delay(() {
    final index = store.data.cameras.indexWhere((c) => c.camera.id == camera.id);
    store.data.cameras[index] = CameraFixture(camera, store.data.cameras[index].scenes);
    return camera;
  });

  @override
  Future<void> deleteCamera(String cameraId) => store.delay(() {
    store.data.cameras.removeWhere((c) => c.camera.id == cameraId);
    store.data.views.removeWhere((v) => v.cameraId == cameraId);
  });

  @override
  Future<void> orderCameras(String siteId, List<String> cameraIds) => store.delay(() {
    for (var i = 0; i < cameraIds.length; i++) {
      final index = store.data.cameras.indexWhere((c) => c.camera.id == cameraIds[i]);
      final fixture = store.data.cameras[index];
      store.data.cameras[index] = CameraFixture(fixture.camera.copyWith(position: i), fixture.scenes);
    }
  });

  @override
  Future<CameraControls> controls(String cameraId) =>
      store.delay(() => CameraControls(presets: store.data.presets[cameraId] ?? const []));

  @override
  Future<void> move(String cameraId, {required double pan, required double tilt, required double zoom}) async {}

  @override
  Future<void> stop(String cameraId) async {}

  @override
  Future<void> gotoPreset(String cameraId, String token) => store.delay(() {});

  @override
  Future<PtzPreset> savePreset(String cameraId, String name) => store.delay(() {
    final list = store.data.presets[cameraId] ??= [];
    final preset = PtzPreset(token: '${list.length + 1}', name: name);
    list.add(preset);
    return preset;
  });

  @override
  Future<void> gotoHome(String cameraId) => store.delay(() {});

  @override
  Future<void> setLight(String cameraId, bool on) => store.delay(() {});

  @override
  Future<void> sirenFor(String cameraId, Duration duration) => store.delay(() {});

  @override
  Future<CameraSettings> settings(String cameraId) => store.delay(() {
    final camera = store.data.camera(cameraId).camera;
    return CameraSettings(
      device: CameraDevice(
        manufacturer: camera.brand == CameraBrand.ezviz ? 'EZVIZ' : 'Generic',
        model: camera.model ?? 'IP camera',
        firmware: 'V5.3.8 build 241104',
        clockOffsetSeconds: 1.4,
        timezone: 'UTC+05:00',
        canReboot: true,
      ),
      encoders: const [
        VideoEncoder(token: 'main', name: 'Main stream', encoding: 'H.265', width: 2560, height: 1440, fps: 15, bitrate: 2048),
        VideoEncoder(token: 'sub', name: 'Sub stream', encoding: 'H.264', width: 768, height: 432, fps: 15, bitrate: 512),
      ],
      image: const ImageSettings(
        brightness: 50,
        contrast: 50,
        saturation: 50,
        sharpness: 50,
        irCut: 'AUTO',
        irCutModes: ['AUTO', 'ON', 'OFF'],
      ),
      motion: const MotionSettings(enabled: true, sensitivity: 60),
    );
  });

  @override
  Future<void> updateMotion(String cameraId, MotionSettings motion) => store.delay(() {});

  @override
  Future<void> updateImage(String cameraId, ImageSettings image) => store.delay(() {});

  @override
  Future<void> syncClock(String cameraId) => store.delay(() {});

  @override
  Future<void> reboot(String cameraId) => store.delay(() {});
}

class FakePairingRepository implements PairingRepository {
  FakePairingRepository(this.store, this.devices);

  final FakeStore store;
  final FakeDeviceRepository devices;
  final reports = <PairingReport>[];

  @override
  Future<List<PairingCatalogEntry>> catalog(String siteId, {String? label, String? discoveredId}) => store.delay(() {
    final connectors = store.data.connectors.where((c) => c.siteId == siteId && c.state == ConnectorState.online);
    final online = connectors.isNotEmpty;
    final nvr = online && (store.data.discovered[connectors.first.id] ?? const []).any((d) => d.nvr && d.cameraId == null);
    return [
      PairingCatalogEntry(id: 'connector_discovery', rank: 1, available: online, recommended: online),
      const PairingCatalogEntry(id: 'label_qr', rank: 2),
      PairingCatalogEntry(id: 'manual_host', rank: 3, available: online),
      PairingCatalogEntry(id: 'nvr_import', rank: 4, available: nvr),
      PairingCatalogEntry(id: 'rtsp_url', rank: 5, available: online),
      const PairingCatalogEntry(id: 'connector_qr', rank: 10, recommended: true),
      const PairingCatalogEntry(id: 'connector_mdns', rank: 11),
      const PairingCatalogEntry(id: 'connector_code', rank: 12),
    ];
  });

  @override
  Future<Connector> claimConnector({required String siteId, required String code, String? name}) =>
      store.delay(() {
        final cleaned = code.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
        if (cleaned.length != 8) throw const ApiFailure(FailureKind.invalid);
        if (cleaned.toUpperCase() == 'EXPIRED0') throw const ApiFailure(FailureKind.expired);
        final connector = Connector(
          id: 'con-${store.sequence++}',
          siteId: siteId,
          name: name ?? 'Connector',
          state: ConnectorState.online,
          version: '0.1.0',
          lastSeenAt: store.clock(),
        );
        store.data.connectors.add(connector);
        store.data.discovered[connector.id] = List.of(store.data.discovered['con-home']!)
            .map((d) => d.copyWith(cameraId: null))
            .toList();
        return connector;
      });

  @override
  Future<LabelIdentity> identifyLabel(String siteId, String payload) => store.delay(() {
    final upper = payload.toUpperCase();
    if (upper.contains('EZVIZ') || upper.startsWith('SN')) {
      return const LabelIdentity(
        method: 'connector_discovery',
        brand: CameraBrand.ezviz,
        manufacturer: 'EZVIZ',
        model: 'CS-H3',
        serial: 'DEMO00001',
        discoveredId: 'disc-1',
      );
    }
    if (upper.contains('V380')) {
      return const LabelIdentity(
        method: 'manual_host',
        brand: CameraBrand.v380,
        manufacturer: 'V380',
        model: 'Dual lens PTZ',
        port: 8899,
      );
    }
    throw const ApiFailure(FailureKind.notFound, 'unknown_label');
  });

  @override
  Future<DiscoveredCamera> identifyHost({
    required String connectorId,
    required String host,
    int? port,
    String? username,
    String? password,
  }) async {
    if (store.latency > Duration.zero) await Future<void>.delayed(const Duration(milliseconds: 900));
    return store.delay(() {
      if (!RegExp(r'^[0-9A-Za-z.-]+$').hasMatch(host)) throw const ApiFailure(FailureKind.invalid, 'host');
      return DiscoveredCamera(
        id: 'manual-${host.hashCode}',
        host: host,
        ports: [port ?? 80, 554],
        brand: CameraBrand.onvif,
        manufacturer: 'Generic',
        model: 'IP camera',
        onvifPort: port ?? 80,
        foundBy: 'manual',
      );
    });
  }

  @override
  Future<List<NvrChannel>> nvrChannels({
    required String connectorId,
    required DiscoveredCamera nvr,
    String? username,
    String? password,
  }) => store.delay(() {
    if (password == null || password.isEmpty) throw const ApiFailure(FailureKind.unauthorised);
    return [for (var i = 1; i <= 8; i++) NvrChannel(index: i, name: 'Channel $i', online: i != 6)];
  });

  @override
  Future<List<Camera>> addChannels({
    required String siteId,
    required String connectorId,
    required DiscoveredCamera nvr,
    required List<NvrChannel> channels,
    String? username,
    String? password,
  }) async {
    final added = <Camera>[];
    for (final channel in channels) {
      added.add(
        await devices.addCamera(
          siteId: siteId,
          connectorId: connectorId,
          camera: nvr.copyWith(id: '${nvr.id}-${channel.index}', nvr: false),
          name: channel.name,
          username: username,
          password: password,
          lenses: 1,
        ),
      );
    }
    final list = store.data.discovered[connectorId];
    if (list != null) {
      final index = list.indexWhere((d) => d.id == nvr.id);
      if (index >= 0 && added.isNotEmpty) list[index] = list[index].copyWith(cameraId: added.first.id);
    }
    return added;
  }

  @override
  Future<void> report(PairingReport report) async => reports.add(report);
}

class FakeLiveRepository implements LiveRepository {
  FakeLiveRepository(this.store);

  final FakeStore store;

  @override
  LiveSource live(Camera camera, {required StreamQuality quality, bool audio = false}) =>
      SyntheticLive([for (var lens = 0; lens < camera.lenses; lens++) store.sceneFor(camera.id, lens)]);

  @override
  Future<MediaSource> snapshot(Camera camera) => store.delay(() => store.sceneFor(camera.id, 0));
}

class FakeEventRepository implements EventRepository {
  FakeEventRepository(this.store);

  final FakeStore store;

  bool matches(CameraEvent event, EventFilter filter) {
    if (filter.day != null) {
      final day = filter.day!;
      final start = DateTime(day.year, day.month, day.day);
      if (event.startedAt.isBefore(start) || !event.startedAt.isBefore(start.add(const Duration(days: 1)))) {
        return false;
      }
    }
    if (filter.from != null && event.startedAt.isBefore(filter.from!)) return false;
    if (filter.until != null && event.startedAt.isAfter(filter.until!)) return false;
    if (filter.cameraIds.isNotEmpty && !filter.cameraIds.contains(event.cameraId)) return false;
    if (filter.viewIds.isNotEmpty && !filter.viewIds.contains(event.viewId)) return false;
    if (filter.kinds.isNotEmpty && !filter.kinds.contains(event.kind)) return false;
    if (filter.labels.isNotEmpty && !filter.labels.contains(event.label)) return false;
    if (filter.zones.isNotEmpty && !filter.zones.contains(event.zoneName)) return false;
    if (filter.lines.isNotEmpty && !filter.lines.contains(event.lineName)) return false;
    if (filter.alertsOnly && !event.alert) return false;
    if (filter.personId != null && event.face?.personId != filter.personId) return false;
    if (filter.clusterId != null && event.face?.clusterId != filter.clusterId) return false;
    if (filter.plate != null && filter.plate!.isNotEmpty) {
      final query = filter.plate!.replaceAll(' ', '').toUpperCase();
      if (!event.plates.any((p) => p.text.contains(query))) return false;
    }
    return true;
  }

  @override
  Future<EventPage> events(String siteId, EventFilter filter, {int page = 1, int pageSize = 30}) => store.delay(() {
    final all = store.data.events.where((e) => e.siteId == siteId && matches(e, filter)).toList();
    final start = (page - 1) * pageSize;
    final items = start >= all.length ? <CameraEvent>[] : all.sublist(start, min(all.length, start + pageSize));
    return EventPage(items: items, total: all.length, page: page, pageSize: pageSize);
  });

  @override
  Future<EventCounts> counts(String siteId, EventFilter filter) => store.delay(() {
    final all = store.data.events.where((e) => e.siteId == siteId && matches(e, filter)).toList();
    final kinds = <EventKind, int>{};
    final labels = <String, int>{};
    for (final event in all) {
      kinds[event.kind] = (kinds[event.kind] ?? 0) + 1;
      if (event.label != null) labels[event.label!] = (labels[event.label!] ?? 0) + 1;
    }
    return EventCounts(
      total: all.length,
      alerts: all.where((e) => e.alert).length,
      unacknowledged: all.where((e) => e.alert && !e.acknowledged).length,
      kinds: kinds,
      labels: labels,
    );
  });

  @override
  Future<CameraEvent> event(String eventId) => store.delay(() {
    final event = store.data.events.where((e) => e.id == eventId).firstOrNull;
    if (event == null) throw const ApiFailure(FailureKind.notFound);
    return event;
  });

  @override
  Future<CameraEvent> acknowledge(String eventId) => store.delay(() {
    final index = store.data.events.indexWhere((e) => e.id == eventId);
    final event = store.data.events[index].copyWith(acknowledged: true);
    store.data.events[index] = event;
    store.controllers[event.siteId]?.add(EventChanged(event));
    return event;
  });

  @override
  Future<int> acknowledgeAll(String siteId) => store.delay(() {
    var changed = 0;
    for (var i = 0; i < store.data.events.length; i++) {
      final event = store.data.events[i];
      if (event.siteId == siteId && event.alert && !event.acknowledged) {
        store.data.events[i] = event.copyWith(acknowledged: true);
        changed++;
      }
    }
    return changed;
  });

  @override
  Stream<LiveUpdate> updates(String siteId) => store.channel(siteId).stream;

  @override
  MediaSource snapshot(CameraEvent event) => store.eventScene(event);

  @override
  MediaSource thumbnail(CameraEvent event) => store.eventScene(event);

  @override
  MediaSource? faceCrop(CameraEvent event) {
    final sampleId = event.face?.sampleId;
    if (sampleId == null) return null;
    for (final person in store.data.people) {
      for (final sample in person.samples) {
        if (sample.id == sampleId) return sample.crop;
      }
    }
    for (final cluster in store.data.clusters) {
      for (final sample in cluster.samples) {
        if (sample.id == sampleId) return sample.crop;
      }
    }
    return null;
  }

  @override
  ClipSource? clip(CameraEvent event) =>
      event.hasClip ? SyntheticClip(store.eventScene(event), event.boxes, const Duration(seconds: 12)) : null;

  @override
  Future<String> downloadClip(CameraEvent event) =>
      store.delay(() => throw const ApiFailure(FailureKind.notFound, 'demo'));
}

class FakeAnalyticsRepository implements AnalyticsRepository {
  FakeAnalyticsRepository(this.store);

  final FakeStore store;

  @override
  Future<List<AnalyticsView>> views(String siteId) => store.delay(
    () => store.data.views.where((v) => store.data.camera(v.cameraId).camera.siteId == siteId).toList(),
  );

  @override
  Future<AnalyticsView> view(String viewId) => store.delay(() => store.data.views.firstWhere((v) => v.id == viewId));

  @override
  Future<AnalyticsView> updateView(AnalyticsView view) => store.delay(() {
    final index = store.data.views.indexWhere((v) => v.id == view.id);
    store.data.views[index] = view;
    return view;
  });

  @override
  Future<AnalyticsView> saveRules(String viewId, {required List<Zone> zones, required List<Line> lines}) =>
      store.delay(() {
        final index = store.data.views.indexWhere((v) => v.id == viewId);
        var next = 0;
        final view = store.data.views[index].copyWith(
          zones: [for (final zone in zones) zone.id == null ? zone.copyWith(id: 'zone-new-${next++}') : zone],
          lines: [for (final line in lines) line.id == null ? line.copyWith(id: 'line-new-${next++}') : line],
        );
        store.data.views[index] = view;
        return view;
      });

  @override
  Future<MediaSource> viewSnapshot(String viewId) => store.delay(() {
    final view = store.data.views.firstWhere((v) => v.id == viewId);
    return store.sceneFor(view.cameraId, view.lens);
  });

  @override
  Stream<List<LiveObject>> liveObjects(String viewId) async* {
    final view = store.data.views.firstWhere((v) => v.id == viewId);
    var t = 0.0;
    while (true) {
      final x = 0.2 + 0.5 * (0.5 + 0.5 * sin(t));
      yield [
        LiveObject(track: 41, label: 'person', box: Rect.fromLTWH(x, 0.4, 0.1, 0.38), name: view.faces ? 'Alex' : null),
        if (view.profile == Profile.vehicle)
          const LiveObject(track: 12, label: 'car', box: Rect.fromLTWH(0.56, 0.52, 0.3, 0.24)),
      ];
      if (!store.live) return;
      await Future<void>.delayed(const Duration(milliseconds: 400));
      t += 0.12;
    }
  }

  @override
  Future<CountsReport> counts(String siteId, {required DateTime start, required DateTime end, required Bucket bucket}) =>
      store.delay(() => store.data.counts(siteId, start, end, bucket));

  @override
  Future<List<Area>> areas(String siteId) => store.delay(() => List.of(store.data.areas[siteId] ?? const []));

  @override
  Future<Area> resetArea(String areaId, int occupancy) => store.delay(() {
    for (final list in store.data.areas.values) {
      final index = list.indexWhere((a) => a.id == areaId);
      if (index >= 0) {
        final area = list[index].copyWith(occupancy: occupancy, entered: 0, exited: 0, since: store.clock());
        list[index] = area;
        return area;
      }
    }
    throw const ApiFailure(FailureKind.notFound);
  });

  @override
  Future<Journey?> journey(String eventId) => store.delay(() {
    final event = store.data.events.firstWhere((e) => e.id == eventId);
    if (!event.personLike) return null;
    final at = event.startedAt;
    return Journey(
      id: 'journey-$eventId',
      description: 'Front gate, then Driveway, then ${event.cameraName}',
      startedAt: at.subtract(const Duration(minutes: 2, seconds: 40)),
      endedAt: at.add(const Duration(seconds: 20)),
      steps: [
        JourneyStep(
          cameraName: 'Front gate',
          viewName: 'Front gate',
          startedAt: at.subtract(const Duration(minutes: 2, seconds: 40)),
          endedAt: at.subtract(const Duration(minutes: 2, seconds: 5)),
          similarity: 0.71,
        ),
        JourneyStep(
          cameraName: 'Driveway',
          viewName: 'Driveway',
          startedAt: at.subtract(const Duration(minutes: 1, seconds: 50)),
          endedAt: at.subtract(const Duration(minutes: 1, seconds: 12)),
          similarity: 0.58,
        ),
        JourneyStep(
          cameraName: event.cameraName,
          viewName: event.viewName,
          startedAt: at,
          endedAt: at.add(const Duration(seconds: 20)),
          eventId: event.id,
        ),
      ],
    );
  });

  @override
  Future<List<AppearanceMatch>> findPerson(String eventId) => store.delay(() {
    final event = store.data.events.firstWhere((e) => e.id == eventId);
    final others = store.data.events
        .where((e) => e.id != eventId && e.label == 'person' && e.siteId == event.siteId)
        .take(5)
        .toList();
    var score = 0.74;
    return [
      for (final other in others)
        AppearanceMatch(
          id: 'match-${other.id}',
          cameraName: other.cameraName,
          viewName: other.viewName,
          startedAt: other.startedAt,
          endedAt: other.endedAt ?? other.startedAt,
          similarity: score -= 0.07,
          eventId: other.id,
          thumbnail: store.eventScene(other),
        ),
    ];
  });
}

class FakePeopleRepository implements PeopleRepository {
  FakePeopleRepository(this.store);

  final FakeStore store;

  @override
  Future<List<Person>> people(String organisationId) => store.delay(() => List.of(store.data.people));

  @override
  Future<Person> person(String personId) => store.delay(() => store.data.people.firstWhere((p) => p.id == personId));

  @override
  Future<Person> createPerson(String organisationId, {required String name, String? notes}) => store.delay(() {
    const colors = [0xFF0090FF, 0xFF45C25F, 0xFFF0A92E, 0xFFE5484D, 0xFFA07CFE];
    final person = Person(
      id: 'person-${store.sequence++}',
      name: name,
      notes: notes,
      color: colors[store.data.people.length % colors.length],
    );
    store.data.people.add(person);
    return person;
  });

  @override
  Future<Person> updatePerson(Person person) => store.delay(() {
    final index = store.data.people.indexWhere((p) => p.id == person.id);
    store.data.people[index] = person;
    return person;
  });

  @override
  Future<void> deletePerson(String personId) => store.delay(() => store.data.people.removeWhere((p) => p.id == personId));

  @override
  Future<PhotoResult> addPhotos(String personId, List<Uint8List> photos) => store.delay(() {
    final index = store.data.people.indexWhere((p) => p.id == personId);
    final person = store.data.people[index];
    final added = [
      for (var i = 0; i < photos.length; i++)
        FaceSample(
          id: 'sample-${store.sequence++}',
          source: SampleSource.upload,
          quality: 0.8,
          seenAt: store.clock(),
          crop: SyntheticMedia(SceneKind.face, seed: person.color),
        ),
    ];
    store.data.people[index] = person.copyWith(samples: [...person.samples, ...added]);
    return PhotoResult(added: added.length);
  });

  @override
  Future<void> deleteSample(String personId, String sampleId) => store.delay(() {
    final index = store.data.people.indexWhere((p) => p.id == personId);
    final person = store.data.people[index];
    store.data.people[index] = person.copyWith(samples: person.samples.where((s) => s.id != sampleId).toList());
  });

  @override
  Future<void> mergePerson(String personId, String intoId) => store.delay(() {
    final from = store.data.people.firstWhere((p) => p.id == personId);
    final index = store.data.people.indexWhere((p) => p.id == intoId);
    final into = store.data.people[index];
    store.data.people[index] = into.copyWith(
      samples: [...into.samples, ...from.samples],
      sightings: [...into.sightings, ...from.sightings],
    );
    store.data.people.removeWhere((p) => p.id == personId);
  });

  @override
  Future<List<FaceCluster>> clusters(String organisationId) => store.delay(() => List.of(store.data.clusters));

  @override
  Future<FaceCluster> cluster(String clusterId) =>
      store.delay(() => store.data.clusters.firstWhere((c) => c.id == clusterId));

  @override
  Future<Person> nameCluster(String clusterId, {String? personId, String? name}) async {
    final cluster = store.data.clusters.firstWhere((c) => c.id == clusterId);
    Person target;
    if (personId != null) {
      target = store.data.people.firstWhere((p) => p.id == personId);
    } else {
      target = await createPerson(Fixtures.demoOrg, name: name ?? cluster.label);
    }
    return store.delay(() {
      final index = store.data.people.indexWhere((p) => p.id == target.id);
      final merged = target.copyWith(
        samples: [...target.samples, ...cluster.samples],
        sightings: [...target.sightings, ...cluster.sightings],
        lastSeenAt: cluster.lastSeenAt,
      );
      store.data.people[index] = merged;
      store.data.clusters.removeWhere((c) => c.id == clusterId);
      return merged;
    });
  }

  @override
  Future<void> deleteCluster(String clusterId) =>
      store.delay(() => store.data.clusters.removeWhere((c) => c.id == clusterId));
}

class FakeSearchRepository implements SearchRepository {
  FakeSearchRepository(this.store, this.events);

  final FakeStore store;
  final FakeEventRepository events;

  @override
  Future<EventPage> search(String siteId, EventFilter filter, {int page = 1, int pageSize = 30}) =>
      events.events(siteId, filter, page: page, pageSize: pageSize);

  @override
  Future<SearchFacets> facets(String siteId) => store.delay(() {
    final siteViews = store.data.views.where((v) => store.data.camera(v.cameraId).camera.siteId == siteId);
    return SearchFacets(
      views: [for (final view in siteViews) FacetItem(id: view.id, name: view.name, detail: view.cameraName)],
      zones: [
        for (final view in siteViews)
          for (final zone in view.zones) FacetItem(id: zone.name, name: zone.name, detail: view.name),
      ],
      lines: [
        for (final view in siteViews)
          for (final line in view.lines) FacetItem(id: line.name, name: line.name, detail: view.name),
      ],
      people: [for (final person in store.data.people) FacetItem(id: person.id, name: person.name)],
      clusters: [for (final cluster in store.data.clusters) FacetItem(id: cluster.id, name: cluster.label)],
      labels: const ['person', 'car', 'truck', 'bicycle', 'dog', 'cat', 'backpack', 'handbag', 'suitcase'],
    );
  });

  @override
  Future<List<SimilarFace>> similarFaces(String organisationId, {String? sampleId, String? eventId, Uint8List? photo}) =>
      store.delay(() {
        final results = <SimilarFace>[];
        var score = 0.93;
        for (final person in store.data.people) {
          for (final sample in person.samples.take(2)) {
            results.add(
              SimilarFace(
                sampleId: sample.id,
                score: score,
                seenAt: sample.seenAt,
                personId: person.id,
                personName: person.name,
                cameraName: sample.cameraName,
                crop: sample.crop,
              ),
            );
            score -= 0.11;
          }
        }
        for (final cluster in store.data.clusters) {
          results.add(
            SimilarFace(
              sampleId: cluster.samples.first.id,
              score: max(0.2, score),
              seenAt: cluster.lastSeenAt,
              clusterId: cluster.id,
              clusterLabel: cluster.label,
              cameraName: 'Entrance',
              crop: cluster.samples.first.crop,
            ),
          );
          score -= 0.06;
        }
        results.sort((a, b) => b.score.compareTo(a.score));
        return results;
      });
}

class FakeHealthRepository implements HealthRepository {
  FakeHealthRepository(this.store);

  final FakeStore store;

  @override
  Future<HealthReport> health(String siteId) => store.delay(() => store.data.health(siteId));
}

class FakeNotificationRepository implements NotificationRepository {
  FakeNotificationRepository(this.store);

  final FakeStore store;

  @override
  Future<NotificationPrefs> prefs(String siteId) =>
      store.delay(() => store.data.prefs[siteId] ?? NotificationPrefs(siteId: siteId));

  @override
  Future<NotificationPrefs> savePrefs(NotificationPrefs prefs) => store.delay(() {
    store.data.prefs[prefs.siteId] = prefs;
    return prefs;
  });

  @override
  Future<void> registerPushTarget({required String provider, required String token}) => store.delay(() {});
}

class FakeBusinessRepository implements BusinessRepository {
  FakeBusinessRepository(this.store);

  final FakeStore store;

  @override
  Future<PlanReport> plan(String organisationId) => store.delay(() {
    final internal = organisationId == Fixtures.demoOrg || store.createdOrganisations.contains(organisationId);
    final sites = store.data.sites.where((s) => s.organisationId == organisationId).map((s) => s.id).toSet();
    final cameras = store.data.cameras.where((c) => sites.contains(c.camera.siteId)).length;
    final now = store.clock();
    final plan = internal
        ? const Plan(id: 'internal', name: 'Internal', internal: true, features: {...PlanFeature.values})
        : const Plan(
            id: 'free',
            name: 'Free',
            limits: PlanLimits(sites: 1, cameras: 4, members: 5, eventRetentionDays: 7, clipRetentionDays: 7),
            features: {PlanFeature.appearance, PlanFeature.journeys, PlanFeature.objects},
          );
    return PlanReport(
      plan: plan,
      usage: Usage(
        periodStart: DateTime(now.year, now.month),
        sites: sites.length,
        cameras: cameras,
        members: store.data.members[organisationId]?.length ?? 1,
        cameraHours: cameras * 24.0 * (now.day - 0.4),
        analyticsHours: cameras * 21.5 * (now.day - 0.4),
        events: store.data.events.where((e) => sites.contains(e.siteId)).length * 37,
        clipBytes: 6800000000,
        notifications: 212,
      ),
    );
  });

  @override
  Future<List<TelegramChat>> telegramChats(String organisationId) =>
      store.delay(() => List.of(store.data.telegram[organisationId] ?? const []));

  @override
  Future<TelegramLink> linkTelegram(String organisationId) => store.delay(() {
    final now = store.clock();
    final list = store.data.telegram[organisationId] ??= [];
    list.add(TelegramChat(id: 'chat-${store.sequence++}', title: 'Demo night shift', group: true, linkedAt: now, linkedBy: store.data.user.name));
    return TelegramLink(url: 'https://t.me/demo_bot?start=demo-link', expiresAt: now.add(const Duration(minutes: 15)));
  });

  @override
  Future<void> unlinkTelegram(String organisationId, String chatId) =>
      store.delay(() => store.data.telegram[organisationId]?.removeWhere((c) => c.id == chatId));

  @override
  Future<int> testTelegram(String organisationId) => store.delay(() => store.data.telegram[organisationId]?.length ?? 0);

  @override
  Future<AuditPage> audit(String organisationId, {AuditCategory? category, int page = 1, int pageSize = 40}) => store.delay(() {
    final all = (store.data.audit[organisationId] ?? const <AuditEntry>[])
        .where((e) => category == null || e.category == category)
        .toList();
    final start = (page - 1) * pageSize;
    return AuditPage(
      items: start >= all.length ? const [] : all.sublist(start, min(all.length, start + pageSize)),
      total: all.length,
      page: page,
    );
  });
}

Backend fakeBackend(FakeStore store) {
  final events = FakeEventRepository(store);
  final devices = FakeDeviceRepository(store);
  return Backend(
    auth: FakeAuthRepository(store),
    tenancy: FakeTenancyRepository(store),
    devices: devices,
    pairing: FakePairingRepository(store, devices),
    live: FakeLiveRepository(store),
    events: events,
    analytics: FakeAnalyticsRepository(store),
    people: FakePeopleRepository(store),
    search: FakeSearchRepository(store, events),
    health: FakeHealthRepository(store),
    notifications: FakeNotificationRepository(store),
    business: FakeBusinessRepository(store),
    demo: true,
  );
}
