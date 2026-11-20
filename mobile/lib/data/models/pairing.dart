import 'package:freezed_annotation/freezed_annotation.dart';

import 'camera.dart';

part 'pairing.freezed.dart';

enum PairingTarget { connector, camera }

enum PairingOutcome { success, failure, cancelled }

@freezed
abstract class PairingCatalogEntry with _$PairingCatalogEntry {
  const factory PairingCatalogEntry({
    required String id,
    required int rank,
    @Default(true) bool available,
    @Default(false) bool recommended,
    String? reason,
  }) = _PairingCatalogEntry;
}

@freezed
abstract class LabelIdentity with _$LabelIdentity {
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

@freezed
abstract class NvrChannel with _$NvrChannel {
  const factory NvrChannel({
    required int index,
    required String name,
    @Default(true) bool online,
    String? cameraId,
  }) = _NvrChannel;
}

@freezed
abstract class PairingReport with _$PairingReport {
  const factory PairingReport({
    required String method,
    required String siteId,
    required String step,
    required PairingOutcome outcome,
    String? errorCode,
    required int durationMs,
  }) = _PairingReport;
}

@freezed
abstract class FoundConnector with _$FoundConnector {
  const factory FoundConnector({
    required String name,
    required String host,
    required int port,
    String? code,
    String? version,
  }) = _FoundConnector;
}
