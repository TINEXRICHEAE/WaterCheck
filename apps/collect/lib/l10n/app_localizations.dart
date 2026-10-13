import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'WaterCheck Collect'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get navSync;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Village sources'**
  String get homeTitle;

  /// No description provided for @homeEmpty.
  ///
  /// In en, this message translates to:
  /// **'No water sources yet. Sources you add will appear here, with their latest result.'**
  String get homeEmpty;

  /// No description provided for @homeTestSource.
  ///
  /// In en, this message translates to:
  /// **'Test a source'**
  String get homeTestSource;

  /// No description provided for @homeComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Testing arrives in the next build (P3).'**
  String get homeComingSoon;

  /// No description provided for @syncTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get syncTitle;

  /// No description provided for @syncExplainer.
  ///
  /// In en, this message translates to:
  /// **'Records are saved on this phone first. They are sent automatically when there is a connection, and nothing is lost if the connection drops. Use Sync now to send straight away.'**
  String get syncExplainer;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsReferenceData.
  ///
  /// In en, this message translates to:
  /// **'Reference data'**
  String get settingsReferenceData;

  /// No description provided for @settingsReferenceDataHint.
  ///
  /// In en, this message translates to:
  /// **'Parameters, limits, tester profiles and areas on this phone'**
  String get settingsReferenceDataHint;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsAboutBody.
  ///
  /// In en, this message translates to:
  /// **'WaterCheck Collect {version}. Water quality screening for Abim District. Results are screening only, not laboratory confirmation.'**
  String settingsAboutBody(String version);

  /// No description provided for @startupFailed.
  ///
  /// In en, this message translates to:
  /// **'WaterCheck could not open its data on this phone.'**
  String get startupFailed;

  /// No description provided for @startupRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get startupRetry;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to WaterCheck'**
  String get welcomeTitle;

  /// No description provided for @privacyHeading.
  ///
  /// In en, this message translates to:
  /// **'How your information is used'**
  String get privacyHeading;

  /// No description provided for @privacyBody.
  ///
  /// In en, this message translates to:
  /// **'WaterCheck records water test results for the shared water sources in your village.\n\nWith every result it saves your name, phone number, collector type, village and the place where you tested. This lets the district trust the result and contact you about it.\n\nWaterCheck does not ask for national ID numbers or information about households.\n\nEverything is kept locked (encrypted) on this phone and sent to the Abim District WaterCheck service when there is internet. You can stop taking part at any time by telling your VHT coordinator.'**
  String get privacyBody;

  /// No description provided for @privacyVersion.
  ///
  /// In en, this message translates to:
  /// **'Privacy notice version {version}'**
  String privacyVersion(int version);

  /// No description provided for @privacyAgree.
  ///
  /// In en, this message translates to:
  /// **'I understand and agree'**
  String get privacyAgree;

  /// No description provided for @whoTitle.
  ///
  /// In en, this message translates to:
  /// **'Who is testing?'**
  String get whoTitle;

  /// No description provided for @whoIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose your name. Everything you save is recorded with it.'**
  String get whoIntro;

  /// No description provided for @whoEmpty.
  ///
  /// In en, this message translates to:
  /// **'No one has been added on this phone yet.'**
  String get whoEmpty;

  /// No description provided for @whoAdd.
  ///
  /// In en, this message translates to:
  /// **'Add a person'**
  String get whoAdd;

  /// No description provided for @whoEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit details'**
  String get whoEdit;

  /// No description provided for @whoCurrent.
  ///
  /// In en, this message translates to:
  /// **'Testing now'**
  String get whoCurrent;

  /// No description provided for @whoSwitch.
  ///
  /// In en, this message translates to:
  /// **'Change who is testing'**
  String get whoSwitch;

  /// No description provided for @profileNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Your details'**
  String get profileNewTitle;

  /// No description provided for @profileEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit details'**
  String get profileEditTitle;

  /// No description provided for @profileFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get profileFullName;

  /// No description provided for @profilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get profilePhone;

  /// No description provided for @profilePhoneHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 0772 123456'**
  String get profilePhoneHint;

  /// No description provided for @profileCollectorType.
  ///
  /// In en, this message translates to:
  /// **'I am a…'**
  String get profileCollectorType;

  /// No description provided for @profileVillage.
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get profileVillage;

  /// No description provided for @profileParish.
  ///
  /// In en, this message translates to:
  /// **'Parish'**
  String get profileParish;

  /// No description provided for @profileSubcounty.
  ///
  /// In en, this message translates to:
  /// **'Sub-county'**
  String get profileSubcounty;

  /// No description provided for @profileDistrict.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get profileDistrict;

  /// No description provided for @profileOrganisation.
  ///
  /// In en, this message translates to:
  /// **'Group or organisation (optional)'**
  String get profileOrganisation;

  /// No description provided for @profileOrganisationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. COBERS team, school'**
  String get profileOrganisationHint;

  /// No description provided for @profileNoId.
  ///
  /// In en, this message translates to:
  /// **'Do not enter a national ID number. WaterCheck does not need it.'**
  String get profileNoId;

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileSave;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Please fill this in'**
  String get fieldRequired;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a Ugandan phone number, e.g. 0772 123456'**
  String get phoneInvalid;

  /// No description provided for @sourcesAdd.
  ///
  /// In en, this message translates to:
  /// **'Add source'**
  String get sourcesAdd;

  /// No description provided for @sourceNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New water source'**
  String get sourceNewTitle;

  /// No description provided for @sourceEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit source'**
  String get sourceEditTitle;

  /// No description provided for @sourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get sourceCode;

  /// No description provided for @sourceCodeHelp.
  ///
  /// In en, this message translates to:
  /// **'Village code and number, e.g. ABIM-ENT-003'**
  String get sourceCodeHelp;

  /// No description provided for @sourceName.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get sourceName;

  /// No description provided for @sourceNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Church borehole'**
  String get sourceNameHint;

  /// No description provided for @sourceType.
  ///
  /// In en, this message translates to:
  /// **'Type of source'**
  String get sourceType;

  /// No description provided for @sourceHouseholds.
  ///
  /// In en, this message translates to:
  /// **'Households using it (optional)'**
  String get sourceHouseholds;

  /// No description provided for @sourceStatus.
  ///
  /// In en, this message translates to:
  /// **'Is it working?'**
  String get sourceStatus;

  /// No description provided for @sourceLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get sourceLocation;

  /// No description provided for @sourceLocationNone.
  ///
  /// In en, this message translates to:
  /// **'No location yet'**
  String get sourceLocationNone;

  /// No description provided for @sourceLocationFix.
  ///
  /// In en, this message translates to:
  /// **'{lat}, {lon} (± {accuracy} m)'**
  String sourceLocationFix(String lat, String lon, String accuracy);

  /// No description provided for @sourceLocationCapture.
  ///
  /// In en, this message translates to:
  /// **'Get GPS location'**
  String get sourceLocationCapture;

  /// No description provided for @sourceLocationCapturing.
  ///
  /// In en, this message translates to:
  /// **'Finding your location…'**
  String get sourceLocationCapturing;

  /// No description provided for @sourceLocationManual.
  ///
  /// In en, this message translates to:
  /// **'Type coordinates instead'**
  String get sourceLocationManual;

  /// No description provided for @sourceLatitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get sourceLatitude;

  /// No description provided for @sourceLongitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get sourceLongitude;

  /// No description provided for @sourceLocationInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a number between -90 and 90 (latitude) or -180 and 180 (longitude)'**
  String get sourceLocationInvalid;

  /// No description provided for @sourceLocationPoorAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy is poor. Stand in the open near the source and try again if you can.'**
  String get sourceLocationPoorAccuracy;

  /// No description provided for @locationServiceOff.
  ///
  /// In en, this message translates to:
  /// **'Location is switched off on this phone. Switch it on in the phone settings.'**
  String get locationServiceOff;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'WaterCheck may not use your location. Allow it to record where the source is.'**
  String get locationDenied;

  /// No description provided for @locationDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location access is blocked for WaterCheck. Allow it in the phone settings.'**
  String get locationDeniedForever;

  /// No description provided for @locationTimeout.
  ///
  /// In en, this message translates to:
  /// **'No GPS signal yet. Move into the open and try again.'**
  String get locationTimeout;

  /// No description provided for @locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The location could not be found on this device. You can type the coordinates.'**
  String get locationUnavailable;

  /// No description provided for @sourceSave.
  ///
  /// In en, this message translates to:
  /// **'Save source'**
  String get sourceSave;

  /// No description provided for @sourceCodeTaken.
  ///
  /// In en, this message translates to:
  /// **'Another source in this village already has this code'**
  String get sourceCodeTaken;

  /// No description provided for @sourceDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Stop using this source'**
  String get sourceDeactivate;

  /// No description provided for @sourceDeactivateConfirm.
  ///
  /// In en, this message translates to:
  /// **'The source will be hidden from lists. Its tests are kept. Continue?'**
  String get sourceDeactivateConfirm;

  /// No description provided for @sourceDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Source hidden from lists'**
  String get sourceDeactivated;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get confirm;

  /// No description provided for @sourceLastTested.
  ///
  /// In en, this message translates to:
  /// **'Last tested {date}'**
  String sourceLastTested(String date);

  /// No description provided for @sourceNeverTested.
  ///
  /// In en, this message translates to:
  /// **'Never tested'**
  String get sourceNeverTested;

  /// No description provided for @sourceNextTest.
  ///
  /// In en, this message translates to:
  /// **'Next test by {date}'**
  String sourceNextTest(String date);

  /// No description provided for @sourceOverdueSince.
  ///
  /// In en, this message translates to:
  /// **'Test overdue since {date}'**
  String sourceOverdueSince(String date);

  /// No description provided for @sourceDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get sourceDetailTitle;

  /// No description provided for @sourceHouseholdsValue.
  ///
  /// In en, this message translates to:
  /// **'{count} households'**
  String sourceHouseholdsValue(int count);

  /// No description provided for @sourceEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get sourceEdit;

  /// No description provided for @pickTitle.
  ///
  /// In en, this message translates to:
  /// **'Which source are you testing?'**
  String get pickTitle;

  /// No description provided for @pickNearest.
  ///
  /// In en, this message translates to:
  /// **'Nearest to me'**
  String get pickNearest;

  /// No description provided for @pickNoSources.
  ///
  /// In en, this message translates to:
  /// **'Add a source first.'**
  String get pickNoSources;

  /// No description provided for @setupTitle.
  ///
  /// In en, this message translates to:
  /// **'Before you test'**
  String get setupTitle;

  /// No description provided for @setupCalibration.
  ///
  /// In en, this message translates to:
  /// **'Tester calibration'**
  String get setupCalibration;

  /// No description provided for @setupCalibratedToday.
  ///
  /// In en, this message translates to:
  /// **'Calibrated today ({result})'**
  String setupCalibratedToday(String result);

  /// No description provided for @setupCalibrationPassed.
  ///
  /// In en, this message translates to:
  /// **'passed'**
  String get setupCalibrationPassed;

  /// No description provided for @setupCalibrationFailed.
  ///
  /// In en, this message translates to:
  /// **'failed'**
  String get setupCalibrationFailed;

  /// No description provided for @setupNotCalibrated.
  ///
  /// In en, this message translates to:
  /// **'Not calibrated today'**
  String get setupNotCalibrated;

  /// No description provided for @setupCalibrate.
  ///
  /// In en, this message translates to:
  /// **'Calibrate now'**
  String get setupCalibrate;

  /// No description provided for @setupSkipCalibration.
  ///
  /// In en, this message translates to:
  /// **'Test without calibrating'**
  String get setupSkipCalibration;

  /// No description provided for @setupSkipWarning.
  ///
  /// In en, this message translates to:
  /// **'Results will be marked “not calibrated”.'**
  String get setupSkipWarning;

  /// No description provided for @setupTester.
  ///
  /// In en, this message translates to:
  /// **'Tester'**
  String get setupTester;

  /// No description provided for @setupLimits.
  ///
  /// In en, this message translates to:
  /// **'Safe limits'**
  String get setupLimits;

  /// No description provided for @setupEditLimits.
  ///
  /// In en, this message translates to:
  /// **'Edit limits'**
  String get setupEditLimits;

  /// No description provided for @setupLocation.
  ///
  /// In en, this message translates to:
  /// **'Are you at the source?'**
  String get setupLocation;

  /// No description provided for @setupCheckLocation.
  ///
  /// In en, this message translates to:
  /// **'Check my location'**
  String get setupCheckLocation;

  /// No description provided for @setupDistance.
  ///
  /// In en, this message translates to:
  /// **'You are {metres} m from the source'**
  String setupDistance(String metres);

  /// No description provided for @setupTooFar.
  ///
  /// In en, this message translates to:
  /// **'You seem to be more than {metres} m away. Say why, or move closer and check again.'**
  String setupTooFar(String metres);

  /// No description provided for @setupFarReason.
  ///
  /// In en, this message translates to:
  /// **'Reason (e.g. water carried from the source)'**
  String get setupFarReason;

  /// No description provided for @setupSourceHasNoLocation.
  ///
  /// In en, this message translates to:
  /// **'This source has no saved location, so distance cannot be checked.'**
  String get setupSourceHasNoLocation;

  /// No description provided for @setupContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue to readings'**
  String get setupContinue;

  /// No description provided for @calibrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Calibrate the tester'**
  String get calibrationTitle;

  /// No description provided for @calibrationIntro.
  ///
  /// In en, this message translates to:
  /// **'Put the pH probe in the pH 7.00 buffer and enter what the tester shows.'**
  String get calibrationIntro;

  /// No description provided for @calibrationSerial.
  ///
  /// In en, this message translates to:
  /// **'Tester serial number (optional)'**
  String get calibrationSerial;

  /// No description provided for @calibrationBuffer7.
  ///
  /// In en, this message translates to:
  /// **'Reading in pH 7.00 buffer'**
  String get calibrationBuffer7;

  /// No description provided for @calibrationBuffer4.
  ///
  /// In en, this message translates to:
  /// **'Reading in pH 4.01 buffer (optional)'**
  String get calibrationBuffer4;

  /// No description provided for @calibrationPassedQuestion.
  ///
  /// In en, this message translates to:
  /// **'Did the calibration pass?'**
  String get calibrationPassedQuestion;

  /// No description provided for @calibrationPass.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get calibrationPass;

  /// No description provided for @calibrationFail.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get calibrationFail;

  /// No description provided for @calibrationSave.
  ///
  /// In en, this message translates to:
  /// **'Save calibration'**
  String get calibrationSave;

  /// No description provided for @limitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit safe limits'**
  String get limitsTitle;

  /// No description provided for @limitsIntro.
  ///
  /// In en, this message translates to:
  /// **'Changes create custom limits for tests from now on. The official limits are kept, earlier results keep the limits they were judged under, and a stakeholder must approve the change.'**
  String get limitsIntro;

  /// No description provided for @limitsMin.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get limitsMin;

  /// No description provided for @limitsMax.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get limitsMax;

  /// No description provided for @limitsReason.
  ///
  /// In en, this message translates to:
  /// **'Why are you changing the limits?'**
  String get limitsReason;

  /// No description provided for @limitsSave.
  ///
  /// In en, this message translates to:
  /// **'Use these limits'**
  String get limitsSave;

  /// No description provided for @limitsChanged.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 limit changed} other{{count} limits changed}}'**
  String limitsChanged(int count);

  /// No description provided for @limitsNoChange.
  ///
  /// In en, this message translates to:
  /// **'Nothing changed yet'**
  String get limitsNoChange;

  /// No description provided for @limitsNumberInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get limitsNumberInvalid;

  /// No description provided for @entryTitle.
  ///
  /// In en, this message translates to:
  /// **'Readings'**
  String get entryTitle;

  /// No description provided for @entryCore.
  ///
  /// In en, this message translates to:
  /// **'Main readings'**
  String get entryCore;

  /// No description provided for @entryFromTester.
  ///
  /// In en, this message translates to:
  /// **'From this tester'**
  String get entryFromTester;

  /// No description provided for @entryAddMore.
  ///
  /// In en, this message translates to:
  /// **'Add more readings'**
  String get entryAddMore;

  /// No description provided for @entryCustom.
  ///
  /// In en, this message translates to:
  /// **'Add another kind of reading'**
  String get entryCustom;

  /// No description provided for @entryDeriveTds.
  ///
  /// In en, this message translates to:
  /// **'Work out TDS from EC'**
  String get entryDeriveTds;

  /// No description provided for @entryDerived.
  ///
  /// In en, this message translates to:
  /// **'worked out from EC'**
  String get entryDerived;

  /// No description provided for @entryImplausible.
  ///
  /// In en, this message translates to:
  /// **'This looks unusual. Check the number.'**
  String get entryImplausible;

  /// No description provided for @entryLimit.
  ///
  /// In en, this message translates to:
  /// **'limit {limit}'**
  String entryLimit(String limit);

  /// No description provided for @entryNoLimit.
  ///
  /// In en, this message translates to:
  /// **'no limit'**
  String get entryNoLimit;

  /// No description provided for @entryDetected.
  ///
  /// In en, this message translates to:
  /// **'Found'**
  String get entryDetected;

  /// No description provided for @entryNotDetected.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get entryNotDetected;

  /// No description provided for @entryAcceptable.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get entryAcceptable;

  /// No description provided for @entryNotAcceptable.
  ///
  /// In en, this message translates to:
  /// **'Not normal'**
  String get entryNotAcceptable;

  /// No description provided for @entryReview.
  ///
  /// In en, this message translates to:
  /// **'Check and submit'**
  String get entryReview;

  /// No description provided for @customParamTitle.
  ///
  /// In en, this message translates to:
  /// **'New kind of reading'**
  String get customParamTitle;

  /// No description provided for @customParamName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get customParamName;

  /// No description provided for @customParamCategory.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get customParamCategory;

  /// No description provided for @customParamUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit (e.g. mg/L)'**
  String get customParamUnit;

  /// No description provided for @customParamType.
  ///
  /// In en, this message translates to:
  /// **'What is recorded'**
  String get customParamType;

  /// No description provided for @customParamTypeNumber.
  ///
  /// In en, this message translates to:
  /// **'A number'**
  String get customParamTypeNumber;

  /// No description provided for @customParamTypePresence.
  ///
  /// In en, this message translates to:
  /// **'Found / not found'**
  String get customParamTypePresence;

  /// No description provided for @customParamTypeText.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get customParamTypeText;

  /// No description provided for @customParamAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get customParamAdd;

  /// No description provided for @resultOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get resultOk;

  /// No description provided for @resultLow.
  ///
  /// In en, this message translates to:
  /// **'LOW'**
  String get resultLow;

  /// No description provided for @resultHigh.
  ///
  /// In en, this message translates to:
  /// **'HIGH'**
  String get resultHigh;

  /// No description provided for @resultDetected.
  ///
  /// In en, this message translates to:
  /// **'FOUND'**
  String get resultDetected;

  /// No description provided for @resultUnacceptable.
  ///
  /// In en, this message translates to:
  /// **'NOT NORMAL'**
  String get resultUnacceptable;

  /// No description provided for @resultInvalid.
  ///
  /// In en, this message translates to:
  /// **'CHECK VALUE'**
  String get resultInvalid;

  /// No description provided for @resultNotAssessed.
  ///
  /// In en, this message translates to:
  /// **'NO LIMIT'**
  String get resultNotAssessed;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Check and submit'**
  String get reviewTitle;

  /// No description provided for @reviewWho.
  ///
  /// In en, this message translates to:
  /// **'Tested by'**
  String get reviewWho;

  /// No description provided for @reviewWhere.
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get reviewWhere;

  /// No description provided for @reviewNoLocation.
  ///
  /// In en, this message translates to:
  /// **'No location recorded'**
  String get reviewNoLocation;

  /// No description provided for @reviewSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get reviewSource;

  /// No description provided for @reviewLimits.
  ///
  /// In en, this message translates to:
  /// **'Limits used'**
  String get reviewLimits;

  /// No description provided for @reviewReadings.
  ///
  /// In en, this message translates to:
  /// **'Readings'**
  String get reviewReadings;

  /// No description provided for @reviewMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing: {list}'**
  String reviewMissing(String list);

  /// No description provided for @reviewUncalibrated.
  ///
  /// In en, this message translates to:
  /// **'Tester not calibrated today'**
  String get reviewUncalibrated;

  /// No description provided for @reviewSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get reviewSubmit;

  /// No description provided for @reviewSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved on this phone. It will be sent when the internet returns.'**
  String get reviewSaved;

  /// No description provided for @resultTitle.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get resultTitle;

  /// No description provided for @limitationNoGermTest.
  ///
  /// In en, this message translates to:
  /// **'Safe on the measured parameters. This test cannot detect germs — boil or treat drinking water.'**
  String get limitationNoGermTest;

  /// No description provided for @limitationEcoliNegative.
  ///
  /// In en, this message translates to:
  /// **'No E. coli found in this test. Still boil or treat drinking water to be safe.'**
  String get limitationEcoliNegative;

  /// No description provided for @resultUnsafeHint.
  ///
  /// In en, this message translates to:
  /// **'One or more readings are outside the safe limits.'**
  String get resultUnsafeHint;

  /// No description provided for @resultInconclusiveHint.
  ///
  /// In en, this message translates to:
  /// **'Some readings are missing or need checking, so no decision can be made.'**
  String get resultInconclusiveHint;

  /// No description provided for @resultRetest.
  ///
  /// In en, this message translates to:
  /// **'Test again'**
  String get resultRetest;

  /// No description provided for @resultDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get resultDone;

  /// No description provided for @alertRaised.
  ///
  /// In en, this message translates to:
  /// **'An alert has been raised'**
  String get alertRaised;

  /// No description provided for @alertRaisedHint.
  ///
  /// In en, this message translates to:
  /// **'It will be sent to the district. Follow the steps for this problem.'**
  String get alertRaisedHint;

  /// No description provided for @alertWhatToDo.
  ///
  /// In en, this message translates to:
  /// **'What to do now'**
  String get alertWhatToDo;

  /// No description provided for @alertTitle.
  ///
  /// In en, this message translates to:
  /// **'What to do'**
  String get alertTitle;

  /// No description provided for @alertTriggerUnsafe.
  ///
  /// In en, this message translates to:
  /// **'Water outside the safe limits'**
  String get alertTriggerUnsafe;

  /// No description provided for @alertTriggerEcoli.
  ///
  /// In en, this message translates to:
  /// **'E. coli found'**
  String get alertTriggerEcoli;

  /// No description provided for @alertTriggerBaseline.
  ///
  /// In en, this message translates to:
  /// **'Sudden change in this source'**
  String get alertTriggerBaseline;

  /// No description provided for @alertActionsHeading.
  ///
  /// In en, this message translates to:
  /// **'Tick what you have done'**
  String get alertActionsHeading;

  /// No description provided for @alertReportTo.
  ///
  /// In en, this message translates to:
  /// **'Report to'**
  String get alertReportTo;

  /// No description provided for @alertNote.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get alertNote;

  /// No description provided for @alertSaveActions.
  ///
  /// In en, this message translates to:
  /// **'Save what I did'**
  String get alertSaveActions;

  /// No description provided for @alertActionsSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved. The district will see what you did.'**
  String get alertActionsSaved;

  /// No description provided for @alertDone.
  ///
  /// In en, this message translates to:
  /// **'Done so far'**
  String get alertDone;

  /// No description provided for @alertNothingYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded yet.'**
  String get alertNothingYet;

  /// No description provided for @alertOpenOnSource.
  ///
  /// In en, this message translates to:
  /// **'Open alerts'**
  String get alertOpenOnSource;

  /// No description provided for @alertOpenedOn.
  ///
  /// In en, this message translates to:
  /// **'Raised {date}'**
  String alertOpenedOn(String date);

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Test history'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tests yet.'**
  String get historyEmpty;

  /// No description provided for @historyCorrected.
  ///
  /// In en, this message translates to:
  /// **'Corrected later'**
  String get historyCorrected;

  /// No description provided for @historyCorrection.
  ///
  /// In en, this message translates to:
  /// **'Correction'**
  String get historyCorrection;

  /// No description provided for @historyRetest.
  ///
  /// In en, this message translates to:
  /// **'Retest'**
  String get historyRetest;

  /// No description provided for @historyUncalibrated.
  ///
  /// In en, this message translates to:
  /// **'Not calibrated'**
  String get historyUncalibrated;

  /// No description provided for @trendTitle.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get trendTitle;

  /// No description provided for @trendNotEnough.
  ///
  /// In en, this message translates to:
  /// **'Trends appear after two or more tests.'**
  String get trendNotEnough;

  /// No description provided for @trendLimit.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get trendLimit;

  /// No description provided for @amendStart.
  ///
  /// In en, this message translates to:
  /// **'Correct a mistake'**
  String get amendStart;

  /// No description provided for @amendExplain.
  ///
  /// In en, this message translates to:
  /// **'Fix a reading that was typed wrongly. The first result is kept and marked as corrected.'**
  String get amendExplain;

  /// No description provided for @amendTitle.
  ///
  /// In en, this message translates to:
  /// **'Correcting a result'**
  String get amendTitle;

  /// No description provided for @amendReason.
  ///
  /// In en, this message translates to:
  /// **'What was wrong?'**
  String get amendReason;

  /// No description provided for @amendReasonHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. typed 71 instead of 7.1'**
  String get amendReasonHint;

  /// No description provided for @amendSubmit.
  ///
  /// In en, this message translates to:
  /// **'Save correction'**
  String get amendSubmit;

  /// No description provided for @amendSuperseded.
  ///
  /// In en, this message translates to:
  /// **'This result was corrected. Open the newest one to make another correction.'**
  String get amendSuperseded;

  /// No description provided for @sourceHistoryLater.
  ///
  /// In en, this message translates to:
  /// **'Test history and trends will appear here.'**
  String get sourceHistoryLater;

  /// No description provided for @inspectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Sanitary inspection'**
  String get inspectionTitle;

  /// No description provided for @inspectionIntro.
  ///
  /// In en, this message translates to:
  /// **'Look around the source and answer each question.'**
  String get inspectionIntro;

  /// No description provided for @inspectionYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get inspectionYes;

  /// No description provided for @inspectionNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get inspectionNo;

  /// No description provided for @inspectionSave.
  ///
  /// In en, this message translates to:
  /// **'Save inspection'**
  String get inspectionSave;

  /// No description provided for @inspectionSaved.
  ///
  /// In en, this message translates to:
  /// **'Inspection saved'**
  String get inspectionSaved;

  /// No description provided for @inspectionStart.
  ///
  /// In en, this message translates to:
  /// **'Check the surroundings'**
  String get inspectionStart;

  /// No description provided for @inspectionNone.
  ///
  /// In en, this message translates to:
  /// **'Surroundings not checked yet'**
  String get inspectionNone;

  /// No description provided for @inspectionLast.
  ///
  /// In en, this message translates to:
  /// **'Checked {date}: {count, plural, =0{no risks found} =1{1 risk found} other{{count} risks found}}'**
  String inspectionLast(String date, int count);

  /// No description provided for @activationTitle.
  ///
  /// In en, this message translates to:
  /// **'Activate this phone'**
  String get activationTitle;

  /// No description provided for @activationIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter the activation code from your IT admin. This needs the internet once. After that, WaterCheck works without internet and nobody needs to log in.'**
  String get activationIntro;

  /// No description provided for @activationCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Activation code'**
  String get activationCodeLabel;

  /// No description provided for @activationScan.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get activationScan;

  /// No description provided for @activationServer.
  ///
  /// In en, this message translates to:
  /// **'Server address'**
  String get activationServer;

  /// No description provided for @activationServerLabel.
  ///
  /// In en, this message translates to:
  /// **'Server address'**
  String get activationServerLabel;

  /// No description provided for @activationServerHint.
  ///
  /// In en, this message translates to:
  /// **'Change only if the IT admin tells you to.'**
  String get activationServerHint;

  /// No description provided for @activationGo.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activationGo;

  /// No description provided for @activationWorking.
  ///
  /// In en, this message translates to:
  /// **'Activating…'**
  String get activationWorking;

  /// No description provided for @activationCodeFormat.
  ///
  /// In en, this message translates to:
  /// **'An activation code has 12 letters and numbers, like K7QM-RT4W-9XHB.'**
  String get activationCodeFormat;

  /// No description provided for @activationServerFormat.
  ///
  /// In en, this message translates to:
  /// **'The server address must start with http:// or https://.'**
  String get activationServerFormat;

  /// No description provided for @activationBadQr.
  ///
  /// In en, this message translates to:
  /// **'That QR code is not a WaterCheck activation code.'**
  String get activationBadQr;

  /// No description provided for @activationInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'This code is not recognised. Check it and try again.'**
  String get activationInvalidCode;

  /// No description provided for @activationExpiredCode.
  ///
  /// In en, this message translates to:
  /// **'This code has expired. Ask the IT admin for a new one.'**
  String get activationExpiredCode;

  /// No description provided for @activationUsedUp.
  ///
  /// In en, this message translates to:
  /// **'This code has already been used on as many phones as allowed. Ask the IT admin for a new one.'**
  String get activationUsedUp;

  /// No description provided for @activationOffline.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server. Activation needs the internet once: check the connection and the server address, then try again.'**
  String get activationOffline;

  /// No description provided for @activationFailed.
  ///
  /// In en, this message translates to:
  /// **'Activation failed ({code}). Try again, or contact the IT admin.'**
  String activationFailed(String code);

  /// No description provided for @scanHint.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the QR code from the IT admin.'**
  String get scanHint;

  /// No description provided for @scanCameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The camera cannot be used. Type the code instead.'**
  String get scanCameraUnavailable;

  /// No description provided for @lockMessage.
  ///
  /// In en, this message translates to:
  /// **'WaterCheck is locked.'**
  String get lockMessage;

  /// No description provided for @lockBiometricReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock WaterCheck'**
  String get lockBiometricReason;

  /// No description provided for @lockForgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN?'**
  String get lockForgot;

  /// No description provided for @lockForgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot your PIN?'**
  String get lockForgotTitle;

  /// No description provided for @lockForgotBody.
  ///
  /// In en, this message translates to:
  /// **'The PIN cannot be recovered. Resetting the app saves unsent records to an encrypted file for the IT admin, then erases WaterCheck from this phone so it can be activated again.'**
  String get lockForgotBody;

  /// No description provided for @lockForgotReset.
  ///
  /// In en, this message translates to:
  /// **'Reset the app'**
  String get lockForgotReset;

  /// No description provided for @lockSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a PIN to protect WaterCheck'**
  String get lockSetupTitle;

  /// No description provided for @lockTurnOff.
  ///
  /// In en, this message translates to:
  /// **'Turn off app lock'**
  String get lockTurnOff;

  /// No description provided for @lockOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn off the app lock?'**
  String get lockOffTitle;

  /// No description provided for @lockOffBody.
  ///
  /// In en, this message translates to:
  /// **'Anyone who picks up this phone can then open WaterCheck and see the records on it.'**
  String get lockOffBody;

  /// No description provided for @lockBiometricOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'Use your fingerprint too?'**
  String get lockBiometricOfferTitle;

  /// No description provided for @lockBiometricOfferBody.
  ///
  /// In en, this message translates to:
  /// **'You can unlock with your fingerprint or face. The PIN still works.'**
  String get lockBiometricOfferBody;

  /// No description provided for @lockBiometricYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get lockBiometricYes;

  /// No description provided for @lockBiometricNo.
  ///
  /// In en, this message translates to:
  /// **'No, PIN only'**
  String get lockBiometricNo;

  /// No description provided for @lockCurrentPin.
  ///
  /// In en, this message translates to:
  /// **'Enter your current PIN'**
  String get lockCurrentPin;

  /// No description provided for @revokedTitle.
  ///
  /// In en, this message translates to:
  /// **'This phone has been switched off'**
  String get revokedTitle;

  /// No description provided for @revokedBody.
  ///
  /// In en, this message translates to:
  /// **'The IT admin has stopped this phone from sending data. Save any unsent records to a file and give it to the IT admin. Then erase WaterCheck from this phone.'**
  String get revokedBody;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset this phone'**
  String get resetTitle;

  /// No description provided for @resetBody.
  ///
  /// In en, this message translates to:
  /// **'This erases all WaterCheck data from this phone and returns it to activation. Save unsent records to a file first and give it to the IT admin.'**
  String get resetBody;

  /// No description provided for @resetCounting.
  ///
  /// In en, this message translates to:
  /// **'Checking for unsent records…'**
  String get resetCounting;

  /// No description provided for @resetNothingUnsent.
  ///
  /// In en, this message translates to:
  /// **'Everything has been sent.'**
  String get resetNothingUnsent;

  /// No description provided for @resetUnsent.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 record not sent} other{{count} records not sent}}'**
  String resetUnsent(int count);

  /// No description provided for @resetFileHint.
  ///
  /// In en, this message translates to:
  /// **'The file is encrypted. Only the WaterCheck server can open it.'**
  String get resetFileHint;

  /// No description provided for @resetSave.
  ///
  /// In en, this message translates to:
  /// **'Save unsent records to a file'**
  String get resetSave;

  /// No description provided for @resetSaveAgain.
  ///
  /// In en, this message translates to:
  /// **'Saved. Save another copy'**
  String get resetSaveAgain;

  /// No description provided for @resetSaved.
  ///
  /// In en, this message translates to:
  /// **'File saved.'**
  String get resetSaved;

  /// No description provided for @resetNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Not saved.'**
  String get resetNotSaved;

  /// No description provided for @resetSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'The file could not be saved. Try again.'**
  String get resetSaveFailed;

  /// No description provided for @resetErase.
  ///
  /// In en, this message translates to:
  /// **'Erase this phone'**
  String get resetErase;

  /// No description provided for @resetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Erase WaterCheck from this phone?'**
  String get resetConfirmTitle;

  /// No description provided for @resetConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'All WaterCheck data on this phone will be erased. This cannot be undone.'**
  String get resetConfirmBody;

  /// No description provided for @resetConfirmLoses.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 record has not been sent or saved and will be lost.} other{{count} records have not been sent or saved and will be lost.}} This cannot be undone.'**
  String resetConfirmLoses(int count);

  /// No description provided for @settingsActivatedFor.
  ///
  /// In en, this message translates to:
  /// **'Activated for {area}'**
  String settingsActivatedFor(String area);

  /// No description provided for @settingsInstallation.
  ///
  /// In en, this message translates to:
  /// **'Installation ID: {id}'**
  String settingsInstallation(String id);

  /// No description provided for @settingsAppLock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get settingsAppLock;

  /// No description provided for @settingsAppLockHint.
  ///
  /// In en, this message translates to:
  /// **'Ask for a PIN when WaterCheck opens'**
  String get settingsAppLockHint;

  /// No description provided for @settingsChangePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get settingsChangePin;

  /// No description provided for @settingsBiometric.
  ///
  /// In en, this message translates to:
  /// **'Unlock with fingerprint or face'**
  String get settingsBiometric;

  /// No description provided for @settingsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset this phone'**
  String get settingsReset;

  /// No description provided for @settingsResetHint.
  ///
  /// In en, this message translates to:
  /// **'Save unsent records, then erase WaterCheck'**
  String get settingsResetHint;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @syncRunning.
  ///
  /// In en, this message translates to:
  /// **'Sending and receiving…'**
  String get syncRunning;

  /// No description provided for @syncOffline.
  ///
  /// In en, this message translates to:
  /// **'No connection. WaterCheck will try again by itself (next try about {when}).'**
  String syncOffline(String when);

  /// No description provided for @syncServerProblem.
  ///
  /// In en, this message translates to:
  /// **'The server did not answer ({code}). WaterCheck will try again by itself (next try about {when}).'**
  String syncServerProblem(String code, String when);

  /// No description provided for @syncRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Not accepted by the server'**
  String get syncRejectedTitle;

  /// No description provided for @syncRejectedHint.
  ///
  /// In en, this message translates to:
  /// **'These records stay on this phone. Show this list to your IT admin.'**
  String get syncRejectedHint;

  /// No description provided for @entitySource.
  ///
  /// In en, this message translates to:
  /// **'Water source'**
  String get entitySource;

  /// No description provided for @entityTest.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get entityTest;

  /// No description provided for @entityResult.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get entityResult;

  /// No description provided for @entityReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get entityReading;

  /// No description provided for @entityAlert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get entityAlert;

  /// No description provided for @entityAlertAction.
  ///
  /// In en, this message translates to:
  /// **'Alert action'**
  String get entityAlertAction;

  /// No description provided for @entityInspection.
  ///
  /// In en, this message translates to:
  /// **'Sanitary inspection'**
  String get entityInspection;

  /// No description provided for @entityCalibration.
  ///
  /// In en, this message translates to:
  /// **'Calibration'**
  String get entityCalibration;

  /// No description provided for @entityCustomLimits.
  ///
  /// In en, this message translates to:
  /// **'Custom limits'**
  String get entityCustomLimits;

  /// No description provided for @entityCustomParameter.
  ///
  /// In en, this message translates to:
  /// **'Custom parameter'**
  String get entityCustomParameter;

  /// No description provided for @rejectMissingParent.
  ///
  /// In en, this message translates to:
  /// **'Something it belongs to was not accepted.'**
  String get rejectMissingParent;

  /// No description provided for @rejectOutOfScope.
  ///
  /// In en, this message translates to:
  /// **'It is outside this phone\'s area.'**
  String get rejectOutOfScope;

  /// No description provided for @rejectNoCollector.
  ///
  /// In en, this message translates to:
  /// **'No collector was recorded for it.'**
  String get rejectNoCollector;

  /// No description provided for @rejectDuplicate.
  ///
  /// In en, this message translates to:
  /// **'A record with the same code already exists.'**
  String get rejectDuplicate;

  /// No description provided for @rejectNotAccepted.
  ///
  /// In en, this message translates to:
  /// **'This kind of change is not accepted from a phone.'**
  String get rejectNotAccepted;

  /// No description provided for @rejectInvalid.
  ///
  /// In en, this message translates to:
  /// **'Some of its information was not valid.'**
  String get rejectInvalid;

  /// No description provided for @rejectOther.
  ///
  /// In en, this message translates to:
  /// **'The server refused it ({reason}).'**
  String rejectOther(String reason);

  /// No description provided for @photoSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Photos of this source'**
  String get photoSourceTitle;

  /// No description provided for @photoTesterTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo of the tester display (optional)'**
  String get photoTesterTitle;

  /// No description provided for @photoTake.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get photoTake;

  /// No description provided for @photoChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose photo'**
  String get photoChoose;

  /// No description provided for @photoSaved.
  ///
  /// In en, this message translates to:
  /// **'Photo saved. It will upload when the phone is on Wi-Fi.'**
  String get photoSaved;

  /// No description provided for @photoLowStorage.
  ///
  /// In en, this message translates to:
  /// **'This phone is almost full (less than 100 MB free). Photos are switched off so readings can still be saved. Free some space to add photos.'**
  String get photoLowStorage;

  /// No description provided for @photoNotImage.
  ///
  /// In en, this message translates to:
  /// **'That file is not a photo WaterCheck can use.'**
  String get photoNotImage;

  /// No description provided for @photoWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting to upload'**
  String get photoWaiting;

  /// No description provided for @photoUploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get photoUploaded;

  /// No description provided for @photoRejected.
  ///
  /// In en, this message translates to:
  /// **'Not accepted by the server'**
  String get photoRejected;

  /// No description provided for @settingsPhotosMobile.
  ///
  /// In en, this message translates to:
  /// **'Upload photos on mobile data'**
  String get settingsPhotosMobile;

  /// No description provided for @settingsPhotosMobileHint.
  ///
  /// In en, this message translates to:
  /// **'Off: photos wait for Wi-Fi. Readings always send on any connection.'**
  String get settingsPhotosMobileHint;

  /// No description provided for @syncPhotosWaiting.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo waiting to upload} other{{count} photos waiting to upload}}'**
  String syncPhotosWaiting(int count);

  /// No description provided for @syncPhotosWifi.
  ///
  /// In en, this message translates to:
  /// **'Photos upload on Wi-Fi, or on mobile data if you allow it in Settings.'**
  String get syncPhotosWifi;

  /// No description provided for @smsOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, =1{This alert has not been sent for 1 hour} other{This alert has not been sent for {hours} hours}}'**
  String smsOfferTitle(int hours);

  /// No description provided for @smsOfferBody.
  ///
  /// In en, this message translates to:
  /// **'The district has not heard about it yet. Send a short SMS now; the full record will follow when the phone can sync. Normal SMS charges apply.'**
  String get smsOfferBody;

  /// No description provided for @smsOfferButton.
  ///
  /// In en, this message translates to:
  /// **'Send by SMS'**
  String get smsOfferButton;

  /// No description provided for @smsOfferFailed.
  ///
  /// In en, this message translates to:
  /// **'This device cannot open the SMS app.'**
  String get smsOfferFailed;

  /// No description provided for @limitsStakeholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Stakeholder approval'**
  String get limitsStakeholderTitle;

  /// No description provided for @limitsStakeholderHint.
  ///
  /// In en, this message translates to:
  /// **'Only a stakeholder can change limits. Sign in with your WaterCheck Console account: the change is recorded under your name with your reason. Needs a connection; you are signed out right after.'**
  String get limitsStakeholderHint;

  /// No description provided for @limitsStakeholderUsername.
  ///
  /// In en, this message translates to:
  /// **'Stakeholder username'**
  String get limitsStakeholderUsername;

  /// No description provided for @limitsStakeholderPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get limitsStakeholderPassword;

  /// No description provided for @limitsStakeholderApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve and use'**
  String get limitsStakeholderApprove;

  /// No description provided for @limitsStakeholderCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get limitsStakeholderCancel;

  /// No description provided for @limitsStakeholderOffline.
  ///
  /// In en, this message translates to:
  /// **'No connection. Changing limits needs the server; try again when online.'**
  String get limitsStakeholderOffline;

  /// No description provided for @limitsStakeholderWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong username or password.'**
  String get limitsStakeholderWrong;

  /// No description provided for @limitsStakeholderFirstSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to the Console once first to set your own password.'**
  String get limitsStakeholderFirstSignIn;

  /// No description provided for @limitsStakeholderNotStakeholder.
  ///
  /// In en, this message translates to:
  /// **'This account is not a stakeholder account.'**
  String get limitsStakeholderNotStakeholder;

  /// No description provided for @limitsStakeholderLocked.
  ///
  /// In en, this message translates to:
  /// **'This account is locked for a while after too many attempts.'**
  String get limitsStakeholderLocked;

  /// No description provided for @limitsStakeholderFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the limits ({code}).'**
  String limitsStakeholderFailed(String code);

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance and time'**
  String get settingsAppearance;

  /// No description provided for @settingsAppearanceDevice.
  ///
  /// In en, this message translates to:
  /// **'Saved on this phone.'**
  String get settingsAppearanceDevice;

  /// No description provided for @settingsAppearanceFor.
  ///
  /// In en, this message translates to:
  /// **'Saved on this phone for {name}.'**
  String settingsAppearanceFor(String name);

  /// No description provided for @pickSearch.
  ///
  /// In en, this message translates to:
  /// **'Search by name or code'**
  String get pickSearch;

  /// No description provided for @pickNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No source matches the search.'**
  String get pickNoMatch;

  /// No description provided for @resultHome.
  ///
  /// In en, this message translates to:
  /// **'Back to the start page'**
  String get resultHome;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
