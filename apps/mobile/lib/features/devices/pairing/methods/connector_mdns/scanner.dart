import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nsd/nsd.dart' as nsd;
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/features/devices/domain/pairing_models.dart';

/// The mDNS service type a connector advertises on its network.
const connectorServiceType = '_sss-connector._tcp';

/// Finds connectors on the network the phone is on.
abstract interface class ConnectorScanner {
  /// Emits the connectors found so far, growing as more answer.
  Stream<List<FoundConnector>> scan();
}

/// Decodes the TXT record [key] from [records].
String? txt(Map<String, List<int>?>? records, String key) {
  final value = records?[key];
  return value == null ? null : utf8.decode(value, allowMalformed: true);
}

/// Scans with the platform's network service discovery.
class NsdConnectorScanner implements ConnectorScanner {
  /// Creates the scanner.
  const NsdConnectorScanner();

  @override
  Stream<List<FoundConnector>> scan() {
    late StreamController<List<FoundConnector>> controller;
    nsd.Discovery? discovery;
    void emit() {
      final services = discovery?.services ?? const <nsd.Service>[];
      controller.add([
        for (final service in services)
          if (service.host != null && service.port != null)
            FoundConnector(
              name: txt(service.txt, 'name') ?? service.name ?? connectorServiceType,
              host: service.host!,
              port: service.port!,
              code: txt(service.txt, 'code'),
              version: txt(service.txt, 'version'),
            ),
      ]);
    }

    controller = StreamController<List<FoundConnector>>(
      onListen: () async {
        try {
          discovery = await nsd.startDiscovery(connectorServiceType);
          discovery!.addListener(emit);
          emit();
        } catch (error) {
          controller.addError(error);
        }
      },
      onCancel: () async {
        final current = discovery;
        if (current != null) {
          current.removeListener(emit);
          await nsd.stopDiscovery(current);
        }
      },
    );
    return controller.stream;
  }
}

/// Finds one connector after a short delay, for the demo build.
class DemoConnectorScanner implements ConnectorScanner {
  /// Creates the scanner.
  const DemoConnectorScanner();

  @override
  Stream<List<FoundConnector>> scan() async* {
    yield const [];
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    yield const [FoundConnector(name: 'Demo connector', host: '192.168.1.20', port: 8780, code: 'DEMO-2468', version: '0.1.0')];
  }
}

/// The scanner for the current backend.
final connectorScannerProvider = Provider<ConnectorScanner>(
  (ref) => ref.watch(backendProvider).demo ? const DemoConnectorScanner() : const NsdConnectorScanner(),
);
