import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/features/analytics/domain/models.dart';

extension AnalyticsLabels on AppLocalizations {
  String profile(Profile profile) => switch (profile) {
    Profile.perimeter => profilePerimeter,
    Profile.vehicle => profileVehicle,
    Profile.identity => profileIdentity,
    Profile.tamper => profileTamper,
  };

  String preset(AnalyticsPreset preset) => switch (preset) {
    AnalyticsPreset.perimeter => presetPerimeter,
    AnalyticsPreset.entrance => presetEntrance,
    AnalyticsPreset.counting => presetCounting,
    AnalyticsPreset.tamperOnly => presetTamper,
  };

  String presetBody(AnalyticsPreset preset) => switch (preset) {
    AnalyticsPreset.perimeter => presetPerimeterBody,
    AnalyticsPreset.entrance => presetEntranceBody,
    AnalyticsPreset.counting => presetCountingBody,
    AnalyticsPreset.tamperOnly => presetTamperBody,
  };

  String alertMode(AlertMode mode) => switch (mode) {
    AlertMode.off => editorAlertOff,
    AlertMode.always => editorAlertAlways,
    AlertMode.schedule => editorAlertSchedule,
  };

  String animalMode(AnimalMode mode) => switch (mode) {
    AnimalMode.include => editorAnimalsInclude,
    AnimalMode.record => editorAnimalsRecord,
    AnimalMode.exclude => editorAnimalsExclude,
  };

  String direction(LineDirection direction) => switch (direction) {
    LineDirection.inward => editorDirectionIn,
    LineDirection.outward => editorDirectionOut,
    LineDirection.both => editorDirectionBoth,
  };
}
