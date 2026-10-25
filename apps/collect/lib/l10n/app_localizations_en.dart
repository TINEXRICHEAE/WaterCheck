// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'WaterCheck Collect';

  @override
  String get navHome => 'Home';

  @override
  String get navSync => 'Sync';

  @override
  String get navSettings => 'Settings';

  @override
  String get homeTitle => 'Water sources';

  @override
  String get homeEmpty =>
      'No water sources yet. Sources you add, and those around you, will appear here with their latest result.';

  @override
  String get homeTestSource => 'Test a source';

  @override
  String get homeComingSoon => 'Testing arrives in the next build (P3).';

  @override
  String get syncTitle => 'Sync';

  @override
  String get syncExplainer =>
      'Records are saved on this device first. They are sent automatically when there is a connection, and nothing is lost if the connection drops. Use Sync now to send straight away.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsReferenceData => 'Reference data';

  @override
  String get settingsReferenceDataHint =>
      'Parameters, limits, tester profiles and areas on this device';

  @override
  String get settingsAbout => 'About';

  @override
  String settingsAboutBody(String version) {
    return 'WaterCheck Collect $version. Water quality screening for communities across Uganda. Results are screening only, not laboratory confirmation.';
  }

  @override
  String get startupFailed =>
      'WaterCheck could not open its data on this device.';

  @override
  String get startupRetry => 'Try again';

  @override
  String get welcomeTitle => 'Welcome to WaterCheck';

  @override
  String get privacyHeading => 'In short';

  @override
  String get privacyBody =>
      'WaterCheck records water tests at shared water sources so that communities and districts can act when water may be unsafe.\n\nWith each test it saves your name, the area you give, where you tested (GPS) and any pictures of the test or the source, with where and when each was taken. Places you add to the map show your name. Trips you follow with Go stay on this device. Your phone and email are optional. Stakeholders for the area see your records and can contact you; other testers see results and your name, not your contacts.\n\nWaterCheck does not ask for national ID numbers or information about households. Please do not photograph people.\n\nYour work is kept on this device (encrypted in the Android and Windows apps) and sent to the WaterCheck server, hosted outside Uganda (South Africa), when there is internet. You can edit your details, or delete your profile, any time under My profile.\n\nA test result is a warning, not a guarantee that water is safe: always follow the advice of your health officials.';

  @override
  String privacyVersion(int version) {
    return 'Privacy notice version $version';
  }

  @override
  String get privacyAgree => 'I understand and agree';

  @override
  String get whoTitle => 'Who is testing?';

  @override
  String get whoIntro =>
      'Choose your name. Everything you save is recorded with it.';

  @override
  String get whoEmpty => 'No one has been added on this device yet.';

  @override
  String get whoAdd => 'Add a person';

  @override
  String get whoEdit => 'Edit details';

  @override
  String get whoCurrent => 'Testing now';

  @override
  String get whoSwitch => 'Change who is testing';

  @override
  String get profileNewTitle => 'Your details';

  @override
  String get profileEditTitle => 'Edit details';

  @override
  String get profileFullName => 'Full name';

  @override
  String get profilePhone => 'Phone number';

  @override
  String get profilePhoneHint => 'e.g. 0772 123456';

  @override
  String get profileCollectorType => 'I am a…';

  @override
  String get profileVillage => 'Village';

  @override
  String get profileParish => 'Parish';

  @override
  String get profileSubcounty => 'Sub-county';

  @override
  String get profileDistrict => 'District';

  @override
  String get profileOrganisation => 'Group or organisation (optional)';

  @override
  String get profileOrganisationHint => 'e.g. COBERS team, school';

  @override
  String get profileNoId =>
      'Do not enter a national ID number. WaterCheck does not need it.';

  @override
  String get profileSave => 'Save';

  @override
  String get fieldRequired => 'Please fill this in';

  @override
  String get phoneInvalid => 'Enter a Ugandan phone number, e.g. 0772 123456';

  @override
  String get sourcesAdd => 'Add source';

  @override
  String get sourceNewTitle => 'New water source';

  @override
  String get sourceEditTitle => 'Edit source';

  @override
  String get sourceCode => 'Source code';

  @override
  String get sourceCodeHelp =>
      'A short code made for you, e.g. WC-7Q2K9. You may change it.';

  @override
  String get sourceName => 'Name (optional)';

  @override
  String get sourceNameHint => 'e.g. Church borehole';

  @override
  String get sourceType => 'Type of source';

  @override
  String get sourceHouseholds => 'Households using it (optional)';

  @override
  String get sourceStatus => 'Is it working?';

  @override
  String get sourceLocation => 'Location';

  @override
  String get sourceLocationNone => 'No location yet';

  @override
  String sourceLocationFix(String lat, String lon, String accuracy) {
    return '$lat, $lon (± $accuracy m)';
  }

  @override
  String get sourceLocationCapture => 'Get GPS location';

  @override
  String get sourceLocationCapturing => 'Finding your location…';

  @override
  String get sourceLocationManual => 'Type coordinates instead';

  @override
  String get sourceLatitude => 'Latitude';

  @override
  String get sourceLongitude => 'Longitude';

  @override
  String get sourceLocationInvalid =>
      'Enter a number between -90 and 90 (latitude) or -180 and 180 (longitude)';

  @override
  String get sourceLocationPoorAccuracy =>
      'Accuracy is poor. Stand in the open near the source and try again if you can.';

  @override
  String get locationServiceOff =>
      'Location is switched off on this device. Switch it on in the device settings.';

  @override
  String get locationDenied =>
      'WaterCheck may not use your location. Allow it to record where the source is.';

  @override
  String get locationDeniedForever =>
      'Location access is blocked for WaterCheck. Allow it in the device settings.';

  @override
  String get locationTimeout =>
      'No GPS signal yet. Move into the open and try again.';

  @override
  String get locationUnavailable =>
      'The location could not be found on this device. You can type the coordinates.';

  @override
  String get sourceSave => 'Save source';

  @override
  String get sourceCodeTaken =>
      'Another source in this village already has this code';

  @override
  String get sourceDeactivate => 'Stop using this source';

  @override
  String get sourceDeactivateConfirm =>
      'The source will be hidden from lists. Its tests are kept. Continue?';

  @override
  String get sourceDeactivated => 'Source hidden from lists';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Continue';

  @override
  String sourceLastTested(String date) {
    return 'Last tested $date';
  }

  @override
  String get sourceNeverTested => 'Never tested';

  @override
  String sourceNextTest(String date) {
    return 'Next test by $date';
  }

  @override
  String sourceOverdueSince(String date) {
    return 'Test overdue since $date';
  }

  @override
  String get sourceDetailTitle => 'Source';

  @override
  String sourceHouseholdsValue(int count) {
    return '$count households';
  }

  @override
  String get sourceEdit => 'Edit';

  @override
  String get pickTitle => 'Which source are you testing?';

  @override
  String get pickNearest => 'Nearest to me';

  @override
  String get pickNoSources => 'Add a source first.';

  @override
  String get setupTitle => 'Before you test';

  @override
  String get setupCalibration => 'Tester calibration';

  @override
  String setupCalibratedToday(String result) {
    return 'Calibrated today ($result)';
  }

  @override
  String get setupCalibrationPassed => 'passed';

  @override
  String get setupCalibrationFailed => 'failed';

  @override
  String get setupNotCalibrated => 'Not calibrated today';

  @override
  String get setupCalibrate => 'Calibrate now';

  @override
  String get setupSkipCalibration => 'Test without calibrating';

  @override
  String get setupSkipWarning => 'Results will be marked “not calibrated”.';

  @override
  String get setupTester => 'Tester';

  @override
  String get setupLimits => 'Safe limits';

  @override
  String get setupEditLimits => 'Edit limits';

  @override
  String get setupLocation => 'Are you at the source?';

  @override
  String get setupCheckLocation => 'Check my location';

  @override
  String setupDistance(String metres) {
    return 'You are $metres m from the source';
  }

  @override
  String setupTooFar(String metres) {
    return 'You seem to be more than $metres m away. Say why, or move closer and check again.';
  }

  @override
  String get setupFarReason => 'Reason (e.g. water carried from the source)';

  @override
  String get setupSourceHasNoLocation =>
      'This source has no saved location, so distance cannot be checked.';

  @override
  String get setupContinue => 'Continue to readings';

  @override
  String get calibrationTitle => 'Calibrate the tester';

  @override
  String get calibrationIntro =>
      'Put the pH probe in the pH 7.00 buffer and enter what the tester shows.';

  @override
  String get calibrationSerial => 'Tester serial number (optional)';

  @override
  String get calibrationBuffer7 => 'Reading in pH 7.00 buffer';

  @override
  String get calibrationBuffer4 => 'Reading in pH 4.01 buffer (optional)';

  @override
  String get calibrationPassedQuestion => 'Did the calibration pass?';

  @override
  String get calibrationPass => 'Passed';

  @override
  String get calibrationFail => 'Failed';

  @override
  String get calibrationSave => 'Save calibration';

  @override
  String get limitsTitle => 'Edit safe limits';

  @override
  String get limitsIntro =>
      'Changes create custom limits for tests from now on. The official limits are kept, earlier results keep the limits they were judged under, and a stakeholder must approve the change.';

  @override
  String get limitsMin => 'Min';

  @override
  String get limitsMax => 'Max';

  @override
  String get limitsReason => 'Why are you changing the limits?';

  @override
  String get limitsSave => 'Use these limits';

  @override
  String limitsChanged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count limits changed',
      one: '1 limit changed',
    );
    return '$_temp0';
  }

  @override
  String get limitsNoChange => 'Nothing changed yet';

  @override
  String get limitsNumberInvalid => 'Enter a number';

  @override
  String get entryTitle => 'Readings';

  @override
  String get entryCore => 'Main readings';

  @override
  String get entryFromTester => 'From this tester';

  @override
  String get entryAddMore => 'Add more readings';

  @override
  String get entryCustom => 'Add another kind of reading';

  @override
  String get entryDeriveTds => 'Work out TDS from EC';

  @override
  String get entryDerived => 'worked out from EC';

  @override
  String get entryImplausible => 'This looks unusual. Check the number.';

  @override
  String entryLimit(String limit) {
    return 'limit $limit';
  }

  @override
  String get entryNoLimit => 'no limit';

  @override
  String get entryDetected => 'Found';

  @override
  String get entryNotDetected => 'Not found';

  @override
  String get entryAcceptable => 'Normal';

  @override
  String get entryNotAcceptable => 'Not normal';

  @override
  String get entryReview => 'Check and submit';

  @override
  String get customParamTitle => 'New kind of reading';

  @override
  String get customParamName => 'Name';

  @override
  String get customParamCategory => 'Group';

  @override
  String get customParamUnit => 'Unit (e.g. mg/L)';

  @override
  String get customParamType => 'What is recorded';

  @override
  String get customParamTypeNumber => 'A number';

  @override
  String get customParamTypePresence => 'Found / not found';

  @override
  String get customParamTypeText => 'Words';

  @override
  String get customParamAdd => 'Add';

  @override
  String get resultOk => 'OK';

  @override
  String get resultLow => 'LOW';

  @override
  String get resultHigh => 'HIGH';

  @override
  String get resultDetected => 'FOUND';

  @override
  String get resultUnacceptable => 'NOT NORMAL';

  @override
  String get resultInvalid => 'CHECK VALUE';

  @override
  String get resultNotAssessed => 'NO LIMIT';

  @override
  String get reviewTitle => 'Check and submit';

  @override
  String get reviewWho => 'Tested by';

  @override
  String get reviewWhere => 'Where';

  @override
  String get reviewNoLocation => 'No location recorded';

  @override
  String get reviewSource => 'Source';

  @override
  String get reviewLimits => 'Limits used';

  @override
  String get reviewReadings => 'Readings';

  @override
  String reviewMissing(String list) {
    return 'Missing: $list';
  }

  @override
  String get reviewUncalibrated => 'Tester not calibrated today';

  @override
  String get reviewSubmit => 'Submit';

  @override
  String get reviewSaved =>
      'Saved on this device. It will be sent when the internet returns.';

  @override
  String get resultTitle => 'Result';

  @override
  String get limitationNoGermTest =>
      'Safe on the measured parameters. This test cannot detect germs — boil or treat drinking water.';

  @override
  String get limitationEcoliNegative =>
      'No E. coli found in this test. Still boil or treat drinking water to be safe.';

  @override
  String get resultUnsafeHint =>
      'One or more readings are outside the safe limits.';

  @override
  String get resultInconclusiveHint =>
      'Some readings are missing or need checking, so no decision can be made.';

  @override
  String get resultRetest => 'Test again';

  @override
  String get resultDone => 'Done';

  @override
  String get alertRaised => 'An alert has been raised';

  @override
  String get alertRaisedHint =>
      'It will be sent to the district. Follow the steps for this problem.';

  @override
  String get alertWhatToDo => 'What to do now';

  @override
  String get alertTitle => 'What to do';

  @override
  String get alertTriggerUnsafe => 'Water outside the safe limits';

  @override
  String get alertTriggerEcoli => 'E. coli found';

  @override
  String get alertTriggerBaseline => 'Sudden change in this source';

  @override
  String get alertActionsHeading => 'Tick what you have done';

  @override
  String get alertReportTo => 'Report to';

  @override
  String get alertNote => 'Notes (optional)';

  @override
  String get alertSaveActions => 'Save what I did';

  @override
  String get alertActionsSaved => 'Saved. The district will see what you did.';

  @override
  String get alertDone => 'Done so far';

  @override
  String get alertNothingYet => 'Nothing recorded yet.';

  @override
  String get alertOpenOnSource => 'Open alerts';

  @override
  String alertOpenedOn(String date) {
    return 'Raised $date';
  }

  @override
  String get historyTitle => 'Test history';

  @override
  String get historyEmpty => 'No tests yet.';

  @override
  String get historyCorrected => 'Corrected later';

  @override
  String get historyCorrection => 'Correction';

  @override
  String get historyRetest => 'Retest';

  @override
  String get historyUncalibrated => 'Not calibrated';

  @override
  String get trendTitle => 'Trend';

  @override
  String get trendNotEnough => 'Trends appear after two or more tests.';

  @override
  String get trendLimit => 'Limit';

  @override
  String get amendStart => 'Correct a mistake';

  @override
  String get amendExplain =>
      'Fix a reading that was typed wrongly. The first result is kept and marked as corrected.';

  @override
  String get amendTitle => 'Correcting a result';

  @override
  String get amendReason => 'What was wrong?';

  @override
  String get amendReasonHint => 'e.g. typed 71 instead of 7.1';

  @override
  String get amendSubmit => 'Save correction';

  @override
  String get amendSuperseded =>
      'This result was corrected. Open the newest one to make another correction.';

  @override
  String get sourceHistoryLater => 'Test history and trends will appear here.';

  @override
  String get inspectionTitle => 'Sanitary inspection';

  @override
  String get inspectionIntro =>
      'Look around the source and answer each question.';

  @override
  String get inspectionYes => 'Yes';

  @override
  String get inspectionNo => 'No';

  @override
  String get inspectionSave => 'Save inspection';

  @override
  String get inspectionSaved => 'Inspection saved';

  @override
  String get inspectionStart => 'Check the surroundings';

  @override
  String get inspectionNone => 'Surroundings not checked yet';

  @override
  String inspectionLast(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count risks found',
      one: '1 risk found',
      zero: 'no risks found',
    );
    return 'Checked $date: $_temp0';
  }

  @override
  String get activationTitle => 'Activate this device';

  @override
  String get activationIntro =>
      'Enter the activation code from your IT admin. This needs the internet once. After that, WaterCheck works without internet and nobody needs to log in.';

  @override
  String get activationCodeLabel => 'Activation code';

  @override
  String get activationScan => 'Scan QR code';

  @override
  String get activationServer => 'Server address';

  @override
  String get activationServerLabel => 'Server address';

  @override
  String get activationServerHint =>
      'Change only if the IT admin tells you to.';

  @override
  String get activationGo => 'Activate';

  @override
  String get activationWorking => 'Activating…';

  @override
  String get activationCodeFormat =>
      'An activation code has 12 letters and numbers, like K7QM-RT4W-9XHB.';

  @override
  String get activationServerFormat =>
      'The server address must start with http:// or https://.';

  @override
  String get activationBadQr =>
      'That QR code is not a WaterCheck activation code.';

  @override
  String get activationInvalidCode =>
      'This code is not recognised. Check it and try again.';

  @override
  String get activationExpiredCode =>
      'This code has expired. Ask the IT admin for a new one.';

  @override
  String get activationUsedUp =>
      'This code has already been used on as many devices as allowed. Ask the IT admin for a new one.';

  @override
  String get activationOffline =>
      'Could not reach the server. Activation needs the internet once: check the connection and the server address, then try again.';

  @override
  String activationFailed(String code) {
    return 'Activation failed ($code). Try again, or contact the IT admin.';
  }

  @override
  String get scanHint => 'Point the camera at the QR code from the IT admin.';

  @override
  String get scanCameraUnavailable =>
      'The camera cannot be used. Type the code instead.';

  @override
  String get lockMessage => 'WaterCheck is locked.';

  @override
  String get lockBiometricReason => 'Unlock WaterCheck';

  @override
  String get lockForgot => 'Forgot PIN?';

  @override
  String get lockForgotTitle => 'Forgot your PIN?';

  @override
  String get lockForgotBody =>
      'The PIN cannot be recovered. Resetting the app saves unsent records to an encrypted file for the IT admin, then erases WaterCheck from this device so it can be activated again.';

  @override
  String get lockForgotReset => 'Reset the app';

  @override
  String get lockSetupTitle => 'Choose a PIN to protect WaterCheck';

  @override
  String get lockTurnOff => 'Turn off app lock';

  @override
  String get lockOffTitle => 'Turn off the app lock?';

  @override
  String get lockOffBody =>
      'Anyone who picks up this device can then open WaterCheck and see the records on it.';

  @override
  String get lockBiometricOfferTitle => 'Use your fingerprint too?';

  @override
  String get lockBiometricOfferBody =>
      'You can unlock with your fingerprint or face. The PIN still works.';

  @override
  String get lockBiometricYes => 'Yes';

  @override
  String get lockBiometricNo => 'No, PIN only';

  @override
  String get lockCurrentPin => 'Enter your current PIN';

  @override
  String get revokedTitle => 'This device has been switched off';

  @override
  String get revokedBody =>
      'The IT admin has stopped this device from sending data. Save any unsent records to a file and give it to the IT admin. Then erase WaterCheck from this device.';

  @override
  String get resetTitle => 'Reset this device';

  @override
  String get resetBody =>
      'This erases all WaterCheck data from this device and returns it to activation. Save unsent records to a file first and give it to the IT admin.';

  @override
  String get resetCounting => 'Checking for unsent records…';

  @override
  String get resetNothingUnsent => 'Everything has been sent.';

  @override
  String resetUnsent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records not sent',
      one: '1 record not sent',
    );
    return '$_temp0';
  }

  @override
  String get resetFileHint =>
      'The file is encrypted. Only the WaterCheck server can open it.';

  @override
  String get resetSave => 'Save unsent records to a file';

  @override
  String get resetSaveAgain => 'Saved. Save another copy';

  @override
  String get resetSaved => 'File saved.';

  @override
  String get resetNotSaved => 'Not saved.';

  @override
  String get resetSaveFailed => 'The file could not be saved. Try again.';

  @override
  String get resetErase => 'Erase this device';

  @override
  String get resetConfirmTitle => 'Erase WaterCheck from this device?';

  @override
  String get resetConfirmBody =>
      'All WaterCheck data on this device will be erased. This cannot be undone.';

  @override
  String resetConfirmLoses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records have not been sent or saved and will be lost.',
      one: '1 record has not been sent or saved and will be lost.',
    );
    return '$_temp0 This cannot be undone.';
  }

  @override
  String settingsActivatedFor(String area) {
    return 'Activated for $area';
  }

  @override
  String settingsInstallation(String id) {
    return 'Installation ID: $id';
  }

  @override
  String get settingsAppLock => 'App lock';

  @override
  String get settingsAppLockHint => 'Ask for a PIN when WaterCheck opens';

  @override
  String get settingsChangePin => 'Change PIN';

  @override
  String get settingsBiometric => 'Unlock with fingerprint or face';

  @override
  String get settingsReset => 'Reset this device';

  @override
  String get settingsResetHint => 'Save unsent records, then erase WaterCheck';

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncRunning => 'Sending and receiving…';

  @override
  String syncOffline(String when) {
    return 'No connection. WaterCheck will try again by itself (next try about $when).';
  }

  @override
  String syncServerProblem(String code, String when) {
    return 'The server did not answer ($code). WaterCheck will try again by itself (next try about $when).';
  }

  @override
  String get syncRejectedTitle => 'Not accepted by the server';

  @override
  String get syncRejectedHint =>
      'These records stay on this device. Show this list to your IT admin.';

  @override
  String get entitySource => 'Water source';

  @override
  String get entityTest => 'Test';

  @override
  String get entityResult => 'Result';

  @override
  String get entityReading => 'Reading';

  @override
  String get entityAlert => 'Alert';

  @override
  String get entityAlertAction => 'Alert action';

  @override
  String get entityInspection => 'Sanitary inspection';

  @override
  String get entityCalibration => 'Calibration';

  @override
  String get entityCustomLimits => 'Custom limits';

  @override
  String get entityCustomParameter => 'Custom parameter';

  @override
  String get rejectMissingParent => 'Something it belongs to was not accepted.';

  @override
  String get rejectOutOfScope => 'It is outside this device\'s area.';

  @override
  String get rejectNoCollector => 'No collector was recorded for it.';

  @override
  String get rejectDuplicate => 'A record with the same code already exists.';

  @override
  String get rejectNotAccepted =>
      'This kind of change is not accepted from a device.';

  @override
  String get rejectInvalid => 'Some of its information was not valid.';

  @override
  String rejectOther(String reason) {
    return 'The server refused it ($reason).';
  }

  @override
  String get photoSourceTitle => 'Photos of this source';

  @override
  String get photoTesterTitle => 'Photo of the tester display (optional)';

  @override
  String get photoTake => 'Take photo';

  @override
  String get photoChoose => 'Choose photo';

  @override
  String get photoSaved =>
      'Photo saved. It will upload when the device is on Wi-Fi.';

  @override
  String get photoLowStorage =>
      'This device is almost full (less than 100 MB free). Photos are switched off so readings can still be saved. Free some space to add photos.';

  @override
  String get photoNotImage => 'That file is not a photo WaterCheck can use.';

  @override
  String get photoWaiting => 'Waiting to upload';

  @override
  String get photoUploaded => 'Uploaded';

  @override
  String get photoRejected => 'Not accepted by the server';

  @override
  String get settingsPhotosMobile => 'Upload photos on mobile data';

  @override
  String get settingsPhotosMobileHint =>
      'Off: photos wait for Wi-Fi. Readings always send on any connection.';

  @override
  String syncPhotosWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos waiting to upload',
      one: '1 photo waiting to upload',
    );
    return '$_temp0';
  }

  @override
  String get syncPhotosWifi =>
      'Photos upload on Wi-Fi, or on mobile data if you allow it in Settings.';

  @override
  String smsOfferTitle(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'This alert has not been sent for $hours hours',
      one: 'This alert has not been sent for 1 hour',
    );
    return '$_temp0';
  }

  @override
  String get smsOfferBody =>
      'The district has not heard about it yet. Send a short SMS now; the full record will follow when the phone can sync. Normal SMS charges apply.';

  @override
  String get smsOfferButton => 'Send by SMS';

  @override
  String get smsOfferFailed => 'This device cannot open the SMS app.';

  @override
  String get limitsStakeholderTitle => 'Stakeholder approval';

  @override
  String get limitsStakeholderHint =>
      'Only a stakeholder can change limits. Sign in with your WaterCheck Console account: the change is recorded under your name with your reason. Needs a connection; you are signed out right after.';

  @override
  String get limitsStakeholderUsername => 'Stakeholder username';

  @override
  String get limitsStakeholderPassword => 'Password';

  @override
  String get limitsStakeholderApprove => 'Approve and use';

  @override
  String get limitsStakeholderCancel => 'Cancel';

  @override
  String get limitsStakeholderOffline =>
      'No connection. Changing limits needs the server; try again when online.';

  @override
  String get limitsStakeholderWrong => 'Wrong username or password.';

  @override
  String get limitsStakeholderFirstSignIn =>
      'Sign in to the Console once first to set your own password.';

  @override
  String get limitsStakeholderNotStakeholder =>
      'This account is not a stakeholder account.';

  @override
  String get limitsStakeholderLocked =>
      'This account is locked for a while after too many attempts.';

  @override
  String limitsStakeholderFailed(String code) {
    return 'Could not save the limits ($code).';
  }

  @override
  String get settingsAppearance => 'Appearance and time';

  @override
  String get settingsAppearanceDevice => 'Saved on this device.';

  @override
  String settingsAppearanceFor(String name) {
    return 'Saved on this device for $name.';
  }

  @override
  String get pickSearch => 'Search by name or code';

  @override
  String get pickNoMatch => 'No source matches the search.';

  @override
  String get resultHome => 'Back to the start page';

  @override
  String get trailTitle => 'Edit history';

  @override
  String get trailCorrections => 'Corrections of this test';

  @override
  String get trailNone => 'No changes recorded.';

  @override
  String get trailUnknown => 'Unknown';

  @override
  String trailField(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'name': 'Name',
      'households_served': 'Households',
      'functional_status': 'Working',
      'is_active': 'In use',
      'source_type': 'Type',
      'lat': 'Latitude',
      'lon': 'Longitude',
      'location_accuracy_m': 'GPS accuracy',
      'label': 'Device name',
      'full_name': 'Full name',
      'phone': 'Phone',
      'collector_type': 'Role',
      'village': 'Village',
      'parish': 'Parish',
      'subcounty': 'Sub-county',
      'district': 'District',
      'organisation': 'Organisation',
      'overall': 'Result',
      'other': '$field',
    });
    return '$_temp0';
  }

  @override
  String trailChange(String field, String before, String after) {
    return '$field: $before → $after';
  }

  @override
  String amendNotYours(String name) {
    return 'Only $name, who made this test, can correct it.';
  }

  @override
  String get refresh => 'Refresh';

  @override
  String get areaVillageHint => 'Type your village; known ones are suggested';

  @override
  String get areaParishHint => 'Search known parishes, or type a new one';

  @override
  String get areaSubcountyHint => 'Search sub-counties (or their district)';

  @override
  String get areaDistrictHint => 'Search districts';

  @override
  String get areaFilledIn => 'Filled in from the sub-county';

  @override
  String areaRegion(String name) {
    return 'Region: $name';
  }

  @override
  String areaOther(String name) {
    return 'Other: \"$name\"';
  }

  @override
  String get areaOtherHint => 'Not in the list (a new place)';

  @override
  String get areaPickOrOther =>
      'Pick a sub-county from the list, or choose Other';

  @override
  String get areaPickDistrict => 'Pick the district from the list';

  @override
  String get sourceWhere => 'Where is it?';

  @override
  String get sourceWhereHint =>
      'Starts with your own area. Change it if the source is somewhere else.';

  @override
  String get sourcesSearch => 'Search by name, code or village';

  @override
  String get filterAll => 'All';

  @override
  String get filterSafe => 'Safe';

  @override
  String get filterUnsafe => 'Unsafe';

  @override
  String get filterNotTested => 'Not tested';

  @override
  String get filterMine => 'Mine';

  @override
  String get filterOthers => 'Others';

  @override
  String get filterNearby => 'Nearby';

  @override
  String get groupMine => 'Added by you';

  @override
  String get groupNearby => 'Nearby (within 5 km)';

  @override
  String get groupArea => 'In your sub-county';

  @override
  String get groupElsewhere => 'Elsewhere';

  @override
  String distanceAway(String distance) {
    return '$distance away';
  }

  @override
  String get setupLocationRequired =>
      'Needed for every test: it shows the test was made at the source.';

  @override
  String get setupLocating => 'Finding your location…';

  @override
  String get setupAtSource => 'You are at the source.';

  @override
  String get setupNoFix =>
      'Your location could not be found. Try again in the open, or say why.';

  @override
  String get setupFarReasonHint =>
      'Kept with the test and shown to the district.';

  @override
  String get navMap => 'Map';

  @override
  String get mapTitle => 'Map';

  @override
  String get mapAllAreas => 'Uganda';

  @override
  String mapWithin(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count areas within',
      one: '1 area within',
    );
    return '$_temp0';
  }

  @override
  String mapSourcesHere(int count, int placed) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sources',
      one: '1 source',
      zero: 'No sources here',
    );
    return '$_temp0 ($placed on the map)';
  }

  @override
  String get mapNoSources =>
      'No source on this device is in this area yet. Search online from Home to find others.';

  @override
  String get mapNoLocation => 'no location saved';

  @override
  String get mapShowOnMap => 'Show on the map';

  @override
  String get mapFindArea => 'Find an area';

  @override
  String get mapFindAreaHint => 'District, sub-county, parish or village';

  @override
  String get mapMyLocation => 'My location';

  @override
  String get levelCountry => 'country';

  @override
  String get levelRegion => 'region';

  @override
  String get levelDistrict => 'district';

  @override
  String get levelSubcounty => 'sub-county';

  @override
  String get levelParish => 'parish';

  @override
  String get levelVillage => 'village';

  @override
  String get refNotFound => 'Not found on this device. Sync and try again.';

  @override
  String get rulesTitle => 'Testing rules';

  @override
  String get rulesIntro =>
      'What every test needs and how often a source is due. Set by the IT admin; they reach this device with sync.';

  @override
  String get rulesRequired => 'Readings every test needs';

  @override
  String get rulesSchedule => 'When a source is due';

  @override
  String rulesRoutine(int days) {
    return 'Every $days days normally';
  }

  @override
  String rulesRainy(int days) {
    return 'Every $days days in the rainy season';
  }

  @override
  String rulesAbnormal(int days) {
    return 'Again within $days days after an abnormal result';
  }

  @override
  String rulesClears(int count) {
    return 'Back to normal after $count normal results';
  }

  @override
  String rulesDueSoon(int days) {
    return 'Shown as due $days days before';
  }

  @override
  String get rulesAtTheSource => 'At the source';

  @override
  String rulesProximity(int metres) {
    return 'Within $metres m of the source (plus the GPS error); farther needs a reason';
  }

  @override
  String get rulesDefaultLimits => 'Limits used when an area has no default';

  @override
  String get rulesSetBy =>
      'Only the IT admin can change these rules, in the Console.';

  @override
  String get limitsCalibrate => 'Calibrate with these limits';

  @override
  String get limitsTestWith => 'Test a source with these limits';

  @override
  String get limitsUsedFor => 'Where it is used';

  @override
  String limitsTestsHere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tests on this device used it.',
      one: '1 test on this device used it.',
      zero: 'No test on this device used it yet.',
    );
    return '$_temp0';
  }

  @override
  String get limitsNoAreaDefault =>
      'No area starts its tests with it by default.';

  @override
  String get limitsAreaDefault => 'New tests here start with these limits';

  @override
  String get limitsTable => 'Limits';

  @override
  String paramCode(String code) {
    return 'Code: $code';
  }

  @override
  String paramUnit(String unit) {
    return 'Unit: $unit';
  }

  @override
  String get paramCore => 'Core';

  @override
  String get paramRequired => 'Needed in every test';

  @override
  String get paramCustom => 'Added in the field';

  @override
  String paramPlausible(String min, String max) {
    return 'Readings outside $min to $max are treated as mistakes.';
  }

  @override
  String get paramLimits => 'Limit in each limit set';

  @override
  String get paramRecent => 'Recent readings on this device';

  @override
  String get paramNoReadings => 'No readings on this device yet.';

  @override
  String get searchOnline => 'Search all of Uganda';

  @override
  String get searchOnlineHint =>
      'Sources beyond the districts on this device (needs internet)';

  @override
  String get groupOnline => 'Elsewhere in Uganda (online)';

  @override
  String get searchOnlineOffline =>
      'Could not reach the server. Try again when online.';

  @override
  String get searchOnlineNone => 'Nothing else found.';

  @override
  String get searchOnlineGet => 'Get this district';

  @override
  String searchOnlineAdded(String district) {
    return '$district added to this device; syncing now.';
  }

  @override
  String get whoRecover => 'I already have a profile';

  @override
  String get whoRecoverHint =>
      'Lost your device, or using another one? Come back as yourself with a code.';

  @override
  String get recoverTitle => 'I already have a profile';

  @override
  String get recoverIntro =>
      'Enter a sign-in code: one you made on another device you use (Settings › Your area and devices), or one from your IT admin or stakeholder. Your details come back to this device, and your earlier work stays yours.';

  @override
  String get recoverCode => 'Code';

  @override
  String get recoverButton => 'Get my profile';

  @override
  String get recoverWhoGives =>
      'No code? Make one on a device you are signed in on, or ask your IT admin or the stakeholder for your area (Console › Collectors › your name › \"Sign-in code for another device\"). An admin\'s code works once, within a day; your own works once, until used.';

  @override
  String get recoverInvalid =>
      'That code is not valid. It may be mistyped or used already (an admin\'s code also expires after a day).';

  @override
  String get recoverOffline =>
      'Could not reach the server. Connect to the internet and try again.';

  @override
  String recoverWelcome(String name) {
    return 'Welcome back, $name.';
  }

  @override
  String get mapOpenSource => 'Open';

  @override
  String get mapLocateForDistance =>
      'Tap \"My location\" for the distance and the route.';

  @override
  String get photoOpen => 'Open picture';

  @override
  String get reviewPicture => 'Test picture';

  @override
  String get reviewPictureHint =>
      'Take a picture of the test (the strip, kit or meter reading). It is needed unless one of the reasons below applies.';

  @override
  String get reviewNoPictureWhy => 'No picture? Say why:';

  @override
  String get reviewPictureNeeded =>
      'Add a test picture, or choose why there is none.';

  @override
  String get noPhotoCameraBroken => 'Camera not working';

  @override
  String get noPhotoNotAllowed => 'Pictures not allowed here';

  @override
  String get noPhotoTooDark => 'Too dark to see';

  @override
  String get noPhotoOther => 'Another reason';

  @override
  String get noPhotoOtherHint => 'Type the reason';

  @override
  String get resultContextTitle => 'Where and how it was tested';

  @override
  String resultAccuracy(int metres) {
    return 'location within $metres m';
  }

  @override
  String resultFarReason(String reason) {
    return 'away from the source because: $reason';
  }

  @override
  String resultNoPhoto(String reason) {
    return 'No test picture: $reason';
  }

  @override
  String get resultShowOnMap => 'Show on the map';

  @override
  String get messagesTitle => 'Messages';

  @override
  String messagesUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Messages: $count new',
      one: 'Messages: 1 new',
    );
    return '$_temp0';
  }

  @override
  String get messagesNone =>
      'No messages yet. Messages about your tests and sources, and replies from stakeholders, appear here.';

  @override
  String get messagesEmpty =>
      'No messages yet. Ask a question or add a note; stakeholders see it in the Console.';

  @override
  String messagesAbout(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'test': 'Test',
      'source': 'Source',
      'collector': 'Collector',
      'area': 'Area',
      'other': 'Thread',
    });
    return '$_temp0';
  }

  @override
  String get messagesOpenSource => 'Open the source';

  @override
  String get messagesTestTitle => 'Messages about this test';

  @override
  String get messagesSourceTitle => 'Messages about this source';

  @override
  String areaOnMap(String where) {
    return 'On the map · $where';
  }

  @override
  String mapOnMap(String where) {
    return 'Named on the map · $where';
  }

  @override
  String sourceLocatedIn(String where) {
    return 'This point is in $where.';
  }

  @override
  String sourceLocatedNear(String where) {
    return 'This point is probably in $where (nearest named place; checked when online).';
  }

  @override
  String get sourceUseLocated => 'Use it';

  @override
  String accountTitle(String name) {
    return '$name: area and devices';
  }

  @override
  String get accountMenu => 'Your area and devices';

  @override
  String get accountMenuHint =>
      'Get assigned to an area, sign in on another device, see and sign out devices';

  @override
  String get accountAreaTitle => 'Area assignment';

  @override
  String get accountAreaHint =>
      'You can test anywhere without one. An assignment code from your IT admin makes you officially responsible for an area.';

  @override
  String get accountNotAssigned => 'Not yet assigned to an area.';

  @override
  String get accountByCode => 'assigned with a code';

  @override
  String get accountByAdmin => 'assigned by an IT admin';

  @override
  String get accountAssignButton => 'Enter an assignment code';

  @override
  String get accountAssignTitle => 'Assignment code';

  @override
  String get accountAssignHint => 'Type the code your IT admin gave you.';

  @override
  String get accountOwnCodeSection => 'Sign in on another device';

  @override
  String get accountOwnCodeIntro =>
      'Make a sign-in code here and use it on another device (\"Who is testing?\" › \"I already have a profile\"). It works once and does not expire until used. You can also ask your IT admin for one.';

  @override
  String get accountOwnCodeButton => 'Make a sign-in code';

  @override
  String get accountOwnCodeTitle => 'Your sign-in code';

  @override
  String get accountOwnCodeHint =>
      'Keep it safe; anyone with it can sign in as you. It works once and is shown only now.';

  @override
  String get accountCopy => 'Copy';

  @override
  String get accountDone => 'Done';

  @override
  String get accountContinue => 'Continue';

  @override
  String get accountDevicesTitle => 'Devices using your profile';

  @override
  String get accountDevicesHint =>
      'Select devices you no longer use to sign them out. Your records from them stay yours.';

  @override
  String get accountDevice => 'Device';

  @override
  String get accountThisDevice => 'this device';

  @override
  String accountVia(String via) {
    String _temp0 = intl.Intl.selectLogic(via, {
      'created': 'started here',
      'admin_code': 'signed in with an admin\'s code',
      'own_code': 'signed in with your own code',
      'other': 'signed in',
    });
    return '$_temp0';
  }

  @override
  String accountLastSeen(String when) {
    return 'last used $when';
  }

  @override
  String get accountSignedOut => 'signed out';

  @override
  String accountSignOutButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sign out $count devices',
      one: 'Sign out 1 device',
      zero: 'Sign out selected devices',
    );
    return '$_temp0';
  }

  @override
  String get accountConfirmTitle => 'Confirm with a code';

  @override
  String get accountConfirmHint =>
      'To confirm it is you, enter the 6-digit code. Until email and SMS are set up, your IT admin sees the code on your page in the Console and gives it to you.';

  @override
  String get accountConfirmWrong =>
      'That code is not right. Check it with your IT admin.';

  @override
  String get accountConfirmExpired =>
      'This request has expired or had too many tries. Start again.';

  @override
  String get accountCodeInvalid =>
      'That code is not valid. Check it with your IT admin.';

  @override
  String get accountCodeExpired =>
      'That code has expired. Ask your IT admin for a new one.';

  @override
  String get accountCodeUsedUp =>
      'That code has been used as many times as allowed.';

  @override
  String get accountSyncFirst =>
      'Sync first, so the server knows your profile, then try again.';

  @override
  String get accountOffline =>
      'Needs the internet. Connect and open this page again.';

  @override
  String get settingsDeviceRegistered => 'This device is registered';

  @override
  String get profileEmail => 'Email (optional)';

  @override
  String get profilePhoneOptional => 'Phone number (optional)';

  @override
  String get emailInvalid => 'That does not look like an email address.';

  @override
  String get profileTitle => 'My profile';

  @override
  String profileMenuHint(String name) {
    return '$name: details, contacts, area, devices, sign out';
  }

  @override
  String get profileEditDetails => 'Edit';

  @override
  String get profilePhoneLabel => 'Phone';

  @override
  String get profileEmailLabel => 'Email';

  @override
  String get profileNotGiven => 'Not given';

  @override
  String get profileConfirmedLabel => 'confirmed';

  @override
  String get profileNotConfirmedLabel => 'not confirmed';

  @override
  String get profileConfirmButton => 'Confirm';

  @override
  String get profileContactCodeHint =>
      'Enter the 6-digit code. Until email and SMS are set up, your IT admin gives it to you.';

  @override
  String get profileAccountTitle => 'Account';

  @override
  String get profileSwitch => 'Switch person';

  @override
  String get profileSwitchHint => 'Choose who is testing on this device.';

  @override
  String get profileSignOut => 'Sign out of this device';

  @override
  String get profileSignOutHint =>
      'Your work is sent first; a sign-in code brings you back.';

  @override
  String get profileSignOutTitle => 'Sign out of this device?';

  @override
  String get profileSignOutBody =>
      'Everything of yours is sent first, then your profile leaves this device. Your records stay yours; sign in again with a sign-in code.';

  @override
  String get profileDelete => 'Delete my profile';

  @override
  String get profileDeleteHint =>
      'For good: every device signs you out and your phone and email are erased. Your tests stay.';

  @override
  String get profileDeleteTitle => 'Delete your profile?';

  @override
  String profileDeleteBody(String name) {
    return '$name, every device will sign you out, your area assignments end, and your phone and email are erased. The tests and sources you sent stay, under your name, because the water records depend on them.';
  }

  @override
  String get profileSendFirst =>
      'Some of your work is not sent yet. Connect and sync, then try again.';

  @override
  String get mapListShow => 'Show the list of areas and sources';

  @override
  String get mapListHide => 'Hide the list';

  @override
  String get tripsTitle => 'My trips';

  @override
  String get tripsTileHint => 'Trips you followed live to a source or place';

  @override
  String get tripsHint =>
      'Trips you followed live with Go. They stay on this device and are not sent anywhere.';

  @override
  String get tripsNone =>
      'No trips yet. Choose a source or place on the map and press Go.';

  @override
  String get tripsArrived => 'Arrived';

  @override
  String get tripsStopped => 'Stopped';

  @override
  String tripsTopSpeed(String speed) {
    return 'top speed $speed';
  }

  @override
  String tripsAltitude(String low, String high) {
    return '$low–$high m high';
  }

  @override
  String get tripsDelete => 'Delete this trip';

  @override
  String get tripsDeleteTitle => 'Delete this trip from this device?';

  @override
  String mapAlertUnsafe(String source) {
    return 'Unsafe result: $source';
  }

  @override
  String mapAlertOther(String source) {
    return 'Alert: $source';
  }

  @override
  String get mapAlertOpen => 'Open the alert';

  @override
  String mapAlertsMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more alerts',
      one: '1 more alert',
    );
    return '$_temp0';
  }
}
