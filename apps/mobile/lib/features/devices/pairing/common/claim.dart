import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/features/devices/domain/models.dart';
import 'package:smart_surveillance/features/devices/pairing/pairing_method.dart';

/// Matches a connector code with or without its dash, such as ABCD-1234.
final codePattern = RegExp(r'^[A-Za-z0-9]{4}-?[A-Za-z0-9]{4}$');

/// Returns the connector code inside [scanned], which may be a code or a link.
String extractCode(String scanned) {
  final text = scanned.trim();
  final fromLink = Uri.tryParse(text)?.queryParameters['code'];
  if (fromLink != null && fromLink.isNotEmpty) return fromLink.toUpperCase();
  return text.toUpperCase();
}

/// Formats [code] as two groups of four characters.
String formatCode(String code) {
  final clean = code.replaceAll(RegExp('[^A-Za-z0-9]'), '').toUpperCase();
  return clean.length == 8 ? '${clean.substring(0, 4)}-${clean.substring(4)}' : clean;
}

/// Claims the connector behind [code] for the pairing's site.
Future<Connector> claim(WidgetRef ref, PairingContext pairing, PairingSession session, String code, {String? name}) async {
  session.step('claim');
  try {
    return await ref
        .read(backendProvider)
        .pairing
        .claimConnector(siteId: pairing.siteId, code: formatCode(extractCode(code)), name: name);
  } catch (failure) {
    await session.fail(failure);
    rethrow;
  }
}
