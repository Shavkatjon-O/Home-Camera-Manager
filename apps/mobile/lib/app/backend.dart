import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_surveillance/features/alerting/domain/notification_repository.dart';
import 'package:smart_surveillance/features/analytics/domain/analytics_repository.dart';
import 'package:smart_surveillance/features/billing/domain/business_repository.dart';
import 'package:smart_surveillance/features/devices/domain/device_repository.dart';
import 'package:smart_surveillance/features/devices/domain/pairing_repository.dart';
import 'package:smart_surveillance/features/events/domain/event_repository.dart';
import 'package:smart_surveillance/features/identity/domain/auth_repository.dart';
import 'package:smart_surveillance/features/investigation/domain/people_repository.dart';
import 'package:smart_surveillance/features/investigation/domain/search_repository.dart';
import 'package:smart_surveillance/features/media/domain/media_repository.dart';
import 'package:smart_surveillance/features/operations/domain/health_repository.dart';
import 'package:smart_surveillance/features/tenancy/domain/tenancy_repository.dart';

part 'backend.g.dart';

/// The bundle of repositories the app reads and writes through, either live or demo.
class Backend {
  /// Creates a backend from one repository per feature area.
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
    this.expirations,
  });

  /// The repository for signing in, signing up and the session.
  final AuthRepository auth;

  /// The repository for organisations, sites and invitations.
  final TenancyRepository tenancy;

  /// The repository for cameras and their views and settings.
  final DeviceRepository devices;

  /// The repository for pairing new devices to a site.
  final PairingRepository pairing;

  /// The repository that streams live updates for a site.
  final LiveRepository live;

  /// The repository for detected events and their clips.
  final EventRepository events;

  /// The repository for counts and trends derived from events.
  final AnalyticsRepository analytics;

  /// The repository for known people and their faces.
  final PeopleRepository people;

  /// The repository for searching events and footage.
  final SearchRepository search;

  /// The repository for device and server health.
  final HealthRepository health;

  /// The repository for alert delivery and notification settings.
  final NotificationRepository notifications;

  /// The repository for plans, billing and business details.
  final BusinessRepository business;

  /// Whether this backend serves built-in demo data instead of a real server.
  final bool demo;

  /// Returns the HTTP headers that media requests need, such as authorization.
  final Map<String, String> Function() mediaHeaders;

  /// Fires when the server ends the session and the user must sign in again.
  final Stream<void>? expirations;

  /// Returns the address of the connected server, or null when none is set.
  final String? Function()? server;

  /// Saves the address of the server to connect to, when the backend supports changing it.
  final void Function(String url)? setServer;

  static Map<String, String> _noHeaders() => const {};
}

/// The provider exposing the active [Backend]; it is overridden at start-up.
@Riverpod(keepAlive: true)
Backend backend(Ref ref) => throw UnimplementedError();
