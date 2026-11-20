import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/app/routes.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/widgets/flow_scaffold.dart';
import 'package:smart_surveillance/features/tenancy/presentation/current_site.dart';

/// The last step of the first setup.
class SetupDoneScreen extends ConsumerWidget {
  /// Creates the screen.
  const SetupDoneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    return FlowScaffold(
      title: l10n.onboardingDoneTitle,
      subtitle: l10n.onboardingDoneBody,
      showBack: false,
      bottom: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () {
            ref.invalidate(organisationsProvider);
            ref.invalidate(allSitesProvider);
            const HomeRoute().go(context);
          },
          child: Text(l10n.onboardingOpenHome),
        ),
      ),
      children: [
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(color: p.ok.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(Icons.check_rounded, size: 48, color: p.ok),
          ),
        ),
      ],
    );
  }
}
