import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/flow_scaffold.dart';
import '../../widgets/states.dart';
import 'validators.dart';

class CodeField extends StatelessWidget {
  const CodeField({super.key, required this.controller, this.onCompleted, this.label});

  final TextEditingController controller;
  final ValueChanged<String>? onCompleted;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      autofillHints: const [AutofillHints.oneTimeCode],
      textAlign: TextAlign.center,
      maxLength: 6,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: dataStyle(context, size: 28, weight: FontWeight.w500).copyWith(letterSpacing: 10),
      decoration: InputDecoration(labelText: label ?? l10n.fieldCode, counterText: ''),
      validator: (value) => validateCode(l10n, value),
      onChanged: (value) {
        if (value.length == 6) onCompleted?.call(value);
      },
    );
  }
}

class VerifyScreen extends ConsumerStatefulWidget {
  const VerifyScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  final form = GlobalKey<FormState>();
  final code = TextEditingController();
  bool busy = false;
  int cooldown = 0;
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    code.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      await ref.read(sessionProvider.notifier).verify(widget.email, code.text.trim());
    } catch (failure) {
      if (mounted) showFailure(context, failure);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> resend() async {
    try {
      await ref.read(backendProvider).auth.resendVerification(widget.email);
      if (!mounted) return;
      showMessage(context, context.l10n.verifyResent);
      setState(() => cooldown = 30);
      timer?.cancel();
      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        setState(() => cooldown--);
        if (cooldown <= 0) t.cancel();
      });
    } catch (failure) {
      if (mounted) showFailure(context, failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    return FlowScaffold(
      title: l10n.verifyTitle,
      subtitle: l10n.verifyBody(widget.email),
      leading: IconButton(
        tooltip: l10n.verifyWrongEmail,
        icon: const Icon(Icons.close_rounded),
        onPressed: () => ref.read(sessionProvider.notifier).cancelVerification(),
      ),
      bottom: BusyButton(label: l10n.verifyAction, busy: busy, onPressed: submit),
      children: [
        Form(key: form, child: CodeField(controller: code, onCompleted: (_) => submit())),
        const SizedBox(height: Gaps.lg),
        Row(
          children: [
            TextButton.icon(
              onPressed: cooldown > 0 ? null : resend,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(cooldown > 0 ? '${l10n.verifyResend} ($cooldown)' : l10n.verifyResend),
            ),
            const Spacer(),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: p.text2),
              onPressed: () => ref.read(sessionProvider.notifier).cancelVerification(),
              child: Text(l10n.verifyWrongEmail),
            ),
          ],
        ),
      ],
    );
  }
}
