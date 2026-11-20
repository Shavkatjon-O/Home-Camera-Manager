import 'package:flutter/material.dart';

import '../data/models/account.dart';
import '../data/models/analytics.dart';
import '../data/models/event.dart';
import '../data/repositories.dart';
import '../l10n/l10n.dart';

extension Labels on AppLocalizations {
  String failure(Object error) {
    if (error is! ApiFailure) return errorUnknown;
    return switch (error.kind) {
      FailureKind.network => errorNetwork,
      FailureKind.unauthorised => errorUnauthorised,
      FailureKind.forbidden => errorForbidden,
      FailureKind.notFound => errorNotFound,
      FailureKind.conflict => errorConflict,
      FailureKind.invalid => errorInvalid,
      FailureKind.unverified => errorUnauthorised,
      FailureKind.expired => errorExpired,
      FailureKind.server => errorServer,
      FailureKind.unknown => errorUnknown,
    };
  }

  String siteKind(SiteKind kind) => switch (kind) {
    SiteKind.home => siteKindHome,
    SiteKind.store => siteKindStore,
    SiteKind.office => siteKindOffice,
    SiteKind.warehouse => siteKindWarehouse,
    SiteKind.other => siteKindOther,
  };

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

  String role(Role role) => switch (role) {
    Role.owner => roleOwner,
    Role.admin => roleAdmin,
    Role.operator => roleOperator,
    Role.viewer => roleViewer,
  };

  String roleBody(Role role) => switch (role) {
    Role.owner => roleOwnerBody,
    Role.admin => roleAdminBody,
    Role.operator => roleOperatorBody,
    Role.viewer => roleViewerBody,
  };

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

  String kind(EventKind kind) => switch (kind) {
    EventKind.motion => kindMotion,
    EventKind.person => kindPerson,
    EventKind.vehicle => kindVehicle,
    EventKind.intrusion => kindIntrusion,
    EventKind.lineCrossing => kindLineCrossing,
    EventKind.loitering => kindLoitering,
    EventKind.crowd => kindCrowd,
    EventKind.faceKnown => kindFaceKnown,
    EventKind.faceUnknown => kindFaceUnknown,
    EventKind.tamper => kindTamper,
    EventKind.storage => kindStorage,
    EventKind.reboot => kindReboot,
    EventKind.animal => kindAnimal,
    EventKind.objectLeft => kindObjectLeft,
    EventKind.objectTaken => kindObjectTaken,
    EventKind.fall => kindFall,
  };

  String label(String? label) => switch (label) {
    'person' => labelPerson,
    'car' => labelCar,
    'truck' => labelTruck,
    'bus' => labelBus,
    'motorcycle' => labelMotorcycle,
    'bicycle' => labelBicycle,
    'dog' => labelDog,
    'cat' => labelCat,
    'bird' => labelBird,
    'backpack' => labelBackpack,
    'handbag' => labelHandbag,
    'suitcase' => labelSuitcase,
    'vehicle' => labelVehicle,
    'animal' => labelAnimal,
    null => labelSomething,
    _ => label[0].toUpperCase() + label.substring(1).replaceAll('_', ' '),
  };

  String tamper(String? label) => switch (label) {
    'covered' => tamperCovered,
    'blurred' => tamperBlurred,
    'dark' => tamperDark,
    'moved' => tamperMoved,
    _ => tamperDisturbed,
  };

  String eventTitle(CameraEvent event) {
    final camera = event.cameraName;
    final what = label(event.label);
    final zone = event.zoneName;
    final line = event.lineName;
    return switch (event.kind) {
      EventKind.motion => titleMotion(camera),
      EventKind.person => titlePerson(camera),
      EventKind.vehicle => titleVehicle(event.label == null ? labelVehicle : what, camera),
      EventKind.intrusion => zone != null ? titleIntrusion(what, zone) : '${kindIntrusion}, $camera',
      EventKind.lineCrossing => line != null ? titleLineCrossing(what, line) : '${kindLineCrossing}, $camera',
      EventKind.loitering => zone != null ? titleLoitering(what, zone) : '${kindLoitering}, $camera',
      EventKind.crowd => zone != null ? titleCrowd(zone) : '${kindCrowd}, $camera',
      EventKind.faceKnown => titleFaceKnown(event.face?.personName ?? kindFaceKnown),
      EventKind.faceUnknown => titleFaceUnknown(event.face?.clusterLabel ?? kindFaceUnknown),
      EventKind.tamper => titleTamper(camera, tamper(event.label)),
      EventKind.animal => titleAnimal(event.label == null ? labelAnimal : what, camera),
      EventKind.objectLeft => titleObjectLeft(event.label == null ? labelObject : what, zone ?? camera),
      EventKind.objectTaken => titleObjectTaken(event.label == null ? labelObject : what, zone ?? camera),
      EventKind.fall => titleFall(camera),
      EventKind.storage => titleStorage(camera),
      EventKind.reboot => titleReboot(camera),
    };
  }

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

IconData kindIcon(EventKind kind) => switch (kind) {
  EventKind.motion => Icons.motion_photos_on_outlined,
  EventKind.person => Icons.person_outline_rounded,
  EventKind.vehicle => Icons.directions_car_outlined,
  EventKind.intrusion => Icons.crop_free_rounded,
  EventKind.lineCrossing => Icons.timeline_rounded,
  EventKind.loitering => Icons.hourglass_bottom_rounded,
  EventKind.crowd => Icons.groups_outlined,
  EventKind.faceKnown => Icons.face_retouching_natural_outlined,
  EventKind.faceUnknown => Icons.face_outlined,
  EventKind.tamper => Icons.visibility_off_outlined,
  EventKind.storage => Icons.sd_card_alert_outlined,
  EventKind.reboot => Icons.restart_alt_rounded,
  EventKind.animal => Icons.pets_outlined,
  EventKind.objectLeft => Icons.work_outline_rounded,
  EventKind.objectTaken => Icons.remove_shopping_cart_outlined,
  EventKind.fall => Icons.personal_injury_outlined,
};

IconData siteKindIcon(SiteKind kind) => switch (kind) {
  SiteKind.home => Icons.home_outlined,
  SiteKind.store => Icons.storefront_outlined,
  SiteKind.office => Icons.business_outlined,
  SiteKind.warehouse => Icons.warehouse_outlined,
  SiteKind.other => Icons.place_outlined,
};

IconData armIcon(ArmMode mode) => switch (mode) {
  ArmMode.disarmed => Icons.shield_outlined,
  ArmMode.home => Icons.home_outlined,
  ArmMode.away => Icons.directions_walk_rounded,
  ArmMode.schedule => Icons.schedule_rounded,
};
