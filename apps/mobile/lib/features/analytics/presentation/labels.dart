import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/features/analytics/domain/models.dart';

/// Localized names and descriptions for the analytics enums.
extension AnalyticsLabels on AppLocalizations {
  /// Returns the localized name of [profile].
  String profile(Profile profile) => switch (profile) {
    Profile.perimeter => profilePerimeter,
    Profile.vehicle => profileVehicle,
    Profile.identity => profileIdentity,
    Profile.tamper => profileTamper,
  };

  /// Returns the localized name of [preset].
  String preset(AnalyticsPreset preset) => switch (preset) {
    AnalyticsPreset.perimeter => presetPerimeter,
    AnalyticsPreset.entrance => presetEntrance,
    AnalyticsPreset.counting => presetCounting,
    AnalyticsPreset.tamperOnly => presetTamper,
  };

  /// Returns the localized description of [preset].
  String presetBody(AnalyticsPreset preset) => switch (preset) {
    AnalyticsPreset.perimeter => presetPerimeterBody,
    AnalyticsPreset.entrance => presetEntranceBody,
    AnalyticsPreset.counting => presetCountingBody,
    AnalyticsPreset.tamperOnly => presetTamperBody,
  };

  /// Returns the localized name of [mode].
  String alertMode(AlertMode mode) => switch (mode) {
    AlertMode.off => editorAlertOff,
    AlertMode.always => editorAlertAlways,
    AlertMode.schedule => editorAlertSchedule,
  };

  /// Returns the localized name of [mode].
  String animalMode(AnimalMode mode) => switch (mode) {
    AnimalMode.include => editorAnimalsInclude,
    AnimalMode.record => editorAnimalsRecord,
    AnimalMode.exclude => editorAnimalsExclude,
  };

  /// Returns the localized name of [direction].
  String direction(LineDirection direction) => switch (direction) {
    LineDirection.inward => editorDirectionIn,
    LineDirection.outward => editorDirectionOut,
    LineDirection.both => editorDirectionBoth,
  };
}
