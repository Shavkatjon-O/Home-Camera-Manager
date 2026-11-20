
import 'package:smart_surveillance/features/alerting/domain/models.dart';
import 'package:smart_surveillance/features/billing/domain/models.dart';
import 'package:smart_surveillance/features/operations/domain/models.dart';
abstract interface class BusinessRepository {
  Future<PlanReport> plan(String organisationId);

  Future<List<TelegramChat>> telegramChats(String organisationId);

  Future<TelegramLink> linkTelegram(String organisationId);

  Future<void> unlinkTelegram(String organisationId, String chatId);

  Future<int> testTelegram(String organisationId);

  Future<AuditPage> audit(String organisationId, {AuditCategory? category, int page = 1, int pageSize = 40});
}
