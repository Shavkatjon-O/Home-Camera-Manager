import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/providers.dart';
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/features/devices/domain/pairing_models.dart';
import 'package:smart_surveillance/features/devices/pairing/methods/connector_code/method.dart';
import 'package:smart_surveillance/features/devices/pairing/methods/connector_discovery/method.dart';
import 'package:smart_surveillance/features/devices/pairing/methods/connector_mdns/method.dart';
import 'package:smart_surveillance/features/devices/pairing/methods/connector_qr/method.dart';
import 'package:smart_surveillance/features/devices/pairing/methods/label_qr/method.dart';
import 'package:smart_surveillance/features/devices/pairing/methods/manual_host/method.dart';
import 'package:smart_surveillance/features/devices/pairing/methods/nvr_import/method.dart';
import 'package:smart_surveillance/features/devices/pairing/methods/rtsp_url/method.dart';
import 'package:smart_surveillance/features/devices/pairing/pairing_method.dart';

/// Every pairing method the app implements.
const pairingMethods = <PairingMethod>[
  ConnectorDiscoveryMethod(),
  LabelQrMethod(),
  ManualHostMethod(),
  NvrImportMethod(),
  RtspUrlMethod(),
  ConnectorQrMethod(),
  ConnectorMdnsMethod(),
  ConnectorCodeMethod(),
];

/// Returns the method with [id], or null when the app does not implement it.
PairingMethod? methodById(String id) => pairingMethods.where((m) => m.id == id).firstOrNull;

/// A method paired with the catalog entry that ranked it.
class RankedMethod {
  /// Creates a ranked method.
  const RankedMethod(this.method, this.entry);

  /// The method.
  final PairingMethod method;

  /// The server's catalog entry for it.
  final PairingCatalogEntry entry;
}

/// Orders the methods for [target] the way the server [catalog] ranks them.
///
/// A method appears only when the catalog lists it as available, the app
/// implements it and it works in [context], so no method is shown that
/// cannot finish.
List<RankedMethod> rankMethods(List<PairingCatalogEntry> catalog, PairingTarget target, PairingContext context) {
  final ranked = <RankedMethod>[];
  for (final entry in catalog) {
    final method = methodById(entry.id);
    if (method == null || method.target != target || !entry.available || !method.supported(context)) continue;
    ranked.add(RankedMethod(method, entry));
  }
  ranked.sort((a, b) => a.entry.rank.compareTo(b.entry.rank));
  return ranked;
}

/// Runs [method] from [pairing] and follows any hand over to another method.
///
/// Reports the attempt's telemetry and returns the final result, or null when
/// the user backed out.
Future<PairingResult?> runPairing(BuildContext context, WidgetRef ref, PairingMethod method, PairingContext pairing) async {
  final l10n = context.l10n;
  final session = PairingSession(
    method: method.id,
    siteId: pairing.siteId,
    repository: ref.read(backendProvider).pairing,
    clock: ref.read(clockProvider),
  );
  if (method.requirements.isNotEmpty && !await requestRequirements(method.requirements)) {
    session.step('permission');
    await session.finish(PairingOutcome.failure, errorCode: 'permission_denied');
    if (context.mounted) showMessage(context, l10n.pairingPermissionDenied);
    return null;
  }
  if (!context.mounted) return null;
  final result = await Navigator.of(
    context,
  ).push<PairingResult>(MaterialPageRoute(builder: (_) => method.flow(pairing, session)));
  if (!session.reported) {
    await session.finish(result == null ? PairingOutcome.cancelled : PairingOutcome.success);
  }
  if (result is ContinueWith && context.mounted) {
    final next = methodById(result.method);
    if (next == null) return null;
    return runPairing(context, ref, next, result.context);
  }
  return result;
}
