import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('ru'), Locale('uz')];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Smart Surveillance'**
  String get appName;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get commonSaved;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get commonApply;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @commonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get commonReset;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get commonSkip;

  /// No description provided for @commonAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get commonAll;

  /// No description provided for @commonNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get commonNone;

  /// No description provided for @commonOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get commonOn;

  /// No description provided for @commonOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get commonOff;

  /// No description provided for @commonBeta.
  ///
  /// In en, this message translates to:
  /// **'Beta'**
  String get commonBeta;

  /// No description provided for @commonDemo.
  ///
  /// In en, this message translates to:
  /// **'Demo data'**
  String get commonDemo;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get commonLoading;

  /// No description provided for @commonSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get commonSeeAll;

  /// No description provided for @commonOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get commonOnline;

  /// No description provided for @commonOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get commonOffline;

  /// No description provided for @commonUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get commonUnknown;

  /// No description provided for @commonToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get commonToday;

  /// No description provided for @commonYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get commonYesterday;

  /// No description provided for @commonJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get commonJustNow;

  /// No description provided for @commonMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String commonMinutesAgo(int count);

  /// No description provided for @commonHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} h ago'**
  String commonHoursAgo(int count);

  /// No description provided for @commonDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} d ago'**
  String commonDaysAgo(int count);

  /// No description provided for @commonSeconds.
  ///
  /// In en, this message translates to:
  /// **'{count} s'**
  String commonSeconds(int count);

  /// No description provided for @commonMinutesSeconds.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min {seconds} s'**
  String commonMinutesSeconds(int minutes, int seconds);

  /// No description provided for @commonPercent.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String commonPercent(String value);

  /// No description provided for @commonPermissionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Your role does not allow this.'**
  String get commonPermissionNeeded;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the server. Check the connection and the server address.'**
  String get errorNetwork;

  /// No description provided for @errorUnauthorised.
  ///
  /// In en, this message translates to:
  /// **'The email or password is wrong.'**
  String get errorUnauthorised;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'Your role does not allow this.'**
  String get errorForbidden;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'It is no longer there.'**
  String get errorNotFound;

  /// No description provided for @errorConflict.
  ///
  /// In en, this message translates to:
  /// **'That already exists.'**
  String get errorConflict;

  /// No description provided for @errorInvalid.
  ///
  /// In en, this message translates to:
  /// **'Check the highlighted fields.'**
  String get errorInvalid;

  /// No description provided for @errorExpired.
  ///
  /// In en, this message translates to:
  /// **'This code has expired. Ask for a new one.'**
  String get errorExpired;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'The server had a problem. Try again in a moment.'**
  String get errorServer;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorUnknown;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load this'**
  String get errorTitle;

  /// No description provided for @fieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// No description provided for @fieldPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get fieldPassword;

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get fieldName;

  /// No description provided for @fieldNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get fieldNewPassword;

  /// No description provided for @fieldCode.
  ///
  /// In en, this message translates to:
  /// **'Code from the email'**
  String get fieldCode;

  /// No description provided for @validationEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get validationEmail;

  /// No description provided for @validationPassword.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get validationPassword;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get validationRequired;

  /// No description provided for @validationCode.
  ///
  /// In en, this message translates to:
  /// **'Paste the link or the code from the email'**
  String get validationCode;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Every camera on your site, in your pocket'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Watch live video, get alerts that matter, and count who comes and goes at home, in a store, an office or a warehouse.'**
  String get welcomeBody;

  /// No description provided for @welcomeCreate.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get welcomeCreate;

  /// No description provided for @welcomeSignIn.
  ///
  /// In en, this message translates to:
  /// **'I have an account'**
  String get welcomeSignIn;

  /// No description provided for @welcomeFeatureLive.
  ///
  /// In en, this message translates to:
  /// **'Live video from every camera'**
  String get welcomeFeatureLive;

  /// No description provided for @welcomeFeatureAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts for people, vehicles and tampering'**
  String get welcomeFeatureAlerts;

  /// No description provided for @welcomeFeatureCounts.
  ///
  /// In en, this message translates to:
  /// **'Counts and occupancy by the hour'**
  String get welcomeFeatureCounts;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back.'**
  String get signInSubtitle;

  /// No description provided for @signInAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInAction;

  /// No description provided for @signInForgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get signInForgot;

  /// No description provided for @signInNoAccount.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get signInNoAccount;

  /// No description provided for @serverTitle.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get serverTitle;

  /// No description provided for @serverHint.
  ///
  /// In en, this message translates to:
  /// **'Address of your Smart Surveillance server'**
  String get serverHint;

  /// No description provided for @serverField.
  ///
  /// In en, this message translates to:
  /// **'Server address'**
  String get serverField;

  /// No description provided for @serverDemo.
  ///
  /// In en, this message translates to:
  /// **'Demo mode shows sample data and needs no server.'**
  String get serverDemo;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUpTitle;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One account for every site you watch.'**
  String get signUpSubtitle;

  /// No description provided for @signUpAction.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUpAction;

  /// No description provided for @signUpTerms.
  ///
  /// In en, this message translates to:
  /// **'By creating an account you agree that video from your cameras is processed on the server you connect to.'**
  String get signUpTerms;

  /// No description provided for @signUpHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get signUpHaveAccount;

  /// No description provided for @passwordWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get passwordWeak;

  /// No description provided for @passwordFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get passwordFair;

  /// No description provided for @passwordStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get passwordStrong;

  /// No description provided for @verifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get verifyTitle;

  /// No description provided for @verifyBody.
  ///
  /// In en, this message translates to:
  /// **'We sent a confirmation link to {email}. Open it on this phone, or paste the link or the code from the email here.'**
  String verifyBody(String email);

  /// No description provided for @verifyAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm email'**
  String get verifyAction;

  /// No description provided for @verifyResend.
  ///
  /// In en, this message translates to:
  /// **'Send the email again'**
  String get verifyResend;

  /// No description provided for @verifyResent.
  ///
  /// In en, this message translates to:
  /// **'A new code is on its way.'**
  String get verifyResent;

  /// No description provided for @verifyWrongEmail.
  ///
  /// In en, this message translates to:
  /// **'Use another email'**
  String get verifyWrongEmail;

  /// No description provided for @forgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get forgotTitle;

  /// No description provided for @forgotBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will send a code to set a new password.'**
  String get forgotBody;

  /// No description provided for @forgotAction.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get forgotAction;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a new password'**
  String get resetTitle;

  /// No description provided for @resetBody.
  ///
  /// In en, this message translates to:
  /// **'Paste the link or the code we sent to {email} and choose a new password.'**
  String resetBody(String email);

  /// No description provided for @resetAction.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get resetAction;

  /// No description provided for @resetDone.
  ///
  /// In en, this message translates to:
  /// **'Password changed. Sign in with the new one.'**
  String get resetDone;

  /// No description provided for @inviteTitle.
  ///
  /// In en, this message translates to:
  /// **'You are invited'**
  String get inviteTitle;

  /// No description provided for @inviteBody.
  ///
  /// In en, this message translates to:
  /// **'{inviter} invited you to {organisation} as {role}.'**
  String inviteBody(String inviter, String organisation, String role);

  /// No description provided for @inviteSites.
  ///
  /// In en, this message translates to:
  /// **'Sites: {sites}'**
  String inviteSites(String sites);

  /// No description provided for @inviteAllSites.
  ///
  /// In en, this message translates to:
  /// **'Every site of the organisation'**
  String get inviteAllSites;

  /// No description provided for @inviteExpires.
  ///
  /// In en, this message translates to:
  /// **'This invitation expires {date}.'**
  String inviteExpires(String date);

  /// No description provided for @inviteAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept invitation'**
  String get inviteAccept;

  /// No description provided for @inviteSignInFirst.
  ///
  /// In en, this message translates to:
  /// **'Sign in or create an account first, then open the link again.'**
  String get inviteSignInFirst;

  /// No description provided for @inviteAccepted.
  ///
  /// In en, this message translates to:
  /// **'You joined {organisation}.'**
  String inviteAccepted(String organisation);

  /// No description provided for @onboardingStep.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String onboardingStep(int step, int total);

  /// No description provided for @onboardingSiteTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your first site'**
  String get onboardingSiteTitle;

  /// No description provided for @onboardingSiteBody.
  ///
  /// In en, this message translates to:
  /// **'A site is one place with cameras: your home, a store, an office or a warehouse. You can add more sites later.'**
  String get onboardingSiteBody;

  /// No description provided for @fieldOrganisation.
  ///
  /// In en, this message translates to:
  /// **'Organisation name'**
  String get fieldOrganisation;

  /// No description provided for @fieldOrganisationHint.
  ///
  /// In en, this message translates to:
  /// **'Your family or company'**
  String get fieldOrganisationHint;

  /// No description provided for @fieldSiteName.
  ///
  /// In en, this message translates to:
  /// **'Site name'**
  String get fieldSiteName;

  /// No description provided for @fieldSiteNameHint.
  ///
  /// In en, this message translates to:
  /// **'For example Home or Main street store'**
  String get fieldSiteNameHint;

  /// No description provided for @fieldSiteKind.
  ///
  /// In en, this message translates to:
  /// **'Kind of site'**
  String get fieldSiteKind;

  /// No description provided for @fieldTimezone.
  ///
  /// In en, this message translates to:
  /// **'Time zone'**
  String get fieldTimezone;

  /// No description provided for @onboardingConnectorTitle.
  ///
  /// In en, this message translates to:
  /// **'Pair a connector'**
  String get onboardingConnectorTitle;

  /// No description provided for @onboardingConnectorBody.
  ///
  /// In en, this message translates to:
  /// **'The connector is a small program that runs on any always-on computer at the site, such as a mini PC or a Raspberry Pi. It finds the cameras and connects them securely to the server.'**
  String get onboardingConnectorBody;

  /// No description provided for @onboardingConnectorStep1.
  ///
  /// In en, this message translates to:
  /// **'Install Docker on a computer that stays on at the site.'**
  String get onboardingConnectorStep1;

  /// No description provided for @onboardingConnectorStep2.
  ///
  /// In en, this message translates to:
  /// **'Start the connector with the command from the server documentation.'**
  String get onboardingConnectorStep2;

  /// No description provided for @onboardingConnectorStep3.
  ///
  /// In en, this message translates to:
  /// **'The connector shows a QR code and an 8 character code. Scan it or type it here.'**
  String get onboardingConnectorStep3;

  /// No description provided for @onboardingScan.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get onboardingScan;

  /// No description provided for @onboardingTypeCode.
  ///
  /// In en, this message translates to:
  /// **'Type the code'**
  String get onboardingTypeCode;

  /// No description provided for @fieldConnectorCode.
  ///
  /// In en, this message translates to:
  /// **'Connector code'**
  String get fieldConnectorCode;

  /// No description provided for @fieldConnectorName.
  ///
  /// In en, this message translates to:
  /// **'Connector name'**
  String get fieldConnectorName;

  /// No description provided for @onboardingPair.
  ///
  /// In en, this message translates to:
  /// **'Pair connector'**
  String get onboardingPair;

  /// No description provided for @onboardingPaired.
  ///
  /// In en, this message translates to:
  /// **'{name} is paired with {site}.'**
  String onboardingPaired(String name, String site);

  /// No description provided for @scanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan the connector code'**
  String get scanTitle;

  /// No description provided for @scanHint.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the QR code on the connector screen.'**
  String get scanHint;

  /// No description provided for @scanNoPermission.
  ///
  /// In en, this message translates to:
  /// **'Allow camera access to scan, or type the code instead.'**
  String get scanNoPermission;

  /// No description provided for @scanAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow camera'**
  String get scanAllow;

  /// No description provided for @onboardingCamerasTitle.
  ///
  /// In en, this message translates to:
  /// **'Cameras on the network'**
  String get onboardingCamerasTitle;

  /// No description provided for @onboardingCamerasBody.
  ///
  /// In en, this message translates to:
  /// **'The connector looked for cameras on its network. Choose one to add it.'**
  String get onboardingCamerasBody;

  /// No description provided for @onboardingSearching.
  ///
  /// In en, this message translates to:
  /// **'Looking for cameras'**
  String get onboardingSearching;

  /// No description provided for @onboardingRescan.
  ///
  /// In en, this message translates to:
  /// **'Search again'**
  String get onboardingRescan;

  /// No description provided for @onboardingNoCameras.
  ///
  /// In en, this message translates to:
  /// **'No cameras found yet'**
  String get onboardingNoCameras;

  /// No description provided for @onboardingNoCamerasBody.
  ///
  /// In en, this message translates to:
  /// **'Make sure the cameras are powered and on the same network as the connector, then search again.'**
  String get onboardingNoCamerasBody;

  /// No description provided for @onboardingAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get onboardingAdded;

  /// No description provided for @onboardingAddCamera.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get onboardingAddCamera;

  /// No description provided for @onboardingFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish setup'**
  String get onboardingFinish;

  /// No description provided for @onboardingCameraTitle.
  ///
  /// In en, this message translates to:
  /// **'Add camera'**
  String get onboardingCameraTitle;

  /// No description provided for @onboardingCameraBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the login the camera uses for its video. It stays on the connector, encrypted, and never reaches the server.'**
  String get onboardingCameraBody;

  /// No description provided for @fieldCameraUser.
  ///
  /// In en, this message translates to:
  /// **'Camera username'**
  String get fieldCameraUser;

  /// No description provided for @fieldCameraPassword.
  ///
  /// In en, this message translates to:
  /// **'Camera password'**
  String get fieldCameraPassword;

  /// No description provided for @fieldCameraName.
  ///
  /// In en, this message translates to:
  /// **'Camera name'**
  String get fieldCameraName;

  /// No description provided for @fieldCameraNameHint.
  ///
  /// In en, this message translates to:
  /// **'For example Front door'**
  String get fieldCameraNameHint;

  /// No description provided for @fieldLenses.
  ///
  /// In en, this message translates to:
  /// **'Pictures in one stream'**
  String get fieldLenses;

  /// No description provided for @lensesOne.
  ///
  /// In en, this message translates to:
  /// **'One picture'**
  String get lensesOne;

  /// No description provided for @lensesTwo.
  ///
  /// In en, this message translates to:
  /// **'Two stacked lenses'**
  String get lensesTwo;

  /// No description provided for @onboardingTest.
  ///
  /// In en, this message translates to:
  /// **'Test the stream'**
  String get onboardingTest;

  /// No description provided for @onboardingTesting.
  ///
  /// In en, this message translates to:
  /// **'Connecting to the camera'**
  String get onboardingTesting;

  /// No description provided for @onboardingTestOk.
  ///
  /// In en, this message translates to:
  /// **'Stream works: {codec}, {width} by {height}'**
  String onboardingTestOk(String codec, int width, int height);

  /// No description provided for @onboardingTestFailed.
  ///
  /// In en, this message translates to:
  /// **'The camera refused the login. Check the username and password.'**
  String get onboardingTestFailed;

  /// No description provided for @onboardingSaveCamera.
  ///
  /// In en, this message translates to:
  /// **'Save camera'**
  String get onboardingSaveCamera;

  /// No description provided for @onboardingAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'What should this camera watch for?'**
  String get onboardingAnalyticsTitle;

  /// No description provided for @onboardingAnalyticsBody.
  ///
  /// In en, this message translates to:
  /// **'Pick a starting point for {camera}. You can draw zones and lines and change every option later.'**
  String onboardingAnalyticsBody(String camera);

  /// No description provided for @presetPerimeter.
  ///
  /// In en, this message translates to:
  /// **'Perimeter'**
  String get presetPerimeter;

  /// No description provided for @presetPerimeterBody.
  ///
  /// In en, this message translates to:
  /// **'Alerts when people or vehicles enter the picture at night or when you are away.'**
  String get presetPerimeterBody;

  /// No description provided for @presetEntrance.
  ///
  /// In en, this message translates to:
  /// **'Entrance'**
  String get presetEntrance;

  /// No description provided for @presetEntranceBody.
  ///
  /// In en, this message translates to:
  /// **'Counts who goes in and out through a door or gate.'**
  String get presetEntranceBody;

  /// No description provided for @presetCounting.
  ///
  /// In en, this message translates to:
  /// **'Counting'**
  String get presetCounting;

  /// No description provided for @presetCountingBody.
  ///
  /// In en, this message translates to:
  /// **'Counts people and occupancy without alerts, for stores and offices.'**
  String get presetCountingBody;

  /// No description provided for @presetTamper.
  ///
  /// In en, this message translates to:
  /// **'Tamper only'**
  String get presetTamper;

  /// No description provided for @presetTamperBody.
  ///
  /// In en, this message translates to:
  /// **'Only tells you when the camera is covered, blurred, moved or too dark.'**
  String get presetTamperBody;

  /// No description provided for @onboardingNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Get alerts on this phone'**
  String get onboardingNotificationsTitle;

  /// No description provided for @onboardingNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications so the app can tell you about alerts while it is closed. Notifications carry no pictures; the app fetches them securely when you open one.'**
  String get onboardingNotificationsBody;

  /// No description provided for @onboardingNotificationsAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get onboardingNotificationsAllow;

  /// No description provided for @onboardingDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Your site is ready'**
  String get onboardingDoneTitle;

  /// No description provided for @onboardingDoneBody.
  ///
  /// In en, this message translates to:
  /// **'The cameras are live. Alerts follow the arm mode, which you can change on the Home tab.'**
  String get onboardingDoneBody;

  /// No description provided for @onboardingOpenHome.
  ///
  /// In en, this message translates to:
  /// **'Open Home'**
  String get onboardingOpenHome;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get navLive;

  /// No description provided for @navEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get navEvents;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @siteKindHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get siteKindHome;

  /// No description provided for @siteKindStore.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get siteKindStore;

  /// No description provided for @siteKindOffice.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get siteKindOffice;

  /// No description provided for @siteKindWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get siteKindWarehouse;

  /// No description provided for @siteKindOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get siteKindOther;

  /// No description provided for @siteSwitcherTitle.
  ///
  /// In en, this message translates to:
  /// **'Sites'**
  String get siteSwitcherTitle;

  /// No description provided for @siteSwitcherAdd.
  ///
  /// In en, this message translates to:
  /// **'Add a site'**
  String get siteSwitcherAdd;

  /// No description provided for @siteCameras.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No cameras} =1{1 camera} other{{count} cameras}}'**
  String siteCameras(int count);

  /// No description provided for @armDisarmed.
  ///
  /// In en, this message translates to:
  /// **'Disarmed'**
  String get armDisarmed;

  /// No description provided for @armHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get armHome;

  /// No description provided for @armAway.
  ///
  /// In en, this message translates to:
  /// **'Away'**
  String get armAway;

  /// No description provided for @armSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get armSchedule;

  /// No description provided for @armDisarmedBody.
  ///
  /// In en, this message translates to:
  /// **'No alerts. Events are still recorded.'**
  String get armDisarmedBody;

  /// No description provided for @armHomeBody.
  ///
  /// In en, this message translates to:
  /// **'Alerts only from zones and lines that alert while you are home.'**
  String get armHomeBody;

  /// No description provided for @armAwayBody.
  ///
  /// In en, this message translates to:
  /// **'Every zone and line alerts.'**
  String get armAwayBody;

  /// No description provided for @armScheduleBody.
  ///
  /// In en, this message translates to:
  /// **'Each zone and line alerts on its own schedule.'**
  String get armScheduleBody;

  /// No description provided for @armTitle.
  ///
  /// In en, this message translates to:
  /// **'Arm mode'**
  String get armTitle;

  /// No description provided for @armChanged.
  ///
  /// In en, this message translates to:
  /// **'Arm mode is now {mode}'**
  String armChanged(String mode);

  /// No description provided for @homeAlertsToday.
  ///
  /// In en, this message translates to:
  /// **'Alerts today'**
  String get homeAlertsToday;

  /// No description provided for @homeUnacknowledged.
  ///
  /// In en, this message translates to:
  /// **'{count} to review'**
  String homeUnacknowledged(int count);

  /// No description provided for @homeAllReviewed.
  ///
  /// In en, this message translates to:
  /// **'All reviewed'**
  String get homeAllReviewed;

  /// No description provided for @homeEventsToday.
  ///
  /// In en, this message translates to:
  /// **'Events today'**
  String get homeEventsToday;

  /// No description provided for @homeCamerasOnline.
  ///
  /// In en, this message translates to:
  /// **'Cameras online'**
  String get homeCamerasOnline;

  /// No description provided for @homeCamerasValue.
  ///
  /// In en, this message translates to:
  /// **'{online} of {total}'**
  String homeCamerasValue(int online, int total);

  /// No description provided for @homeOccupancy.
  ///
  /// In en, this message translates to:
  /// **'Inside now'**
  String get homeOccupancy;

  /// No description provided for @homeRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent events'**
  String get homeRecent;

  /// No description provided for @homeAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get homeAttention;

  /// No description provided for @homeAllGood.
  ///
  /// In en, this message translates to:
  /// **'All cameras and connectors are online'**
  String get homeAllGood;

  /// No description provided for @homeCameraOffline.
  ///
  /// In en, this message translates to:
  /// **'{camera} is offline'**
  String homeCameraOffline(String camera);

  /// No description provided for @homeConnectorOffline.
  ///
  /// In en, this message translates to:
  /// **'{connector} is offline, last seen {when}'**
  String homeConnectorOffline(String connector, String when);

  /// No description provided for @homeConnectorOnline.
  ///
  /// In en, this message translates to:
  /// **'{connector} online, version {version}'**
  String homeConnectorOnline(String connector, String version);

  /// No description provided for @homeCountsToday.
  ///
  /// In en, this message translates to:
  /// **'Visitors today'**
  String get homeCountsToday;

  /// No description provided for @homeCountsIn.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get homeCountsIn;

  /// No description provided for @homeCountsOut.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get homeCountsOut;

  /// No description provided for @homeNoSite.
  ///
  /// In en, this message translates to:
  /// **'No site yet'**
  String get homeNoSite;

  /// No description provided for @homeNoSiteBody.
  ///
  /// In en, this message translates to:
  /// **'Set up a site and pair its connector to start watching.'**
  String get homeNoSiteBody;

  /// No description provided for @homeSetUp.
  ///
  /// In en, this message translates to:
  /// **'Set up a site'**
  String get homeSetUp;

  /// No description provided for @homeNoEvents.
  ///
  /// In en, this message translates to:
  /// **'Quiet so far today'**
  String get homeNoEvents;

  /// No description provided for @liveTitle.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get liveTitle;

  /// No description provided for @liveLayoutAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get liveLayoutAuto;

  /// No description provided for @liveLayoutOne.
  ///
  /// In en, this message translates to:
  /// **'One column'**
  String get liveLayoutOne;

  /// No description provided for @liveLayoutTwo.
  ///
  /// In en, this message translates to:
  /// **'Two by two'**
  String get liveLayoutTwo;

  /// No description provided for @liveLayoutThree.
  ///
  /// In en, this message translates to:
  /// **'Three by three'**
  String get liveLayoutThree;

  /// No description provided for @liveLayout.
  ///
  /// In en, this message translates to:
  /// **'Layout'**
  String get liveLayout;

  /// No description provided for @liveNoCameras.
  ///
  /// In en, this message translates to:
  /// **'No cameras yet'**
  String get liveNoCameras;

  /// No description provided for @liveNoCamerasBody.
  ///
  /// In en, this message translates to:
  /// **'Add cameras from a paired connector to see them here.'**
  String get liveNoCamerasBody;

  /// No description provided for @liveAddCamera.
  ///
  /// In en, this message translates to:
  /// **'Add camera'**
  String get liveAddCamera;

  /// No description provided for @liveConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting'**
  String get liveConnecting;

  /// No description provided for @liveFailed.
  ///
  /// In en, this message translates to:
  /// **'Video unavailable'**
  String get liveFailed;

  /// No description provided for @liveCameraOffline.
  ///
  /// In en, this message translates to:
  /// **'Camera offline'**
  String get liveCameraOffline;

  /// No description provided for @liveBadge.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get liveBadge;

  /// No description provided for @liveLens.
  ///
  /// In en, this message translates to:
  /// **'Lens {lens}'**
  String liveLens(int lens);

  /// No description provided for @cameraMain.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get cameraMain;

  /// No description provided for @cameraSub.
  ///
  /// In en, this message translates to:
  /// **'Sub'**
  String get cameraSub;

  /// No description provided for @cameraQuality.
  ///
  /// In en, this message translates to:
  /// **'Stream'**
  String get cameraQuality;

  /// No description provided for @cameraSound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get cameraSound;

  /// No description provided for @cameraBoxes.
  ///
  /// In en, this message translates to:
  /// **'Show detections'**
  String get cameraBoxes;

  /// No description provided for @cameraFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Full screen'**
  String get cameraFullscreen;

  /// No description provided for @cameraSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Snapshot'**
  String get cameraSnapshot;

  /// No description provided for @cameraSnapshotSaved.
  ///
  /// In en, this message translates to:
  /// **'Snapshot saved'**
  String get cameraSnapshotSaved;

  /// No description provided for @cameraPtz.
  ///
  /// In en, this message translates to:
  /// **'Pan and tilt'**
  String get cameraPtz;

  /// No description provided for @cameraSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get cameraSpeed;

  /// No description provided for @cameraZoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get cameraZoomIn;

  /// No description provided for @cameraZoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get cameraZoomOut;

  /// No description provided for @cameraHome.
  ///
  /// In en, this message translates to:
  /// **'Home position'**
  String get cameraHome;

  /// No description provided for @cameraPresets.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get cameraPresets;

  /// No description provided for @cameraNoPresets.
  ///
  /// In en, this message translates to:
  /// **'No presets yet'**
  String get cameraNoPresets;

  /// No description provided for @cameraSavePreset.
  ///
  /// In en, this message translates to:
  /// **'Save position'**
  String get cameraSavePreset;

  /// No description provided for @cameraPresetName.
  ///
  /// In en, this message translates to:
  /// **'Preset name'**
  String get cameraPresetName;

  /// No description provided for @cameraLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get cameraLight;

  /// No description provided for @cameraSiren.
  ///
  /// In en, this message translates to:
  /// **'Siren'**
  String get cameraSiren;

  /// No description provided for @cameraSirenConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sound the siren for 10 seconds?'**
  String get cameraSirenConfirm;

  /// No description provided for @cameraSirenOn.
  ///
  /// In en, this message translates to:
  /// **'Siren sounding'**
  String get cameraSirenOn;

  /// No description provided for @cameraRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent on this camera'**
  String get cameraRecent;

  /// No description provided for @cameraSettings.
  ///
  /// In en, this message translates to:
  /// **'Camera settings'**
  String get cameraSettings;

  /// No description provided for @cameraAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get cameraAnalytics;

  /// No description provided for @ptzUp.
  ///
  /// In en, this message translates to:
  /// **'Tilt up'**
  String get ptzUp;

  /// No description provided for @ptzDown.
  ///
  /// In en, this message translates to:
  /// **'Tilt down'**
  String get ptzDown;

  /// No description provided for @ptzLeft.
  ///
  /// In en, this message translates to:
  /// **'Pan left'**
  String get ptzLeft;

  /// No description provided for @ptzRight.
  ///
  /// In en, this message translates to:
  /// **'Pan right'**
  String get ptzRight;

  /// No description provided for @eventsTitle.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get eventsTitle;

  /// No description provided for @eventsAlertsOnly.
  ///
  /// In en, this message translates to:
  /// **'Alerts only'**
  String get eventsAlertsOnly;

  /// No description provided for @eventsFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get eventsFilters;

  /// No description provided for @eventsFilterCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 filter} other{{count} filters}}'**
  String eventsFilterCount(int count);

  /// No description provided for @eventsNew.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 new event} other{{count} new events}}'**
  String eventsNew(int count);

  /// No description provided for @eventsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No events'**
  String get eventsEmpty;

  /// No description provided for @eventsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing matched. Try another day or fewer filters.'**
  String get eventsEmptyBody;

  /// No description provided for @eventsEmptyToday.
  ///
  /// In en, this message translates to:
  /// **'Nothing happened yet. Events appear here as the cameras see them.'**
  String get eventsEmptyToday;

  /// No description provided for @eventsAckAll.
  ///
  /// In en, this message translates to:
  /// **'Mark all reviewed'**
  String get eventsAckAll;

  /// No description provided for @eventsAckAllDone.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing to review} =1{1 alert reviewed} other{{count} alerts reviewed}}'**
  String eventsAckAllDone(int count);

  /// No description provided for @eventsTotal.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No events} =1{1 event} other{{count} events}}'**
  String eventsTotal(int count);

  /// No description provided for @eventsLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get eventsLoadMore;

  /// No description provided for @filterDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get filterDay;

  /// No description provided for @filterAnyDay.
  ///
  /// In en, this message translates to:
  /// **'Any day'**
  String get filterAnyDay;

  /// No description provided for @filterCameras.
  ///
  /// In en, this message translates to:
  /// **'Cameras'**
  String get filterCameras;

  /// No description provided for @filterViews.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get filterViews;

  /// No description provided for @filterKinds.
  ///
  /// In en, this message translates to:
  /// **'Kinds'**
  String get filterKinds;

  /// No description provided for @filterLabels.
  ///
  /// In en, this message translates to:
  /// **'Objects'**
  String get filterLabels;

  /// No description provided for @filterZones.
  ///
  /// In en, this message translates to:
  /// **'Zones'**
  String get filterZones;

  /// No description provided for @filterLines.
  ///
  /// In en, this message translates to:
  /// **'Lines'**
  String get filterLines;

  /// No description provided for @filterPerson.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get filterPerson;

  /// No description provided for @filterPlate.
  ///
  /// In en, this message translates to:
  /// **'Plate'**
  String get filterPlate;

  /// No description provided for @filterTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get filterTime;

  /// No description provided for @filterShow.
  ///
  /// In en, this message translates to:
  /// **'Show results'**
  String get filterShow;

  /// No description provided for @eventAlert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get eventAlert;

  /// No description provided for @eventReviewed.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get eventReviewed;

  /// No description provided for @eventOngoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get eventOngoing;

  /// No description provided for @eventAcknowledge.
  ///
  /// In en, this message translates to:
  /// **'Mark reviewed'**
  String get eventAcknowledge;

  /// No description provided for @eventAcknowledged.
  ///
  /// In en, this message translates to:
  /// **'Marked reviewed'**
  String get eventAcknowledged;

  /// No description provided for @eventShareClip.
  ///
  /// In en, this message translates to:
  /// **'Share clip'**
  String get eventShareClip;

  /// No description provided for @eventClip.
  ///
  /// In en, this message translates to:
  /// **'Clip'**
  String get eventClip;

  /// No description provided for @eventNoClip.
  ///
  /// In en, this message translates to:
  /// **'This event has no clip.'**
  String get eventNoClip;

  /// No description provided for @eventSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Snapshot'**
  String get eventSnapshot;

  /// No description provided for @eventDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get eventDetails;

  /// No description provided for @eventCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get eventCamera;

  /// No description provided for @eventView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get eventView;

  /// No description provided for @eventZone.
  ///
  /// In en, this message translates to:
  /// **'Zone'**
  String get eventZone;

  /// No description provided for @eventLine.
  ///
  /// In en, this message translates to:
  /// **'Line'**
  String get eventLine;

  /// No description provided for @eventDirection.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get eventDirection;

  /// No description provided for @eventDirectionIn.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get eventDirectionIn;

  /// No description provided for @eventDirectionOut.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get eventDirectionOut;

  /// No description provided for @eventObjects.
  ///
  /// In en, this message translates to:
  /// **'Objects'**
  String get eventObjects;

  /// No description provided for @eventDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get eventDuration;

  /// No description provided for @eventStarted.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get eventStarted;

  /// No description provided for @eventSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get eventSource;

  /// No description provided for @eventSourceCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get eventSourceCamera;

  /// No description provided for @eventSourceAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get eventSourceAnalytics;

  /// No description provided for @eventFace.
  ///
  /// In en, this message translates to:
  /// **'Face'**
  String get eventFace;

  /// No description provided for @eventConfidence.
  ///
  /// In en, this message translates to:
  /// **'{value}% match'**
  String eventConfidence(int value);

  /// No description provided for @eventPlate.
  ///
  /// In en, this message translates to:
  /// **'Number plate'**
  String get eventPlate;

  /// No description provided for @eventPlateReads.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 read} other{{count} reads}}'**
  String eventPlateReads(int count);

  /// No description provided for @plateInfrared.
  ///
  /// In en, this message translates to:
  /// **'Not read at night: infrared light glares on the plate.'**
  String get plateInfrared;

  /// No description provided for @plateNone.
  ///
  /// In en, this message translates to:
  /// **'No plate was found on the vehicle.'**
  String get plateNone;

  /// No description provided for @plateSmall.
  ///
  /// In en, this message translates to:
  /// **'The plate was too small to read.'**
  String get plateSmall;

  /// No description provided for @plateUnreadable.
  ///
  /// In en, this message translates to:
  /// **'The plate could not be read.'**
  String get plateUnreadable;

  /// No description provided for @platePending.
  ///
  /// In en, this message translates to:
  /// **'Reading the plate.'**
  String get platePending;

  /// No description provided for @eventJourney.
  ///
  /// In en, this message translates to:
  /// **'Journey'**
  String get eventJourney;

  /// No description provided for @eventFindPerson.
  ///
  /// In en, this message translates to:
  /// **'Find this person'**
  String get eventFindPerson;

  /// No description provided for @eventWhoIsThis.
  ///
  /// In en, this message translates to:
  /// **'Who is this?'**
  String get eventWhoIsThis;

  /// No description provided for @eventDemoClip.
  ///
  /// In en, this message translates to:
  /// **'Demo clip'**
  String get eventDemoClip;

  /// No description provided for @kindMotion.
  ///
  /// In en, this message translates to:
  /// **'Motion'**
  String get kindMotion;

  /// No description provided for @kindPerson.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get kindPerson;

  /// No description provided for @kindVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get kindVehicle;

  /// No description provided for @kindIntrusion.
  ///
  /// In en, this message translates to:
  /// **'Intrusion'**
  String get kindIntrusion;

  /// No description provided for @kindLineCrossing.
  ///
  /// In en, this message translates to:
  /// **'Line crossing'**
  String get kindLineCrossing;

  /// No description provided for @kindLoitering.
  ///
  /// In en, this message translates to:
  /// **'Loitering'**
  String get kindLoitering;

  /// No description provided for @kindCrowd.
  ///
  /// In en, this message translates to:
  /// **'Crowd'**
  String get kindCrowd;

  /// No description provided for @kindFaceKnown.
  ///
  /// In en, this message translates to:
  /// **'Known face'**
  String get kindFaceKnown;

  /// No description provided for @kindFaceUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown face'**
  String get kindFaceUnknown;

  /// No description provided for @kindTamper.
  ///
  /// In en, this message translates to:
  /// **'Tamper'**
  String get kindTamper;

  /// No description provided for @kindStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get kindStorage;

  /// No description provided for @kindReboot.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get kindReboot;

  /// No description provided for @kindAnimal.
  ///
  /// In en, this message translates to:
  /// **'Animal'**
  String get kindAnimal;

  /// No description provided for @kindObjectLeft.
  ///
  /// In en, this message translates to:
  /// **'Object left'**
  String get kindObjectLeft;

  /// No description provided for @kindObjectTaken.
  ///
  /// In en, this message translates to:
  /// **'Object taken'**
  String get kindObjectTaken;

  /// No description provided for @kindFall.
  ///
  /// In en, this message translates to:
  /// **'Fall'**
  String get kindFall;

  /// No description provided for @titleMotion.
  ///
  /// In en, this message translates to:
  /// **'Motion on {camera}'**
  String titleMotion(String camera);

  /// No description provided for @titlePerson.
  ///
  /// In en, this message translates to:
  /// **'Person on {camera}'**
  String titlePerson(String camera);

  /// No description provided for @titleVehicle.
  ///
  /// In en, this message translates to:
  /// **'{label} on {camera}'**
  String titleVehicle(String label, String camera);

  /// No description provided for @titleIntrusion.
  ///
  /// In en, this message translates to:
  /// **'{label} entered {zone}'**
  String titleIntrusion(String label, String zone);

  /// No description provided for @titleLineCrossing.
  ///
  /// In en, this message translates to:
  /// **'{label} crossed {line}'**
  String titleLineCrossing(String label, String line);

  /// No description provided for @titleLoitering.
  ///
  /// In en, this message translates to:
  /// **'{label} lingering in {zone}'**
  String titleLoitering(String label, String zone);

  /// No description provided for @titleCrowd.
  ///
  /// In en, this message translates to:
  /// **'Crowd in {zone}'**
  String titleCrowd(String zone);

  /// No description provided for @titleFaceKnown.
  ///
  /// In en, this message translates to:
  /// **'{name} seen'**
  String titleFaceKnown(String name);

  /// No description provided for @titleFaceUnknown.
  ///
  /// In en, this message translates to:
  /// **'{label} seen'**
  String titleFaceUnknown(String label);

  /// No description provided for @titleTamper.
  ///
  /// In en, this message translates to:
  /// **'{camera} view {how}'**
  String titleTamper(String camera, String how);

  /// No description provided for @titleAnimal.
  ///
  /// In en, this message translates to:
  /// **'{label} on {camera}'**
  String titleAnimal(String label, String camera);

  /// No description provided for @titleObjectLeft.
  ///
  /// In en, this message translates to:
  /// **'{label} left in {zone}'**
  String titleObjectLeft(String label, String zone);

  /// No description provided for @titleObjectTaken.
  ///
  /// In en, this message translates to:
  /// **'{label} taken from {zone}'**
  String titleObjectTaken(String label, String zone);

  /// No description provided for @titleFall.
  ///
  /// In en, this message translates to:
  /// **'Possible fall on {camera}'**
  String titleFall(String camera);

  /// No description provided for @titleStorage.
  ///
  /// In en, this message translates to:
  /// **'{camera} storage problem'**
  String titleStorage(String camera);

  /// No description provided for @titleReboot.
  ///
  /// In en, this message translates to:
  /// **'{camera} restarted'**
  String titleReboot(String camera);

  /// No description provided for @tamperCovered.
  ///
  /// In en, this message translates to:
  /// **'covered'**
  String get tamperCovered;

  /// No description provided for @tamperBlurred.
  ///
  /// In en, this message translates to:
  /// **'blurred'**
  String get tamperBlurred;

  /// No description provided for @tamperDark.
  ///
  /// In en, this message translates to:
  /// **'too dark'**
  String get tamperDark;

  /// No description provided for @tamperMoved.
  ///
  /// In en, this message translates to:
  /// **'moved'**
  String get tamperMoved;

  /// No description provided for @tamperDisturbed.
  ///
  /// In en, this message translates to:
  /// **'disturbed'**
  String get tamperDisturbed;

  /// No description provided for @labelPerson.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get labelPerson;

  /// No description provided for @labelCar.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get labelCar;

  /// No description provided for @labelTruck.
  ///
  /// In en, this message translates to:
  /// **'Truck'**
  String get labelTruck;

  /// No description provided for @labelBus.
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get labelBus;

  /// No description provided for @labelMotorcycle.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle'**
  String get labelMotorcycle;

  /// No description provided for @labelBicycle.
  ///
  /// In en, this message translates to:
  /// **'Bicycle'**
  String get labelBicycle;

  /// No description provided for @labelDog.
  ///
  /// In en, this message translates to:
  /// **'Dog'**
  String get labelDog;

  /// No description provided for @labelCat.
  ///
  /// In en, this message translates to:
  /// **'Cat'**
  String get labelCat;

  /// No description provided for @labelBird.
  ///
  /// In en, this message translates to:
  /// **'Bird'**
  String get labelBird;

  /// No description provided for @labelBackpack.
  ///
  /// In en, this message translates to:
  /// **'Backpack'**
  String get labelBackpack;

  /// No description provided for @labelHandbag.
  ///
  /// In en, this message translates to:
  /// **'Handbag'**
  String get labelHandbag;

  /// No description provided for @labelSuitcase.
  ///
  /// In en, this message translates to:
  /// **'Suitcase'**
  String get labelSuitcase;

  /// No description provided for @labelVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get labelVehicle;

  /// No description provided for @labelAnimal.
  ///
  /// In en, this message translates to:
  /// **'Animal'**
  String get labelAnimal;

  /// No description provided for @labelSomething.
  ///
  /// In en, this message translates to:
  /// **'Something'**
  String get labelSomething;

  /// No description provided for @labelObject.
  ///
  /// In en, this message translates to:
  /// **'Object'**
  String get labelObject;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get searchEvents;

  /// No description provided for @searchPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get searchPeople;

  /// No description provided for @searchFaces.
  ///
  /// In en, this message translates to:
  /// **'Faces'**
  String get searchFaces;

  /// No description provided for @searchPlates.
  ///
  /// In en, this message translates to:
  /// **'Plates'**
  String get searchPlates;

  /// No description provided for @searchFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get searchFrom;

  /// No description provided for @searchUntil.
  ///
  /// In en, this message translates to:
  /// **'Until'**
  String get searchUntil;

  /// No description provided for @searchLast24h.
  ///
  /// In en, this message translates to:
  /// **'Last 24 hours'**
  String get searchLast24h;

  /// No description provided for @searchLast7d.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get searchLast7d;

  /// No description provided for @searchLast30d.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get searchLast30d;

  /// No description provided for @searchRun.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchRun;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No results} =1{1 result} other{{count} results}}'**
  String searchResults(int count);

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Build a query from time, cameras, kinds and objects.'**
  String get searchHint;

  /// No description provided for @searchFacesTitle.
  ///
  /// In en, this message translates to:
  /// **'Find a face'**
  String get searchFacesTitle;

  /// No description provided for @searchFacesBody.
  ///
  /// In en, this message translates to:
  /// **'Pick a photo with one face, or tap a face the cameras saw, to find where it appeared.'**
  String get searchFacesBody;

  /// No description provided for @searchFacesPhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose a photo'**
  String get searchFacesPhoto;

  /// No description provided for @searchFacesCamera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get searchFacesCamera;

  /// No description provided for @searchFacesResults.
  ///
  /// In en, this message translates to:
  /// **'Similar faces'**
  String get searchFacesResults;

  /// No description provided for @searchPlatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Find a vehicle by plate'**
  String get searchPlatesTitle;

  /// No description provided for @searchPlatesHint.
  ///
  /// In en, this message translates to:
  /// **'Plate text, for example 01 A 123 BC'**
  String get searchPlatesHint;

  /// No description provided for @searchPlatesBody.
  ///
  /// In en, this message translates to:
  /// **'Plates are read by day on views where plate reading is on.'**
  String get searchPlatesBody;

  /// No description provided for @facesOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Face recognition is off'**
  String get facesOffTitle;

  /// No description provided for @facesOffBody.
  ///
  /// In en, this message translates to:
  /// **'An owner or admin can turn it on for the organisation in More, Faces.'**
  String get facesOffBody;

  /// No description provided for @facesTurnOn.
  ///
  /// In en, this message translates to:
  /// **'Open face settings'**
  String get facesTurnOn;

  /// No description provided for @peopleKnown.
  ///
  /// In en, this message translates to:
  /// **'Known people'**
  String get peopleKnown;

  /// No description provided for @peopleUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown faces'**
  String get peopleUnknown;

  /// No description provided for @peopleAdd.
  ///
  /// In en, this message translates to:
  /// **'Add person'**
  String get peopleAdd;

  /// No description provided for @peopleEmpty.
  ///
  /// In en, this message translates to:
  /// **'No people yet'**
  String get peopleEmpty;

  /// No description provided for @peopleEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add the people you know, or name the unknown faces the cameras gather.'**
  String get peopleEmptyBody;

  /// No description provided for @peopleSeen.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Seen once} other{Seen {count} times}}'**
  String peopleSeen(int count);

  /// No description provided for @peopleLastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen {when}'**
  String peopleLastSeen(String when);

  /// No description provided for @peopleNeverSeen.
  ///
  /// In en, this message translates to:
  /// **'Not seen yet'**
  String get peopleNeverSeen;

  /// No description provided for @peopleSamples.
  ///
  /// In en, this message translates to:
  /// **'Faces'**
  String get peopleSamples;

  /// No description provided for @peopleSightings.
  ///
  /// In en, this message translates to:
  /// **'Sightings'**
  String get peopleSightings;

  /// No description provided for @peopleNoSightings.
  ///
  /// In en, this message translates to:
  /// **'No sightings yet'**
  String get peopleNoSightings;

  /// No description provided for @peopleAddPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add photos'**
  String get peopleAddPhotos;

  /// No description provided for @peoplePhotosAdded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No photos added} =1{1 photo added} other{{count} photos added}}'**
  String peoplePhotosAdded(int count);

  /// No description provided for @peoplePhotosRejected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo had no single clear face} other{{count} photos had no single clear face}}'**
  String peoplePhotosRejected(int count);

  /// No description provided for @peopleMerge.
  ///
  /// In en, this message translates to:
  /// **'Merge into another person'**
  String get peopleMerge;

  /// No description provided for @peopleMergeTitle.
  ///
  /// In en, this message translates to:
  /// **'Merge {name} into'**
  String peopleMergeTitle(String name);

  /// No description provided for @peopleDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete person'**
  String get peopleDelete;

  /// No description provided for @peopleDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This deletes {name} with every face sample and crop. Past events keep their snapshots.'**
  String peopleDeleteBody(String name);

  /// No description provided for @peopleNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get peopleNotes;

  /// No description provided for @peopleName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get peopleName;

  /// No description provided for @clusterWhoTitle.
  ///
  /// In en, this message translates to:
  /// **'Who is this?'**
  String get clusterWhoTitle;

  /// No description provided for @clusterWhoBody.
  ///
  /// In en, this message translates to:
  /// **'Name a new person or pick someone you know. Their past events are relabelled.'**
  String get clusterWhoBody;

  /// No description provided for @clusterNewPerson.
  ///
  /// In en, this message translates to:
  /// **'New person'**
  String get clusterNewPerson;

  /// No description provided for @clusterExisting.
  ///
  /// In en, this message translates to:
  /// **'Someone you know'**
  String get clusterExisting;

  /// No description provided for @clusterNamed.
  ///
  /// In en, this message translates to:
  /// **'Named as {name}'**
  String clusterNamed(String name);

  /// No description provided for @clusterDelete.
  ///
  /// In en, this message translates to:
  /// **'Forget these faces'**
  String get clusterDelete;

  /// No description provided for @clusterDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This deletes the unknown face samples. Past events keep their snapshots.'**
  String get clusterDeleteBody;

  /// No description provided for @findPersonTitle.
  ///
  /// In en, this message translates to:
  /// **'Find this person'**
  String get findPersonTitle;

  /// No description provided for @findPersonBody.
  ///
  /// In en, this message translates to:
  /// **'Sightings on other cameras that look like the same person, by clothing and build. Day and night pictures do not match each other.'**
  String get findPersonBody;

  /// No description provided for @findPersonEmpty.
  ///
  /// In en, this message translates to:
  /// **'No similar sightings found'**
  String get findPersonEmpty;

  /// No description provided for @findPersonMatch.
  ///
  /// In en, this message translates to:
  /// **'{value}% similar'**
  String findPersonMatch(int value);

  /// No description provided for @moreTitle.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreTitle;

  /// No description provided for @moreSite.
  ///
  /// In en, this message translates to:
  /// **'This site'**
  String get moreSite;

  /// No description provided for @moreOrganisation.
  ///
  /// In en, this message translates to:
  /// **'Organisation'**
  String get moreOrganisation;

  /// No description provided for @moreYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get moreYou;

  /// No description provided for @moreCounts.
  ///
  /// In en, this message translates to:
  /// **'Counts and occupancy'**
  String get moreCounts;

  /// No description provided for @moreSiteSettings.
  ///
  /// In en, this message translates to:
  /// **'Site settings'**
  String get moreSiteSettings;

  /// No description provided for @moreCameras.
  ///
  /// In en, this message translates to:
  /// **'Cameras'**
  String get moreCameras;

  /// No description provided for @moreAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get moreAnalytics;

  /// No description provided for @moreConnectors.
  ///
  /// In en, this message translates to:
  /// **'Connectors'**
  String get moreConnectors;

  /// No description provided for @moreHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get moreHealth;

  /// No description provided for @moreMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get moreMembers;

  /// No description provided for @moreFaces.
  ///
  /// In en, this message translates to:
  /// **'Faces'**
  String get moreFaces;

  /// No description provided for @moreNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get moreNotifications;

  /// No description provided for @moreAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get moreAccount;

  /// No description provided for @moreAppearance.
  ///
  /// In en, this message translates to:
  /// **'Language and theme'**
  String get moreAppearance;

  /// No description provided for @moreAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get moreAbout;

  /// No description provided for @moreSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get moreSignOut;

  /// No description provided for @moreSignOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign out of this phone?'**
  String get moreSignOutConfirm;

  /// No description provided for @countsTitle.
  ///
  /// In en, this message translates to:
  /// **'Counts'**
  String get countsTitle;

  /// No description provided for @countsHourly.
  ///
  /// In en, this message translates to:
  /// **'By hour'**
  String get countsHourly;

  /// No description provided for @countsDaily.
  ///
  /// In en, this message translates to:
  /// **'By day'**
  String get countsDaily;

  /// No description provided for @countsIn.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get countsIn;

  /// No description provided for @countsOut.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get countsOut;

  /// No description provided for @countsTotalIn.
  ///
  /// In en, this message translates to:
  /// **'{count} in'**
  String countsTotalIn(int count);

  /// No description provided for @countsTotalOut.
  ///
  /// In en, this message translates to:
  /// **'{count} out'**
  String countsTotalOut(int count);

  /// No description provided for @countsNoLines.
  ///
  /// In en, this message translates to:
  /// **'No counting lines'**
  String get countsNoLines;

  /// No description provided for @countsNoLinesBody.
  ///
  /// In en, this message translates to:
  /// **'Draw a line on a view in Analytics to count people and vehicles crossing it.'**
  String get countsNoLinesBody;

  /// No description provided for @countsAreas.
  ///
  /// In en, this message translates to:
  /// **'Areas'**
  String get countsAreas;

  /// No description provided for @countsOccupancy.
  ///
  /// In en, this message translates to:
  /// **'{count} inside'**
  String countsOccupancy(int count);

  /// No description provided for @countsCapacity.
  ///
  /// In en, this message translates to:
  /// **'of {count}'**
  String countsCapacity(int count);

  /// No description provided for @countsSince.
  ///
  /// In en, this message translates to:
  /// **'Entered {entered}, left {exited} since {time}'**
  String countsSince(int entered, int exited, String time);

  /// No description provided for @countsReset.
  ///
  /// In en, this message translates to:
  /// **'Set occupancy'**
  String get countsReset;

  /// No description provided for @countsResetTitle.
  ///
  /// In en, this message translates to:
  /// **'How many are inside now?'**
  String get countsResetTitle;

  /// No description provided for @countsResetDone.
  ///
  /// In en, this message translates to:
  /// **'Occupancy set to {count}'**
  String countsResetDone(int count);

  /// No description provided for @countsDailyReset.
  ///
  /// In en, this message translates to:
  /// **'Resets every day at {time}'**
  String countsDailyReset(String time);

  /// No description provided for @countsPeak.
  ///
  /// In en, this message translates to:
  /// **'Busiest hour {hour}'**
  String countsPeak(String hour);

  /// No description provided for @siteSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Site settings'**
  String get siteSettingsTitle;

  /// No description provided for @siteRetention.
  ///
  /// In en, this message translates to:
  /// **'Keep events for'**
  String get siteRetention;

  /// No description provided for @siteRetentionDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String siteRetentionDays(int count);

  /// No description provided for @siteArmHelp.
  ///
  /// In en, this message translates to:
  /// **'The arm mode decides which events alert. In Schedule mode every zone and line follows its own alert hours, which you set in Analytics.'**
  String get siteArmHelp;

  /// No description provided for @camerasTitle.
  ///
  /// In en, this message translates to:
  /// **'Cameras'**
  String get camerasTitle;

  /// No description provided for @camerasReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to change the order of the live grid.'**
  String get camerasReorder;

  /// No description provided for @camerasAdd.
  ///
  /// In en, this message translates to:
  /// **'Add camera'**
  String get camerasAdd;

  /// No description provided for @camerasDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete camera'**
  String get camerasDelete;

  /// No description provided for @camerasDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This removes {camera} with its views, zones and lines. Its past events stay until they expire.'**
  String camerasDeleteBody(String camera);

  /// No description provided for @camerasEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get camerasEnabled;

  /// No description provided for @camerasNoConnector.
  ///
  /// In en, this message translates to:
  /// **'Pair a connector first'**
  String get camerasNoConnector;

  /// No description provided for @camerasNoConnectorBody.
  ///
  /// In en, this message translates to:
  /// **'Cameras are found and added through the connector at the site.'**
  String get camerasNoConnectorBody;

  /// No description provided for @settingsDevice.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get settingsDevice;

  /// No description provided for @settingsManufacturer.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer'**
  String get settingsManufacturer;

  /// No description provided for @settingsModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get settingsModel;

  /// No description provided for @settingsFirmware.
  ///
  /// In en, this message translates to:
  /// **'Firmware'**
  String get settingsFirmware;

  /// No description provided for @settingsVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get settingsVideo;

  /// No description provided for @settingsImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get settingsImage;

  /// No description provided for @settingsBrightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get settingsBrightness;

  /// No description provided for @settingsContrast.
  ///
  /// In en, this message translates to:
  /// **'Contrast'**
  String get settingsContrast;

  /// No description provided for @settingsSaturation.
  ///
  /// In en, this message translates to:
  /// **'Saturation'**
  String get settingsSaturation;

  /// No description provided for @settingsSharpness.
  ///
  /// In en, this message translates to:
  /// **'Sharpness'**
  String get settingsSharpness;

  /// No description provided for @settingsIrCut.
  ///
  /// In en, this message translates to:
  /// **'Night mode filter'**
  String get settingsIrCut;

  /// No description provided for @settingsMotion.
  ///
  /// In en, this message translates to:
  /// **'Camera motion detection'**
  String get settingsMotion;

  /// No description provided for @settingsSensitivity.
  ///
  /// In en, this message translates to:
  /// **'Sensitivity'**
  String get settingsSensitivity;

  /// No description provided for @settingsClock.
  ///
  /// In en, this message translates to:
  /// **'Clock'**
  String get settingsClock;

  /// No description provided for @settingsClockOffset.
  ///
  /// In en, this message translates to:
  /// **'{value} s from the server'**
  String settingsClockOffset(String value);

  /// No description provided for @settingsSyncClock.
  ///
  /// In en, this message translates to:
  /// **'Sync clock'**
  String get settingsSyncClock;

  /// No description provided for @settingsClockSynced.
  ///
  /// In en, this message translates to:
  /// **'Clock synced'**
  String get settingsClockSynced;

  /// No description provided for @settingsReboot.
  ///
  /// In en, this message translates to:
  /// **'Restart camera'**
  String get settingsReboot;

  /// No description provided for @settingsRebootBody.
  ///
  /// In en, this message translates to:
  /// **'The camera drops its video for about a minute.'**
  String get settingsRebootBody;

  /// No description provided for @settingsRebooting.
  ///
  /// In en, this message translates to:
  /// **'Restarting the camera'**
  String get settingsRebooting;

  /// No description provided for @settingsUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This camera does not offer this setting.'**
  String get settingsUnsupported;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTitle;

  /// No description provided for @analyticsViewsBody.
  ///
  /// In en, this message translates to:
  /// **'Each lens is a view. Choose what it watches and draw its zones and lines.'**
  String get analyticsViewsBody;

  /// No description provided for @analyticsZonesLines.
  ///
  /// In en, this message translates to:
  /// **'{zones, plural, =0{No zones} =1{1 zone} other{{zones} zones}}, {lines, plural, =0{no lines} =1{1 line} other{{lines} lines}}'**
  String analyticsZonesLines(int zones, int lines);

  /// No description provided for @analyticsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Analytics off'**
  String get analyticsDisabled;

  /// No description provided for @analyticsFps.
  ///
  /// In en, this message translates to:
  /// **'{value} fps'**
  String analyticsFps(String value);

  /// No description provided for @analyticsSuspended.
  ///
  /// In en, this message translates to:
  /// **'Lens turned away from its zones'**
  String get analyticsSuspended;

  /// No description provided for @analyticsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Analyse this view'**
  String get analyticsEnabled;

  /// No description provided for @analyticsProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get analyticsProfile;

  /// No description provided for @profilePerimeter.
  ///
  /// In en, this message translates to:
  /// **'Perimeter'**
  String get profilePerimeter;

  /// No description provided for @profileVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get profileVehicle;

  /// No description provided for @profileIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get profileIdentity;

  /// No description provided for @profileTamper.
  ///
  /// In en, this message translates to:
  /// **'Tamper only'**
  String get profileTamper;

  /// No description provided for @analyticsStream.
  ///
  /// In en, this message translates to:
  /// **'Analysed stream'**
  String get analyticsStream;

  /// No description provided for @analyticsStreamSub.
  ///
  /// In en, this message translates to:
  /// **'Sub stream, for detection and counting'**
  String get analyticsStreamSub;

  /// No description provided for @analyticsStreamMain.
  ///
  /// In en, this message translates to:
  /// **'Main stream, for faces and plates'**
  String get analyticsStreamMain;

  /// No description provided for @analyticsFeatures.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get analyticsFeatures;

  /// No description provided for @featureTamper.
  ///
  /// In en, this message translates to:
  /// **'Tamper watch'**
  String get featureTamper;

  /// No description provided for @featureTamperBody.
  ///
  /// In en, this message translates to:
  /// **'Covered, blurred, moved and too dark'**
  String get featureTamperBody;

  /// No description provided for @featureFaces.
  ///
  /// In en, this message translates to:
  /// **'Faces'**
  String get featureFaces;

  /// No description provided for @featureFacesBody.
  ///
  /// In en, this message translates to:
  /// **'Name known people, gather unknown faces'**
  String get featureFacesBody;

  /// No description provided for @featureFacesLocked.
  ///
  /// In en, this message translates to:
  /// **'Turn on faces for the organisation first'**
  String get featureFacesLocked;

  /// No description provided for @featureAppearance.
  ///
  /// In en, this message translates to:
  /// **'Journeys'**
  String get featureAppearance;

  /// No description provided for @featureAppearanceBody.
  ///
  /// In en, this message translates to:
  /// **'Link a person across cameras by appearance'**
  String get featureAppearanceBody;

  /// No description provided for @featureFalls.
  ///
  /// In en, this message translates to:
  /// **'Falls'**
  String get featureFalls;

  /// No description provided for @featureFallsBody.
  ///
  /// In en, this message translates to:
  /// **'Alert when someone falls and stays down'**
  String get featureFallsBody;

  /// No description provided for @featurePlates.
  ///
  /// In en, this message translates to:
  /// **'Number plates'**
  String get featurePlates;

  /// No description provided for @featurePlatesBody.
  ///
  /// In en, this message translates to:
  /// **'Read plates on vehicle events by day'**
  String get featurePlatesBody;

  /// No description provided for @featureFollow.
  ///
  /// In en, this message translates to:
  /// **'Auto follow'**
  String get featureFollow;

  /// No description provided for @featureFollowBody.
  ///
  /// In en, this message translates to:
  /// **'Turn the lens to keep a person in view, then return'**
  String get featureFollowBody;

  /// No description provided for @featureMoving.
  ///
  /// In en, this message translates to:
  /// **'Moving lens'**
  String get featureMoving;

  /// No description provided for @featureMovingBody.
  ///
  /// In en, this message translates to:
  /// **'Zones keep the picture they were drawn on'**
  String get featureMovingBody;

  /// No description provided for @analyticsRules.
  ///
  /// In en, this message translates to:
  /// **'Zones and lines'**
  String get analyticsRules;

  /// No description provided for @analyticsEdit.
  ///
  /// In en, this message translates to:
  /// **'Draw zones and lines'**
  String get analyticsEdit;

  /// No description provided for @analyticsNoRules.
  ///
  /// In en, this message translates to:
  /// **'No zones or lines yet'**
  String get analyticsNoRules;

  /// No description provided for @analyticsWholeView.
  ///
  /// In en, this message translates to:
  /// **'Whole view'**
  String get analyticsWholeView;

  /// No description provided for @editorTitle.
  ///
  /// In en, this message translates to:
  /// **'Zones and lines'**
  String get editorTitle;

  /// No description provided for @editorZone.
  ///
  /// In en, this message translates to:
  /// **'Zone'**
  String get editorZone;

  /// No description provided for @editorLine.
  ///
  /// In en, this message translates to:
  /// **'Line'**
  String get editorLine;

  /// No description provided for @editorAddZone.
  ///
  /// In en, this message translates to:
  /// **'New zone'**
  String get editorAddZone;

  /// No description provided for @editorAddLine.
  ///
  /// In en, this message translates to:
  /// **'New line'**
  String get editorAddLine;

  /// No description provided for @editorHintZone.
  ///
  /// In en, this message translates to:
  /// **'Tap the picture to place corners. Drag a corner to move it.'**
  String get editorHintZone;

  /// No description provided for @editorHintLine.
  ///
  /// In en, this message translates to:
  /// **'Tap two points for the line. The arrow shows the inward side.'**
  String get editorHintLine;

  /// No description provided for @editorUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo point'**
  String get editorUndo;

  /// No description provided for @editorFlip.
  ///
  /// In en, this message translates to:
  /// **'Flip direction'**
  String get editorFlip;

  /// No description provided for @editorDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete shape'**
  String get editorDelete;

  /// No description provided for @editorDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get editorDiscard;

  /// No description provided for @editorDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'Your zones and lines are not saved yet.'**
  String get editorDiscardBody;

  /// No description provided for @editorKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get editorKeepEditing;

  /// No description provided for @editorSaved.
  ///
  /// In en, this message translates to:
  /// **'Zones and lines saved. They apply within a few seconds.'**
  String get editorSaved;

  /// No description provided for @editorNameZone.
  ///
  /// In en, this message translates to:
  /// **'Zone name'**
  String get editorNameZone;

  /// No description provided for @editorNameLine.
  ///
  /// In en, this message translates to:
  /// **'Line name'**
  String get editorNameLine;

  /// No description provided for @editorObjects.
  ///
  /// In en, this message translates to:
  /// **'Watch for'**
  String get editorObjects;

  /// No description provided for @editorDwell.
  ///
  /// In en, this message translates to:
  /// **'Minimum time inside'**
  String get editorDwell;

  /// No description provided for @editorLoiter.
  ///
  /// In en, this message translates to:
  /// **'Loitering after'**
  String get editorLoiter;

  /// No description provided for @editorCrowd.
  ///
  /// In en, this message translates to:
  /// **'Crowd from'**
  String get editorCrowd;

  /// No description provided for @editorCrowdPeople.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Off} =1{1 person} other{{count} people}}'**
  String editorCrowdPeople(int count);

  /// No description provided for @editorLeft.
  ///
  /// In en, this message translates to:
  /// **'Object left after'**
  String get editorLeft;

  /// No description provided for @editorTaken.
  ///
  /// In en, this message translates to:
  /// **'Object taken after'**
  String get editorTaken;

  /// No description provided for @editorAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get editorAlerts;

  /// No description provided for @editorAlertOff.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get editorAlertOff;

  /// No description provided for @editorAlertAlways.
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get editorAlertAlways;

  /// No description provided for @editorAlertSchedule.
  ///
  /// In en, this message translates to:
  /// **'On a schedule'**
  String get editorAlertSchedule;

  /// No description provided for @editorAlertHours.
  ///
  /// In en, this message translates to:
  /// **'Alert between {start} and {end}'**
  String editorAlertHours(String start, String end);

  /// No description provided for @editorAnimals.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get editorAnimals;

  /// No description provided for @editorAnimalsInclude.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get editorAnimalsInclude;

  /// No description provided for @editorAnimalsRecord.
  ///
  /// In en, this message translates to:
  /// **'Record only'**
  String get editorAnimalsRecord;

  /// No description provided for @editorAnimalsExclude.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get editorAnimalsExclude;

  /// No description provided for @editorDirection.
  ///
  /// In en, this message translates to:
  /// **'Count direction'**
  String get editorDirection;

  /// No description provided for @editorDirectionIn.
  ///
  /// In en, this message translates to:
  /// **'Inward'**
  String get editorDirectionIn;

  /// No description provided for @editorDirectionOut.
  ///
  /// In en, this message translates to:
  /// **'Outward'**
  String get editorDirectionOut;

  /// No description provided for @editorDirectionBoth.
  ///
  /// In en, this message translates to:
  /// **'Both ways'**
  String get editorDirectionBoth;

  /// No description provided for @editorDurationOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get editorDurationOff;

  /// No description provided for @editorEnabled.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get editorEnabled;

  /// No description provided for @editorTooFewPoints.
  ///
  /// In en, this message translates to:
  /// **'A zone needs at least 3 corners.'**
  String get editorTooFewPoints;

  /// No description provided for @connectorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Connectors'**
  String get connectorsTitle;

  /// No description provided for @connectorsPair.
  ///
  /// In en, this message translates to:
  /// **'Pair a connector'**
  String get connectorsPair;

  /// No description provided for @connectorsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No connector yet'**
  String get connectorsEmpty;

  /// No description provided for @connectorsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'A connector at the site finds the cameras and links them to the server.'**
  String get connectorsEmptyBody;

  /// No description provided for @connectorsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String connectorsVersion(String version);

  /// No description provided for @connectorsSeen.
  ///
  /// In en, this message translates to:
  /// **'Seen {when}'**
  String connectorsSeen(String when);

  /// No description provided for @connectorsRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove connector'**
  String get connectorsRemove;

  /// No description provided for @connectorsRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'Its cameras stop until another connector is paired with this site.'**
  String get connectorsRemoveBody;

  /// No description provided for @connectorsMode.
  ///
  /// In en, this message translates to:
  /// **'Direct connection'**
  String get connectorsMode;

  /// No description provided for @connectorsFind.
  ///
  /// In en, this message translates to:
  /// **'Find cameras'**
  String get connectorsFind;

  /// No description provided for @membersTitle.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get membersTitle;

  /// No description provided for @membersInvite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get membersInvite;

  /// No description provided for @membersInvited.
  ///
  /// In en, this message translates to:
  /// **'Invited'**
  String get membersInvited;

  /// No description provided for @membersYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get membersYou;

  /// No description provided for @membersAllSites.
  ///
  /// In en, this message translates to:
  /// **'All sites'**
  String get membersAllSites;

  /// No description provided for @membersSomeSites.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 site} other{{count} sites}}'**
  String membersSomeSites(int count);

  /// No description provided for @membersPending.
  ///
  /// In en, this message translates to:
  /// **'Pending invitations'**
  String get membersPending;

  /// No description provided for @membersExpires.
  ///
  /// In en, this message translates to:
  /// **'Expires {date}'**
  String membersExpires(String date);

  /// No description provided for @membersRevoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke invitation'**
  String get membersRevoke;

  /// No description provided for @membersRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from organisation'**
  String get membersRemove;

  /// No description provided for @membersRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'{name} loses access to every site of the organisation at once.'**
  String membersRemoveBody(String name);

  /// No description provided for @membersRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get membersRole;

  /// No description provided for @membersSites.
  ///
  /// In en, this message translates to:
  /// **'Sites'**
  String get membersSites;

  /// No description provided for @membersInviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite a member'**
  String get membersInviteTitle;

  /// No description provided for @membersInviteBody.
  ///
  /// In en, this message translates to:
  /// **'They get an email with a link that works once, for 7 days.'**
  String get membersInviteBody;

  /// No description provided for @membersInviteSent.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent to {email}'**
  String membersInviteSent(String email);

  /// No description provided for @roleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get roleOwner;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleOperator.
  ///
  /// In en, this message translates to:
  /// **'Operator'**
  String get roleOperator;

  /// No description provided for @roleViewer.
  ///
  /// In en, this message translates to:
  /// **'Viewer'**
  String get roleViewer;

  /// No description provided for @roleOwnerBody.
  ///
  /// In en, this message translates to:
  /// **'Everything, including deleting the organisation'**
  String get roleOwnerBody;

  /// No description provided for @roleAdminBody.
  ///
  /// In en, this message translates to:
  /// **'Cameras, analytics, people and members'**
  String get roleAdminBody;

  /// No description provided for @roleOperatorBody.
  ///
  /// In en, this message translates to:
  /// **'Watch, control cameras and arm or disarm'**
  String get roleOperatorBody;

  /// No description provided for @roleViewerBody.
  ///
  /// In en, this message translates to:
  /// **'Watch live video and events'**
  String get roleViewerBody;

  /// No description provided for @facesTitle.
  ///
  /// In en, this message translates to:
  /// **'Face recognition'**
  String get facesTitle;

  /// No description provided for @facesBody.
  ///
  /// In en, this message translates to:
  /// **'Faces are matched on the server of this organisation. Turn this on only where people who are filmed have been told and agree, as the law of your country requires.'**
  String get facesBody;

  /// No description provided for @facesConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on face recognition?'**
  String get facesConsentTitle;

  /// No description provided for @facesConsentBody.
  ///
  /// In en, this message translates to:
  /// **'Face recognition stores face pictures and face measurements of everyone the cameras see on views where faces are on. Face measurements are biometric data. You confirm that the people who are filmed have been informed, that you have a lawful reason to process their faces, and that the data is kept only as long as needed. You can turn this off at any time; known people and their faces then stay until you delete them.'**
  String get facesConsentBody;

  /// No description provided for @facesConsentConfirm.
  ///
  /// In en, this message translates to:
  /// **'I understand, turn on'**
  String get facesConsentConfirm;

  /// No description provided for @facesEnabled.
  ///
  /// In en, this message translates to:
  /// **'Face recognition on'**
  String get facesEnabled;

  /// No description provided for @facesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Face recognition off'**
  String get facesDisabled;

  /// No description provided for @facesOwnerOnly.
  ///
  /// In en, this message translates to:
  /// **'Only an owner or admin can change this.'**
  String get facesOwnerOnly;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsSite.
  ///
  /// In en, this message translates to:
  /// **'Alerts for {site}'**
  String notificationsSite(String site);

  /// No description provided for @notificationsAlertsOnly.
  ///
  /// In en, this message translates to:
  /// **'Only alerts'**
  String get notificationsAlertsOnly;

  /// No description provided for @notificationsAlertsOnlyBody.
  ///
  /// In en, this message translates to:
  /// **'Off sends every event, which can be many.'**
  String get notificationsAlertsOnlyBody;

  /// No description provided for @notificationsKinds.
  ///
  /// In en, this message translates to:
  /// **'Kinds'**
  String get notificationsKinds;

  /// No description provided for @notificationsQuiet.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours'**
  String get notificationsQuiet;

  /// No description provided for @notificationsQuietBody.
  ///
  /// In en, this message translates to:
  /// **'Silent between {from} and {until}'**
  String notificationsQuietBody(String from, String until);

  /// No description provided for @notificationsQuietOff.
  ///
  /// In en, this message translates to:
  /// **'No quiet hours'**
  String get notificationsQuietOff;

  /// No description provided for @notificationsPermissionOff.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked for this app.'**
  String get notificationsPermissionOff;

  /// No description provided for @notificationsOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get notificationsOpenSettings;

  /// No description provided for @notificationsChannel.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get notificationsChannel;

  /// No description provided for @notificationsChannelFcm.
  ///
  /// In en, this message translates to:
  /// **'Push through Firebase Cloud Messaging'**
  String get notificationsChannelFcm;

  /// No description provided for @notificationsChannelNone.
  ///
  /// In en, this message translates to:
  /// **'While the app is open. This build has no push service.'**
  String get notificationsChannelNone;

  /// No description provided for @healthTitle.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get healthTitle;

  /// No description provided for @healthUptime.
  ///
  /// In en, this message translates to:
  /// **'{value}% up'**
  String healthUptime(String value);

  /// No description provided for @healthLatency.
  ///
  /// In en, this message translates to:
  /// **'{value} ms'**
  String healthLatency(String value);

  /// No description provided for @healthOutages.
  ///
  /// In en, this message translates to:
  /// **'Outages'**
  String get healthOutages;

  /// No description provided for @healthNoOutages.
  ///
  /// In en, this message translates to:
  /// **'No outages in the last 24 hours'**
  String get healthNoOutages;

  /// No description provided for @healthOngoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing for {duration}'**
  String healthOngoing(String duration);

  /// No description provided for @healthLasted.
  ///
  /// In en, this message translates to:
  /// **'Lasted {duration}'**
  String healthLasted(String duration);

  /// No description provided for @healthCause.
  ///
  /// In en, this message translates to:
  /// **'Caused by {name}'**
  String healthCause(String name);

  /// No description provided for @healthLast24h.
  ///
  /// In en, this message translates to:
  /// **'Last 24 hours'**
  String get healthLast24h;

  /// No description provided for @healthUp.
  ///
  /// In en, this message translates to:
  /// **'Up'**
  String get healthUp;

  /// No description provided for @healthDegraded.
  ///
  /// In en, this message translates to:
  /// **'Degraded'**
  String get healthDegraded;

  /// No description provided for @healthDown.
  ///
  /// In en, this message translates to:
  /// **'Down'**
  String get healthDown;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @accountProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get accountProfile;

  /// No description provided for @accountSessions.
  ///
  /// In en, this message translates to:
  /// **'Signed in devices'**
  String get accountSessions;

  /// No description provided for @accountThisDevice.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get accountThisDevice;

  /// No description provided for @accountLastUsed.
  ///
  /// In en, this message translates to:
  /// **'Last used {when}'**
  String accountLastUsed(String when);

  /// No description provided for @accountRevoke.
  ///
  /// In en, this message translates to:
  /// **'Sign out this device'**
  String get accountRevoke;

  /// No description provided for @accountRevoked.
  ///
  /// In en, this message translates to:
  /// **'Signed out {device}'**
  String accountRevoked(String device);

  /// No description provided for @accountAppLock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get accountAppLock;

  /// No description provided for @accountAppLockBody.
  ///
  /// In en, this message translates to:
  /// **'Ask for fingerprint, face or screen lock when the app opens'**
  String get accountAppLockBody;

  /// No description provided for @accountAppLockUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This phone has no screen lock set up.'**
  String get accountAppLockUnavailable;

  /// No description provided for @accountDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get accountDelete;

  /// No description provided for @accountDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account'**
  String get accountDeleteTitle;

  /// No description provided for @accountDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This deletes your account and signs you out everywhere. Organisations you own must be handed to another owner or deleted first. This cannot be undone.'**
  String get accountDeleteBody;

  /// No description provided for @accountDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get accountDeleteConfirm;

  /// No description provided for @accountDeletePassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to confirm'**
  String get accountDeletePassword;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your account is deleted.'**
  String get accountDeleted;

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Language and theme'**
  String get appearanceTitle;

  /// No description provided for @appearanceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get appearanceLanguage;

  /// No description provided for @appearanceSystem.
  ///
  /// In en, this message translates to:
  /// **'Phone setting'**
  String get appearanceSystem;

  /// No description provided for @appearanceTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get appearanceTheme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Phone setting'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutBuild.
  ///
  /// In en, this message translates to:
  /// **'{flavor} build'**
  String aboutBuild(String flavor);

  /// No description provided for @aboutServer.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get aboutServer;

  /// No description provided for @aboutLicences.
  ///
  /// In en, this message translates to:
  /// **'Open source licences'**
  String get aboutLicences;

  /// No description provided for @aboutPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Video, snapshots and faces stay on the server you connect to. Notifications carry only ids; the app fetches the picture itself.'**
  String get aboutPrivacy;

  /// No description provided for @lockTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Surveillance is locked'**
  String get lockTitle;

  /// No description provided for @lockUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get lockUnlock;

  /// No description provided for @lockReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock to watch your cameras'**
  String get lockReason;

  /// No description provided for @notificationAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Alert at {site}'**
  String notificationAlertTitle(String site);

  /// No description provided for @notificationChannelName.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelBody.
  ///
  /// In en, this message translates to:
  /// **'Alerts from your cameras'**
  String get notificationChannelBody;

  /// No description provided for @commonHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min'**
  String commonHoursMinutes(int hours, int minutes);

  /// No description provided for @commonShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get commonShowPassword;

  /// No description provided for @commonHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get commonHidePassword;

  /// No description provided for @countsInside.
  ///
  /// In en, this message translates to:
  /// **'inside'**
  String get countsInside;

  /// No description provided for @editorAddPoints.
  ///
  /// In en, this message translates to:
  /// **'Add corners'**
  String get editorAddPoints;

  /// No description provided for @connectorsVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get connectorsVersionLabel;

  /// No description provided for @connectorsLastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen'**
  String get connectorsLastSeen;

  /// No description provided for @connectorsConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get connectorsConnection;

  /// No description provided for @connectorsTunnel.
  ///
  /// In en, this message translates to:
  /// **'Secure tunnel'**
  String get connectorsTunnel;

  /// No description provided for @fieldCodeHelp.
  ///
  /// In en, this message translates to:
  /// **'Paste the link from the email, or the code in it'**
  String get fieldCodeHelp;

  /// No description provided for @verifyDone.
  ///
  /// In en, this message translates to:
  /// **'Email confirmed. Sign in to continue.'**
  String get verifyDone;

  /// No description provided for @resetLinkBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password for your account.'**
  String get resetLinkBody;

  /// No description provided for @pairingAddTitle.
  ///
  /// In en, this message translates to:
  /// **'How do you want to add it?'**
  String get pairingAddTitle;

  /// No description provided for @pairingAddBody.
  ///
  /// In en, this message translates to:
  /// **'Pick the way that suits the camera. The best one for this site comes first.'**
  String get pairingAddBody;

  /// No description provided for @pairingRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get pairingRecommended;

  /// No description provided for @pairingPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'This needs a permission the phone did not give. Allow it in the phone settings, or choose another way.'**
  String get pairingPermissionDenied;

  /// No description provided for @pairingDemoCode.
  ///
  /// In en, this message translates to:
  /// **'Use the demo code'**
  String get pairingDemoCode;

  /// No description provided for @pairingWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the connector to confirm'**
  String get pairingWaiting;

  /// No description provided for @pairingCamerasAdded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Camera added} other{{count} cameras added}}'**
  String pairingCamerasAdded(int count);

  /// No description provided for @validationConnectorCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 8 character code, like ABCD-1234'**
  String get validationConnectorCode;

  /// No description provided for @methodConnectorDiscovery.
  ///
  /// In en, this message translates to:
  /// **'Cameras on the network'**
  String get methodConnectorDiscovery;

  /// No description provided for @methodConnectorDiscoveryBody.
  ///
  /// In en, this message translates to:
  /// **'Pick one of the cameras the connector found'**
  String get methodConnectorDiscoveryBody;

  /// No description provided for @methodLabelQr.
  ///
  /// In en, this message translates to:
  /// **'Scan the camera\'s label'**
  String get methodLabelQr;

  /// No description provided for @methodLabelQrBody.
  ///
  /// In en, this message translates to:
  /// **'Point at the QR code on the sticker of the camera'**
  String get methodLabelQrBody;

  /// No description provided for @methodManualHost.
  ///
  /// In en, this message translates to:
  /// **'Enter its address'**
  String get methodManualHost;

  /// No description provided for @methodManualHostBody.
  ///
  /// In en, this message translates to:
  /// **'Type the camera\'s IP address and the connector identifies it'**
  String get methodManualHostBody;

  /// No description provided for @methodNvrImport.
  ///
  /// In en, this message translates to:
  /// **'Import from a recorder'**
  String get methodNvrImport;

  /// No description provided for @methodNvrImportBody.
  ///
  /// In en, this message translates to:
  /// **'Add channels of an NVR or DVR at once'**
  String get methodNvrImportBody;

  /// No description provided for @methodRtspUrl.
  ///
  /// In en, this message translates to:
  /// **'Paste an RTSP link'**
  String get methodRtspUrl;

  /// No description provided for @methodRtspUrlBody.
  ///
  /// In en, this message translates to:
  /// **'For cameras that give a stream address'**
  String get methodRtspUrlBody;

  /// No description provided for @methodConnectorQr.
  ///
  /// In en, this message translates to:
  /// **'Scan the connector\'s QR code'**
  String get methodConnectorQr;

  /// No description provided for @methodConnectorQrBody.
  ///
  /// In en, this message translates to:
  /// **'The connector shows it on its screen or web page'**
  String get methodConnectorQrBody;

  /// No description provided for @methodConnectorMdns.
  ///
  /// In en, this message translates to:
  /// **'Find it on this Wi-Fi'**
  String get methodConnectorMdns;

  /// No description provided for @methodConnectorMdnsBody.
  ///
  /// In en, this message translates to:
  /// **'Look for connectors on the network this phone is on'**
  String get methodConnectorMdnsBody;

  /// No description provided for @methodConnectorCode.
  ///
  /// In en, this message translates to:
  /// **'Type the code'**
  String get methodConnectorCode;

  /// No description provided for @methodConnectorCodeBody.
  ///
  /// In en, this message translates to:
  /// **'The 8 character code the connector shows'**
  String get methodConnectorCodeBody;

  /// No description provided for @mdnsTitle.
  ///
  /// In en, this message translates to:
  /// **'Connectors on this Wi-Fi'**
  String get mdnsTitle;

  /// No description provided for @mdnsSearching.
  ///
  /// In en, this message translates to:
  /// **'Looking for connectors on this network'**
  String get mdnsSearching;

  /// No description provided for @mdnsNone.
  ///
  /// In en, this message translates to:
  /// **'No connector found yet. Make sure this phone and the connector are on the same Wi-Fi.'**
  String get mdnsNone;

  /// No description provided for @labelTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan the label'**
  String get labelTitle;

  /// No description provided for @labelHint.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the QR code on the camera\'s sticker.'**
  String get labelHint;

  /// No description provided for @labelUnknown.
  ///
  /// In en, this message translates to:
  /// **'This label is not one we know. Add the camera another way.'**
  String get labelUnknown;

  /// No description provided for @manualTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera address'**
  String get manualTitle;

  /// No description provided for @manualBody.
  ///
  /// In en, this message translates to:
  /// **'The connector asks the camera what it is. Its login comes on the next step.'**
  String get manualBody;

  /// No description provided for @manualHost.
  ///
  /// In en, this message translates to:
  /// **'IP address or host name'**
  String get manualHost;

  /// No description provided for @manualPort.
  ///
  /// In en, this message translates to:
  /// **'ONVIF port, if not the usual one'**
  String get manualPort;

  /// No description provided for @manualIdentify.
  ///
  /// In en, this message translates to:
  /// **'Identify camera'**
  String get manualIdentify;

  /// No description provided for @manualIdentifying.
  ///
  /// In en, this message translates to:
  /// **'Asking the camera'**
  String get manualIdentifying;

  /// No description provided for @manualNotFound.
  ///
  /// In en, this message translates to:
  /// **'No camera answered at that address. Check it and try again.'**
  String get manualNotFound;

  /// No description provided for @rtspTitle.
  ///
  /// In en, this message translates to:
  /// **'RTSP link'**
  String get rtspTitle;

  /// No description provided for @rtspBody.
  ///
  /// In en, this message translates to:
  /// **'Paste the stream link from the camera\'s manual or app. A login in the link is kept on the connector.'**
  String get rtspBody;

  /// No description provided for @rtspField.
  ///
  /// In en, this message translates to:
  /// **'Stream link'**
  String get rtspField;

  /// No description provided for @rtspInvalid.
  ///
  /// In en, this message translates to:
  /// **'That is not an RTSP link.'**
  String get rtspInvalid;

  /// No description provided for @nvrPick.
  ///
  /// In en, this message translates to:
  /// **'Choose the recorder'**
  String get nvrPick;

  /// No description provided for @nvrNone.
  ///
  /// In en, this message translates to:
  /// **'No recorders found'**
  String get nvrNone;

  /// No description provided for @nvrTitle.
  ///
  /// In en, this message translates to:
  /// **'Import channels'**
  String get nvrTitle;

  /// No description provided for @nvrLogin.
  ///
  /// In en, this message translates to:
  /// **'Recorder login'**
  String get nvrLogin;

  /// No description provided for @nvrLoad.
  ///
  /// In en, this message translates to:
  /// **'Show channels'**
  String get nvrLoad;

  /// No description provided for @nvrChannels.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get nvrChannels;

  /// No description provided for @nvrAdd.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Choose channels} =1{Add 1 camera} other{Add {count} cameras}}'**
  String nvrAdd(int count);

  /// No description provided for @nvrOffline.
  ///
  /// In en, this message translates to:
  /// **'No signal'**
  String get nvrOffline;

  /// No description provided for @onboardingTestPassed.
  ///
  /// In en, this message translates to:
  /// **'Stream works'**
  String get onboardingTestPassed;

  /// No description provided for @presetZoneName.
  ///
  /// In en, this message translates to:
  /// **'Whole view'**
  String get presetZoneName;

  /// No description provided for @presetLineName.
  ///
  /// In en, this message translates to:
  /// **'Entrance'**
  String get presetLineName;

  /// No description provided for @morePlan.
  ///
  /// In en, this message translates to:
  /// **'Plan and usage'**
  String get morePlan;

  /// No description provided for @moreActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get moreActivity;

  /// No description provided for @planTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan and usage'**
  String get planTitle;

  /// No description provided for @planInternal.
  ///
  /// In en, this message translates to:
  /// **'Internal plan with no limits'**
  String get planInternal;

  /// No description provided for @planUnlimited.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get planUnlimited;

  /// No description provided for @planLimits.
  ///
  /// In en, this message translates to:
  /// **'Limits'**
  String get planLimits;

  /// No description provided for @planUsage.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get planUsage;

  /// No description provided for @planFeatures.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get planFeatures;

  /// No description provided for @planIncluded.
  ///
  /// In en, this message translates to:
  /// **'Included'**
  String get planIncluded;

  /// No description provided for @planNotIncluded.
  ///
  /// In en, this message translates to:
  /// **'Not in your plan'**
  String get planNotIncluded;

  /// No description provided for @planUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not in your plan. An owner can change the plan.'**
  String get planUnavailable;

  /// No description provided for @planSites.
  ///
  /// In en, this message translates to:
  /// **'Sites'**
  String get planSites;

  /// No description provided for @planCameras.
  ///
  /// In en, this message translates to:
  /// **'Cameras'**
  String get planCameras;

  /// No description provided for @planMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get planMembers;

  /// No description provided for @planEventRetention.
  ///
  /// In en, this message translates to:
  /// **'Events kept'**
  String get planEventRetention;

  /// No description provided for @planClipRetention.
  ///
  /// In en, this message translates to:
  /// **'Clips kept'**
  String get planClipRetention;

  /// No description provided for @planCameraHours.
  ///
  /// In en, this message translates to:
  /// **'Camera hours online'**
  String get planCameraHours;

  /// No description provided for @planAnalyticsHours.
  ///
  /// In en, this message translates to:
  /// **'Analysed view hours'**
  String get planAnalyticsHours;

  /// No description provided for @planEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get planEvents;

  /// No description provided for @planClipStorage.
  ///
  /// In en, this message translates to:
  /// **'Clip storage'**
  String get planClipStorage;

  /// No description provided for @planNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications sent'**
  String get planNotifications;

  /// No description provided for @planOf.
  ///
  /// In en, this message translates to:
  /// **'{used} of {limit}'**
  String planOf(String used, String limit);

  /// No description provided for @planSince.
  ///
  /// In en, this message translates to:
  /// **'since {date}'**
  String planSince(String date);

  /// No description provided for @planGigabytes.
  ///
  /// In en, this message translates to:
  /// **'{value} GB'**
  String planGigabytes(String value);

  /// No description provided for @featureObjects.
  ///
  /// In en, this message translates to:
  /// **'Objects left and taken'**
  String get featureObjects;

  /// No description provided for @featureJourneys.
  ///
  /// In en, this message translates to:
  /// **'Journeys'**
  String get featureJourneys;

  /// No description provided for @featureAppearanceSearch.
  ///
  /// In en, this message translates to:
  /// **'Find this person'**
  String get featureAppearanceSearch;

  /// No description provided for @featureTelegram.
  ///
  /// In en, this message translates to:
  /// **'Telegram alerts'**
  String get featureTelegram;

  /// No description provided for @telegramTitle.
  ///
  /// In en, this message translates to:
  /// **'Telegram'**
  String get telegramTitle;

  /// No description provided for @telegramBody.
  ///
  /// In en, this message translates to:
  /// **'Send alerts with the snapshot to a Telegram chat or group.'**
  String get telegramBody;

  /// No description provided for @telegramLink.
  ///
  /// In en, this message translates to:
  /// **'Link a chat'**
  String get telegramLink;

  /// No description provided for @telegramLinkBody.
  ///
  /// In en, this message translates to:
  /// **'Telegram opens the bot. Press Start in a private chat, or add the bot to a group, and the chat appears here.'**
  String get telegramLinkBody;

  /// No description provided for @telegramOpened.
  ///
  /// In en, this message translates to:
  /// **'Finish in Telegram, then come back here.'**
  String get telegramOpened;

  /// No description provided for @telegramChats.
  ///
  /// In en, this message translates to:
  /// **'Linked chats'**
  String get telegramChats;

  /// No description provided for @telegramNone.
  ///
  /// In en, this message translates to:
  /// **'No chat linked yet'**
  String get telegramNone;

  /// No description provided for @telegramGroup.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get telegramGroup;

  /// No description provided for @telegramPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private chat'**
  String get telegramPrivate;

  /// No description provided for @telegramLinked.
  ///
  /// In en, this message translates to:
  /// **'Linked {when}'**
  String telegramLinked(String when);

  /// No description provided for @telegramUnlink.
  ///
  /// In en, this message translates to:
  /// **'Unlink'**
  String get telegramUnlink;

  /// No description provided for @telegramUnlinkBody.
  ///
  /// In en, this message translates to:
  /// **'Alerts stop going to {chat}.'**
  String telegramUnlinkBody(String chat);

  /// No description provided for @telegramTest.
  ///
  /// In en, this message translates to:
  /// **'Send a test'**
  String get telegramTest;

  /// No description provided for @telegramTestSent.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No chat to send to} =1{Test sent to 1 chat} other{Test sent to {count} chats}}'**
  String telegramTestSent(int count);

  /// No description provided for @telegramCannotOpen.
  ///
  /// In en, this message translates to:
  /// **'Telegram could not be opened on this phone.'**
  String get telegramCannotOpen;

  /// No description provided for @activityTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityTitle;

  /// No description provided for @activityEmpty.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get activityEmpty;

  /// No description provided for @activityAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get activityAll;

  /// No description provided for @auditSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign ins'**
  String get auditSignIn;

  /// No description provided for @auditMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get auditMembers;

  /// No description provided for @auditCameras.
  ///
  /// In en, this message translates to:
  /// **'Cameras'**
  String get auditCameras;

  /// No description provided for @auditRules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get auditRules;

  /// No description provided for @auditArm.
  ///
  /// In en, this message translates to:
  /// **'Arm mode'**
  String get auditArm;

  /// No description provided for @auditViews.
  ///
  /// In en, this message translates to:
  /// **'Viewing'**
  String get auditViews;

  /// No description provided for @auditExports.
  ///
  /// In en, this message translates to:
  /// **'Exports'**
  String get auditExports;

  /// No description provided for @auditFaces.
  ///
  /// In en, this message translates to:
  /// **'Faces'**
  String get auditFaces;

  /// No description provided for @auditAdmin.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get auditAdmin;

  /// No description provided for @actionAuthSignIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get actionAuthSignIn;

  /// No description provided for @actionMemberInvite.
  ///
  /// In en, this message translates to:
  /// **'Invited a member'**
  String get actionMemberInvite;

  /// No description provided for @actionMemberRole.
  ///
  /// In en, this message translates to:
  /// **'Changed a role'**
  String get actionMemberRole;

  /// No description provided for @actionMemberRemove.
  ///
  /// In en, this message translates to:
  /// **'Removed a member'**
  String get actionMemberRemove;

  /// No description provided for @actionCameraAdd.
  ///
  /// In en, this message translates to:
  /// **'Added a camera'**
  String get actionCameraAdd;

  /// No description provided for @actionCameraUpdate.
  ///
  /// In en, this message translates to:
  /// **'Changed a camera'**
  String get actionCameraUpdate;

  /// No description provided for @actionCameraDelete.
  ///
  /// In en, this message translates to:
  /// **'Deleted a camera'**
  String get actionCameraDelete;

  /// No description provided for @actionRulesUpdate.
  ///
  /// In en, this message translates to:
  /// **'Changed zones and lines'**
  String get actionRulesUpdate;

  /// No description provided for @actionArmChange.
  ///
  /// In en, this message translates to:
  /// **'Changed the arm mode'**
  String get actionArmChange;

  /// No description provided for @actionLiveView.
  ///
  /// In en, this message translates to:
  /// **'Watched live'**
  String get actionLiveView;

  /// No description provided for @actionClipView.
  ///
  /// In en, this message translates to:
  /// **'Watched a clip'**
  String get actionClipView;

  /// No description provided for @actionClipExport.
  ///
  /// In en, this message translates to:
  /// **'Shared a clip'**
  String get actionClipExport;

  /// No description provided for @actionFaceEnrol.
  ///
  /// In en, this message translates to:
  /// **'Added face photos'**
  String get actionFaceEnrol;

  /// No description provided for @actionFaceDelete.
  ///
  /// In en, this message translates to:
  /// **'Deleted faces'**
  String get actionFaceDelete;

  /// No description provided for @actionOrgPlan.
  ///
  /// In en, this message translates to:
  /// **'Changed the plan'**
  String get actionOrgPlan;

  /// No description provided for @capabilityNone.
  ///
  /// In en, this message translates to:
  /// **'This camera has no controls to show.'**
  String get capabilityNone;

  /// No description provided for @eventsAlertCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 alert} other{{count} alerts}}'**
  String eventsAlertCount(int count);

  /// Action on a discovered recorder that opens its channel import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get discoveredImport;

  /// No description provided for @errorTooMany.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait a minute and try again.'**
  String get errorTooMany;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
