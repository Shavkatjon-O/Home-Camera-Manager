import 'package:flutter/material.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/features/tenancy/domain/models.dart';

/// Localised labels for sites and roles.
extension TenancyLabels on AppLocalizations {
  /// Returns the name of [kind].
  String siteKind(SiteKind kind) => switch (kind) {
    SiteKind.home => siteKindHome,
    SiteKind.store => siteKindStore,
    SiteKind.office => siteKindOffice,
    SiteKind.warehouse => siteKindWarehouse,
    SiteKind.other => siteKindOther,
  };

  /// Returns the name of [role].
  String role(Role role) => switch (role) {
    Role.owner => roleOwner,
    Role.admin => roleAdmin,
    Role.operator => roleOperator,
    Role.viewer => roleViewer,
  };

  /// Returns the explanation of what [role] may do.
  String roleBody(Role role) => switch (role) {
    Role.owner => roleOwnerBody,
    Role.admin => roleAdminBody,
    Role.operator => roleOperatorBody,
    Role.viewer => roleViewerBody,
  };
}

/// Returns the icon that represents [kind].
IconData siteKindIcon(SiteKind kind) => switch (kind) {
  SiteKind.home => Icons.home_outlined,
  SiteKind.store => Icons.storefront_outlined,
  SiteKind.office => Icons.business_outlined,
  SiteKind.warehouse => Icons.warehouse_outlined,
  SiteKind.other => Icons.place_outlined,
};
