import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/network/failure.dart';
import 'package:smart_surveillance/features/devices/domain/models.dart';
import 'package:smart_surveillance/features/devices/domain/pairing_models.dart';
import 'package:smart_surveillance/features/devices/domain/pairing_repository.dart';

/// A phone permission that a pairing method needs before it starts.
enum PairingPermission { camera, bluetooth, nearbyWifi, location }

/// What a pairing method knows when it starts: the site, its connectors and
/// anything an earlier method found out.
class PairingContext {
  /// Creates a pairing context.
  const PairingContext({
    required this.siteId,
    required this.connectors,
    this.label,
    this.discovered,
    this.code,
    this.first = false,
  });

  /// The site the camera or connector joins.
  final String siteId;

  /// The site's connectors.
  final List<Connector> connectors;

  /// What a scanned camera label identified, if a label was scanned.
  final LabelIdentity? label;

  /// A camera or recorder the connector found, if one was picked.
  final DiscoveredCamera? discovered;

  /// A connector code from a link or a scan, if one was given.
  final String? code;

  /// Whether this runs inside the first setup flow.
  final bool first;

  /// The first online connector of the site.
  Connector? get connector => connectors.where((c) => c.state == ConnectorState.online).firstOrNull;

  /// Whether the site has an online connector.
  bool get hasConnector => connector != null;

  /// Returns a copy with the given fields replaced.
  PairingContext copyWith({List<Connector>? connectors, LabelIdentity? label, DiscoveredCamera? discovered, String? code}) =>
      PairingContext(
        siteId: siteId,
        connectors: connectors ?? this.connectors,
        label: label ?? this.label,
        discovered: discovered ?? this.discovered,
        code: code ?? this.code,
        first: first,
      );
}

/// The outcome a pairing flow returns when it finishes.
sealed class PairingResult {
  /// Creates a result.
  const PairingResult();
}

/// A connector was paired with the site.
class ConnectorPaired extends PairingResult {
  /// Creates the result for [connector].
  const ConnectorPaired(this.connector);

  /// The paired connector.
  final Connector connector;
}

/// One or more cameras were added to the site.
class CamerasAdded extends PairingResult {
  /// Creates the result for [cameras].
  const CamerasAdded(this.cameras);

  /// The added cameras.
  final List<Camera> cameras;
}

/// The flow found out enough to hand over to another method.
class ContinueWith extends PairingResult {
  /// Creates a hand over to [method] with [context].
  const ContinueWith(this.method, this.context);

  /// The id of the method to continue with.
  final String method;

  /// The context the next method starts from.
  final PairingContext context;
}

/// Tracks one pairing attempt and reports its telemetry once.
class PairingSession {
  /// Starts a session for [method] on [siteId].
  PairingSession({required this.method, required this.siteId, required this.repository, DateTime Function()? clock})
    : clock = clock ?? DateTime.now,
      started = (clock ?? DateTime.now)();

  /// The id of the method being tried.
  final String method;

  /// The site being paired.
  final String siteId;

  /// Where the report goes.
  final PairingRepository repository;

  /// The clock used for the duration.
  final DateTime Function() clock;

  /// When the attempt started.
  final DateTime started;

  /// The last step the user reached.
  String current = 'start';

  /// Whether the outcome was already reported.
  bool reported = false;

  /// Records that the user reached [name].
  void step(String name) => current = name;

  /// Reports the attempt's [outcome] with an optional [errorCode].
  Future<void> finish(PairingOutcome outcome, {String? errorCode}) async {
    if (reported) return;
    reported = true;
    try {
      await repository.report(
        PairingReport(
          method: method,
          siteId: siteId,
          step: current,
          outcome: outcome,
          errorCode: errorCode,
          durationMs: clock().difference(started).inMilliseconds,
        ),
      );
    } catch (_) {
      // Telemetry never blocks pairing.
    }
  }

  /// Reports a failure caused by [error].
  Future<void> fail(Object error) =>
      finish(PairingOutcome.failure, errorCode: error is ApiFailure ? (error.detail ?? error.kind.name) : 'unknown');
}

/// One way of adding a camera or pairing a connector.
///
/// Each method lives in its own folder under `methods/` with its flow.
abstract class PairingMethod {
  /// Creates a method.
  const PairingMethod();

  /// The stable id the server catalog uses.
  String get id;

  /// Whether the method pairs a connector or adds cameras.
  PairingTarget get target;

  /// The icon shown in the method list.
  IconData get icon;

  /// The title shown in the method list.
  String title(AppLocalizations l10n);

  /// The one line explanation shown under the title.
  String subtitle(AppLocalizations l10n);

  /// The permissions the method needs before it starts.
  Set<PairingPermission> get requirements => const {};

  /// Whether the method works in [context] on this phone.
  bool supported(PairingContext context) => true;

  /// Builds the first screen of the flow.
  Widget flow(PairingContext context, PairingSession session);
}

/// Maps a [PairingPermission] to the phone permission behind it.
Permission permissionFor(PairingPermission permission) => switch (permission) {
  PairingPermission.camera => Permission.camera,
  PairingPermission.bluetooth => Permission.bluetoothScan,
  PairingPermission.nearbyWifi => Permission.nearbyWifiDevices,
  PairingPermission.location => Permission.locationWhenInUse,
};

/// Asks for every permission in [requirements] and tells whether all were given.
Future<bool> requestRequirements(Set<PairingPermission> requirements) async {
  for (final requirement in requirements) {
    final status = await permissionFor(requirement).request();
    if (!status.isGranted && !status.isLimited) return false;
  }
  return true;
}
