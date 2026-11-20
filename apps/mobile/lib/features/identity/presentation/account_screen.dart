import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/format.dart';
import 'package:smart_surveillance/core/providers.dart';
import 'package:smart_surveillance/core/widgets/flow_scaffold.dart';
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/core/widgets/surfaces.dart';
import 'package:smart_surveillance/features/identity/domain/models.dart';
import 'package:smart_surveillance/features/identity/presentation/session.dart';

/// The devices signed in to the user's account.
final sessionsProvider = FutureProvider.autoDispose<List<DeviceSession>>(
  (ref) => ref.read(backendProvider).auth.sessions(),
);

/// The account page with the profile, signed-in devices, sign out and account deletion.
class AccountScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  late bool lock = ref.read(preferencesProvider).appLock;

  Future<void> rename(User user) async {
    final l10n = context.l10n;
    final controller = TextEditingController(text: user.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.fieldName),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty) return;
    try {
      final updated = await ref.read(backendProvider).auth.updateProfile(name: name.trim());
      ref.read(sessionProvider.notifier).updateUser(updated);
    } catch (failure) {
      if (mounted) showFailure(context, failure);
    }
  }

  Future<void> toggleLock(bool value) async {
    final l10n = context.l10n;
    if (value) {
      final auth = LocalAuthentication();
      if (!await auth.isDeviceSupported()) {
        if (mounted) showMessage(context, l10n.accountAppLockUnavailable);
        return;
      }
      final ok = await auth.authenticate(localizedReason: l10n.lockReason);
      if (!ok) return;
    }
    await ref.read(preferencesProvider).setAppLock(value);
    setState(() => lock = value);
  }

  Future<void> delete() async {
    final l10n = context.l10n;
    final password = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: context.palette.dangerText),
        title: Text(l10n.accountDeleteTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.accountDeleteBody),
            const SizedBox(height: Gaps.lg),
            PasswordField(controller: password, label: l10n.accountDeletePassword),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.palette.danger,
              foregroundColor: const Color(0xFFFFFFFF),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.accountDeleteConfirm),
          ),
        ],
      ),
    );
    final text = password.text;
    password.dispose();
    if (ok != true) return;
    try {
      await ref.read(sessionProvider.notifier).deleteAccount(text);
    } catch (failure) {
      if (mounted) showFailure(context, failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final user = signedInUser(ref);
    final sessions = ref.watch(sessionsProvider);
    final format = Formats(context, ref.read(clockProvider)());
    if (user == null) return const Scaffold();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Gaps.xxl),
        children: [
          SectionHeader(
            l10n.accountProfile,
            padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.sm, Gaps.page, Gaps.sm),
          ),
          TileGroup(
            children: [
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: Text(user.name),
                subtitle: Text(l10n.fieldName),
                trailing: const Icon(Icons.edit_outlined, size: 20),
                onTap: () => rename(user),
              ),
              ListTile(
                leading: const Icon(Icons.alternate_email_rounded),
                title: Text(user.email),
                subtitle: Text(l10n.fieldEmail),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.fingerprint_rounded),
                title: Text(l10n.accountAppLock),
                subtitle: Text(l10n.accountAppLockBody),
                value: lock,
                onChanged: toggleLock,
              ),
            ],
          ),
          SectionHeader(l10n.accountSessions),
          sessions.when(
            loading: () =>
                const SizedBox(height: 160, child: ListSkeleton(rows: 2, thumbnail: false)),
            error: (error, _) => ErrorState(
              error: error,
              compact: true,
              onRetry: () => ref.invalidate(sessionsProvider),
            ),
            data: (sessions) => TileGroup(
              children: [
                for (final session in sessions)
                  ListTile(
                    leading: Icon(
                      session.platform.toLowerCase() == 'web'
                          ? Icons.computer_outlined
                          : Icons.smartphone_outlined,
                    ),
                    title: Row(
                      children: [
                        Flexible(child: Text(session.deviceName, overflow: TextOverflow.ellipsis)),
                        if (session.current) ...[
                          const SizedBox(width: 8),
                          Tag(l10n.accountThisDevice, tone: TagTone.ok, dense: true),
                        ],
                      ],
                    ),
                    subtitle: Text(l10n.accountLastUsed(format.ago(session.lastUsedAt))),
                    trailing: session.current
                        ? null
                        : IconButton(
                            tooltip: l10n.accountRevoke,
                            onPressed: () async {
                              try {
                                await ref.read(backendProvider).auth.revokeSession(session.id);
                                ref.invalidate(sessionsProvider);
                                if (context.mounted) {
                                  showMessage(context, l10n.accountRevoked(session.deviceName));
                                }
                              } catch (failure) {
                                if (context.mounted) showFailure(context, failure);
                              }
                            },
                            icon: const Icon(Icons.logout_rounded),
                          ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Gaps.xl),
          TileGroup(
            children: [
              ListTile(
                leading: Icon(Icons.delete_forever_outlined, color: p.dangerText),
                title: Text(l10n.accountDelete, style: TextStyle(color: p.dangerText)),
                onTap: delete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
