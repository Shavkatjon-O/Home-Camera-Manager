// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Smart Surveillance';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSaved => 'Saved';

  @override
  String get commonDone => 'Done';

  @override
  String get commonNext => 'Next';

  @override
  String get commonBack => 'Back';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonClose => 'Close';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonApply => 'Apply';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonReset => 'Reset';

  @override
  String get commonSkip => 'Skip for now';

  @override
  String get commonAll => 'All';

  @override
  String get commonNone => 'None';

  @override
  String get commonOn => 'On';

  @override
  String get commonOff => 'Off';

  @override
  String get commonBeta => 'Beta';

  @override
  String get commonDemo => 'Demo data';

  @override
  String get commonLoading => 'Loading';

  @override
  String get commonSeeAll => 'See all';

  @override
  String get commonOnline => 'Online';

  @override
  String get commonOffline => 'Offline';

  @override
  String get commonUnknown => 'Unknown';

  @override
  String get commonToday => 'Today';

  @override
  String get commonYesterday => 'Yesterday';

  @override
  String get commonJustNow => 'Just now';

  @override
  String commonMinutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String commonHoursAgo(int count) {
    return '$count h ago';
  }

  @override
  String commonDaysAgo(int count) {
    return '$count d ago';
  }

  @override
  String commonSeconds(int count) {
    return '$count s';
  }

  @override
  String commonMinutesSeconds(int minutes, int seconds) {
    return '$minutes min $seconds s';
  }

  @override
  String commonPercent(String value) {
    return '$value%';
  }

  @override
  String get commonPermissionNeeded => 'Your role does not allow this.';

  @override
  String get errorNetwork =>
      'Cannot reach the server. Check the connection and the server address.';

  @override
  String get errorUnauthorised => 'The email or password is wrong.';

  @override
  String get errorForbidden => 'Your role does not allow this.';

  @override
  String get errorNotFound => 'It is no longer there.';

  @override
  String get errorConflict => 'That already exists.';

  @override
  String get errorInvalid => 'Check the highlighted fields.';

  @override
  String get errorExpired => 'This code has expired. Ask for a new one.';

  @override
  String get errorServer => 'The server had a problem. Try again in a moment.';

  @override
  String get errorUnknown => 'Something went wrong.';

  @override
  String get errorTitle => 'Could not load this';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPassword => 'Password';

  @override
  String get fieldName => 'Your name';

  @override
  String get fieldNewPassword => 'New password';

  @override
  String get fieldCode => 'Code from the email';

  @override
  String get validationEmail => 'Enter a valid email address';

  @override
  String get validationPassword => 'Use at least 8 characters';

  @override
  String get validationRequired => 'Required';

  @override
  String get validationCode => 'Paste the link or the code from the email';

  @override
  String get welcomeTitle => 'Every camera on your site, in your pocket';

  @override
  String get welcomeBody =>
      'Watch live video, get alerts that matter, and count who comes and goes at home, in a store, an office or a warehouse.';

  @override
  String get welcomeCreate => 'Create account';

  @override
  String get welcomeSignIn => 'I have an account';

  @override
  String get welcomeFeatureLive => 'Live video from every camera';

  @override
  String get welcomeFeatureAlerts => 'Alerts for people, vehicles and tampering';

  @override
  String get welcomeFeatureCounts => 'Counts and occupancy by the hour';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get signInSubtitle => 'Welcome back.';

  @override
  String get signInAction => 'Sign in';

  @override
  String get signInForgot => 'Forgot password?';

  @override
  String get signInNoAccount => 'New here? Create an account';

  @override
  String get serverTitle => 'Server';

  @override
  String get serverHint => 'Address of your Smart Surveillance server';

  @override
  String get serverField => 'Server address';

  @override
  String get serverDemo => 'Demo mode shows sample data and needs no server.';

  @override
  String get signUpTitle => 'Create account';

  @override
  String get signUpSubtitle => 'One account for every site you watch.';

  @override
  String get signUpAction => 'Create account';

  @override
  String get signUpTerms =>
      'By creating an account you agree that video from your cameras is processed on the server you connect to.';

  @override
  String get signUpHaveAccount => 'Already have an account? Sign in';

  @override
  String get passwordWeak => 'Weak';

  @override
  String get passwordFair => 'Fair';

  @override
  String get passwordStrong => 'Strong';

  @override
  String get verifyTitle => 'Check your email';

  @override
  String verifyBody(String email) {
    return 'We sent a confirmation link to $email. Open it on this phone, or paste the link or the code from the email here.';
  }

  @override
  String get verifyAction => 'Confirm email';

  @override
  String get verifyResend => 'Send the email again';

  @override
  String get verifyResent => 'A new code is on its way.';

  @override
  String get verifyWrongEmail => 'Use another email';

  @override
  String get forgotTitle => 'Reset password';

  @override
  String get forgotBody => 'Enter your email and we will send a code to set a new password.';

  @override
  String get forgotAction => 'Send code';

  @override
  String get resetTitle => 'Set a new password';

  @override
  String resetBody(String email) {
    return 'Paste the link or the code we sent to $email and choose a new password.';
  }

  @override
  String get resetAction => 'Save password';

  @override
  String get resetDone => 'Password changed. Sign in with the new one.';

  @override
  String get inviteTitle => 'You are invited';

  @override
  String inviteBody(String inviter, String organisation, String role) {
    return '$inviter invited you to $organisation as $role.';
  }

  @override
  String inviteSites(String sites) {
    return 'Sites: $sites';
  }

  @override
  String get inviteAllSites => 'Every site of the organisation';

  @override
  String inviteExpires(String date) {
    return 'This invitation expires $date.';
  }

  @override
  String get inviteAccept => 'Accept invitation';

  @override
  String get inviteSignInFirst => 'Sign in or create an account first, then open the link again.';

  @override
  String inviteAccepted(String organisation) {
    return 'You joined $organisation.';
  }

  @override
  String onboardingStep(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get onboardingSiteTitle => 'Set up your first site';

  @override
  String get onboardingSiteBody =>
      'A site is one place with cameras: your home, a store, an office or a warehouse. You can add more sites later.';

  @override
  String get fieldOrganisation => 'Organisation name';

  @override
  String get fieldOrganisationHint => 'Your family or company';

  @override
  String get fieldSiteName => 'Site name';

  @override
  String get fieldSiteNameHint => 'For example Home or Main street store';

  @override
  String get fieldSiteKind => 'Kind of site';

  @override
  String get fieldTimezone => 'Time zone';

  @override
  String get onboardingConnectorTitle => 'Pair a connector';

  @override
  String get onboardingConnectorBody =>
      'The connector is a small program that runs on any always-on computer at the site, such as a mini PC or a Raspberry Pi. It finds the cameras and connects them securely to the server.';

  @override
  String get onboardingConnectorStep1 => 'Install Docker on a computer that stays on at the site.';

  @override
  String get onboardingConnectorStep2 =>
      'Start the connector with the command from the server documentation.';

  @override
  String get onboardingConnectorStep3 =>
      'The connector shows a QR code and an 8 character code. Scan it or type it here.';

  @override
  String get onboardingScan => 'Scan QR code';

  @override
  String get onboardingTypeCode => 'Type the code';

  @override
  String get fieldConnectorCode => 'Connector code';

  @override
  String get fieldConnectorName => 'Connector name';

  @override
  String get onboardingPair => 'Pair connector';

  @override
  String onboardingPaired(String name, String site) {
    return '$name is paired with $site.';
  }

  @override
  String get scanTitle => 'Scan the connector code';

  @override
  String get scanHint => 'Point the camera at the QR code on the connector screen.';

  @override
  String get scanNoPermission => 'Allow camera access to scan, or type the code instead.';

  @override
  String get scanAllow => 'Allow camera';

  @override
  String get onboardingCamerasTitle => 'Cameras on the network';

  @override
  String get onboardingCamerasBody =>
      'The connector looked for cameras on its network. Choose one to add it.';

  @override
  String get onboardingSearching => 'Looking for cameras';

  @override
  String get onboardingRescan => 'Search again';

  @override
  String get onboardingNoCameras => 'No cameras found yet';

  @override
  String get onboardingNoCamerasBody =>
      'Make sure the cameras are powered and on the same network as the connector, then search again.';

  @override
  String get onboardingAdded => 'Added';

  @override
  String get onboardingAddCamera => 'Add';

  @override
  String get onboardingFinish => 'Finish setup';

  @override
  String get onboardingCameraTitle => 'Add camera';

  @override
  String get onboardingCameraBody =>
      'Enter the login the camera uses for its video. It stays on the connector, encrypted, and never reaches the server.';

  @override
  String get fieldCameraUser => 'Camera username';

  @override
  String get fieldCameraPassword => 'Camera password';

  @override
  String get fieldCameraName => 'Camera name';

  @override
  String get fieldCameraNameHint => 'For example Front door';

  @override
  String get fieldLenses => 'Pictures in one stream';

  @override
  String get lensesOne => 'One picture';

  @override
  String get lensesTwo => 'Two stacked lenses';

  @override
  String get onboardingTest => 'Test the stream';

  @override
  String get onboardingTesting => 'Connecting to the camera';

  @override
  String onboardingTestOk(String codec, int width, int height) {
    return 'Stream works: $codec, $width by $height';
  }

  @override
  String get onboardingTestFailed =>
      'The camera refused the login. Check the username and password.';

  @override
  String get onboardingSaveCamera => 'Save camera';

  @override
  String get onboardingAnalyticsTitle => 'What should this camera watch for?';

  @override
  String onboardingAnalyticsBody(String camera) {
    return 'Pick a starting point for $camera. You can draw zones and lines and change every option later.';
  }

  @override
  String get presetPerimeter => 'Perimeter';

  @override
  String get presetPerimeterBody =>
      'Alerts when people or vehicles enter the picture at night or when you are away.';

  @override
  String get presetEntrance => 'Entrance';

  @override
  String get presetEntranceBody => 'Counts who goes in and out through a door or gate.';

  @override
  String get presetCounting => 'Counting';

  @override
  String get presetCountingBody =>
      'Counts people and occupancy without alerts, for stores and offices.';

  @override
  String get presetTamper => 'Tamper only';

  @override
  String get presetTamperBody =>
      'Only tells you when the camera is covered, blurred, moved or too dark.';

  @override
  String get onboardingNotificationsTitle => 'Get alerts on this phone';

  @override
  String get onboardingNotificationsBody =>
      'Allow notifications so the app can tell you about alerts while it is closed. Notifications carry no pictures; the app fetches them securely when you open one.';

  @override
  String get onboardingNotificationsAllow => 'Allow notifications';

  @override
  String get onboardingDoneTitle => 'Your site is ready';

  @override
  String get onboardingDoneBody =>
      'The cameras are live. Alerts follow the arm mode, which you can change on the Home tab.';

  @override
  String get onboardingOpenHome => 'Open Home';

  @override
  String get navHome => 'Home';

  @override
  String get navLive => 'Live';

  @override
  String get navEvents => 'Events';

  @override
  String get navSearch => 'Search';

  @override
  String get navMore => 'More';

  @override
  String get siteKindHome => 'Home';

  @override
  String get siteKindStore => 'Store';

  @override
  String get siteKindOffice => 'Office';

  @override
  String get siteKindWarehouse => 'Warehouse';

  @override
  String get siteKindOther => 'Other';

  @override
  String get siteSwitcherTitle => 'Sites';

  @override
  String get siteSwitcherAdd => 'Add a site';

  @override
  String siteCameras(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cameras',
      one: '1 camera',
      zero: 'No cameras',
    );
    return '$_temp0';
  }

  @override
  String get armDisarmed => 'Disarmed';

  @override
  String get armHome => 'Home';

  @override
  String get armAway => 'Away';

  @override
  String get armSchedule => 'Schedule';

  @override
  String get armDisarmedBody => 'No alerts. Events are still recorded.';

  @override
  String get armHomeBody => 'Alerts only from zones and lines that alert while you are home.';

  @override
  String get armAwayBody => 'Every zone and line alerts.';

  @override
  String get armScheduleBody => 'Each zone and line alerts on its own schedule.';

  @override
  String get armTitle => 'Arm mode';

  @override
  String armChanged(String mode) {
    return 'Arm mode is now $mode';
  }

  @override
  String get homeAlertsToday => 'Alerts today';

  @override
  String homeUnacknowledged(int count) {
    return '$count to review';
  }

  @override
  String get homeAllReviewed => 'All reviewed';

  @override
  String get homeEventsToday => 'Events today';

  @override
  String get homeCamerasOnline => 'Cameras online';

  @override
  String homeCamerasValue(int online, int total) {
    return '$online of $total';
  }

  @override
  String get homeOccupancy => 'Inside now';

  @override
  String get homeRecent => 'Recent events';

  @override
  String get homeAttention => 'Needs attention';

  @override
  String get homeAllGood => 'All cameras and connectors are online';

  @override
  String homeCameraOffline(String camera) {
    return '$camera is offline';
  }

  @override
  String homeConnectorOffline(String connector, String when) {
    return '$connector is offline, last seen $when';
  }

  @override
  String homeConnectorOnline(String connector, String version) {
    return '$connector online, version $version';
  }

  @override
  String get homeCountsToday => 'Visitors today';

  @override
  String get homeCountsIn => 'In';

  @override
  String get homeCountsOut => 'Out';

  @override
  String get homeNoSite => 'No site yet';

  @override
  String get homeNoSiteBody => 'Set up a site and pair its connector to start watching.';

  @override
  String get homeSetUp => 'Set up a site';

  @override
  String get homeNoEvents => 'Quiet so far today';

  @override
  String get liveTitle => 'Live';

  @override
  String get liveLayoutAuto => 'Automatic';

  @override
  String get liveLayoutOne => 'One column';

  @override
  String get liveLayoutTwo => 'Two by two';

  @override
  String get liveLayoutThree => 'Three by three';

  @override
  String get liveLayout => 'Layout';

  @override
  String get liveNoCameras => 'No cameras yet';

  @override
  String get liveNoCamerasBody => 'Add cameras from a paired connector to see them here.';

  @override
  String get liveAddCamera => 'Add camera';

  @override
  String get liveConnecting => 'Connecting';

  @override
  String get liveFailed => 'Video unavailable';

  @override
  String get liveCameraOffline => 'Camera offline';

  @override
  String get liveBadge => 'Live';

  @override
  String liveLens(int lens) {
    return 'Lens $lens';
  }

  @override
  String get cameraMain => 'Main';

  @override
  String get cameraSub => 'Sub';

  @override
  String get cameraQuality => 'Stream';

  @override
  String get cameraSound => 'Sound';

  @override
  String get cameraBoxes => 'Show detections';

  @override
  String get cameraFullscreen => 'Full screen';

  @override
  String get cameraSnapshot => 'Snapshot';

  @override
  String get cameraSnapshotSaved => 'Snapshot saved';

  @override
  String get cameraPtz => 'Pan and tilt';

  @override
  String get cameraSpeed => 'Speed';

  @override
  String get cameraZoomIn => 'Zoom in';

  @override
  String get cameraZoomOut => 'Zoom out';

  @override
  String get cameraHome => 'Home position';

  @override
  String get cameraPresets => 'Presets';

  @override
  String get cameraNoPresets => 'No presets yet';

  @override
  String get cameraSavePreset => 'Save position';

  @override
  String get cameraPresetName => 'Preset name';

  @override
  String get cameraLight => 'Light';

  @override
  String get cameraSiren => 'Siren';

  @override
  String get cameraSirenConfirm => 'Sound the siren for 10 seconds?';

  @override
  String get cameraSirenOn => 'Siren sounding';

  @override
  String get cameraRecent => 'Recent on this camera';

  @override
  String get cameraSettings => 'Camera settings';

  @override
  String get cameraAnalytics => 'Analytics';

  @override
  String get ptzUp => 'Tilt up';

  @override
  String get ptzDown => 'Tilt down';

  @override
  String get ptzLeft => 'Pan left';

  @override
  String get ptzRight => 'Pan right';

  @override
  String get eventsTitle => 'Events';

  @override
  String get eventsAlertsOnly => 'Alerts only';

  @override
  String get eventsFilters => 'Filters';

  @override
  String eventsFilterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filters',
      one: '1 filter',
    );
    return '$_temp0';
  }

  @override
  String eventsNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new events',
      one: '1 new event',
    );
    return '$_temp0';
  }

  @override
  String get eventsEmpty => 'No events';

  @override
  String get eventsEmptyBody => 'Nothing matched. Try another day or fewer filters.';

  @override
  String get eventsEmptyToday =>
      'Nothing happened yet. Events appear here as the cameras see them.';

  @override
  String get eventsAckAll => 'Mark all reviewed';

  @override
  String eventsAckAllDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alerts reviewed',
      one: '1 alert reviewed',
      zero: 'Nothing to review',
    );
    return '$_temp0';
  }

  @override
  String eventsTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events',
      one: '1 event',
      zero: 'No events',
    );
    return '$_temp0';
  }

  @override
  String get eventsLoadMore => 'Load more';

  @override
  String get filterDay => 'Day';

  @override
  String get filterAnyDay => 'Any day';

  @override
  String get filterCameras => 'Cameras';

  @override
  String get filterViews => 'Views';

  @override
  String get filterKinds => 'Kinds';

  @override
  String get filterLabels => 'Objects';

  @override
  String get filterZones => 'Zones';

  @override
  String get filterLines => 'Lines';

  @override
  String get filterPerson => 'Person';

  @override
  String get filterPlate => 'Plate';

  @override
  String get filterTime => 'Time';

  @override
  String get filterShow => 'Show results';

  @override
  String get eventAlert => 'Alert';

  @override
  String get eventReviewed => 'Reviewed';

  @override
  String get eventOngoing => 'Ongoing';

  @override
  String get eventAcknowledge => 'Mark reviewed';

  @override
  String get eventAcknowledged => 'Marked reviewed';

  @override
  String get eventShareClip => 'Share clip';

  @override
  String get eventClip => 'Clip';

  @override
  String get eventNoClip => 'This event has no clip.';

  @override
  String get eventSnapshot => 'Snapshot';

  @override
  String get eventDetails => 'Details';

  @override
  String get eventCamera => 'Camera';

  @override
  String get eventView => 'View';

  @override
  String get eventZone => 'Zone';

  @override
  String get eventLine => 'Line';

  @override
  String get eventDirection => 'Direction';

  @override
  String get eventDirectionIn => 'In';

  @override
  String get eventDirectionOut => 'Out';

  @override
  String get eventObjects => 'Objects';

  @override
  String get eventDuration => 'Duration';

  @override
  String get eventStarted => 'Started';

  @override
  String get eventSource => 'Source';

  @override
  String get eventSourceCamera => 'Camera';

  @override
  String get eventSourceAnalytics => 'Analytics';

  @override
  String get eventFace => 'Face';

  @override
  String eventConfidence(int value) {
    return '$value% match';
  }

  @override
  String get eventPlate => 'Number plate';

  @override
  String eventPlateReads(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reads',
      one: '1 read',
    );
    return '$_temp0';
  }

  @override
  String get plateInfrared => 'Not read at night: infrared light glares on the plate.';

  @override
  String get plateNone => 'No plate was found on the vehicle.';

  @override
  String get plateSmall => 'The plate was too small to read.';

  @override
  String get plateUnreadable => 'The plate could not be read.';

  @override
  String get platePending => 'Reading the plate.';

  @override
  String get eventJourney => 'Journey';

  @override
  String get eventFindPerson => 'Find this person';

  @override
  String get eventWhoIsThis => 'Who is this?';

  @override
  String get eventDemoClip => 'Demo clip';

  @override
  String get kindMotion => 'Motion';

  @override
  String get kindPerson => 'Person';

  @override
  String get kindVehicle => 'Vehicle';

  @override
  String get kindIntrusion => 'Intrusion';

  @override
  String get kindLineCrossing => 'Line crossing';

  @override
  String get kindLoitering => 'Loitering';

  @override
  String get kindCrowd => 'Crowd';

  @override
  String get kindFaceKnown => 'Known face';

  @override
  String get kindFaceUnknown => 'Unknown face';

  @override
  String get kindTamper => 'Tamper';

  @override
  String get kindStorage => 'Storage';

  @override
  String get kindReboot => 'Restart';

  @override
  String get kindAnimal => 'Animal';

  @override
  String get kindObjectLeft => 'Object left';

  @override
  String get kindObjectTaken => 'Object taken';

  @override
  String get kindFall => 'Fall';

  @override
  String titleMotion(String camera) {
    return 'Motion on $camera';
  }

  @override
  String titlePerson(String camera) {
    return 'Person on $camera';
  }

  @override
  String titleVehicle(String label, String camera) {
    return '$label on $camera';
  }

  @override
  String titleIntrusion(String label, String zone) {
    return '$label entered $zone';
  }

  @override
  String titleLineCrossing(String label, String line) {
    return '$label crossed $line';
  }

  @override
  String titleLoitering(String label, String zone) {
    return '$label lingering in $zone';
  }

  @override
  String titleCrowd(String zone) {
    return 'Crowd in $zone';
  }

  @override
  String titleFaceKnown(String name) {
    return '$name seen';
  }

  @override
  String titleFaceUnknown(String label) {
    return '$label seen';
  }

  @override
  String titleTamper(String camera, String how) {
    return '$camera view $how';
  }

  @override
  String titleAnimal(String label, String camera) {
    return '$label on $camera';
  }

  @override
  String titleObjectLeft(String label, String zone) {
    return '$label left in $zone';
  }

  @override
  String titleObjectTaken(String label, String zone) {
    return '$label taken from $zone';
  }

  @override
  String titleFall(String camera) {
    return 'Possible fall on $camera';
  }

  @override
  String titleStorage(String camera) {
    return '$camera storage problem';
  }

  @override
  String titleReboot(String camera) {
    return '$camera restarted';
  }

  @override
  String get tamperCovered => 'covered';

  @override
  String get tamperBlurred => 'blurred';

  @override
  String get tamperDark => 'too dark';

  @override
  String get tamperMoved => 'moved';

  @override
  String get tamperDisturbed => 'disturbed';

  @override
  String get labelPerson => 'Person';

  @override
  String get labelCar => 'Car';

  @override
  String get labelTruck => 'Truck';

  @override
  String get labelBus => 'Bus';

  @override
  String get labelMotorcycle => 'Motorcycle';

  @override
  String get labelBicycle => 'Bicycle';

  @override
  String get labelDog => 'Dog';

  @override
  String get labelCat => 'Cat';

  @override
  String get labelBird => 'Bird';

  @override
  String get labelBackpack => 'Backpack';

  @override
  String get labelHandbag => 'Handbag';

  @override
  String get labelSuitcase => 'Suitcase';

  @override
  String get labelVehicle => 'Vehicle';

  @override
  String get labelAnimal => 'Animal';

  @override
  String get labelSomething => 'Something';

  @override
  String get labelObject => 'Object';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchEvents => 'Events';

  @override
  String get searchPeople => 'People';

  @override
  String get searchFaces => 'Faces';

  @override
  String get searchPlates => 'Plates';

  @override
  String get searchFrom => 'From';

  @override
  String get searchUntil => 'Until';

  @override
  String get searchLast24h => 'Last 24 hours';

  @override
  String get searchLast7d => 'Last 7 days';

  @override
  String get searchLast30d => 'Last 30 days';

  @override
  String get searchRun => 'Search';

  @override
  String searchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
      zero: 'No results',
    );
    return '$_temp0';
  }

  @override
  String get searchHint => 'Build a query from time, cameras, kinds and objects.';

  @override
  String get searchFacesTitle => 'Find a face';

  @override
  String get searchFacesBody =>
      'Pick a photo with one face, or tap a face the cameras saw, to find where it appeared.';

  @override
  String get searchFacesPhoto => 'Choose a photo';

  @override
  String get searchFacesCamera => 'Take a photo';

  @override
  String get searchFacesResults => 'Similar faces';

  @override
  String get searchPlatesTitle => 'Find a vehicle by plate';

  @override
  String get searchPlatesHint => 'Plate text, for example 01 A 123 BC';

  @override
  String get searchPlatesBody => 'Plates are read by day on views where plate reading is on.';

  @override
  String get facesOffTitle => 'Face recognition is off';

  @override
  String get facesOffBody =>
      'An owner or admin can turn it on for the organisation in More, Faces.';

  @override
  String get facesTurnOn => 'Open face settings';

  @override
  String get peopleKnown => 'Known people';

  @override
  String get peopleUnknown => 'Unknown faces';

  @override
  String get peopleAdd => 'Add person';

  @override
  String get peopleEmpty => 'No people yet';

  @override
  String get peopleEmptyBody =>
      'Add the people you know, or name the unknown faces the cameras gather.';

  @override
  String peopleSeen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Seen $count times',
      one: 'Seen once',
    );
    return '$_temp0';
  }

  @override
  String peopleLastSeen(String when) {
    return 'Last seen $when';
  }

  @override
  String get peopleNeverSeen => 'Not seen yet';

  @override
  String get peopleSamples => 'Faces';

  @override
  String get peopleSightings => 'Sightings';

  @override
  String get peopleNoSightings => 'No sightings yet';

  @override
  String get peopleAddPhotos => 'Add photos';

  @override
  String peoplePhotosAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos added',
      one: '1 photo added',
      zero: 'No photos added',
    );
    return '$_temp0';
  }

  @override
  String peoplePhotosRejected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos had no single clear face',
      one: '1 photo had no single clear face',
    );
    return '$_temp0';
  }

  @override
  String get peopleMerge => 'Merge into another person';

  @override
  String peopleMergeTitle(String name) {
    return 'Merge $name into';
  }

  @override
  String get peopleDelete => 'Delete person';

  @override
  String peopleDeleteBody(String name) {
    return 'This deletes $name with every face sample and crop. Past events keep their snapshots.';
  }

  @override
  String get peopleNotes => 'Notes';

  @override
  String get peopleName => 'Name';

  @override
  String get clusterWhoTitle => 'Who is this?';

  @override
  String get clusterWhoBody =>
      'Name a new person or pick someone you know. Their past events are relabelled.';

  @override
  String get clusterNewPerson => 'New person';

  @override
  String get clusterExisting => 'Someone you know';

  @override
  String clusterNamed(String name) {
    return 'Named as $name';
  }

  @override
  String get clusterDelete => 'Forget these faces';

  @override
  String get clusterDeleteBody =>
      'This deletes the unknown face samples. Past events keep their snapshots.';

  @override
  String get findPersonTitle => 'Find this person';

  @override
  String get findPersonBody =>
      'Sightings on other cameras that look like the same person, by clothing and build. Day and night pictures do not match each other.';

  @override
  String get findPersonEmpty => 'No similar sightings found';

  @override
  String findPersonMatch(int value) {
    return '$value% similar';
  }

  @override
  String get moreTitle => 'More';

  @override
  String get moreSite => 'This site';

  @override
  String get moreOrganisation => 'Organisation';

  @override
  String get moreYou => 'You';

  @override
  String get moreCounts => 'Counts and occupancy';

  @override
  String get moreSiteSettings => 'Site settings';

  @override
  String get moreCameras => 'Cameras';

  @override
  String get moreAnalytics => 'Analytics';

  @override
  String get moreConnectors => 'Connectors';

  @override
  String get moreHealth => 'Health';

  @override
  String get moreMembers => 'Members';

  @override
  String get moreFaces => 'Faces';

  @override
  String get moreNotifications => 'Notifications';

  @override
  String get moreAccount => 'Account';

  @override
  String get moreAppearance => 'Language and theme';

  @override
  String get moreAbout => 'About';

  @override
  String get moreSignOut => 'Sign out';

  @override
  String get moreSignOutConfirm => 'Sign out of this phone?';

  @override
  String get countsTitle => 'Counts';

  @override
  String get countsHourly => 'By hour';

  @override
  String get countsDaily => 'By day';

  @override
  String get countsIn => 'In';

  @override
  String get countsOut => 'Out';

  @override
  String countsTotalIn(int count) {
    return '$count in';
  }

  @override
  String countsTotalOut(int count) {
    return '$count out';
  }

  @override
  String get countsNoLines => 'No counting lines';

  @override
  String get countsNoLinesBody =>
      'Draw a line on a view in Analytics to count people and vehicles crossing it.';

  @override
  String get countsAreas => 'Areas';

  @override
  String countsOccupancy(int count) {
    return '$count inside';
  }

  @override
  String countsCapacity(int count) {
    return 'of $count';
  }

  @override
  String countsSince(int entered, int exited, String time) {
    return 'Entered $entered, left $exited since $time';
  }

  @override
  String get countsReset => 'Set occupancy';

  @override
  String get countsResetTitle => 'How many are inside now?';

  @override
  String countsResetDone(int count) {
    return 'Occupancy set to $count';
  }

  @override
  String countsDailyReset(String time) {
    return 'Resets every day at $time';
  }

  @override
  String countsPeak(String hour) {
    return 'Busiest hour $hour';
  }

  @override
  String get siteSettingsTitle => 'Site settings';

  @override
  String get siteRetention => 'Keep events for';

  @override
  String siteRetentionDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get siteArmHelp =>
      'The arm mode decides which events alert. In Schedule mode every zone and line follows its own alert hours, which you set in Analytics.';

  @override
  String get camerasTitle => 'Cameras';

  @override
  String get camerasReorder => 'Drag to change the order of the live grid.';

  @override
  String get camerasAdd => 'Add camera';

  @override
  String get camerasDelete => 'Delete camera';

  @override
  String camerasDeleteBody(String camera) {
    return 'This removes $camera with its views, zones and lines. Its past events stay until they expire.';
  }

  @override
  String get camerasEnabled => 'Enabled';

  @override
  String get camerasNoConnector => 'Pair a connector first';

  @override
  String get camerasNoConnectorBody =>
      'Cameras are found and added through the connector at the site.';

  @override
  String get settingsDevice => 'Device';

  @override
  String get settingsManufacturer => 'Manufacturer';

  @override
  String get settingsModel => 'Model';

  @override
  String get settingsFirmware => 'Firmware';

  @override
  String get settingsVideo => 'Video';

  @override
  String get settingsImage => 'Image';

  @override
  String get settingsBrightness => 'Brightness';

  @override
  String get settingsContrast => 'Contrast';

  @override
  String get settingsSaturation => 'Saturation';

  @override
  String get settingsSharpness => 'Sharpness';

  @override
  String get settingsIrCut => 'Night mode filter';

  @override
  String get settingsMotion => 'Camera motion detection';

  @override
  String get settingsSensitivity => 'Sensitivity';

  @override
  String get settingsClock => 'Clock';

  @override
  String settingsClockOffset(String value) {
    return '$value s from the server';
  }

  @override
  String get settingsSyncClock => 'Sync clock';

  @override
  String get settingsClockSynced => 'Clock synced';

  @override
  String get settingsReboot => 'Restart camera';

  @override
  String get settingsRebootBody => 'The camera drops its video for about a minute.';

  @override
  String get settingsRebooting => 'Restarting the camera';

  @override
  String get settingsUnsupported => 'This camera does not offer this setting.';

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get analyticsViewsBody =>
      'Each lens is a view. Choose what it watches and draw its zones and lines.';

  @override
  String analyticsZonesLines(int zones, int lines) {
    String _temp0 = intl.Intl.pluralLogic(
      zones,
      locale: localeName,
      other: '$zones zones',
      one: '1 zone',
      zero: 'No zones',
    );
    String _temp1 = intl.Intl.pluralLogic(
      lines,
      locale: localeName,
      other: '$lines lines',
      one: '1 line',
      zero: 'no lines',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String get analyticsDisabled => 'Analytics off';

  @override
  String analyticsFps(String value) {
    return '$value fps';
  }

  @override
  String get analyticsSuspended => 'Lens turned away from its zones';

  @override
  String get analyticsEnabled => 'Analyse this view';

  @override
  String get analyticsProfile => 'Profile';

  @override
  String get profilePerimeter => 'Perimeter';

  @override
  String get profileVehicle => 'Vehicles';

  @override
  String get profileIdentity => 'Identity';

  @override
  String get profileTamper => 'Tamper only';

  @override
  String get analyticsStream => 'Analysed stream';

  @override
  String get analyticsStreamSub => 'Sub stream, for detection and counting';

  @override
  String get analyticsStreamMain => 'Main stream, for faces and plates';

  @override
  String get analyticsFeatures => 'Features';

  @override
  String get featureTamper => 'Tamper watch';

  @override
  String get featureTamperBody => 'Covered, blurred, moved and too dark';

  @override
  String get featureFaces => 'Faces';

  @override
  String get featureFacesBody => 'Name known people, gather unknown faces';

  @override
  String get featureFacesLocked => 'Turn on faces for the organisation first';

  @override
  String get featureAppearance => 'Journeys';

  @override
  String get featureAppearanceBody => 'Link a person across cameras by appearance';

  @override
  String get featureFalls => 'Falls';

  @override
  String get featureFallsBody => 'Alert when someone falls and stays down';

  @override
  String get featurePlates => 'Number plates';

  @override
  String get featurePlatesBody => 'Read plates on vehicle events by day';

  @override
  String get featureFollow => 'Auto follow';

  @override
  String get featureFollowBody => 'Turn the lens to keep a person in view, then return';

  @override
  String get featureMoving => 'Moving lens';

  @override
  String get featureMovingBody => 'Zones keep the picture they were drawn on';

  @override
  String get analyticsRules => 'Zones and lines';

  @override
  String get analyticsEdit => 'Draw zones and lines';

  @override
  String get analyticsNoRules => 'No zones or lines yet';

  @override
  String get analyticsWholeView => 'Whole view';

  @override
  String get editorTitle => 'Zones and lines';

  @override
  String get editorZone => 'Zone';

  @override
  String get editorLine => 'Line';

  @override
  String get editorAddZone => 'New zone';

  @override
  String get editorAddLine => 'New line';

  @override
  String get editorHintZone => 'Tap the picture to place corners. Drag a corner to move it.';

  @override
  String get editorHintLine => 'Tap two points for the line. The arrow shows the inward side.';

  @override
  String get editorUndo => 'Undo point';

  @override
  String get editorFlip => 'Flip direction';

  @override
  String get editorDelete => 'Delete shape';

  @override
  String get editorDiscard => 'Discard changes?';

  @override
  String get editorDiscardBody => 'Your zones and lines are not saved yet.';

  @override
  String get editorKeepEditing => 'Keep editing';

  @override
  String get editorSaved => 'Zones and lines saved. They apply within a few seconds.';

  @override
  String get editorNameZone => 'Zone name';

  @override
  String get editorNameLine => 'Line name';

  @override
  String get editorObjects => 'Watch for';

  @override
  String get editorDwell => 'Minimum time inside';

  @override
  String get editorLoiter => 'Loitering after';

  @override
  String get editorCrowd => 'Crowd from';

  @override
  String editorCrowdPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
      zero: 'Off',
    );
    return '$_temp0';
  }

  @override
  String get editorLeft => 'Object left after';

  @override
  String get editorTaken => 'Object taken after';

  @override
  String get editorAlerts => 'Alerts';

  @override
  String get editorAlertOff => 'Never';

  @override
  String get editorAlertAlways => 'Always';

  @override
  String get editorAlertSchedule => 'On a schedule';

  @override
  String editorAlertHours(String start, String end) {
    return 'Alert between $start and $end';
  }

  @override
  String get editorAnimals => 'Animals';

  @override
  String get editorAnimalsInclude => 'Alert';

  @override
  String get editorAnimalsRecord => 'Record only';

  @override
  String get editorAnimalsExclude => 'Ignore';

  @override
  String get editorDirection => 'Count direction';

  @override
  String get editorDirectionIn => 'Inward';

  @override
  String get editorDirectionOut => 'Outward';

  @override
  String get editorDirectionBoth => 'Both ways';

  @override
  String get editorDurationOff => 'Off';

  @override
  String get editorEnabled => 'Active';

  @override
  String get editorTooFewPoints => 'A zone needs at least 3 corners.';

  @override
  String get connectorsTitle => 'Connectors';

  @override
  String get connectorsPair => 'Pair a connector';

  @override
  String get connectorsEmpty => 'No connector yet';

  @override
  String get connectorsEmptyBody =>
      'A connector at the site finds the cameras and links them to the server.';

  @override
  String connectorsVersion(String version) {
    return 'Version $version';
  }

  @override
  String connectorsSeen(String when) {
    return 'Seen $when';
  }

  @override
  String get connectorsRemove => 'Remove connector';

  @override
  String get connectorsRemoveBody =>
      'Its cameras stop until another connector is paired with this site.';

  @override
  String get connectorsMode => 'Direct connection';

  @override
  String get connectorsFind => 'Find cameras';

  @override
  String get membersTitle => 'Members';

  @override
  String get membersInvite => 'Invite';

  @override
  String get membersInvited => 'Invited';

  @override
  String get membersYou => 'You';

  @override
  String get membersAllSites => 'All sites';

  @override
  String membersSomeSites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sites',
      one: '1 site',
    );
    return '$_temp0';
  }

  @override
  String get membersPending => 'Pending invitations';

  @override
  String membersExpires(String date) {
    return 'Expires $date';
  }

  @override
  String get membersRevoke => 'Revoke invitation';

  @override
  String get membersRemove => 'Remove from organisation';

  @override
  String membersRemoveBody(String name) {
    return '$name loses access to every site of the organisation at once.';
  }

  @override
  String get membersRole => 'Role';

  @override
  String get membersSites => 'Sites';

  @override
  String get membersInviteTitle => 'Invite a member';

  @override
  String get membersInviteBody => 'They get an email with a link that works once, for 7 days.';

  @override
  String membersInviteSent(String email) {
    return 'Invitation sent to $email';
  }

  @override
  String get roleOwner => 'Owner';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleOperator => 'Operator';

  @override
  String get roleViewer => 'Viewer';

  @override
  String get roleOwnerBody => 'Everything, including deleting the organisation';

  @override
  String get roleAdminBody => 'Cameras, analytics, people and members';

  @override
  String get roleOperatorBody => 'Watch, control cameras and arm or disarm';

  @override
  String get roleViewerBody => 'Watch live video and events';

  @override
  String get facesTitle => 'Face recognition';

  @override
  String get facesBody =>
      'Faces are matched on the server of this organisation. Turn this on only where people who are filmed have been told and agree, as the law of your country requires.';

  @override
  String get facesConsentTitle => 'Turn on face recognition?';

  @override
  String get facesConsentBody =>
      'Face recognition stores face pictures and face measurements of everyone the cameras see on views where faces are on. Face measurements are biometric data. You confirm that the people who are filmed have been informed, that you have a lawful reason to process their faces, and that the data is kept only as long as needed. You can turn this off at any time; known people and their faces then stay until you delete them.';

  @override
  String get facesConsentConfirm => 'I understand, turn on';

  @override
  String get facesEnabled => 'Face recognition on';

  @override
  String get facesDisabled => 'Face recognition off';

  @override
  String get facesOwnerOnly => 'Only an owner or admin can change this.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String notificationsSite(String site) {
    return 'Alerts for $site';
  }

  @override
  String get notificationsAlertsOnly => 'Only alerts';

  @override
  String get notificationsAlertsOnlyBody => 'Off sends every event, which can be many.';

  @override
  String get notificationsKinds => 'Kinds';

  @override
  String get notificationsQuiet => 'Quiet hours';

  @override
  String notificationsQuietBody(String from, String until) {
    return 'Silent between $from and $until';
  }

  @override
  String get notificationsQuietOff => 'No quiet hours';

  @override
  String get notificationsPermissionOff => 'Notifications are blocked for this app.';

  @override
  String get notificationsOpenSettings => 'Open settings';

  @override
  String get notificationsChannel => 'Delivery';

  @override
  String get notificationsChannelFcm => 'Push through Firebase Cloud Messaging';

  @override
  String get notificationsChannelNone => 'While the app is open. This build has no push service.';

  @override
  String get healthTitle => 'Health';

  @override
  String healthUptime(String value) {
    return '$value% up';
  }

  @override
  String healthLatency(String value) {
    return '$value ms';
  }

  @override
  String get healthOutages => 'Outages';

  @override
  String get healthNoOutages => 'No outages in the last 24 hours';

  @override
  String healthOngoing(String duration) {
    return 'Ongoing for $duration';
  }

  @override
  String healthLasted(String duration) {
    return 'Lasted $duration';
  }

  @override
  String healthCause(String name) {
    return 'Caused by $name';
  }

  @override
  String get healthLast24h => 'Last 24 hours';

  @override
  String get healthUp => 'Up';

  @override
  String get healthDegraded => 'Degraded';

  @override
  String get healthDown => 'Down';

  @override
  String get accountTitle => 'Account';

  @override
  String get accountProfile => 'Profile';

  @override
  String get accountSessions => 'Signed in devices';

  @override
  String get accountThisDevice => 'This device';

  @override
  String accountLastUsed(String when) {
    return 'Last used $when';
  }

  @override
  String get accountRevoke => 'Sign out this device';

  @override
  String accountRevoked(String device) {
    return 'Signed out $device';
  }

  @override
  String get accountAppLock => 'App lock';

  @override
  String get accountAppLockBody => 'Ask for fingerprint, face or screen lock when the app opens';

  @override
  String get accountAppLockUnavailable => 'This phone has no screen lock set up.';

  @override
  String get accountDelete => 'Delete account';

  @override
  String get accountDeleteTitle => 'Delete your account';

  @override
  String get accountDeleteBody =>
      'This deletes your account and signs you out everywhere. Organisations you own must be handed to another owner or deleted first. This cannot be undone.';

  @override
  String get accountDeleteConfirm => 'Delete my account';

  @override
  String get accountDeletePassword => 'Enter your password to confirm';

  @override
  String get accountDeleted => 'Your account is deleted.';

  @override
  String get appearanceTitle => 'Language and theme';

  @override
  String get appearanceLanguage => 'Language';

  @override
  String get appearanceSystem => 'Phone setting';

  @override
  String get appearanceTheme => 'Theme';

  @override
  String get themeSystem => 'Phone setting';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get aboutTitle => 'About';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String aboutBuild(String flavor) {
    return '$flavor build';
  }

  @override
  String get aboutServer => 'Server';

  @override
  String get aboutLicences => 'Open source licences';

  @override
  String get aboutPrivacy =>
      'Video, snapshots and faces stay on the server you connect to. Notifications carry only ids; the app fetches the picture itself.';

  @override
  String get lockTitle => 'Smart Surveillance is locked';

  @override
  String get lockUnlock => 'Unlock';

  @override
  String get lockReason => 'Unlock to watch your cameras';

  @override
  String notificationAlertTitle(String site) {
    return 'Alert at $site';
  }

  @override
  String get notificationChannelName => 'Alerts';

  @override
  String get notificationChannelBody => 'Alerts from your cameras';

  @override
  String commonHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get commonShowPassword => 'Show password';

  @override
  String get commonHidePassword => 'Hide password';

  @override
  String get countsInside => 'inside';

  @override
  String get editorAddPoints => 'Add corners';

  @override
  String get connectorsVersionLabel => 'Version';

  @override
  String get connectorsLastSeen => 'Last seen';

  @override
  String get connectorsConnection => 'Connection';

  @override
  String get connectorsTunnel => 'Secure tunnel';

  @override
  String get fieldCodeHelp => 'Paste the link from the email, or the code in it';

  @override
  String get verifyDone => 'Email confirmed. Sign in to continue.';

  @override
  String get resetLinkBody => 'Choose a new password for your account.';

  @override
  String get pairingAddTitle => 'How do you want to add it?';

  @override
  String get pairingAddBody =>
      'Pick the way that suits the camera. The best one for this site comes first.';

  @override
  String get pairingRecommended => 'Recommended';

  @override
  String get pairingPermissionDenied =>
      'This needs a permission the phone did not give. Allow it in the phone settings, or choose another way.';

  @override
  String get pairingDemoCode => 'Use the demo code';

  @override
  String get pairingWaiting => 'Waiting for the connector to confirm';

  @override
  String pairingCamerasAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cameras added',
      one: 'Camera added',
    );
    return '$_temp0';
  }

  @override
  String get validationConnectorCode => 'Enter the 8 character code, like ABCD-1234';

  @override
  String get methodConnectorDiscovery => 'Cameras on the network';

  @override
  String get methodConnectorDiscoveryBody => 'Pick one of the cameras the connector found';

  @override
  String get methodLabelQr => 'Scan the camera\'s label';

  @override
  String get methodLabelQrBody => 'Point at the QR code on the sticker of the camera';

  @override
  String get methodManualHost => 'Enter its address';

  @override
  String get methodManualHostBody => 'Type the camera\'s IP address and the app identifies it';

  @override
  String get methodNvrImport => 'Import from a recorder';

  @override
  String get methodNvrImportBody => 'Add channels of an NVR or DVR at once';

  @override
  String get methodRtspUrl => 'Paste an RTSP link';

  @override
  String get methodRtspUrlBody => 'For cameras that give a stream address';

  @override
  String get methodConnectorQr => 'Scan the connector\'s QR code';

  @override
  String get methodConnectorQrBody => 'The connector shows it on its screen or web page';

  @override
  String get methodConnectorMdns => 'Find it on this Wi-Fi';

  @override
  String get methodConnectorMdnsBody => 'Look for connectors on the network this phone is on';

  @override
  String get methodConnectorCode => 'Type the code';

  @override
  String get methodConnectorCodeBody => 'The 8 character code the connector shows';

  @override
  String get mdnsTitle => 'Connectors on this Wi-Fi';

  @override
  String get mdnsSearching => 'Looking for connectors on this network';

  @override
  String get mdnsNone =>
      'No connector found yet. Make sure this phone and the connector are on the same Wi-Fi.';

  @override
  String get labelTitle => 'Scan the label';

  @override
  String get labelHint => 'Point the camera at the QR code on the camera\'s sticker.';

  @override
  String get labelUnknown => 'This label is not one we know. Add the camera another way.';

  @override
  String get manualTitle => 'Camera address';

  @override
  String get manualBody =>
      'The connector asks the camera what it is. Its login comes on the next step.';

  @override
  String get manualHost => 'IP address or host name';

  @override
  String get manualPort => 'ONVIF port, if not the usual one';

  @override
  String get manualIdentify => 'Identify camera';

  @override
  String get manualIdentifying => 'Asking the camera';

  @override
  String get manualNotFound => 'No camera answered at that address. Check it and try again.';

  @override
  String get rtspTitle => 'RTSP link';

  @override
  String get rtspBody =>
      'Paste the stream link from the camera\'s manual or app. A login in the link is kept on the connector.';

  @override
  String get rtspField => 'Stream link';

  @override
  String get rtspInvalid => 'That is not an RTSP link.';

  @override
  String get nvrPick => 'Choose the recorder';

  @override
  String get nvrNone => 'No recorders found';

  @override
  String get nvrTitle => 'Import channels';

  @override
  String get nvrLogin => 'Recorder login';

  @override
  String get nvrLoad => 'Show channels';

  @override
  String get nvrChannels => 'Channels';

  @override
  String nvrAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count cameras',
      one: 'Add 1 camera',
      zero: 'Choose channels',
    );
    return '$_temp0';
  }

  @override
  String get nvrOffline => 'No signal';

  @override
  String get onboardingTestPassed => 'Stream works';

  @override
  String get presetZoneName => 'Whole view';

  @override
  String get presetLineName => 'Entrance';

  @override
  String get morePlan => 'Plan and usage';

  @override
  String get moreActivity => 'Activity';

  @override
  String get planTitle => 'Plan and usage';

  @override
  String get planInternal => 'Internal plan with no limits';

  @override
  String get planUnlimited => 'No limit';

  @override
  String get planLimits => 'Limits';

  @override
  String get planUsage => 'This month';

  @override
  String get planFeatures => 'Features';

  @override
  String get planIncluded => 'Included';

  @override
  String get planNotIncluded => 'Not in your plan';

  @override
  String get planUnavailable => 'Not in your plan. An owner can change the plan.';

  @override
  String get planSites => 'Sites';

  @override
  String get planCameras => 'Cameras';

  @override
  String get planMembers => 'Members';

  @override
  String get planEventRetention => 'Events kept';

  @override
  String get planClipRetention => 'Clips kept';

  @override
  String get planCameraHours => 'Camera hours online';

  @override
  String get planAnalyticsHours => 'Analysed view hours';

  @override
  String get planEvents => 'Events';

  @override
  String get planClipStorage => 'Clip storage';

  @override
  String get planNotifications => 'Notifications sent';

  @override
  String planOf(String used, String limit) {
    return '$used of $limit';
  }

  @override
  String planSince(String date) {
    return 'since $date';
  }

  @override
  String planGigabytes(String value) {
    return '$value GB';
  }

  @override
  String get featureObjects => 'Objects left and taken';

  @override
  String get featureJourneys => 'Journeys';

  @override
  String get featureAppearanceSearch => 'Find this person';

  @override
  String get featureTelegram => 'Telegram alerts';

  @override
  String get telegramTitle => 'Telegram';

  @override
  String get telegramBody => 'Send alerts with the snapshot to a Telegram chat or group.';

  @override
  String get telegramLink => 'Link a chat';

  @override
  String get telegramLinkBody =>
      'Telegram opens the bot. Press Start in a private chat, or add the bot to a group, and the chat appears here.';

  @override
  String get telegramOpened => 'Finish in Telegram, then come back here.';

  @override
  String get telegramChats => 'Linked chats';

  @override
  String get telegramNone => 'No chat linked yet';

  @override
  String get telegramGroup => 'Group';

  @override
  String get telegramPrivate => 'Private chat';

  @override
  String telegramLinked(String when) {
    return 'Linked $when';
  }

  @override
  String get telegramUnlink => 'Unlink';

  @override
  String telegramUnlinkBody(String chat) {
    return 'Alerts stop going to $chat.';
  }

  @override
  String get telegramTest => 'Send a test';

  @override
  String telegramTestSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Test sent to $count chats',
      one: 'Test sent to 1 chat',
      zero: 'No chat to send to',
    );
    return '$_temp0';
  }

  @override
  String get telegramCannotOpen => 'Telegram could not be opened on this phone.';

  @override
  String get activityTitle => 'Activity';

  @override
  String get activityEmpty => 'No activity yet';

  @override
  String get activityAll => 'All';

  @override
  String get auditSignIn => 'Sign ins';

  @override
  String get auditMembers => 'Members';

  @override
  String get auditCameras => 'Cameras';

  @override
  String get auditRules => 'Rules';

  @override
  String get auditArm => 'Arm mode';

  @override
  String get auditViews => 'Viewing';

  @override
  String get auditExports => 'Exports';

  @override
  String get auditFaces => 'Faces';

  @override
  String get auditAdmin => 'Platform';

  @override
  String get actionAuthSignIn => 'Signed in';

  @override
  String get actionMemberInvite => 'Invited a member';

  @override
  String get actionMemberRole => 'Changed a role';

  @override
  String get actionMemberRemove => 'Removed a member';

  @override
  String get actionCameraAdd => 'Added a camera';

  @override
  String get actionCameraUpdate => 'Changed a camera';

  @override
  String get actionCameraDelete => 'Deleted a camera';

  @override
  String get actionRulesUpdate => 'Changed zones and lines';

  @override
  String get actionArmChange => 'Changed the arm mode';

  @override
  String get actionLiveView => 'Watched live';

  @override
  String get actionClipView => 'Watched a clip';

  @override
  String get actionClipExport => 'Shared a clip';

  @override
  String get actionFaceEnrol => 'Added face photos';

  @override
  String get actionFaceDelete => 'Deleted faces';

  @override
  String get actionOrgPlan => 'Changed the plan';

  @override
  String get capabilityNone => 'This camera has no controls to show.';

  @override
  String eventsAlertCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alerts',
      one: '1 alert',
    );
    return '$_temp0';
  }

  @override
  String get discoveredImport => 'Import';

  @override
  String get errorTooMany => 'Too many attempts. Wait a minute and try again.';

  @override
  String get onboardingCameraBodyDirect =>
      'Enter the login the camera uses for its video. The server keeps it encrypted and uses it only to reach the camera.';
}
