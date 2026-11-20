// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_feed.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the event filter chosen for a site.

@ProviderFor(EventFilterState)
final eventFilterStateProvider = EventFilterStateFamily._();

/// Holds the event filter chosen for a site.
final class EventFilterStateProvider
    extends $NotifierProvider<EventFilterState, EventFilter> {
  /// Holds the event filter chosen for a site.
  EventFilterStateProvider._({
    required EventFilterStateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'eventFilterStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventFilterStateHash();

  @override
  String toString() {
    return r'eventFilterStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EventFilterState create() => EventFilterState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventFilter>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventFilterStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventFilterStateHash() => r'a9e0f6e2b7aa2a09cb658f128da632620d72d8fe';

/// Holds the event filter chosen for a site.

final class EventFilterStateFamily extends $Family
    with
        $ClassFamilyOverride<
          EventFilterState,
          EventFilter,
          EventFilter,
          EventFilter,
          String
        > {
  EventFilterStateFamily._()
    : super(
        retry: null,
        name: r'eventFilterStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Holds the event filter chosen for a site.

  EventFilterStateProvider call(String siteId) =>
      EventFilterStateProvider._(argument: siteId, from: this);

  @override
  String toString() => r'eventFilterStateProvider';
}

/// Holds the event filter chosen for a site.

abstract class _$EventFilterState extends $Notifier<EventFilter> {
  late final _$args = ref.$arg as String;
  String get siteId => _$args;

  EventFilter build(String siteId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<EventFilter, EventFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EventFilter, EventFilter>,
              EventFilter,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// Loads and updates the paged list of events at a site for the current filter.

@ProviderFor(EventFeed)
final eventFeedProvider = EventFeedFamily._();

/// Loads and updates the paged list of events at a site for the current filter.
final class EventFeedProvider
    extends $AsyncNotifierProvider<EventFeed, FeedState> {
  /// Loads and updates the paged list of events at a site for the current filter.
  EventFeedProvider._({
    required EventFeedFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'eventFeedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventFeedHash();

  @override
  String toString() {
    return r'eventFeedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EventFeed create() => EventFeed();

  @override
  bool operator ==(Object other) {
    return other is EventFeedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventFeedHash() => r'8bf2169410341291c1d6bb5de657ee39a89a68e7';

/// Loads and updates the paged list of events at a site for the current filter.

final class EventFeedFamily extends $Family
    with
        $ClassFamilyOverride<
          EventFeed,
          AsyncValue<FeedState>,
          FeedState,
          FutureOr<FeedState>,
          String
        > {
  EventFeedFamily._()
    : super(
        retry: null,
        name: r'eventFeedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Loads and updates the paged list of events at a site for the current filter.

  EventFeedProvider call(String siteId) =>
      EventFeedProvider._(argument: siteId, from: this);

  @override
  String toString() => r'eventFeedProvider';
}

/// Loads and updates the paged list of events at a site for the current filter.

abstract class _$EventFeed extends $AsyncNotifier<FeedState> {
  late final _$args = ref.$arg as String;
  String get siteId => _$args;

  FutureOr<FeedState> build(String siteId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<FeedState>, FeedState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<FeedState>, FeedState>,
              AsyncValue<FeedState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
