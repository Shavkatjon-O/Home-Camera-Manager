import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/widgets/flow_scaffold.dart';
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/features/devices/pairing/common/claim.dart';
import 'package:smart_surveillance/features/devices/pairing/pairing_method.dart';

/// Pairs a connector by the code it shows.
class ConnectorCodeScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const ConnectorCodeScreen({super.key, required this.pairing, required this.session, this.initialName});

  /// The pairing context.
  final PairingContext pairing;

  /// The attempt being reported.
  final PairingSession session;

  /// A connector name to prefill.
  final String? initialName;

  @override
  ConsumerState<ConnectorCodeScreen> createState() => _ConnectorCodeScreenState();
}

class _ConnectorCodeScreenState extends ConsumerState<ConnectorCodeScreen> {
  final form = GlobalKey<FormState>();
  late final code = TextEditingController(
    text: widget.pairing.code == null ? '' : formatCode(extractCode(widget.pairing.code!)),
  );
  late final name = TextEditingController(text: widget.initialName ?? '');
  bool busy = false;

  @override
  void dispose() {
    code.dispose();
    name.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      final connector = await claim(
        ref,
        widget.pairing,
        widget.session,
        code.text,
        name: name.text.trim().isEmpty ? null : name.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(ConnectorPaired(connector));
    } catch (failure) {
      if (mounted) showFailure(context, failure);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    widget.session.step('code');
    return FlowScaffold(
      title: l10n.methodConnectorCode,
      subtitle: l10n.onboardingConnectorStep3,
      bottom: BusyButton(label: l10n.onboardingPair, busy: busy, onPressed: submit),
      children: [
        Form(
          key: form,
          child: Column(
            children: [
              TextFormField(
                controller: code,
                autofocus: widget.pairing.code == null,
                textCapitalization: TextCapitalization.characters,
                textAlign: TextAlign.center,
                maxLength: 9,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9-]')), const UpperCaseText()],
                style: dataStyle(context, size: 26, weight: FontWeight.w500).copyWith(letterSpacing: 6),
                decoration: InputDecoration(labelText: l10n.fieldConnectorCode, counterText: '', hintText: 'ABCD-1234'),
                validator: (value) => codePattern.hasMatch((value ?? '').trim()) ? null : l10n.validationConnectorCode,
              ),
              const SizedBox(height: Gaps.md),
              TextFormField(
                controller: name,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: l10n.fieldConnectorName),
              ),
            ],
          ),
        ),
        if (busy) ...[
          const SizedBox(height: Gaps.lg),
          Text(l10n.pairingWaiting, style: context.text.bodySmall),
        ],
      ],
    );
  }
}

/// Turns typed letters into capitals.
class UpperCaseText extends TextInputFormatter {
  /// Creates the formatter.
  const UpperCaseText();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}
