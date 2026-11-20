import 'dart:math';
import 'dart:ui';

import '../models/account.dart';
import '../models/analytics.dart';
import '../models/camera.dart';
import '../models/event.dart';
import '../models/insights.dart';
import '../models/media.dart';
import '../models/people.dart';

class CameraFixture {
  const CameraFixture(this.camera, this.scenes);

  final Camera camera;
  final List<SceneKind> scenes;
}

class Fixtures {
  Fixtures(this.now) {
    build();
  }

  final DateTime now;

  late User user;
  final organisations = <Organisation>[];
  final sites = <Site>[];
  final connectors = <Connector>[];
  final cameras = <CameraFixture>[];
  final views = <AnalyticsView>[];
  final events = <CameraEvent>[];
  final people = <Person>[];
  final clusters = <FaceCluster>[];
  final members = <String, List<Member>>{};
  final invitations = <String, List<Invitation>>{};
  final sessions = <DeviceSession>[];
  final areas = <String, List<Area>>{};
  final discovered = <String, List<DiscoveredCamera>>{};
  final presets = <String, List<PtzPreset>>{};
  final prefs = <String, NotificationPrefs>{};

  static const homeSite = 'site-home';
  static const storeSite = 'site-store';
  static const demoOrg = 'org-demo';

  void build() {
    user = const User(id: 'user-demo', name: 'Demo owner', email: 'owner@demo.example');
    organisations.addAll(const [
      Organisation(id: demoOrg, name: 'Demo organisation', role: Role.owner, facesEnabled: true),
      Organisation(id: 'org-corner', name: 'Corner bakery', role: Role.viewer, siteScope: ['site-bakery']),
    ]);
    sites.addAll(const [
      Site(id: homeSite, organisationId: demoOrg, name: 'Demo home', kind: SiteKind.home, timezone: 'Asia/Tashkent'),
      Site(
        id: storeSite,
        organisationId: demoOrg,
        name: 'Demo store',
        kind: SiteKind.store,
        timezone: 'Asia/Tashkent',
        armMode: ArmMode.home,
        retentionDays: 14,
      ),
      Site(
        id: 'site-bakery',
        organisationId: 'org-corner',
        name: 'Bakery front',
        kind: SiteKind.store,
        timezone: 'Asia/Tashkent',
        armMode: ArmMode.disarmed,
      ),
    ]);
    connectors.addAll([
      Connector(
        id: 'con-home',
        siteId: homeSite,
        name: 'Home hub',
        state: ConnectorState.online,
        version: '0.1.0',
        lastSeenAt: now.subtract(const Duration(seconds: 8)),
        cameraCount: 4,
      ),
      Connector(
        id: 'con-store',
        siteId: storeSite,
        name: 'Store box',
        state: ConnectorState.online,
        version: '0.1.0',
        lastSeenAt: now.subtract(const Duration(seconds: 3)),
        cameraCount: 4,
      ),
      Connector(
        id: 'con-bakery',
        siteId: 'site-bakery',
        name: 'Bakery box',
        state: ConnectorState.offline,
        version: '0.1.0',
        lastSeenAt: now.subtract(const Duration(hours: 3)),
        cameraCount: 1,
      ),
    ]);

    Camera cam(
      String id,
      String site,
      String name,
      CameraBrand brand, {
      int lenses = 1,
      bool ptz = false,
      bool? online = true,
      bool extras = false,
      int position = 0,
      String? model,
      double aspect = 16 / 9,
    }) => Camera(
      id: id,
      siteId: site,
      connectorId: site == homeSite ? 'con-home' : (site == storeSite ? 'con-store' : 'con-bakery'),
      name: name,
      brand: brand,
      lenses: lenses,
      ptz: ptz,
      online: online,
      hasExtras: extras,
      position: position,
      model: model,
      aspect: aspect,
      checkedAt: now.subtract(const Duration(seconds: 12)),
      error: online == false ? 'No answer on port 554' : null,
    );

    cameras.addAll([
      CameraFixture(cam('cam-gate', homeSite, 'Front gate', CameraBrand.ezviz, model: 'CS-H3'), [SceneKind.street]),
      CameraFixture(cam('cam-drive', homeSite, 'Driveway', CameraBrand.onvif, position: 1), [SceneKind.driveway]),
      CameraFixture(
        cam(
          'cam-porch',
          homeSite,
          'Porch',
          CameraBrand.v380,
          lenses: 2,
          ptz: true,
          extras: true,
          position: 2,
          aspect: 16 / 18,
        ),
        [SceneKind.yard, SceneKind.entrance],
      ),
      CameraFixture(cam('cam-back', homeSite, 'Backyard', CameraBrand.onvif, online: false, position: 3), [
        SceneKind.yard,
      ]),
      CameraFixture(cam('cam-entrance', storeSite, 'Entrance', CameraBrand.onvif), [SceneKind.entrance]),
      CameraFixture(cam('cam-checkout', storeSite, 'Checkout', CameraBrand.onvif, position: 1), [SceneKind.checkout]),
      CameraFixture(cam('cam-aisle', storeSite, 'Aisle 3', CameraBrand.rtsp, position: 2), [SceneKind.aisle]),
      CameraFixture(cam('cam-stock', storeSite, 'Stock room', CameraBrand.onvif, ptz: true, position: 3), [
        SceneKind.stockroom,
      ]),
      CameraFixture(cam('cam-bakery', 'site-bakery', 'Counter', CameraBrand.onvif, online: null), [
        SceneKind.checkout,
      ]),
    ]);

    const evening = AlertPolicy(
      mode: AlertMode.schedule,
      schedule: [TimeWindow(start: '22:00', end: '07:00')],
      labels: ['person'],
    );
    views.addAll([
      AnalyticsView(
        id: 'view-gate',
        cameraId: 'cam-gate',
        cameraName: 'Front gate',
        lens: 0,
        lenses: 1,
        name: 'Front gate',
        appearance: true,
        fpsMeasured: 8.0,
        zones: [
          const Zone(
            id: 'zone-gate',
            name: 'Gate',
            polygon: [Offset(0.18, 0.52), Offset(0.62, 0.48), Offset(0.78, 0.96), Offset(0.08, 0.98)],
            labels: ['person', 'car', 'dog'],
            loiterSeconds: 120,
            alert: evening,
          ),
        ],
        lines: [
          const Line(
            id: 'line-gate',
            name: 'Gate line',
            a: Offset(0.12, 0.62),
            b: Offset(0.7, 0.58),
            direction: LineDirection.inward,
            labels: ['person', 'car'],
          ),
        ],
      ),
      AnalyticsView(
        id: 'view-drive',
        cameraId: 'cam-drive',
        cameraName: 'Driveway',
        lens: 0,
        lenses: 1,
        name: 'Driveway',
        profile: Profile.vehicle,
        plates: true,
        stream: StreamQuality.main,
        fpsMeasured: 8.0,
        zones: [
          const Zone(
            id: 'zone-drive',
            name: 'Parking',
            polygon: [Offset(0.1, 0.45), Offset(0.9, 0.42), Offset(0.98, 0.98), Offset(0.02, 0.98)],
            labels: ['person', 'car', 'truck'],
            leftSeconds: 900,
            takenSeconds: 3600,
            objectLabels: ['backpack', 'suitcase'],
            alert: evening,
          ),
        ],
      ),
      AnalyticsView(
        id: 'view-porch-1',
        cameraId: 'cam-porch',
        cameraName: 'Porch',
        lens: 0,
        lenses: 2,
        name: 'Porch yard',
        ptz: true,
        fpsMeasured: 9.6,
        zones: [
          const Zone(
            id: 'zone-yard',
            name: 'Yard',
            polygon: [Offset(0.05, 0.35), Offset(0.95, 0.35), Offset(0.95, 0.95), Offset(0.05, 0.95)],
            labels: ['person', 'dog', 'cat'],
            animals: AnimalMode.include,
          ),
        ],
      ),
      AnalyticsView(
        id: 'view-porch-2',
        cameraId: 'cam-porch',
        cameraName: 'Porch',
        lens: 1,
        lenses: 2,
        name: 'Porch door',
        profile: Profile.identity,
        faces: true,
        moving: true,
        falls: true,
        ptz: true,
        stream: StreamQuality.main,
        fpsMeasured: 9.8,
        zones: [
          const Zone(
            id: 'zone-door',
            name: 'Doorstep',
            polygon: [Offset(0.3, 0.3), Offset(0.7, 0.3), Offset(0.78, 0.98), Offset(0.22, 0.98)],
            labels: ['person'],
            leftSeconds: 300,
            takenSeconds: 1800,
            objectLabels: ['backpack', 'handbag', 'suitcase'],
          ),
        ],
        lines: [
          const Line(
            id: 'line-door',
            name: 'Door',
            a: Offset(0.28, 0.7),
            b: Offset(0.74, 0.7),
            direction: LineDirection.both,
          ),
        ],
      ),
      const AnalyticsView(
        id: 'view-back',
        cameraId: 'cam-back',
        cameraName: 'Backyard',
        lens: 0,
        lenses: 1,
        name: 'Backyard',
        profile: Profile.tamper,
        appearance: false,
      ),
      AnalyticsView(
        id: 'view-entrance',
        cameraId: 'cam-entrance',
        cameraName: 'Entrance',
        lens: 0,
        lenses: 1,
        name: 'Entrance',
        profile: Profile.identity,
        faces: true,
        stream: StreamQuality.main,
        fpsMeasured: 8.0,
        lines: [
          const Line(
            id: 'line-store-door',
            name: 'Store door',
            a: Offset(0.18, 0.66),
            b: Offset(0.84, 0.66),
            direction: LineDirection.inward,
          ),
        ],
      ),
      AnalyticsView(
        id: 'view-checkout',
        cameraId: 'cam-checkout',
        cameraName: 'Checkout',
        lens: 0,
        lenses: 1,
        name: 'Checkout',
        fpsMeasured: 8.0,
        zones: [
          const Zone(
            id: 'zone-counter',
            name: 'Counter queue',
            polygon: [Offset(0.08, 0.4), Offset(0.6, 0.4), Offset(0.66, 0.96), Offset(0.04, 0.96)],
            crowdCount: 4,
            alert: AlertPolicy(mode: AlertMode.off),
          ),
          const Zone(
            id: 'zone-bags',
            name: 'Bag shelf',
            polygon: [Offset(0.66, 0.3), Offset(0.94, 0.3), Offset(0.94, 0.6), Offset(0.66, 0.6)],
            labels: ['backpack', 'handbag', 'suitcase'],
            leftSeconds: 600,
            objectLabels: ['backpack', 'handbag', 'suitcase'],
          ),
        ],
      ),
      AnalyticsView(
        id: 'view-aisle',
        cameraId: 'cam-aisle',
        cameraName: 'Aisle 3',
        lens: 0,
        lenses: 1,
        name: 'Aisle 3',
        falls: true,
        fpsMeasured: 8.0,
        zones: [
          const Zone(
            id: 'zone-shelves',
            name: 'Shelves',
            polygon: [Offset(0.05, 0.2), Offset(0.4, 0.25), Offset(0.42, 0.9), Offset(0.03, 0.95)],
            loiterSeconds: 300,
            takenSeconds: 900,
            objectLabels: ['handbag', 'suitcase'],
            alert: AlertPolicy(mode: AlertMode.off),
          ),
        ],
      ),
      AnalyticsView(
        id: 'view-stock',
        cameraId: 'cam-stock',
        cameraName: 'Stock room',
        lens: 0,
        lenses: 1,
        name: 'Stock room',
        ptz: true,
        fpsMeasured: 8.0,
        zones: [
          const Zone(
            id: 'zone-stock',
            name: 'Stock',
            polygon: [],
            wholeView: true,
            alert: evening,
          ),
        ],
      ),
    ]);

    presets['cam-porch'] = const [
      PtzPreset(token: '1', name: 'Door'),
      PtzPreset(token: '2', name: 'Yard'),
      PtzPreset(token: '3', name: 'Street'),
    ];
    presets['cam-stock'] = const [PtzPreset(token: '1', name: 'Shelves'), PtzPreset(token: '2', name: 'Back door')];

    buildPeople();
    buildEvents();
    buildTenancy();

    areas[storeSite] = [
      Area(
        id: 'area-floor',
        name: 'Store floor',
        occupancy: 12,
        entered: 214,
        exited: 202,
        since: DateTime(now.year, now.month, now.day, 4),
        resetAt: '04:00',
        lineNames: const ['Store door'],
        capacity: 30,
      ),
    ];
    areas[homeSite] = [
      Area(
        id: 'area-house',
        name: 'House',
        occupancy: 3,
        entered: 9,
        exited: 6,
        since: DateTime(now.year, now.month, now.day, 4),
        resetAt: '04:00',
        lineNames: const ['Gate line', 'Door'],
      ),
    ];

    discovered['con-home'] = const [
      DiscoveredCamera(
        id: 'disc-1',
        host: '192.168.1.104',
        ports: [80, 554],
        brand: CameraBrand.ezviz,
        manufacturer: 'EZVIZ',
        model: 'CS-H3',
        onvifPort: 80,
        cameraId: 'cam-gate',
      ),
      DiscoveredCamera(
        id: 'disc-2',
        host: '192.168.1.120',
        ports: [80, 554, 8000],
        brand: CameraBrand.onvif,
        manufacturer: 'Generic',
        model: 'IPC-B140',
        onvifPort: 8000,
      ),
      DiscoveredCamera(
        id: 'disc-3',
        host: '192.168.1.131',
        ports: [8800, 8899],
        brand: CameraBrand.v380,
        manufacturer: 'V380',
        model: 'Dual lens PTZ',
        onvifPort: 8899,
        ptz: true,
      ),
    ];
    discovered['con-store'] = const [
      DiscoveredCamera(
        id: 'disc-4',
        host: '192.168.1.150',
        ports: [80, 554],
        brand: CameraBrand.onvif,
        manufacturer: 'Generic',
        model: 'Dome 4MP',
        onvifPort: 80,
      ),
    ];

    for (final site in sites) {
      prefs[site.id] = NotificationPrefs(siteId: site.id, quietFrom: '23:00', quietUntil: '06:30');
    }
  }

