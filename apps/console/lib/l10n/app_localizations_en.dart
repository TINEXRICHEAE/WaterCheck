// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'WaterCheck Console';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navSources => 'Sources';

  @override
  String get navAlerts => 'Alerts';

  @override
  String get navCollectors => 'Collectors';

  @override
  String get navReports => 'Reports';

  @override
  String get navAdmin => 'Admin';

  @override
  String comingIn(String phase) {
    return 'Arrives in $phase';
  }

  @override
  String get dashboardHint =>
      'Sources tested, % unsafe, open alerts, overdue sources and collector activity for your area.';

  @override
  String get sourcesHint =>
      'All sources in your area with status, last test and history.';

  @override
  String get alertsHint =>
      'Open alerts by age and severity: acknowledge, record action, close.';

  @override
  String get collectorsHint =>
      'Who submitted what, built from submissions. Mark collectors known or flag a submission.';

  @override
  String get reportsHint =>
      'Made on this device from the data synced to it; works offline on Windows and Android.';

  @override
  String get adminReferenceData => 'Reference data';

  @override
  String get adminReferenceDataHint =>
      'Parameters, limits, tester profiles and areas loaded on this device';

  @override
  String get adminMoreHint =>
      'Changes here reach the devices with their next sync.';

  @override
  String get startupFailed =>
      'WaterCheck Console could not open its local data.';

  @override
  String get startupRetry => 'Try again';

  @override
  String get cancel => 'Cancel';

  @override
  String get signInTitle => 'Sign in to WaterCheck Console';

  @override
  String get signInUsername => 'Username';

  @override
  String get signInUsernameHint =>
      'Your phone number or email, as given by the IT admin';

  @override
  String get signInPassword => 'Password';

  @override
  String get signInGo => 'Sign in';

  @override
  String get signInWorking => 'Signing in…';

  @override
  String get signInMissing => 'Enter your username and password.';

  @override
  String get signInWrong => 'Wrong username or password.';

  @override
  String get signInLocked =>
      'Too many wrong attempts. Try again in 15 minutes, or ask the IT admin.';

  @override
  String get signInOffline =>
      'Could not reach the server. Signing in needs the internet.';

  @override
  String signInFailed(String code) {
    return 'Sign-in failed ($code). Try again, or contact the IT admin.';
  }

  @override
  String get signInAfterIdle =>
      'You were signed out after 30 minutes without activity.';

  @override
  String get signInExpired => 'Your session has ended. Please sign in again.';

  @override
  String get forgotLink => 'Forgot password?';

  @override
  String get forgotTitle => 'Forgot your password?';

  @override
  String get forgotBody =>
      'The IT admin will be asked to give you a new temporary password. Enter your username.';

  @override
  String get forgotSend => 'Send request';

  @override
  String get forgotSent =>
      'Request sent. The IT admin will contact you with a new temporary password.';

  @override
  String get forgotFailed =>
      'The request could not be sent. Try again, or contact the IT admin.';

  @override
  String get passwordTitle => 'Choose your own password';

  @override
  String get passwordIntro =>
      'You signed in with a temporary password. Choose a new password that only you know.';

  @override
  String get passwordNew => 'New password';

  @override
  String get passwordAgain => 'New password again';

  @override
  String get passwordRule =>
      'Use at least 10 characters, mixing letters and numbers.';

  @override
  String get passwordMismatch => 'The two passwords are not the same.';

  @override
  String get passwordSame =>
      'Choose a password different from the temporary one.';

  @override
  String get passwordSave => 'Save password';

  @override
  String get pinChooseTitle => 'Choose a PIN for this device';

  @override
  String unlockFor(String name) {
    return 'Signed in as $name';
  }

  @override
  String get unlockForgot => 'Forgot PIN? Sign out';

  @override
  String get offlineBanner => 'Offline: showing data saved on this device.';

  @override
  String get offlineRetry => 'Reconnect';

  @override
  String get accountMenu => 'Account';

  @override
  String get accountSignOut => 'Sign out';

  @override
  String get roleAdmin => 'IT admin';

  @override
  String get roleStakeholder => 'Stakeholder';

  @override
  String dashboardWelcome(String name) {
    return 'Signed in as $name';
  }

  @override
  String dashboardAreas(String areas) {
    return 'Your areas: $areas';
  }

  @override
  String get dashboardNoAreas =>
      'No areas have been assigned to you yet. Ask the IT admin.';

  @override
  String get dashboardAdminScope => 'IT admin: all areas';

  @override
  String get recentTitle => 'Latest tests';

  @override
  String get recentHint => 'Synced from Collect devices in your areas.';

  @override
  String get recentEmpty => 'No tests have reached this device yet.';

  @override
  String recentLine(String when, String collector) {
    return '$when · by $collector';
  }

  @override
  String get recentUnknownCollector => 'a collector';

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncRunning => 'Syncing…';

  @override
  String get syncOffline =>
      'Offline: showing data saved on this device. It will update when the connection returns.';

  @override
  String syncProblem(String code) {
    return 'Could not sync ($code). It will try again by itself.';
  }

  @override
  String get alertTriggerEcoli => 'E. coli detected';

  @override
  String get alertTriggerUnsafe => 'Unsafe result';

  @override
  String get alertTriggerBaseline => 'Sudden change';

  @override
  String get alertTriggerSms => 'Reported by SMS';

  @override
  String get alertStatusOpen => 'Open';

  @override
  String get alertStatusAcknowledged => 'Acknowledged';

  @override
  String get alertStatusAction => 'Action in progress';

  @override
  String get alertStatusClosed => 'Closed';

  @override
  String get alertStatusFalseAlarm => 'False alarm';

  @override
  String get alertsTitle => 'Alerts';

  @override
  String get alertsShowClosed => 'Show closed';

  @override
  String get alertsNone => 'No open alerts in your areas.';

  @override
  String get alertNotFound =>
      'This alert is not on this device yet. Sync and try again.';

  @override
  String alertSeverity(String severity) {
    return 'Severity: $severity';
  }

  @override
  String alertOpened(String when) {
    return 'Reported $when';
  }

  @override
  String get alertReadings => 'Readings';

  @override
  String get detected => 'Detected';

  @override
  String get notDetected => 'Not detected';

  @override
  String get alertActions => 'What to do';

  @override
  String get alertAcknowledge => 'Acknowledge';

  @override
  String get alertStartAction => 'Action in progress';

  @override
  String get alertClose => 'Close';

  @override
  String get alertFalseAlarm => 'False alarm';

  @override
  String get alertRequestLab => 'Request lab confirmation';

  @override
  String get alertAddNote => 'Add a note';

  @override
  String get alertCloseTitle => 'Close the alert: what was done?';

  @override
  String get alertFalseAlarmTitle => 'Why is this a false alarm?';

  @override
  String get alertNoteHint =>
      'For example: chlorinated the borehole, advised households to boil water';

  @override
  String get alertSave => 'Save';

  @override
  String get alertHistory => 'History';

  @override
  String get alertBySystem => 'WaterCheck';

  @override
  String get alertByYou => 'you';

  @override
  String get alertByStakeholder => 'a stakeholder';

  @override
  String get eventAcknowledged => 'Acknowledged';

  @override
  String get eventAction => 'Action started';

  @override
  String get eventClosed => 'Closed';

  @override
  String get eventFalseAlarm => 'Marked a false alarm';

  @override
  String get eventActionTaken => 'Collector recorded actions';

  @override
  String get eventLabRequested => 'Lab confirmation requested';

  @override
  String get eventEscalated => 'Escalated: nobody had acknowledged it';

  @override
  String get eventSms => 'Received by SMS';

  @override
  String get eventReconciled => 'SMS alert matched with the full record';

  @override
  String get eventNote => 'Note';

  @override
  String get inboxTitle => 'Notifications';

  @override
  String get inboxMarkAll => 'Mark all read';

  @override
  String get inboxEmpty => 'No notifications.';

  @override
  String get inboxOffline => 'Notifications need a connection.';

  @override
  String get filterArea => 'Area';

  @override
  String get filterAllAreas => 'All my areas';

  @override
  String get filterPeriod => 'Period';

  @override
  String filterDays(int days) {
    return 'Last $days days';
  }

  @override
  String get filterProfile => 'Judge results by';

  @override
  String get filterAsCollected => 'Profile used at collection';

  @override
  String get profileShownAsCollected =>
      'Each result is shown under the profile used when it was collected.';

  @override
  String profileShownUnder(String code) {
    return 'All results re-evaluated under $code. Saved results do not change.';
  }

  @override
  String get kpiTested => 'Sources tested';

  @override
  String kpiOfSources(int count) {
    return 'of $count sources';
  }

  @override
  String get kpiUnsafe => 'Tests unsafe';

  @override
  String kpiUnsafeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unsafe tests',
      one: '1 unsafe test',
      zero: 'no unsafe tests',
    );
    return '$_temp0';
  }

  @override
  String get kpiOpenAlerts => 'Open alerts';

  @override
  String get kpiOpenAlertsHint => 'Not closed yet';

  @override
  String get kpiAckTime => 'Time to acknowledge';

  @override
  String get kpiAckTimeHint => 'Median, alerts in the period';

  @override
  String overdueTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count overdue sources',
      one: '1 overdue source',
      zero: 'Overdue sources',
    );
    return '$_temp0';
  }

  @override
  String get overdueNone => 'No source is overdue for testing.';

  @override
  String overdueSince(String when) {
    return 'Test was due $when';
  }

  @override
  String get seeAllSources => 'All sources';

  @override
  String get collectorActivity => 'Collector activity';

  @override
  String get seeAllCollectors => 'All collectors';

  @override
  String get collectorsNone => 'Nobody submitted data in this period.';

  @override
  String collectorLine(int count, String when) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count submissions',
      one: '1 submission',
    );
    return '$_temp0, last $when';
  }

  @override
  String get markKnown => 'Known';

  @override
  String get markFlagged => 'Flagged';

  @override
  String durationDays(int count) {
    return '$count days';
  }

  @override
  String durationHours(int count) {
    return '$count h';
  }

  @override
  String durationMinutes(int count) {
    return '$count min';
  }

  @override
  String get sourcesSearch => 'Search by code or name';

  @override
  String get filterAll => 'All';

  @override
  String get filterUnsafe => 'Unsafe';

  @override
  String get filterOverdue => 'Overdue';

  @override
  String get filterNotTested => 'Not tested';

  @override
  String sourcesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sources',
      one: '1 source',
      zero: 'No sources',
    );
    return '$_temp0';
  }

  @override
  String get neverTested => 'Never tested';

  @override
  String lastTested(String when) {
    return 'Last tested $when';
  }

  @override
  String get overdueShort => 'Overdue';

  @override
  String functionalStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'functional': 'Functional',
      'partly_functional': 'Partly functional',
      'broken': 'Broken',
      'other': '$status',
    });
    return '$_temp0';
  }

  @override
  String sourceType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'borehole': 'Borehole',
      'shallow_well': 'Shallow well',
      'protected_spring': 'Protected spring',
      'tap': 'Tap',
      'rain_tank': 'Rain tank',
      'other': 'Other source',
    });
    return '$_temp0';
  }

  @override
  String get sourceNotFound =>
      'This source is not in your areas, or has not synced yet.';

  @override
  String get sourceUpdate => 'Update source';

  @override
  String get sourceName => 'Name';

  @override
  String get sourceHouseholds => 'Households served (leave empty to keep)';

  @override
  String get sourceStatusLabel => 'Working status';

  @override
  String get historyTitle => 'Test history';

  @override
  String reEvaluatedUnder(String code) {
    return 're-evaluated under $code';
  }

  @override
  String collectedUnder(String code) {
    return 'judged under $code';
  }

  @override
  String get submissionFlagged => 'Flagged as suspicious';

  @override
  String get flagSubmission => 'Flag as suspicious';

  @override
  String get flagReasonHint =>
      'What looks wrong? For example: readings identical to last week';

  @override
  String get flagSave => 'Flag';

  @override
  String get photosTitle => 'Photos';

  @override
  String get photosNone => 'No photos.';

  @override
  String get photoNeedsConnection => 'Needs a connection';

  @override
  String get photoNotUploaded => 'Not uploaded yet';

  @override
  String get inspectionsTitle => 'Sanitary inspections';

  @override
  String get inspectionsNone => 'No inspections.';

  @override
  String inspectionRisks(int risks, int answered) {
    return '$risks of $answered risks present';
  }

  @override
  String get submittedBy => 'Submitted by';

  @override
  String get markCollector => 'Mark collector';

  @override
  String get markAsKnown => 'Mark as known';

  @override
  String get markAsFlagged => 'Flag collector';

  @override
  String get navProfile => 'Profile and settings';

  @override
  String get profileTitle => 'My profile';

  @override
  String get profileOffline => 'Changing notifications needs a connection.';

  @override
  String get profileFailed => 'Could not save. Try again.';

  @override
  String get notifyTitle => 'How alerts reach me';

  @override
  String get notifyHint =>
      'Alerts for your areas are always in the Console. Choose the other channels.';

  @override
  String get notifyInApp => 'In the Console';

  @override
  String get notifyInAppHint => 'Always on';

  @override
  String get notifyEmail => 'Email';

  @override
  String get notifyNoEmail =>
      'No email address on file; ask your IT administrator.';

  @override
  String get notifyPush => 'Phone notification';

  @override
  String get notifyPushHint => 'On Android phones signed in to the Console';

  @override
  String get notifySms => 'SMS';

  @override
  String get notifyNoPhone =>
      'No phone number on file; ask your IT administrator.';

  @override
  String get connectionLost =>
      'Connection lost. Showing the data from the last sync.';

  @override
  String get viewList => 'List';

  @override
  String get viewMap => 'Map';

  @override
  String get mapNoBackground =>
      'The map background is not available yet; dots still show where sources are.';

  @override
  String mapMissingLocation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sources have no location and are not on the map.',
      one: '1 source has no location and is not on the map.',
    );
    return '$_temp0';
  }

  @override
  String get mapAttribution => 'OpenStreetMap contributors';

  @override
  String get profileAreas => 'Areas';

  @override
  String get profileResponsibilities => 'Responsibilities';

  @override
  String get profileAllResponsibilities => 'All alerts in my areas';

  @override
  String get profileContacts => 'Contacts';

  @override
  String get profileNoContacts => 'None on file; ask your IT administrator.';

  @override
  String collectorType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'vht': 'VHT member',
      'lc1': 'LC1 leader',
      'resident': 'Trained resident',
      'student': 'Student',
      'other': 'Other collector',
    });
    return '$_temp0';
  }

  @override
  String responsibility(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'water': 'Water',
      'sanitation': 'Sanitation',
      'health_inspection': 'Health inspection',
      'other': '$code',
    });
    return '$_temp0';
  }

  @override
  String get conflictTitle => 'Two changes disagree';

  @override
  String conflictBody(String phone, String current) {
    return 'A device set the working status to \"$phone\", but it is now \"$current\" from a newer change. Which is right?';
  }

  @override
  String get conflictKeep => 'Keep current';

  @override
  String get conflictUsePhone => 'Use the device\'s value';

  @override
  String get conflictActive => 'In use';

  @override
  String get conflictInactive => 'No longer in use';

  @override
  String get mapUnsafe => 'Unsafe';

  @override
  String get mapInconclusive => 'Inconclusive';

  @override
  String get mapOverdue => 'Overdue';

  @override
  String get mapSafe => 'Safe';

  @override
  String get mapNotTested => 'Not tested';

  @override
  String get mapUnsafeResult => 'Unsafe result';

  @override
  String get mapNoLocation =>
      'Turn on location to see how far sources are from you.';

  @override
  String get mapLocateMe => 'Show where I am';

  @override
  String get mapLayers => 'Map layers';

  @override
  String get mapLayerDistances => 'Distances from me';

  @override
  String get mapLayerLabels => 'Source names';

  @override
  String get mapLatestIssue => 'Latest issue';

  @override
  String get mapOpenMap => 'Open map';

  @override
  String get mapNoIssue => 'No open issues in your areas.';

  @override
  String mapSeverity(String severity) {
    String _temp0 = intl.Intl.selectLogic(severity, {
      'critical': 'Critical',
      'high': 'High',
      'medium': 'Medium',
      'low': 'Low',
      'other': '$severity',
    });
    return '$_temp0';
  }

  @override
  String mapAway(String distance) {
    return '$distance away';
  }

  @override
  String mapAgo(String time) {
    return '$time ago';
  }

  @override
  String get mapOpenSource => 'Open the source';

  @override
  String get mapYouAreHere => 'You are here';

  @override
  String mapCluster(int count) {
    return '$count sources here; zoom in';
  }

  @override
  String get noticeTitle => 'Water test notice';

  @override
  String get noticeHeadlineUnsafe =>
      'NOT SAFE to drink without boiling or treating';

  @override
  String get noticeHeadlineCaution =>
      'NOT CONFIRMED SAFE: boil or treat before drinking';

  @override
  String get noticeHeadlineSafe => 'Safe on the last test';

  @override
  String get noticeHeadlineNotTested => 'Not tested yet';

  @override
  String noticeTested(String date) {
    return 'Tested on $date';
  }

  @override
  String get noticeWhatToDo => 'What to do';

  @override
  String get noticeBoil =>
      'Boil drinking water for at least one minute, or treat it (for example with chlorine tablets).';

  @override
  String get noticeOtherSource =>
      'If you can, use another safe source until the next test.';

  @override
  String get noticeContainers => 'Keep water containers covered and clean.';

  @override
  String get noticeReportChange =>
      'Tell the village health team if the colour, smell or taste changes.';

  @override
  String get noticeMeasured => 'What was measured';

  @override
  String get noticeLimitationNoGermTest =>
      'This test cannot detect germs. Boiling is still the safest choice.';

  @override
  String get noticeLimitationGermNegative =>
      'No E. coli was found in this test, but water can become unsafe at any time.';

  @override
  String get noticeContact =>
      'Questions: ask the village health team (VHT) or the health inspector.';

  @override
  String noticePrinted(String date) {
    return 'Printed $date from WaterCheck';
  }

  @override
  String get pdfColParameter => 'Measured';

  @override
  String get pdfColValue => 'Value';

  @override
  String get pdfColLimit => 'Safe range';

  @override
  String get pdfColResult => 'Result';

  @override
  String readingResult(String result) {
    String _temp0 = intl.Intl.selectLogic(result, {
      'ok': 'OK',
      'high': 'Too high',
      'low': 'Too low',
      'detected': 'Found',
      'unacceptable': 'Not acceptable',
      'invalid': 'Invalid',
      'other': '-',
    });
    return '$_temp0';
  }

  @override
  String statusWord(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'safe': 'SAFE',
      'unsafe': 'UNSAFE',
      'inconclusive': 'INCONCLUSIVE',
      'other': 'NOT TESTED',
    });
    return '$_temp0';
  }

  @override
  String get reportTitle => 'Water quality report';

  @override
  String reportArea(String name) {
    return 'Area: $name';
  }

  @override
  String reportPeriod(String from, String to) {
    return 'Period: $from to $to';
  }

  @override
  String reportGenerated(String date) {
    return 'Generated $date on this device';
  }

  @override
  String get reportProfiles => 'Limit sets used';

  @override
  String reportProfileLine(String code, String title, int version) {
    return '$code: $title (version $version)';
  }

  @override
  String get reportProvisional =>
      'Provisional: may change after field calibration.';

  @override
  String reportCustom(String base, String reason) {
    return 'Custom limits based on $base. Reason: $reason';
  }

  @override
  String get reportIndicators => 'Impact indicators';

  @override
  String get indSourcesTested => 'Sources tested in the period';

  @override
  String get indTests => 'Tests in the period';

  @override
  String get indAbnormalAction => 'Abnormal tests with a documented action';

  @override
  String get indOnSchedule => 'Sources tested on schedule';

  @override
  String get indCollectors => 'Collectors active';

  @override
  String get indAck => 'Median time to acknowledge an alert';

  @override
  String indOf(int n, int total) {
    return '$n of $total';
  }

  @override
  String get reportSources => 'Sources';

  @override
  String get colSource => 'Source';

  @override
  String get colVillage => 'Village';

  @override
  String get colLastTest => 'Last test';

  @override
  String get colStatus => 'Status';

  @override
  String get colReadings => 'Latest readings (value / safe range)';

  @override
  String get reportAlerts => 'Alerts and responses';

  @override
  String get colOpened => 'Opened';

  @override
  String get colAlert => 'Alert';

  @override
  String get colActions => 'What was done';

  @override
  String get reportNoAlerts => 'No alerts were opened in this period.';

  @override
  String get reportLimitations => 'Limitations';

  @override
  String get reportLimitationsText =>
      'Results come from field test kits, not a laboratory. A test cannot detect germs unless E. coli was tested. Each result is judged under the limit set used when it was collected (named above); provisional limits may change after field calibration. Sources without a location or never tested are listed but cannot show trends.';

  @override
  String reportPage(int n, int total) {
    return 'Page $n of $total';
  }

  @override
  String get reportNone => 'None';

  @override
  String get reportsTitle => 'Reports and exports';

  @override
  String get reportsPdf => 'PDF report';

  @override
  String get reportsPdfHint =>
      'Summary, impact indicators, sources with their latest values, alerts and what was done.';

  @override
  String get reportsCsv => 'Readings (CSV)';

  @override
  String get reportsCsvHint =>
      'One row per reading, for spreadsheets and analysis.';

  @override
  String reportsSaved(String name) {
    return 'Saved: $name';
  }

  @override
  String get reportsCancelled => 'Not saved.';

  @override
  String reportsFailed(String error) {
    return 'Could not make the file: $error';
  }

  @override
  String get reportsPrint => 'Print';

  @override
  String get reportsSave => 'Save';

  @override
  String get noticeAction => 'Community notice';

  @override
  String get noticeSize => 'Paper size';

  @override
  String get colIndicator => 'Indicator';

  @override
  String get colValue => 'Value';

  @override
  String get adminNeedsConnection =>
      'Managing people and devices needs a connection to the server.';

  @override
  String areaLevel(String level) {
    String _temp0 = intl.Intl.selectLogic(level, {
      'country': 'national',
      'region': 'region',
      'district': 'district',
      'subcounty': 'sub-county',
      'parish': 'parish',
      'village': 'village',
      'other': '$level',
    });
    return '$_temp0';
  }

  @override
  String get areaPickTitle => 'Choose areas';

  @override
  String get areaPickOne => 'Choose an area';

  @override
  String get areaPickSearch =>
      'Search any village, sub-county, district or region';

  @override
  String areaPickDone(int n) {
    return 'Use $n areas';
  }

  @override
  String get adminPeople => 'People';

  @override
  String get adminPeopleHint =>
      'Create stakeholders and IT admins at any level, reset passwords, disable accounts.';

  @override
  String get adminPhones => 'Collect devices';

  @override
  String get adminPhonesHint =>
      'Activation codes, devices in use, revoking a lost device.';

  @override
  String get adminChain => 'Who covers an area';

  @override
  String get adminChainHint =>
      'The chain of people an alert reaches, level by level, and the gaps.';

  @override
  String get usersTitle => 'People';

  @override
  String get usersNew => 'New person';

  @override
  String get usersSearch => 'Search by name, username or area';

  @override
  String get usersNeverSignedIn => 'Never signed in';

  @override
  String usersLastSignIn(String when) {
    return 'Last sign-in $when';
  }

  @override
  String get usersDisabled => 'Disabled';

  @override
  String get usersLocked => 'Locked';

  @override
  String get usersFirstSignIn => 'Not signed in yet';

  @override
  String get usersFullName => 'Full name';

  @override
  String get usersUsername => 'Username (email or phone)';

  @override
  String get usersOrganisation => 'Organisation';

  @override
  String get usersPosition => 'Position';

  @override
  String get usersPhone => 'Phone';

  @override
  String get usersEmail => 'Email';

  @override
  String get usersAreas => 'Areas';

  @override
  String get usersAddArea => 'Add or change areas';

  @override
  String get usersAreasHint =>
      'Any level, from a village to national. The person sees these areas and everything below them, and receives alerts from them.';

  @override
  String get usersResponsibilities => 'Responsibilities';

  @override
  String get usersResponsibilitiesHint =>
      'None chosen: every alert in their areas.';

  @override
  String get usersActive => 'Account active';

  @override
  String get usersActiveHint =>
      'Turning it off signs the person out everywhere.';

  @override
  String get usersResetPassword => 'Reset password';

  @override
  String get usersCreate => 'Create';

  @override
  String get usersTaken => 'That username is already in use.';

  @override
  String get usersSelfLockout =>
      'You cannot disable your own account or remove your own IT admin role.';

  @override
  String usersFailed(String code) {
    return 'Could not save ($code).';
  }

  @override
  String get credentialsTitle => 'Temporary password';

  @override
  String get credentialsHint =>
      'Shown only now. Give it to the person in person, by SMS or by email; they must change it when they first sign in.';

  @override
  String credentialsUsername(String name) {
    return 'Username: $name';
  }

  @override
  String get credentialsCopy => 'Copy';

  @override
  String get credentialsDone => 'Done';

  @override
  String get phonesTitle => 'Collect devices';

  @override
  String get phonesHint =>
      'Devices activated with a code for an area. Revoke a lost or stolen device: it stops syncing and locks itself.';

  @override
  String get phonesNone => 'No devices activated yet.';

  @override
  String get phonesNewCode => 'New activation code';

  @override
  String phonesActivity(int collectors, int tests) {
    return '$collectors collectors, $tests tests';
  }

  @override
  String get phonesNeverSynced => 'Never synced';

  @override
  String phonesLastSeen(String when) {
    return 'Last sync $when';
  }

  @override
  String phonesRevokedAt(String when) {
    return 'Revoked $when';
  }

  @override
  String get phonesRevoke => 'Revoke';

  @override
  String get phonesRevokeTitle => 'Revoke this device?';

  @override
  String get phonesRevokeHint =>
      'It stops syncing at once. Unsent records on it are saved to an encrypted file only the server can read.';

  @override
  String get phonesCodes => 'Recent activation codes';

  @override
  String get phonesNoCodes => 'No codes yet.';

  @override
  String phonesCodeLine(int used, int max, String until) {
    return '$used of $max devices · valid until $until';
  }

  @override
  String phonesNewCodeFor(String area) {
    return 'Activation code for $area';
  }

  @override
  String phonesMax(int n) {
    return 'Up to $n devices';
  }

  @override
  String phonesValidDays(int n) {
    return 'Valid for $n days';
  }

  @override
  String get phonesCreateCode => 'Create code';

  @override
  String phonesCodeTitle(String area) {
    return 'Code for $area';
  }

  @override
  String get phonesCodeHint =>
      'Shown only now. On the device, open WaterCheck Collect and scan the QR code or type the code.';

  @override
  String get phonesQrLabel => 'Activation QR code';

  @override
  String get chainTitle => 'Who covers an area';

  @override
  String get chainHint =>
      'Pick any area to see who an alert from it reaches, level by level. Levels with nobody are skipped; the IT admins are told only when nobody covers it.';

  @override
  String get chainPick => 'Choose an area';

  @override
  String get chainGap => 'Nobody at this level (skipped)';

  @override
  String get chainFirst => 'Gets the first notice';

  @override
  String get chainNobody =>
      'Nobody covers this area: alerts from it go to the IT admins.';

  @override
  String get limitSetsTitle => 'Limit sets';

  @override
  String get limitSetsHint =>
      'Published sets come from the standards. A custom set changes some limits for tests from now on; it is recorded under your name with your comment, and earlier results keep the limits they were judged under.';

  @override
  String get limitSetsHintAdmin =>
      'Published and custom sets. Only stakeholders create custom sets (in the Console, or on a device at calibration after signing in).';

  @override
  String get limitSetsNew => 'New custom limit set';

  @override
  String limitSetsCustomOf(String base) {
    return 'Custom, based on $base';
  }

  @override
  String get limitSetsProvisional =>
      'Provisional: may change after field calibration';

  @override
  String limitSetsReason(String reason) {
    return 'Comment: $reason';
  }

  @override
  String get limitSetsBase => 'Based on';

  @override
  String get limitSetsMin => 'Min';

  @override
  String get limitSetsMax => 'Max';

  @override
  String get limitSetsComment => 'Your comment (why these limits)';

  @override
  String get limitSetsCommentHint => 'Required. Recorded with your name.';

  @override
  String limitSetsChanged(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n limits changed',
      one: '1 limit changed',
      zero: 'No limit changed yet',
    );
    return '$_temp0';
  }

  @override
  String get limitSetsSave => 'Create limit set';

  @override
  String get navLimitSets => 'Limit sets';

  @override
  String get adminSystem => 'System';

  @override
  String get adminSystemHint => 'Health of the server and the audit log';

  @override
  String get adminSecurity => 'Sign-in security';

  @override
  String get adminSecurityHint => 'Lockout, password length and idle timeout';

  @override
  String get adminRouting => 'Alert routing';

  @override
  String get adminRoutingHint =>
      'Which responsibilities each kind of alert reaches';

  @override
  String get adminPlaces => 'Places';

  @override
  String get adminPlacesHint =>
      'Add parishes and villages, rename places, set default limit sets';

  @override
  String get adminParams => 'New parameters';

  @override
  String get adminParamsHint =>
      'Approve, rename, merge or reject parameters added in the field';

  @override
  String get adminCards => 'Response cards';

  @override
  String get adminCardsHint =>
      'What collectors are told to do after an unsafe result';

  @override
  String get systemHealth => 'System health';

  @override
  String get systemRefresh => 'Refresh';

  @override
  String get systemAudit => 'Audit log';

  @override
  String get systemAuditHint =>
      'Every change by a person or device, newest first. Filter by action (for example user. or reference_profile.) and dates.';

  @override
  String get systemAuditAction => 'Action starts with';

  @override
  String get systemAuditAnyDate => 'Any date';

  @override
  String get systemAuditApply => 'Apply';

  @override
  String get systemAuditExport => 'Export CSV';

  @override
  String get systemAuditEmpty => 'Nothing matches these filters.';

  @override
  String get systemAuditSystem => 'System';

  @override
  String systemExported(String name) {
    return 'Saved $name';
  }

  @override
  String get healthDatabase => 'Database';

  @override
  String get healthOk => 'Working';

  @override
  String get healthDown => 'Not reachable';

  @override
  String get healthWorker => 'Last background job';

  @override
  String get healthNever => 'None yet';

  @override
  String get healthJobs => 'Jobs waiting';

  @override
  String healthJobsValue(int queued, int overdue) {
    return '$queued ($overdue late)';
  }

  @override
  String get healthFailed => 'Failures (24 h)';

  @override
  String get healthPhones => 'Devices active (7 days)';

  @override
  String healthPhonesValue(int active, int total) {
    return '$active of $total';
  }

  @override
  String get healthRecords => 'Tests received (24 h)';

  @override
  String get healthConflicts => 'Open sync conflicts';

  @override
  String get healthPhotos => 'Photos';

  @override
  String healthPhotosValue(int count, String mb) {
    return '$count ($mb MB)';
  }

  @override
  String get healthBackup => 'Last backup';

  @override
  String get healthBackupNone => 'Not set up yet (comes with deployment)';

  @override
  String healthVersions(String list) {
    return 'Collect versions in use: $list';
  }

  @override
  String get securityTitle => 'Sign-in security';

  @override
  String get securityHint =>
      'Applies at each person\'s next sign-in or password change. The idle timeout applies to the Console.';

  @override
  String get securityMaxFailed => 'Wrong passwords before lockout';

  @override
  String get securityLockout => 'Lockout length (minutes)';

  @override
  String get securityPasswordLength => 'Shortest password allowed';

  @override
  String get securityIdle => 'Console idle timeout (minutes)';

  @override
  String securityRange(int min, int max) {
    return 'From $min to $max';
  }

  @override
  String get securityOutOfRange => 'Outside the allowed range';

  @override
  String get securitySave => 'Save';

  @override
  String get securitySaved => 'Security settings saved';

  @override
  String get routingTitle => 'Alert routing';

  @override
  String get routingHint =>
      'Besides the people covering the area, each kind of alert also reaches the people with the ticked responsibilities.';

  @override
  String get routingResponsibility => 'Responsibility';

  @override
  String routingTrigger(String rule) {
    String _temp0 = intl.Intl.selectLogic(rule, {
      'ecoli': 'E. coli found',
      'unsafe': 'Unsafe readings',
      'baseline_jump': 'Sudden change',
      'sms': 'By text message',
      'other': '$rule',
    });
    return '$_temp0';
  }

  @override
  String get routingSave => 'Save routing';

  @override
  String get routingSaved => 'Alert routing saved';

  @override
  String get routingAdd => 'New responsibility';

  @override
  String get routingAddName => 'Name, for example School health';

  @override
  String get routingAddCreate => 'Create';

  @override
  String get routingExists =>
      'That responsibility exists already, or the server is not reachable.';

  @override
  String get placesTitle => 'Places';

  @override
  String get placesHint =>
      'The official list ends at sub-county. Add parishes and villages below it, fix names, and choose the limit set devices in an area start with.';

  @override
  String get placesAdd => 'Add a place below';

  @override
  String get placesRename => 'Rename';

  @override
  String get placesLevel => 'Level';

  @override
  String get placesName => 'Name';

  @override
  String get placesAddSave => 'Add';

  @override
  String get placesRenameSave => 'Save name';

  @override
  String placesAdded(String name) {
    return '$name added';
  }

  @override
  String placesRenamed(String name) {
    return 'Renamed to $name';
  }

  @override
  String get placesExists => 'A place with that name is already there.';

  @override
  String get placesDefault => 'Default limit set';

  @override
  String get placesDefaultHint =>
      'Devices in this area, and the areas below it, start with this set. Tests already taken keep the set they were judged by.';

  @override
  String get placesInherit => 'Same as the area above';

  @override
  String get placesDefaultSaved => 'Default limit set saved';

  @override
  String get paramsTitle => 'New parameters';

  @override
  String get paramsHint =>
      'Collectors can add a parameter that is not in the list. Approve it, fix its name, merge it into an existing parameter, or reject it.';

  @override
  String get paramsNone => 'Nothing waiting for review.';

  @override
  String paramsBy(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count readings',
      one: '1 reading',
      zero: 'no readings',
    );
    return 'Added by $name · $_temp0';
  }

  @override
  String get paramsApprove => 'Approve';

  @override
  String get paramsRename => 'Rename';

  @override
  String get paramsMerge => 'Merge into...';

  @override
  String get paramsMergeInto => 'Merge into';

  @override
  String get paramsReject => 'Reject';

  @override
  String get paramsSaveName => 'Save';

  @override
  String get paramsDone => 'Review saved';

  @override
  String get cardsTitle => 'Response cards';

  @override
  String get cardsHint =>
      'Shown to collectors after a result. Each save makes a new version; devices get it with their next sync.';

  @override
  String cardsVersion(int v) {
    return 'version $v';
  }

  @override
  String get cardsEdit => 'Edit card';

  @override
  String get cardsCardTitle => 'Title';

  @override
  String get cardsActions => 'What to do';

  @override
  String get cardsActionsHint => 'One step per line, in plain words';

  @override
  String get cardsReportNote => 'Note on reporting';

  @override
  String get cardsSave => 'Save new version';

  @override
  String get cardsSaved => 'Card saved';

  @override
  String get accountAbout => 'About WaterCheck';

  @override
  String get appearanceTitle => 'Appearance and time';

  @override
  String get appearanceHint =>
      'Saved with your account, so they follow you to any device.';

  @override
  String get appearanceLocalOnly =>
      'Saved on this device only: the server could not be reached.';

  @override
  String get signOutConfirmTitle => 'Sign out with changes not sent?';

  @override
  String signOutConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes have not reached the server yet.',
      one: '1 change has not reached the server yet.',
    );
    return '$_temp0 On the web they are lost when you sign out.';
  }

  @override
  String get alertsFilterOpen => 'Open';

  @override
  String get alertsFilterAll => 'All';

  @override
  String paramsRejectTitle(String name) {
    return 'Reject $name?';
  }

  @override
  String get paramsRejectBody =>
      'Collectors can no longer pick it. Readings already taken keep their values.';

  @override
  String get adminArchived => 'Archived';

  @override
  String get adminArchivedHint =>
      'Devices, collectors, sources and tests that were archived; restore them here';

  @override
  String get archiveAction => 'Archive…';

  @override
  String get archiveSource => 'Archive this source';

  @override
  String get archiveTest => 'Archive this test';

  @override
  String get archivedTag => 'archived';

  @override
  String archiveTitle(String label) {
    return 'Archive $label?';
  }

  @override
  String archiveCascade(String entity) {
    String _temp0 = intl.Intl.selectLogic(entity, {
      'installation': 'The device is revoked, and its collectors, their tests and the sources only they used are archived too.',
      'collector': 'Their tests and the sources only they used are archived too. Sources others have tested stay.',
      'water_source': 'Its tests and alerts are archived too.',
      'test_session': 'Its results and alerts are archived too.',
      'other': 'Related records are archived too.',
    });
    return '$_temp0';
  }

  @override
  String get archiveRestorable =>
      'Archived records disappear from lists, maps, dashboards, reports and devices. Nothing is deleted: Admin › Archived can restore them.';

  @override
  String get archiveReason => 'Reason';

  @override
  String get archiveReasonHint => 'At least 5 characters, e.g. \"test data\"';

  @override
  String get archiveConfirm => 'Archive';

  @override
  String archiveDone(String counts) {
    return 'Archived: $counts';
  }

  @override
  String get archiveUndo => 'Undo';

  @override
  String get archiveAlready => 'This is already archived.';

  @override
  String archiveCount(String entity, int n) {
    String _temp0 = intl.Intl.selectLogic(entity, {
      'installation': 'phone',
      'collector': 'collector',
      'water_source': 'source',
      'test_session': 'test',
      'alert': 'alert',
      'other': '$entity',
    });
    String _temp1 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$n $_temp0$_temp1';
  }

  @override
  String archiveEntity(String entity) {
    String _temp0 = intl.Intl.selectLogic(entity, {
      'installation': 'Phone',
      'collector': 'Collector',
      'water_source': 'Source',
      'test_session': 'Test',
      'other': '$entity',
    });
    return '$_temp0';
  }

  @override
  String archiveBy(String name, String when) {
    return 'Archived by $name, $when';
  }

  @override
  String get archiveListTitle => 'Archived';

  @override
  String get archiveListHint =>
      'Each line is one archive action and everything it took with it. Restoring brings all of it back.';

  @override
  String get archiveListNone => 'Nothing is archived.';

  @override
  String get archiveRestore => 'Restore';

  @override
  String archiveRestoreTitle(String label) {
    return 'Restore $label?';
  }

  @override
  String get archiveRestoreBody =>
      'Everything this action archived comes back to lists, dashboards, reports and devices.';

  @override
  String get archiveRestorePhone =>
      'Its records come back. The device itself stays revoked: issue a new activation code to use it again.';

  @override
  String get archiveRestored => 'Restored';

  @override
  String get moreActions => 'More actions';

  @override
  String get phonesName => 'Name this device';

  @override
  String get phonesNameHint => 'e.g. Health centre tablet';

  @override
  String get trailTitle => 'Edit history';

  @override
  String get trailCorrections => 'Corrections of this test';

  @override
  String get trailNone => 'No changes recorded.';

  @override
  String get trailUnknown => 'Unknown';

  @override
  String trailChange(String field, String before, String after) {
    return '$field: $before → $after';
  }

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
  String get refresh => 'Refresh';

  @override
  String get kpiTestedListHint =>
      'Every source, latest test first. Tap one to open it.';

  @override
  String get kpiUnsafeListHint =>
      'Unsafe tests in the period, newest first. Tap one to open its source.';

  @override
  String get kpiOpenAlertsListHint =>
      'Alerts not closed yet. Tap one to open it.';

  @override
  String get kpiWaitingAckListHint =>
      'Alerts still waiting to be acknowledged, oldest first.';

  @override
  String get kpiOverdueListHint =>
      'Sources whose next test is overdue. Tap one to open it.';

  @override
  String get kpiCollectorListHint => 'Their tests in the period, newest first.';

  @override
  String kpiNotTestedInPeriod(String when) {
    return 'Not tested in the period (last $when)';
  }

  @override
  String get kpiListAfterSync =>
      'The list appears once this device has finished its first sync.';

  @override
  String get kpiListEmpty => 'Nothing to show for this period.';

  @override
  String get kpiListClose => 'Close';

  @override
  String get pinSkip => 'Skip: no PIN on this device';

  @override
  String get lockTitle => 'App lock';

  @override
  String get lockSwitch => 'Ask for a PIN on this device';

  @override
  String get lockHint =>
      'Optional. Turn it off on an office computer shared with colleagues; anyone using this device then sees your areas.';

  @override
  String get lockAdminRequired =>
      'Required for IT admins, who can change people, devices and records.';

  @override
  String get lockOffTitle => 'Turn off the PIN?';

  @override
  String get lockOffBody =>
      'WaterCheck will open on this device without a PIN, and stay open when no one is using it. Sign out when you leave a shared computer.';

  @override
  String get lockOffConfirm => 'Turn off';

  @override
  String get recoveryAction => 'Sign-in code for another device';

  @override
  String recoveryTitle(String name) {
    return 'Code for $name';
  }

  @override
  String get recoveryHow =>
      'Give this code to the collector (call or text them). In WaterCheck Collect on any phone: \"Who is testing?\" › \"I already have a profile\" › enter the code. They come back as the same person, with their details. The code works once.';

  @override
  String recoveryValid(String when) {
    return 'Valid until $when.';
  }

  @override
  String get recoveryCopy => 'Copy';

  @override
  String get recoveryNotYours =>
      'This collector does not work in your areas. Ask the IT admin.';

  @override
  String get showOnMap => 'Show on map';

  @override
  String get deviceTitle => 'Device';

  @override
  String deviceActivated(String when) {
    return 'Activated $when';
  }

  @override
  String get deviceCollectors => 'Collectors and testers on this device';

  @override
  String get deviceCollectorsHint =>
      'From what they sent. Someone added on the device who has not sent anything yet is not known here.';

  @override
  String get deviceNoCollectors =>
      'Nobody has sent anything from this device yet.';

  @override
  String deviceCollectorWork(int tests, int sources) {
    String _temp0 = intl.Intl.pluralLogic(
      tests,
      locale: localeName,
      other: '$tests tests',
      one: '1 test',
    );
    String _temp1 = intl.Intl.pluralLogic(
      sources,
      locale: localeName,
      other: '$sources sources',
      one: '1 source',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String get deviceRecoveredHere => 'came back here with a code';

  @override
  String get collectorShowArea => 'Their area on the map';

  @override
  String collectorSources(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sources added',
      one: '1 source added',
      zero: 'Sources added',
    );
    return '$_temp0';
  }

  @override
  String get collectorNoSources => 'No source added by them on record here.';

  @override
  String collectorTests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tests',
      one: '1 test',
      zero: 'Tests',
    );
    return '$_temp0';
  }

  @override
  String get collectorNoTests => 'No test by them in your areas yet.';

  @override
  String testDistance(int metres) {
    return '$metres m from the source';
  }

  @override
  String testAwayReason(String reason) {
    return 'away: $reason';
  }

  @override
  String get placesAssign => 'Who covers it';

  @override
  String placesNewTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places added from devices',
      one: '1 place added from devices',
      zero: 'Added from devices',
    );
    return '$_temp0';
  }

  @override
  String get placesNewHint =>
      'Collectors typed these because they were not in the list. Accept them, fix their names, or look at them on the map.';

  @override
  String get placesNewNone => 'Nothing waiting.';

  @override
  String placesNewBy(String name) {
    return 'added by $name';
  }

  @override
  String get placesAccept => 'Accept into the list';

  @override
  String placesAccepted(String name) {
    return '$name is now in the list.';
  }

  @override
  String paramsFirstAt(String source, String value) {
    return 'First used at $source: $value';
  }

  @override
  String get paramsOpenSource => 'The source and its test';

  @override
  String get paramsOpenCollector => 'The collector';

  @override
  String get chainAddExisting => 'An existing person';

  @override
  String get chainAddStakeholder => 'A new stakeholder';

  @override
  String get chainAddCollector => 'A new collector device (activation code)';

  @override
  String get chainNoCandidates => 'Everyone active already covers this area.';

  @override
  String chainAdded(String name, String area) {
    return '$name now covers $area.';
  }

  @override
  String get ledgerTitle => 'Codes and accounts';

  @override
  String get ledgerMenuHint =>
      'Every activation code and account made, and who and what used them';

  @override
  String get ledgerHint =>
      'Made by whom, for which area, and how each was used. The codes and passwords themselves are never kept.';

  @override
  String ledgerCodes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count activation codes',
      one: '1 activation code',
    );
    return '$_temp0';
  }

  @override
  String ledgerAccounts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count accounts',
      one: '1 account',
    );
    return '$_temp0';
  }

  @override
  String ledgerMadeBy(String name, String when) {
    return 'made by $name, $when';
  }

  @override
  String ledgerWithdrawn(String when) {
    return 'withdrawn $when';
  }

  @override
  String get ledgerExpired => 'expired';

  @override
  String get ledgerUsedUp => 'used up';

  @override
  String get ledgerNoDevices => 'No device has used this code yet.';

  @override
  String get ledgerWithdraw => 'Withdraw this code';

  @override
  String get ledgerNotUsed => 'not used yet (temporary password never changed)';

  @override
  String ledgerLastSignIn(String when) {
    return 'last signed in $when';
  }

  @override
  String get photoOpen => 'Open picture';

  @override
  String get testNotFound =>
      'This test is not on this device yet. Sync, then try again.';

  @override
  String get testUncalibrated => 'tester not calibrated';

  @override
  String get testIsCorrection => 'a correction of an earlier result';

  @override
  String get testReadings => 'Readings';

  @override
  String testDetected(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'true': 'Found',
      'other': 'Not found',
    });
    return '$_temp0';
  }

  @override
  String testAcceptable(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'true': 'Acceptable',
      'other': 'Not acceptable',
    });
    return '$_temp0';
  }

  @override
  String get testContextTitle => 'Where and how it was tested';

  @override
  String get testNoLocation => 'No location recorded';

  @override
  String testAccuracy(int metres) {
    return 'location within $metres m';
  }

  @override
  String testFarReason(String reason) {
    return 'away from the source because: $reason';
  }

  @override
  String testNoPhoto(String reason) {
    return 'No test picture: $reason';
  }

  @override
  String get testNoInspection => 'Surroundings not checked';

  @override
  String testInspection(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count risks found',
      one: '1 risk found',
      zero: 'no risks found',
    );
    return 'Surroundings checked $date: $_temp0';
  }

  @override
  String get testPictures => 'Pictures of the test';

  @override
  String get sourcePictures => 'Pictures of the source';

  @override
  String get testOpen => 'Open this test';

  @override
  String get noPhotoCameraBroken => 'Camera not working';

  @override
  String get noPhotoNotAllowed => 'Pictures not allowed here';

  @override
  String get noPhotoTooDark => 'Too dark to see';

  @override
  String get typedTitle => 'Typed list values';

  @override
  String get typedMenuHint =>
      'Source and collector types typed under \"Other\"; add them to the shared list';

  @override
  String get typedHint =>
      'Collectors type a value when the list has nothing that fits. It is used at once on their device. Add it here to offer it on every device after the next sync; records that already hold it keep it.';

  @override
  String get typedNone => 'Nothing typed under \"Other\" yet.';

  @override
  String typedList(String list) {
    String _temp0 = intl.Intl.selectLogic(list, {
      'source_types': 'Source type',
      'collector_types': 'Collector type',
      'other': 'List',
    });
    return '$_temp0';
  }

  @override
  String typedUses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'used $count times',
      one: 'used once',
    );
    return '$_temp0';
  }

  @override
  String typedFirstSeen(String date) {
    return 'first $date';
  }

  @override
  String get typedAdd => 'Add to the list';

  @override
  String typedAdded(String value) {
    return '\"$value\" is now in the shared list.';
  }

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
  String get messagesHint =>
      'Conversations with collectors about tests, sources, collectors and areas. No SMS or email: everyone reads them in the apps.';

  @override
  String get messagesNone => 'No messages yet.';

  @override
  String get messagesEmpty =>
      'No messages yet. Write to the collectors here; they read it in Collect after their next sync.';

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
  String messagesOpen(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'test': 'Open the test',
      'source': 'Open the source',
      'collector': 'Open the collector',
      'area': 'Open Places',
      'other': 'Open',
    });
    return '$_temp0';
  }

  @override
  String get messagesSectionTitle => 'Messages';
}
