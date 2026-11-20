import 'package:smart_surveillance/features/devices/domain/models.dart';
import 'package:smart_surveillance/features/devices/domain/pairing_models.dart';

/// Offers the ways to pair connectors and cameras and carries out the chosen one.
abstract interface class PairingRepository {
  /// Returns the pairing methods for the site [siteId], optionally for a scanned [label] or
  /// [discoveredId].
  Future<PairingCatalog> catalog(String siteId, {String? label, String? discoveredId});

  /// Claims the connector with the pairing [code] for the site [siteId], optionally named [name].
  Future<Connector> claimConnector({required String siteId, required String code, String? name});

  /// Identifies the camera that a scanned label [payload] belongs to in the site [siteId].
  Future<LabelIdentity> identifyLabel(String siteId, String payload);

  /// Probes [host] through [connectorId] and returns the camera found there.
  Future<DiscoveredCamera> identifyHost({
    String? connectorId,
    required String host,
    int? port,
    String? username,
    String? password,
  });

  /// Lists the channels of the recorder [nvr] reached through [connectorId].
  Future<List<NvrChannel>> nvrChannels({
    String? connectorId,
    required DiscoveredCamera nvr,
    String? username,
    String? password,
  });

  /// Adds the recorder [channels] of [nvr] to the site [siteId] as cameras.
  Future<List<Camera>> addChannels({
    required String siteId,
    String? connectorId,
    required DiscoveredCamera nvr,
    required List<NvrChannel> channels,
    String? username,
    String? password,
  });

  /// Sends the outcome of a pairing attempt [report] for diagnostics.
  Future<void> report(PairingReport report);
}
