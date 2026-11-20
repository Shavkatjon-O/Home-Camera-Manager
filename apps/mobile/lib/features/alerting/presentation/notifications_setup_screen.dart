import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/app/routes.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/providers.dart';
import 'package:smart_surveillance/core/widgets/flow_scaffold.dart';
import 'package:smart_surveillance/core/widgets/surfaces.dart';

/// Asks for the notification permission during setup.
class NotificationsSetupScreen extends ConsumerWidget {
  /// Creates the screen.
  const NotificationsSetupScreen({super.key});

  /// Requests notification permission when [ask] is true, then continues onboarding.
  Future<void> finish(BuildContext context, WidgetRef ref, {required bool ask}) async {
    if (ask) await Permission.notification.request();
    await ref.read(preferencesProvider).setOnboardedNotifications(true);
    if (context.mounted) const OnboardingDoneRoute().pushReplacement(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return FlowScaffold(
      title: l10n.onboardingNotificationsTitle,
      subtitle: l10n.onboardingNotificationsBody,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => finish(context, ref, ask: true),
              icon: const Icon(Icons.notifications_active_outlined),
              label: Text(l10n.onboardingNotificationsAllow),
            ),
          ),
          TextButton(onPressed: () => finish(context, ref, ask: false), child: Text(l10n.commonSkip)),
        ],
      ),
      children: [
        Center(child: IconBadge(icon: Icons.notifications_active_outlined, size: 88, color: context.palette.text)),
      ],
    );
  }
}
