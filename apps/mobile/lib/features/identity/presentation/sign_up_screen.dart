import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/app/routes.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/widgets/flow_scaffold.dart';
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/features/identity/presentation/session.dart';
import 'package:smart_surveillance/features/identity/presentation/validators.dart';
/// The screen where a new user creates an account.
class SignUpScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool busy = false;
  int strength = 0;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      await ref.read(sessionProvider.notifier).signUp(name.text.trim(), email.text.trim(), password.text);
    } catch (failure) {
      if (mounted) showFailure(context, failure);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final labels = [l10n.passwordWeak, l10n.passwordFair, l10n.passwordStrong];
    final colors = [p.error, p.warning, p.ok];
    return FlowScaffold(
      title: l10n.signUpTitle,
      subtitle: l10n.signUpSubtitle,
      bottom: BusyButton(label: l10n.signUpAction, busy: busy, onPressed: submit),
      children: [
        Form(
          key: form,
          child: AutofillGroup(
            child: Column(
              children: [
                TextFormField(
                  controller: name,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: l10n.fieldName),
                  validator: (value) => validateRequired(l10n, value),
                ),
                const SizedBox(height: Gaps.md),
                TextFormField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  decoration: InputDecoration(labelText: l10n.fieldEmail),
                  validator: (value) => validateEmail(l10n, value),
                ),
                const SizedBox(height: Gaps.md),
                PasswordField(
                  controller: password,
                  label: l10n.fieldPassword,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: (value) => validatePassword(l10n, value),
                  onChanged: (value) => setState(() => strength = passwordStrength(value)),
                  onSubmitted: (_) => submit(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Gaps.md),
        if (password.text.isNotEmpty)
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= strength ? colors[strength] : p.surface3,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (i < 2) const SizedBox(width: 6),
              ],
              const SizedBox(width: 12),
              Text(labels[strength], style: dataStyle(context, size: 12, color: colors[strength])),
            ],
          ),
        const SizedBox(height: Gaps.lg),
        Text(l10n.signUpTerms, style: context.text.bodySmall?.copyWith(color: p.text3)),
        const SizedBox(height: Gaps.md),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4), foregroundColor: p.text2),
            onPressed: () => const SignInRoute().pushReplacement(context),
            child: Text(l10n.signUpHaveAccount),
          ),
        ),
      ],
    );
  }
}
