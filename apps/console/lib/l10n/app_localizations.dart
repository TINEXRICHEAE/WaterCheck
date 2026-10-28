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
  /// **'FieldQuire Console'**
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
  /// **'Changes here reach the devices with their next sync.'**
  String get adminMoreHint;

  /// No description provided for @startupFailed.
  ///
  /// In en, this message translates to:
  /// **'FieldQuire Console could not open its local data.'**
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
  /// **'Sign in to FieldQuire Console'**
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
  /// **'Synced from Collect devices in your areas.'**
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
  /// **'FieldQuire'**
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
  /// **'A device set the working status to \"{phone}\", but it is now \"{current}\" from a newer change. Which is right?'**
  String conflictBody(String phone, String current);

  /// No description provided for @conflictKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep current'**
  String get conflictKeep;

  /// No description provided for @conflictUsePhone.
  ///
  /// In en, this message translates to:
  /// **'Use the device\'s value'**
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
  /// **'Printed {date} from FieldQuire'**
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
  /// **'Managing people and devices needs a connection to the server.'**
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
  /// **'Collect devices'**
  String get adminPhones;

  /// No description provided for @adminPhonesHint.
  ///
  /// In en, this message translates to:
  /// **'Assignment codes for testers, devices in use, revoking a lost device.'**
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
  /// **'Collect devices'**
  String get phonesTitle;

  /// No description provided for @phonesHint.
  ///
  /// In en, this message translates to:
  /// **'Devices register themselves when Collect is opened; testers are assigned to areas with codes. Revoke a lost or stolen device: it stops syncing and locks itself.'**
  String get phonesHint;

  /// No description provided for @phonesNone.
  ///
  /// In en, this message translates to:
  /// **'No devices yet.'**
  String get phonesNone;

  /// No description provided for @phonesNewCode.
  ///
  /// In en, this message translates to:
  /// **'New assignment code'**
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
  /// **'Revoke this device?'**
  String get phonesRevokeTitle;

  /// No description provided for @phonesRevokeHint.
  ///
  /// In en, this message translates to:
  /// **'It stops syncing at once. Unsent records on it are saved to an encrypted file only the server can read.'**
  String get phonesRevokeHint;

  /// No description provided for @phonesCodes.
  ///
  /// In en, this message translates to:
  /// **'Recent assignment codes'**
  String get phonesCodes;

  /// No description provided for @phonesNoCodes.
  ///
  /// In en, this message translates to:
  /// **'No codes yet.'**
  String get phonesNoCodes;

  /// No description provided for @phonesCodeLine.
  ///
  /// In en, this message translates to:
  /// **'{used} of {max} uses · valid until {until}'**
  String phonesCodeLine(int used, int max, String until);

  /// No description provided for @phonesNewCodeFor.
  ///
  /// In en, this message translates to:
  /// **'Assignment code for {area}'**
  String phonesNewCodeFor(String area);

  /// No description provided for @phonesMax.
  ///
  /// In en, this message translates to:
  /// **'Up to {n} testers'**
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
  /// **'Shown only now. The tester opens Collect › Settings › Your area and devices › Enter an assignment code, and types or scans it.'**
  String get phonesCodeHint;

  /// No description provided for @phonesQrLabel.
  ///
  /// In en, this message translates to:
  /// **'Assignment QR code'**
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
  /// **'Published and custom sets. Only stakeholders create custom sets (in the Console, or on a device at calibration after signing in).'**
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

  /// No description provided for @adminSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get adminSystem;

  /// No description provided for @adminSystemHint.
  ///
  /// In en, this message translates to:
  /// **'Health of the server and the audit log'**
  String get adminSystemHint;

  /// No description provided for @adminSecurity.
  ///
  /// In en, this message translates to:
  /// **'Sign-in security'**
  String get adminSecurity;

  /// No description provided for @adminSecurityHint.
  ///
  /// In en, this message translates to:
  /// **'Lockout, password length and idle timeout'**
  String get adminSecurityHint;

  /// No description provided for @adminRouting.
  ///
  /// In en, this message translates to:
  /// **'Alert routing'**
  String get adminRouting;

  /// No description provided for @adminRoutingHint.
  ///
  /// In en, this message translates to:
  /// **'Which responsibilities each kind of alert reaches'**
  String get adminRoutingHint;

  /// No description provided for @adminPlaces.
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get adminPlaces;

  /// No description provided for @adminPlacesHint.
  ///
  /// In en, this message translates to:
  /// **'Add parishes and villages, rename places, set default limit sets'**
  String get adminPlacesHint;

  /// No description provided for @adminParams.
  ///
  /// In en, this message translates to:
  /// **'New parameters'**
  String get adminParams;

  /// No description provided for @adminParamsHint.
  ///
  /// In en, this message translates to:
  /// **'Approve, rename, merge or reject parameters added in the field'**
  String get adminParamsHint;

  /// No description provided for @adminCards.
  ///
  /// In en, this message translates to:
  /// **'Response cards'**
  String get adminCards;

  /// No description provided for @adminCardsHint.
  ///
  /// In en, this message translates to:
  /// **'What collectors are told to do after an unsafe result'**
  String get adminCardsHint;

  /// No description provided for @systemHealth.
  ///
  /// In en, this message translates to:
  /// **'System health'**
  String get systemHealth;

  /// No description provided for @systemRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get systemRefresh;

  /// No description provided for @systemAudit.
  ///
  /// In en, this message translates to:
  /// **'Audit log'**
  String get systemAudit;

  /// No description provided for @systemAuditHint.
  ///
  /// In en, this message translates to:
  /// **'Every change by a person or device, newest first. Filter by action (for example user. or reference_profile.) and dates.'**
  String get systemAuditHint;

  /// No description provided for @systemAuditAction.
  ///
  /// In en, this message translates to:
  /// **'Action starts with'**
  String get systemAuditAction;

  /// No description provided for @systemAuditAnyDate.
  ///
  /// In en, this message translates to:
  /// **'Any date'**
  String get systemAuditAnyDate;

  /// No description provided for @systemAuditApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get systemAuditApply;

  /// No description provided for @systemAuditExport.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get systemAuditExport;

  /// No description provided for @systemAuditEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches these filters.'**
  String get systemAuditEmpty;

  /// No description provided for @systemAuditSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemAuditSystem;

  /// No description provided for @systemExported.
  ///
  /// In en, this message translates to:
  /// **'Saved {name}'**
  String systemExported(String name);

  /// No description provided for @healthDatabase.
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get healthDatabase;

  /// No description provided for @healthOk.
  ///
  /// In en, this message translates to:
  /// **'Working'**
  String get healthOk;

  /// No description provided for @healthDown.
  ///
  /// In en, this message translates to:
  /// **'Not reachable'**
  String get healthDown;

  /// No description provided for @healthWorker.
  ///
  /// In en, this message translates to:
  /// **'Last background job'**
  String get healthWorker;

  /// No description provided for @healthNever.
  ///
  /// In en, this message translates to:
  /// **'None yet'**
  String get healthNever;

  /// No description provided for @healthJobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs waiting'**
  String get healthJobs;

  /// No description provided for @healthJobsValue.
  ///
  /// In en, this message translates to:
  /// **'{queued} ({overdue} late)'**
  String healthJobsValue(int queued, int overdue);

  /// No description provided for @healthFailed.
  ///
  /// In en, this message translates to:
  /// **'Failures (24 h)'**
  String get healthFailed;

  /// No description provided for @healthPhones.
  ///
  /// In en, this message translates to:
  /// **'Devices active (7 days)'**
  String get healthPhones;

  /// No description provided for @healthPhonesValue.
  ///
  /// In en, this message translates to:
  /// **'{active} of {total}'**
  String healthPhonesValue(int active, int total);

  /// No description provided for @healthRecords.
  ///
  /// In en, this message translates to:
  /// **'Tests received (24 h)'**
  String get healthRecords;

  /// No description provided for @healthConflicts.
  ///
  /// In en, this message translates to:
  /// **'Open sync conflicts'**
  String get healthConflicts;

  /// No description provided for @healthPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get healthPhotos;

  /// No description provided for @healthPhotosValue.
  ///
  /// In en, this message translates to:
  /// **'{count} ({mb} MB)'**
  String healthPhotosValue(int count, String mb);

  /// No description provided for @healthBackup.
  ///
  /// In en, this message translates to:
  /// **'Last backup'**
  String get healthBackup;

  /// No description provided for @healthBackupNone.
  ///
  /// In en, this message translates to:
  /// **'Not set up yet (comes with deployment)'**
  String get healthBackupNone;

  /// No description provided for @healthVersions.
  ///
  /// In en, this message translates to:
  /// **'Collect versions in use: {list}'**
  String healthVersions(String list);

  /// No description provided for @securityTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign-in security'**
  String get securityTitle;

  /// No description provided for @securityHint.
  ///
  /// In en, this message translates to:
  /// **'Applies at each person\'s next sign-in or password change. The idle timeout applies to the Console.'**
  String get securityHint;

  /// No description provided for @securityMaxFailed.
  ///
  /// In en, this message translates to:
  /// **'Wrong passwords before lockout'**
  String get securityMaxFailed;

  /// No description provided for @securityLockout.
  ///
  /// In en, this message translates to:
  /// **'Lockout length (minutes)'**
  String get securityLockout;

  /// No description provided for @securityPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Shortest password allowed'**
  String get securityPasswordLength;

  /// No description provided for @securityIdle.
  ///
  /// In en, this message translates to:
  /// **'Console idle timeout (minutes)'**
  String get securityIdle;

  /// No description provided for @securityRange.
  ///
  /// In en, this message translates to:
  /// **'From {min} to {max}'**
  String securityRange(int min, int max);

  /// No description provided for @securityOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'Outside the allowed range'**
  String get securityOutOfRange;

  /// No description provided for @securitySave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get securitySave;

  /// No description provided for @securitySaved.
  ///
  /// In en, this message translates to:
  /// **'Security settings saved'**
  String get securitySaved;

  /// No description provided for @routingTitle.
  ///
  /// In en, this message translates to:
  /// **'Alert routing'**
  String get routingTitle;

  /// No description provided for @routingHint.
  ///
  /// In en, this message translates to:
  /// **'Besides the people covering the area, each kind of alert also reaches the people with the ticked responsibilities.'**
  String get routingHint;

  /// No description provided for @routingResponsibility.
  ///
  /// In en, this message translates to:
  /// **'Responsibility'**
  String get routingResponsibility;

  /// No description provided for @routingTrigger.
  ///
  /// In en, this message translates to:
  /// **'{rule, select, ecoli{E. coli found} unsafe{Unsafe readings} baseline_jump{Sudden change} sms{By text message} other{{rule}}}'**
  String routingTrigger(String rule);

  /// No description provided for @routingSave.
  ///
  /// In en, this message translates to:
  /// **'Save routing'**
  String get routingSave;

  /// No description provided for @routingSaved.
  ///
  /// In en, this message translates to:
  /// **'Alert routing saved'**
  String get routingSaved;

  /// No description provided for @routingAdd.
  ///
  /// In en, this message translates to:
  /// **'New responsibility'**
  String get routingAdd;

  /// No description provided for @routingAddName.
  ///
  /// In en, this message translates to:
  /// **'Name, for example School health'**
  String get routingAddName;

  /// No description provided for @routingAddCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get routingAddCreate;

  /// No description provided for @routingExists.
  ///
  /// In en, this message translates to:
  /// **'That responsibility exists already, or the server is not reachable.'**
  String get routingExists;

  /// No description provided for @placesTitle.
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get placesTitle;

  /// No description provided for @placesHint.
  ///
  /// In en, this message translates to:
  /// **'The official list ends at sub-county. Add parishes and villages below it, fix names, and choose the limit set devices in an area start with.'**
  String get placesHint;

  /// No description provided for @placesAdd.
  ///
  /// In en, this message translates to:
  /// **'Add a place below'**
  String get placesAdd;

  /// No description provided for @placesRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get placesRename;

  /// No description provided for @placesLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get placesLevel;

  /// No description provided for @placesName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get placesName;

  /// No description provided for @placesAddSave.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get placesAddSave;

  /// No description provided for @placesRenameSave.
  ///
  /// In en, this message translates to:
  /// **'Save name'**
  String get placesRenameSave;

  /// No description provided for @placesAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} added'**
  String placesAdded(String name);

  /// No description provided for @placesRenamed.
  ///
  /// In en, this message translates to:
  /// **'Renamed to {name}'**
  String placesRenamed(String name);

  /// No description provided for @placesExists.
  ///
  /// In en, this message translates to:
  /// **'A place with that name is already there.'**
  String get placesExists;

  /// No description provided for @placesDefault.
  ///
  /// In en, this message translates to:
  /// **'Default limit set'**
  String get placesDefault;

  /// No description provided for @placesDefaultHint.
  ///
  /// In en, this message translates to:
  /// **'Devices in this area, and the areas below it, start with this set. Tests already taken keep the set they were judged by.'**
  String get placesDefaultHint;

  /// No description provided for @placesInherit.
  ///
  /// In en, this message translates to:
  /// **'Same as the area above'**
  String get placesInherit;

  /// No description provided for @placesDefaultSaved.
  ///
  /// In en, this message translates to:
  /// **'Default limit set saved'**
  String get placesDefaultSaved;

  /// No description provided for @paramsTitle.
  ///
  /// In en, this message translates to:
  /// **'New parameters'**
  String get paramsTitle;

  /// No description provided for @paramsHint.
  ///
  /// In en, this message translates to:
  /// **'Collectors can add a parameter that is not in the list. Approve it, fix its name, merge it into an existing parameter, or reject it.'**
  String get paramsHint;

  /// No description provided for @paramsNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing waiting for review.'**
  String get paramsNone;

  /// No description provided for @paramsBy.
  ///
  /// In en, this message translates to:
  /// **'Added by {name} · {count, plural, =0{no readings} =1{1 reading} other{{count} readings}}'**
  String paramsBy(String name, int count);

  /// No description provided for @paramsApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get paramsApprove;

  /// No description provided for @paramsRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get paramsRename;

  /// No description provided for @paramsMerge.
  ///
  /// In en, this message translates to:
  /// **'Merge into...'**
  String get paramsMerge;

  /// No description provided for @paramsMergeInto.
  ///
  /// In en, this message translates to:
  /// **'Merge into'**
  String get paramsMergeInto;

  /// No description provided for @paramsReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get paramsReject;

  /// No description provided for @paramsSaveName.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get paramsSaveName;

  /// No description provided for @paramsDone.
  ///
  /// In en, this message translates to:
  /// **'Review saved'**
  String get paramsDone;

  /// No description provided for @cardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Response cards'**
  String get cardsTitle;

  /// No description provided for @cardsHint.
  ///
  /// In en, this message translates to:
  /// **'Shown to collectors after a result. Each save makes a new version; devices get it with their next sync.'**
  String get cardsHint;

  /// No description provided for @cardsVersion.
  ///
  /// In en, this message translates to:
  /// **'version {v}'**
  String cardsVersion(int v);

  /// No description provided for @cardsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit card'**
  String get cardsEdit;

  /// No description provided for @cardsCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get cardsCardTitle;

  /// No description provided for @cardsActions.
  ///
  /// In en, this message translates to:
  /// **'What to do'**
  String get cardsActions;

  /// No description provided for @cardsActionsHint.
  ///
  /// In en, this message translates to:
  /// **'One step per line, in plain words'**
  String get cardsActionsHint;

  /// No description provided for @cardsReportNote.
  ///
  /// In en, this message translates to:
  /// **'Note on reporting'**
  String get cardsReportNote;

  /// No description provided for @cardsSave.
  ///
  /// In en, this message translates to:
  /// **'Save new version'**
  String get cardsSave;

  /// No description provided for @cardsSaved.
  ///
  /// In en, this message translates to:
  /// **'Card saved'**
  String get cardsSaved;

  /// No description provided for @accountAbout.
  ///
  /// In en, this message translates to:
  /// **'About FieldQuire'**
  String get accountAbout;

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance and time'**
  String get appearanceTitle;

  /// No description provided for @appearanceHint.
  ///
  /// In en, this message translates to:
  /// **'Saved with your account, so they follow you to any device.'**
  String get appearanceHint;

  /// No description provided for @appearanceLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device only: the server could not be reached.'**
  String get appearanceLocalOnly;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out with changes not sent?'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change has not reached the server yet.} other{{count} changes have not reached the server yet.}} On the web they are lost when you sign out.'**
  String signOutConfirmBody(int count);

  /// No description provided for @alertsFilterOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get alertsFilterOpen;

  /// No description provided for @alertsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get alertsFilterAll;

  /// No description provided for @paramsRejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject {name}?'**
  String paramsRejectTitle(String name);

  /// No description provided for @paramsRejectBody.
  ///
  /// In en, this message translates to:
  /// **'Collectors can no longer pick it. Readings already taken keep their values.'**
  String get paramsRejectBody;

  /// No description provided for @adminArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get adminArchived;

  /// No description provided for @adminArchivedHint.
  ///
  /// In en, this message translates to:
  /// **'Devices, collectors, sources and tests that were archived; restore them here'**
  String get adminArchivedHint;

  /// No description provided for @archiveAction.
  ///
  /// In en, this message translates to:
  /// **'Archive…'**
  String get archiveAction;

  /// No description provided for @archiveSource.
  ///
  /// In en, this message translates to:
  /// **'Archive this source'**
  String get archiveSource;

  /// No description provided for @archiveTest.
  ///
  /// In en, this message translates to:
  /// **'Archive this test'**
  String get archiveTest;

  /// No description provided for @archivedTag.
  ///
  /// In en, this message translates to:
  /// **'archived'**
  String get archivedTag;

  /// No description provided for @archiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive {label}?'**
  String archiveTitle(String label);

  /// No description provided for @archiveCascade.
  ///
  /// In en, this message translates to:
  /// **'{entity, select, installation{The device is revoked, and its collectors, their tests and the sources only they used are archived too.} collector{Their tests and the sources only they used are archived too. Sources others have tested stay.} water_source{Its tests and alerts are archived too.} test_session{Its results and alerts are archived too.} other{Related records are archived too.}}'**
  String archiveCascade(String entity);

  /// No description provided for @archiveRestorable.
  ///
  /// In en, this message translates to:
  /// **'Archived records disappear from lists, maps, dashboards, reports and devices. Nothing is deleted: Admin › Archived can restore them.'**
  String get archiveRestorable;

  /// No description provided for @archiveReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get archiveReason;

  /// No description provided for @archiveReasonHint.
  ///
  /// In en, this message translates to:
  /// **'At least 5 characters, e.g. \"test data\"'**
  String get archiveReasonHint;

  /// No description provided for @archiveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveConfirm;

  /// No description provided for @archiveDone.
  ///
  /// In en, this message translates to:
  /// **'Archived: {counts}'**
  String archiveDone(String counts);

  /// No description provided for @archiveUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get archiveUndo;

  /// No description provided for @archiveAlready.
  ///
  /// In en, this message translates to:
  /// **'This is already archived.'**
  String get archiveAlready;

  /// No description provided for @archiveCount.
  ///
  /// In en, this message translates to:
  /// **'{n} {entity, select, installation{phone} collector{collector} water_source{source} test_session{test} alert{alert} other{{entity}}}{n, plural, =1{} other{s}}'**
  String archiveCount(String entity, int n);

  /// No description provided for @archiveEntity.
  ///
  /// In en, this message translates to:
  /// **'{entity, select, installation{Phone} collector{Collector} water_source{Source} test_session{Test} other{{entity}}}'**
  String archiveEntity(String entity);

  /// No description provided for @archiveBy.
  ///
  /// In en, this message translates to:
  /// **'Archived by {name}, {when}'**
  String archiveBy(String name, String when);

  /// No description provided for @archiveListTitle.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archiveListTitle;

  /// No description provided for @archiveListHint.
  ///
  /// In en, this message translates to:
  /// **'Each line is one archive action and everything it took with it. Restoring brings all of it back.'**
  String get archiveListHint;

  /// No description provided for @archiveListNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing is archived.'**
  String get archiveListNone;

  /// No description provided for @archiveRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get archiveRestore;

  /// No description provided for @archiveRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore {label}?'**
  String archiveRestoreTitle(String label);

  /// No description provided for @archiveRestoreBody.
  ///
  /// In en, this message translates to:
  /// **'Everything this action archived comes back to lists, dashboards, reports and devices.'**
  String get archiveRestoreBody;

  /// No description provided for @archiveRestorePhone.
  ///
  /// In en, this message translates to:
  /// **'Its records come back. The device itself stays revoked.'**
  String get archiveRestorePhone;

  /// No description provided for @archiveRestored.
  ///
  /// In en, this message translates to:
  /// **'Restored'**
  String get archiveRestored;

  /// No description provided for @moreActions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get moreActions;

  /// No description provided for @phonesName.
  ///
  /// In en, this message translates to:
  /// **'Name this device'**
  String get phonesName;

  /// No description provided for @phonesNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Health centre tablet'**
  String get phonesNameHint;

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

  /// No description provided for @trailChange.
  ///
  /// In en, this message translates to:
  /// **'{field}: {before} → {after}'**
  String trailChange(String field, String before, String after);

  /// No description provided for @trailField.
  ///
  /// In en, this message translates to:
  /// **'{field, select, name{Name} households_served{Households} functional_status{Working} is_active{In use} source_type{Type} lat{Latitude} lon{Longitude} location_accuracy_m{GPS accuracy} label{Device name} full_name{Full name} phone{Phone} collector_type{Role} village{Village} parish{Parish} subcounty{Sub-county} district{District} organisation{Organisation} overall{Result} other{{field}}}'**
  String trailField(String field);

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @kpiTestedListHint.
  ///
  /// In en, this message translates to:
  /// **'Every source, latest test first. Tap one to open it.'**
  String get kpiTestedListHint;

  /// No description provided for @kpiUnsafeListHint.
  ///
  /// In en, this message translates to:
  /// **'Unsafe tests in the period, newest first. Tap one to open its source.'**
  String get kpiUnsafeListHint;

  /// No description provided for @kpiOpenAlertsListHint.
  ///
  /// In en, this message translates to:
  /// **'Alerts not closed yet. Tap one to open it.'**
  String get kpiOpenAlertsListHint;

  /// No description provided for @kpiWaitingAckListHint.
  ///
  /// In en, this message translates to:
  /// **'Alerts still waiting to be acknowledged, oldest first.'**
  String get kpiWaitingAckListHint;

  /// No description provided for @kpiOverdueListHint.
  ///
  /// In en, this message translates to:
  /// **'Sources whose next test is overdue. Tap one to open it.'**
  String get kpiOverdueListHint;

  /// No description provided for @kpiCollectorListHint.
  ///
  /// In en, this message translates to:
  /// **'Their tests in the period, newest first.'**
  String get kpiCollectorListHint;

  /// No description provided for @kpiNotTestedInPeriod.
  ///
  /// In en, this message translates to:
  /// **'Not tested in the period (last {when})'**
  String kpiNotTestedInPeriod(String when);

  /// No description provided for @kpiListAfterSync.
  ///
  /// In en, this message translates to:
  /// **'The list appears once this device has finished its first sync.'**
  String get kpiListAfterSync;

  /// No description provided for @kpiListEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to show for this period.'**
  String get kpiListEmpty;

  /// No description provided for @kpiListClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get kpiListClose;

  /// No description provided for @pinSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip: no PIN on this device'**
  String get pinSkip;

  /// No description provided for @lockTitle.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get lockTitle;

  /// No description provided for @lockSwitch.
  ///
  /// In en, this message translates to:
  /// **'Ask for a PIN on this device'**
  String get lockSwitch;

  /// No description provided for @lockHint.
  ///
  /// In en, this message translates to:
  /// **'Optional. Turn it off on an office computer shared with colleagues; anyone using this device then sees your areas.'**
  String get lockHint;

  /// No description provided for @lockAdminRequired.
  ///
  /// In en, this message translates to:
  /// **'Required for IT admins, who can change people, devices and records.'**
  String get lockAdminRequired;

  /// No description provided for @lockOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn off the PIN?'**
  String get lockOffTitle;

  /// No description provided for @lockOffBody.
  ///
  /// In en, this message translates to:
  /// **'FieldQuire will open on this device without a PIN, and stay open when no one is using it. Sign out when you leave a shared computer.'**
  String get lockOffBody;

  /// No description provided for @lockOffConfirm.
  ///
  /// In en, this message translates to:
  /// **'Turn off'**
  String get lockOffConfirm;

  /// No description provided for @recoveryAction.
  ///
  /// In en, this message translates to:
  /// **'Sign-in code for another device'**
  String get recoveryAction;

  /// No description provided for @recoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Code for {name}'**
  String recoveryTitle(String name);

  /// No description provided for @recoveryHow.
  ///
  /// In en, this message translates to:
  /// **'Give this code to the collector (call or text them). In FieldQuire Collect on any phone: \"Who is testing?\" › \"I already have a profile\" › enter the code. They come back as the same person, with their details. The code works once.'**
  String get recoveryHow;

  /// No description provided for @recoveryValid.
  ///
  /// In en, this message translates to:
  /// **'Valid until {when}.'**
  String recoveryValid(String when);

  /// No description provided for @recoveryCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get recoveryCopy;

  /// No description provided for @recoveryNotYours.
  ///
  /// In en, this message translates to:
  /// **'This collector does not work in your areas. Ask the IT admin.'**
  String get recoveryNotYours;

  /// No description provided for @showOnMap.
  ///
  /// In en, this message translates to:
  /// **'Show on map'**
  String get showOnMap;

  /// No description provided for @deviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get deviceTitle;

  /// No description provided for @deviceActivated.
  ///
  /// In en, this message translates to:
  /// **'Activated {when}'**
  String deviceActivated(String when);

  /// No description provided for @deviceCollectors.
  ///
  /// In en, this message translates to:
  /// **'Collectors and testers on this device'**
  String get deviceCollectors;

  /// No description provided for @deviceCollectorsHint.
  ///
  /// In en, this message translates to:
  /// **'From what they sent. Someone added on the device who has not sent anything yet is not known here.'**
  String get deviceCollectorsHint;

  /// No description provided for @deviceNoCollectors.
  ///
  /// In en, this message translates to:
  /// **'Nobody has sent anything from this device yet.'**
  String get deviceNoCollectors;

  /// No description provided for @deviceCollectorWork.
  ///
  /// In en, this message translates to:
  /// **'{tests, plural, =1{1 test} other{{tests} tests}}, {sources, plural, =1{1 source} other{{sources} sources}}'**
  String deviceCollectorWork(int tests, int sources);

  /// No description provided for @deviceRecoveredHere.
  ///
  /// In en, this message translates to:
  /// **'came back here with a code'**
  String get deviceRecoveredHere;

  /// No description provided for @collectorShowArea.
  ///
  /// In en, this message translates to:
  /// **'Their area on the map'**
  String get collectorShowArea;

  /// No description provided for @collectorSources.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Sources added} =1{1 source added} other{{count} sources added}}'**
  String collectorSources(int count);

  /// No description provided for @collectorNoSources.
  ///
  /// In en, this message translates to:
  /// **'No source added by them on record here.'**
  String get collectorNoSources;

  /// No description provided for @collectorTests.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Tests} =1{1 test} other{{count} tests}}'**
  String collectorTests(int count);

  /// No description provided for @collectorNoTests.
  ///
  /// In en, this message translates to:
  /// **'No test by them in your areas yet.'**
  String get collectorNoTests;

  /// No description provided for @testDistance.
  ///
  /// In en, this message translates to:
  /// **'{metres} m from the source'**
  String testDistance(int metres);

  /// No description provided for @testAwayReason.
  ///
  /// In en, this message translates to:
  /// **'away: {reason}'**
  String testAwayReason(String reason);

  /// No description provided for @placesAssign.
  ///
  /// In en, this message translates to:
  /// **'Who covers it'**
  String get placesAssign;

  /// No description provided for @placesNewTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Added from devices} =1{1 place added from devices} other{{count} places added from devices}}'**
  String placesNewTitle(int count);

  /// No description provided for @placesNewHint.
  ///
  /// In en, this message translates to:
  /// **'Collectors typed these because they were not in the list. Accept them, fix their names, or look at them on the map.'**
  String get placesNewHint;

  /// No description provided for @placesNewNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing waiting.'**
  String get placesNewNone;

  /// No description provided for @placesNewBy.
  ///
  /// In en, this message translates to:
  /// **'added by {name}'**
  String placesNewBy(String name);

  /// No description provided for @placesAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept into the list'**
  String get placesAccept;

  /// No description provided for @placesAccepted.
  ///
  /// In en, this message translates to:
  /// **'{name} is now in the list.'**
  String placesAccepted(String name);

  /// No description provided for @paramsFirstAt.
  ///
  /// In en, this message translates to:
  /// **'First used at {source}: {value}'**
  String paramsFirstAt(String source, String value);

  /// No description provided for @paramsOpenSource.
  ///
  /// In en, this message translates to:
  /// **'The source and its test'**
  String get paramsOpenSource;

  /// No description provided for @paramsOpenCollector.
  ///
  /// In en, this message translates to:
  /// **'The collector'**
  String get paramsOpenCollector;

  /// No description provided for @chainAddExisting.
  ///
  /// In en, this message translates to:
  /// **'An existing person'**
  String get chainAddExisting;

  /// No description provided for @chainAddStakeholder.
  ///
  /// In en, this message translates to:
  /// **'A new stakeholder'**
  String get chainAddStakeholder;

  /// No description provided for @chainAddCollector.
  ///
  /// In en, this message translates to:
  /// **'A tester for this area (assignment code)'**
  String get chainAddCollector;

  /// No description provided for @chainNoCandidates.
  ///
  /// In en, this message translates to:
  /// **'Everyone active already covers this area.'**
  String get chainNoCandidates;

  /// No description provided for @chainAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} now covers {area}.'**
  String chainAdded(String name, String area);

  /// No description provided for @ledgerTitle.
  ///
  /// In en, this message translates to:
  /// **'Codes and accounts'**
  String get ledgerTitle;

  /// No description provided for @ledgerMenuHint.
  ///
  /// In en, this message translates to:
  /// **'Every assignment code and account made, and who used them'**
  String get ledgerMenuHint;

  /// No description provided for @ledgerHint.
  ///
  /// In en, this message translates to:
  /// **'Made by whom, for which area, and how each was used. The codes and passwords themselves are never kept.'**
  String get ledgerHint;

  /// No description provided for @ledgerCodes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 assignment code} other{{count} assignment codes}}'**
  String ledgerCodes(int count);

  /// No description provided for @ledgerAccounts.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 account} other{{count} accounts}}'**
  String ledgerAccounts(int count);

  /// No description provided for @ledgerMadeBy.
  ///
  /// In en, this message translates to:
  /// **'made by {name}, {when}'**
  String ledgerMadeBy(String name, String when);

  /// No description provided for @ledgerWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'withdrawn {when}'**
  String ledgerWithdrawn(String when);

  /// No description provided for @ledgerExpired.
  ///
  /// In en, this message translates to:
  /// **'expired'**
  String get ledgerExpired;

  /// No description provided for @ledgerUsedUp.
  ///
  /// In en, this message translates to:
  /// **'used up'**
  String get ledgerUsedUp;

  /// No description provided for @ledgerNoDevices.
  ///
  /// In en, this message translates to:
  /// **'No tester has used this code yet.'**
  String get ledgerNoDevices;

  /// No description provided for @ledgerWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw this code'**
  String get ledgerWithdraw;

  /// No description provided for @ledgerNotUsed.
  ///
  /// In en, this message translates to:
  /// **'not used yet (temporary password never changed)'**
  String get ledgerNotUsed;

  /// No description provided for @ledgerLastSignIn.
  ///
  /// In en, this message translates to:
  /// **'last signed in {when}'**
  String ledgerLastSignIn(String when);

  /// No description provided for @photoOpen.
  ///
  /// In en, this message translates to:
  /// **'Open picture'**
  String get photoOpen;

  /// No description provided for @testNotFound.
  ///
  /// In en, this message translates to:
  /// **'This test is not on this device yet. Sync, then try again.'**
  String get testNotFound;

  /// No description provided for @testUncalibrated.
  ///
  /// In en, this message translates to:
  /// **'tester not calibrated'**
  String get testUncalibrated;

  /// No description provided for @testIsCorrection.
  ///
  /// In en, this message translates to:
  /// **'a correction of an earlier result'**
  String get testIsCorrection;

  /// No description provided for @testReadings.
  ///
  /// In en, this message translates to:
  /// **'Readings'**
  String get testReadings;

  /// No description provided for @testDetected.
  ///
  /// In en, this message translates to:
  /// **'{value, select, true{Found} other{Not found}}'**
  String testDetected(String value);

  /// No description provided for @testAcceptable.
  ///
  /// In en, this message translates to:
  /// **'{value, select, true{Acceptable} other{Not acceptable}}'**
  String testAcceptable(String value);

  /// No description provided for @testContextTitle.
  ///
  /// In en, this message translates to:
  /// **'Where and how it was tested'**
  String get testContextTitle;

  /// No description provided for @testNoLocation.
  ///
  /// In en, this message translates to:
  /// **'No location recorded'**
  String get testNoLocation;

  /// No description provided for @testAccuracy.
  ///
  /// In en, this message translates to:
  /// **'location within {metres} m'**
  String testAccuracy(int metres);

  /// No description provided for @testFarReason.
  ///
  /// In en, this message translates to:
  /// **'away from the source because: {reason}'**
  String testFarReason(String reason);

  /// No description provided for @testNoPhoto.
  ///
  /// In en, this message translates to:
  /// **'No test picture: {reason}'**
  String testNoPhoto(String reason);

  /// No description provided for @testNoInspection.
  ///
  /// In en, this message translates to:
  /// **'Surroundings not checked'**
  String get testNoInspection;

  /// No description provided for @testInspection.
  ///
  /// In en, this message translates to:
  /// **'Surroundings checked {date}: {count, plural, =0{no risks found} =1{1 risk found} other{{count} risks found}}'**
  String testInspection(String date, int count);

  /// No description provided for @testPictures.
  ///
  /// In en, this message translates to:
  /// **'Pictures of the test'**
  String get testPictures;

  /// No description provided for @sourcePictures.
  ///
  /// In en, this message translates to:
  /// **'Pictures of the source'**
  String get sourcePictures;

  /// No description provided for @testOpen.
  ///
  /// In en, this message translates to:
  /// **'Open this test'**
  String get testOpen;

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

  /// No description provided for @typedTitle.
  ///
  /// In en, this message translates to:
  /// **'Typed list values'**
  String get typedTitle;

  /// No description provided for @typedMenuHint.
  ///
  /// In en, this message translates to:
  /// **'Source and collector types typed under \"Other\"; add them to the shared list'**
  String get typedMenuHint;

  /// No description provided for @typedHint.
  ///
  /// In en, this message translates to:
  /// **'Collectors type a value when the list has nothing that fits. It is used at once on their device. Add it here to offer it on every device after the next sync; records that already hold it keep it.'**
  String get typedHint;

  /// No description provided for @typedNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing typed under \"Other\" yet.'**
  String get typedNone;

  /// No description provided for @typedList.
  ///
  /// In en, this message translates to:
  /// **'{list, select, source_types{Source type} collector_types{Collector type} other{List}}'**
  String typedList(String list);

  /// No description provided for @typedUses.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{used once} other{used {count} times}}'**
  String typedUses(int count);

  /// No description provided for @typedFirstSeen.
  ///
  /// In en, this message translates to:
  /// **'first {date}'**
  String typedFirstSeen(String date);

  /// No description provided for @typedAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to the list'**
  String get typedAdd;

  /// No description provided for @typedAdded.
  ///
  /// In en, this message translates to:
  /// **'\"{value}\" is now in the shared list.'**
  String typedAdded(String value);

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

  /// No description provided for @messagesHint.
  ///
  /// In en, this message translates to:
  /// **'Conversations with collectors about tests, sources, collectors and areas. No SMS or email: everyone reads them in the apps.'**
  String get messagesHint;

  /// No description provided for @messagesNone.
  ///
  /// In en, this message translates to:
  /// **'No messages yet.'**
  String get messagesNone;

  /// No description provided for @messagesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No messages yet. Write to the collectors here; they read it in Collect after their next sync.'**
  String get messagesEmpty;

  /// No description provided for @messagesAbout.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, test{Test} source{Source} collector{Collector} area{Area} research{Research record} other{Thread}}'**
  String messagesAbout(String kind);

  /// No description provided for @messagesOpen.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, test{Open the test} source{Open the source} collector{Open the collector} area{Open Places} other{Open}}'**
  String messagesOpen(String kind);

  /// No description provided for @messagesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesSectionTitle;

  /// No description provided for @testerAreaTitle.
  ///
  /// In en, this message translates to:
  /// **'Area and devices'**
  String get testerAreaTitle;

  /// No description provided for @testerNotAssigned.
  ///
  /// In en, this message translates to:
  /// **'Not yet assigned to an area. Testers work anywhere without one; an assignment makes them officially responsible for an area.'**
  String get testerNotAssigned;

  /// No description provided for @testerAssign.
  ///
  /// In en, this message translates to:
  /// **'Assign to an area'**
  String get testerAssign;

  /// No description provided for @testerEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get testerEnd;

  /// No description provided for @testerByCode.
  ///
  /// In en, this message translates to:
  /// **'assigned with a code'**
  String get testerByCode;

  /// No description provided for @testerByAdmin.
  ///
  /// In en, this message translates to:
  /// **'assigned by an IT admin'**
  String get testerByAdmin;

  /// No description provided for @testerDevices.
  ///
  /// In en, this message translates to:
  /// **'Devices they use'**
  String get testerDevices;

  /// No description provided for @testerNoDevices.
  ///
  /// In en, this message translates to:
  /// **'No device has sent anything for them yet.'**
  String get testerNoDevices;

  /// No description provided for @testerDevice.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get testerDevice;

  /// No description provided for @testerVia.
  ///
  /// In en, this message translates to:
  /// **'{via, select, created{started there} admin_code{signed in with an admin\'s code} own_code{signed in with their own code} other{signed in}}'**
  String testerVia(String via);

  /// No description provided for @testerLastUsed.
  ///
  /// In en, this message translates to:
  /// **'last used {when}'**
  String testerLastUsed(String when);

  /// No description provided for @testerSignedOut.
  ///
  /// In en, this message translates to:
  /// **'signed out {when}'**
  String testerSignedOut(String when);

  /// No description provided for @testerSignIns.
  ///
  /// In en, this message translates to:
  /// **'Sign-ins on other devices'**
  String get testerSignIns;

  /// No description provided for @testerPendingCode.
  ///
  /// In en, this message translates to:
  /// **'Code to give them: {code}'**
  String testerPendingCode(String code);

  /// No description provided for @testerPendingHint.
  ///
  /// In en, this message translates to:
  /// **'They asked to sign out {count, plural, =1{1 device} other{{count} devices}}. Check it is them (by phone), then give them this code. Valid until {until}.'**
  String testerPendingHint(int count, String until);

  /// No description provided for @collectorNotAssigned.
  ///
  /// In en, this message translates to:
  /// **'not yet assigned'**
  String get collectorNotAssigned;

  /// No description provided for @deviceSelfRegistered.
  ///
  /// In en, this message translates to:
  /// **'registered itself (no area)'**
  String get deviceSelfRegistered;

  /// No description provided for @ledgerAssigned.
  ///
  /// In en, this message translates to:
  /// **'assigned {when}'**
  String ledgerAssigned(String when);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileSave;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get profileEdit;

  /// No description provided for @profileEditDetails.
  ///
  /// In en, this message translates to:
  /// **'My details'**
  String get profileEditDetails;

  /// No description provided for @profileDetails.
  ///
  /// In en, this message translates to:
  /// **'My details'**
  String get profileDetails;

  /// No description provided for @profileFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get profileFullName;

  /// No description provided for @profileOrganisation.
  ///
  /// In en, this message translates to:
  /// **'Organisation'**
  String get profileOrganisation;

  /// No description provided for @profilePosition.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get profilePosition;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profilePhone;

  /// No description provided for @profileNone.
  ///
  /// In en, this message translates to:
  /// **'Not given'**
  String get profileNone;

  /// No description provided for @profileAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get profileAdd;

  /// No description provided for @profileChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get profileChange;

  /// No description provided for @profileConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get profileConfirm;

  /// No description provided for @profileConfirmed.
  ///
  /// In en, this message translates to:
  /// **'confirmed'**
  String get profileConfirmed;

  /// No description provided for @profileNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'not confirmed'**
  String get profileNotConfirmed;

  /// No description provided for @profileChangeEmail.
  ///
  /// In en, this message translates to:
  /// **'New email'**
  String get profileChangeEmail;

  /// No description provided for @profileChangePhone.
  ///
  /// In en, this message translates to:
  /// **'New phone number'**
  String get profileChangePhone;

  /// No description provided for @profileContactHint.
  ///
  /// In en, this message translates to:
  /// **'It is saved as not confirmed until you enter the code sent to it. Until email and SMS are set up, your IT admin gives you the code. Alerts go only to confirmed contacts.'**
  String get profileContactHint;

  /// No description provided for @profileConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get profileConfirmTitle;

  /// No description provided for @profileConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Ask your IT admin for the 6-digit code (Admin › Codes to pass on). It is valid for a day.'**
  String get profileConfirmHint;

  /// No description provided for @profileCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get profileCode;

  /// No description provided for @profileBadEmail.
  ///
  /// In en, this message translates to:
  /// **'That does not look like an email address.'**
  String get profileBadEmail;

  /// No description provided for @profileBadPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a Ugandan phone number, e.g. 0772 123456.'**
  String get profileBadPhone;

  /// No description provided for @profileWrongCode.
  ///
  /// In en, this message translates to:
  /// **'That code is not right.'**
  String get profileWrongCode;

  /// No description provided for @profileCodeExpired.
  ///
  /// In en, this message translates to:
  /// **'The code has expired or had too many tries. Change it again for a new one.'**
  String get profileCodeExpired;

  /// No description provided for @profileWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'That password is not right.'**
  String get profileWrongPassword;

  /// No description provided for @profileLastAdmin.
  ///
  /// In en, this message translates to:
  /// **'You are the only IT admin: make another IT admin first.'**
  String get profileLastAdmin;

  /// No description provided for @profileAllAreas.
  ///
  /// In en, this message translates to:
  /// **'All areas (IT admin)'**
  String get profileAllAreas;

  /// No description provided for @profileAskAreas.
  ///
  /// In en, this message translates to:
  /// **'Ask for different areas'**
  String get profileAskAreas;

  /// No description provided for @profileAreasWhy.
  ///
  /// In en, this message translates to:
  /// **'Why these areas?'**
  String get profileAreasWhy;

  /// No description provided for @profileAreasReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get profileAreasReason;

  /// No description provided for @profileAreasHint.
  ///
  /// In en, this message translates to:
  /// **'Your areas decide what you see, so an IT admin approves the change.'**
  String get profileAreasHint;

  /// No description provided for @profileAreasPending.
  ///
  /// In en, this message translates to:
  /// **'Asked for: {areas}'**
  String profileAreasPending(String areas);

  /// No description provided for @profileAreasPendingSince.
  ///
  /// In en, this message translates to:
  /// **'Waiting for an IT admin since {when}'**
  String profileAreasPendingSince(String when);

  /// No description provided for @profileAreasDeclined.
  ///
  /// In en, this message translates to:
  /// **'Your last request ({areas}) was declined.'**
  String profileAreasDeclined(String areas);

  /// No description provided for @profileAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccount;

  /// No description provided for @profileSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'Appearance, time, alert channels, app lock'**
  String get profileSettingsHint;

  /// No description provided for @profileSwitch.
  ///
  /// In en, this message translates to:
  /// **'Sign in as someone else'**
  String get profileSwitch;

  /// No description provided for @profileSwitchHint.
  ///
  /// In en, this message translates to:
  /// **'Signs you out, then shows the sign-in page.'**
  String get profileSwitchHint;

  /// No description provided for @profileRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove this account from this device'**
  String get profileRemove;

  /// No description provided for @profileRemoveHint.
  ///
  /// In en, this message translates to:
  /// **'Signs out and erases what this device keeps for you (data, saved sign-in, PIN).'**
  String get profileRemoveHint;

  /// No description provided for @profileRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove from this device?'**
  String get profileRemoveTitle;

  /// No description provided for @profileRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'You are signed out and the data kept on this device is erased. Nothing on the server changes; sign in again to get it back.'**
  String get profileRemoveBody;

  /// No description provided for @profileClose.
  ///
  /// In en, this message translates to:
  /// **'Close my account'**
  String get profileClose;

  /// No description provided for @profileCloseHint.
  ///
  /// In en, this message translates to:
  /// **'For good: sign-in stops and your email and phone are erased. Records you made stay.'**
  String get profileCloseHint;

  /// No description provided for @profileCloseTitle.
  ///
  /// In en, this message translates to:
  /// **'Close your account?'**
  String get profileCloseTitle;

  /// No description provided for @profileCloseBody.
  ///
  /// In en, this message translates to:
  /// **'You will not be able to sign in again, and your contact details are erased. Alerts, notes and reviews you made stay, under your name, because the water records depend on them. An IT admin can make a new account later.'**
  String get profileCloseBody;

  /// No description provided for @profileCloseContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get profileCloseContinue;

  /// No description provided for @profileClosePassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to close your account.'**
  String get profileClosePassword;

  /// No description provided for @profilePassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get profilePassword;

  /// No description provided for @adminCodes.
  ///
  /// In en, this message translates to:
  /// **'Codes to pass on'**
  String get adminCodes;

  /// No description provided for @adminCodesHint.
  ///
  /// In en, this message translates to:
  /// **'Confirmation codes people are waiting for (contacts, signing devices out)'**
  String get adminCodesHint;

  /// No description provided for @codesTitle.
  ///
  /// In en, this message translates to:
  /// **'Codes to pass on'**
  String get codesTitle;

  /// No description provided for @codesHint.
  ///
  /// In en, this message translates to:
  /// **'Until email and SMS are set up, people confirm a new email or phone, or signing other devices out, with a code an IT admin gives them. Check it is them (call them on a number you know), then read out the code. Codes last a day.'**
  String get codesHint;

  /// No description provided for @codesNone.
  ///
  /// In en, this message translates to:
  /// **'No one is waiting for a code.'**
  String get codesNone;

  /// No description provided for @codesFor.
  ///
  /// In en, this message translates to:
  /// **'{who}: {detail}'**
  String codesFor(String who, String detail);

  /// No description provided for @codesUntil.
  ///
  /// In en, this message translates to:
  /// **'valid until {when}'**
  String codesUntil(String when);

  /// No description provided for @areaRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Area change requests'**
  String get areaRequestsTitle;

  /// No description provided for @areaRequestLine.
  ///
  /// In en, this message translates to:
  /// **'{name} asks for {areas} (now: {current})'**
  String areaRequestLine(String name, String areas, String current);

  /// No description provided for @areaRequestApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get areaRequestApprove;

  /// No description provided for @areaRequestDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get areaRequestDecline;

  /// No description provided for @mapPlaceRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get mapPlaceRename;

  /// No description provided for @mapPlaceRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename this place'**
  String get mapPlaceRenameTitle;

  /// No description provided for @mapPlaceRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get mapPlaceRemove;

  /// No description provided for @mapPlaceRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} for everyone?'**
  String mapPlaceRemoveTitle(String name);

  /// No description provided for @mapPlaceRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} removed'**
  String mapPlaceRemoved(String name);

  /// No description provided for @mapPlaceNotChanged.
  ///
  /// In en, this message translates to:
  /// **'Not changed: the server could not be reached. Try again.'**
  String get mapPlaceNotChanged;

  /// No description provided for @mapLocationHelp.
  ///
  /// In en, this message translates to:
  /// **'Your location is not available. Allow location for this site (the icon in the address bar, or the site settings) and switch location on for the device. On iPhone: Settings › Privacy & Security › Location Services › Safari Websites › While Using the App. A laptop without GPS may show an approximate place.'**
  String get mapLocationHelp;

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

  /// No description provided for @researchProjects.
  ///
  /// In en, this message translates to:
  /// **'Research projects'**
  String get researchProjects;

  /// No description provided for @researchNoProjects.
  ///
  /// In en, this message translates to:
  /// **'No research projects yet. Projects you own or help supervise appear here.'**
  String get researchNoProjects;

  /// No description provided for @researchFormsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 form} other{{count} forms}}'**
  String researchFormsCount(int count);

  /// No description provided for @researchRecordsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{no records} =1{1 record} other{{count} records}}'**
  String researchRecordsCount(int count);

  /// No description provided for @researchFormsTitle.
  ///
  /// In en, this message translates to:
  /// **'Forms'**
  String get researchFormsTitle;

  /// No description provided for @researchPointsTitle.
  ///
  /// In en, this message translates to:
  /// **'Where records were made ({count})'**
  String researchPointsTitle(int count);

  /// No description provided for @researchPublished.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get researchPublished;

  /// No description provided for @researchClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get researchClosed;

  /// No description provided for @researchDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get researchDraft;

  /// No description provided for @researchAccessOpen.
  ///
  /// In en, this message translates to:
  /// **'Any collector'**
  String get researchAccessOpen;

  /// No description provided for @researchAccessCode.
  ///
  /// In en, this message translates to:
  /// **'With a code'**
  String get researchAccessCode;

  /// No description provided for @researchAccessAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned collectors'**
  String get researchAccessAssigned;

  /// No description provided for @researchHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get researchHidden;

  /// No description provided for @researchPublic.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get researchPublic;

  /// No description provided for @researchShared.
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get researchShared;

  /// No description provided for @researchPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get researchPrivate;

  /// No description provided for @researchRecords.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get researchRecords;

  /// No description provided for @researchSearchNumber.
  ///
  /// In en, this message translates to:
  /// **'Search by research number'**
  String get researchSearchNumber;

  /// No description provided for @researchNoLocation.
  ///
  /// In en, this message translates to:
  /// **'No location'**
  String get researchNoLocation;

  /// No description provided for @researchDeclinedShort.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get researchDeclinedShort;

  /// No description provided for @researchClash.
  ///
  /// In en, this message translates to:
  /// **'Number used twice: check with the collector'**
  String get researchClash;

  /// No description provided for @researchMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get researchMore;

  /// No description provided for @researchRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Record {number}'**
  String researchRecordTitle(String number);

  /// No description provided for @researchMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String researchMinutes(int minutes);

  /// No description provided for @researchPointAt.
  ///
  /// In en, this message translates to:
  /// **'Location: {point} (±{metres} m)'**
  String researchPointAt(String point, String metres);

  /// No description provided for @researchErrCodeTaken.
  ///
  /// In en, this message translates to:
  /// **'That code is already used. Choose another.'**
  String get researchErrCodeTaken;

  /// No description provided for @researchErrNoUser.
  ///
  /// In en, this message translates to:
  /// **'No active account signs in with that email.'**
  String get researchErrNoUser;

  /// No description provided for @researchErrNothingToPublish.
  ///
  /// In en, this message translates to:
  /// **'There are no changes to publish.'**
  String get researchErrNothingToPublish;

  /// No description provided for @researchErrNoFields.
  ///
  /// In en, this message translates to:
  /// **'Add at least one question before publishing.'**
  String get researchErrNoFields;

  /// No description provided for @researchErrAnalyst.
  ///
  /// In en, this message translates to:
  /// **'Analysts can read and analyse, not change the project.'**
  String get researchErrAnalyst;

  /// No description provided for @researchErrOwnerOnly.
  ///
  /// In en, this message translates to:
  /// **'Only the project\'s owner can do this.'**
  String get researchErrOwnerOnly;

  /// No description provided for @researchErrNothingToClone.
  ///
  /// In en, this message translates to:
  /// **'This form has nothing to copy yet.'**
  String get researchErrNothingToClone;

  /// No description provided for @researchErrInvalid.
  ///
  /// In en, this message translates to:
  /// **'The form could not be read. Check it and try again.'**
  String get researchErrInvalid;

  /// No description provided for @researchErrOffline.
  ///
  /// In en, this message translates to:
  /// **'No connection. Try again when online.'**
  String get researchErrOffline;

  /// No description provided for @researchErrOther.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong ({code}). Try again.'**
  String researchErrOther(String code);

  /// No description provided for @researchAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Research'**
  String get researchAppTitle;

  /// No description provided for @researchProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get researchProject;

  /// No description provided for @researchNoProjectYet.
  ///
  /// In en, this message translates to:
  /// **'No project yet'**
  String get researchNoProjectYet;

  /// No description provided for @researchNewProject.
  ///
  /// In en, this message translates to:
  /// **'New project'**
  String get researchNewProject;

  /// No description provided for @researchTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get researchTitle;

  /// No description provided for @researchDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get researchDescription;

  /// No description provided for @researchRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get researchRequired;

  /// No description provided for @researchProjectCode.
  ///
  /// In en, this message translates to:
  /// **'Project code'**
  String get researchProjectCode;

  /// No description provided for @researchProjectCodeHint.
  ///
  /// In en, this message translates to:
  /// **'2 to 8 letters or digits, e.g. ENT. It starts every research number (ENT-HQ-…) and cannot be changed later.'**
  String get researchProjectCodeHint;

  /// No description provided for @researchProjectCodeRule.
  ///
  /// In en, this message translates to:
  /// **'Use 2 to 8 letters or digits'**
  String get researchProjectCodeRule;

  /// No description provided for @researchCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get researchCreate;

  /// No description provided for @researchDashboardHint.
  ///
  /// In en, this message translates to:
  /// **'Your research project at a glance: records, forms, collectors and where records were made.'**
  String get researchDashboardHint;

  /// No description provided for @researchOwnerRole.
  ///
  /// In en, this message translates to:
  /// **'Owner: {owner} · You: {role}'**
  String researchOwnerRole(String owner, String role);

  /// No description provided for @researchTeam.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Team (1)} other{Team ({count})}}'**
  String researchTeam(int count);

  /// No description provided for @researchKpiRecords.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get researchKpiRecords;

  /// No description provided for @researchKpiToday.
  ///
  /// In en, this message translates to:
  /// **'{count} made today'**
  String researchKpiToday(int count);

  /// No description provided for @researchKpiForms.
  ///
  /// In en, this message translates to:
  /// **'Published forms'**
  String get researchKpiForms;

  /// No description provided for @researchKpiFormsHint.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 form in all} other{{count} forms in all}}'**
  String researchKpiFormsHint(int count);

  /// No description provided for @researchKpiCollectors.
  ///
  /// In en, this message translates to:
  /// **'Collectors'**
  String get researchKpiCollectors;

  /// No description provided for @researchKpiCollectorsHint.
  ///
  /// In en, this message translates to:
  /// **'{count} with records'**
  String researchKpiCollectorsHint(int count);

  /// No description provided for @researchKpiMessages.
  ///
  /// In en, this message translates to:
  /// **'Awaiting an answer'**
  String get researchKpiMessages;

  /// No description provided for @researchKpiMessagesHint.
  ///
  /// In en, this message translates to:
  /// **'Messages from collectors'**
  String get researchKpiMessagesHint;

  /// No description provided for @researchPointsHint.
  ///
  /// In en, this message translates to:
  /// **'Research numbers only, never names. Tap a point to open its record.'**
  String get researchPointsHint;

  /// No description provided for @researchOpenMap.
  ///
  /// In en, this message translates to:
  /// **'Open the map'**
  String get researchOpenMap;

  /// No description provided for @researchLatestRecords.
  ///
  /// In en, this message translates to:
  /// **'Latest records'**
  String get researchLatestRecords;

  /// No description provided for @researchSeeAllRecords.
  ///
  /// In en, this message translates to:
  /// **'All records'**
  String get researchSeeAllRecords;

  /// No description provided for @researchNoRecordsYet.
  ///
  /// In en, this message translates to:
  /// **'No records yet.'**
  String get researchNoRecordsYet;

  /// No description provided for @researchNoCollectorsYet.
  ///
  /// In en, this message translates to:
  /// **'No collectors yet. Give a form to testers, or share its access code.'**
  String get researchNoCollectorsYet;

  /// No description provided for @researchLastAt.
  ///
  /// In en, this message translates to:
  /// **'last {when}'**
  String researchLastAt(String when);

  /// No description provided for @researchRoleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get researchRoleOwner;

  /// No description provided for @researchRoleSupervisor.
  ///
  /// In en, this message translates to:
  /// **'Supervisor'**
  String get researchRoleSupervisor;

  /// No description provided for @researchRoleAnalyst.
  ///
  /// In en, this message translates to:
  /// **'Analyst'**
  String get researchRoleAnalyst;

  /// No description provided for @researchRoleSupervisorHint.
  ///
  /// In en, this message translates to:
  /// **'Builds and publishes forms, manages collectors, sees all records.'**
  String get researchRoleSupervisorHint;

  /// No description provided for @researchRoleAnalystHint.
  ///
  /// In en, this message translates to:
  /// **'Sees all records and analysis; changes nothing.'**
  String get researchRoleAnalystHint;

  /// No description provided for @researchWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Start your research'**
  String get researchWelcomeTitle;

  /// No description provided for @researchWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Create a project, then build its forms here in the Console (or import an XLSForm, or copy one from the library). Publish a form and give it to collectors: they fill it in Collect, offline, and every record keeps where and when it was made.'**
  String get researchWelcomeBody;

  /// No description provided for @researchLibrary.
  ///
  /// In en, this message translates to:
  /// **'Form library'**
  String get researchLibrary;

  /// No description provided for @researchTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'Project and team'**
  String get researchTeamTitle;

  /// No description provided for @researchTeamHint.
  ///
  /// In en, this message translates to:
  /// **'Supervisors build forms and manage collectors; analysts read and analyse. People are added by the email they sign in with.'**
  String get researchTeamHint;

  /// No description provided for @researchEditProject.
  ///
  /// In en, this message translates to:
  /// **'Edit the project'**
  String get researchEditProject;

  /// No description provided for @researchRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get researchRemove;

  /// No description provided for @researchRemoveMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove from the project?'**
  String get researchRemoveMemberTitle;

  /// No description provided for @researchRemoveMemberBody.
  ///
  /// In en, this message translates to:
  /// **'{name} will no longer see the project or its records.'**
  String researchRemoveMemberBody(String name);

  /// No description provided for @researchAddMember.
  ///
  /// In en, this message translates to:
  /// **'Add a person'**
  String get researchAddMember;

  /// No description provided for @researchMemberEmail.
  ///
  /// In en, this message translates to:
  /// **'Their sign-in email'**
  String get researchMemberEmail;

  /// No description provided for @researchMemberEmailHint.
  ///
  /// In en, this message translates to:
  /// **'They need a Console account. An IT admin can make one.'**
  String get researchMemberEmailHint;

  /// No description provided for @researchAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get researchAdd;

  /// No description provided for @researchSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get researchSave;

  /// No description provided for @researchSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get researchSaved;

  /// No description provided for @researchAllForms.
  ///
  /// In en, this message translates to:
  /// **'All forms'**
  String get researchAllForms;

  /// No description provided for @researchAllCollectors.
  ///
  /// In en, this message translates to:
  /// **'All collectors'**
  String get researchAllCollectors;

  /// No description provided for @researchCollectedBy.
  ///
  /// In en, this message translates to:
  /// **'Collected by'**
  String get researchCollectedBy;

  /// No description provided for @researchTook.
  ///
  /// In en, this message translates to:
  /// **'took {duration}'**
  String researchTook(String duration);

  /// No description provided for @researchStarted.
  ///
  /// In en, this message translates to:
  /// **'started'**
  String get researchStarted;

  /// No description provided for @researchFinishedAt.
  ///
  /// In en, this message translates to:
  /// **'Finished at {point}'**
  String researchFinishedAt(String point);

  /// No description provided for @researchAnswers.
  ///
  /// In en, this message translates to:
  /// **'Answers'**
  String get researchAnswers;

  /// No description provided for @researchMessagesHint.
  ///
  /// In en, this message translates to:
  /// **'Talk with the collector about this record. They see it in Collect with their next sync.'**
  String get researchMessagesHint;

  /// No description provided for @researchMessagesListHint.
  ///
  /// In en, this message translates to:
  /// **'Conversations with collectors about records in this project.'**
  String get researchMessagesListHint;

  /// No description provided for @researchNeedsAnswer.
  ///
  /// In en, this message translates to:
  /// **'needs an answer'**
  String get researchNeedsAnswer;

  /// No description provided for @researchAwaiting.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 record awaits an answer} other{{count} records await an answer}}'**
  String researchAwaiting(int count);

  /// No description provided for @researchFormsHint.
  ///
  /// In en, this message translates to:
  /// **'Build forms here, publish them, and choose who collects with them and who may copy them.'**
  String get researchFormsHint;

  /// No description provided for @researchNewForm.
  ///
  /// In en, this message translates to:
  /// **'New form'**
  String get researchNewForm;

  /// No description provided for @researchImportXlsForm.
  ///
  /// In en, this message translates to:
  /// **'Import XLSForm'**
  String get researchImportXlsForm;

  /// No description provided for @researchNoForms.
  ///
  /// In en, this message translates to:
  /// **'No forms yet. Start a new form, import an XLSForm, or copy one from the library.'**
  String get researchNoForms;

  /// No description provided for @researchVersion.
  ///
  /// In en, this message translates to:
  /// **'version {number}'**
  String researchVersion(int number);

  /// No description provided for @researchUnpublishedChanges.
  ///
  /// In en, this message translates to:
  /// **'unpublished changes'**
  String get researchUnpublishedChanges;

  /// No description provided for @researchImportFailed.
  ///
  /// In en, this message translates to:
  /// **'That file could not be read as an XLSForm: {reason}'**
  String researchImportFailed(String reason);

  /// No description provided for @researchImportWarnings.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 row could not be imported} other{{count} rows could not be imported}}'**
  String researchImportWarnings(int count);

  /// No description provided for @researchImportAnyway.
  ///
  /// In en, this message translates to:
  /// **'Import the rest'**
  String get researchImportAnyway;

  /// No description provided for @researchFormCode.
  ///
  /// In en, this message translates to:
  /// **'Form code'**
  String get researchFormCode;

  /// No description provided for @researchFormCodeHint.
  ///
  /// In en, this message translates to:
  /// **'1 to 6 letters or digits, e.g. HQ. It is part of the research numbers (ENT-HQ-…).'**
  String get researchFormCodeHint;

  /// No description provided for @researchFormCodeRule.
  ///
  /// In en, this message translates to:
  /// **'Use 1 to 6 letters or digits'**
  String get researchFormCodeRule;

  /// No description provided for @researchLibraryHint.
  ///
  /// In en, this message translates to:
  /// **'Forms other researchers made public or shared with you. Open one to see it, then copy it into your project as a draft.'**
  String get researchLibraryHint;

  /// No description provided for @researchLibraryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No forms are shared with you yet.'**
  String get researchLibraryEmpty;

  /// No description provided for @researchFixFirst.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Fix 1 problem first (listed above the questions).} other{Fix {count} problems first (listed above the questions).}}'**
  String researchFixFirst(int count);

  /// No description provided for @researchPublishTitle.
  ///
  /// In en, this message translates to:
  /// **'Publish the form?'**
  String get researchPublishTitle;

  /// No description provided for @researchPublishFirstBody.
  ///
  /// In en, this message translates to:
  /// **'Collectors who may use it get it with their next sync.'**
  String get researchPublishFirstBody;

  /// No description provided for @researchPublishBody.
  ///
  /// In en, this message translates to:
  /// **'This becomes version {number}. Collectors get it with their next sync; records already made keep the version they were filled with.'**
  String researchPublishBody(int number);

  /// No description provided for @researchPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get researchPublish;

  /// No description provided for @researchPublishedNow.
  ///
  /// In en, this message translates to:
  /// **'Published. Collectors get it with their next sync.'**
  String get researchPublishedNow;

  /// No description provided for @researchDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard the changes?'**
  String get researchDiscardTitle;

  /// No description provided for @researchDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'The form goes back to its published version.'**
  String get researchDiscardBody;

  /// No description provided for @researchDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard changes'**
  String get researchDiscard;

  /// No description provided for @researchCopyForm.
  ///
  /// In en, this message translates to:
  /// **'Copy to my project'**
  String get researchCopyForm;

  /// No description provided for @researchExportXlsForm.
  ///
  /// In en, this message translates to:
  /// **'Download XLSForm'**
  String get researchExportXlsForm;

  /// No description provided for @researchSeeRecords.
  ///
  /// In en, this message translates to:
  /// **'See its records'**
  String get researchSeeRecords;

  /// No description provided for @researchDraftNote.
  ///
  /// In en, this message translates to:
  /// **'Changes are saved as a draft. Collectors keep the published version until you publish again.'**
  String get researchDraftNote;

  /// No description provided for @researchTabQuestions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get researchTabQuestions;

  /// No description provided for @researchTabAccess.
  ///
  /// In en, this message translates to:
  /// **'Access and sharing'**
  String get researchTabAccess;

  /// No description provided for @researchTabVersions.
  ///
  /// In en, this message translates to:
  /// **'Versions'**
  String get researchTabVersions;

  /// No description provided for @researchTabPreview.
  ///
  /// In en, this message translates to:
  /// **'Try it'**
  String get researchTabPreview;

  /// No description provided for @researchNeedProject.
  ///
  /// In en, this message translates to:
  /// **'Create a project first.'**
  String get researchNeedProject;

  /// No description provided for @researchWhoCollects.
  ///
  /// In en, this message translates to:
  /// **'Who may collect with this form'**
  String get researchWhoCollects;

  /// No description provided for @researchAccessAssignedHint.
  ///
  /// In en, this message translates to:
  /// **'Only testers you give the form to (Collectors).'**
  String get researchAccessAssignedHint;

  /// No description provided for @researchAccessCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Testers who type the form\'s access code in Collect, and those you give it to.'**
  String get researchAccessCodeHint;

  /// No description provided for @researchAccessOpenHint.
  ///
  /// In en, this message translates to:
  /// **'Any tester on Collect, unless the form is hidden.'**
  String get researchAccessOpenHint;

  /// No description provided for @researchCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Testers type this code in Collect › Research to join.'**
  String get researchCodeHint;

  /// No description provided for @researchCopyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy the code'**
  String get researchCopyCode;

  /// No description provided for @researchNewCode.
  ///
  /// In en, this message translates to:
  /// **'New code'**
  String get researchNewCode;

  /// No description provided for @researchNewCodeBody.
  ///
  /// In en, this message translates to:
  /// **'The old code stops working. Collectors who already joined keep the form.'**
  String get researchNewCodeBody;

  /// No description provided for @researchFormCollectors.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No collectors yet} =1{1 collector} other{{count} collectors}}'**
  String researchFormCollectors(int count);

  /// No description provided for @researchAssign.
  ///
  /// In en, this message translates to:
  /// **'Give the form'**
  String get researchAssign;

  /// No description provided for @researchJoinedWithCode.
  ///
  /// In en, this message translates to:
  /// **'joined with the code'**
  String get researchJoinedWithCode;

  /// No description provided for @researchAssignedByTeam.
  ///
  /// In en, this message translates to:
  /// **'given by the team'**
  String get researchAssignedByTeam;

  /// No description provided for @researchHiddenTitle.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get researchHiddenTitle;

  /// No description provided for @researchHiddenHint.
  ///
  /// In en, this message translates to:
  /// **'Not listed for browsing or the library. Collectors you gave it to still get it.'**
  String get researchHiddenHint;

  /// No description provided for @researchOpenForCollection.
  ///
  /// In en, this message translates to:
  /// **'Open for collection'**
  String get researchOpenForCollection;

  /// No description provided for @researchOpenForCollectionHint.
  ///
  /// In en, this message translates to:
  /// **'Off: collectors can no longer send new records (those made stay).'**
  String get researchOpenForCollectionHint;

  /// No description provided for @researchWhoSees.
  ///
  /// In en, this message translates to:
  /// **'Who may see and copy this form'**
  String get researchWhoSees;

  /// No description provided for @researchPrivateHint.
  ///
  /// In en, this message translates to:
  /// **'Only this project\'s team.'**
  String get researchPrivateHint;

  /// No description provided for @researchSharedHint.
  ///
  /// In en, this message translates to:
  /// **'The team, and the people you name below.'**
  String get researchSharedHint;

  /// No description provided for @researchPublicHint.
  ///
  /// In en, this message translates to:
  /// **'Any researcher on FieldQuire (never the records).'**
  String get researchPublicHint;

  /// No description provided for @researchShareWith.
  ///
  /// In en, this message translates to:
  /// **'Share with a person'**
  String get researchShareWith;

  /// No description provided for @researchAssignTitle.
  ///
  /// In en, this message translates to:
  /// **'Give {code} to testers'**
  String researchAssignTitle(String code);

  /// No description provided for @researchFindTester.
  ///
  /// In en, this message translates to:
  /// **'Find a collector'**
  String get researchFindTester;

  /// No description provided for @researchFindTesterHint.
  ///
  /// In en, this message translates to:
  /// **'By the collector code they give you (on their Collect profile), or by name or phone if they let research teams find them.'**
  String get researchFindTesterHint;

  /// No description provided for @researchDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get researchDone;

  /// No description provided for @researchVersionsHint.
  ///
  /// In en, this message translates to:
  /// **'Each publish makes a new version. Records keep the version they were filled with.'**
  String get researchVersionsHint;

  /// No description provided for @researchNotPublished.
  ///
  /// In en, this message translates to:
  /// **'Not published yet.'**
  String get researchNotPublished;

  /// No description provided for @researchPublishedOn.
  ///
  /// In en, this message translates to:
  /// **'published {when}'**
  String researchPublishedOn(String when);

  /// No description provided for @researchCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get researchCurrent;

  /// No description provided for @researchPreviewBroken.
  ///
  /// In en, this message translates to:
  /// **'The form has a problem; see the list above the questions.'**
  String get researchPreviewBroken;

  /// No description provided for @researchPreviewHint.
  ///
  /// In en, this message translates to:
  /// **'Fill the form as a collector would, to try skip logic and checks. Nothing is saved.'**
  String get researchPreviewHint;

  /// No description provided for @researchPreviewCheck.
  ///
  /// In en, this message translates to:
  /// **'Check the answers'**
  String get researchPreviewCheck;

  /// No description provided for @researchPreviewReset.
  ///
  /// In en, this message translates to:
  /// **'Start again'**
  String get researchPreviewReset;

  /// No description provided for @researchPreviewOk.
  ///
  /// In en, this message translates to:
  /// **'All answers are accepted. This is what would be saved:'**
  String get researchPreviewOk;

  /// No description provided for @researchPreviewIssues.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 answer needs attention} other{{count} answers need attention}}'**
  String researchPreviewIssues(int count);

  /// No description provided for @researchCollectorsHint.
  ///
  /// In en, this message translates to:
  /// **'Testers collecting for this project, the forms each has, and their records.'**
  String get researchCollectorsHint;

  /// No description provided for @researchGiveForm.
  ///
  /// In en, this message translates to:
  /// **'Give a form to testers'**
  String get researchGiveForm;

  /// No description provided for @researchHowCollectorsJoin.
  ///
  /// In en, this message translates to:
  /// **'How collectors get each form'**
  String get researchHowCollectorsJoin;

  /// No description provided for @researchJoinHint.
  ///
  /// In en, this message translates to:
  /// **'Open a form to change who may collect, see its access code, or give it to testers.'**
  String get researchJoinHint;

  /// No description provided for @researchCollectorsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 collector} other{{count} collectors}}'**
  String researchCollectorsCount(int count);

  /// No description provided for @researchByCode.
  ///
  /// In en, this message translates to:
  /// **'by code'**
  String get researchByCode;

  /// No description provided for @researchAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get researchAnalysis;

  /// No description provided for @researchAnalysisHint.
  ///
  /// In en, this message translates to:
  /// **'Summaries, cross-tabs, indicators against targets, the visit audit and exports, from the records of one form.'**
  String get researchAnalysisHint;

  /// No description provided for @researchForm.
  ///
  /// In en, this message translates to:
  /// **'Form'**
  String get researchForm;

  /// No description provided for @researchTabSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get researchTabSummary;

  /// No description provided for @researchTabCrossTab.
  ///
  /// In en, this message translates to:
  /// **'Cross-tab'**
  String get researchTabCrossTab;

  /// No description provided for @researchTabIndicators.
  ///
  /// In en, this message translates to:
  /// **'Indicators'**
  String get researchTabIndicators;

  /// No description provided for @researchTabAudit.
  ///
  /// In en, this message translates to:
  /// **'Visit audit'**
  String get researchTabAudit;

  /// No description provided for @researchTabExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get researchTabExport;

  /// No description provided for @researchSummaryLine.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 record} other{{count} records}} · {declined} declined'**
  String researchSummaryLine(int count, int declined);

  /// No description provided for @researchAnswered.
  ///
  /// In en, this message translates to:
  /// **'{answered} of {asked} answered'**
  String researchAnswered(int answered, int asked);

  /// No description provided for @researchStatMean.
  ///
  /// In en, this message translates to:
  /// **'Mean'**
  String get researchStatMean;

  /// No description provided for @researchStatMedian.
  ///
  /// In en, this message translates to:
  /// **'Median'**
  String get researchStatMedian;

  /// No description provided for @researchStatMin.
  ///
  /// In en, this message translates to:
  /// **'Lowest'**
  String get researchStatMin;

  /// No description provided for @researchStatMax.
  ///
  /// In en, this message translates to:
  /// **'Highest'**
  String get researchStatMax;

  /// No description provided for @researchStatTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get researchStatTotal;

  /// No description provided for @researchDateRange.
  ///
  /// In en, this message translates to:
  /// **'From {first} to {last}'**
  String researchDateRange(String first, String last);

  /// No description provided for @researchNoAnswers.
  ///
  /// In en, this message translates to:
  /// **'No answers yet.'**
  String get researchNoAnswers;

  /// No description provided for @researchMultiNote.
  ///
  /// In en, this message translates to:
  /// **'Several answers per record are possible, so shares add up to more than 100%.'**
  String get researchMultiNote;

  /// No description provided for @researchCrossTabNeeds.
  ///
  /// In en, this message translates to:
  /// **'A cross-tab needs two choice questions in the form.'**
  String get researchCrossTabNeeds;

  /// No description provided for @researchRows.
  ///
  /// In en, this message translates to:
  /// **'Rows'**
  String get researchRows;

  /// No description provided for @researchColumns.
  ///
  /// In en, this message translates to:
  /// **'Columns'**
  String get researchColumns;

  /// No description provided for @researchRowPercent.
  ///
  /// In en, this message translates to:
  /// **'Row percentages'**
  String get researchRowPercent;

  /// No description provided for @researchTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get researchTotal;

  /// No description provided for @researchCrossTabNote.
  ///
  /// In en, this message translates to:
  /// **'Declined records are left out. A choose-many answer counts once for each choice.'**
  String get researchCrossTabNote;

  /// No description provided for @researchIndicatorsHint.
  ///
  /// In en, this message translates to:
  /// **'Indicators are kept with the project: the share of records where a condition holds, against its target (as in the proposal\'s indicator table).'**
  String get researchIndicatorsHint;

  /// No description provided for @researchNoIndicators.
  ///
  /// In en, this message translates to:
  /// **'No indicators for this form yet.'**
  String get researchNoIndicators;

  /// No description provided for @researchIndicator.
  ///
  /// In en, this message translates to:
  /// **'Indicator'**
  String get researchIndicator;

  /// No description provided for @researchResult.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get researchResult;

  /// No description provided for @researchTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get researchTarget;

  /// No description provided for @researchStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get researchStatus;

  /// No description provided for @researchIndicatorBroken.
  ///
  /// In en, this message translates to:
  /// **'Check the expression'**
  String get researchIndicatorBroken;

  /// No description provided for @researchMet.
  ///
  /// In en, this message translates to:
  /// **'Met'**
  String get researchMet;

  /// No description provided for @researchNotMet.
  ///
  /// In en, this message translates to:
  /// **'Not met'**
  String get researchNotMet;

  /// No description provided for @researchNoTarget.
  ///
  /// In en, this message translates to:
  /// **'No target'**
  String get researchNoTarget;

  /// No description provided for @researchAddIndicator.
  ///
  /// In en, this message translates to:
  /// **'Add an indicator'**
  String get researchAddIndicator;

  /// No description provided for @researchIndicatorLabel.
  ///
  /// In en, this message translates to:
  /// **'What it measures'**
  String get researchIndicatorLabel;

  /// No description provided for @researchNumerator.
  ///
  /// In en, this message translates to:
  /// **'Counts records where'**
  String get researchNumerator;

  /// No description provided for @researchNumeratorHint.
  ///
  /// In en, this message translates to:
  /// **'An expression, e.g. {example}'**
  String researchNumeratorHint(String example);

  /// No description provided for @researchDenominator.
  ///
  /// In en, this message translates to:
  /// **'Out of records where (optional)'**
  String get researchDenominator;

  /// No description provided for @researchDenominatorHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty for all records that were not declined.'**
  String get researchDenominatorHint;

  /// No description provided for @researchTargetPercent.
  ///
  /// In en, this message translates to:
  /// **'Target (%)'**
  String get researchTargetPercent;

  /// No description provided for @researchAuditHint.
  ///
  /// In en, this message translates to:
  /// **'Where and when each record was made, and how long it took, per collector. Flags are prompts to talk with collectors, not verdicts.'**
  String get researchAuditHint;

  /// No description provided for @auditTooFast.
  ///
  /// In en, this message translates to:
  /// **'very quick'**
  String get auditTooFast;

  /// No description provided for @auditFar.
  ///
  /// In en, this message translates to:
  /// **'far from the others'**
  String get auditFar;

  /// No description provided for @auditSamePoint.
  ///
  /// In en, this message translates to:
  /// **'several at one spot'**
  String get auditSamePoint;

  /// No description provided for @auditNoLocation.
  ///
  /// In en, this message translates to:
  /// **'no location'**
  String get auditNoLocation;

  /// No description provided for @auditMoved.
  ///
  /// In en, this message translates to:
  /// **'finished elsewhere'**
  String get auditMoved;

  /// No description provided for @auditFlagged.
  ///
  /// In en, this message translates to:
  /// **'{count} flagged'**
  String auditFlagged(int count);

  /// No description provided for @auditUsual.
  ///
  /// In en, this message translates to:
  /// **'usually {duration}'**
  String auditUsual(String duration);

  /// No description provided for @auditKm.
  ///
  /// In en, this message translates to:
  /// **'{km} km from the centre'**
  String auditKm(String km);

  /// No description provided for @auditNote.
  ///
  /// In en, this message translates to:
  /// **'Very quick: under a third of the form\'s usual time (at least 2 minutes). Far: over 5 km from the middle of all records. Several at one spot: 3 or more within 15 m by the same collector.'**
  String get auditNote;

  /// No description provided for @researchExportHint.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 record} other{{count} records}}. Repeats come as their own sheets, linked by research number.'**
  String researchExportHint(int count);

  /// No description provided for @researchExportLabels.
  ///
  /// In en, this message translates to:
  /// **'Choice labels'**
  String get researchExportLabels;

  /// No description provided for @researchExportLabelsHint.
  ///
  /// In en, this message translates to:
  /// **'\"Boiling\" rather than the code \"boiling\".'**
  String get researchExportLabelsHint;

  /// No description provided for @researchExportIdentifying.
  ///
  /// In en, this message translates to:
  /// **'Include identifying answers'**
  String get researchExportIdentifying;

  /// No description provided for @researchExportIdentifyingHint.
  ///
  /// In en, this message translates to:
  /// **'Names, phone numbers and other fields marked identifying. Off by default: research numbers stand for participants.'**
  String get researchExportIdentifyingHint;

  /// No description provided for @researchExportExcel.
  ///
  /// In en, this message translates to:
  /// **'Excel'**
  String get researchExportExcel;

  /// No description provided for @researchExportCsv.
  ///
  /// In en, this message translates to:
  /// **'CSV'**
  String get researchExportCsv;

  /// No description provided for @researchExportGeoJson.
  ///
  /// In en, this message translates to:
  /// **'GeoJSON (map)'**
  String get researchExportGeoJson;

  /// No description provided for @researchExportMedia.
  ///
  /// In en, this message translates to:
  /// **'Pictures ({count})'**
  String researchExportMedia(int count);

  /// No description provided for @researchMediaProgress.
  ///
  /// In en, this message translates to:
  /// **'Getting pictures: record {done} of {total}'**
  String researchMediaProgress(int done, int total);

  /// No description provided for @researchAdminHint.
  ///
  /// In en, this message translates to:
  /// **'IT admins see every research project. People, phones and the system are shared with water testing.'**
  String get researchAdminHint;

  /// No description provided for @researchAdminPeople.
  ///
  /// In en, this message translates to:
  /// **'People and accounts'**
  String get researchAdminPeople;

  /// No description provided for @researchAdminPhones.
  ///
  /// In en, this message translates to:
  /// **'Phones'**
  String get researchAdminPhones;

  /// No description provided for @researchAdminSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get researchAdminSecurity;

  /// No description provided for @researchAdminSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get researchAdminSystem;

  /// No description provided for @researchAdminAll.
  ///
  /// In en, this message translates to:
  /// **'All administration'**
  String get researchAdminAll;

  /// No description provided for @researchAllProjects.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 research project} other{{count} research projects}}'**
  String researchAllProjects(int count);

  /// No description provided for @fieldNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get fieldNote;

  /// No description provided for @fieldText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get fieldText;

  /// No description provided for @fieldInteger.
  ///
  /// In en, this message translates to:
  /// **'Whole number'**
  String get fieldInteger;

  /// No description provided for @fieldDecimal.
  ///
  /// In en, this message translates to:
  /// **'Decimal number'**
  String get fieldDecimal;

  /// No description provided for @fieldYesNo.
  ///
  /// In en, this message translates to:
  /// **'Yes / no'**
  String get fieldYesNo;

  /// No description provided for @fieldSelectOne.
  ///
  /// In en, this message translates to:
  /// **'Choose one'**
  String get fieldSelectOne;

  /// No description provided for @fieldSelectMany.
  ///
  /// In en, this message translates to:
  /// **'Choose many'**
  String get fieldSelectMany;

  /// No description provided for @fieldLikert.
  ///
  /// In en, this message translates to:
  /// **'Scale (Likert)'**
  String get fieldLikert;

  /// No description provided for @fieldRange.
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get fieldRange;

  /// No description provided for @fieldDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get fieldDate;

  /// No description provided for @fieldTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get fieldTime;

  /// No description provided for @fieldDateTime.
  ///
  /// In en, this message translates to:
  /// **'Date and time'**
  String get fieldDateTime;

  /// No description provided for @fieldGeopoint.
  ///
  /// In en, this message translates to:
  /// **'GPS point'**
  String get fieldGeopoint;

  /// No description provided for @fieldPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get fieldPhoto;

  /// No description provided for @fieldAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get fieldAudio;

  /// No description provided for @fieldVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get fieldVideo;

  /// No description provided for @fieldBarcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode / QR'**
  String get fieldBarcode;

  /// No description provided for @fieldCalculate.
  ///
  /// In en, this message translates to:
  /// **'Calculation'**
  String get fieldCalculate;

  /// No description provided for @fieldConsent.
  ///
  /// In en, this message translates to:
  /// **'Consent'**
  String get fieldConsent;

  /// No description provided for @fieldGroup.
  ///
  /// In en, this message translates to:
  /// **'Section'**
  String get fieldGroup;

  /// No description provided for @fieldRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat (rows)'**
  String get fieldRepeat;

  /// No description provided for @builderPickType.
  ///
  /// In en, this message translates to:
  /// **'What kind of question?'**
  String get builderPickType;

  /// No description provided for @builderOption.
  ///
  /// In en, this message translates to:
  /// **'Option {number}'**
  String builderOption(int number);

  /// No description provided for @builderSettings.
  ///
  /// In en, this message translates to:
  /// **'Form settings'**
  String get builderSettings;

  /// No description provided for @builderNumbering.
  ///
  /// In en, this message translates to:
  /// **'Research numbers'**
  String get builderNumbering;

  /// No description provided for @builderNumberingGenerated.
  ///
  /// In en, this message translates to:
  /// **'Made by the phone'**
  String get builderNumberingGenerated;

  /// No description provided for @builderNumberingTyped.
  ///
  /// In en, this message translates to:
  /// **'Typed from a list'**
  String get builderNumberingTyped;

  /// No description provided for @builderNumberingGeneratedHint.
  ///
  /// In en, this message translates to:
  /// **'Each phone makes unique numbers without a connection: project, form, phone and a count, e.g. ENT-HQ-7Q2K-0007.'**
  String get builderNumberingGeneratedHint;

  /// No description provided for @builderNumberingTypedHint.
  ///
  /// In en, this message translates to:
  /// **'Collectors type the number from the team\'s list (e.g. the sampling list). A number used twice is kept and flagged.'**
  String get builderNumberingTypedHint;

  /// No description provided for @builderNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'What the team calls the number (e.g. Household code)'**
  String get builderNumberLabel;

  /// No description provided for @builderProblems.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 problem to fix before publishing} other{{count} problems to fix before publishing}}'**
  String builderProblems(int count);

  /// No description provided for @builderQuestions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 question} other{{count} questions}}'**
  String builderQuestions(int count);

  /// No description provided for @builderAddQuestion.
  ///
  /// In en, this message translates to:
  /// **'Add a question'**
  String get builderAddQuestion;

  /// No description provided for @builderEmpty.
  ///
  /// In en, this message translates to:
  /// **'No questions yet. Add the first one; consent usually comes first.'**
  String get builderEmpty;

  /// No description provided for @builderBadgeRequired.
  ///
  /// In en, this message translates to:
  /// **'required'**
  String get builderBadgeRequired;

  /// No description provided for @builderBadgeLogic.
  ///
  /// In en, this message translates to:
  /// **'skip logic'**
  String get builderBadgeLogic;

  /// No description provided for @builderBadgeCheck.
  ///
  /// In en, this message translates to:
  /// **'check'**
  String get builderBadgeCheck;

  /// No description provided for @builderBadgeIdentifying.
  ///
  /// In en, this message translates to:
  /// **'identifying'**
  String get builderBadgeIdentifying;

  /// No description provided for @builderBadgeChoices.
  ///
  /// In en, this message translates to:
  /// **'{count} choices'**
  String builderBadgeChoices(int count);

  /// No description provided for @builderNoLabel.
  ///
  /// In en, this message translates to:
  /// **'(no wording yet)'**
  String get builderNoLabel;

  /// No description provided for @builderMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get builderMore;

  /// No description provided for @builderMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get builderMoveUp;

  /// No description provided for @builderMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get builderMoveDown;

  /// No description provided for @builderDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get builderDuplicate;

  /// No description provided for @builderDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get builderDelete;

  /// No description provided for @builderAddInRepeat.
  ///
  /// In en, this message translates to:
  /// **'Add a question to each row'**
  String get builderAddInRepeat;

  /// No description provided for @builderAddInGroup.
  ///
  /// In en, this message translates to:
  /// **'Add a question to this section'**
  String get builderAddInGroup;

  /// No description provided for @builderNameRule.
  ///
  /// In en, this message translates to:
  /// **'Letters, digits and _ only, not starting with a digit'**
  String get builderNameRule;

  /// No description provided for @builderNameUsed.
  ///
  /// In en, this message translates to:
  /// **'Another question has this name'**
  String get builderNameUsed;

  /// No description provided for @builderUnknownField.
  ///
  /// In en, this message translates to:
  /// **'No question is named \"{name}\"'**
  String builderUnknownField(String name);

  /// No description provided for @builderNeedChoices.
  ///
  /// In en, this message translates to:
  /// **'Add at least one choice'**
  String get builderNeedChoices;

  /// No description provided for @builderNeedCalculation.
  ///
  /// In en, this message translates to:
  /// **'Write the calculation'**
  String get builderNeedCalculation;

  /// No description provided for @builderNewQuestion.
  ///
  /// In en, this message translates to:
  /// **'New question'**
  String get builderNewQuestion;

  /// No description provided for @builderEditQuestion.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get builderEditQuestion;

  /// No description provided for @builderType.
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get builderType;

  /// No description provided for @builderLabel.
  ///
  /// In en, this message translates to:
  /// **'Question (as asked)'**
  String get builderLabel;

  /// No description provided for @builderName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get builderName;

  /// No description provided for @builderNameHint.
  ///
  /// In en, this message translates to:
  /// **'The column name in exports; used in skip logic as {example}.'**
  String builderNameHint(String example);

  /// No description provided for @builderHint.
  ///
  /// In en, this message translates to:
  /// **'Hint (shown under the question)'**
  String get builderHint;

  /// No description provided for @builderRequired.
  ///
  /// In en, this message translates to:
  /// **'An answer is required'**
  String get builderRequired;

  /// No description provided for @builderIdentifying.
  ///
  /// In en, this message translates to:
  /// **'Identifying'**
  String get builderIdentifying;

  /// No description provided for @builderIdentifyingHint.
  ///
  /// In en, this message translates to:
  /// **'A name, phone number…: left off maps and out of default exports.'**
  String get builderIdentifyingHint;

  /// No description provided for @builderChoices.
  ///
  /// In en, this message translates to:
  /// **'Choices'**
  String get builderChoices;

  /// No description provided for @builderLikertDefault.
  ///
  /// In en, this message translates to:
  /// **'Without choices of its own the scale is Agree / Not sure / Disagree.'**
  String get builderLikertDefault;

  /// No description provided for @builderOther.
  ///
  /// In en, this message translates to:
  /// **'Add \"Other: specify\"'**
  String get builderOther;

  /// No description provided for @builderOtherHint.
  ///
  /// In en, this message translates to:
  /// **'The collector types what the other answer is.'**
  String get builderOtherHint;

  /// No description provided for @builderMinRows.
  ///
  /// In en, this message translates to:
  /// **'Fewest rows'**
  String get builderMinRows;

  /// No description provided for @builderMaxRows.
  ///
  /// In en, this message translates to:
  /// **'Most rows'**
  String get builderMaxRows;

  /// No description provided for @builderMin.
  ///
  /// In en, this message translates to:
  /// **'Lowest accepted'**
  String get builderMin;

  /// No description provided for @builderMax.
  ///
  /// In en, this message translates to:
  /// **'Highest accepted'**
  String get builderMax;

  /// No description provided for @builderMaxSeconds.
  ///
  /// In en, this message translates to:
  /// **'Longest recording (seconds)'**
  String get builderMaxSeconds;

  /// No description provided for @builderMaxAudio.
  ///
  /// In en, this message translates to:
  /// **'At most 300 (5 minutes).'**
  String get builderMaxAudio;

  /// No description provided for @builderMaxVideo.
  ///
  /// In en, this message translates to:
  /// **'At most 60 seconds, at 480p.'**
  String get builderMaxVideo;

  /// No description provided for @builderLogic.
  ///
  /// In en, this message translates to:
  /// **'Logic'**
  String get builderLogic;

  /// No description provided for @builderLogicHint.
  ///
  /// In en, this message translates to:
  /// **'Expressions as in XLSForm, e.g. {example}. A dot (.) is this answer.'**
  String builderLogicHint(String example);

  /// No description provided for @builderRelevant.
  ///
  /// In en, this message translates to:
  /// **'Ask only when (skip logic)'**
  String get builderRelevant;

  /// No description provided for @builderRelevantHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. {example}'**
  String builderRelevantHint(String example);

  /// No description provided for @builderConstraint.
  ///
  /// In en, this message translates to:
  /// **'Accept only when (check)'**
  String get builderConstraint;

  /// No description provided for @builderConstraintHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. . >= 0 and . <= 20'**
  String get builderConstraintHint;

  /// No description provided for @builderConstraintMessage.
  ///
  /// In en, this message translates to:
  /// **'Message when not accepted'**
  String get builderConstraintMessage;

  /// No description provided for @builderDefault.
  ///
  /// In en, this message translates to:
  /// **'Default answer'**
  String get builderDefault;

  /// No description provided for @builderCalculation.
  ///
  /// In en, this message translates to:
  /// **'Calculation'**
  String get builderCalculation;

  /// No description provided for @builderCalculationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. {example}'**
  String builderCalculationHint(String example);

  /// No description provided for @builderChoiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Choice {number}'**
  String builderChoiceLabel(int number);

  /// No description provided for @builderChoiceValue.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get builderChoiceValue;

  /// No description provided for @builderAddChoice.
  ///
  /// In en, this message translates to:
  /// **'Add a choice'**
  String get builderAddChoice;

  /// No description provided for @builderDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get builderDone;

  /// No description provided for @joinAlready.
  ///
  /// In en, this message translates to:
  /// **'This account is already on that side.'**
  String get joinAlready;

  /// No description provided for @joinGo.
  ///
  /// In en, this message translates to:
  /// **'Join {side}'**
  String joinGo(String side);

  /// No description provided for @joinHow.
  ///
  /// In en, this message translates to:
  /// **'A separate {side} account is made for {email}, with the same password. It is linked to this one, so you can switch between them; each keeps its own pages, records and settings.'**
  String joinHow(String email, String side);

  /// No description provided for @joinMenu.
  ///
  /// In en, this message translates to:
  /// **'Join {side}'**
  String joinMenu(String side);

  /// No description provided for @joinPassword.
  ///
  /// In en, this message translates to:
  /// **'Your password (to confirm it is you)'**
  String get joinPassword;

  /// No description provided for @joinResearchIntro.
  ///
  /// In en, this message translates to:
  /// **'Research is where projects are planned, forms are built and published, and records from collectors are analysed and reported on.'**
  String get joinResearchIntro;

  /// No description provided for @joinTitle.
  ///
  /// In en, this message translates to:
  /// **'Join {side}'**
  String joinTitle(String side);

  /// No description provided for @joinWaterIntro.
  ///
  /// In en, this message translates to:
  /// **'Water testing is where water sources and test results are followed up, alerts are handled and reports are made.'**
  String get joinWaterIntro;

  /// No description provided for @legalTitleSide.
  ///
  /// In en, this message translates to:
  /// **'{side}: Terms of Use and Privacy Policy'**
  String legalTitleSide(String side);

  /// No description provided for @profileAdminAllSides.
  ///
  /// In en, this message translates to:
  /// **'As an IT admin you work on every side, and switch between them.'**
  String get profileAdminAllSides;

  /// No description provided for @profileLinked.
  ///
  /// In en, this message translates to:
  /// **'You have an account there too.'**
  String get profileLinked;

  /// No description provided for @profileNotJoined.
  ///
  /// In en, this message translates to:
  /// **'Not joined. Joining makes a separate, linked account.'**
  String get profileNotJoined;

  /// No description provided for @profileSideHint.
  ///
  /// In en, this message translates to:
  /// **'This account belongs to this side only; other sides have their own accounts.'**
  String get profileSideHint;

  /// No description provided for @profileSides.
  ///
  /// In en, this message translates to:
  /// **'Sides of FieldQuire'**
  String get profileSides;

  /// No description provided for @profileThisSide.
  ///
  /// In en, this message translates to:
  /// **'This account: {side}'**
  String profileThisSide(String side);

  /// No description provided for @recoveryGive.
  ///
  /// In en, this message translates to:
  /// **'Give a recovery code'**
  String get recoveryGive;

  /// No description provided for @researchCollectorAccess.
  ///
  /// In en, this message translates to:
  /// **'Getting back in'**
  String get researchCollectorAccess;

  /// No description provided for @researchCollectorAccessHint.
  ///
  /// In en, this message translates to:
  /// **'A collector who lost their phone, or uses another one, gets back in as the same person with a one-time recovery code. Pass it on in person or by phone.'**
  String get researchCollectorAccessHint;

  /// No description provided for @researchCollectorLastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen'**
  String get researchCollectorLastSeen;

  /// No description provided for @researchCollectorNoForms.
  ///
  /// In en, this message translates to:
  /// **'No forms of your projects yet.'**
  String get researchCollectorNoForms;

  /// No description provided for @researchCollectorRole.
  ///
  /// In en, this message translates to:
  /// **'Research collector'**
  String get researchCollectorRole;

  /// No description provided for @researchFindCollector.
  ///
  /// In en, this message translates to:
  /// **'Find a collector'**
  String get researchFindCollector;

  /// No description provided for @roleOnSide.
  ///
  /// In en, this message translates to:
  /// **'{side} account'**
  String roleOnSide(String side);

  /// No description provided for @signUpEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get signUpEmail;

  /// No description provided for @signUpEmailHint.
  ///
  /// In en, this message translates to:
  /// **'You sign in with it.'**
  String get signUpEmailHint;

  /// No description provided for @signUpEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get signUpEmailLabel;

  /// No description provided for @signUpFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get signUpFullName;

  /// No description provided for @signUpGo.
  ///
  /// In en, this message translates to:
  /// **'Create the account'**
  String get signUpGo;

  /// No description provided for @signUpHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get signUpHaveAccount;

  /// No description provided for @signUpLink.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get signUpLink;

  /// No description provided for @signUpName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name.'**
  String get signUpName;

  /// No description provided for @signUpOrganisation.
  ///
  /// In en, this message translates to:
  /// **'Organisation (optional)'**
  String get signUpOrganisation;

  /// No description provided for @signUpResearchIntro.
  ///
  /// In en, this message translates to:
  /// **'For researchers and their teams: start projects, build forms, give them to collectors, and analyse the records. The account works at once.'**
  String get signUpResearchIntro;

  /// No description provided for @signUpTaken.
  ///
  /// In en, this message translates to:
  /// **'An account on this side already uses that email. Sign in instead.'**
  String get signUpTaken;

  /// No description provided for @signUpTick.
  ///
  /// In en, this message translates to:
  /// **'Tick both boxes to accept the Terms of Use and the Privacy Policy.'**
  String get signUpTick;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a {side} account'**
  String signUpTitle(String side);

  /// No description provided for @signUpWaterIntro.
  ///
  /// In en, this message translates to:
  /// **'For district officers and other stakeholders: follow water sources and test results, act on alerts and make reports. The account works at once; an IT admin may add the areas you are officially responsible for.'**
  String get signUpWaterIntro;

  /// No description provided for @switchBody.
  ///
  /// In en, this message translates to:
  /// **'You will use your {side} account, with its own pages, records and settings.'**
  String switchBody(String side);

  /// No description provided for @switchGo.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get switchGo;

  /// No description provided for @switchTo.
  ///
  /// In en, this message translates to:
  /// **'Switch to {side}'**
  String switchTo(String side);

  /// No description provided for @usersWaterHint.
  ///
  /// In en, this message translates to:
  /// **'Water testing accounts and the IT admins. Research accounts are managed on the research side.'**
  String get usersWaterHint;

  /// No description provided for @usersResearchHint.
  ///
  /// In en, this message translates to:
  /// **'Research accounts and the IT admins. Water testing accounts are managed on the water side.'**
  String get usersResearchHint;

  /// No description provided for @testerAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Devices, sign-ins and codes'**
  String get testerAccessTitle;

  /// No description provided for @acceptancesTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use and Privacy Policy accepted'**
  String get acceptancesTitle;

  /// No description provided for @acceptancesNone.
  ///
  /// In en, this message translates to:
  /// **'No acceptance recorded yet.'**
  String get acceptancesNone;

  /// No description provided for @acceptancesLine.
  ///
  /// In en, this message translates to:
  /// **'{side}, version {version}'**
  String acceptancesLine(String side, int version);

  /// No description provided for @acceptancesHow.
  ///
  /// In en, this message translates to:
  /// **'{how, select, signup{when signing up} join{when joining from the other side} prompt{when asked after a change} profile{on a phone} other{{how}}}'**
  String acceptancesHow(String how);

  /// No description provided for @researchAdminLedger.
  ///
  /// In en, this message translates to:
  /// **'Accounts, sign-ins and codes'**
  String get researchAdminLedger;

  /// No description provided for @switchIntro.
  ///
  /// In en, this message translates to:
  /// **'{side} is a separate side of FieldQuire, with its own people, pages and records. Choose how to go there.'**
  String switchIntro(String side);

  /// No description provided for @switchSignIn.
  ///
  /// In en, this message translates to:
  /// **'I have a {side} account'**
  String switchSignIn(String side);

  /// No description provided for @switchSignInHint.
  ///
  /// In en, this message translates to:
  /// **'Sign in with its email and password. You leave this account first.'**
  String switchSignInHint(String side);

  /// No description provided for @switchJoin.
  ///
  /// In en, this message translates to:
  /// **'Use my details here to join {side}'**
  String switchJoin(String side);

  /// No description provided for @switchJoinHint.
  ///
  /// In en, this message translates to:
  /// **'A separate {side} account with your email and password, linked to this one, after you accept its Terms of Use and Privacy Policy.'**
  String switchJoinHint(String side);

  /// No description provided for @switchNew.
  ///
  /// In en, this message translates to:
  /// **'Create a new {side} account'**
  String switchNew(String side);

  /// No description provided for @switchNewHint.
  ///
  /// In en, this message translates to:
  /// **'With other details. You leave this account first.'**
  String switchNewHint(String side);

  /// No description provided for @searchPhones.
  ///
  /// In en, this message translates to:
  /// **'Search phones by name, area, code or app'**
  String get searchPhones;

  /// No description provided for @searchLedger.
  ///
  /// In en, this message translates to:
  /// **'Search codes and accounts'**
  String get searchLedger;

  /// No description provided for @searchCollectors.
  ///
  /// In en, this message translates to:
  /// **'Search collectors'**
  String get searchCollectors;

  /// No description provided for @searchAlerts.
  ///
  /// In en, this message translates to:
  /// **'Search alerts by source or status'**
  String get searchAlerts;

  /// No description provided for @searchArchived.
  ///
  /// In en, this message translates to:
  /// **'Search archived items'**
  String get searchArchived;

  /// No description provided for @searchCodes.
  ///
  /// In en, this message translates to:
  /// **'Search by person, code or reason'**
  String get searchCodes;

  /// No description provided for @searchMessages.
  ///
  /// In en, this message translates to:
  /// **'Search messages'**
  String get searchMessages;

  /// No description provided for @searchProjects.
  ///
  /// In en, this message translates to:
  /// **'Search projects'**
  String get searchProjects;

  /// No description provided for @searchForms.
  ///
  /// In en, this message translates to:
  /// **'Search forms by code, title or status'**
  String get searchForms;

  /// No description provided for @researchAllPublished.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get researchAllPublished;

  /// No description provided for @researchExportCsvOf.
  ///
  /// In en, this message translates to:
  /// **'CSV: {table}'**
  String researchExportCsvOf(String table);

  /// No description provided for @researchTabCharts.
  ///
  /// In en, this message translates to:
  /// **'Charts'**
  String get researchTabCharts;

  /// No description provided for @researchChartsHint.
  ///
  /// In en, this message translates to:
  /// **'Put the answers together: group the records by an answer, the day they were finished or the collector; count them or add up, average or compare a number; split each group by a second answer.'**
  String get researchChartsHint;

  /// No description provided for @researchChartGroupBy.
  ///
  /// In en, this message translates to:
  /// **'Group by'**
  String get researchChartGroupBy;

  /// No description provided for @researchChartByFinished.
  ///
  /// In en, this message translates to:
  /// **'Day finished'**
  String get researchChartByFinished;

  /// No description provided for @researchChartByCollector.
  ///
  /// In en, this message translates to:
  /// **'Collector'**
  String get researchChartByCollector;

  /// No description provided for @researchChartStep.
  ///
  /// In en, this message translates to:
  /// **'Dates by'**
  String get researchChartStep;

  /// No description provided for @researchChartDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get researchChartDay;

  /// No description provided for @researchChartWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get researchChartWeek;

  /// No description provided for @researchChartMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get researchChartMonth;

  /// No description provided for @researchChartSplit.
  ///
  /// In en, this message translates to:
  /// **'Split by'**
  String get researchChartSplit;

  /// No description provided for @researchChartNoSplit.
  ///
  /// In en, this message translates to:
  /// **'No split'**
  String get researchChartNoSplit;

  /// No description provided for @researchChartMeasure.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get researchChartMeasure;

  /// No description provided for @researchChartCount.
  ///
  /// In en, this message translates to:
  /// **'Number of records'**
  String get researchChartCount;

  /// No description provided for @researchChartSum.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get researchChartSum;

  /// No description provided for @researchChartMean.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get researchChartMean;

  /// No description provided for @researchChartMin.
  ///
  /// In en, this message translates to:
  /// **'Lowest'**
  String get researchChartMin;

  /// No description provided for @researchChartMax.
  ///
  /// In en, this message translates to:
  /// **'Highest'**
  String get researchChartMax;

  /// No description provided for @researchChartOf.
  ///
  /// In en, this message translates to:
  /// **'Of'**
  String get researchChartOf;

  /// No description provided for @researchChartBars.
  ///
  /// In en, this message translates to:
  /// **'Bars'**
  String get researchChartBars;

  /// No description provided for @researchChartHorizontal.
  ///
  /// In en, this message translates to:
  /// **'Horizontal bars'**
  String get researchChartHorizontal;

  /// No description provided for @researchChartGrouped.
  ///
  /// In en, this message translates to:
  /// **'Grouped bars'**
  String get researchChartGrouped;

  /// No description provided for @researchChartStacked.
  ///
  /// In en, this message translates to:
  /// **'Stacked bars'**
  String get researchChartStacked;

  /// No description provided for @researchChartLine.
  ///
  /// In en, this message translates to:
  /// **'Line'**
  String get researchChartLine;

  /// No description provided for @researchChartArea.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get researchChartArea;

  /// No description provided for @researchChartPie.
  ///
  /// In en, this message translates to:
  /// **'Pie'**
  String get researchChartPie;

  /// No description provided for @researchChartDonut.
  ///
  /// In en, this message translates to:
  /// **'Donut'**
  String get researchChartDonut;

  /// No description provided for @researchChartOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get researchChartOther;

  /// No description provided for @researchChartNone.
  ///
  /// In en, this message translates to:
  /// **'(no answer)'**
  String get researchChartNone;

  /// No description provided for @researchChartGroup.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get researchChartGroup;

  /// No description provided for @researchChartNothing.
  ///
  /// In en, this message translates to:
  /// **'No records to chart yet.'**
  String get researchChartNothing;

  /// No description provided for @researchChartUnits.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{From 1 record or repeat row} other{From {count} records or repeat rows}}'**
  String researchChartUnits(int count);
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
