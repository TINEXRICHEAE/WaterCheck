// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FieldQuire Console';

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
      'FieldQuire Console could not open its local data.';

  @override
  String get startupRetry => 'Try again';

  @override
  String get cancel => 'Cancel';

  @override
  String get signInTitle => 'Sign in to FieldQuire Console';

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
  String get alertBySystem => 'FieldQuire';

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
  String get navProfile => 'My profile';

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
    return 'Printed $date from FieldQuire';
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
      'Assignment codes for testers, devices in use, revoking a lost device.';

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
      'Devices register themselves when Collect is opened; testers are assigned to areas with codes. Revoke a lost or stolen device: it stops syncing and locks itself.';

  @override
  String get phonesNone => 'No devices yet.';

  @override
  String get phonesNewCode => 'New assignment code';

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
  String get phonesCodes => 'Recent assignment codes';

  @override
  String get phonesNoCodes => 'No codes yet.';

  @override
  String phonesCodeLine(int used, int max, String until) {
    return '$used of $max uses · valid until $until';
  }

  @override
  String phonesNewCodeFor(String area) {
    return 'Assignment code for $area';
  }

  @override
  String phonesMax(int n) {
    return 'Up to $n testers';
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
      'Shown only now. The tester opens Collect › Settings › Your area and devices › Enter an assignment code, and types or scans it.';

  @override
  String get phonesQrLabel => 'Assignment QR code';

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
  String get accountAbout => 'About FieldQuire';

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
      'Its records come back. The device itself stays revoked.';

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
      'FieldQuire will open on this device without a PIN, and stay open when no one is using it. Sign out when you leave a shared computer.';

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
      'Give this code to the collector (call or text them). In FieldQuire Collect on any phone: \"Who is testing?\" › \"I already have a profile\" › enter the code. They come back as the same person, with their details. The code works once.';

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
  String get chainAddCollector => 'A tester for this area (assignment code)';

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
      'Every assignment code and account made, and who used them';

  @override
  String get ledgerHint =>
      'Made by whom, for which area, and how each was used. The codes and passwords themselves are never kept.';

  @override
  String ledgerCodes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count assignment codes',
      one: '1 assignment code',
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
  String get ledgerNoDevices => 'No tester has used this code yet.';

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
      'research': 'Research record',
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

  @override
  String get testerAreaTitle => 'Area and devices';

  @override
  String get testerNotAssigned =>
      'Not yet assigned to an area. Testers work anywhere without one; an assignment makes them officially responsible for an area.';

  @override
  String get testerAssign => 'Assign to an area';

  @override
  String get testerEnd => 'End';

  @override
  String get testerByCode => 'assigned with a code';

  @override
  String get testerByAdmin => 'assigned by an IT admin';

  @override
  String get testerDevices => 'Devices they use';

  @override
  String get testerNoDevices => 'No device has sent anything for them yet.';

  @override
  String get testerDevice => 'Device';

  @override
  String testerVia(String via) {
    String _temp0 = intl.Intl.selectLogic(via, {
      'created': 'started there',
      'admin_code': 'signed in with an admin\'s code',
      'own_code': 'signed in with their own code',
      'other': 'signed in',
    });
    return '$_temp0';
  }

  @override
  String testerLastUsed(String when) {
    return 'last used $when';
  }

  @override
  String testerSignedOut(String when) {
    return 'signed out $when';
  }

  @override
  String get testerSignIns => 'Sign-ins on other devices';

  @override
  String testerPendingCode(String code) {
    return 'Code to give them: $code';
  }

  @override
  String testerPendingHint(int count, String until) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count devices',
      one: '1 device',
    );
    return 'They asked to sign out $_temp0. Check it is them (by phone), then give them this code. Valid until $until.';
  }

  @override
  String get collectorNotAssigned => 'not yet assigned';

  @override
  String get deviceSelfRegistered => 'registered itself (no area)';

  @override
  String ledgerAssigned(String when) {
    return 'assigned $when';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get navSettings => 'Settings';

  @override
  String get profileSave => 'Save';

  @override
  String get profileEdit => 'Edit';

  @override
  String get profileEditDetails => 'My details';

  @override
  String get profileDetails => 'My details';

  @override
  String get profileFullName => 'Full name';

  @override
  String get profileOrganisation => 'Organisation';

  @override
  String get profilePosition => 'Position';

  @override
  String get profileEmail => 'Email';

  @override
  String get profilePhone => 'Phone';

  @override
  String get profileNone => 'Not given';

  @override
  String get profileAdd => 'Add';

  @override
  String get profileChange => 'Change';

  @override
  String get profileConfirm => 'Confirm';

  @override
  String get profileConfirmed => 'confirmed';

  @override
  String get profileNotConfirmed => 'not confirmed';

  @override
  String get profileChangeEmail => 'New email';

  @override
  String get profileChangePhone => 'New phone number';

  @override
  String get profileContactHint =>
      'It is saved as not confirmed until you enter the code sent to it. Until email and SMS are set up, your IT admin gives you the code. Alerts go only to confirmed contacts.';

  @override
  String get profileConfirmTitle => 'Enter the code';

  @override
  String get profileConfirmHint =>
      'Ask your IT admin for the 6-digit code (Admin › Codes to pass on). It is valid for a day.';

  @override
  String get profileCode => 'Code';

  @override
  String get profileBadEmail => 'That does not look like an email address.';

  @override
  String get profileBadPhone =>
      'Enter a Ugandan phone number, e.g. 0772 123456.';

  @override
  String get profileWrongCode => 'That code is not right.';

  @override
  String get profileCodeExpired =>
      'The code has expired or had too many tries. Change it again for a new one.';

  @override
  String get profileWrongPassword => 'That password is not right.';

  @override
  String get profileLastAdmin =>
      'You are the only IT admin: make another IT admin first.';

  @override
  String get profileAllAreas => 'All areas (IT admin)';

  @override
  String get profileAskAreas => 'Ask for different areas';

  @override
  String get profileAreasWhy => 'Why these areas?';

  @override
  String get profileAreasReason => 'Reason';

  @override
  String get profileAreasHint =>
      'Your areas decide what you see, so an IT admin approves the change.';

  @override
  String profileAreasPending(String areas) {
    return 'Asked for: $areas';
  }

  @override
  String profileAreasPendingSince(String when) {
    return 'Waiting for an IT admin since $when';
  }

  @override
  String profileAreasDeclined(String areas) {
    return 'Your last request ($areas) was declined.';
  }

  @override
  String get profileAccount => 'Account';

  @override
  String get profileSettingsHint =>
      'Appearance, time, alert channels, app lock';

  @override
  String get profileSwitch => 'Sign in as someone else';

  @override
  String get profileSwitchHint => 'Signs you out, then shows the sign-in page.';

  @override
  String get profileRemove => 'Remove this account from this device';

  @override
  String get profileRemoveHint =>
      'Signs out and erases what this device keeps for you (data, saved sign-in, PIN).';

  @override
  String get profileRemoveTitle => 'Remove from this device?';

  @override
  String get profileRemoveBody =>
      'You are signed out and the data kept on this device is erased. Nothing on the server changes; sign in again to get it back.';

  @override
  String get profileClose => 'Close my account';

  @override
  String get profileCloseHint =>
      'For good: sign-in stops and your email and phone are erased. Records you made stay.';

  @override
  String get profileCloseTitle => 'Close your account?';

  @override
  String get profileCloseBody =>
      'You will not be able to sign in again, and your contact details are erased. Alerts, notes and reviews you made stay, under your name, because the water records depend on them. An IT admin can make a new account later.';

  @override
  String get profileCloseContinue => 'Continue';

  @override
  String get profileClosePassword =>
      'Enter your password to close your account.';

  @override
  String get profilePassword => 'Password';

  @override
  String get adminCodes => 'Codes to pass on';

  @override
  String get adminCodesHint =>
      'Confirmation codes people are waiting for (contacts, signing devices out)';

  @override
  String get codesTitle => 'Codes to pass on';

  @override
  String get codesHint =>
      'Until email and SMS are set up, people confirm a new email or phone, or signing other devices out, with a code an IT admin gives them. Check it is them (call them on a number you know), then read out the code. Codes last a day.';

  @override
  String get codesNone => 'No one is waiting for a code.';

  @override
  String codesFor(String who, String detail) {
    return '$who: $detail';
  }

  @override
  String codesUntil(String when) {
    return 'valid until $when';
  }

  @override
  String get areaRequestsTitle => 'Area change requests';

  @override
  String areaRequestLine(String name, String areas, String current) {
    return '$name asks for $areas (now: $current)';
  }

  @override
  String get areaRequestApprove => 'Approve';

  @override
  String get areaRequestDecline => 'Decline';

  @override
  String get mapPlaceRename => 'Rename';

  @override
  String get mapPlaceRenameTitle => 'Rename this place';

  @override
  String get mapPlaceRemove => 'Remove';

  @override
  String mapPlaceRemoveTitle(String name) {
    return 'Remove $name for everyone?';
  }

  @override
  String mapPlaceRemoved(String name) {
    return '$name removed';
  }

  @override
  String get mapPlaceNotChanged =>
      'Not changed: the server could not be reached. Try again.';

  @override
  String get mapLocationHelp =>
      'Your location is not available. Allow location for this site (the icon in the address bar, or the site settings) and switch location on for the device. On iPhone: Settings › Privacy & Security › Location Services › Safari Websites › While Using the App. A laptop without GPS may show an approximate place.';

  @override
  String get modeWater => 'Water testing';

  @override
  String get modeResearch => 'Research';

  @override
  String get researchProjects => 'Research projects';

  @override
  String get researchNoProjects =>
      'No research projects yet. Projects you own or help supervise appear here.';

  @override
  String researchFormsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count forms',
      one: '1 form',
    );
    return '$_temp0';
  }

  @override
  String researchRecordsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records',
      one: '1 record',
      zero: 'no records',
    );
    return '$_temp0';
  }

  @override
  String get researchFormsTitle => 'Forms';

  @override
  String researchPointsTitle(int count) {
    return 'Where records were made ($count)';
  }

  @override
  String get researchPublished => 'Published';

  @override
  String get researchClosed => 'Closed';

  @override
  String get researchDraft => 'Draft';

  @override
  String get researchAccessOpen => 'Any collector';

  @override
  String get researchAccessCode => 'With a code';

  @override
  String get researchAccessAssigned => 'Assigned collectors';

  @override
  String get researchHidden => 'Hidden';

  @override
  String get researchPublic => 'Public';

  @override
  String get researchShared => 'Shared';

  @override
  String get researchPrivate => 'Private';

  @override
  String get researchRecords => 'Records';

  @override
  String get researchSearchNumber => 'Search by research number';

  @override
  String get researchNoLocation => 'No location';

  @override
  String get researchDeclinedShort => 'Declined';

  @override
  String get researchClash => 'Number used twice: check with the collector';

  @override
  String get researchMore => 'Show more';

  @override
  String researchRecordTitle(String number) {
    return 'Record $number';
  }

  @override
  String researchMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String researchPointAt(String point, String metres) {
    return 'Location: $point (±$metres m)';
  }

  @override
  String get researchErrCodeTaken =>
      'That code is already used. Choose another.';

  @override
  String get researchErrNoUser => 'No active account signs in with that email.';

  @override
  String get researchErrNothingToPublish => 'There are no changes to publish.';

  @override
  String get researchErrNoFields =>
      'Add at least one question before publishing.';

  @override
  String get researchErrAnalyst =>
      'Analysts can read and analyse, not change the project.';

  @override
  String get researchErrOwnerOnly => 'Only the project\'s owner can do this.';

  @override
  String get researchErrNothingToClone => 'This form has nothing to copy yet.';

  @override
  String get researchErrInvalid =>
      'The form could not be read. Check it and try again.';

  @override
  String get researchErrOffline => 'No connection. Try again when online.';

  @override
  String researchErrOther(String code) {
    return 'Something went wrong ($code). Try again.';
  }

  @override
  String get researchAppTitle => 'Research';

  @override
  String get researchProject => 'Project';

  @override
  String get researchNoProjectYet => 'No project yet';

  @override
  String get researchNewProject => 'New project';

  @override
  String get researchTitle => 'Title';

  @override
  String get researchDescription => 'Description';

  @override
  String get researchRequired => 'Required';

  @override
  String get researchProjectCode => 'Project code';

  @override
  String get researchProjectCodeHint =>
      '2 to 8 letters or digits, e.g. ENT. It starts every research number (ENT-HQ-…) and cannot be changed later.';

  @override
  String get researchProjectCodeRule => 'Use 2 to 8 letters or digits';

  @override
  String get researchCreate => 'Create';

  @override
  String get researchDashboardHint =>
      'Your research project at a glance: records, forms, collectors and where records were made.';

  @override
  String researchOwnerRole(String owner, String role) {
    return 'Owner: $owner · You: $role';
  }

  @override
  String researchTeam(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Team ($count)',
      one: 'Team (1)',
    );
    return '$_temp0';
  }

  @override
  String get researchKpiRecords => 'Records';

  @override
  String researchKpiToday(int count) {
    return '$count made today';
  }

  @override
  String get researchKpiForms => 'Published forms';

  @override
  String researchKpiFormsHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count forms in all',
      one: '1 form in all',
    );
    return '$_temp0';
  }

  @override
  String get researchKpiCollectors => 'Collectors';

  @override
  String researchKpiCollectorsHint(int count) {
    return '$count with records';
  }

  @override
  String get researchKpiMessages => 'Awaiting an answer';

  @override
  String get researchKpiMessagesHint => 'Messages from collectors';

  @override
  String get researchPointsHint =>
      'Research numbers only, never names. Tap a point to open its record.';

  @override
  String get researchOpenMap => 'Open the map';

  @override
  String get researchLatestRecords => 'Latest records';

  @override
  String get researchSeeAllRecords => 'All records';

  @override
  String get researchNoRecordsYet => 'No records yet.';

  @override
  String get researchNoCollectorsYet =>
      'No collectors yet. Give a form to collectors, or share its access code.';

  @override
  String researchLastAt(String when) {
    return 'last $when';
  }

  @override
  String get researchRoleOwner => 'Owner';

  @override
  String get researchRoleSupervisor => 'Supervisor';

  @override
  String get researchRoleAnalyst => 'Analyst';

  @override
  String get researchRoleSupervisorHint =>
      'Builds and publishes forms, manages collectors, sees all records.';

  @override
  String get researchRoleAnalystHint =>
      'Sees all records and analysis; changes nothing.';

  @override
  String get researchWelcomeTitle => 'Start your research';

  @override
  String get researchWelcomeBody =>
      'Create a project, then build its forms here in the Console (or import an XLSForm, or copy one from the library). Publish a form and give it to collectors: they fill it in Collect, offline, and every record keeps where and when it was made.';

  @override
  String get researchLibrary => 'Form library';

  @override
  String get researchTeamTitle => 'Project and team';

  @override
  String get researchTeamHint =>
      'Supervisors build forms and manage collectors; analysts read and analyse. People are added by the email they sign in with.';

  @override
  String get researchEditProject => 'Edit the project';

  @override
  String get researchRemove => 'Remove';

  @override
  String get researchRemoveMemberTitle => 'Remove from the project?';

  @override
  String researchRemoveMemberBody(String name) {
    return '$name will no longer see the project or its records.';
  }

  @override
  String get researchAddMember => 'Add a person';

  @override
  String get researchMemberEmail => 'Their sign-in email';

  @override
  String get researchMemberEmailHint =>
      'They need a Console account. An IT admin can make one.';

  @override
  String get researchAdd => 'Add';

  @override
  String get researchSave => 'Save';

  @override
  String get researchSaved => 'Saved';

  @override
  String get researchAllForms => 'All forms';

  @override
  String get researchAllCollectors => 'All collectors';

  @override
  String get researchCollectedBy => 'Collected by';

  @override
  String researchTook(String duration) {
    return 'took $duration';
  }

  @override
  String get researchStarted => 'started';

  @override
  String researchFinishedAt(String point) {
    return 'Finished at $point';
  }

  @override
  String get researchAnswers => 'Answers';

  @override
  String get researchMessagesHint =>
      'Talk with the collector about this record. They see it in Collect with their next sync.';

  @override
  String get researchMessagesListHint =>
      'Conversations with collectors about records in this project.';

  @override
  String get researchNeedsAnswer => 'needs an answer';

  @override
  String researchAwaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records await an answer',
      one: '1 record awaits an answer',
    );
    return '$_temp0';
  }

  @override
  String get researchFormsHint =>
      'Build forms here, publish them, and choose who collects with them and who may copy them.';

  @override
  String get researchNewForm => 'New form';

  @override
  String get researchImportXlsForm => 'Import XLSForm';

  @override
  String get researchNoForms =>
      'No forms yet. Start a new form, import an XLSForm, or copy one from the library.';

  @override
  String researchVersion(int number) {
    return 'version $number';
  }

  @override
  String get researchUnpublishedChanges => 'unpublished changes';

  @override
  String researchImportFailed(String reason) {
    return 'That file could not be read as an XLSForm: $reason';
  }

  @override
  String researchImportWarnings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rows could not be imported',
      one: '1 row could not be imported',
    );
    return '$_temp0';
  }

  @override
  String get researchImportAnyway => 'Import the rest';

  @override
  String get researchFormCode => 'Form code';

  @override
  String get researchFormCodeHint =>
      '1 to 6 letters or digits, e.g. HQ. It is part of the research numbers (ENT-HQ-…).';

  @override
  String get researchFormCodeRule => 'Use 1 to 6 letters or digits';

  @override
  String get researchLibraryHint =>
      'Forms other researchers made public or shared with you. Open one to see it, then copy it into your project as a draft.';

  @override
  String get researchLibraryEmpty => 'No forms are shared with you yet.';

  @override
  String researchFixFirst(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Fix $count problems first (listed above the questions).',
      one: 'Fix 1 problem first (listed above the questions).',
    );
    return '$_temp0';
  }

  @override
  String get researchPublishTitle => 'Publish the form?';

  @override
  String get researchPublishFirstBody =>
      'Collectors who may use it get it with their next sync.';

  @override
  String researchPublishBody(int number) {
    return 'This becomes version $number. Collectors get it with their next sync; records already made keep the version they were filled with.';
  }

  @override
  String get researchPublish => 'Publish';

  @override
  String get researchPublishedNow =>
      'Published. Collectors get it with their next sync.';

  @override
  String get researchDiscardTitle => 'Discard the changes?';

  @override
  String get researchDiscardBody =>
      'The form goes back to its published version.';

  @override
  String get researchDiscard => 'Discard changes';

  @override
  String get researchCopyForm => 'Copy to my project';

  @override
  String get researchExportXlsForm => 'Download XLSForm';

  @override
  String get researchSeeRecords => 'See its records';

  @override
  String get researchDraftNote =>
      'Changes are saved as a draft. Collectors keep the published version until you publish again.';

  @override
  String get researchTabQuestions => 'Questions';

  @override
  String get researchTabAccess => 'Access and sharing';

  @override
  String get researchTabVersions => 'Versions';

  @override
  String get researchTabPreview => 'Try it';

  @override
  String get researchNeedProject => 'Create a project first.';

  @override
  String get researchWhoCollects => 'Who may collect with this form';

  @override
  String get researchAccessAssignedHint =>
      'Only collectors you give the form to (Collectors).';

  @override
  String get researchAccessCodeHint =>
      'Collectors who type the form\'s access code in Collect, and those you give it to. Every research collector sees it with a lock.';

  @override
  String get researchAccessOpenHint =>
      'Any research collector on Collect, unless the form is hidden.';

  @override
  String get researchCodeHint =>
      'Collectors type this code in Collect › Research to join.';

  @override
  String get researchCopyCode => 'Copy the code';

  @override
  String get researchNewCode => 'New code';

  @override
  String get researchNewCodeBody =>
      'The old code stops working. Collectors who already joined keep the form.';

  @override
  String researchFormCollectors(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count collectors',
      one: '1 collector',
      zero: 'No collectors yet',
    );
    return '$_temp0';
  }

  @override
  String get researchAssign => 'Give the form';

  @override
  String get researchJoinedWithCode => 'joined with the code';

  @override
  String get researchAssignedByTeam => 'given by the team';

  @override
  String get researchHiddenTitle => 'Hidden';

  @override
  String get researchHiddenHint =>
      'Not listed for browsing or the library. Collectors you gave it to still get it.';

  @override
  String get researchOpenForCollection => 'Open for collection';

  @override
  String get researchOpenForCollectionHint =>
      'Off: collectors can no longer send new records (those made stay).';

  @override
  String get researchWhoSees => 'Who may see and copy this form';

  @override
  String get researchPrivateHint => 'Only this project\'s team.';

  @override
  String get researchSharedHint => 'The team, and the people you name below.';

  @override
  String get researchPublicHint =>
      'Any researcher on FieldQuire (never the records).';

  @override
  String get researchShareWith => 'Share with a person';

  @override
  String researchAssignTitle(String code) {
    return 'Give $code to collectors';
  }

  @override
  String get researchFindTester => 'Find a collector';

  @override
  String get researchFindTesterHint =>
      'By the collector code they give you (on their Collect profile), or by name or phone if they let research teams find them.';

  @override
  String get researchDone => 'Done';

  @override
  String get researchVersionsHint =>
      'Each publish makes a new version. Records keep the version they were filled with.';

  @override
  String get researchNotPublished => 'Not published yet.';

  @override
  String researchPublishedOn(String when) {
    return 'published $when';
  }

  @override
  String get researchCurrent => 'Current';

  @override
  String get researchPreviewBroken =>
      'The form has a problem; see the list above the questions.';

  @override
  String get researchPreviewHint =>
      'Fill the form as a collector would, to try skip logic and checks. Nothing is saved.';

  @override
  String get researchPreviewCheck => 'Check the answers';

  @override
  String get researchPreviewReset => 'Start again';

  @override
  String get researchPreviewOk =>
      'All answers are accepted. This is what would be saved:';

  @override
  String researchPreviewIssues(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count answers need attention',
      one: '1 answer needs attention',
    );
    return '$_temp0';
  }

  @override
  String get researchCollectorsHint =>
      'Collectors working on this project, the forms each has, and their records.';

  @override
  String get researchGiveForm => 'Give a form to collectors';

  @override
  String get researchHowCollectorsJoin => 'How collectors get each form';

  @override
  String get researchJoinHint =>
      'Open a form to change who may collect, see its access code, or give it to collectors.';

  @override
  String researchCollectorsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count collectors',
      one: '1 collector',
    );
    return '$_temp0';
  }

  @override
  String get researchByCode => 'by code';

  @override
  String get researchAnalysis => 'Analysis';

  @override
  String get researchAnalysisHint =>
      'Summaries, cross-tabs, indicators against targets, the visit audit and exports, from the records of one form.';

  @override
  String get researchForm => 'Form';

  @override
  String get researchTabSummary => 'Summary';

  @override
  String get researchTabCrossTab => 'Cross-tab';

  @override
  String get researchTabIndicators => 'Indicators';

  @override
  String get researchTabAudit => 'Visit audit';

  @override
  String get researchTabExport => 'Export';

  @override
  String researchSummaryLine(int count, int declined) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records',
      one: '1 record',
    );
    return '$_temp0 · $declined declined';
  }

  @override
  String researchAnswered(int answered, int asked) {
    return '$answered of $asked answered';
  }

  @override
  String get researchStatMean => 'Mean';

  @override
  String get researchStatMedian => 'Median';

  @override
  String get researchStatMin => 'Lowest';

  @override
  String get researchStatMax => 'Highest';

  @override
  String get researchStatTotal => 'Total';

  @override
  String researchDateRange(String first, String last) {
    return 'From $first to $last';
  }

  @override
  String get researchNoAnswers => 'No answers yet.';

  @override
  String get researchMultiNote =>
      'Several answers per record are possible, so shares add up to more than 100%.';

  @override
  String get researchCrossTabNeeds =>
      'A cross-tab needs two choice questions in the form.';

  @override
  String get researchRows => 'Rows';

  @override
  String get researchColumns => 'Columns';

  @override
  String get researchRowPercent => 'Row percentages';

  @override
  String get researchTotal => 'Total';

  @override
  String get researchCrossTabNote =>
      'Declined records are left out. A choose-many answer counts once for each choice.';

  @override
  String get researchIndicatorsHint =>
      'Indicators are kept with the project: the share of records where a condition holds, against its target (as in the proposal\'s indicator table).';

  @override
  String get researchNoIndicators => 'No indicators for this form yet.';

  @override
  String get researchIndicator => 'Indicator';

  @override
  String get researchResult => 'Result';

  @override
  String get researchTarget => 'Target';

  @override
  String get researchStatus => 'Status';

  @override
  String get researchIndicatorBroken => 'Check the expression';

  @override
  String get researchMet => 'Met';

  @override
  String get researchNotMet => 'Not met';

  @override
  String get researchNoTarget => 'No target';

  @override
  String get researchAddIndicator => 'Add an indicator';

  @override
  String get researchIndicatorLabel => 'What it measures';

  @override
  String get researchNumerator => 'Counts records where';

  @override
  String researchNumeratorHint(String example) {
    return 'An expression, e.g. $example';
  }

  @override
  String get researchDenominator => 'Out of records where (optional)';

  @override
  String get researchDenominatorHint =>
      'Leave empty for all records that were not declined.';

  @override
  String get researchTargetPercent => 'Target (%)';

  @override
  String get researchAuditHint =>
      'Where and when each record was made, and how long it took, per collector. Flags are prompts to talk with collectors, not verdicts.';

  @override
  String get auditTooFast => 'very quick';

  @override
  String get auditFar => 'far from the others';

  @override
  String get auditSamePoint => 'several at one spot';

  @override
  String get auditNoLocation => 'no location';

  @override
  String get auditMoved => 'finished elsewhere';

  @override
  String auditFlagged(int count) {
    return '$count flagged';
  }

  @override
  String auditUsual(String duration) {
    return 'usually $duration';
  }

  @override
  String auditKm(String km) {
    return '$km km from the centre';
  }

  @override
  String get auditNote =>
      'Very quick: under a third of the form\'s usual time (at least 2 minutes). Far: over 5 km from the middle of all records. Several at one spot: 3 or more within 15 m by the same collector.';

  @override
  String researchExportHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records',
      one: '1 record',
    );
    return '$_temp0. Repeats come as their own sheets, linked by research number.';
  }

  @override
  String get researchExportLabels => 'Choice labels';

  @override
  String get researchExportLabelsHint =>
      '\"Boiling\" rather than the code \"boiling\".';

  @override
  String get researchExportIdentifying => 'Include identifying answers';

  @override
  String get researchExportIdentifyingHint =>
      'Names, phone numbers and other fields marked identifying. Off by default: research numbers stand for participants.';

  @override
  String get researchExportExcel => 'Excel';

  @override
  String get researchExportCsv => 'CSV';

  @override
  String get researchExportGeoJson => 'GeoJSON (map)';

  @override
  String researchExportMedia(int count) {
    return 'Pictures ($count)';
  }

  @override
  String researchMediaProgress(int done, int total) {
    return 'Getting pictures: record $done of $total';
  }

  @override
  String get researchAdminHint =>
      'IT admins see every research project. Research has its own people, phones, codes and security pages.';

  @override
  String get researchAdminPeople => 'People and accounts';

  @override
  String get researchAdminPhones => 'Phones';

  @override
  String get researchAdminSecurity => 'Security';

  @override
  String get researchAdminSystem => 'System';

  @override
  String get researchAdminAll => 'All administration';

  @override
  String researchAllProjects(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count research projects',
      one: '1 research project',
    );
    return '$_temp0';
  }

  @override
  String get fieldNote => 'Note';

  @override
  String get fieldText => 'Text';

  @override
  String get fieldInteger => 'Whole number';

  @override
  String get fieldDecimal => 'Decimal number';

  @override
  String get fieldYesNo => 'Yes / no';

  @override
  String get fieldSelectOne => 'Choose one';

  @override
  String get fieldSelectMany => 'Choose many';

  @override
  String get fieldLikert => 'Scale (Likert)';

  @override
  String get fieldRange => 'Range';

  @override
  String get fieldDate => 'Date';

  @override
  String get fieldTime => 'Time';

  @override
  String get fieldDateTime => 'Date and time';

  @override
  String get fieldGeopoint => 'GPS point';

  @override
  String get fieldPhoto => 'Photo';

  @override
  String get fieldAudio => 'Audio';

  @override
  String get fieldVideo => 'Video';

  @override
  String get fieldBarcode => 'Barcode / QR';

  @override
  String get fieldCalculate => 'Calculation';

  @override
  String get fieldConsent => 'Consent';

  @override
  String get fieldGroup => 'Section';

  @override
  String get fieldRepeat => 'Repeat (rows)';

  @override
  String get builderPickType => 'What kind of question?';

  @override
  String builderOption(int number) {
    return 'Option $number';
  }

  @override
  String get builderSettings => 'Form settings';

  @override
  String get builderNumbering => 'Research numbers';

  @override
  String get builderNumberingGenerated => 'Made by the phone';

  @override
  String get builderNumberingTyped => 'Typed from a list';

  @override
  String get builderNumberingGeneratedHint =>
      'Each phone makes unique numbers without a connection: project, form, phone and a count, e.g. ENT-HQ-7Q2K-0007.';

  @override
  String get builderNumberingTypedHint =>
      'Collectors type the number from the team\'s list (e.g. the sampling list). A number used twice is kept and flagged.';

  @override
  String get builderNumberLabel =>
      'What the team calls the number (e.g. Household code)';

  @override
  String builderProblems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count problems to fix before publishing',
      one: '1 problem to fix before publishing',
    );
    return '$_temp0';
  }

  @override
  String builderQuestions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions',
      one: '1 question',
    );
    return '$_temp0';
  }

  @override
  String get builderAddQuestion => 'Add a question';

  @override
  String get builderEmpty =>
      'No questions yet. Add the first one; consent usually comes first.';

  @override
  String get builderBadgeRequired => 'required';

  @override
  String get builderBadgeLogic => 'skip logic';

  @override
  String get builderBadgeCheck => 'check';

  @override
  String get builderBadgeIdentifying => 'identifying';

  @override
  String builderBadgeChoices(int count) {
    return '$count choices';
  }

  @override
  String get builderNoLabel => '(no wording yet)';

  @override
  String get builderMore => 'More';

  @override
  String get builderMoveUp => 'Move up';

  @override
  String get builderMoveDown => 'Move down';

  @override
  String get builderDuplicate => 'Duplicate';

  @override
  String get builderDelete => 'Delete';

  @override
  String get builderAddInRepeat => 'Add a question to each row';

  @override
  String get builderAddInGroup => 'Add a question to this section';

  @override
  String get builderNameRule =>
      'Letters, digits and _ only, not starting with a digit';

  @override
  String get builderNameUsed => 'Another question has this name';

  @override
  String builderUnknownField(String name) {
    return 'No question is named \"$name\"';
  }

  @override
  String get builderNeedChoices => 'Add at least one choice';

  @override
  String get builderNeedCalculation => 'Write the calculation';

  @override
  String get builderNewQuestion => 'New question';

  @override
  String get builderEditQuestion => 'Edit';

  @override
  String get builderType => 'Kind';

  @override
  String get builderLabel => 'Question (as asked)';

  @override
  String get builderName => 'Name';

  @override
  String builderNameHint(String example) {
    return 'The column name in exports; used in skip logic as $example.';
  }

  @override
  String get builderHint => 'Hint (shown under the question)';

  @override
  String get builderRequired => 'An answer is required';

  @override
  String get builderIdentifying => 'Identifying';

  @override
  String get builderIdentifyingHint =>
      'A name, phone number…: left off maps and out of default exports.';

  @override
  String get builderChoices => 'Choices';

  @override
  String get builderLikertDefault =>
      'Without choices of its own the scale is Agree / Not sure / Disagree.';

  @override
  String get builderOther => 'Add \"Other: specify\"';

  @override
  String get builderOtherHint =>
      'The collector types what the other answer is.';

  @override
  String get builderMinRows => 'Fewest rows';

  @override
  String get builderMaxRows => 'Most rows';

  @override
  String get builderMin => 'Lowest accepted';

  @override
  String get builderMax => 'Highest accepted';

  @override
  String get builderMaxSeconds => 'Longest recording (seconds)';

  @override
  String get builderMaxAudio => 'At most 300 (5 minutes).';

  @override
  String get builderMaxVideo => 'At most 60 seconds, at 480p.';

  @override
  String get builderLogic => 'Logic';

  @override
  String builderLogicHint(String example) {
    return 'Expressions as in XLSForm, e.g. $example. A dot (.) is this answer.';
  }

  @override
  String get builderRelevant => 'Ask only when (skip logic)';

  @override
  String builderRelevantHint(String example) {
    return 'e.g. $example';
  }

  @override
  String get builderConstraint => 'Accept only when (check)';

  @override
  String get builderConstraintHint => 'e.g. . >= 0 and . <= 20';

  @override
  String get builderConstraintMessage => 'Message when not accepted';

  @override
  String get builderDefault => 'Default answer';

  @override
  String get builderCalculation => 'Calculation';

  @override
  String builderCalculationHint(String example) {
    return 'e.g. $example';
  }

  @override
  String builderChoiceLabel(int number) {
    return 'Choice $number';
  }

  @override
  String get builderChoiceValue => 'Code';

  @override
  String get builderAddChoice => 'Add a choice';

  @override
  String get builderDone => 'Done';

  @override
  String get joinAlready => 'This account is already on that side.';

  @override
  String joinGo(String side) {
    return 'Join $side';
  }

  @override
  String joinHow(String email, String side) {
    return 'A separate $side account is made for $email, with the same password. It is linked to this one, so you can switch between them; each keeps its own pages, records and settings.';
  }

  @override
  String joinMenu(String side) {
    return 'Join $side';
  }

  @override
  String get joinPassword => 'Your password (to confirm it is you)';

  @override
  String get joinResearchIntro =>
      'Research is where projects are planned, forms are built and published, and records from collectors are analysed and reported on.';

  @override
  String joinTitle(String side) {
    return 'Join $side';
  }

  @override
  String get joinWaterIntro =>
      'Water testing is where water sources and test results are followed up, alerts are handled and reports are made.';

  @override
  String legalTitleSide(String side) {
    return '$side: Terms of Use and Privacy Policy';
  }

  @override
  String get profileAdminAllSides =>
      'As an IT admin you work on every side, and switch between them.';

  @override
  String get profileLinked => 'You have an account there too.';

  @override
  String get profileNotJoined =>
      'Not joined. Joining makes a separate, linked account.';

  @override
  String get profileSideHint =>
      'This account belongs to this side only; other sides have their own accounts.';

  @override
  String get profileSides => 'Sides of FieldQuire';

  @override
  String profileThisSide(String side) {
    return 'This account: $side';
  }

  @override
  String get recoveryGive => 'Give a recovery code';

  @override
  String get researchCollectorAccess => 'Getting back in';

  @override
  String get researchCollectorAccessHint =>
      'A collector who lost their phone, or uses another one, gets back in as the same person with a one-time recovery code. Pass it on in person or by phone.';

  @override
  String get researchCollectorLastSeen => 'Last seen';

  @override
  String get researchCollectorNoForms => 'No forms of your projects yet.';

  @override
  String get researchCollectorRole => 'Research collector';

  @override
  String get researchFindCollector => 'Find a collector';

  @override
  String roleOnSide(String side) {
    return '$side account';
  }

  @override
  String get signUpEmail => 'Enter a valid email address.';

  @override
  String get signUpEmailHint => 'You sign in with it.';

  @override
  String get signUpEmailLabel => 'Email';

  @override
  String get signUpFullName => 'Full name';

  @override
  String get signUpGo => 'Create the account';

  @override
  String get signUpHaveAccount => 'I already have an account';

  @override
  String get signUpLink => 'Create an account';

  @override
  String get signUpName => 'Enter your name.';

  @override
  String get signUpOrganisation => 'Organisation (optional)';

  @override
  String get signUpResearchIntro =>
      'For researchers and their teams: start projects, build forms, give them to collectors, and analyse the records. The account works at once.';

  @override
  String get signUpTaken =>
      'An account on this side already uses that email. Sign in instead.';

  @override
  String get signUpTick =>
      'Tick both boxes to accept the Terms of Use and the Privacy Policy.';

  @override
  String signUpTitle(String side) {
    return 'Create a $side account';
  }

  @override
  String get signUpWaterIntro =>
      'For district officers and other stakeholders: follow water sources and test results, act on alerts and make reports. The account works at once; an IT admin may add the areas you are officially responsible for.';

  @override
  String switchBody(String side) {
    return 'You will use your $side account, with its own pages, records and settings.';
  }

  @override
  String get switchGo => 'Switch';

  @override
  String switchTo(String side) {
    return 'Switch to $side';
  }

  @override
  String get usersWaterHint =>
      'Water testing accounts and the IT admins. Research accounts are managed on the research side.';

  @override
  String get usersResearchHint =>
      'Research accounts and the IT admins. Water testing accounts are managed on the water side.';

  @override
  String get testerAccessTitle => 'Devices, sign-ins and codes';

  @override
  String get acceptancesTitle => 'Terms of Use and Privacy Policy accepted';

  @override
  String get acceptancesNone => 'No acceptance recorded yet.';

  @override
  String acceptancesLine(String side, int version) {
    return '$side, version $version';
  }

  @override
  String acceptancesHow(String how) {
    String _temp0 = intl.Intl.selectLogic(how, {
      'signup': 'when signing up',
      'join': 'when joining from the other side',
      'prompt': 'when asked after a change',
      'profile': 'on a phone',
      'other': '$how',
    });
    return '$_temp0';
  }

  @override
  String get researchAdminLedger => 'Accounts, sign-ins and codes';

  @override
  String switchIntro(String side) {
    return '$side is a separate side of FieldQuire, with its own people, pages and records. Choose how to go there.';
  }

  @override
  String switchSignIn(String side) {
    return 'I have a $side account';
  }

  @override
  String switchSignInHint(String side) {
    return 'Sign in with its email and password. You leave this account first.';
  }

  @override
  String switchJoin(String side) {
    return 'Use my details here to join $side';
  }

  @override
  String switchJoinHint(String side) {
    return 'A separate $side account with your email and password, linked to this one, after you accept its Terms of Use and Privacy Policy.';
  }

  @override
  String switchNew(String side) {
    return 'Create a new $side account';
  }

  @override
  String switchNewHint(String side) {
    return 'With other details. You leave this account first.';
  }

  @override
  String get searchPhones => 'Search phones by name, area, code or app';

  @override
  String get searchLedger => 'Search codes and accounts';

  @override
  String get searchCollectors => 'Search collectors';

  @override
  String get searchAlerts => 'Search alerts by source or status';

  @override
  String get searchArchived => 'Search archived items';

  @override
  String get searchCodes => 'Search by person, code or reason';

  @override
  String get searchMessages => 'Search messages';

  @override
  String get searchProjects => 'Search projects';

  @override
  String get searchForms => 'Search forms by code, title or status';

  @override
  String get researchAllPublished => 'Published';

  @override
  String researchExportCsvOf(String table) {
    return 'CSV: $table';
  }

  @override
  String get researchTabCharts => 'Charts';

  @override
  String get researchChartsHint =>
      'Put the answers together: group the records by an answer, the day they were finished or the collector; count them or add up, average or compare a number; split each group by a second answer.';

  @override
  String get researchChartGroupBy => 'Group by';

  @override
  String get researchChartByFinished => 'Day finished';

  @override
  String get researchChartByCollector => 'Collector';

  @override
  String get researchChartStep => 'Dates by';

  @override
  String get researchChartDay => 'Day';

  @override
  String get researchChartWeek => 'Week';

  @override
  String get researchChartMonth => 'Month';

  @override
  String get researchChartSplit => 'Split by';

  @override
  String get researchChartNoSplit => 'No split';

  @override
  String get researchChartMeasure => 'Show';

  @override
  String get researchChartCount => 'Number of records';

  @override
  String get researchChartSum => 'Total';

  @override
  String get researchChartMean => 'Average';

  @override
  String get researchChartMin => 'Lowest';

  @override
  String get researchChartMax => 'Highest';

  @override
  String get researchChartOf => 'Of';

  @override
  String get researchChartBars => 'Bars';

  @override
  String get researchChartHorizontal => 'Horizontal bars';

  @override
  String get researchChartGrouped => 'Grouped bars';

  @override
  String get researchChartStacked => 'Stacked bars';

  @override
  String get researchChartLine => 'Line';

  @override
  String get researchChartArea => 'Area';

  @override
  String get researchChartPie => 'Pie';

  @override
  String get researchChartDonut => 'Donut';

  @override
  String get researchChartOther => 'Other';

  @override
  String get researchChartNone => '(no answer)';

  @override
  String get researchChartGroup => 'Group';

  @override
  String get researchChartNothing => 'No records to chart yet.';

  @override
  String researchChartUnits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'From $count records or repeat rows',
      one: 'From 1 record or repeat row',
    );
    return '$_temp0';
  }

  @override
  String get researchOpenMyCopy => 'Open my copy';

  @override
  String get researchEditorsTitle => 'Editors';

  @override
  String get researchEditorsHint =>
      'People outside this project who may change the questions and publish new versions. Each version shows who published it. Only this project\'s team changes access and sharing.';

  @override
  String get researchAddEditor => 'Add an editor';

  @override
  String get researchEmailOrUsername => 'Their email or username';

  @override
  String researchPublishedBy(String name) {
    return 'by $name';
  }

  @override
  String get phonesHintResearch =>
      'Devices register themselves when Collect is opened. Each row shows the research collectors who used it and their records. Revoke a lost or stolen device.';

  @override
  String phonesActivityResearch(int collectors, int records) {
    String _temp0 = intl.Intl.pluralLogic(
      collectors,
      locale: localeName,
      other: '$collectors collectors',
      one: '1 collector',
    );
    String _temp1 = intl.Intl.pluralLogic(
      records,
      locale: localeName,
      other: '$records records',
      one: '1 record',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String get deviceCollectorsResearch => 'Collectors on this device';

  @override
  String deviceCollectorRecords(int records) {
    String _temp0 = intl.Intl.pluralLogic(
      records,
      locale: localeName,
      other: '$records records',
      one: '1 record',
    );
    return '$_temp0';
  }

  @override
  String get researchOpenRecord => 'Open the record';
}
