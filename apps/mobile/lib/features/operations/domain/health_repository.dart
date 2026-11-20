import 'package:smart_surveillance/features/operations/domain/models.dart';

/// Reads the health of a site's connectors and cameras.
abstract interface class HealthRepository {
  /// Returns the health report of the site [siteId].
  Future<HealthReport> health(String siteId);
}
