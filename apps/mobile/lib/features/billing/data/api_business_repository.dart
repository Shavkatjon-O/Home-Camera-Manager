import 'package:smart_surveillance/core/network/api/surveillance_api.dart' as api;
import 'package:smart_surveillance/core/network/client/http.dart';
import 'package:smart_surveillance/core/network/failure.dart';
import 'package:smart_surveillance/features/alerting/domain/models.dart';
import 'package:smart_surveillance/features/billing/domain/business_repository.dart';
import 'package:smart_surveillance/features/billing/domain/models.dart';
import 'package:smart_surveillance/features/operations/domain/models.dart';

/// Reads the organisation's plan and usage, its Telegram chats and its
/// activity log from the server.
///
/// Telegram chats belong to the organisation of the site in the X-Site
/// header, so those calls use the selected site.
class ApiBusinessRepository implements BusinessRepository {
  /// Creates the repository over [client]; [now] reads the current time.
  ApiBusinessRepository(this.client, {DateTime Function()? now}) : now = now ?? DateTime.now;

  /// The generated API.
  final api.SurveillanceApi client;

  /// Reads the current time.
  final DateTime Function() now;

  /// Site names by id, loaded once for the activity log.
  Map<String, String>? siteNames;

  /// The app's feature for each feature key of the server.
  static const features = {
    'faces': PlanFeature.faces,
    'plates': PlanFeature.plates,
    'appearance_search': PlanFeature.appearance,
    'journeys': PlanFeature.journeys,
    'falls': PlanFeature.falls,
    'objects': PlanFeature.objects,
    'follow': PlanFeature.follow,
    'telegram_alerts': PlanFeature.telegram,
  };

  /// Converts the server's plan to the app's [Plan]; a missing or null limit is unlimited.
  static Plan planOf(api.PlanRead plan) => Plan(
    id: plan.key,
    name: plan.name,
    internal: plan.key == 'internal',
    limits: PlanLimits(
      sites: plan.limits['sites'],
      cameras: plan.limits['cameras'],
      members: plan.limits['members'],
      eventRetentionDays: plan.limits['event_retention_days'],
      clipRetentionDays: plan.limits['clip_retention_days'],
    ),
    features: {for (final key in plan.features) ?features[key]},
  );

  @override
  Future<PlanReport> plan(String organisationId) async {
    final entitlements = await guarded(
      () => client.billing.getOrganisationPlan(organisation: organisationId),
    );
    final today = now();
    final start = DateTime(today.year, today.month);
    var usage = Usage(
      periodStart: start,
      sites: entitlements.usage['sites'] ?? 0,
      cameras: entitlements.usage['cameras'] ?? 0,
      members: entitlements.usage['members'] ?? 0,
      metered: false,
    );
    try {
      final metered = await guarded(
        () => client.billing.getOrganisationUsage(
          organisation: organisationId,
          days: today.difference(start).inDays + 1,
          bucket: 'day',
        ),
      );
      double total(String metric) =>
          metered.totals.where((t) => t.metric == metric).fold(0.0, (sum, t) => sum + t.value);
      usage = usage.copyWith(
        cameraHours: total('camera_hours'),
        analyticsHours: total('view_hours'),
        events: total('events').round(),
        clipBytes: total('clip_bytes').round(),
        notifications: total('notifications').round(),
        metered: true,
      );
    } on ApiFailure catch (failure) {
      // Usage is for admins and owners; other members see the plan and the counts.
      if (failure.kind != FailureKind.forbidden) rethrow;
    }
    return PlanReport(
      plan: planOf(entitlements.plan),
      usage: usage,
      suspended: entitlements.suspended,
    );
  }

  @override
  Future<TelegramChats> telegramChats(String organisationId) async {
    final list = await guarded(() => client.telegram.listTelegramChats());
    return TelegramChats([
      for (final chat in list.items)
        TelegramChat(
          id: chat.uuid,
          title: chat.title ?? chat.chatType,
          group: chat.chatType != 'private',
          linkedAt: chat.createdAt.toLocal(),
          blocked: chat.blocked,
        ),
    ], available: list.available);
  }

  @override
  Future<TelegramLink> linkTelegram(String organisationId) async {
    final link = await guarded(() => client.telegram.createTelegramLink());
    return TelegramLink(
      url: link.url,
      groupUrl: link.groupUrl,
      expiresAt: link.expiresAt.toLocal(),
    );
  }

  @override
  Future<void> unlinkTelegram(String organisationId, String chatId) =>
      guarded(() => client.telegram.removeTelegramChat(uuid: chatId));

  @override
  Future<int> testTelegram(String organisationId) async {
    final chats = await telegramChats(organisationId);
    var sent = 0;
    for (final chat in chats.items.where((chat) => !chat.blocked)) {
      try {
        await guarded(() => client.telegram.testTelegramChat(uuid: chat.id));
        sent++;
      } on ApiFailure {
        // A chat that refuses the test is counted out; the others still get it.
      }
    }
    return sent;
  }

  /// Loads the names of the sites the user can reach, once.
  Future<Map<String, String>> names() async {
    final known = siteNames;
    if (known != null) return known;
    final list = await guarded(() => client.sites.listSites());
    return siteNames = {for (final site in list.items) site.uuid: site.name};
  }

  /// Converts the server's audit record to the app's [AuditEntry].
  static AuditEntry entryOf(api.AuditRead record, Map<String, String> sites) {
    final details = record.details;
    final target = [
      details['name'],
      details['email'],
      details['title'],
      details['platform'],
    ].whereType<String>().firstOrNull;
    return AuditEntry(
      id: record.uuid,
      at: record.at.toLocal(),
      actor: record.actor ?? '',
      action: record.action,
      category: auditCategoryOf(record.action),
      target: target,
      siteName: record.site == null ? null : sites[record.site],
    );
  }

  @override
  Future<AuditPage> audit(
    String organisationId, {
    AuditCategory? category,
    int page = 1,
    int pageSize = 40,
  }) async {
    final sites = await names();
    if (category == null) {
      final list = await guarded(
        () => client.audit.readOrganisationAudit(
          organisation: organisationId,
          page: page,
          pageSize: pageSize,
        ),
      );
      return AuditPage(
        items: [for (final record in list.items) entryOf(record, sites)],
        total: list.total,
        page: list.page,
      );
    }
    // The server filters by one action, so a category reads the newest records and keeps its own.
    final list = await guarded(
      () => client.audit.readOrganisationAudit(organisation: organisationId, pageSize: 200),
    );
    final items = [
      for (final record in list.items)
        if (auditCategoryOf(record.action) == category) entryOf(record, sites),
    ];
    return AuditPage(items: items, total: items.length, page: 1);
  }
}
