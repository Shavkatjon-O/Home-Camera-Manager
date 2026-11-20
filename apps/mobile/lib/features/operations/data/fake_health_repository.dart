import 'dart:async';

import 'package:smart_surveillance/app/demo/fake_store.dart';
import 'package:smart_surveillance/features/operations/domain/health_repository.dart';
import 'package:smart_surveillance/features/operations/domain/models.dart';
/// A health repository that returns sample data from a [FakeStore].
class FakeHealthRepository implements HealthRepository {
  /// Creates a repository that reads from [store].
  FakeHealthRepository(this.store);

  /// The shared fake data store.
  final FakeStore store;

  @override
  Future<HealthReport> health(String siteId) => store.delay(() => store.data.health(siteId));
}
