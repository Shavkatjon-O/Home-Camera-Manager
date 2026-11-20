import 'package:flutter/material.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/features/tenancy/domain/models.dart';

extension TenancyLabels on AppLocalizations {
  String siteKind(SiteKind kind) => switch (kind) {
    SiteKind.home => siteKindHome,
    SiteKind.store => siteKindStore,
    SiteKind.office => siteKindOffice,
    SiteKind.warehouse => siteKindWarehouse,
    SiteKind.other => siteKindOther,
  };

  String role(Role role) => switch (role) {
    Role.owner => roleOwner,
    Role.admin => roleAdmin,
    Role.operator => roleOperator,
    Role.viewer => roleViewer,
  };

  String roleBody(Role role) => switch (role) {
    Role.owner => roleOwnerBody,
    Role.admin => roleAdminBody,
    Role.operator => roleOperatorBody,
    Role.viewer => roleViewerBody,
  };
}

IconData siteKindIcon(SiteKind kind) => switch (kind) {
  SiteKind.home => Icons.home_outlined,
  SiteKind.store => Icons.storefront_outlined,
  SiteKind.office => Icons.business_outlined,
  SiteKind.warehouse => Icons.warehouse_outlined,
  SiteKind.other => Icons.place_outlined,
};
