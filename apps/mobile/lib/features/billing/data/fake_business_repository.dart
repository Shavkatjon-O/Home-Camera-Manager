import 'dart:async';
import 'dart:math';

import 'package:smart_surveillance/app/demo/fake_store.dart';
import 'package:smart_surveillance/app/demo/fixtures.dart';
import 'package:smart_surveillance/features/alerting/domain/models.dart';
import 'package:smart_surveillance/features/billing/domain/business_repository.dart';
import 'package:smart_surveillance/features/billing/domain/models.dart';
import 'package:smart_surveillance/features/operations/domain/models.dart';
/// An in-memory business repository backed by a [FakeStore].
class FakeBusinessRepository implements BusinessRepository {
  /// Creates a repository that keeps its data in [store].
  FakeBusinessRepository(this.store);

  /// The shared fake data store.
  final FakeStore store;

  @override
  Future<PlanReport> plan(String organisationId) => store.delay(() {
    final internal = organisationId == Fixtures.demoOrg || store.createdOrganisations.contains(organisationId);
    final sites = store.data.sites.where((s) => s.organisationId == organisationId).map((s) => s.id).toSet();
    final cameras = store.data.cameras.where((c) => sites.contains(c.camera.siteId)).length;
    final now = store.clock();
    final plan = internal
        ? const Plan(id: 'internal', name: 'Internal', internal: true, features: {...PlanFeature.values})
        : const Plan(
            id: 'free',
            name: 'Free',
            limits: PlanLimits(sites: 1, cameras: 4, members: 5, eventRetentionDays: 7, clipRetentionDays: 7),
            features: {PlanFeature.appearance, PlanFeature.journeys, PlanFeature.objects},
          );
    return PlanReport(
      plan: plan,
      usage: Usage(
        periodStart: DateTime(now.year, now.month),
        sites: sites.length,
        cameras: cameras,
        members: store.data.members[organisationId]?.length ?? 1,
        cameraHours: cameras * 24.0 * (now.day - 0.4),
        analyticsHours: cameras * 21.5 * (now.day - 0.4),
        events: store.data.events.where((e) => sites.contains(e.siteId)).length * 37,
        clipBytes: 6800000000,
        notifications: 212,
      ),
    );
  });

  @override
  Future<List<TelegramChat>> telegramChats(String organisationId) =>
      store.delay(() => List.of(store.data.telegram[organisationId] ?? const []));

  @override
  Future<TelegramLink> linkTelegram(String organisationId) => store.delay(() {
    final now = store.clock();
    final list = store.data.telegram[organisationId] ??= [];
    list.add(TelegramChat(id: 'chat-${store.sequence++}', title: 'Demo night shift', group: true, linkedAt: now, linkedBy: store.data.user.name));
    return TelegramLink(url: 'https://t.me/demo_bot?start=demo-link', expiresAt: now.add(const Duration(minutes: 15)));
  });

  @override
  Future<void> unlinkTelegram(String organisationId, String chatId) =>
      store.delay(() => store.data.telegram[organisationId]?.removeWhere((c) => c.id == chatId));

  @override
  Future<int> testTelegram(String organisationId) => store.delay(() => store.data.telegram[organisationId]?.length ?? 0);

  @override
  Future<AuditPage> audit(String organisationId, {AuditCategory? category, int page = 1, int pageSize = 40}) => store.delay(() {
    final all = (store.data.audit[organisationId] ?? const <AuditEntry>[])
        .where((e) => category == null || e.category == category)
        .toList();
    final start = (page - 1) * pageSize;
    return AuditPage(
      items: start >= all.length ? const [] : all.sublist(start, min(all.length, start + pageSize)),
      total: all.length,
      page: page,
    );
  });
}
