import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/app/routes.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/widgets/failure_labels.dart';
import 'package:smart_surveillance/core/widgets/flow_scaffold.dart';
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/features/identity/presentation/session.dart';
import 'package:smart_surveillance/features/identity/presentation/token.dart';

/// A field for the code or the link from an email.
class TokenField extends StatelessWidget {
  /// Creates the field.
  const TokenField({super.key, required this.controller, this.onSubmitted});

  /// The field's text.
  final TextEditingController controller;

  /// Called when the keyboard's done key is pressed.
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.url,
      autocorrect: false,
      enableSuggestions: false,
      minLines: 1,
      maxLines: 3,
      style: dataStyle(context, size: 14),
      decoration: InputDecoration(labelText: l10n.fieldCode, helperText: l10n.fieldCodeHelp),
      validator: (value) => extractToken(value ?? '').length >= 6 ? null : l10n.validationCode,
      onFieldSubmitted: onSubmitted,
    );
  }
}

/// Confirms the email address of a new account.
class VerifyScreen extends ConsumerStatefulWidget {
  /// Creates the screen for [email].
  const VerifyScreen({super.key, required this.email});

  /// The address the code was sent to.
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
      await ref.read(sessionProvider.notifier).verify(extractToken(code.text));
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
        Form(
          key: form,
          child: TokenField(controller: code, onSubmitted: (_) => submit()),
        ),
        const SizedBox(height: Gaps.lg),
        Wrap(
          spacing: 8,
          children: [
            TextButton.icon(
              onPressed: cooldown > 0 ? null : resend,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(cooldown > 0 ? '${l10n.verifyResend} ($cooldown)' : l10n.verifyResend),
            ),
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

/// Confirms an email address from the link in the verification email.
class VerifyLinkScreen extends ConsumerStatefulWidget {
  /// Creates the screen for the link's [token].
  const VerifyLinkScreen({super.key, required this.token});

  /// The verification token in the link.
  final String token;

  @override
  ConsumerState<VerifyLinkScreen> createState() => _VerifyLinkScreenState();
}

class _VerifyLinkScreenState extends ConsumerState<VerifyLinkScreen> {
  Object? error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => verify());
  }

  Future<void> verify() async {
    setState(() => error = null);
    try {
      final signedIn = await ref.read(sessionProvider.notifier).verify(widget.token);
      if (!mounted) return;
      if (signedIn) {
        const HomeRoute().go(context);
      } else {
        SignInRoute(notice: context.l10n.verifyDone).go(context);
      }
    } catch (failure) {
      if (mounted) setState(() => error = failure);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: Center(
      child: error == null
          ? const CircularProgressIndicator(strokeWidth: 2)
          : EmptyState(
              icon: Icons.mark_email_unread_outlined,
              title: context.l10n.verifyTitle,
              body: context.l10n.failure(error!),
              action: OutlinedButton(onPressed: verify, child: Text(context.l10n.commonRetry)),
            ),
    ),
  );
}
