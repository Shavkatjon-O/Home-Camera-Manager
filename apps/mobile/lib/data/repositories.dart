import 'dart:typed_data';

import 'models/account.dart';
import 'models/analytics.dart';
import 'models/business.dart';
import 'models/camera.dart';
import 'models/event.dart';
import 'models/insights.dart';
import 'models/media.dart';
import 'models/pairing.dart';
import 'models/people.dart';

class ApiFailure implements Exception {
  const ApiFailure(this.kind, [this.detail]);

  final FailureKind kind;
  final String? detail;

  @override
  String toString() => 'ApiFailure($kind, $detail)';
}

enum FailureKind {
  network,
  unauthorised,
  forbidden,
  notFound,
  conflict,
  invalid,
  unverified,
  expired,
  server,
  unknown,
}

class SignUpResult {
  const SignUpResult({required this.email, required this.needsVerification});

  final String email;
  final bool needsVerification;
}

abstract interface class AuthRepository {
  Future<User?> restore();

  Future<User> signIn({required String email, required String password});

  Future<SignUpResult> signUp({required String name, required String email, required String password});

  Future<void> resendVerification(String email);

  Future<User> verifyEmail({required String token});

  Future<void> requestPasswordReset(String email);

  Future<void> resetPassword({required String token, required String password});

  Future<void> signOut();

  Future<void> deleteAccount(String password);

  Future<List<DeviceSession>> sessions();

  Future<void> revokeSession(String id);

  Future<User> updateProfile({required String name});
}

abstract interface class TenancyRepository {
  Future<List<Organisation>> organisations();

  Future<Organisation> createOrganisation(String name);

  Future<List<Site>> sites(String organisationId);

  Future<Site> createSite({
    required String organisationId,
    required String name,
    required SiteKind kind,
    required String timezone,
  });

  Future<Site> updateSite(Site site);

  Future<Site> setArmMode(String siteId, ArmMode mode);

  Future<({String version, String? text})> facesConsent();

  Future<Organisation> setFaces(String organisationId, bool enabled, {String? consentVersion});

  Future<List<Member>> members(String organisationId);

  Future<List<Invitation>> invitations(String organisationId);

  Future<Invitation> invite({
    required String organisationId,
    required String email,
    required Role role,
    List<String>? siteIds,
  });

  Future<void> revokeInvitation(String organisationId, String invitationId);

  Future<Member> updateMember(String organisationId, String userId, {required Role role, List<String>? siteIds});

  Future<void> removeMember(String organisationId, String userId);

  Future<InvitationPreview> previewInvitation(String token);

  Future<Organisation> acceptInvitation(String token);
}

abstract interface class PairingRepository {
  Future<List<PairingCatalogEntry>> catalog(String siteId, {String? label, String? discoveredId});

  Future<Connector> claimConnector({required String siteId, required String code, String? name});

  Future<LabelIdentity> identifyLabel(String siteId, String payload);

  Future<DiscoveredCamera> identifyHost({
    required String connectorId,
    required String host,
    int? port,
    String? username,
    String? password,
  });

  Future<List<NvrChannel>> nvrChannels({
    required String connectorId,
    required DiscoveredCamera nvr,
    String? username,
    String? password,
  });

  Future<List<Camera>> addChannels({
    required String siteId,
    required String connectorId,
    required DiscoveredCamera nvr,
    required List<NvrChannel> channels,
    String? username,
    String? password,
  });

  Future<void> report(PairingReport report);
}

abstract interface class DeviceRepository {
  Future<List<Connector>> connectors(String siteId);

  Future<void> removeConnector(String connectorId);

  Future<List<DiscoveredCamera>> discovered(String connectorId, {bool rescan = false});

  Future<StreamTest> testCamera({
    required String connectorId,
    required DiscoveredCamera camera,
    String? username,
    String? password,
  });

  Future<Camera> addCamera({
    required String siteId,
    required String connectorId,
    required DiscoveredCamera camera,
    required String name,
    String? username,
    String? password,
    required int lenses,
  });

  Future<List<Camera>> cameras(String siteId);

  Future<Camera> updateCamera(Camera camera);

  Future<void> deleteCamera(String cameraId);

  Future<void> orderCameras(String siteId, List<String> cameraIds);

  Future<CameraControls> controls(String cameraId);

  Future<void> move(String cameraId, {required double pan, required double tilt, required double zoom});

  Future<void> stop(String cameraId);

  Future<void> gotoPreset(String cameraId, String token);

  Future<PtzPreset> savePreset(String cameraId, String name);

  Future<void> gotoHome(String cameraId);

  Future<void> setLight(String cameraId, bool on);

