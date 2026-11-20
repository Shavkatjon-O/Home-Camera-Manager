
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

@Riverpod(keepAlive: true)
Backend backend(Ref ref) => throw UnimplementedError();
