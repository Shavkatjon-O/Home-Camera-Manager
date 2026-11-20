import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/app/routes.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/core/widgets/surfaces.dart';
import 'package:smart_surveillance/features/identity/presentation/session.dart';
import 'package:smart_surveillance/features/tenancy/domain/models.dart';
import 'package:smart_surveillance/features/tenancy/presentation/current_site.dart';
import 'package:smart_surveillance/features/tenancy/presentation/labels.dart';
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final user = signedInUser(ref);
    final site = ref.watch(currentSiteProvider).value;
    final admin = site?.can(Role.admin) ?? false;
    ListTile tile(IconData icon, String title, VoidCallback onTap, {String? subtitle, Widget? trailing}) => ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.moreTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Gaps.xxl),
        children: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.xs, Gaps.page, 0),
              child: Panel(
                onTap: () => const AccountRoute().go(context),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: p.surface3,
                      child: Text(
                        user.name.isEmpty ? '?' : user.name.characters.first.toUpperCase(),
                        style: context.text.titleMedium,
                      ),
                    ),
                    const SizedBox(width: Gaps.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name, style: context.text.titleMedium),
                          Text(user.email, style: context.text.bodySmall, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    if (site != null) Tag(l10n.role(site.role)),
                  ],
                ),
              ),
            ),
          if (site != null) ...[
            SectionHeader('${l10n.moreSite}: ${site.site.name}'),
            TileGroup(
              children: [
                tile(Icons.bar_chart_rounded, l10n.moreCounts, () => const CountsRoute().go(context)),
                tile(Icons.health_and_safety_outlined, l10n.moreHealth, () => const HealthRoute().go(context)),
                if (admin) ...[
                  tile(Icons.videocam_outlined, l10n.moreCameras, () => const CamerasRoute().go(context)),
                  tile(Icons.auto_awesome_outlined, l10n.moreAnalytics, () => const AnalyticsRoute().go(context)),
                  tile(Icons.router_outlined, l10n.moreConnectors, () => const ConnectorsRoute().go(context)),
                  tile(Icons.tune_rounded, l10n.moreSiteSettings, () => const SiteSettingsRoute().go(context)),
                ],
              ],
            ),
            SectionHeader('${l10n.moreOrganisation}: ${site.organisation.name}'),
            TileGroup(
              children: [
                tile(Icons.group_outlined, l10n.moreMembers, () => const MembersRoute().go(context)),
                if (admin) tile(Icons.workspace_premium_outlined, l10n.morePlan, () => const PlanRoute().go(context)),
                if (admin) tile(Icons.history_rounded, l10n.moreActivity, () => const ActivityRoute().go(context)),
                tile(
                  Icons.face_outlined,
                  l10n.moreFaces,
                  () => const FacesRoute().go(context),
                  subtitle: site.organisation.facesEnabled ? l10n.facesEnabled : l10n.facesDisabled,
                ),
              ],
            ),
          ],
          SectionHeader(l10n.moreYou),
          TileGroup(
            children: [
              tile(Icons.notifications_outlined, l10n.moreNotifications, () => const NotificationsRoute().go(context)),
              tile(Icons.person_outline_rounded, l10n.moreAccount, () => const AccountRoute().go(context)),
              tile(Icons.palette_outlined, l10n.moreAppearance, () => const AppearanceRoute().go(context)),
              tile(Icons.info_outline_rounded, l10n.moreAbout, () => const AboutRoute().go(context)),
            ],
          ),
          const SizedBox(height: Gaps.xl),
          TileGroup(
            children: [
              ListTile(
                leading: Icon(Icons.logout_rounded, color: p.dangerText),
                title: Text(l10n.moreSignOut, style: TextStyle(color: p.dangerText)),
                onTap: () async {
                  final ok = await confirm(context, title: l10n.moreSignOutConfirm, action: l10n.moreSignOut);
                  if (ok) await ref.read(sessionProvider.notifier).signOut();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
