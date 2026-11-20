// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads the analytics views of the site [siteId].

@ProviderFor(views)
final viewsProvider = ViewsFamily._();

/// Loads the analytics views of the site [siteId].

final class ViewsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AnalyticsView>>,
          List<AnalyticsView>,
          FutureOr<List<AnalyticsView>>
        >
    with
        $FutureModifier<List<AnalyticsView>>,
        $FutureProvider<List<AnalyticsView>> {
  /// Loads the analytics views of the site [siteId].
  ViewsProvider._({
    required ViewsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'viewsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$viewsHash();

  @override
  String toString() {
    return r'viewsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<AnalyticsView>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AnalyticsView>> create(Ref ref) {
    final argument = this.argument as String;
    return views(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ViewsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$viewsHash() => r'1a50b884766edd03c6bb413bce9fffd85a759d02';

/// Loads the analytics views of the site [siteId].

final class ViewsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<AnalyticsView>>, String> {
  ViewsFamily._()
    : super(
        retry: null,
        name: r'viewsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Loads the analytics views of the site [siteId].

  ViewsProvider call(String siteId) =>
      ViewsProvider._(argument: siteId, from: this);

  @override
  String toString() => r'viewsProvider';
}