  Future<void> sirenFor(String cameraId, Duration duration);

  Future<CameraSettings> settings(String cameraId);

  Future<void> updateMotion(String cameraId, MotionSettings motion);

  Future<void> updateImage(String cameraId, ImageSettings image);

  Future<void> syncClock(String cameraId);

  Future<void> reboot(String cameraId);
}

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

abstract interface class EventRepository {
  Future<EventPage> events(String siteId, EventFilter filter, {int page = 1, int pageSize = 30});

  Future<EventCounts> counts(String siteId, EventFilter filter);

  Future<CameraEvent> event(String eventId);

  Future<CameraEvent> acknowledge(String eventId);

  Future<int> acknowledgeAll(String siteId);

  Stream<LiveUpdate> updates(String siteId);

  MediaSource snapshot(CameraEvent event);

  MediaSource thumbnail(CameraEvent event);

  MediaSource? faceCrop(CameraEvent event);

  ClipSource? clip(CameraEvent event);

  Future<String> downloadClip(CameraEvent event);
}

abstract interface class AnalyticsRepository {
  Future<List<AnalyticsView>> views(String siteId);

  Future<AnalyticsView> view(String viewId);

  Future<AnalyticsView> updateView(AnalyticsView view);

  Future<AnalyticsView> saveRules(String viewId, {required List<Zone> zones, required List<Line> lines});

  Future<MediaSource> viewSnapshot(String viewId);

  Stream<List<LiveObject>> liveObjects(String viewId);

  Future<CountsReport> counts(String siteId, {required DateTime start, required DateTime end, required Bucket bucket});

  Future<List<Area>> areas(String siteId);

  Future<Area> resetArea(String areaId, int occupancy);

  Future<Journey?> journey(String eventId);

  Future<List<AppearanceMatch>> findPerson(String eventId);
}

abstract interface class PeopleRepository {
  Future<List<Person>> people(String organisationId);

  Future<Person> person(String personId);

  Future<Person> createPerson(String organisationId, {required String name, String? notes});

  Future<Person> updatePerson(Person person);

  Future<void> deletePerson(String personId);

  Future<PhotoResult> addPhotos(String personId, List<Uint8List> photos);

  Future<void> deleteSample(String personId, String sampleId);

  Future<void> mergePerson(String personId, String intoId);

  Future<List<FaceCluster>> clusters(String organisationId);

  Future<FaceCluster> cluster(String clusterId);

  Future<Person> nameCluster(String clusterId, {String? personId, String? name});

  Future<void> deleteCluster(String clusterId);
}

abstract interface class SearchRepository {
  Future<EventPage> search(String siteId, EventFilter filter, {int page = 1, int pageSize = 30});

  Future<SearchFacets> facets(String siteId);

  Future<List<SimilarFace>> similarFaces(String organisationId, {String? sampleId, String? eventId, Uint8List? photo});
}

abstract interface class HealthRepository {
  Future<HealthReport> health(String siteId);
}

abstract interface class BusinessRepository {
  Future<PlanReport> plan(String organisationId);

  Future<List<TelegramChat>> telegramChats(String organisationId);

  Future<TelegramLink> linkTelegram(String organisationId);

  Future<void> unlinkTelegram(String organisationId, String chatId);

  Future<int> testTelegram(String organisationId);

  Future<AuditPage> audit(String organisationId, {AuditCategory? category, int page = 1, int pageSize = 40});
}

abstract interface class NotificationRepository {
  Future<NotificationPrefs> prefs(String siteId);

  Future<NotificationPrefs> savePrefs(NotificationPrefs prefs);

  Future<void> registerPushTarget({required String provider, required String token});
}

class Backend {
  const Backend({
    required this.auth,
    required this.tenancy,
    required this.devices,
    required this.pairing,
    required this.live,
    required this.events,
    required this.analytics,
    required this.people,
    required this.search,
    required this.health,
    required this.notifications,
    required this.business,
    required this.demo,
    this.mediaHeaders = _noHeaders,
    this.server,
    this.setServer,
  });

  final AuthRepository auth;
  final TenancyRepository tenancy;
  final DeviceRepository devices;
  final PairingRepository pairing;
  final LiveRepository live;
  final EventRepository events;
  final AnalyticsRepository analytics;
  final PeopleRepository people;
  final SearchRepository search;
  final HealthRepository health;
  final NotificationRepository notifications;
  final BusinessRepository business;
  final bool demo;
  final Map<String, String> Function() mediaHeaders;
  final String? Function()? server;
  final void Function(String url)? setServer;

  static Map<String, String> _noHeaders() => const {};
}
