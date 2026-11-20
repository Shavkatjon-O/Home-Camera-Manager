import 'package:flutter_test/flutter_test.dart';
import 'package:smart_surveillance/core/network/api/surveillance_api.dart' as api;
import 'package:smart_surveillance/features/alerting/domain/models.dart';
import 'package:smart_surveillance/features/tenancy/data/api_tenancy_repository.dart';
import 'package:smart_surveillance/features/tenancy/domain/models.dart';

/// A site as the server writes it.
Map<String, Object?> siteJson({String kind = 'store'}) => {
  'uuid': 'site-1',
  'organisation': 'org-1',
  'organisation_name': 'Example organisation',
  'name': 'Example store',
  'kind': kind,
  'timezone': 'Asia/Tashkent',
  'position': 0,
  'role': 'admin',
  'camera_count': 4,
  'connector_count': 1,
  'created_at': '2026-03-01T08:00:00Z',
  'updated_at': '2026-03-02T08:00:00Z',
};

/// Runs the tenancy mapping tests.
void main() {
  group('roles', () {
    test('map every server role to the app role', () {
      expect(ApiTenancyRepository.roleOf(api.Role.viewer), Role.viewer);
      expect(ApiTenancyRepository.roleOf(api.Role.operator2), Role.operator);
      expect(ApiTenancyRepository.roleOf(api.Role.admin), Role.admin);
      expect(ApiTenancyRepository.roleOf(api.Role.owner), Role.owner);
    });

    test('fall back to viewer for an unknown role', () {
      expect(ApiTenancyRepository.roleOf(api.Role.fromJson('auditor')), Role.viewer);
    });

    test('round trip through the wire role', () {
      for (final role in Role.values) {
        expect(ApiTenancyRepository.roleOf(ApiTenancyRepository.wireRole(role)), role);
      }
    });

    test('order by power', () {
      expect(Role.owner.atLeast(Role.admin), isTrue);
      expect(Role.operator.atLeast(Role.operator), isTrue);
      expect(Role.viewer.atLeast(Role.operator), isFalse);
    });
  });

  group('siteOf', () {
    test('maps a site and keeps the given arm mode', () {
      final site = ApiTenancyRepository.siteOf(
        api.SiteRead.fromJson(siteJson()),
        armMode: ArmMode.away,
      );
      expect(site.id, 'site-1');
      expect(site.organisationId, 'org-1');
      expect(site.name, 'Example store');
      expect(site.kind, SiteKind.store);
      expect(site.timezone, 'Asia/Tashkent');
      expect(site.armMode, ArmMode.away);
    });

    test('defaults the arm mode to the schedule', () {
      final site = ApiTenancyRepository.siteOf(api.SiteRead.fromJson(siteJson(kind: 'home')));
      expect(site.kind, SiteKind.home);
      expect(site.armMode, ArmMode.schedule);
    });
  });

  group('organisationOf', () {
    test('maps an organisation with its role and face switch', () {
      final organisation = ApiTenancyRepository.organisationOf(
        api.OrganisationRead.fromJson({
          'uuid': 'org-1',
          'name': 'Example organisation',
          'role': 'owner',
          'faces_enabled': true,
          'faces_consent_at': null,
          'site_count': 1,
          'member_count': 3,
          'sites': [siteJson()],
          'created_at': '2026-03-01T08:00:00Z',
        }),
      );
      expect(organisation.id, 'org-1');
      expect(organisation.name, 'Example organisation');
      expect(organisation.role, Role.owner);
      expect(organisation.facesEnabled, isTrue);
    });
  });
}
