// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backend.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(backend)
final backendProvider = BackendProvider._();

final class BackendProvider
    extends $FunctionalProvider<Backend, Backend, Backend>
    with $Provider<Backend> {
  BackendProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backendProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backendHash();

  @$internal
  @override
  $ProviderElement<Backend> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Backend create(Ref ref) {
    return backend(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Backend value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Backend>(value),
    );
  }
}

String _$backendHash() => r'7fe43b1e15e6c53f902f4ef6d002d356ed901ecd';
