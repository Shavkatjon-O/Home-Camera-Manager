import 'dart:async';

import 'package:smart_surveillance/app/demo/fake_store.dart';
import 'package:smart_surveillance/features/operations/domain/health_repository.dart';
import 'package:smart_surveillance/features/operations/domain/models.dart';
class FakeHealthRepository implements HealthRepository {
  FakeHealthRepository(this.store);

  final FakeStore store;

  @override
  Future<HealthReport> health(String siteId) => store.delay(() => store.data.health(siteId));
}
