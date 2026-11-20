import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/app/routes.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/providers.dart';
import 'package:smart_surveillance/core/widgets/failure_labels.dart';
import 'package:smart_surveillance/core/widgets/flow_scaffold.dart';
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/features/identity/presentation/session.dart';
import 'package:smart_surveillance/features/identity/presentation/validators.dart';
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key, this.notice});

  final String? notice;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  bool busy = false;
  String? error;

  @override
  void initState() {
    super.initState();
    if (widget.notice != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showMessage(context, widget.notice!);
      });
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await ref.read(sessionProvider.notifier).signIn(email.text.trim(), password.text);
    } catch (failure) {
      if (mounted) setState(() => error = context.l10n.failure(failure));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    return FlowScaffold(
      title: l10n.signInTitle,
      subtitle: l10n.signInSubtitle,
      bottom: BusyButton(label: l10n.signInAction, busy: busy, onPressed: submit),
      children: [
        Form(
          key: form,
          child: AutofillGroup(
            child: Column(
              children: [
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
                  validator: (value) => validateRequired(l10n, value),
                  onSubmitted: (_) => submit(),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          child: error == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: Gaps.md),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded, size: 18, color: p.dangerText),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Semantics(
                          liveRegion: true,
                          child: Text(error!, style: context.text.bodyMedium?.copyWith(color: p.dangerText)),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: Gaps.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4)),
            onPressed: () => const ForgotRoute().push<void>(context),
            child: Text(l10n.signInForgot),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4), foregroundColor: p.text2),
            onPressed: () => const SignUpRoute().pushReplacement(context),
            child: Text(l10n.signInNoAccount),
          ),
        ),
        const SizedBox(height: Gaps.xl),
        const ServerTile(),
      ],
    );
  }
}

class ServerTile extends ConsumerStatefulWidget {
  const ServerTile({super.key});

  @override
  ConsumerState<ServerTile> createState() => _ServerTileState();
}

class _ServerTileState extends ConsumerState<ServerTile> {
  Future<void> edit() async {
    final backend = ref.read(backendProvider);
    final controller = TextEditingController(text: backend.server?.call() ?? '');
    final l10n = context.l10n;
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.serverTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.url,
          autocorrect: false,
          decoration: InputDecoration(labelText: l10n.serverField, helperText: l10n.serverHint),
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(controller.text), child: Text(l10n.commonSave)),
        ],
      ),
    );
    controller.dispose();
    if (result == null || result.trim().isEmpty) return;
    final url = result.trim().replaceAll(RegExp(r'/+$'), '');
    backend.setServer?.call(url);
    await ref.read(preferencesProvider).setServerUrl(url);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final backend = ref.watch(backendProvider);
    final l10n = context.l10n;
    final p = context.palette;
    final address = backend.server?.call();
    return Material(
      color: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.large), side: BorderSide(color: p.border)),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(backend.demo ? Icons.science_outlined : Icons.dns_outlined),
        title: Text(l10n.serverTitle),
        subtitle: Text(
          backend.demo ? l10n.serverDemo : (address ?? ''),
          style: backend.demo ? null : dataStyle(context, size: 12.5, color: p.text2),
        ),
        trailing: backend.demo ? null : const Icon(Icons.edit_outlined, size: 20),
        onTap: backend.demo ? null : edit,
      ),
    );
  }
}
