import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/routes.dart';
import '../../core/theme/theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/flow_scaffold.dart';
import '../../widgets/states.dart';
import 'validators.dart';
import 'verify_screen.dart';

class ForgotScreen extends ConsumerStatefulWidget {
  const ForgotScreen({super.key});

  @override
  ConsumerState<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends ConsumerState<ForgotScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController();
  bool busy = false;

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      await ref.read(backendProvider).auth.requestPasswordReset(email.text.trim());
      if (mounted) ResetRoute(email: email.text.trim()).pushReplacement(context);
    } catch (failure) {
      if (mounted) showFailure(context, failure);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FlowScaffold(
      title: l10n.forgotTitle,
      subtitle: l10n.forgotBody,
      bottom: BusyButton(label: l10n.forgotAction, busy: busy, onPressed: submit),
      children: [
        Form(
          key: form,
          child: TextFormField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            autocorrect: false,
            decoration: InputDecoration(labelText: l10n.fieldEmail),
            validator: (value) => validateEmail(l10n, value),
            onFieldSubmitted: (_) => submit(),
          ),
        ),
      ],
    );
  }
}

class ResetScreen extends ConsumerStatefulWidget {
  const ResetScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<ResetScreen> createState() => _ResetScreenState();
}

class _ResetScreenState extends ConsumerState<ResetScreen> {
  final form = GlobalKey<FormState>();
  final code = TextEditingController();
  final password = TextEditingController();
  bool busy = false;

  @override
  void dispose() {
    code.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      await ref
          .read(backendProvider)
          .auth
          .resetPassword(email: widget.email, code: code.text.trim(), password: password.text);
      if (mounted) SignInRoute(notice: context.l10n.resetDone).pushReplacement(context);
    } catch (failure) {
      if (mounted) showFailure(context, failure);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FlowScaffold(
      title: l10n.resetTitle,
      subtitle: l10n.resetBody(widget.email),
      bottom: BusyButton(label: l10n.resetAction, busy: busy, onPressed: submit),
      children: [
        Form(
          key: form,
          child: Column(
            children: [
              CodeField(controller: code),
              const SizedBox(height: Gaps.md),
              PasswordField(
                controller: password,
                label: l10n.fieldNewPassword,
                autofillHints: const [AutofillHints.newPassword],
                validator: (value) => validatePassword(l10n, value),
                onSubmitted: (_) => submit(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
