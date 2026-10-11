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
      'PDF reports stating the limits used, CSV export and community notices.';

  @override
  String get adminReferenceData => 'Reference data';

  @override
  String get adminReferenceDataHint =>
      'Parameters, limits, tester profiles and areas loaded on this device';

  @override
  String get adminMoreHint =>
      'Users, installations, configuration, security, system health and audit arrive in P11.';

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
  String get recentHint => 'Synced from Collect phones in your areas.';

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
    return 'A phone set the working status to \"$phone\", but it is now \"$current\" from a newer change. Which is right?';
  }

  @override
  String get conflictKeep => 'Keep current';

  @override
  String get conflictUsePhone => 'Use the phone\'s value';

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
}
