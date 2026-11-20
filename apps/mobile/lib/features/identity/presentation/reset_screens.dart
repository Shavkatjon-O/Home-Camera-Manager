import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/app/routes.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/widgets/flow_scaffold.dart';
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/features/identity/presentation/token.dart';
import 'package:smart_surveillance/features/identity/presentation/validators.dart';
import 'package:smart_surveillance/features/identity/presentation/verify_screen.dart';

/// The screen where the user asks for a password reset email.
class ForgotScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
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

/// Sets a new password with the token from the reset email.
class ResetScreen extends ConsumerStatefulWidget {
  /// Creates the screen for [email], or for a link's [token].
  const ResetScreen({super.key, required this.email, this.token});

  /// The address the reset email went to.
  final String email;

  /// The token from an opened reset link.
  final String? token;

  @override
  ConsumerState<ResetScreen> createState() => _ResetScreenState();
}

class _ResetScreenState extends ConsumerState<ResetScreen> {
  final form = GlobalKey<FormState>();
  late final code = TextEditingController(text: widget.token ?? '');
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
          .resetPassword(token: extractToken(code.text), password: password.text);
      if (mounted) SignInRoute(notice: context.l10n.resetDone).go(context);
    } catch (failure) {
      if (mounted) showFailure(context, failure);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final linked = widget.token != null;
    return FlowScaffold(
      title: l10n.resetTitle,
      subtitle: linked ? l10n.resetLinkBody : l10n.resetBody(widget.email),
      bottom: BusyButton(label: l10n.resetAction, busy: busy, onPressed: submit),
      children: [
        Form(
          key: form,
          child: Column(
            children: [
              if (!linked) ...[TokenField(controller: code), const SizedBox(height: Gaps.md)],
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
