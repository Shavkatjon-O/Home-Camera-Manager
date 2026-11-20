
import 'package:smart_surveillance/features/operations/domain/models.dart';
abstract interface class HealthRepository {
  Future<HealthReport> health(String siteId);
}
