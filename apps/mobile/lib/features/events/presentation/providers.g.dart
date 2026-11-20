// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(todayCounts)
final todayCountsProvider = TodayCountsFamily._();

final class TodayCountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<EventCounts>,
          EventCounts,
          FutureOr<EventCounts>
        >
    with $FutureModifier<EventCounts>, $FutureProvider<EventCounts> {
  TodayCountsProvider._({
    required TodayCountsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'todayCountsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$todayCountsHash();

  @override
  String toString() {
    return r'todayCountsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<EventCounts> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<EventCounts> create(Ref ref) {
    final argument = this.argument as String;
    return todayCounts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TodayCountsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$todayCountsHash() => r'689cdd2de3333d08a8f230f962897d604b6ef5f9';

final class TodayCountsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<EventCounts>, String> {
  TodayCountsFamily._()
    : super(
        retry: null,
        name: r'todayCountsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TodayCountsProvider call(String siteId) =>
      TodayCountsProvider._(argument: siteId, from: this);

  @override
  String toString() => r'todayCountsProvider';
}

@ProviderFor(recentEvents)
final recentEventsProvider = RecentEventsFamily._();

final class RecentEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CameraEvent>>,
          List<CameraEvent>,
          FutureOr<List<CameraEvent>>
        >
    with
        $FutureModifier<List<CameraEvent>>,
        $FutureProvider<List<CameraEvent>> {
  RecentEventsProvider._({
    required RecentEventsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'recentEventsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recentEventsHash();

  @override
  String toString() {
    return r'recentEventsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CameraEvent>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CameraEvent>> create(Ref ref) {
    final argument = this.argument as String;
    return recentEvents(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecentEventsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recentEventsHash() => r'7ef45b63fde96349ea9673a9d4c3b0f924d72016';

final class RecentEventsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<CameraEvent>>, String> {
  RecentEventsFamily._()
    : super(
        retry: null,
        name: r'recentEventsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RecentEventsProvider call(String siteId) =>
      RecentEventsProvider._(argument: siteId, from: this);

  @override
  String toString() => r'recentEventsProvider';
}

@ProviderFor(liveUpdates)
final liveUpdatesProvider = LiveUpdatesFamily._();

final class LiveUpdatesProvider
    extends
        $FunctionalProvider<
          AsyncValue<LiveUpdate>,
          LiveUpdate,
          Stream<LiveUpdate>
        >
    with $FutureModifier<LiveUpdate>, $StreamProvider<LiveUpdate> {
  LiveUpdatesProvider._({
    required LiveUpdatesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'liveUpdatesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$liveUpdatesHash();

  @override
  String toString() {
    return r'liveUpdatesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<LiveUpdate> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<LiveUpdate> create(Ref ref) {
    final argument = this.argument as String;
    return liveUpdates(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LiveUpdatesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$liveUpdatesHash() => r'2636b80ae12cd6c66af8d955df90afa488efe2f3';

final class LiveUpdatesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<LiveUpdate>, String> {
  LiveUpdatesFamily._()
    : super(
        retry: null,
        name: r'liveUpdatesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LiveUpdatesProvider call(String siteId) =>
      LiveUpdatesProvider._(argument: siteId, from: this);

  @override
  String toString() => r'liveUpdatesProvider';
}
