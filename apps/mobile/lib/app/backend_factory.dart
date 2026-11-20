import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/demo/fake_backend.dart';
import 'package:smart_surveillance/app/demo/fake_store.dart';
import 'package:smart_surveillance/core/config.dart';
import 'package:smart_surveillance/core/storage/preferences.dart';

/// Builds the backend the app talks to.
Future<Backend> createBackend(AppConfig config, Preferences preferences) async => fakeBackend(FakeStore());
