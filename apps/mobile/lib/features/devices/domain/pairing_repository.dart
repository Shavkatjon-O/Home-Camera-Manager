
import 'package:smart_surveillance/features/devices/domain/models.dart';
import 'package:smart_surveillance/features/devices/domain/pairing_models.dart';
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
