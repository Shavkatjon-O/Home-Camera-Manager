import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_surveillance/core/network/api/surveillance_api.dart' as api;
import 'package:smart_surveillance/core/network/client/http.dart';
import 'package:smart_surveillance/core/network/failure.dart';
import 'package:smart_surveillance/features/billing/data/api_business_repository.dart';
import 'package:smart_surveillance/features/billing/domain/models.dart';
import 'package:smart_surveillance/features/operations/domain/models.dart';
import 'package:smart_surveillance/features/tenancy/data/api_tenancy_repository.dart';

/// Builds a Dio error with [status] and the API error [code].
DioException refusal(int status, String code) {
  final options = RequestOptions(path: '/things');
  return DioException(
    requestOptions: options,
    response: Response<Object?>(
      requestOptions: options,
      statusCode: status,
      data: {
        'detail': {'code': code, 'message': 'Refused'},
      },
    ),
  );
}

/// Runs the plan, activity and retention mapping tests.
void main() {
  group('plans', () {
    test('map limits, unlimited values and feature keys', () {
      final plan = ApiBusinessRepository.planOf(
        api.PlanRead.fromJson({
          'key': 'free',
          'name': 'Free',
          'limits': {
            'sites': 3,
            'cameras': 16,
            'members': 10,
            'event_retention_days': 30,
            'clip_retention_days': null,
          },
          'features': ['faces', 'appearance_search', 'telegram_alerts', 'something_new'],
        }),
      );
      expect(plan.internal, isFalse);
      expect(plan.limits.sites, 3);
      expect(plan.limits.eventRetentionDays, 30);
      expect(plan.limits.clipRetentionDays, isNull);
      expect(plan.features, {PlanFeature.faces, PlanFeature.appearance, PlanFeature.telegram});
    });

    test('mark the internal plan', () {
      final plan = ApiBusinessRepository.planOf(
        api.PlanRead.fromJson({
          'key': 'internal',
          'name': 'Internal',
          'limits': <String, Object?>{},
          'features': <Object?>[],
        }),
      );
      expect(plan.internal, isTrue);
      expect(plan.limits.cameras, isNull);
    });
  });

  group('activity', () {
    test('sorts every server action into a category', () {
      expect(auditCategoryOf('sign_in'), AuditCategory.signIn);
      expect(auditCategoryOf('password_change'), AuditCategory.signIn);
      expect(auditCategoryOf('device_pair'), AuditCategory.cameras);
      expect(auditCategoryOf('rules_update'), AuditCategory.rules);
      expect(auditCategoryOf('alert_channel_link'), AuditCategory.arm);
      expect(auditCategoryOf('live_view'), AuditCategory.views);
      expect(auditCategoryOf('export'), AuditCategory.exports);
      expect(auditCategoryOf('faces_consent'), AuditCategory.faces);
      expect(auditCategoryOf('admin_suspend'), AuditCategory.admin);
      expect(auditCategoryOf('site_update'), AuditCategory.members);
    });

    test('reads the actor, a target and the site name', () {
      final entry = ApiBusinessRepository.entryOf(
        api.AuditRead.fromJson({
          'uuid': 'audit-1',
          'at': '2026-03-14T10:00:00Z',
          'action': 'invitation_create',
          'actor': 'example-owner',
          'organisation': 'org-1',
          'site': 'site-1',
          'target_kind': 'invitation',
          'target_uuid': 'invitation-1',
          'details': {'email': 'guard@example.com'},
          'ip': null,
        }),
        {'site-1': 'Example store'},
      );
      expect(entry.actor, 'example-owner');
      expect(entry.category, AuditCategory.members);
      expect(entry.target, 'guard@example.com');
      expect(entry.siteName, 'Example store');
    });
  });

  group('plan refusals', () {
    test('map the plan and suspension codes', () {
      expect(failureOf(refusal(403, 'feature_not_in_plan')).kind, FailureKind.planFeature);
      expect(failureOf(refusal(403, 'plan_limit_reached')).kind, FailureKind.planLimit);
      expect(failureOf(refusal(403, 'organisation_suspended')).kind, FailureKind.suspended);
      expect(failureOf(refusal(422, 'retention_over_plan')).kind, FailureKind.planLimit);
      expect(failureOf(refusal(422, 'validation')).kind, FailureKind.invalid);
    });
  });

  group('site retention', () {
    test('uses the effective retention of a site', () {
      final site = ApiTenancyRepository.siteOf(
        api.SiteRead.fromJson({
          'uuid': 'site-1',
          'organisation': 'org-1',
          'organisation_name': 'Example organisation',
          'name': 'Example store',
          'kind': 'store',
          'timezone': 'UTC',
          'position': 0,
          'role': 'owner',
          'camera_count': 1,
          'connector_count': 0,
          'event_retention_days': null,
          'effective_event_retention_days': 14,
          'created_at': '2026-03-01T08:00:00Z',
          'updated_at': '2026-03-02T08:00:00Z',
        }),
      );
      expect(site.retentionDays, 14);
    });
  });
}
