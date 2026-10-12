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
  /// **'Made on this device from the data synced to it; works offline on Windows and Android.'**
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

  /// No description provided for @noticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Water test notice'**
  String get noticeTitle;

  /// No description provided for @noticeHeadlineUnsafe.
  ///
  /// In en, this message translates to:
  /// **'NOT SAFE to drink without boiling or treating'**
  String get noticeHeadlineUnsafe;

  /// No description provided for @noticeHeadlineCaution.
  ///
  /// In en, this message translates to:
  /// **'NOT CONFIRMED SAFE: boil or treat before drinking'**
  String get noticeHeadlineCaution;

  /// No description provided for @noticeHeadlineSafe.
  ///
  /// In en, this message translates to:
  /// **'Safe on the last test'**
  String get noticeHeadlineSafe;

  /// No description provided for @noticeHeadlineNotTested.
  ///
  /// In en, this message translates to:
  /// **'Not tested yet'**
  String get noticeHeadlineNotTested;

  /// No description provided for @noticeTested.
  ///
  /// In en, this message translates to:
  /// **'Tested on {date}'**
  String noticeTested(String date);

  /// No description provided for @noticeWhatToDo.
  ///
  /// In en, this message translates to:
  /// **'What to do'**
  String get noticeWhatToDo;

  /// No description provided for @noticeBoil.
  ///
  /// In en, this message translates to:
  /// **'Boil drinking water for at least one minute, or treat it (for example with chlorine tablets).'**
  String get noticeBoil;

  /// No description provided for @noticeOtherSource.
  ///
  /// In en, this message translates to:
  /// **'If you can, use another safe source until the next test.'**
  String get noticeOtherSource;

  /// No description provided for @noticeContainers.
  ///
  /// In en, this message translates to:
  /// **'Keep water containers covered and clean.'**
  String get noticeContainers;

  /// No description provided for @noticeReportChange.
  ///
  /// In en, this message translates to:
  /// **'Tell the village health team if the colour, smell or taste changes.'**
  String get noticeReportChange;

  /// No description provided for @noticeMeasured.
  ///
  /// In en, this message translates to:
  /// **'What was measured'**
  String get noticeMeasured;

  /// No description provided for @noticeLimitationNoGermTest.
  ///
  /// In en, this message translates to:
  /// **'This test cannot detect germs. Boiling is still the safest choice.'**
  String get noticeLimitationNoGermTest;

  /// No description provided for @noticeLimitationGermNegative.
  ///
  /// In en, this message translates to:
  /// **'No E. coli was found in this test, but water can become unsafe at any time.'**
  String get noticeLimitationGermNegative;

  /// No description provided for @noticeContact.
  ///
  /// In en, this message translates to:
  /// **'Questions: ask the village health team (VHT) or the health inspector.'**
  String get noticeContact;

  /// No description provided for @noticePrinted.
  ///
  /// In en, this message translates to:
  /// **'Printed {date} from WaterCheck'**
  String noticePrinted(String date);

  /// No description provided for @pdfColParameter.
  ///
  /// In en, this message translates to:
  /// **'Measured'**
  String get pdfColParameter;

  /// No description provided for @pdfColValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get pdfColValue;

  /// No description provided for @pdfColLimit.
  ///
  /// In en, this message translates to:
  /// **'Safe range'**
  String get pdfColLimit;

  /// No description provided for @pdfColResult.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get pdfColResult;

  /// No description provided for @readingResult.
  ///
  /// In en, this message translates to:
  /// **'{result, select, ok{OK} high{Too high} low{Too low} detected{Found} unacceptable{Not acceptable} invalid{Invalid} other{-}}'**
  String readingResult(String result);

  /// No description provided for @statusWord.
  ///
  /// In en, this message translates to:
  /// **'{status, select, safe{SAFE} unsafe{UNSAFE} inconclusive{INCONCLUSIVE} other{NOT TESTED}}'**
  String statusWord(String status);

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Water quality report'**
  String get reportTitle;

  /// No description provided for @reportArea.
  ///
  /// In en, this message translates to:
  /// **'Area: {name}'**
  String reportArea(String name);

  /// No description provided for @reportPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period: {from} to {to}'**
  String reportPeriod(String from, String to);

  /// No description provided for @reportGenerated.
  ///
  /// In en, this message translates to:
  /// **'Generated {date} on this device'**
  String reportGenerated(String date);

  /// No description provided for @reportProfiles.
  ///
  /// In en, this message translates to:
  /// **'Limit sets used'**
  String get reportProfiles;

  /// No description provided for @reportProfileLine.
  ///
  /// In en, this message translates to:
  /// **'{code}: {title} (version {version})'**
  String reportProfileLine(String code, String title, int version);

  /// No description provided for @reportProvisional.
  ///
  /// In en, this message translates to:
  /// **'Provisional: may change after field calibration.'**
  String get reportProvisional;

  /// No description provided for @reportCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom limits based on {base}. Reason: {reason}'**
  String reportCustom(String base, String reason);

  /// No description provided for @reportIndicators.
  ///
  /// In en, this message translates to:
  /// **'Impact indicators'**
  String get reportIndicators;

  /// No description provided for @indSourcesTested.
  ///
  /// In en, this message translates to:
  /// **'Sources tested in the period'**
  String get indSourcesTested;

  /// No description provided for @indTests.
  ///
  /// In en, this message translates to:
  /// **'Tests in the period'**
  String get indTests;

  /// No description provided for @indAbnormalAction.
  ///
  /// In en, this message translates to:
  /// **'Abnormal tests with a documented action'**
  String get indAbnormalAction;

  /// No description provided for @indOnSchedule.
  ///
  /// In en, this message translates to:
  /// **'Sources tested on schedule'**
  String get indOnSchedule;

  /// No description provided for @indCollectors.
  ///
  /// In en, this message translates to:
  /// **'Collectors active'**
  String get indCollectors;

  /// No description provided for @indAck.
  ///
  /// In en, this message translates to:
  /// **'Median time to acknowledge an alert'**
  String get indAck;

  /// No description provided for @indOf.
  ///
  /// In en, this message translates to:
  /// **'{n} of {total}'**
  String indOf(int n, int total);

  /// No description provided for @reportSources.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get reportSources;

  /// No description provided for @colSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get colSource;

  /// No description provided for @colVillage.
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get colVillage;

  /// No description provided for @colLastTest.
  ///
  /// In en, this message translates to:
  /// **'Last test'**
  String get colLastTest;

  /// No description provided for @colStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get colStatus;

  /// No description provided for @colReadings.
  ///
  /// In en, this message translates to:
  /// **'Latest readings (value / safe range)'**
  String get colReadings;

  /// No description provided for @reportAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts and responses'**
  String get reportAlerts;

  /// No description provided for @colOpened.
  ///
  /// In en, this message translates to:
  /// **'Opened'**
  String get colOpened;

  /// No description provided for @colAlert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get colAlert;

  /// No description provided for @colActions.
  ///
  /// In en, this message translates to:
  /// **'What was done'**
  String get colActions;

  /// No description provided for @reportNoAlerts.
  ///
  /// In en, this message translates to:
  /// **'No alerts were opened in this period.'**
  String get reportNoAlerts;

  /// No description provided for @reportLimitations.
  ///
  /// In en, this message translates to:
  /// **'Limitations'**
  String get reportLimitations;

  /// No description provided for @reportLimitationsText.
  ///
  /// In en, this message translates to:
  /// **'Results come from field test kits, not a laboratory. A test cannot detect germs unless E. coli was tested. Each result is judged under the limit set used when it was collected (named above); provisional limits may change after field calibration. Sources without a location or never tested are listed but cannot show trends.'**
  String get reportLimitationsText;

  /// No description provided for @reportPage.
  ///
  /// In en, this message translates to:
  /// **'Page {n} of {total}'**
  String reportPage(int n, int total);

  /// No description provided for @reportNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get reportNone;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports and exports'**
  String get reportsTitle;

  /// No description provided for @reportsPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF report'**
  String get reportsPdf;

  /// No description provided for @reportsPdfHint.
  ///
  /// In en, this message translates to:
  /// **'Summary, impact indicators, sources with their latest values, alerts and what was done.'**
  String get reportsPdfHint;

  /// No description provided for @reportsCsv.
  ///
  /// In en, this message translates to:
  /// **'Readings (CSV)'**
  String get reportsCsv;

  /// No description provided for @reportsCsvHint.
  ///
  /// In en, this message translates to:
  /// **'One row per reading, for spreadsheets and analysis.'**
  String get reportsCsvHint;

  /// No description provided for @reportsSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved: {name}'**
  String reportsSaved(String name);

  /// No description provided for @reportsCancelled.
  ///
  /// In en, this message translates to:
  /// **'Not saved.'**
  String get reportsCancelled;

  /// No description provided for @reportsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not make the file: {error}'**
  String reportsFailed(String error);

  /// No description provided for @reportsPrint.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get reportsPrint;

  /// No description provided for @reportsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get reportsSave;

  /// No description provided for @noticeAction.
  ///
  /// In en, this message translates to:
  /// **'Community notice'**
  String get noticeAction;

  /// No description provided for @noticeSize.
  ///
  /// In en, this message translates to:
  /// **'Paper size'**
  String get noticeSize;

  /// No description provided for @colIndicator.
  ///
  /// In en, this message translates to:
  /// **'Indicator'**
  String get colIndicator;

  /// No description provided for @colValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get colValue;

  /// No description provided for @adminNeedsConnection.
  ///
  /// In en, this message translates to:
  /// **'Managing people and phones needs a connection to the server.'**
  String get adminNeedsConnection;

  /// No description provided for @areaLevel.
  ///
  /// In en, this message translates to:
  /// **'{level, select, country{national} region{region} district{district} subcounty{sub-county} parish{parish} village{village} other{{level}}}'**
  String areaLevel(String level);

  /// No description provided for @areaPickTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose areas'**
  String get areaPickTitle;

  /// No description provided for @areaPickOne.
  ///
  /// In en, this message translates to:
  /// **'Choose an area'**
  String get areaPickOne;

  /// No description provided for @areaPickSearch.
  ///
  /// In en, this message translates to:
  /// **'Search any village, sub-county, district or region'**
  String get areaPickSearch;

  /// No description provided for @areaPickDone.
  ///
  /// In en, this message translates to:
  /// **'Use {n} areas'**
  String areaPickDone(int n);

  /// No description provided for @adminPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get adminPeople;

  /// No description provided for @adminPeopleHint.
  ///
  /// In en, this message translates to:
  /// **'Create stakeholders and IT admins at any level, reset passwords, disable accounts.'**
  String get adminPeopleHint;

  /// No description provided for @adminPhones.
  ///
  /// In en, this message translates to:
  /// **'Collect phones'**
  String get adminPhones;

  /// No description provided for @adminPhonesHint.
  ///
  /// In en, this message translates to:
  /// **'Activation codes, phones in use, revoking a lost phone.'**
  String get adminPhonesHint;

  /// No description provided for @adminChain.
  ///
  /// In en, this message translates to:
  /// **'Who covers an area'**
  String get adminChain;

  /// No description provided for @adminChainHint.
  ///
  /// In en, this message translates to:
  /// **'The chain of people an alert reaches, level by level, and the gaps.'**
  String get adminChainHint;

  /// No description provided for @usersTitle.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get usersTitle;

  /// No description provided for @usersNew.
  ///
  /// In en, this message translates to:
  /// **'New person'**
  String get usersNew;

  /// No description provided for @usersSearch.
  ///
  /// In en, this message translates to:
  /// **'Search by name, username or area'**
  String get usersSearch;

  /// No description provided for @usersNeverSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Never signed in'**
  String get usersNeverSignedIn;

  /// No description provided for @usersLastSignIn.
  ///
  /// In en, this message translates to:
  /// **'Last sign-in {when}'**
  String usersLastSignIn(String when);

  /// No description provided for @usersDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get usersDisabled;

  /// No description provided for @usersLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get usersLocked;

  /// No description provided for @usersFirstSignIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in yet'**
  String get usersFirstSignIn;

  /// No description provided for @usersFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get usersFullName;

  /// No description provided for @usersUsername.
  ///
  /// In en, this message translates to:
  /// **'Username (email or phone)'**
  String get usersUsername;

  /// No description provided for @usersOrganisation.
  ///
  /// In en, this message translates to:
  /// **'Organisation'**
  String get usersOrganisation;

  /// No description provided for @usersPosition.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get usersPosition;

  /// No description provided for @usersPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get usersPhone;

  /// No description provided for @usersEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get usersEmail;

  /// No description provided for @usersAreas.
  ///
  /// In en, this message translates to:
  /// **'Areas'**
  String get usersAreas;

  /// No description provided for @usersAddArea.
  ///
  /// In en, this message translates to:
  /// **'Add or change areas'**
  String get usersAddArea;

  /// No description provided for @usersAreasHint.
  ///
  /// In en, this message translates to:
  /// **'Any level, from a village to national. The person sees these areas and everything below them, and receives alerts from them.'**
  String get usersAreasHint;

  /// No description provided for @usersResponsibilities.
  ///
  /// In en, this message translates to:
  /// **'Responsibilities'**
  String get usersResponsibilities;

  /// No description provided for @usersResponsibilitiesHint.
  ///
  /// In en, this message translates to:
  /// **'None chosen: every alert in their areas.'**
  String get usersResponsibilitiesHint;

  /// No description provided for @usersActive.
  ///
  /// In en, this message translates to:
  /// **'Account active'**
  String get usersActive;

  /// No description provided for @usersActiveHint.
  ///
  /// In en, this message translates to:
  /// **'Turning it off signs the person out everywhere.'**
  String get usersActiveHint;

  /// No description provided for @usersResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get usersResetPassword;

  /// No description provided for @usersCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get usersCreate;

  /// No description provided for @usersTaken.
  ///
  /// In en, this message translates to:
  /// **'That username is already in use.'**
  String get usersTaken;

  /// No description provided for @usersSelfLockout.
  ///
  /// In en, this message translates to:
  /// **'You cannot disable your own account or remove your own IT admin role.'**
  String get usersSelfLockout;

  /// No description provided for @usersFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save ({code}).'**
  String usersFailed(String code);

  /// No description provided for @credentialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Temporary password'**
  String get credentialsTitle;

  /// No description provided for @credentialsHint.
  ///
  /// In en, this message translates to:
  /// **'Shown only now. Give it to the person in person, by SMS or by email; they must change it when they first sign in.'**
  String get credentialsHint;

  /// No description provided for @credentialsUsername.
  ///
  /// In en, this message translates to:
  /// **'Username: {name}'**
  String credentialsUsername(String name);

  /// No description provided for @credentialsCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get credentialsCopy;

  /// No description provided for @credentialsDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get credentialsDone;

  /// No description provided for @phonesTitle.
  ///
  /// In en, this message translates to:
  /// **'Collect phones'**
  String get phonesTitle;

  /// No description provided for @phonesHint.
  ///
  /// In en, this message translates to:
  /// **'Phones activated with a code for an area. Revoke a lost or stolen phone: it stops syncing and locks itself.'**
  String get phonesHint;

  /// No description provided for @phonesNone.
  ///
  /// In en, this message translates to:
  /// **'No phones activated yet.'**
  String get phonesNone;

  /// No description provided for @phonesNewCode.
  ///
  /// In en, this message translates to:
  /// **'New activation code'**
  String get phonesNewCode;

  /// No description provided for @phonesActivity.
  ///
  /// In en, this message translates to:
  /// **'{collectors} collectors, {tests} tests'**
  String phonesActivity(int collectors, int tests);

  /// No description provided for @phonesNeverSynced.
  ///
  /// In en, this message translates to:
  /// **'Never synced'**
  String get phonesNeverSynced;

  /// No description provided for @phonesLastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last sync {when}'**
  String phonesLastSeen(String when);

  /// No description provided for @phonesRevokedAt.
  ///
  /// In en, this message translates to:
  /// **'Revoked {when}'**
  String phonesRevokedAt(String when);

  /// No description provided for @phonesRevoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get phonesRevoke;

  /// No description provided for @phonesRevokeTitle.
  ///
  /// In en, this message translates to:
  /// **'Revoke this phone?'**
  String get phonesRevokeTitle;

  /// No description provided for @phonesRevokeHint.
  ///
  /// In en, this message translates to:
  /// **'It stops syncing at once. Unsent records on it are saved to an encrypted file only the server can read.'**
  String get phonesRevokeHint;

  /// No description provided for @phonesCodes.
  ///
  /// In en, this message translates to:
  /// **'Recent activation codes'**
  String get phonesCodes;

  /// No description provided for @phonesNoCodes.
  ///
  /// In en, this message translates to:
  /// **'No codes yet.'**
  String get phonesNoCodes;

  /// No description provided for @phonesCodeLine.
  ///
  /// In en, this message translates to:
  /// **'{used} of {max} phones · valid until {until}'**
  String phonesCodeLine(int used, int max, String until);

  /// No description provided for @phonesNewCodeFor.
  ///
  /// In en, this message translates to:
  /// **'Activation code for {area}'**
  String phonesNewCodeFor(String area);

  /// No description provided for @phonesMax.
  ///
  /// In en, this message translates to:
  /// **'Up to {n} phones'**
  String phonesMax(int n);

  /// No description provided for @phonesValidDays.
  ///
  /// In en, this message translates to:
  /// **'Valid for {n} days'**
  String phonesValidDays(int n);

  /// No description provided for @phonesCreateCode.
  ///
  /// In en, this message translates to:
  /// **'Create code'**
  String get phonesCreateCode;

  /// No description provided for @phonesCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Code for {area}'**
  String phonesCodeTitle(String area);

  /// No description provided for @phonesCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Shown only now. On the phone, open WaterCheck Collect and scan the QR code or type the code.'**
  String get phonesCodeHint;

  /// No description provided for @phonesQrLabel.
  ///
  /// In en, this message translates to:
  /// **'Activation QR code'**
  String get phonesQrLabel;

  /// No description provided for @chainTitle.
  ///
  /// In en, this message translates to:
  /// **'Who covers an area'**
  String get chainTitle;

  /// No description provided for @chainHint.
  ///
  /// In en, this message translates to:
  /// **'Pick any area to see who an alert from it reaches, level by level. Levels with nobody are skipped; the IT admins are told only when nobody covers it.'**
  String get chainHint;

  /// No description provided for @chainPick.
  ///
  /// In en, this message translates to:
  /// **'Choose an area'**
  String get chainPick;

  /// No description provided for @chainGap.
  ///
  /// In en, this message translates to:
  /// **'Nobody at this level (skipped)'**
  String get chainGap;

  /// No description provided for @chainFirst.
  ///
  /// In en, this message translates to:
  /// **'Gets the first notice'**
  String get chainFirst;

  /// No description provided for @chainNobody.
  ///
  /// In en, this message translates to:
  /// **'Nobody covers this area: alerts from it go to the IT admins.'**
  String get chainNobody;

  /// No description provided for @limitSetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Limit sets'**
  String get limitSetsTitle;

  /// No description provided for @limitSetsHint.
  ///
  /// In en, this message translates to:
  /// **'Published sets come from the standards. A custom set changes some limits for tests from now on; it is recorded under your name with your comment, and earlier results keep the limits they were judged under.'**
  String get limitSetsHint;

  /// No description provided for @limitSetsHintAdmin.
  ///
  /// In en, this message translates to:
  /// **'Published and custom sets. Only stakeholders create custom sets (in the Console, or on a phone at calibration after signing in).'**
  String get limitSetsHintAdmin;

  /// No description provided for @limitSetsNew.
  ///
  /// In en, this message translates to:
  /// **'New custom limit set'**
  String get limitSetsNew;

  /// No description provided for @limitSetsCustomOf.
  ///
  /// In en, this message translates to:
  /// **'Custom, based on {base}'**
  String limitSetsCustomOf(String base);

  /// No description provided for @limitSetsProvisional.
  ///
  /// In en, this message translates to:
  /// **'Provisional: may change after field calibration'**
  String get limitSetsProvisional;

  /// No description provided for @limitSetsReason.
  ///
  /// In en, this message translates to:
  /// **'Comment: {reason}'**
  String limitSetsReason(String reason);

  /// No description provided for @limitSetsBase.
  ///
  /// In en, this message translates to:
  /// **'Based on'**
  String get limitSetsBase;

  /// No description provided for @limitSetsMin.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get limitSetsMin;

  /// No description provided for @limitSetsMax.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get limitSetsMax;

  /// No description provided for @limitSetsComment.
  ///
  /// In en, this message translates to:
  /// **'Your comment (why these limits)'**
  String get limitSetsComment;

  /// No description provided for @limitSetsCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Required. Recorded with your name.'**
  String get limitSetsCommentHint;

  /// No description provided for @limitSetsChanged.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =0{No limit changed yet} =1{1 limit changed} other{{n} limits changed}}'**
  String limitSetsChanged(int n);

  /// No description provided for @limitSetsSave.
  ///
  /// In en, this message translates to:
  /// **'Create limit set'**
  String get limitSetsSave;

  /// No description provided for @navLimitSets.
  ///
  /// In en, this message translates to:
  /// **'Limit sets'**
  String get navLimitSets;
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
