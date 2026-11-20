import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/app/routes.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/features/alerting/presentation/labels.dart';
import 'package:smart_surveillance/features/tenancy/presentation/current_site.dart';
import 'package:smart_surveillance/features/tenancy/presentation/labels.dart';

/// A button that shows the current site and opens the site sheet.
class SiteSwitcherButton extends ConsumerWidget {
  /// Creates the button.
  const SiteSwitcherButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final site = ref.watch(currentSiteProvider).value;
    final p = context.palette;
    if (site == null) return Text(context.l10n.appName);
    return Semantics(
      button: true,
      label: '${context.l10n.siteSwitcherTitle}: ${site.site.name}',
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.medium),
        onTap: () => showSiteSheet(context, ref),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(siteKindIcon(site.site.kind), size: 20, color: p.text2),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      site.site.name,
                      style: context.text.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      site.organisation.name,
                      style: context.text.labelSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.unfold_more_rounded, size: 20, color: p.text3),
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens the sheet where the user picks a site.
Future<void> showSiteSheet(BuildContext context, WidgetRef ref) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (context) => const SiteSheet(),
);

/// A sheet that lists the user's sites to choose from.
class SiteSheet extends ConsumerWidget {
  /// Creates the sheet.
  const SiteSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final organisations = ref.watch(organisationsProvider).value ?? const [];
    final sites = ref.watch(allSitesProvider).value ?? const [];
    final current = ref.watch(currentSiteProvider).value?.site.id;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: Gaps.lg),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Gaps.page + 4, 0, Gaps.page, Gaps.sm),
              child: Text(l10n.siteSwitcherTitle, style: context.text.titleLarge),
            ),
            for (final organisation in organisations) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(Gaps.page + 4, Gaps.md, Gaps.page, Gaps.xs),
                child: Row(
                  children: [
                    Expanded(child: Text(organisation.name, style: context.text.labelMedium)),
                    Text(
                      l10n.role(organisation.role),
                      style: dataStyle(context, size: 11.5, color: p.text3),
                    ),
                  ],
                ),
              ),
              for (final site in sites.where((s) => s.organisationId == organisation.id))
                ListTile(
                  leading: Icon(siteKindIcon(site.kind)),
                  title: Text(site.name),
                  subtitle: Text(
                    '${l10n.siteKind(site.kind)}, ${l10n.arm(site.armMode).toLowerCase()}',
                  ),
                  trailing: site.id == current ? Icon(Icons.check_rounded, color: p.text) : null,
                  selected: site.id == current,
                  selectedTileColor: p.surface2,
                  onTap: () {
                    ref.read(selectedSiteProvider.notifier).select(site.id);
                    Navigator.of(context).pop();
                  },
                ),
            ],
            const Divider(height: Gaps.xl),
            ListTile(
              leading: const Icon(Icons.add_rounded),
              title: Text(l10n.siteSwitcherAdd),
              onTap: () {
                Navigator.of(context).pop();
                const OnboardingSiteRoute(first: false).push<void>(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
