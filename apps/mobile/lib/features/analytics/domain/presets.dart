import 'dart:ui';

import 'package:smart_surveillance/features/analytics/domain/models.dart';
import 'package:smart_surveillance/features/devices/domain/models.dart';

/// What applying a preset to a view changes.
class PresetPlan {
  /// Creates a plan.
  const PresetPlan({required this.view, required this.zones, required this.lines});

  /// The view with the preset's profile and features.
  final AnalyticsView view;

  /// The zones the view gets.
  final List<Zone> zones;

  /// The lines the view gets.
  final List<Line> lines;
}

/// Alerts for people and cars between 22:00 and 07:00.
const nightAlerts = AlertPolicy(
  mode: AlertMode.schedule,
  schedule: [TimeWindow(start: '22:00', end: '07:00')],
  labels: ['person', 'car'],
);

/// Builds what [preset] does to [view], naming new shapes [zoneName] and [lineName].
PresetPlan presetPlan(
  AnalyticsPreset preset,
  AnalyticsView view, {
  String zoneName = 'Area',
  String lineName = 'Entrance',
}) {
  switch (preset) {
    case AnalyticsPreset.perimeter:
      return PresetPlan(
        view: view.copyWith(
          enabled: true,
          profile: Profile.perimeter,
          tamper: true,
          stream: StreamQuality.sub,
        ),
        zones: [
          Zone(
            name: zoneName,
            polygon: const [],
            wholeView: true,
            labels: const ['person', 'car', 'truck', 'dog'],
            loiterSeconds: 120,
            alert: nightAlerts,
          ),
        ],
        lines: const [],
      );
    case AnalyticsPreset.entrance:
      return PresetPlan(
        view: view.copyWith(
          enabled: true,
          profile: Profile.perimeter,
          tamper: true,
          appearance: true,
        ),
        zones: const [],
        lines: [
          Line(
            name: lineName,
            a: const Offset(0.15, 0.7),
            b: const Offset(0.85, 0.7),
            direction: LineDirection.both,
            labels: const ['person'],
            alert: nightAlerts.copyWith(labels: const ['person']),
          ),
        ],
      );
    case AnalyticsPreset.counting:
      return PresetPlan(
        view: view.copyWith(enabled: true, profile: Profile.perimeter, tamper: true),
        zones: const [],
        lines: [
          Line(
            name: lineName,
            a: const Offset(0.1, 0.65),
            b: const Offset(0.9, 0.65),
            direction: LineDirection.both,
            labels: const ['person'],
            alert: const AlertPolicy(mode: AlertMode.off),
          ),
        ],
      );
    case AnalyticsPreset.tamperOnly:
      return PresetPlan(
        view: view.copyWith(
          enabled: true,
          profile: Profile.tamper,
          tamper: true,
          faces: false,
          appearance: false,
          falls: false,
          plates: false,
        ),
        zones: const [],
        lines: const [],
      );
  }
}
