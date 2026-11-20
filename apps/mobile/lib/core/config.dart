import 'package:flutter/services.dart';
enum BackendMode { fake, api }

class AppConfig {
  const AppConfig({required this.mode, required this.apiUrl, required this.flavor});

  final BackendMode mode;
  final String apiUrl;
  final String flavor;

  static const defaultApiUrl = String.fromEnvironment('SSS_API_URL', defaultValue: 'http://10.0.2.2:8810');

  factory AppConfig.fromEnvironment() => AppConfig(
    mode: const String.fromEnvironment('SSS_BACKEND', defaultValue: 'fake') == 'api' ? BackendMode.api : BackendMode.fake,
    apiUrl: defaultApiUrl,
    flavor: appFlavor ?? 'foss',
  );

  bool get play => flavor == 'play';
}
