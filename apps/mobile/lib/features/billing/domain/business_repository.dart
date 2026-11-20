
import 'package:smart_surveillance/features/alerting/domain/models.dart';
import 'package:smart_surveillance/features/billing/domain/models.dart';
import 'package:smart_surveillance/features/operations/domain/models.dart';
/// Reads plan, Telegram and audit data of an organisation.
abstract interface class BusinessRepository {
  /// Returns the plan and usage of the organisation [organisationId].
  Future<PlanReport> plan(String organisationId);

  /// Returns the Telegram chats linked to the organisation [organisationId].
  Future<List<TelegramChat>> telegramChats(String organisationId);

  /// Creates a one-time link for connecting a Telegram chat to [organisationId].
  Future<TelegramLink> linkTelegram(String organisationId);

  /// Removes the Telegram chat [chatId] from the organisation [organisationId].
  Future<void> unlinkTelegram(String organisationId, String chatId);

  /// Sends a test message to the linked chats of [organisationId] and returns how many received it.
  Future<int> testTelegram(String organisationId);

  /// Returns one page of the audit log of [organisationId], optionally limited to [category].
  Future<AuditPage> audit(String organisationId, {AuditCategory? category, int page = 1, int pageSize = 40});
}
