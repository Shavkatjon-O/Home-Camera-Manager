import 'package:flutter/services.dart';

/// Which backend the app talks to.
enum BackendMode {
  /// The in-memory simulated site, with no server.
  fake,

  /// The server at [AppConfig.apiUrl].
  api,
}

/// The build's configuration, read from compile-time defines and the Android flavor.
class AppConfig {
  /// Creates a configuration.
  const AppConfig({required this.mode, required this.apiUrl, required this.flavor});

  /// Which backend the app talks to.
  final BackendMode mode;

  /// The server address used until the user enters another one at sign in.
  final String apiUrl;

  /// The Android flavor, foss or play.
  final String flavor;

  /// The default server address, set with --dart-define=SSS_API_URL; the
  /// default reaches the development kit on the host from the Android emulator.
  static const defaultApiUrl = String.fromEnvironment(
    'SSS_API_URL',
    defaultValue: 'http://10.0.2.2:18700',
  );

  /// Reads the configuration from --dart-define=SSS_BACKEND=fake|api and the flavor.
  factory AppConfig.fromEnvironment() => AppConfig(
    mode: const String.fromEnvironment('SSS_BACKEND', defaultValue: 'fake') == 'api'
        ? BackendMode.api
        : BackendMode.fake,
    apiUrl: defaultApiUrl,
    flavor: appFlavor ?? 'foss',
  );

  /// Whether this is the Play build, which has Firebase push.
  bool get play => flavor == 'play';
}
