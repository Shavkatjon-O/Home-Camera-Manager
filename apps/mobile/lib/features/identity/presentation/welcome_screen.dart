import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/app/routes.dart';
import 'package:smart_surveillance/app/settings/appearance_screen.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/widgets/logo.dart';
import 'package:smart_surveillance/core/widgets/surfaces.dart';
/// The first screen, with the choice to sign in or create an account.
class WelcomeScreen extends ConsumerWidget {
  /// Creates the screen.
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final l10n = context.l10n;
    final demo = ref.watch(backendProvider).demo;
    Widget feature(IconData icon, String text) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          IconBadge(icon: icon, size: 34),
          const SizedBox(width: 14),
          Expanded(child: Text(text, style: context.text.bodyLarge)),
        ],
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.sm, Gaps.sm, 0),
              child: Row(
                children: [
                  if (demo) Tag(l10n.commonDemo, tone: TagTone.info),
                  const Spacer(),
                  IconButton(
                    tooltip: l10n.appearanceLanguage,
                    onPressed: () => showLanguageSheet(context, ref),
                    icon: Icon(Icons.translate_rounded, color: p.text2),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(Gaps.page + 8, Gaps.xl, Gaps.page + 8, Gaps.lg),
                children: [
                  const Align(alignment: Alignment.centerLeft, child: LogoMark(size: 64)),
                  const SizedBox(height: Gaps.xl + 4),
                  Text(l10n.appName, style: dataStyle(context, size: 13, color: p.text3)),
                  const SizedBox(height: Gaps.sm),
                  Semantics(header: true, child: Text(l10n.welcomeTitle, style: context.text.displaySmall)),
                  const SizedBox(height: Gaps.md),
                  Text(l10n.welcomeBody, style: context.text.bodyLarge?.copyWith(color: p.text2)),
                  const SizedBox(height: Gaps.xl),
                  feature(Icons.videocam_outlined, l10n.welcomeFeatureLive),
                  feature(Icons.notifications_active_outlined, l10n.welcomeFeatureAlerts),
                  feature(Icons.bar_chart_rounded, l10n.welcomeFeatureCounts),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Gaps.page + 4, 0, Gaps.page + 4, Gaps.lg),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(onPressed: () => const SignUpRoute().push<void>(context), child: Text(l10n.welcomeCreate)),
                  ),
                  const SizedBox(height: Gaps.sm + 2),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => const SignInRoute().push<void>(context),
                      child: Text(l10n.welcomeSignIn),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
