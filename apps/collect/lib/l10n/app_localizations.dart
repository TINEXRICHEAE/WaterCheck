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
  /// **'FieldQuire Collect'**
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
  /// **'Water sources'**
  String get homeTitle;

  /// No description provided for @homeEmpty.
  ///
  /// In en, this message translates to:
  /// **'No water sources yet. Sources you add, and those around you, will appear here with their latest result.'**
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
  /// **'Records are saved on this device first. They are sent automatically when there is a connection, and nothing is lost if the connection drops. Use Sync now to send straight away.'**
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
  /// **'Parameters, limits, tester profiles and areas on this device'**
  String get settingsReferenceDataHint;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsAboutBody.
  ///
  /// In en, this message translates to:
  /// **'FieldQuire Collect {version}. Collect field data, also without a connection: water tests at shared sources, research forms and more, each record with where and when it was made. Water test results are screening only, not laboratory confirmation.'**
  String settingsAboutBody(String version);

  /// No description provided for @startupFailed.
  ///
  /// In en, this message translates to:
  /// **'FieldQuire could not open its data on this device.'**
  String get startupFailed;

  /// No description provided for @startupRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get startupRetry;

  /// No description provided for @privacyHeading.
  ///
  /// In en, this message translates to:
  /// **'In short'**
  String get privacyHeading;

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
  /// **'No one has been added on this device yet.'**
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
  /// **'Do not enter a national ID number. FieldQuire does not need it.'**
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
  /// **'A short code made for you, e.g. WC-7Q2K9. You may change it.'**
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
  /// **'Location is switched off on this device. Switch it on in the device settings.'**
  String get locationServiceOff;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'FieldQuire may not use your location. Allow it to record where your records are made.'**
  String get locationDenied;

  /// No description provided for @locationDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location access is blocked for FieldQuire. Allow it in the device settings.'**
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
  /// **'Saved on this device. It will be sent when the internet returns.'**
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
  /// **'Activate this device'**
  String get activationTitle;

  /// No description provided for @activationIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter the activation code from your IT admin. This needs the internet once. After that, FieldQuire works without internet and nobody needs to log in.'**
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
  /// **'That QR code is not a FieldQuire activation code.'**
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
  /// **'This code has already been used on as many devices as allowed. Ask the IT admin for a new one.'**
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
  /// **'FieldQuire is locked.'**
  String get lockMessage;

  /// No description provided for @lockBiometricReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock FieldQuire'**
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
  /// **'The PIN cannot be recovered. Resetting the app saves unsent records to an encrypted file for the IT admin, then erases FieldQuire from this device so it can be activated again.'**
  String get lockForgotBody;

  /// No description provided for @lockForgotReset.
  ///
  /// In en, this message translates to:
  /// **'Reset the app'**
  String get lockForgotReset;

  /// No description provided for @lockSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a PIN to protect FieldQuire'**
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
  /// **'Anyone who picks up this device can then open FieldQuire and see the records on it.'**
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
  /// **'This device has been switched off'**
  String get revokedTitle;

  /// No description provided for @revokedBody.
  ///
  /// In en, this message translates to:
  /// **'The IT admin has stopped this device from sending data. Save any unsent records to a file and give it to the IT admin. Then erase FieldQuire from this device.'**
  String get revokedBody;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset this device'**
  String get resetTitle;

  /// No description provided for @resetBody.
  ///
  /// In en, this message translates to:
  /// **'This erases all FieldQuire data from this device and returns it to activation. Save unsent records to a file first and give it to the IT admin.'**
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
  /// **'The file is encrypted. Only the FieldQuire server can open it.'**
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
  /// **'Erase this device'**
  String get resetErase;

  /// No description provided for @resetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Erase FieldQuire from this device?'**
  String get resetConfirmTitle;

  /// No description provided for @resetConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'All FieldQuire data on this device will be erased. This cannot be undone.'**
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
  /// **'Ask for a PIN when FieldQuire opens'**
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
  /// **'Reset this device'**
  String get settingsReset;

  /// No description provided for @settingsResetHint.
  ///
  /// In en, this message translates to:
  /// **'Save unsent records, then erase FieldQuire'**
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
  /// **'No connection. FieldQuire will try again by itself (next try about {when}).'**
  String syncOffline(String when);

  /// No description provided for @syncServerProblem.
  ///
  /// In en, this message translates to:
  /// **'The server did not answer ({code}). FieldQuire will try again by itself (next try about {when}).'**
  String syncServerProblem(String code, String when);

  /// No description provided for @syncRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Not accepted by the server'**
  String get syncRejectedTitle;

  /// No description provided for @syncRejectedHint.
  ///
  /// In en, this message translates to:
  /// **'These records stay on this device. Show this list to your IT admin.'**
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
  /// **'It is outside this device\'s area.'**
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
  /// **'This kind of change is not accepted from a device.'**
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
  /// **'Photo saved. It will upload when the device is on Wi-Fi.'**
  String get photoSaved;

  /// No description provided for @photoLowStorage.
  ///
  /// In en, this message translates to:
  /// **'This device is almost full (less than 100 MB free). Photos are switched off so readings can still be saved. Free some space to add photos.'**
  String get photoLowStorage;

  /// No description provided for @photoNotImage.
  ///
  /// In en, this message translates to:
  /// **'That file is not a photo FieldQuire can use.'**
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
  /// **'Only a stakeholder can change limits. Sign in with your FieldQuire Console account: the change is recorded under your name with your reason. Needs a connection; you are signed out right after.'**
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
  /// **'Saved on this device.'**
  String get settingsAppearanceDevice;

  /// No description provided for @settingsAppearanceFor.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device for {name}.'**
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

  /// No description provided for @trailTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit history'**
  String get trailTitle;

  /// No description provided for @trailCorrections.
  ///
  /// In en, this message translates to:
  /// **'Corrections of this test'**
  String get trailCorrections;

  /// No description provided for @trailNone.
  ///
  /// In en, this message translates to:
  /// **'No changes recorded.'**
  String get trailNone;

  /// No description provided for @trailUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get trailUnknown;

  /// No description provided for @trailField.
  ///
  /// In en, this message translates to:
  /// **'{field, select, name{Name} households_served{Households} functional_status{Working} is_active{In use} source_type{Type} lat{Latitude} lon{Longitude} location_accuracy_m{GPS accuracy} label{Device name} full_name{Full name} phone{Phone} collector_type{Role} village{Village} parish{Parish} subcounty{Sub-county} district{District} organisation{Organisation} overall{Result} other{{field}}}'**
  String trailField(String field);

  /// No description provided for @trailChange.
  ///
  /// In en, this message translates to:
  /// **'{field}: {before} → {after}'**
  String trailChange(String field, String before, String after);

  /// No description provided for @amendNotYours.
  ///
  /// In en, this message translates to:
  /// **'Only {name}, who made this test, can correct it.'**
  String amendNotYours(String name);

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @areaVillageHint.
  ///
  /// In en, this message translates to:
  /// **'Type your village; known ones are suggested'**
  String get areaVillageHint;

  /// No description provided for @areaParishHint.
  ///
  /// In en, this message translates to:
  /// **'Search known parishes, or type a new one'**
  String get areaParishHint;

  /// No description provided for @areaSubcountyHint.
  ///
  /// In en, this message translates to:
  /// **'Search sub-counties (or their district)'**
  String get areaSubcountyHint;

  /// No description provided for @areaDistrictHint.
  ///
  /// In en, this message translates to:
  /// **'Search districts'**
  String get areaDistrictHint;

  /// No description provided for @areaFilledIn.
  ///
  /// In en, this message translates to:
  /// **'Filled in from the sub-county'**
  String get areaFilledIn;

  /// No description provided for @areaRegion.
  ///
  /// In en, this message translates to:
  /// **'Region: {name}'**
  String areaRegion(String name);

  /// No description provided for @areaOther.
  ///
  /// In en, this message translates to:
  /// **'Other: \"{name}\"'**
  String areaOther(String name);

  /// No description provided for @areaOtherHint.
  ///
  /// In en, this message translates to:
  /// **'Not in the list (a new place)'**
  String get areaOtherHint;

  /// No description provided for @areaPickOrOther.
  ///
  /// In en, this message translates to:
  /// **'Pick a sub-county from the list, or choose Other'**
  String get areaPickOrOther;

  /// No description provided for @areaPickDistrict.
  ///
  /// In en, this message translates to:
  /// **'Pick the district from the list'**
  String get areaPickDistrict;

  /// No description provided for @sourceWhere.
  ///
  /// In en, this message translates to:
  /// **'Where is it?'**
  String get sourceWhere;

  /// No description provided for @sourceWhereHint.
  ///
  /// In en, this message translates to:
  /// **'Starts with your own area. Change it if the source is somewhere else.'**
  String get sourceWhereHint;

  /// No description provided for @sourcesSearch.
  ///
  /// In en, this message translates to:
  /// **'Search by name, code or village'**
  String get sourcesSearch;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterSafe.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get filterSafe;

  /// No description provided for @filterUnsafe.
  ///
  /// In en, this message translates to:
  /// **'Unsafe'**
  String get filterUnsafe;

  /// No description provided for @filterNotTested.
  ///
  /// In en, this message translates to:
  /// **'Not tested'**
  String get filterNotTested;

  /// No description provided for @filterMine.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get filterMine;

  /// No description provided for @filterOthers.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get filterOthers;

  /// No description provided for @filterNearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get filterNearby;

  /// No description provided for @groupMine.
  ///
  /// In en, this message translates to:
  /// **'Added by you'**
  String get groupMine;

  /// No description provided for @groupNearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby (within 5 km)'**
  String get groupNearby;

  /// No description provided for @groupArea.
  ///
  /// In en, this message translates to:
  /// **'In your sub-county'**
  String get groupArea;

  /// No description provided for @groupElsewhere.
  ///
  /// In en, this message translates to:
  /// **'Elsewhere'**
  String get groupElsewhere;

  /// No description provided for @distanceAway.
  ///
  /// In en, this message translates to:
  /// **'{distance} away'**
  String distanceAway(String distance);

  /// No description provided for @setupLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Needed for every test: it shows the test was made at the source.'**
  String get setupLocationRequired;

  /// No description provided for @setupLocating.
  ///
  /// In en, this message translates to:
  /// **'Finding your location…'**
  String get setupLocating;

  /// No description provided for @setupAtSource.
  ///
  /// In en, this message translates to:
  /// **'You are at the source.'**
  String get setupAtSource;

  /// No description provided for @setupNoFix.
  ///
  /// In en, this message translates to:
  /// **'Your location could not be found. Try again in the open, or say why.'**
  String get setupNoFix;

  /// No description provided for @setupFarReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Kept with the test and shown to the district.'**
  String get setupFarReasonHint;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapTitle;

  /// No description provided for @mapAllAreas.
  ///
  /// In en, this message translates to:
  /// **'Uganda'**
  String get mapAllAreas;

  /// No description provided for @mapWithin.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 area within} other{{count} areas within}}'**
  String mapWithin(int count);

  /// No description provided for @mapSourcesHere.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No sources here} =1{1 source} other{{count} sources}} ({placed} on the map)'**
  String mapSourcesHere(int count, int placed);

  /// No description provided for @mapNoSources.
  ///
  /// In en, this message translates to:
  /// **'No source on this device is in this area yet. Search online from Home to find others.'**
  String get mapNoSources;

  /// No description provided for @mapNoLocation.
  ///
  /// In en, this message translates to:
  /// **'no location saved'**
  String get mapNoLocation;

  /// No description provided for @mapShowOnMap.
  ///
  /// In en, this message translates to:
  /// **'Show on the map'**
  String get mapShowOnMap;

  /// No description provided for @mapFindArea.
  ///
  /// In en, this message translates to:
  /// **'Find an area'**
  String get mapFindArea;

  /// No description provided for @mapFindAreaHint.
  ///
  /// In en, this message translates to:
  /// **'District, sub-county, parish or village'**
  String get mapFindAreaHint;

  /// No description provided for @mapMyLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get mapMyLocation;

  /// No description provided for @levelCountry.
  ///
  /// In en, this message translates to:
  /// **'country'**
  String get levelCountry;

  /// No description provided for @levelRegion.
  ///
  /// In en, this message translates to:
  /// **'region'**
  String get levelRegion;

  /// No description provided for @levelDistrict.
  ///
  /// In en, this message translates to:
  /// **'district'**
  String get levelDistrict;

  /// No description provided for @levelSubcounty.
  ///
  /// In en, this message translates to:
  /// **'sub-county'**
  String get levelSubcounty;

  /// No description provided for @levelParish.
  ///
  /// In en, this message translates to:
  /// **'parish'**
  String get levelParish;

  /// No description provided for @levelVillage.
  ///
  /// In en, this message translates to:
  /// **'village'**
  String get levelVillage;

  /// No description provided for @refNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found on this device. Sync and try again.'**
  String get refNotFound;

  /// No description provided for @rulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Testing rules'**
  String get rulesTitle;

  /// No description provided for @rulesIntro.
  ///
  /// In en, this message translates to:
  /// **'What every test needs and how often a source is due. Set by the IT admin; they reach this device with sync.'**
  String get rulesIntro;

  /// No description provided for @rulesRequired.
  ///
  /// In en, this message translates to:
  /// **'Readings every test needs'**
  String get rulesRequired;

  /// No description provided for @rulesSchedule.
  ///
  /// In en, this message translates to:
  /// **'When a source is due'**
  String get rulesSchedule;

  /// No description provided for @rulesRoutine.
  ///
  /// In en, this message translates to:
  /// **'Every {days} days normally'**
  String rulesRoutine(int days);

  /// No description provided for @rulesRainy.
  ///
  /// In en, this message translates to:
  /// **'Every {days} days in the rainy season'**
  String rulesRainy(int days);

  /// No description provided for @rulesAbnormal.
  ///
  /// In en, this message translates to:
  /// **'Again within {days} days after an abnormal result'**
  String rulesAbnormal(int days);

  /// No description provided for @rulesClears.
  ///
  /// In en, this message translates to:
  /// **'Back to normal after {count} normal results'**
  String rulesClears(int count);

  /// No description provided for @rulesDueSoon.
  ///
  /// In en, this message translates to:
  /// **'Shown as due {days} days before'**
  String rulesDueSoon(int days);

  /// No description provided for @rulesAtTheSource.
  ///
  /// In en, this message translates to:
  /// **'At the source'**
  String get rulesAtTheSource;

  /// No description provided for @rulesProximity.
  ///
  /// In en, this message translates to:
  /// **'Within {metres} m of the source (plus the GPS error); farther needs a reason'**
  String rulesProximity(int metres);

  /// No description provided for @rulesDefaultLimits.
  ///
  /// In en, this message translates to:
  /// **'Limits used when an area has no default'**
  String get rulesDefaultLimits;

  /// No description provided for @rulesSetBy.
  ///
  /// In en, this message translates to:
  /// **'Only the IT admin can change these rules, in the Console.'**
  String get rulesSetBy;

  /// No description provided for @limitsCalibrate.
  ///
  /// In en, this message translates to:
  /// **'Calibrate with these limits'**
  String get limitsCalibrate;

  /// No description provided for @limitsTestWith.
  ///
  /// In en, this message translates to:
  /// **'Test a source with these limits'**
  String get limitsTestWith;

  /// No description provided for @limitsUsedFor.
  ///
  /// In en, this message translates to:
  /// **'Where it is used'**
  String get limitsUsedFor;

  /// No description provided for @limitsTestsHere.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No test on this device used it yet.} =1{1 test on this device used it.} other{{count} tests on this device used it.}}'**
  String limitsTestsHere(int count);

  /// No description provided for @limitsNoAreaDefault.
  ///
  /// In en, this message translates to:
  /// **'No area starts its tests with it by default.'**
  String get limitsNoAreaDefault;

  /// No description provided for @limitsAreaDefault.
  ///
  /// In en, this message translates to:
  /// **'New tests here start with these limits'**
  String get limitsAreaDefault;

  /// No description provided for @limitsTable.
  ///
  /// In en, this message translates to:
  /// **'Limits'**
  String get limitsTable;

  /// No description provided for @paramCode.
  ///
  /// In en, this message translates to:
  /// **'Code: {code}'**
  String paramCode(String code);

  /// No description provided for @paramUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit: {unit}'**
  String paramUnit(String unit);

  /// No description provided for @paramCore.
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get paramCore;

  /// No description provided for @paramRequired.
  ///
  /// In en, this message translates to:
  /// **'Needed in every test'**
  String get paramRequired;

  /// No description provided for @paramCustom.
  ///
  /// In en, this message translates to:
  /// **'Added in the field'**
  String get paramCustom;

  /// No description provided for @paramPlausible.
  ///
  /// In en, this message translates to:
  /// **'Readings outside {min} to {max} are treated as mistakes.'**
  String paramPlausible(String min, String max);

  /// No description provided for @paramLimits.
  ///
  /// In en, this message translates to:
  /// **'Limit in each limit set'**
  String get paramLimits;

  /// No description provided for @paramRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent readings on this device'**
  String get paramRecent;

  /// No description provided for @paramNoReadings.
  ///
  /// In en, this message translates to:
  /// **'No readings on this device yet.'**
  String get paramNoReadings;

  /// No description provided for @searchOnline.
  ///
  /// In en, this message translates to:
  /// **'Search all of Uganda'**
  String get searchOnline;

  /// No description provided for @searchOnlineHint.
  ///
  /// In en, this message translates to:
  /// **'Sources beyond the districts on this device (needs internet)'**
  String get searchOnlineHint;

  /// No description provided for @groupOnline.
  ///
  /// In en, this message translates to:
  /// **'Elsewhere in Uganda (online)'**
  String get groupOnline;

  /// No description provided for @searchOnlineOffline.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server. Try again when online.'**
  String get searchOnlineOffline;

  /// No description provided for @searchOnlineNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing else found.'**
  String get searchOnlineNone;

  /// No description provided for @searchOnlineGet.
  ///
  /// In en, this message translates to:
  /// **'Get this district'**
  String get searchOnlineGet;

  /// No description provided for @searchOnlineAdded.
  ///
  /// In en, this message translates to:
  /// **'{district} added to this device; syncing now.'**
  String searchOnlineAdded(String district);

  /// No description provided for @whoRecover.
  ///
  /// In en, this message translates to:
  /// **'I already have a profile'**
  String get whoRecover;

  /// No description provided for @whoRecoverHint.
  ///
  /// In en, this message translates to:
  /// **'Lost your device, or using another one? Come back as yourself with a code.'**
  String get whoRecoverHint;

  /// No description provided for @recoverTitle.
  ///
  /// In en, this message translates to:
  /// **'I already have a profile'**
  String get recoverTitle;

  /// No description provided for @recoverIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter a sign-in code: one you made on another device you use (Settings › Your area and devices), or one from your IT admin or stakeholder. Your details come back to this device, and your earlier work stays yours.'**
  String get recoverIntro;

  /// No description provided for @recoverCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get recoverCode;

  /// No description provided for @recoverButton.
  ///
  /// In en, this message translates to:
  /// **'Get my profile'**
  String get recoverButton;

  /// No description provided for @recoverWhoGives.
  ///
  /// In en, this message translates to:
  /// **'No code? Make one on a device you are signed in on, or ask your IT admin or the stakeholder for your area (Console › Collectors › your name › \"Sign-in code for another device\"). An admin\'s code works once, within a day; your own works once, until used.'**
  String get recoverWhoGives;

  /// No description provided for @recoverInvalid.
  ///
  /// In en, this message translates to:
  /// **'That code is not valid. It may be mistyped or used already (an admin\'s code also expires after a day).'**
  String get recoverInvalid;

  /// No description provided for @recoverOffline.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server. Connect to the internet and try again.'**
  String get recoverOffline;

  /// No description provided for @recoverWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}.'**
  String recoverWelcome(String name);

  /// No description provided for @mapOpenSource.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get mapOpenSource;

  /// No description provided for @mapLocateForDistance.
  ///
  /// In en, this message translates to:
  /// **'Tap \"My location\" for the distance and the route.'**
  String get mapLocateForDistance;

  /// No description provided for @photoOpen.
  ///
  /// In en, this message translates to:
  /// **'Open picture'**
  String get photoOpen;

  /// No description provided for @reviewPicture.
  ///
  /// In en, this message translates to:
  /// **'Test picture'**
  String get reviewPicture;

  /// No description provided for @reviewPictureHint.
  ///
  /// In en, this message translates to:
  /// **'Take a picture of the test (the strip, kit or meter reading). It is needed unless one of the reasons below applies.'**
  String get reviewPictureHint;

  /// No description provided for @reviewNoPictureWhy.
  ///
  /// In en, this message translates to:
  /// **'No picture? Say why:'**
  String get reviewNoPictureWhy;

  /// No description provided for @reviewPictureNeeded.
  ///
  /// In en, this message translates to:
  /// **'Add a test picture, or choose why there is none.'**
  String get reviewPictureNeeded;

  /// No description provided for @noPhotoCameraBroken.
  ///
  /// In en, this message translates to:
  /// **'Camera not working'**
  String get noPhotoCameraBroken;

  /// No description provided for @noPhotoNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Pictures not allowed here'**
  String get noPhotoNotAllowed;

  /// No description provided for @noPhotoTooDark.
  ///
  /// In en, this message translates to:
  /// **'Too dark to see'**
  String get noPhotoTooDark;

  /// No description provided for @noPhotoOther.
  ///
  /// In en, this message translates to:
  /// **'Another reason'**
  String get noPhotoOther;

  /// No description provided for @noPhotoOtherHint.
  ///
  /// In en, this message translates to:
  /// **'Type the reason'**
  String get noPhotoOtherHint;

  /// No description provided for @resultContextTitle.
  ///
  /// In en, this message translates to:
  /// **'Where and how it was tested'**
  String get resultContextTitle;

  /// No description provided for @resultAccuracy.
  ///
  /// In en, this message translates to:
  /// **'location within {metres} m'**
  String resultAccuracy(int metres);

  /// No description provided for @resultFarReason.
  ///
  /// In en, this message translates to:
  /// **'away from the source because: {reason}'**
  String resultFarReason(String reason);

  /// No description provided for @resultNoPhoto.
  ///
  /// In en, this message translates to:
  /// **'No test picture: {reason}'**
  String resultNoPhoto(String reason);

  /// No description provided for @resultShowOnMap.
  ///
  /// In en, this message translates to:
  /// **'Show on the map'**
  String get resultShowOnMap;

  /// No description provided for @messagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTitle;

  /// No description provided for @messagesUnread.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Messages: 1 new} other{Messages: {count} new}}'**
  String messagesUnread(int count);

  /// No description provided for @messagesNone.
  ///
  /// In en, this message translates to:
  /// **'No messages yet. Messages about your tests and sources, and replies from stakeholders, appear here.'**
  String get messagesNone;

  /// No description provided for @messagesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No messages yet. Ask a question or add a note; stakeholders see it in the Console.'**
  String get messagesEmpty;

  /// No description provided for @messagesAbout.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, test{Test} source{Source} collector{Collector} area{Area} research{Research record} other{Thread}}'**
  String messagesAbout(String kind);

  /// No description provided for @messagesOpenSource.
  ///
  /// In en, this message translates to:
  /// **'Open the source'**
  String get messagesOpenSource;

  /// No description provided for @messagesTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages about this test'**
  String get messagesTestTitle;

  /// No description provided for @messagesSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages about this source'**
  String get messagesSourceTitle;

  /// No description provided for @areaOnMap.
  ///
  /// In en, this message translates to:
  /// **'On the map · {where}'**
  String areaOnMap(String where);

  /// No description provided for @mapOnMap.
  ///
  /// In en, this message translates to:
  /// **'Named on the map · {where}'**
  String mapOnMap(String where);

  /// No description provided for @sourceLocatedIn.
  ///
  /// In en, this message translates to:
  /// **'This point is in {where}.'**
  String sourceLocatedIn(String where);

  /// No description provided for @sourceLocatedNear.
  ///
  /// In en, this message translates to:
  /// **'This point is probably in {where} (nearest named place; checked when online).'**
  String sourceLocatedNear(String where);

  /// No description provided for @sourceUseLocated.
  ///
  /// In en, this message translates to:
  /// **'Use it'**
  String get sourceUseLocated;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'{name}: area and devices'**
  String accountTitle(String name);

  /// No description provided for @accountMenu.
  ///
  /// In en, this message translates to:
  /// **'Your area and devices'**
  String get accountMenu;

  /// No description provided for @accountMenuHint.
  ///
  /// In en, this message translates to:
  /// **'Get assigned to an area, sign in on another device, see and sign out devices'**
  String get accountMenuHint;

  /// No description provided for @accountAreaTitle.
  ///
  /// In en, this message translates to:
  /// **'Area assignment'**
  String get accountAreaTitle;

  /// No description provided for @accountAreaHint.
  ///
  /// In en, this message translates to:
  /// **'You can test anywhere without one. An assignment code from your IT admin makes you officially responsible for an area.'**
  String get accountAreaHint;

  /// No description provided for @accountNotAssigned.
  ///
  /// In en, this message translates to:
  /// **'Not yet assigned to an area.'**
  String get accountNotAssigned;

  /// No description provided for @accountByCode.
  ///
  /// In en, this message translates to:
  /// **'assigned with a code'**
  String get accountByCode;

  /// No description provided for @accountByAdmin.
  ///
  /// In en, this message translates to:
  /// **'assigned by an IT admin'**
  String get accountByAdmin;

  /// No description provided for @accountAssignButton.
  ///
  /// In en, this message translates to:
  /// **'Enter an assignment code'**
  String get accountAssignButton;

  /// No description provided for @accountAssignTitle.
  ///
  /// In en, this message translates to:
  /// **'Assignment code'**
  String get accountAssignTitle;

  /// No description provided for @accountAssignHint.
  ///
  /// In en, this message translates to:
  /// **'Type the code your IT admin gave you.'**
  String get accountAssignHint;

  /// No description provided for @accountOwnCodeSection.
  ///
  /// In en, this message translates to:
  /// **'Sign in on another device'**
  String get accountOwnCodeSection;

  /// No description provided for @accountOwnCodeIntro.
  ///
  /// In en, this message translates to:
  /// **'Make a sign-in code here and use it on another device (\"Who is testing?\" › \"I already have a profile\"). It works once and does not expire until used. You can also ask your IT admin for one.'**
  String get accountOwnCodeIntro;

  /// No description provided for @accountOwnCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Make a sign-in code'**
  String get accountOwnCodeButton;

  /// No description provided for @accountOwnCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your sign-in code'**
  String get accountOwnCodeTitle;

  /// No description provided for @accountOwnCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Keep it safe; anyone with it can sign in as you. It works once and is shown only now.'**
  String get accountOwnCodeHint;

  /// No description provided for @accountCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get accountCopy;

  /// No description provided for @accountDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get accountDone;

  /// No description provided for @accountContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get accountContinue;

  /// No description provided for @accountDevicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Devices using your profile'**
  String get accountDevicesTitle;

  /// No description provided for @accountDevicesHint.
  ///
  /// In en, this message translates to:
  /// **'Select devices you no longer use to sign them out. Your records from them stay yours.'**
  String get accountDevicesHint;

  /// No description provided for @accountDevice.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get accountDevice;

  /// No description provided for @accountThisDevice.
  ///
  /// In en, this message translates to:
  /// **'this device'**
  String get accountThisDevice;

  /// No description provided for @accountVia.
  ///
  /// In en, this message translates to:
  /// **'{via, select, created{started here} admin_code{signed in with an admin\'s code} own_code{signed in with your own code} other{signed in}}'**
  String accountVia(String via);

  /// No description provided for @accountLastSeen.
  ///
  /// In en, this message translates to:
  /// **'last used {when}'**
  String accountLastSeen(String when);

  /// No description provided for @accountSignedOut.
  ///
  /// In en, this message translates to:
  /// **'signed out'**
  String get accountSignedOut;

  /// No description provided for @accountSignOutButton.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Sign out selected devices} =1{Sign out 1 device} other{Sign out {count} devices}}'**
  String accountSignOutButton(int count);

  /// No description provided for @accountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm with a code'**
  String get accountConfirmTitle;

  /// No description provided for @accountConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'To confirm it is you, enter the 6-digit code. Until email and SMS are set up, your IT admin sees the code on your page in the Console and gives it to you.'**
  String get accountConfirmHint;

  /// No description provided for @accountConfirmWrong.
  ///
  /// In en, this message translates to:
  /// **'That code is not right. Check it with your IT admin.'**
  String get accountConfirmWrong;

  /// No description provided for @accountConfirmExpired.
  ///
  /// In en, this message translates to:
  /// **'This request has expired or had too many tries. Start again.'**
  String get accountConfirmExpired;

  /// No description provided for @accountCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'That code is not valid. Check it with your IT admin.'**
  String get accountCodeInvalid;

  /// No description provided for @accountCodeExpired.
  ///
  /// In en, this message translates to:
  /// **'That code has expired. Ask your IT admin for a new one.'**
  String get accountCodeExpired;

  /// No description provided for @accountCodeUsedUp.
  ///
  /// In en, this message translates to:
  /// **'That code has been used as many times as allowed.'**
  String get accountCodeUsedUp;

  /// No description provided for @accountSyncFirst.
  ///
  /// In en, this message translates to:
  /// **'Sync first, so the server knows your profile, then try again.'**
  String get accountSyncFirst;

  /// No description provided for @accountOffline.
  ///
  /// In en, this message translates to:
  /// **'Needs the internet. Connect and open this page again.'**
  String get accountOffline;

  /// No description provided for @settingsDeviceRegistered.
  ///
  /// In en, this message translates to:
  /// **'This device is registered'**
  String get settingsDeviceRegistered;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get profileEmail;

  /// No description provided for @profilePhoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone number (optional)'**
  String get profilePhoneOptional;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'That does not look like an email address.'**
  String get emailInvalid;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get profileTitle;

  /// No description provided for @profileMenuHint.
  ///
  /// In en, this message translates to:
  /// **'{name}: details, contacts, area, devices, sign out'**
  String profileMenuHint(String name);

  /// No description provided for @profileEditDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get profileEditDetails;

  /// No description provided for @profilePhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profilePhoneLabel;

  /// No description provided for @profileEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmailLabel;

  /// No description provided for @profileNotGiven.
  ///
  /// In en, this message translates to:
  /// **'Not given'**
  String get profileNotGiven;

  /// No description provided for @profileConfirmedLabel.
  ///
  /// In en, this message translates to:
  /// **'confirmed'**
  String get profileConfirmedLabel;

  /// No description provided for @profileNotConfirmedLabel.
  ///
  /// In en, this message translates to:
  /// **'not confirmed'**
  String get profileNotConfirmedLabel;

  /// No description provided for @profileConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get profileConfirmButton;

  /// No description provided for @profileContactCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code. Until email and SMS are set up, your IT admin gives it to you.'**
  String get profileContactCodeHint;

  /// No description provided for @profileAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccountTitle;

  /// No description provided for @profileSwitch.
  ///
  /// In en, this message translates to:
  /// **'Switch person'**
  String get profileSwitch;

  /// No description provided for @profileSwitchHint.
  ///
  /// In en, this message translates to:
  /// **'Choose who is testing on this device.'**
  String get profileSwitchHint;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out of this device'**
  String get profileSignOut;

  /// No description provided for @profileSignOutHint.
  ///
  /// In en, this message translates to:
  /// **'Your work is sent first; a sign-in code brings you back.'**
  String get profileSignOutHint;

  /// No description provided for @profileSignOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of this device?'**
  String get profileSignOutTitle;

  /// No description provided for @profileSignOutBody.
  ///
  /// In en, this message translates to:
  /// **'Everything of yours is sent first, then your profile leaves this device. Your records stay yours; sign in again with a sign-in code.'**
  String get profileSignOutBody;

  /// No description provided for @profileDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete my profile'**
  String get profileDelete;

  /// No description provided for @profileDeleteHint.
  ///
  /// In en, this message translates to:
  /// **'For good: every device signs you out and your phone and email are erased. Your tests stay.'**
  String get profileDeleteHint;

  /// No description provided for @profileDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your profile?'**
  String get profileDeleteTitle;

  /// No description provided for @profileDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'{name}, every device will sign you out, your area assignments end, and your phone and email are erased. The tests and sources you sent stay, under your name, because the water records depend on them.'**
  String profileDeleteBody(String name);

  /// No description provided for @profileSendFirst.
  ///
  /// In en, this message translates to:
  /// **'Some of your work is not sent yet. Connect and sync, then try again.'**
  String get profileSendFirst;

  /// No description provided for @mapListShow.
  ///
  /// In en, this message translates to:
  /// **'Show the list of areas and sources'**
  String get mapListShow;

  /// No description provided for @mapListHide.
  ///
  /// In en, this message translates to:
  /// **'Hide the list'**
  String get mapListHide;

  /// No description provided for @tripsTitle.
  ///
  /// In en, this message translates to:
  /// **'My trips'**
  String get tripsTitle;

  /// No description provided for @tripsTileHint.
  ///
  /// In en, this message translates to:
  /// **'Trips you followed live to a source or place'**
  String get tripsTileHint;

  /// No description provided for @tripsHint.
  ///
  /// In en, this message translates to:
  /// **'Trips you followed live with Go. They stay on this device and are not sent anywhere.'**
  String get tripsHint;

  /// No description provided for @tripsNone.
  ///
  /// In en, this message translates to:
  /// **'No trips yet. Choose a source or place on the map and press Go.'**
  String get tripsNone;

  /// No description provided for @tripsArrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get tripsArrived;

  /// No description provided for @tripsStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get tripsStopped;

  /// No description provided for @tripsTopSpeed.
  ///
  /// In en, this message translates to:
  /// **'top speed {speed}'**
  String tripsTopSpeed(String speed);

  /// No description provided for @tripsAltitude.
  ///
  /// In en, this message translates to:
  /// **'{low}–{high} m high'**
  String tripsAltitude(String low, String high);

  /// No description provided for @tripsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete this trip'**
  String get tripsDelete;

  /// No description provided for @tripsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this trip from this device?'**
  String get tripsDeleteTitle;

  /// No description provided for @mapAlertUnsafe.
  ///
  /// In en, this message translates to:
  /// **'Unsafe result: {source}'**
  String mapAlertUnsafe(String source);

  /// No description provided for @mapAlertOther.
  ///
  /// In en, this message translates to:
  /// **'Alert: {source}'**
  String mapAlertOther(String source);

  /// No description provided for @mapAlertOpen.
  ///
  /// In en, this message translates to:
  /// **'Open the alert'**
  String get mapAlertOpen;

  /// No description provided for @mapAlertsMore.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more alert} other{{count} more alerts}}'**
  String mapAlertsMore(int count);

  /// No description provided for @locationBlockedWeb.
  ///
  /// In en, this message translates to:
  /// **'This browser is not letting FieldQuire see your location. Allow location for this site (the icon in the address bar, or the site settings), then try again. On iPhone: Settings › Privacy & Security › Location Services › Safari Websites › While Using the App, then choose Allow in Safari.'**
  String get locationBlockedWeb;

  /// No description provided for @locationOffWeb.
  ///
  /// In en, this message translates to:
  /// **'Location is switched off for this browser or device. On iPhone: Settings › Privacy & Security › Location Services, switch it on, and set Safari Websites to While Using the App. On Android: switch Location on, and allow it for the browser.'**
  String get locationOffWeb;

  /// No description provided for @modeChoose.
  ///
  /// In en, this message translates to:
  /// **'What are you here for?'**
  String get modeChoose;

  /// No description provided for @modeWater.
  ///
  /// In en, this message translates to:
  /// **'Water testing'**
  String get modeWater;

  /// No description provided for @modeResearch.
  ///
  /// In en, this message translates to:
  /// **'Research'**
  String get modeResearch;

  /// No description provided for @navForms.
  ///
  /// In en, this message translates to:
  /// **'Forms'**
  String get navForms;

  /// No description provided for @researchTitle.
  ///
  /// In en, this message translates to:
  /// **'Research'**
  String get researchTitle;

  /// No description provided for @researchForms.
  ///
  /// In en, this message translates to:
  /// **'Forms to fill'**
  String get researchForms;

  /// No description provided for @researchNoForms.
  ///
  /// In en, this message translates to:
  /// **'No research forms yet. They appear here once a researcher publishes one you may use. Sync to check.'**
  String get researchNoForms;

  /// No description provided for @researchStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get researchStart;

  /// No description provided for @researchDrafts.
  ///
  /// In en, this message translates to:
  /// **'Not finished'**
  String get researchDrafts;

  /// No description provided for @researchNoNumber.
  ///
  /// In en, this message translates to:
  /// **'No number yet'**
  String get researchNoNumber;

  /// No description provided for @researchMine.
  ///
  /// In en, this message translates to:
  /// **'My records'**
  String get researchMine;

  /// No description provided for @researchNone.
  ///
  /// In en, this message translates to:
  /// **'No records yet.'**
  String get researchNone;

  /// No description provided for @researchSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get researchSent;

  /// No description provided for @researchWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting to send'**
  String get researchWaiting;

  /// No description provided for @researchClash.
  ///
  /// In en, this message translates to:
  /// **'Number used twice: your supervisor will check'**
  String get researchClash;

  /// No description provided for @researchNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Research number'**
  String get researchNumberLabel;

  /// No description provided for @researchNumberTyped.
  ///
  /// In en, this message translates to:
  /// **'Type the number from your list. Never a name.'**
  String get researchNumberTyped;

  /// No description provided for @researchNumberGenerated.
  ///
  /// In en, this message translates to:
  /// **'Given by the app; it shows on the map instead of a name.'**
  String get researchNumberGenerated;

  /// No description provided for @researchNumberMissing.
  ///
  /// In en, this message translates to:
  /// **'Give the research number'**
  String get researchNumberMissing;

  /// No description provided for @researchNumberUsed.
  ///
  /// In en, this message translates to:
  /// **'{number} is already used in this project. Keep it anyway? Your supervisor will see both.'**
  String researchNumberUsed(String number);

  /// No description provided for @researchKeepNumber.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get researchKeepNumber;

  /// No description provided for @researchChangeNumber.
  ///
  /// In en, this message translates to:
  /// **'Change it'**
  String get researchChangeNumber;

  /// No description provided for @researchIssues.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 answer needs attention} other{{count} answers need attention}}'**
  String researchIssues(int count);

  /// No description provided for @researchSaveClose.
  ///
  /// In en, this message translates to:
  /// **'Save and close'**
  String get researchSaveClose;

  /// No description provided for @researchFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get researchFinish;

  /// No description provided for @researchFinished.
  ///
  /// In en, this message translates to:
  /// **'Saved {number}. It is sent when there is internet.'**
  String researchFinished(String number);

  /// No description provided for @researchDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard this record'**
  String get researchDiscard;

  /// No description provided for @researchDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard this unfinished record and its pictures?'**
  String get researchDiscardTitle;

  /// No description provided for @researchNoPoint.
  ///
  /// In en, this message translates to:
  /// **'Finding where you are… The record keeps the first location found.'**
  String get researchNoPoint;

  /// No description provided for @researchPointAt.
  ///
  /// In en, this message translates to:
  /// **'Location: {point} (±{metres} m)'**
  String researchPointAt(String point, String metres);

  /// No description provided for @researchMap.
  ///
  /// In en, this message translates to:
  /// **'My research points'**
  String get researchMap;

  /// No description provided for @researchMapNone.
  ///
  /// In en, this message translates to:
  /// **'Your records with a location show here, by research number.'**
  String get researchMapNone;

  /// No description provided for @researchRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Record {number}'**
  String researchRecordTitle(String number);

  /// No description provided for @researchStartedAt.
  ///
  /// In en, this message translates to:
  /// **'Started {when}'**
  String researchStartedAt(String when);

  /// No description provided for @researchDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined: no consent, so no questions were asked.'**
  String get researchDeclined;

  /// No description provided for @researchWhichForm.
  ///
  /// In en, this message translates to:
  /// **'Which form?'**
  String get researchWhichForm;

  /// No description provided for @researchJoinTitle.
  ///
  /// In en, this message translates to:
  /// **'Join with a code'**
  String get researchJoinTitle;

  /// No description provided for @researchJoinHint.
  ///
  /// In en, this message translates to:
  /// **'Type the access code the research team gave you. This needs the internet once.'**
  String get researchJoinHint;

  /// No description provided for @researchJoinCode.
  ///
  /// In en, this message translates to:
  /// **'Access code'**
  String get researchJoinCode;

  /// No description provided for @researchJoin.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get researchJoin;

  /// No description provided for @researchJoinWrong.
  ///
  /// In en, this message translates to:
  /// **'That code does not open any form. Check it with the research team.'**
  String get researchJoinWrong;

  /// No description provided for @researchJoinOffline.
  ///
  /// In en, this message translates to:
  /// **'No connection. Join when you have internet.'**
  String get researchJoinOffline;

  /// No description provided for @researchJoinFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not join ({code}). Try again.'**
  String researchJoinFailed(String code);

  /// No description provided for @researchJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined. The form is on this phone now.'**
  String get researchJoined;

  /// No description provided for @researchSearch.
  ///
  /// In en, this message translates to:
  /// **'Search by research number or form'**
  String get researchSearch;

  /// No description provided for @researchFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get researchFilterAll;

  /// No description provided for @researchFilterFlagged.
  ///
  /// In en, this message translates to:
  /// **'To check'**
  String get researchFilterFlagged;

  /// No description provided for @researchMineCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{My records} =1{My records (1)} other{My records ({count})}}'**
  String researchMineCount(int count);

  /// No description provided for @researchFill.
  ///
  /// In en, this message translates to:
  /// **'Fill a form'**
  String get researchFill;

  /// No description provided for @researchTookMinutes.
  ///
  /// In en, this message translates to:
  /// **'Took {minutes} min'**
  String researchTookMinutes(int minutes);

  /// No description provided for @researchNoLocation.
  ///
  /// In en, this message translates to:
  /// **'No location'**
  String get researchNoLocation;

  /// No description provided for @researchAnswers.
  ///
  /// In en, this message translates to:
  /// **'Answers'**
  String get researchAnswers;

  /// No description provided for @researchMessagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages with the research team'**
  String get researchMessagesTitle;

  /// No description provided for @researchOpenRecord.
  ///
  /// In en, this message translates to:
  /// **'Open the record'**
  String get researchOpenRecord;

  /// No description provided for @legalForProfile.
  ///
  /// In en, this message translates to:
  /// **'Before {name} continues'**
  String legalForProfile(String name);

  /// No description provided for @legalTickBoth.
  ///
  /// In en, this message translates to:
  /// **'Tick both boxes to accept the Terms of Use and the Privacy Policy.'**
  String get legalTickBoth;

  /// No description provided for @profileJoinTitle.
  ///
  /// In en, this message translates to:
  /// **'Join {side}'**
  String profileJoinTitle(String side);

  /// No description provided for @profileNewTitleSide.
  ///
  /// In en, this message translates to:
  /// **'New {side} profile'**
  String profileNewTitleSide(String side);

  /// No description provided for @profileJoinIntro.
  ///
  /// In en, this message translates to:
  /// **'A separate {side} profile is made with your details below, linked to the one you use now. Each keeps its own records, forms and sign-in codes, and you can switch between them.'**
  String profileJoinIntro(String side);

  /// No description provided for @profileNewWaterIntro.
  ///
  /// In en, this message translates to:
  /// **'For people who test shared water sources. You can test anywhere at once; an IT admin may also make you officially responsible for an area.'**
  String get profileNewWaterIntro;

  /// No description provided for @profileNewResearchIntro.
  ///
  /// In en, this message translates to:
  /// **'For people who collect data for research projects: you fill the forms you are given, join with a code, or that are open to all.'**
  String get profileNewResearchIntro;

  /// No description provided for @profileCreate.
  ///
  /// In en, this message translates to:
  /// **'Create my profile'**
  String get profileCreate;

  /// No description provided for @profileTitleWater.
  ///
  /// In en, this message translates to:
  /// **'My water-testing profile'**
  String get profileTitleWater;

  /// No description provided for @profileTitleResearch.
  ///
  /// In en, this message translates to:
  /// **'My research profile'**
  String get profileTitleResearch;

  /// No description provided for @accountFormsHint.
  ///
  /// In en, this message translates to:
  /// **'The research forms on this phone that you may fill.'**
  String get accountFormsHint;

  /// No description provided for @researchNoFormsShort.
  ///
  /// In en, this message translates to:
  /// **'No forms yet. Join one with a code from the research team.'**
  String get researchNoFormsShort;

  /// No description provided for @whoEmptySide.
  ///
  /// In en, this message translates to:
  /// **'Nobody on this phone collects for {side} yet. Add yourself, or come back with a recovery code.'**
  String whoEmptySide(String side);

  /// No description provided for @sideJoin.
  ///
  /// In en, this message translates to:
  /// **'Also collect for {side}'**
  String sideJoin(String side);

  /// No description provided for @sideJoinHint.
  ///
  /// In en, this message translates to:
  /// **'Make a separate {side} profile with your details and its own Terms of Use.'**
  String sideJoinHint(String side);

  /// No description provided for @sideSwitch.
  ///
  /// In en, this message translates to:
  /// **'Switch to {side}'**
  String sideSwitch(String side);

  /// No description provided for @sideSwitchHint.
  ///
  /// In en, this message translates to:
  /// **'As {name}'**
  String sideSwitchHint(String name);

  /// No description provided for @sideSwitchBody.
  ///
  /// In en, this message translates to:
  /// **'You will collect with your {side} profile, with its own records, forms and settings.'**
  String sideSwitchBody(String side);

  /// No description provided for @sideSwitchGo.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get sideSwitchGo;

  /// No description provided for @sideSwitchNotYet.
  ///
  /// In en, this message translates to:
  /// **'Not on {side} yet: choose how to start there.'**
  String sideSwitchNotYet(String side);

  /// No description provided for @switchSideIntro.
  ///
  /// In en, this message translates to:
  /// **'{side} is a separate side of FieldQuire, with its own people, forms or sources, and records. Choose how to collect there.'**
  String switchSideIntro(String side);

  /// No description provided for @switchSideOnPhone.
  ///
  /// In en, this message translates to:
  /// **'Already on this phone for {side}'**
  String switchSideOnPhone(String side);

  /// No description provided for @switchSideJoin.
  ///
  /// In en, this message translates to:
  /// **'Use my details to join {side}'**
  String switchSideJoin(String side);

  /// No description provided for @switchSideCode.
  ///
  /// In en, this message translates to:
  /// **'I have a {side} profile on another phone'**
  String switchSideCode(String side);

  /// No description provided for @switchSideCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Come back with a sign-in or recovery code.'**
  String get switchSideCodeHint;

  /// No description provided for @switchSideNew.
  ///
  /// In en, this message translates to:
  /// **'Add a new person for {side}'**
  String switchSideNew(String side);

  /// No description provided for @switchSideNewHint.
  ///
  /// In en, this message translates to:
  /// **'With other details, and the side\'s own Terms of Use.'**
  String get switchSideNewHint;
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
