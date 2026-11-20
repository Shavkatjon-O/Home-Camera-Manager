import '../core/config.dart';
import '../core/preferences.dart';
import 'api/api_backend.dart';
import 'fake/fake_backend.dart';
import 'repositories.dart';

Future<Backend> createBackend(AppConfig config, Preferences preferences) async {
  if (config.mode == BackendMode.fake) return fakeBackend(FakeStore());
  return ApiBackend.create(baseUrl: preferences.serverUrl ?? config.apiUrl);
}
