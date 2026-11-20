// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads the cameras of the site [siteId].

@ProviderFor(cameras)
final camerasProvider = CamerasFamily._();

/// Loads the cameras of the site [siteId].

final class CamerasProvider
    extends $FunctionalProvider<AsyncValue<List<Camera>>, List<Camera>, FutureOr<List<Camera>>>
    with $FutureModifier<List<Camera>>, $FutureProvider<List<Camera>> {
  /// Loads the cameras of the site [siteId].
  CamerasProvider._({required CamerasFamily super.from, required String super.argument})
    : super(
        retry: null,
        name: r'camerasProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$camerasHash();

  @override
  String toString() {
    return r'camerasProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Camera>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Camera>> create(Ref ref) {
    final argument = this.argument as String;
    return cameras(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CamerasProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$camerasHash() => r'6578bf85c7512468d8c003f9820e4866072930e5';

/// Loads the cameras of the site [siteId].

final class CamerasFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Camera>>, String> {
  CamerasFamily._()
    : super(
        retry: null,
        name: r'camerasProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Loads the cameras of the site [siteId].

  CamerasProvider call(String siteId) => CamerasProvider._(argument: siteId, from: this);

  @override
  String toString() => r'camerasProvider';
}

/// Builds one tile per lens of every enabled camera of [siteId], with its saved view.

@ProviderFor(tiles)
final tilesProvider = TilesFamily._();

/// Builds one tile per lens of every enabled camera of [siteId], with its saved view.

final class TilesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CameraTile>>,
          List<CameraTile>,
          FutureOr<List<CameraTile>>
        >
    with $FutureModifier<List<CameraTile>>, $FutureProvider<List<CameraTile>> {
  /// Builds one tile per lens of every enabled camera of [siteId], with its saved view.
  TilesProvider._({required TilesFamily super.from, required String super.argument})
    : super(
        retry: null,
        name: r'tilesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tilesHash();

  @override
  String toString() {
    return r'tilesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CameraTile>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<CameraTile>> create(Ref ref) {
    final argument = this.argument as String;
    return tiles(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TilesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tilesHash() => r'cc07b2c5647b26d272ae042c4b52c86f8e1df4b8';

/// Builds one tile per lens of every enabled camera of [siteId], with its saved view.

final class TilesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<CameraTile>>, String> {
  TilesFamily._()
    : super(
        retry: null,
        name: r'tilesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Builds one tile per lens of every enabled camera of [siteId], with its saved view.

  TilesProvider call(String siteId) => TilesProvider._(argument: siteId, from: this);

  @override
  String toString() => r'tilesProvider';
}

/// Loads the connectors of the site [siteId].

@ProviderFor(connectors)
final connectorsProvider = ConnectorsFamily._();

/// Loads the connectors of the site [siteId].

final class ConnectorsProvider
    extends
        $FunctionalProvider<AsyncValue<List<Connector>>, List<Connector>, FutureOr<List<Connector>>>
    with $FutureModifier<List<Connector>>, $FutureProvider<List<Connector>> {
  /// Loads the connectors of the site [siteId].
  ConnectorsProvider._({required ConnectorsFamily super.from, required String super.argument})
    : super(
        retry: null,
        name: r'connectorsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectorsHash();

  @override
  String toString() {
    return r'connectorsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Connector>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Connector>> create(Ref ref) {
    final argument = this.argument as String;
    return connectors(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ConnectorsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$connectorsHash() => r'91f296d8dba4fa8d71ca9f7e87e4d82a509a58fb';

/// Loads the connectors of the site [siteId].

final class ConnectorsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Connector>>, String> {
  ConnectorsFamily._()
    : super(
        retry: null,
        name: r'connectorsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Loads the connectors of the site [siteId].

  ConnectorsProvider call(String siteId) => ConnectorsProvider._(argument: siteId, from: this);

  @override
  String toString() => r'connectorsProvider';
}
