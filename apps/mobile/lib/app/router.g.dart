// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The deep link saved while signed out, so it can be opened after signing in.

@ProviderFor(PendingLink)
final pendingLinkProvider = PendingLinkProvider._();

/// The deep link saved while signed out, so it can be opened after signing in.
final class PendingLinkProvider extends $NotifierProvider<PendingLink, String?> {
  /// The deep link saved while signed out, so it can be opened after signing in.
  PendingLinkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingLinkProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingLinkHash();

  @$internal
  @override
  PendingLink create() => PendingLink();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<String?>(value));
  }
}

String _$pendingLinkHash() => r'656db4047a66ec52c3524b3fa743dbf98a91e7c8';

/// The deep link saved while signed out, so it can be opened after signing in.

abstract class _$PendingLink extends $Notifier<String?> {
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

/// The provider of the app's router.

@ProviderFor(router)
final routerProvider = RouterProvider._();

/// The provider of the app's router.

final class RouterProvider extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The provider of the app's router.
  RouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routerHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return router(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<GoRouter>(value));
  }
}

String _$routerHash() => r'fad45cca83126db91153fc3253e83d22cda24fe2';
