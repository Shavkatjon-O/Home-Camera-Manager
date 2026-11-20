import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/routes.dart';
import '../../core/format.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/theme.dart';
import '../../data/models/account.dart';
import '../../l10n/l10n.dart';
import '../../widgets/flow_scaffold.dart';
import '../../widgets/labels.dart';
import '../../widgets/states.dart';
import '../../widgets/surfaces.dart';

final invitationProvider = FutureProvider.autoDispose.family<InvitationPreview, String>(
  (ref, token) => ref.read(backendProvider).tenancy.previewInvitation(token),
);

class InviteScreen extends ConsumerStatefulWidget {
  const InviteScreen({super.key, required this.token});

  final String token;

  @override
  ConsumerState<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends ConsumerState<InviteScreen> {
  bool busy = false;

  Future<void> accept(InvitationPreview preview) async {
    setState(() => busy = true);
    try {
      final organisation = await ref.read(backendProvider).tenancy.acceptInvitation(widget.token);
      ref.invalidate(organisationsProvider);
      if (!mounted) return;
      showMessage(context, context.l10n.inviteAccepted(organisation.name));
      const HomeRoute().go(context);
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
    final value = ref.watch(invitationProvider(widget.token));
    final signedIn = ref.watch(sessionProvider).value is SignedIn;
    final preview = value.value;
    final format = Formats(context, ref.read(clockProvider)());
    return FlowScaffold(
      title: l10n.inviteTitle,
      bottom: preview == null
          ? null
          : signedIn
          ? BusyButton(label: l10n.inviteAccept, busy: busy, onPressed: () => accept(preview))
          : Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => const SignInRoute().push<void>(context),
                    child: Text(l10n.welcomeSignIn),
                  ),
                ),
                const SizedBox(width: Gaps.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: () => const SignUpRoute().push<void>(context),
                    child: Text(l10n.welcomeCreate),
                  ),
                ),
              ],
            ),
      children: [
        AsyncBody(
          value: value,
          onRetry: () => ref.invalidate(invitationProvider(widget.token)),
          data: (preview) => Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const IconBadge(icon: Icons.mail_outline_rounded),
                    const SizedBox(width: 12),
                    Expanded(child: Text(preview.organisationName, style: context.text.titleMedium)),
                  ],
                ),
                const SizedBox(height: Gaps.lg),
                Text(
                  l10n.inviteBody(preview.invitedBy, preview.organisationName, l10n.role(preview.role).toLowerCase()),
                  style: context.text.bodyLarge,
                ),
                const SizedBox(height: Gaps.sm),
                Text(
                  preview.siteNames.isEmpty ? l10n.inviteAllSites : l10n.inviteSites(preview.siteNames.join(', ')),
                  style: context.text.bodyMedium?.copyWith(color: p.text2),
                ),
                const SizedBox(height: Gaps.sm),
                Text(l10n.inviteExpires(format.date(preview.expiresAt)), style: context.text.bodySmall),
                if (!signedIn) ...[
                  const SizedBox(height: Gaps.lg),
                  Text(l10n.inviteSignInFirst, style: context.text.bodyMedium?.copyWith(color: p.text2)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
