import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/app/routes.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/format.dart';
import 'package:smart_surveillance/core/providers.dart';
import 'package:smart_surveillance/core/widgets/flow_scaffold.dart';
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/core/widgets/surfaces.dart';
import 'package:smart_surveillance/features/identity/presentation/session.dart';
import 'package:smart_surveillance/features/tenancy/domain/models.dart';
import 'package:smart_surveillance/features/tenancy/presentation/current_site.dart';
import 'package:smart_surveillance/features/tenancy/presentation/labels.dart';

/// What an invitation offers, loaded by its token.
final invitationProvider = FutureProvider.autoDispose.family<InvitationPreview, String>(
  (ref, token) => ref.read(backendProvider).tenancy.previewInvitation(token),
);

/// The screen where an invited person reviews and accepts an invitation.
class InviteScreen extends ConsumerStatefulWidget {
  /// Creates the screen for the invitation identified by [token].
  const InviteScreen({super.key, required this.token});

  /// The token of the invitation.
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
                    Expanded(
                      child: Text(preview.organisationName, style: context.text.titleMedium),
                    ),
                  ],
                ),
                const SizedBox(height: Gaps.lg),
                Text(
                  l10n.inviteBody(
                    preview.invitedBy,
                    preview.organisationName,
                    l10n.role(preview.role).toLowerCase(),
                  ),
                  style: context.text.bodyLarge,
                ),
                const SizedBox(height: Gaps.sm),
                Text(
                  preview.siteNames.isEmpty
                      ? l10n.inviteAllSites
                      : l10n.inviteSites(preview.siteNames.join(', ')),
                  style: context.text.bodyMedium?.copyWith(color: p.text2),
                ),
                const SizedBox(height: Gaps.sm),
                Text(
                  l10n.inviteExpires(format.date(preview.expiresAt)),
                  style: context.text.bodySmall,
                ),
                if (!signedIn) ...[
                  const SizedBox(height: Gaps.lg),
                  Text(
                    l10n.inviteSignInFirst,
                    style: context.text.bodyMedium?.copyWith(color: p.text2),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
