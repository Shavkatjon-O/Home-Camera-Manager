import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/format.dart';
import 'package:smart_surveillance/core/providers.dart';
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/core/widgets/surfaces.dart';
import 'package:smart_surveillance/features/alerting/data/alert_center.dart';
import 'package:smart_surveillance/features/alerting/domain/models.dart';
import 'package:smart_surveillance/features/billing/domain/models.dart';
import 'package:smart_surveillance/features/billing/presentation/plan_screen.dart';
import 'package:smart_surveillance/features/events/domain/models.dart';
import 'package:smart_surveillance/features/events/presentation/labels.dart';
import 'package:smart_surveillance/features/tenancy/domain/models.dart';
import 'package:smart_surveillance/features/tenancy/presentation/current_site.dart';
import 'package:url_launcher/url_launcher.dart';

/// The notification settings of a site.
final prefsProvider = FutureProvider.autoDispose.family<NotificationPrefs, String>(
  (ref, siteId) => ref.read(backendProvider).notifications.prefs(siteId),
);

/// Whether the phone lets the app post notifications.
final notificationPermissionProvider = FutureProvider.autoDispose<PermissionStatus>(
  (ref) => Permission.notification.status,
);

/// The Telegram chats an organisation sends alerts to.
final telegramChatsProvider = FutureProvider.autoDispose.family<List<TelegramChat>, String>(
  (ref, organisationId) => ref.read(backendProvider).business.telegramChats(organisationId),
);

/// The event kinds a user can mute.
const mutableKinds = [
  EventKind.intrusion,
  EventKind.lineCrossing,
  EventKind.loitering,
  EventKind.crowd,
  EventKind.tamper,
  EventKind.faceUnknown,
  EventKind.objectLeft,
  EventKind.objectTaken,
  EventKind.fall,
];

/// Notification settings: alerts per site, kinds, quiet hours, delivery and Telegram.
class NotificationsScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  NotificationPrefs? draft;

  Future<void> save(NotificationPrefs prefs) async {
    setState(() => draft = prefs);
    try {
      await ref.read(backendProvider).notifications.savePrefs(prefs);
    } catch (failure) {
      if (mounted) showFailure(context, failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final site = ref.watch(currentSiteProvider).value;
    if (site == null) return const Scaffold();
    final value = ref.watch(prefsProvider(site.site.id));
    final permission = ref.watch(notificationPermissionProvider).value;
    final center = ref.watch(alertCenterProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationsTitle)),
      body: AsyncBody(
        value: value,
        onRetry: () => ref.invalidate(prefsProvider(site.site.id)),
        data: (loaded) {
          final prefs = draft?.siteId == site.site.id ? draft! : loaded;
          return ListView(
            padding: const EdgeInsets.only(bottom: Gaps.xxl),
            children: [
              if (permission != null && !permission.isGranted)
                Padding(
                  padding: const EdgeInsets.fromLTRB(Gaps.page, 0, Gaps.page, Gaps.md),
                  child: Panel(
                    color: p.warning.withValues(alpha: 0.08),
                    child: Row(
                      children: [
                        Icon(Icons.notifications_off_outlined, color: p.warning),
                        const SizedBox(width: Gaps.md),
                        Expanded(child: Text(l10n.notificationsPermissionOff)),
                        TextButton(
                          onPressed: () async {
                            final status = await Permission.notification.request();
                            if (status.isPermanentlyDenied) await openAppSettings();
                            ref.invalidate(notificationPermissionProvider);
                          },
                          child: Text(l10n.notificationsOpenSettings),
                        ),
                      ],
                    ),
                  ),
                ),
              TileGroup(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_active_outlined),
                    title: Text(l10n.notificationsSite(site.site.name)),
                    value: prefs.enabled,
                    onChanged: (value) => save(prefs.copyWith(enabled: value)),
                  ),
                  SwitchListTile(
                    title: Text(l10n.notificationsAlertsOnly),
                    subtitle: Text(l10n.notificationsAlertsOnlyBody),
                    value: prefs.alertsOnly,
                    onChanged: prefs.enabled
                        ? (value) => save(prefs.copyWith(alertsOnly: value))
                        : null,
                  ),
                ],
              ),
              SectionHeader(l10n.notificationsKinds),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final kind in mutableKinds)
                      FilterChip(
                        avatar: Icon(kindIcon(kind), size: 16),
                        label: Text(l10n.kind(kind)),
                        selected: !prefs.mutedKinds.contains(kind.name),
                        onSelected: prefs.enabled
                            ? (on) => save(
                                prefs.copyWith(
                                  mutedKinds: on
                                      ? ({...prefs.mutedKinds}..remove(kind.name))
                                      : {...prefs.mutedKinds, kind.name},
                                ),
                              )
                            : null,
                      ),
                  ],
                ),
              ),
              SectionHeader(l10n.notificationsQuiet),
              TileGroup(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.bedtime_outlined),
                    title: Text(l10n.notificationsQuiet),
                    subtitle: Text(
                      prefs.quietFrom == null
                          ? l10n.notificationsQuietOff
                          : l10n.notificationsQuietBody(
                              prefs.quietFrom!,
                              prefs.quietUntil ?? '07:00',
                            ),
                    ),
                    value: prefs.quietFrom != null,
                    onChanged: prefs.enabled
                        ? (on) => save(
                            on
                                ? prefs.copyWith(quietFrom: '23:00', quietUntil: '07:00')
                                : prefs.copyWith(quietFrom: null, quietUntil: null),
                          )
                        : null,
                  ),
                ],
              ),
              SectionHeader(l10n.notificationsChannel),
              TileGroup(
                children: [
                  ListTile(
                    leading: Icon(
                      center.pushAvailable
                          ? Icons.cloud_done_outlined
                          : Icons.phone_android_outlined,
                    ),
                    title: Text(
                      center.pushAvailable
                          ? l10n.notificationsChannelFcm
                          : l10n.notificationsChannelNone,
                    ),
                  ),
                ],
              ),
              TelegramSection(site: site),
            ],
          );
        },
      ),
    );
  }
}

