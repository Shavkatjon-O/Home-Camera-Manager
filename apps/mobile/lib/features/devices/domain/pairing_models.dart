import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_surveillance/features/devices/domain/models.dart';

part 'pairing_models.freezed.dart';
/// What a pairing flow sets up.
enum PairingTarget {
  /// A connector.
  connector,
  /// A camera.
  camera,
}

/// How a pairing attempt ended.
enum PairingOutcome {
  /// Pairing worked.
  success,
  /// Pairing failed.
  failure,
  /// The user stopped pairing.
  cancelled,
}

/// One pairing method offered to the user with its availability.
@freezed
abstract class PairingCatalogEntry with _$PairingCatalogEntry {
  /// Creates an entry for the method [id] shown at position [rank].
  const factory PairingCatalogEntry({
    required String id,
    required int rank,
    @Default(true) bool available,
    @Default(false) bool recommended,
    String? reason,
  }) = _PairingCatalogEntry;
}

/// What a scanned camera label reveals about the camera.
@freezed
abstract class LabelIdentity with _$LabelIdentity {
  /// Creates an identity found through the [method].
  const factory LabelIdentity({
    required String method,
    CameraBrand? brand,
    String? manufacturer,
    String? model,
    String? serial,
    String? discoveredId,
    String? host,
    int? port,
  }) = _LabelIdentity;
}

/// One channel of a network video recorder.
@freezed
abstract class NvrChannel with _$NvrChannel {
  /// Creates the channel numbered [index] named [name].
  const factory NvrChannel({
    required int index,
    required String name,
    @Default(true) bool online,
    String? cameraId,
  }) = _NvrChannel;
}

/// The outcome of one pairing attempt, sent for diagnostics.
@freezed
abstract class PairingReport with _$PairingReport {
  /// Creates a report of [method] for the site [siteId] that ended in [outcome].
  const factory PairingReport({
    required String method,
    required String siteId,
    required String step,
    required PairingOutcome outcome,
    String? errorCode,
    required int durationMs,
  }) = _PairingReport;
}

/// A connector found on the local network during setup.
@freezed
abstract class FoundConnector with _$FoundConnector {
  /// Creates a found connector named [name] at [host] and [port].
  const factory FoundConnector({
    required String name,
    required String host,
    required int port,
    String? code,
    String? version,
  }) = _FoundConnector;
}
