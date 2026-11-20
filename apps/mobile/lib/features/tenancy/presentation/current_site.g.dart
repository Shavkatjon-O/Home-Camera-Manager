// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_site.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads the organisations of the signed-in user.

@ProviderFor(organisations)
final organisationsProvider = OrganisationsProvider._();

/// Loads the organisations of the signed-in user.

final class OrganisationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Organisation>>,
          List<Organisation>,
          FutureOr<List<Organisation>>
        >
    with $FutureModifier<List<Organisation>>, $FutureProvider<List<Organisation>> {
  /// Loads the organisations of the signed-in user.
  OrganisationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'organisationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$organisationsHash();

  @$internal
  @override
  $FutureProviderElement<List<Organisation>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Organisation>> create(Ref ref) {
    return organisations(ref);
  }
}

String _$organisationsHash() => r'6c17ffdf549a77d07330ea29413e6e95d6191952';

/// Loads the sites of every organisation of the user.

@ProviderFor(allSites)
final allSitesProvider = AllSitesProvider._();

/// Loads the sites of every organisation of the user.

final class AllSitesProvider
    extends $FunctionalProvider<AsyncValue<List<Site>>, List<Site>, FutureOr<List<Site>>>
    with $FutureModifier<List<Site>>, $FutureProvider<List<Site>> {
  /// Loads the sites of every organisation of the user.
  AllSitesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allSitesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allSitesHash();

  @$internal
  @override
  $FutureProviderElement<List<Site>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Site>> create(Ref ref) {
    return allSites(ref);
  }
}

String _$allSitesHash() => r'1d09b3deabee6fcede9fab00e23f0ea239031c74';

/// Holds the id of the site the user chose and remembers it.

@ProviderFor(SelectedSite)
final selectedSiteProvider = SelectedSiteProvider._();

/// Holds the id of the site the user chose and remembers it.
final class SelectedSiteProvider extends $NotifierProvider<SelectedSite, String?> {
  /// Holds the id of the site the user chose and remembers it.
  SelectedSiteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedSiteProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedSiteHash();

  @$internal
  @override
  SelectedSite create() => SelectedSite();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<String?>(value));
  }
}

String _$selectedSiteHash() => r'f4bd19f105859065e2b74b75a60d06d00aa129c1';

/// Holds the id of the site the user chose and remembers it.

abstract class _$SelectedSite extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<AnyNotifier<String?, String?>, String?, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

/// Resolves the site in use, or null when the user has no site.

@ProviderFor(currentSite)
final currentSiteProvider = CurrentSiteProvider._();

/// Resolves the site in use, or null when the user has no site.

final class CurrentSiteProvider
    extends $FunctionalProvider<AsyncValue<SiteContext?>, SiteContext?, FutureOr<SiteContext?>>
    with $FutureModifier<SiteContext?>, $FutureProvider<SiteContext?> {
  /// Resolves the site in use, or null when the user has no site.
  CurrentSiteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentSiteProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentSiteHash();

  @$internal
  @override
  $FutureProviderElement<SiteContext?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SiteContext?> create(Ref ref) {
    return currentSite(ref);
  }
}

String _$currentSiteHash() => r'3be49ce7d132a0d238a1d9dda9a29465c6fd9968';