/// Links, lists, tests and unlinks the organisation's Telegram chats.
class TelegramSection extends ConsumerStatefulWidget {
  /// Creates the section for [site]'s organisation.
  const TelegramSection({super.key, required this.site});

  /// The current site and its organisation.
  final SiteContext site;

  @override
  ConsumerState<TelegramSection> createState() => _TelegramSectionState();
}

class _TelegramSectionState extends ConsumerState<TelegramSection> with WidgetsBindingObserver {
  bool busy = false;

  String get organisationId => widget.site.organisation.id;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Coming back from Telegram is when a new chat has just been linked.
    if (state == AppLifecycleState.resumed) ref.invalidate(telegramChatsProvider(organisationId));
  }

  Future<void> link() async {
    final l10n = context.l10n;
    setState(() => busy = true);
    try {
      final link = await ref.read(backendProvider).business.linkTelegram(organisationId);
      final opened =
          ref.read(backendProvider).demo ||
          await launchUrl(Uri.parse(link.url), mode: LaunchMode.externalApplication);
      if (!mounted) return;
      showMessage(context, opened ? l10n.telegramOpened : l10n.telegramCannotOpen);
      ref.invalidate(telegramChatsProvider(organisationId));
    } catch (failure) {
      if (mounted) showFailure(context, failure);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> test() async {
    try {
      final sent = await ref.read(backendProvider).business.testTelegram(organisationId);
      if (mounted) showMessage(context, context.l10n.telegramTestSent(sent));
    } catch (failure) {
      if (mounted) showFailure(context, failure);
    }
  }

  Future<void> unlink(TelegramChat chat) async {
    final l10n = context.l10n;
    final ok = await confirm(
      context,
      title: l10n.telegramUnlink,
      body: l10n.telegramUnlinkBody(chat.title),
      action: l10n.telegramUnlink,
      destructive: true,
    );
    if (!ok) return;
    try {
      await ref.read(backendProvider).business.unlinkTelegram(organisationId, chat.id);
      ref.invalidate(telegramChatsProvider(organisationId));
    } catch (failure) {
      if (mounted) showFailure(context, failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final plan = ref.watch(planProvider(organisationId)).value?.plan;
    final format = Formats(context, ref.read(clockProvider)());
    final admin = widget.site.can(Role.admin);
    final header = SectionHeader(l10n.telegramTitle);
    if (plan != null && !plan.has(PlanFeature.telegram)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          TileGroup(
            children: [
              ListTile(
                leading: Icon(Icons.send_outlined, color: p.text3),
                title: Text(l10n.featureTelegram, style: TextStyle(color: p.text2)),
                subtitle: Text(l10n.planUnavailable),
              ),
            ],
          ),
        ],
      );
    }
    final chats = ref.watch(telegramChatsProvider(organisationId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        Padding(
          padding: const EdgeInsets.fromLTRB(Gaps.page, 0, Gaps.page, Gaps.sm),
          child: Text(l10n.telegramBody, style: context.text.bodySmall),
        ),
        chats.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(Gaps.lg),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (error, _) => ErrorState(
            error: error,
            compact: true,
            onRetry: () => ref.invalidate(telegramChatsProvider(organisationId)),
          ),
          data: (list) => TileGroup(
            children: [
              if (list.isEmpty)
                ListTile(
                  leading: Icon(Icons.send_outlined, color: p.text3),
                  title: Text(l10n.telegramNone, style: TextStyle(color: p.text2)),
                ),
              for (final chat in list)
                ListTile(
                  leading: Icon(chat.group ? Icons.groups_outlined : Icons.person_outline_rounded),
                  title: Text(chat.title),
                  subtitle: Text(
                    '${chat.group ? l10n.telegramGroup : l10n.telegramPrivate}, ${l10n.telegramLinked(format.ago(chat.linkedAt))}',
                  ),
                  trailing: admin
                      ? IconButton(
                          tooltip: l10n.telegramUnlink,
                          onPressed: () => unlink(chat),
                          icon: const Icon(Icons.link_off_rounded),
                        )
                      : null,
                ),
            ],
          ),
        ),
        if (admin)
          Padding(
            padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.md, Gaps.page, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: busy ? null : link,
                        icon: const Icon(Icons.add_link_rounded, size: 18),
                        label: Text(l10n.telegramLink),
                      ),
                    ),
                    const SizedBox(width: Gaps.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: (chats.value?.isEmpty ?? true) ? null : test,
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: Text(l10n.telegramTest),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Gaps.sm),
                Text(l10n.telegramLinkBody, style: context.text.bodySmall),
              ],
            ),
          ),
      ],
    );
  }
}
