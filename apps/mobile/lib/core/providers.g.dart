// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The provider of the app configuration; it is overridden at start-up.

@ProviderFor(config)
final configProvider = ConfigProvider._();

/// The provider of the app configuration; it is overridden at start-up.

final class ConfigProvider
    extends $FunctionalProvider<AppConfig, AppConfig, AppConfig>
    with $Provider<AppConfig> {
  /// The provider of the app configuration; it is overridden at start-up.
  ConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'configProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$configHash();

  @$internal
  @override
  $ProviderElement<AppConfig> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppConfig create(Ref ref) {
    return config(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppConfig>(value),
    );
  }
}

String _$configHash() => r'96ac52638f180eea6a4ad0df195a1f4f5c7f7474';

/// The provider of the stored preferences; it is overridden at start-up.

@ProviderFor(preferences)
final preferencesProvider = PreferencesProvider._();

/// The provider of the stored preferences; it is overridden at start-up.

final class PreferencesProvider
    extends $FunctionalProvider<Preferences, Preferences, Preferences>
    with $Provider<Preferences> {
  /// The provider of the stored preferences; it is overridden at start-up.
  PreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferencesHash();

  @$internal
  @override
  $ProviderElement<Preferences> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Preferences create(Ref ref) {
    return preferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Preferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Preferences>(value),
    );
  }
}

String _$preferencesHash() => r'146aadc563c45847149d6e6b391962ff5b1228eb';

/// The provider of the current time, replaceable in tests.

@ProviderFor(clock)
final clockProvider = ClockProvider._();

/// The provider of the current time, replaceable in tests.

final class ClockProvider
    extends
        $FunctionalProvider<
          DateTime Function(),
          DateTime Function(),
          DateTime Function()
        >
    with $Provider<DateTime Function()> {
  /// The provider of the current time, replaceable in tests.
  ClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clockHash();

  @$internal
  @override
  $ProviderElement<DateTime Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DateTime Function() create(Ref ref) {
    return clock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime Function()>(value),
    );
  }
}

String _$clockHash() => r'3f65ad34ac6fcd532de9004042bdf2ed2bd85b13';
