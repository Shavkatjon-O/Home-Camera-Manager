// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appearance.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The notifier holding the chosen theme mode and language, persisted in preferences.

@ProviderFor(AppearanceSettings)
final appearanceSettingsProvider = AppearanceSettingsProvider._();

/// The notifier holding the chosen theme mode and language, persisted in preferences.
final class AppearanceSettingsProvider
    extends
        $NotifierProvider<
          AppearanceSettings,
          ({Locale? locale, ThemeMode theme})
        > {
  /// The notifier holding the chosen theme mode and language, persisted in preferences.
  AppearanceSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appearanceSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appearanceSettingsHash();

  @$internal
  @override
  AppearanceSettings create() => AppearanceSettings();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(({Locale? locale, ThemeMode theme}) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<({Locale? locale, ThemeMode theme})>(
        value,
      ),
    );
  }
}

String _$appearanceSettingsHash() =>
    r'23d5f4601fbe10a14a736b7b754f3a62648e1d9d';

/// The notifier holding the chosen theme mode and language, persisted in preferences.

abstract class _$AppearanceSettings
    extends $Notifier<({Locale? locale, ThemeMode theme})> {
  ({Locale? locale, ThemeMode theme}) build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              ({Locale? locale, ThemeMode theme}),
              ({Locale? locale, ThemeMode theme})
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                ({Locale? locale, ThemeMode theme}),
                ({Locale? locale, ThemeMode theme})
              >,
              ({Locale? locale, ThemeMode theme}),
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