  SyntheticMedia face(int seed) => SyntheticMedia(SceneKind.face, seed: seed);

  void buildPeople() {
    FaceSample sample(String id, int seed, int minutes, {SampleSource source = SampleSource.event}) => FaceSample(
      id: id,
      source: source,
      quality: 0.6 + (seed % 4) / 10,
      seenAt: now.subtract(Duration(minutes: minutes)),
      cameraName: source == SampleSource.event ? 'Porch' : null,
      viewName: source == SampleSource.event ? 'Porch door' : null,
      crop: face(seed),
    );
    Sighting sighting(String sampleId, int seed, int minutes, String camera) => Sighting(
      sampleId: sampleId,
      seenAt: now.subtract(Duration(minutes: minutes)),
      cameraName: camera,
      confidence: 0.62 + (seed % 3) / 10,
      crop: face(seed),
    );
    people.addAll([
      Person(
        id: 'person-alex',
        name: 'Alex',
        notes: 'Family',
        color: 0xFF0090FF,
        samples: [
          sample('s-a1', 1, 600, source: SampleSource.upload),
          sample('s-a2', 1, 300, source: SampleSource.upload),
          sample('s-a3', 1, 42),
        ],
        lastSeenAt: now.subtract(const Duration(minutes: 42)),
        sightings: [sighting('s-a3', 1, 42, 'Porch'), sighting('s-a4', 1, 190, 'Front gate')],
      ),
      Person(
        id: 'person-sam',
        name: 'Sam',
        notes: 'Courier on weekdays',
        color: 0xFF45C25F,
        samples: [sample('s-s1', 2, 900, source: SampleSource.upload), sample('s-s2', 2, 130)],
        lastSeenAt: now.subtract(const Duration(minutes: 130)),
        sightings: [sighting('s-s2', 2, 130, 'Porch')],
      ),
      Person(
        id: 'person-mira',
        name: 'Mira',
        color: 0xFFF0A92E,
        samples: [sample('s-m1', 5, 2000, source: SampleSource.upload)],
        lastSeenAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
    ]);
    clusters.addAll([
      FaceCluster(
        id: 'cluster-3',
        number: 3,
        label: 'Unknown 3',
        seenCount: 5,
        firstSeenAt: now.subtract(const Duration(days: 2)),
        lastSeenAt: now.subtract(const Duration(minutes: 18)),
        samples: [sample('s-u1', 3, 18), sample('s-u2', 3, 260), sample('s-u3', 3, 1400)],
        sightings: [sighting('s-u1', 3, 18, 'Entrance'), sighting('s-u2', 3, 260, 'Porch')],
      ),
      FaceCluster(
        id: 'cluster-4',
        number: 4,
        label: 'Unknown 4',
        seenCount: 2,
        firstSeenAt: now.subtract(const Duration(hours: 9)),
        lastSeenAt: now.subtract(const Duration(hours: 5)),
        samples: [sample('s-v1', 4, 300)],
        sightings: [sighting('s-v1', 4, 300, 'Entrance')],
      ),
    ]);
  }

  CameraFixture camera(String id) => cameras.firstWhere((c) => c.camera.id == id);

  AnalyticsView viewFor(String cameraId, [int lens = 0]) =>
      views.firstWhere((v) => v.cameraId == cameraId && v.lens == lens);

  void buildEvents() {
    final random = Random(7);
    var counter = 0;
    CameraEvent make({
      required String cameraId,
      int lens = 0,
      required EventKind kind,
      required int minutesAgo,
      String? label = 'person',
      bool alert = false,
      bool acknowledged = false,
      String? zone,
      String? line,
      String? direction,
      int objects = 1,
      FaceInfo? face,
      List<PlateCandidate> plates = const [],
      String? plateStatus,
      bool clip = true,
      EventSource source = EventSource.analytics,
      double seconds = 14,
    }) {
      counter++;
      final fixture = camera(cameraId);
      final view = viewFor(cameraId, lens);
      final started = now.subtract(Duration(minutes: minutesAgo, seconds: random.nextInt(50)));
      final boxes = <EventBox>[];
      for (var i = 0; i < objects; i++) {
        final w = label == 'person' ? 0.09 + random.nextDouble() * 0.05 : 0.22 + random.nextDouble() * 0.08;
        final h = label == 'person' ? 0.32 + random.nextDouble() * 0.12 : 0.18 + random.nextDouble() * 0.06;
        final x = 0.12 + random.nextDouble() * (0.7 - w);
        final y = 0.38 + random.nextDouble() * (0.55 - h);
        boxes.add(EventBox(object: 100 + counter * 3 + i, label: label ?? 'object', box: Rect.fromLTWH(x, y, w, h)));
      }
      return CameraEvent(
        id: 'event-$counter',
        siteId: fixture.camera.siteId,
        cameraId: cameraId,
        cameraName: fixture.camera.name,
        viewId: source == EventSource.analytics ? view.id : null,
        viewName: source == EventSource.analytics ? view.name : null,
        kind: kind,
        source: source,
        label: label,
        alert: alert,
        acknowledged: acknowledged,
        startedAt: started,
        endedAt: started.add(Duration(milliseconds: (seconds * 1000).round())),
        hasClip: clip,
        zoneName: zone,
        lineName: line,
        direction: direction,
        boxes: source == EventSource.analytics ? boxes : const [],
        count: objects,
        profile: view.profile.name,
        face: face,
        plates: plates,
        plateStatus: plateStatus,
        aspect: fixture.camera.aspect * fixture.camera.lenses,
      );
    }

    final alex = const FaceInfo(
      status: FaceStatus.known,
      personId: 'person-alex',
      personName: 'Alex',
      personColor: 0xFF0090FF,
      confidence: 0.81,
      sampleId: 's-a3',
    );
    final unknown = const FaceInfo(
      status: FaceStatus.unknown,
      clusterId: 'cluster-3',
      clusterLabel: 'Unknown 3',
      confidence: 0.58,
      sampleId: 's-u1',
    );
    events.addAll([
      make(cameraId: 'cam-entrance', kind: EventKind.faceUnknown, minutesAgo: 18, face: unknown, alert: true),
      make(
        cameraId: 'cam-gate',
        kind: EventKind.lineCrossing,
        minutesAgo: 24,
        line: 'Gate line',
        direction: 'in',
        alert: true,
      ),
      make(cameraId: 'cam-checkout', kind: EventKind.crowd, minutesAgo: 31, zone: 'Counter queue', objects: 5),
      make(cameraId: 'cam-porch', lens: 1, kind: EventKind.faceKnown, minutesAgo: 42, face: alex),
      make(
        cameraId: 'cam-drive',
        kind: EventKind.vehicle,
        minutesAgo: 55,
        label: 'car',
        zone: 'Parking',
        plates: const [
          PlateCandidate(text: '00D001EM', display: '00 D 001 EM', format: 'private', score: 0.91, reads: 4),
          PlateCandidate(text: '00D007EM', display: '00 D 007 EM', format: 'private', score: 0.62, reads: 1),
        ],
      ),
      make(
        cameraId: 'cam-aisle',
        kind: EventKind.objectTaken,
        minutesAgo: 68,
        label: 'handbag',
        zone: 'Shelves',
        alert: true,
        acknowledged: true,
      ),
      make(cameraId: 'cam-porch', kind: EventKind.animal, minutesAgo: 80, label: 'cat', zone: 'Yard'),
      make(
        cameraId: 'cam-checkout',
        kind: EventKind.objectLeft,
        minutesAgo: 96,
        label: 'backpack',
        zone: 'Bag shelf',
        alert: true,
      ),
      make(
        cameraId: 'cam-back',
        kind: EventKind.tamper,
        minutesAgo: 110,
        label: 'covered',
        source: EventSource.analytics,
        alert: true,
        objects: 0,
        clip: false,
      ),
      make(cameraId: 'cam-gate', kind: EventKind.intrusion, minutesAgo: 140, zone: 'Gate', objects: 2),
      make(
        cameraId: 'cam-entrance',
        kind: EventKind.lineCrossing,
        minutesAgo: 150,
        line: 'Store door',
        direction: 'in',
        objects: 2,
      ),
      make(cameraId: 'cam-aisle', kind: EventKind.fall, minutesAgo: 175, alert: true, acknowledged: true),
      make(cameraId: 'cam-gate', kind: EventKind.loitering, minutesAgo: 230, zone: 'Gate', alert: true),
      make(
        cameraId: 'cam-drive',
        kind: EventKind.vehicle,
        minutesAgo: 300,
        label: 'truck',
        zone: 'Parking',
        plateStatus: 'too_small',
      ),
      make(cameraId: 'cam-stock', kind: EventKind.intrusion, minutesAgo: 610, zone: 'Stock', alert: true),
      make(
        cameraId: 'cam-gate',
        kind: EventKind.motion,
        minutesAgo: 700,
        label: null,
        source: EventSource.camera,
        clip: false,
        objects: 0,
      ),
      make(cameraId: 'cam-porch', lens: 1, kind: EventKind.faceUnknown, minutesAgo: 260, face: unknown),
      make(
        cameraId: 'cam-entrance',
        kind: EventKind.lineCrossing,
        minutesAgo: 1500,
        line: 'Store door',
        direction: 'out',
      ),
      make(
        cameraId: 'cam-gate',
        kind: EventKind.lineCrossing,
        minutesAgo: 1580,
        line: 'Gate line',
        direction: 'out',
        label: 'car',
      ),
      make(cameraId: 'cam-checkout', kind: EventKind.crowd, minutesAgo: 1700, zone: 'Counter queue', objects: 4),
      make(cameraId: 'cam-stock', kind: EventKind.intrusion, minutesAgo: 1900, zone: 'Stock', alert: true, acknowledged: true),
      make(cameraId: 'cam-porch', kind: EventKind.intrusion, minutesAgo: 2100, zone: 'Yard', acknowledged: true),
    ]);
    events.sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  void buildTenancy() {
    members[demoOrg] = [
      Member(
        userId: user.id,
        name: user.name,
        email: user.email,
        role: Role.owner,
        lastActiveAt: now,
        you: true,
      ),
      Member(
        userId: 'user-admin',
        name: 'Demo admin',
        email: 'admin@demo.example',
        role: Role.admin,
        lastActiveAt: now.subtract(const Duration(hours: 2)),
      ),
      Member(
        userId: 'user-operator',
        name: 'Demo operator',
        email: 'operator@demo.example',
        role: Role.operator,
        siteIds: const [storeSite],
        lastActiveAt: now.subtract(const Duration(days: 1)),
      ),
      const Member(
        userId: 'user-viewer',
        name: 'Demo viewer',
        email: 'viewer@demo.example',
        role: Role.viewer,
        siteIds: [homeSite],
      ),
    ];
    invitations[demoOrg] = [
      Invitation(
        id: 'inv-1',
        email: 'guard@demo.example',
        role: Role.operator,
        siteIds: const [storeSite],
        expiresAt: now.add(const Duration(days: 6)),
        invitedBy: user.name,
      ),
    ];
    sessions.addAll([
      DeviceSession(
        id: 'session-this',
        deviceName: 'This phone',
        platform: 'Android',
        createdAt: now.subtract(const Duration(days: 3)),
        lastUsedAt: now,
        current: true,
      ),
      DeviceSession(
        id: 'session-tablet',
        deviceName: 'Kitchen tablet',
        platform: 'Android',
        createdAt: now.subtract(const Duration(days: 20)),
        lastUsedAt: now.subtract(const Duration(hours: 6)),
      ),
      DeviceSession(
        id: 'session-web',
        deviceName: 'Web browser',
        platform: 'Web',
        createdAt: now.subtract(const Duration(days: 40)),
        lastUsedAt: now.subtract(const Duration(days: 2)),
      ),
    ]);
  }

  CountsReport counts(String siteId, DateTime start, DateTime end, Bucket bucket) {
    final siteViews = views.where((v) => camera(v.cameraId).camera.siteId == siteId);
    final lines = <CountLine>[];
    for (final view in siteViews) {
      for (final line in view.lines) {
        lines.add(CountLine(id: line.id!, name: line.name, viewName: view.name, cameraName: view.cameraName));
      }
    }
    final buckets = <CountBucket>[];
    final step = bucket == Bucket.hour ? const Duration(hours: 1) : const Duration(days: 1);
    for (final line in lines) {
      final random = Random(line.id.hashCode);
      var at = start;
      var index = 0;
      while (at.isBefore(end) && !at.isAfter(now)) {
        final hour = at.hour;
        final weight = bucket == Bucket.hour ? shape(hour, siteId == storeSite) : 1.0;
        final base = siteId == storeSite ? 26 : 4;
        final scale = bucket == Bucket.hour ? 1.0 : (siteId == storeSite ? 9.0 : 7.0);
        final inward = (base * weight * scale * (0.7 + random.nextDouble() * 0.6)).round();
        final outward = (inward * (0.8 + random.nextDouble() * 0.35)).round();
        buckets.add(CountBucket(lineId: line.id, at: at, label: 'person', inward: inward, outward: outward));
        at = at.add(step);
        index++;
        if (index > 400) break;
      }
    }
    return CountsReport(start: start, end: end, bucket: bucket, lines: lines, buckets: buckets);
  }

  double shape(int hour, bool store) {
    if (store) {
      if (hour < 8 || hour > 21) return 0.02;
      const curve = [0.3, 0.55, 0.7, 0.8, 1.0, 0.95, 0.75, 0.7, 0.85, 1.1, 1.2, 0.9, 0.5, 0.25];
      return curve[(hour - 8).clamp(0, curve.length - 1)];
    }
    const home = [0.1, 0.05, 0.0, 0.0, 0.05, 0.2, 0.9, 1.4, 1.0, 0.4, 0.3, 0.3];
    return hour < home.length ? home[hour] : (hour > 16 && hour < 21 ? 1.2 : 0.4);
  }

  HealthReport health(String siteId) {
    final targets = <HealthTarget>[];
    final outages = <Outage>[];
    final connector = connectors.firstWhere((c) => c.siteId == siteId);
    List<HealthBucket> buckets(int seed, {double floor = 0.98, int? gapAt}) {
      final random = Random(seed);
      return List.generate(24, (i) {
        final down = gapAt != null && i >= gapAt;
        return HealthBucket(
          start: now.subtract(Duration(hours: 24 - i)),
          availability: down ? 0.0 : floor + random.nextDouble() * (1 - floor),
          latencyMs: down ? null : 4 + random.nextDouble() * 9,
        );
      });
    }

    targets.add(
      HealthTarget(
        id: connector.id,
        name: connector.name,
        kind: 'connector',
        status: connector.state == ConnectorState.online ? HealthStatus.up : HealthStatus.down,
        uptimePercent: 100,
        latencyMs: 3.1,
        lastSampleAt: connector.lastSeenAt,
        buckets: buckets(1, floor: 0.999),
      ),
    );
    for (final fixture in cameras.where((c) => c.camera.siteId == siteId)) {
      final down = fixture.camera.online == false;
      targets.add(
        HealthTarget(
          id: fixture.camera.id,
          name: fixture.camera.name,
          kind: 'camera',
          status: down ? HealthStatus.down : HealthStatus.up,
          uptimePercent: down ? 91.6 : 99.2 + (fixture.camera.position % 3) * 0.3,
          latencyMs: down ? null : 6.0 + fixture.camera.position * 2.4,
          outageCount: down ? 2 : (fixture.camera.position == 1 ? 1 : 0),
          parentName: connector.name,
          lastSampleAt: now.subtract(const Duration(seconds: 6)),
          buckets: buckets(fixture.camera.id.hashCode, floor: 0.95, gapAt: down ? 22 : null),
        ),
      );
      if (down) {
        outages.add(
          Outage(
            id: 'outage-${fixture.camera.id}',
            targetName: fixture.camera.name,
            startedAt: now.subtract(const Duration(hours: 1, minutes: 52)),
            ongoing: true,
            causeName: 'Garden access point',
          ),
        );
        outages.add(
          Outage(
            id: 'outage-old-${fixture.camera.id}',
            targetName: fixture.camera.name,
            startedAt: now.subtract(const Duration(hours: 19)),
            endedAt: now.subtract(const Duration(hours: 18, minutes: 41)),
          ),
        );
      }
    }
    return HealthReport(targets: targets, outages: outages);
  }
}
