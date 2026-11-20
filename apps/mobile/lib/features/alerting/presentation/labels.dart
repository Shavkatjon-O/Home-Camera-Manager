import 'package:flutter/material.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/features/alerting/domain/models.dart';

extension AlertingLabels on AppLocalizations {
  String arm(ArmMode mode) => switch (mode) {
    ArmMode.disarmed => armDisarmed,
    ArmMode.home => armHome,
    ArmMode.away => armAway,
    ArmMode.schedule => armSchedule,
  };

  String armBody(ArmMode mode) => switch (mode) {
    ArmMode.disarmed => armDisarmedBody,
    ArmMode.home => armHomeBody,
    ArmMode.away => armAwayBody,
    ArmMode.schedule => armScheduleBody,
  };
}

IconData armIcon(ArmMode mode) => switch (mode) {
  ArmMode.disarmed => Icons.shield_outlined,
  ArmMode.home => Icons.home_outlined,
  ArmMode.away => Icons.directions_walk_rounded,
  ArmMode.schedule => Icons.schedule_rounded,
};
