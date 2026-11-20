// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(areas)
final areasProvider = AreasFamily._();

final class AreasProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Area>>,
          List<Area>,
          FutureOr<List<Area>>
        >
    with $FutureModifier<List<Area>>, $FutureProvider<List<Area>> {
  AreasProvider._({
    required AreasFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'areasProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$areasHash();

  @override
  String toString() {
    return r'areasProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Area>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Area>> create(Ref ref) {
    final argument = this.argument as String;
    return areas(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AreasProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$areasHash() => r'ba35ddebc24110812b5ea8f9f493c5f1422f9848';

final class AreasFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Area>>, String> {
  AreasFamily._()
    : super(
        retry: null,
        name: r'areasProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AreasProvider call(String siteId) =>
      AreasProvider._(argument: siteId, from: this);

  @override
  String toString() => r'areasProvider';
}

@ProviderFor(todayReport)
final todayReportProvider = TodayReportFamily._();

final class TodayReportProvider
    extends
        $FunctionalProvider<
          AsyncValue<CountsReport>,
          CountsReport,
          FutureOr<CountsReport>
        >
    with $FutureModifier<CountsReport>, $FutureProvider<CountsReport> {
  TodayReportProvider._({
    required TodayReportFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'todayReportProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$todayReportHash();

  @override
  String toString() {
    return r'todayReportProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CountsReport> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CountsReport> create(Ref ref) {
    final argument = this.argument as String;
    return todayReport(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TodayReportProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$todayReportHash() => r'fe82683518c8642a384b3a0e758c6165f1044c4e';

final class TodayReportFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CountsReport>, String> {
  TodayReportFamily._()
    : super(
        retry: null,
        name: r'todayReportProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TodayReportProvider call(String siteId) =>
      TodayReportProvider._(argument: siteId, from: this);

  @override
  String toString() => r'todayReportProvider';
}
