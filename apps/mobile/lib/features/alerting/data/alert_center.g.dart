// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_center.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the alert center for the signed-in backend.

@ProviderFor(alertCenter)
final alertCenterProvider = AlertCenterProvider._();

/// Provides the alert center for the signed-in backend.

final class AlertCenterProvider extends $FunctionalProvider<AlertCenter, AlertCenter, AlertCenter>
    with $Provider<AlertCenter> {
  /// Provides the alert center for the signed-in backend.
  AlertCenterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'alertCenterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$alertCenterHash();

  @$internal
  @override
  $ProviderElement<AlertCenter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AlertCenter create(Ref ref) {
    return alertCenter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AlertCenter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AlertCenter>(value),
    );
  }
}

String _$alertCenterHash() => r'76e5f34ccd8c7f4003e99136cecec0d56369cb77';

/// Provides whether notifications are enabled.

@ProviderFor(notificationsEnabled)
final notificationsEnabledProvider = NotificationsEnabledProvider._();

/// Provides whether notifications are enabled.

final class NotificationsEnabledProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provides whether notifications are enabled.
  NotificationsEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsEnabledProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsEnabledHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return notificationsEnabled(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<bool>(value));
  }
}

String _$notificationsEnabledHash() => r'b7a5fd60d33ebdf3347ee2503e5933fe10c618ba';
