import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/widgets/flow_scaffold.dart';
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/features/devices/pairing/common/camera_details.dart';
import 'package:smart_surveillance/features/devices/pairing/pairing_method.dart';
import 'package:smart_surveillance/features/identity/presentation/validators.dart';

/// Matches an IP address or a host name.
final hostPattern = RegExp(r'^[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?$');

/// Asks for a camera's address and lets the connector identify it.
class ManualHostScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const ManualHostScreen({super.key, required this.pairing, required this.session});

  /// The pairing context.
  final PairingContext pairing;

  /// The attempt being reported.
  final PairingSession session;

  @override
  ConsumerState<ManualHostScreen> createState() => _ManualHostScreenState();
}

class _ManualHostScreenState extends ConsumerState<ManualHostScreen> {
  final form = GlobalKey<FormState>();
  late final host = TextEditingController(text: widget.pairing.label?.host ?? '');
  late final port = TextEditingController(text: widget.pairing.label?.port?.toString() ?? '');
  bool busy = false;

  @override
  void dispose() {
    host.dispose();
    port.dispose();
    super.dispose();
  }

  Future<void> identify() async {
    final l10n = context.l10n;
    if (!form.currentState!.validate()) return;
    final navigator = Navigator.of(context);
    widget.session.step('identify');
    setState(() => busy = true);
    try {
      final camera = await ref
          .read(backendProvider)
          .pairing
          .identifyHost(
            connectorId: widget.pairing.connector?.id,
            host: host.text.trim(),
            port: int.tryParse(port.text.trim()),
          );
      final label = widget.pairing.label;
      final identified = label == null
          ? camera
          : camera.copyWith(
              brand: label.brand ?? camera.brand,
              manufacturer: label.manufacturer ?? camera.manufacturer,
              model: label.model ?? camera.model,
            );
      if (!mounted) return;
      final result = await navigator.push<PairingResult>(
        MaterialPageRoute(
          builder: (_) => CameraDetailsScreen(
            pairing: widget.pairing,
            session: widget.session,
            camera: identified,
          ),
        ),
      );
      if (result != null) navigator.pop(result);
    } catch (failure) {
      await widget.session.fail(failure);
      if (mounted) showMessage(context, l10n.manualNotFound);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    widget.session.step('address');
    return FlowScaffold(
      title: l10n.manualTitle,
      subtitle: l10n.manualBody,
      bottom: BusyButton(
        label: busy ? l10n.manualIdentifying : l10n.manualIdentify,
        busy: busy,
        onPressed: identify,
      ),
      children: [
        Form(
          key: form,
          child: Column(
            children: [
              TextFormField(
                controller: host,
                autofocus: host.text.isEmpty,
                keyboardType: TextInputType.url,
                autocorrect: false,
                style: dataStyle(context, size: 16),
                decoration: InputDecoration(labelText: l10n.manualHost, hintText: '192.168.1.64'),
                validator: (value) =>
                    hostPattern.hasMatch((value ?? '').trim()) ? null : l10n.validationRequired,
              ),
              const SizedBox(height: Gaps.md),
              TextFormField(
                controller: port,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5),
                ],
                style: dataStyle(context, size: 16),
                decoration: InputDecoration(labelText: l10n.manualPort, hintText: '80'),
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final number = int.tryParse(value);
                  return number != null && number > 0 && number < 65536
                      ? null
                      : validateRequired(l10n, '');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
