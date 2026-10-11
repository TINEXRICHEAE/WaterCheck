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
  /// **'WaterCheck Console'**
  String get appTitle;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navSources.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get navSources;

  /// No description provided for @navAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get navAlerts;

  /// No description provided for @navCollectors.
  ///
  /// In en, this message translates to:
  /// **'Collectors'**
  String get navCollectors;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get navAdmin;

  /// No description provided for @comingIn.
  ///
  /// In en, this message translates to:
  /// **'Arrives in {phase}'**
  String comingIn(String phase);

  /// No description provided for @dashboardHint.
  ///
  /// In en, this message translates to:
  /// **'Sources tested, % unsafe, open alerts, overdue sources and collector activity for your area.'**
  String get dashboardHint;

  /// No description provided for @sourcesHint.
  ///
  /// In en, this message translates to:
  /// **'All sources in your area with status, last test and history.'**
  String get sourcesHint;

  /// No description provided for @alertsHint.
  ///
  /// In en, this message translates to:
  /// **'Open alerts by age and severity: acknowledge, record action, close.'**
  String get alertsHint;

  /// No description provided for @collectorsHint.
  ///
  /// In en, this message translates to:
  /// **'Who submitted what, built from submissions. Mark collectors known or flag a submission.'**
  String get collectorsHint;

  /// No description provided for @reportsHint.
  ///
  /// In en, this message translates to:
  /// **'PDF reports stating the limits used, CSV export and community notices.'**
  String get reportsHint;

  /// No description provided for @adminReferenceData.
  ///
  /// In en, this message translates to:
  /// **'Reference data'**
  String get adminReferenceData;

  /// No description provided for @adminReferenceDataHint.
  ///
  /// In en, this message translates to:
  /// **'Parameters, limits, tester profiles and areas loaded on this device'**
  String get adminReferenceDataHint;

  /// No description provided for @adminMoreHint.
  ///
  /// In en, this message translates to:
  /// **'Users, installations, configuration, security, system health and audit arrive in P11.'**
  String get adminMoreHint;

  /// No description provided for @startupFailed.
  ///
  /// In en, this message translates to:
  /// **'WaterCheck Console could not open its local data.'**
  String get startupFailed;

  /// No description provided for @startupRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get startupRetry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to WaterCheck Console'**
  String get signInTitle;

  /// No description provided for @signInUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get signInUsername;

  /// No description provided for @signInUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Your phone number or email, as given by the IT admin'**
  String get signInUsernameHint;

  /// No description provided for @signInPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get signInPassword;

  /// No description provided for @signInGo.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInGo;

  /// No description provided for @signInWorking.
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get signInWorking;

  /// No description provided for @signInMissing.
  ///
  /// In en, this message translates to:
  /// **'Enter your username and password.'**
  String get signInMissing;

  /// No description provided for @signInWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong username or password.'**
  String get signInWrong;

  /// No description provided for @signInLocked.
  ///
  /// In en, this message translates to:
  /// **'Too many wrong attempts. Try again in 15 minutes, or ask the IT admin.'**
  String get signInLocked;

  /// No description provided for @signInOffline.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server. Signing in needs the internet.'**
  String get signInOffline;

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed ({code}). Try again, or contact the IT admin.'**
  String signInFailed(String code);

  /// No description provided for @signInAfterIdle.
  ///
  /// In en, this message translates to:
  /// **'You were signed out after 30 minutes without activity.'**
  String get signInAfterIdle;

  /// No description provided for @signInExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has ended. Please sign in again.'**
  String get signInExpired;

  /// No description provided for @forgotLink.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotLink;

  /// No description provided for @forgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotTitle;

  /// No description provided for @forgotBody.
  ///
  /// In en, this message translates to:
  /// **'The IT admin will be asked to give you a new temporary password. Enter your username.'**
  String get forgotBody;

  /// No description provided for @forgotSend.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get forgotSend;

  /// No description provided for @forgotSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent. The IT admin will contact you with a new temporary password.'**
  String get forgotSent;

  /// No description provided for @forgotFailed.
  ///
  /// In en, this message translates to:
  /// **'The request could not be sent. Try again, or contact the IT admin.'**
  String get forgotFailed;

  /// No description provided for @passwordTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your own password'**
  String get passwordTitle;

  /// No description provided for @passwordIntro.
  ///
  /// In en, this message translates to:
  /// **'You signed in with a temporary password. Choose a new password that only you know.'**
  String get passwordIntro;

  /// No description provided for @passwordNew.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get passwordNew;

  /// No description provided for @passwordAgain.
  ///
  /// In en, this message translates to:
  /// **'New password again'**
  String get passwordAgain;

  /// No description provided for @passwordRule.
  ///
  /// In en, this message translates to:
  /// **'Use at least 10 characters, mixing letters and numbers.'**
  String get passwordRule;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'The two passwords are not the same.'**
  String get passwordMismatch;

  /// No description provided for @passwordSame.
  ///
  /// In en, this message translates to:
  /// **'Choose a password different from the temporary one.'**
  String get passwordSame;

  /// No description provided for @passwordSave.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get passwordSave;

  /// No description provided for @pinChooseTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a PIN for this device'**
  String get pinChooseTitle;

  /// No description provided for @unlockFor.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {name}'**
  String unlockFor(String name);

  /// No description provided for @unlockForgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN? Sign out'**
  String get unlockForgot;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'Offline: showing data saved on this device.'**
  String get offlineBanner;

  /// No description provided for @offlineRetry.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get offlineRetry;

  /// No description provided for @accountMenu.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountMenu;

  /// No description provided for @accountSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get accountSignOut;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'IT admin'**
  String get roleAdmin;

  /// No description provided for @roleStakeholder.
  ///
  /// In en, this message translates to:
  /// **'Stakeholder'**
  String get roleStakeholder;

  /// No description provided for @dashboardWelcome.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {name}'**
  String dashboardWelcome(String name);

  /// No description provided for @dashboardAreas.
  ///
  /// In en, this message translates to:
  /// **'Your areas: {areas}'**
  String dashboardAreas(String areas);

  /// No description provided for @dashboardNoAreas.
  ///
  /// In en, this message translates to:
  /// **'No areas have been assigned to you yet. Ask the IT admin.'**
  String get dashboardNoAreas;

  /// No description provided for @dashboardAdminScope.
  ///
  /// In en, this message translates to:
  /// **'IT admin: all areas'**
  String get dashboardAdminScope;

  /// No description provided for @recentTitle.
  ///
  /// In en, this message translates to:
  /// **'Latest tests'**
  String get recentTitle;

  /// No description provided for @recentHint.
  ///
  /// In en, this message translates to:
  /// **'Synced from Collect phones in your areas.'**
  String get recentHint;

  /// No description provided for @recentEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tests have reached this device yet.'**
  String get recentEmpty;

  /// No description provided for @recentLine.
  ///
  /// In en, this message translates to:
  /// **'{when} · by {collector}'**
  String recentLine(String when, String collector);

  /// No description provided for @recentUnknownCollector.
  ///
  /// In en, this message translates to:
  /// **'a collector'**
  String get recentUnknownCollector;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @syncRunning.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncRunning;

  /// No description provided for @syncOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline: showing data saved on this device. It will update when the connection returns.'**
  String get syncOffline;

  /// No description provided for @syncProblem.
  ///
  /// In en, this message translates to:
  /// **'Could not sync ({code}). It will try again by itself.'**
  String syncProblem(String code);

  /// No description provided for @alertTriggerEcoli.
  ///
  /// In en, this message translates to:
  /// **'E. coli detected'**
  String get alertTriggerEcoli;

  /// No description provided for @alertTriggerUnsafe.
  ///
  /// In en, this message translates to:
  /// **'Unsafe result'**
  String get alertTriggerUnsafe;

  /// No description provided for @alertTriggerBaseline.
  ///
  /// In en, this message translates to:
  /// **'Sudden change'**
  String get alertTriggerBaseline;

  /// No description provided for @alertTriggerSms.
  ///
  /// In en, this message translates to:
  /// **'Reported by SMS'**
  String get alertTriggerSms;

  /// No description provided for @alertStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get alertStatusOpen;

  /// No description provided for @alertStatusAcknowledged.
  ///
  /// In en, this message translates to:
  /// **'Acknowledged'**
  String get alertStatusAcknowledged;

  /// No description provided for @alertStatusAction.
  ///
  /// In en, this message translates to:
  /// **'Action in progress'**
  String get alertStatusAction;

  /// No description provided for @alertStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get alertStatusClosed;

  /// No description provided for @alertStatusFalseAlarm.
  ///
  /// In en, this message translates to:
  /// **'False alarm'**
  String get alertStatusFalseAlarm;

  /// No description provided for @alertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alertsTitle;

  /// No description provided for @alertsShowClosed.
  ///
  /// In en, this message translates to:
  /// **'Show closed'**
  String get alertsShowClosed;

  /// No description provided for @alertsNone.
  ///
  /// In en, this message translates to:
  /// **'No open alerts in your areas.'**
  String get alertsNone;

  /// No description provided for @alertNotFound.
  ///
  /// In en, this message translates to:
  /// **'This alert is not on this device yet. Sync and try again.'**
  String get alertNotFound;

  /// No description provided for @alertSeverity.
  ///
  /// In en, this message translates to:
  /// **'Severity: {severity}'**
  String alertSeverity(String severity);

  /// No description provided for @alertOpened.
  ///
  /// In en, this message translates to:
  /// **'Reported {when}'**
  String alertOpened(String when);

  /// No description provided for @alertReadings.
  ///
  /// In en, this message translates to:
  /// **'Readings'**
  String get alertReadings;

  /// No description provided for @detected.
  ///
  /// In en, this message translates to:
  /// **'Detected'**
  String get detected;

  /// No description provided for @notDetected.
  ///
  /// In en, this message translates to:
  /// **'Not detected'**
  String get notDetected;

  /// No description provided for @alertActions.
  ///
  /// In en, this message translates to:
  /// **'What to do'**
  String get alertActions;

  /// No description provided for @alertAcknowledge.
  ///
  /// In en, this message translates to:
  /// **'Acknowledge'**
  String get alertAcknowledge;

  /// No description provided for @alertStartAction.
  ///
  /// In en, this message translates to:
  /// **'Action in progress'**
  String get alertStartAction;

  /// No description provided for @alertClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get alertClose;

  /// No description provided for @alertFalseAlarm.
  ///
  /// In en, this message translates to:
  /// **'False alarm'**
  String get alertFalseAlarm;

  /// No description provided for @alertRequestLab.
  ///
  /// In en, this message translates to:
  /// **'Request lab confirmation'**
  String get alertRequestLab;

  /// No description provided for @alertAddNote.
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get alertAddNote;

  /// No description provided for @alertCloseTitle.
  ///
  /// In en, this message translates to:
  /// **'Close the alert: what was done?'**
  String get alertCloseTitle;

  /// No description provided for @alertFalseAlarmTitle.
  ///
  /// In en, this message translates to:
  /// **'Why is this a false alarm?'**
  String get alertFalseAlarmTitle;

  /// No description provided for @alertNoteHint.
  ///
  /// In en, this message translates to:
  /// **'For example: chlorinated the borehole, advised households to boil water'**
  String get alertNoteHint;

  /// No description provided for @alertSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get alertSave;

  /// No description provided for @alertHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get alertHistory;

  /// No description provided for @alertBySystem.
  ///
  /// In en, this message translates to:
  /// **'WaterCheck'**
  String get alertBySystem;

  /// No description provided for @alertByYou.
  ///
  /// In en, this message translates to:
  /// **'you'**
  String get alertByYou;

  /// No description provided for @alertByStakeholder.
  ///
  /// In en, this message translates to:
  /// **'a stakeholder'**
  String get alertByStakeholder;

  /// No description provided for @eventAcknowledged.
  ///
  /// In en, this message translates to:
  /// **'Acknowledged'**
  String get eventAcknowledged;

  /// No description provided for @eventAction.
  ///
  /// In en, this message translates to:
  /// **'Action started'**
  String get eventAction;

  /// No description provided for @eventClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get eventClosed;

  /// No description provided for @eventFalseAlarm.
  ///
  /// In en, this message translates to:
  /// **'Marked a false alarm'**
  String get eventFalseAlarm;

  /// No description provided for @eventActionTaken.
  ///
  /// In en, this message translates to:
  /// **'Collector recorded actions'**
  String get eventActionTaken;

  /// No description provided for @eventLabRequested.
  ///
  /// In en, this message translates to:
  /// **'Lab confirmation requested'**
  String get eventLabRequested;

  /// No description provided for @eventEscalated.
  ///
  /// In en, this message translates to:
  /// **'Escalated: nobody had acknowledged it'**
  String get eventEscalated;

  /// No description provided for @eventSms.
  ///
  /// In en, this message translates to:
  /// **'Received by SMS'**
  String get eventSms;

  /// No description provided for @eventReconciled.
  ///
  /// In en, this message translates to:
  /// **'SMS alert matched with the full record'**
  String get eventReconciled;

  /// No description provided for @eventNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get eventNote;

  /// No description provided for @inboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get inboxTitle;

  /// No description provided for @inboxMarkAll.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get inboxMarkAll;

  /// No description provided for @inboxEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications.'**
  String get inboxEmpty;

  /// No description provided for @inboxOffline.
  ///
  /// In en, this message translates to:
  /// **'Notifications need a connection.'**
  String get inboxOffline;

  /// No description provided for @filterArea.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get filterArea;

  /// No description provided for @filterAllAreas.
  ///
  /// In en, this message translates to:
  /// **'All my areas'**
  String get filterAllAreas;

  /// No description provided for @filterPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get filterPeriod;

  /// No description provided for @filterDays.
  ///
  /// In en, this message translates to:
  /// **'Last {days} days'**
  String filterDays(int days);

  /// No description provided for @filterProfile.
  ///
  /// In en, this message translates to:
  /// **'Judge results by'**
  String get filterProfile;

  /// No description provided for @filterAsCollected.
  ///
  /// In en, this message translates to:
  /// **'Profile used at collection'**
  String get filterAsCollected;

  /// No description provided for @profileShownAsCollected.
  ///
  /// In en, this message translates to:
  /// **'Each result is shown under the profile used when it was collected.'**
  String get profileShownAsCollected;

  /// No description provided for @profileShownUnder.
  ///
  /// In en, this message translates to:
  /// **'All results re-evaluated under {code}. Saved results do not change.'**
  String profileShownUnder(String code);

  /// No description provided for @kpiTested.
  ///
  /// In en, this message translates to:
  /// **'Sources tested'**
  String get kpiTested;

  /// No description provided for @kpiOfSources.
  ///
  /// In en, this message translates to:
  /// **'of {count} sources'**
  String kpiOfSources(int count);

  /// No description provided for @kpiUnsafe.
  ///
  /// In en, this message translates to:
  /// **'Tests unsafe'**
  String get kpiUnsafe;

  /// No description provided for @kpiUnsafeCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{no unsafe tests} =1{1 unsafe test} other{{count} unsafe tests}}'**
  String kpiUnsafeCount(int count);

  /// No description provided for @kpiOpenAlerts.
  ///
  /// In en, this message translates to:
  /// **'Open alerts'**
  String get kpiOpenAlerts;

  /// No description provided for @kpiOpenAlertsHint.
  ///
  /// In en, this message translates to:
  /// **'Not closed yet'**
  String get kpiOpenAlertsHint;

  /// No description provided for @kpiAckTime.
  ///
  /// In en, this message translates to:
  /// **'Time to acknowledge'**
  String get kpiAckTime;

  /// No description provided for @kpiAckTimeHint.
  ///
  /// In en, this message translates to:
  /// **'Median, alerts in the period'**
  String get kpiAckTimeHint;

  /// No description provided for @overdueTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Overdue sources} =1{1 overdue source} other{{count} overdue sources}}'**
  String overdueTitle(int count);

  /// No description provided for @overdueNone.
  ///
  /// In en, this message translates to:
  /// **'No source is overdue for testing.'**
  String get overdueNone;

  /// No description provided for @overdueSince.
  ///
  /// In en, this message translates to:
  /// **'Test was due {when}'**
  String overdueSince(String when);

  /// No description provided for @seeAllSources.
  ///
  /// In en, this message translates to:
  /// **'All sources'**
  String get seeAllSources;

  /// No description provided for @collectorActivity.
  ///
  /// In en, this message translates to:
  /// **'Collector activity'**
  String get collectorActivity;

  /// No description provided for @seeAllCollectors.
  ///
  /// In en, this message translates to:
  /// **'All collectors'**
  String get seeAllCollectors;

  /// No description provided for @collectorsNone.
  ///
  /// In en, this message translates to:
  /// **'Nobody submitted data in this period.'**
  String get collectorsNone;

  /// No description provided for @collectorLine.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 submission} other{{count} submissions}}, last {when}'**
  String collectorLine(int count, String when);

  /// No description provided for @markKnown.
  ///
  /// In en, this message translates to:
  /// **'Known'**
  String get markKnown;

  /// No description provided for @markFlagged.
  ///
  /// In en, this message translates to:
  /// **'Flagged'**
  String get markFlagged;

  /// No description provided for @durationDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String durationDays(int count);

  /// No description provided for @durationHours.
  ///
  /// In en, this message translates to:
  /// **'{count} h'**
  String durationHours(int count);

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String durationMinutes(int count);

  /// No description provided for @sourcesSearch.
  ///
  /// In en, this message translates to:
  /// **'Search by code or name'**
  String get sourcesSearch;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterUnsafe.
  ///
  /// In en, this message translates to:
  /// **'Unsafe'**
  String get filterUnsafe;

  /// No description provided for @filterOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get filterOverdue;

  /// No description provided for @filterNotTested.
  ///
  /// In en, this message translates to:
  /// **'Not tested'**
  String get filterNotTested;

  /// No description provided for @sourcesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No sources} =1{1 source} other{{count} sources}}'**
  String sourcesCount(int count);

  /// No description provided for @neverTested.
  ///
  /// In en, this message translates to:
  /// **'Never tested'**
  String get neverTested;

  /// No description provided for @lastTested.
  ///
  /// In en, this message translates to:
  /// **'Last tested {when}'**
  String lastTested(String when);

  /// No description provided for @overdueShort.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdueShort;

  /// No description provided for @functionalStatus.
  ///
  /// In en, this message translates to:
  /// **'{status, select, functional{Functional} partly_functional{Partly functional} broken{Broken} other{{status}}}'**
  String functionalStatus(String status);

  /// No description provided for @sourceType.
  ///
  /// In en, this message translates to:
  /// **'{type, select, borehole{Borehole} shallow_well{Shallow well} protected_spring{Protected spring} tap{Tap} rain_tank{Rain tank} other{Other source}}'**
  String sourceType(String type);

  /// No description provided for @sourceNotFound.
  ///
  /// In en, this message translates to:
  /// **'This source is not in your areas, or has not synced yet.'**
  String get sourceNotFound;

  /// No description provided for @sourceUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update source'**
  String get sourceUpdate;

  /// No description provided for @sourceName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sourceName;

  /// No description provided for @sourceHouseholds.
  ///
  /// In en, this message translates to:
  /// **'Households served (leave empty to keep)'**
  String get sourceHouseholds;

  /// No description provided for @sourceStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Working status'**
  String get sourceStatusLabel;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Test history'**
  String get historyTitle;

  /// No description provided for @reEvaluatedUnder.
  ///
  /// In en, this message translates to:
  /// **'re-evaluated under {code}'**
  String reEvaluatedUnder(String code);

  /// No description provided for @collectedUnder.
  ///
  /// In en, this message translates to:
  /// **'judged under {code}'**
  String collectedUnder(String code);

  /// No description provided for @submissionFlagged.
  ///
  /// In en, this message translates to:
  /// **'Flagged as suspicious'**
  String get submissionFlagged;

  /// No description provided for @flagSubmission.
  ///
  /// In en, this message translates to:
  /// **'Flag as suspicious'**
  String get flagSubmission;

  /// No description provided for @flagReasonHint.
  ///
  /// In en, this message translates to:
  /// **'What looks wrong? For example: readings identical to last week'**
  String get flagReasonHint;

  /// No description provided for @flagSave.
  ///
  /// In en, this message translates to:
  /// **'Flag'**
  String get flagSave;

  /// No description provided for @photosTitle.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photosTitle;

  /// No description provided for @photosNone.
  ///
  /// In en, this message translates to:
  /// **'No photos.'**
  String get photosNone;

  /// No description provided for @photoNeedsConnection.
  ///
  /// In en, this message translates to:
  /// **'Needs a connection'**
  String get photoNeedsConnection;

  /// No description provided for @photoNotUploaded.
  ///
  /// In en, this message translates to:
  /// **'Not uploaded yet'**
  String get photoNotUploaded;

  /// No description provided for @inspectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sanitary inspections'**
  String get inspectionsTitle;

  /// No description provided for @inspectionsNone.
  ///
  /// In en, this message translates to:
  /// **'No inspections.'**
  String get inspectionsNone;

  /// No description provided for @inspectionRisks.
  ///
  /// In en, this message translates to:
  /// **'{risks} of {answered} risks present'**
  String inspectionRisks(int risks, int answered);

  /// No description provided for @submittedBy.
  ///
  /// In en, this message translates to:
  /// **'Submitted by'**
  String get submittedBy;

  /// No description provided for @markCollector.
  ///
  /// In en, this message translates to:
  /// **'Mark collector'**
  String get markCollector;

  /// No description provided for @markAsKnown.
  ///
  /// In en, this message translates to:
  /// **'Mark as known'**
  String get markAsKnown;

  /// No description provided for @markAsFlagged.
  ///
  /// In en, this message translates to:
  /// **'Flag collector'**
  String get markAsFlagged;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get navProfile;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get profileTitle;

  /// No description provided for @profileOffline.
  ///
  /// In en, this message translates to:
  /// **'Changing notifications needs a connection.'**
  String get profileOffline;

  /// No description provided for @profileFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Try again.'**
  String get profileFailed;

  /// No description provided for @notifyTitle.
  ///
  /// In en, this message translates to:
  /// **'How alerts reach me'**
  String get notifyTitle;

  /// No description provided for @notifyHint.
  ///
  /// In en, this message translates to:
  /// **'Alerts for your areas are always in the Console. Choose the other channels.'**
  String get notifyHint;

  /// No description provided for @notifyInApp.
  ///
  /// In en, this message translates to:
  /// **'In the Console'**
  String get notifyInApp;

  /// No description provided for @notifyInAppHint.
  ///
  /// In en, this message translates to:
  /// **'Always on'**
  String get notifyInAppHint;

  /// No description provided for @notifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get notifyEmail;

  /// No description provided for @notifyNoEmail.
  ///
  /// In en, this message translates to:
  /// **'No email address on file; ask your IT administrator.'**
  String get notifyNoEmail;

  /// No description provided for @notifyPush.
  ///
  /// In en, this message translates to:
  /// **'Phone notification'**
  String get notifyPush;

  /// No description provided for @notifyPushHint.
  ///
  /// In en, this message translates to:
  /// **'On Android phones signed in to the Console'**
  String get notifyPushHint;

  /// No description provided for @notifySms.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get notifySms;

  /// No description provided for @notifyNoPhone.
  ///
  /// In en, this message translates to:
  /// **'No phone number on file; ask your IT administrator.'**
  String get notifyNoPhone;

  /// No description provided for @connectionLost.
  ///
  /// In en, this message translates to:
  /// **'Connection lost. Showing the data from the last sync.'**
  String get connectionLost;

  /// No description provided for @viewList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get viewList;

  /// No description provided for @viewMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get viewMap;

  /// No description provided for @mapNoBackground.
  ///
  /// In en, this message translates to:
  /// **'The map background is not available yet; dots still show where sources are.'**
  String get mapNoBackground;

  /// No description provided for @mapMissingLocation.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 source has no location and is not on the map.} other{{count} sources have no location and are not on the map.}}'**
  String mapMissingLocation(int count);

  /// No description provided for @mapAttribution.
  ///
  /// In en, this message translates to:
  /// **'OpenStreetMap contributors'**
  String get mapAttribution;

  /// No description provided for @profileAreas.
  ///
  /// In en, this message translates to:
  /// **'Areas'**
  String get profileAreas;

  /// No description provided for @profileResponsibilities.
  ///
  /// In en, this message translates to:
  /// **'Responsibilities'**
  String get profileResponsibilities;

  /// No description provided for @profileAllResponsibilities.
  ///
  /// In en, this message translates to:
  /// **'All alerts in my areas'**
  String get profileAllResponsibilities;

  /// No description provided for @profileContacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get profileContacts;

  /// No description provided for @profileNoContacts.
  ///
  /// In en, this message translates to:
  /// **'None on file; ask your IT administrator.'**
  String get profileNoContacts;

  /// No description provided for @collectorType.
  ///
  /// In en, this message translates to:
  /// **'{type, select, vht{VHT member} lc1{LC1 leader} resident{Trained resident} student{Student} other{Other collector}}'**
  String collectorType(String type);

  /// No description provided for @responsibility.
  ///
  /// In en, this message translates to:
  /// **'{code, select, water{Water} sanitation{Sanitation} health_inspection{Health inspection} other{{code}}}'**
  String responsibility(String code);

  /// No description provided for @conflictTitle.
  ///
  /// In en, this message translates to:
  /// **'Two changes disagree'**
  String get conflictTitle;

  /// No description provided for @conflictBody.
  ///
  /// In en, this message translates to:
  /// **'A phone set the working status to \"{phone}\", but it is now \"{current}\" from a newer change. Which is right?'**
  String conflictBody(String phone, String current);

  /// No description provided for @conflictKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep current'**
  String get conflictKeep;

  /// No description provided for @conflictUsePhone.
  ///
  /// In en, this message translates to:
  /// **'Use the phone\'s value'**
  String get conflictUsePhone;

  /// No description provided for @conflictActive.
  ///
  /// In en, this message translates to:
  /// **'In use'**
  String get conflictActive;

  /// No description provided for @conflictInactive.
  ///
  /// In en, this message translates to:
  /// **'No longer in use'**
  String get conflictInactive;

  /// No description provided for @mapUnsafe.
  ///
  /// In en, this message translates to:
  /// **'Unsafe'**
  String get mapUnsafe;

  /// No description provided for @mapInconclusive.
  ///
  /// In en, this message translates to:
  /// **'Inconclusive'**
  String get mapInconclusive;

  /// No description provided for @mapOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get mapOverdue;

  /// No description provided for @mapSafe.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get mapSafe;

  /// No description provided for @mapNotTested.
  ///
  /// In en, this message translates to:
  /// **'Not tested'**
  String get mapNotTested;

  /// No description provided for @mapUnsafeResult.
  ///
  /// In en, this message translates to:
  /// **'Unsafe result'**
  String get mapUnsafeResult;

  /// No description provided for @mapNoLocation.
  ///
  /// In en, this message translates to:
  /// **'Turn on location to see how far sources are from you.'**
  String get mapNoLocation;

  /// No description provided for @mapLocateMe.
  ///
  /// In en, this message translates to:
  /// **'Show where I am'**
  String get mapLocateMe;

  /// No description provided for @mapLayers.
  ///
  /// In en, this message translates to:
  /// **'Map layers'**
  String get mapLayers;

  /// No description provided for @mapLayerDistances.
  ///
  /// In en, this message translates to:
  /// **'Distances from me'**
  String get mapLayerDistances;

  /// No description provided for @mapLayerLabels.
  ///
  /// In en, this message translates to:
  /// **'Source names'**
  String get mapLayerLabels;

  /// No description provided for @mapLatestIssue.
  ///
  /// In en, this message translates to:
  /// **'Latest issue'**
  String get mapLatestIssue;

  /// No description provided for @mapOpenMap.
  ///
  /// In en, this message translates to:
  /// **'Open map'**
  String get mapOpenMap;

  /// No description provided for @mapNoIssue.
  ///
  /// In en, this message translates to:
  /// **'No open issues in your areas.'**
  String get mapNoIssue;

  /// No description provided for @mapSeverity.
  ///
  /// In en, this message translates to:
  /// **'{severity, select, critical{Critical} high{High} medium{Medium} low{Low} other{{severity}}}'**
  String mapSeverity(String severity);

  /// No description provided for @mapAway.
  ///
  /// In en, this message translates to:
  /// **'{distance} away'**
  String mapAway(String distance);

  /// No description provided for @mapAgo.
  ///
  /// In en, this message translates to:
  /// **'{time} ago'**
  String mapAgo(String time);

  /// No description provided for @mapOpenSource.
  ///
  /// In en, this message translates to:
  /// **'Open the source'**
  String get mapOpenSource;

  /// No description provided for @mapYouAreHere.
  ///
  /// In en, this message translates to:
  /// **'You are here'**
  String get mapYouAreHere;

  /// No description provided for @mapCluster.
  ///
  /// In en, this message translates to:
  /// **'{count} sources here; zoom in'**
  String mapCluster(int count);
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
