import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/routes.dart';
import '../../core/theme/palette.dart';
import '../../data/models/event.dart';
import '../../l10n/l10n.dart';
import '../../widgets/labels.dart';
import '../site_data.dart';
import 'alerts.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final site = ref.watch(currentSiteProvider).value;
    final unreviewed = site == null ? 0 : ref.watch(todayCountsProvider(site.site.id)).value?.unacknowledged ?? 0;
    if (site != null) {
      ref.listen(liveUpdatesProvider(site.site.id), (previous, next) {
        final update = next.value;
        if (update is! EventChanged) return;
        ref.refreshSite(site.site.id);
        if (update.created && update.event.alert) {
          ref.read(alertCenterProvider).alert(update.event, site.site.name);
          final messenger = ScaffoldMessenger.maybeOf(context);
          messenger
            ?..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(kindIcon(update.event.kind), size: 18, color: p.dangerText),
                    const SizedBox(width: 10),
                    Expanded(child: Text(l10n.eventTitle(update.event), maxLines: 2, overflow: TextOverflow.ellipsis)),
                  ],
                ),
                action: SnackBarAction(
                  label: l10n.commonSeeAll,
                  onPressed: () => EventRoute(eventId: update.event.id).push<void>(context),
                ),
              ),
            );
        }
      });
    }
    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.space_dashboard_outlined),
        selectedIcon: const Icon(Icons.space_dashboard_rounded),
        label: l10n.navHome,
      ),
      NavigationDestination(
        icon: const Icon(Icons.videocam_outlined),
        selectedIcon: const Icon(Icons.videocam_rounded),
        label: l10n.navLive,
      ),
      NavigationDestination(
        icon: Badge.count(
          count: unreviewed,
          isLabelVisible: unreviewed > 0,
          child: const Icon(Icons.notifications_none_rounded),
        ),
        selectedIcon: Badge.count(
          count: unreviewed,
          isLabelVisible: unreviewed > 0,
          child: const Icon(Icons.notifications_rounded),
        ),
        label: l10n.navEvents,
        tooltip: unreviewed > 0 ? '${l10n.navEvents}, ${l10n.homeUnacknowledged(unreviewed)}' : null,
      ),
      NavigationDestination(
        icon: const Icon(Icons.manage_search_rounded),
        selectedIcon: const Icon(Icons.manage_search_rounded),
        label: l10n.navSearch,
      ),
      NavigationDestination(
        icon: const Icon(Icons.menu_rounded),
        selectedIcon: const Icon(Icons.menu_open_rounded),
        label: l10n.navMore,
      ),
    ];
    return Scaffold(
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: p.border))),
        child: NavigationBar(
          selectedIndex: shell.currentIndex,
          destinations: destinations,
          onDestinationSelected: (index) => shell.goBranch(index, initialLocation: index == shell.currentIndex),
        ),
      ),
    );
  }
}
