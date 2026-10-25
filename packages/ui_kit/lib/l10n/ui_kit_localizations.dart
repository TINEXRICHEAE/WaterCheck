import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'ui_kit_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of UiKitLocalizations
/// returned by `UiKitLocalizations.of(context)`.
///
/// Applications need to include `UiKitLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/ui_kit_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: UiKitLocalizations.localizationsDelegates,
///   supportedLocales: UiKitLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the UiKitLocalizations.supportedLocales
/// property.
abstract class UiKitLocalizations {
  UiKitLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static UiKitLocalizations of(BuildContext context) {
    return Localizations.of<UiKitLocalizations>(context, UiKitLocalizations)!;
  }

  static const LocalizationsDelegate<UiKitLocalizations> delegate =
      _UiKitLocalizationsDelegate();

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

  /// Overall result: safe on the measured parameters. Shown with a tick icon.
  ///
  /// In en, this message translates to:
  /// **'SAFE'**
  String get statusSafe;

  /// Overall result: at least one reading outside the limits.
  ///
  /// In en, this message translates to:
  /// **'UNSAFE'**
  String get statusUnsafe;

  /// Overall result: a required reading is missing or invalid.
  ///
  /// In en, this message translates to:
  /// **'INCONCLUSIVE'**
  String get statusInconclusive;

  /// Source has never been tested.
  ///
  /// In en, this message translates to:
  /// **'NOT TESTED'**
  String get statusNotTested;

  /// Source test is due within a few days.
  ///
  /// In en, this message translates to:
  /// **'DUE'**
  String get statusDueSoon;

  /// Source test is past its due date.
  ///
  /// In en, this message translates to:
  /// **'OVERDUE'**
  String get statusOverdue;

  /// No description provided for @syncAllSent.
  ///
  /// In en, this message translates to:
  /// **'Everything is sent'**
  String get syncAllSent;

  /// No description provided for @syncPending.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item waiting to send} other{{count} items waiting to send}}'**
  String syncPending(int count);

  /// No description provided for @syncRejected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item was refused} other{{count} items were refused}}'**
  String syncRejected(int count);

  /// No description provided for @syncOfflineHint.
  ///
  /// In en, this message translates to:
  /// **'Saved on this phone. It will be sent when the internet returns.'**
  String get syncOfflineHint;

  /// No description provided for @syncNeverSent.
  ///
  /// In en, this message translates to:
  /// **'Not sent yet'**
  String get syncNeverSent;

  /// No description provided for @syncLastSent.
  ///
  /// In en, this message translates to:
  /// **'Last sent {when}'**
  String syncLastSent(String when);

  /// Badge on reference profiles whose values await confirmation.
  ///
  /// In en, this message translates to:
  /// **'Provisional limits'**
  String get provisionalLimits;

  /// Badge on results computed with limits edited at calibration.
  ///
  /// In en, this message translates to:
  /// **'Custom limits'**
  String get customLimits;

  /// No description provided for @refDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Reference data'**
  String get refDataTitle;

  /// No description provided for @refDataIntro.
  ///
  /// In en, this message translates to:
  /// **'Loaded on this device from the bundled seed. Works offline.'**
  String get refDataIntro;

  /// No description provided for @refParameters.
  ///
  /// In en, this message translates to:
  /// **'Parameters ({count})'**
  String refParameters(int count);

  /// No description provided for @refCore.
  ///
  /// In en, this message translates to:
  /// **'Core (always shown first)'**
  String get refCore;

  /// No description provided for @refProfiles.
  ///
  /// In en, this message translates to:
  /// **'Reference profiles ({count})'**
  String refProfiles(int count);

  /// No description provided for @refLimitCount.
  ///
  /// In en, this message translates to:
  /// **'{count} limits'**
  String refLimitCount(int count);

  /// No description provided for @refTesterProfiles.
  ///
  /// In en, this message translates to:
  /// **'Tester profiles'**
  String get refTesterProfiles;

  /// No description provided for @refAreas.
  ///
  /// In en, this message translates to:
  /// **'Areas'**
  String get refAreas;

  /// No description provided for @refRules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get refRules;

  /// No description provided for @refRequired.
  ///
  /// In en, this message translates to:
  /// **'Required: {list}'**
  String refRequired(String list);

  /// No description provided for @refSchedule.
  ///
  /// In en, this message translates to:
  /// **'Test every {routine} days; {rainy} days in the rainy season; {abnormal} days after an abnormal result'**
  String refSchedule(int routine, int rainy, int abnormal);

  /// No description provided for @refNoLimit.
  ///
  /// In en, this message translates to:
  /// **'no limit'**
  String get refNoLimit;

  /// No description provided for @refMustBeAbsent.
  ///
  /// In en, this message translates to:
  /// **'must be absent'**
  String get refMustBeAbsent;

  /// No description provided for @refMustBeAcceptable.
  ///
  /// In en, this message translates to:
  /// **'must be acceptable'**
  String get refMustBeAcceptable;

  /// No description provided for @pinEnter.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get pinEnter;

  /// No description provided for @pinChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose a PIN'**
  String get pinChoose;

  /// No description provided for @pinChooseHint.
  ///
  /// In en, this message translates to:
  /// **'4 to 8 digits. You will need it to open the app.'**
  String get pinChooseHint;

  /// No description provided for @pinConfirm.
  ///
  /// In en, this message translates to:
  /// **'Enter the same PIN again'**
  String get pinConfirm;

  /// No description provided for @pinMismatch.
  ///
  /// In en, this message translates to:
  /// **'The PINs did not match. Try again.'**
  String get pinMismatch;

  /// No description provided for @pinWrong.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Wrong PIN.} =1{Wrong PIN. 1 more try before a wait.} other{Wrong PIN. {count} more tries before a wait.}}'**
  String pinWrong(int count);

  /// No description provided for @pinWait.
  ///
  /// In en, this message translates to:
  /// **'Too many wrong PINs. Try again in {seconds} seconds.'**
  String pinWait(int seconds);

  /// No description provided for @pinOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get pinOk;

  /// No description provided for @pinDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete last digit'**
  String get pinDelete;

  /// No description provided for @pinUseBiometric.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or face'**
  String get pinUseBiometric;

  /// No description provided for @pinDigitsEntered.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No digits entered} =1{1 digit entered} other{{count} digits entered}}'**
  String pinDigitsEntered(int count);

  /// No description provided for @trendTitle.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get trendTitle;

  /// No description provided for @trendLimit.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get trendLimit;

  /// No description provided for @appLogo.
  ///
  /// In en, this message translates to:
  /// **'WaterCheck logo'**
  String get appLogo;

  /// No description provided for @passwordShow.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get passwordShow;

  /// No description provided for @passwordHide.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get passwordHide;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @errorRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get errorRetry;

  /// No description provided for @errorHome.
  ///
  /// In en, this message translates to:
  /// **'Go to the start page'**
  String get errorHome;

  /// No description provided for @errorOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get errorOfflineTitle;

  /// No description provided for @errorOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'The server cannot be reached. Check the internet connection and try again. Work saved on this device is kept.'**
  String get errorOfflineBody;

  /// No description provided for @errorTimeoutTitle.
  ///
  /// In en, this message translates to:
  /// **'This is taking too long'**
  String get errorTimeoutTitle;

  /// No description provided for @errorTimeoutBody.
  ///
  /// In en, this message translates to:
  /// **'The server did not answer in time. The connection may be slow; try again in a moment.'**
  String get errorTimeoutBody;

  /// No description provided for @errorSignedOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again'**
  String get errorSignedOutTitle;

  /// No description provided for @errorSignedOutBody.
  ///
  /// In en, this message translates to:
  /// **'Your session has ended. Sign in again to continue.'**
  String get errorSignedOutBody;

  /// No description provided for @errorForbiddenTitle.
  ///
  /// In en, this message translates to:
  /// **'Not allowed'**
  String get errorForbiddenTitle;

  /// No description provided for @errorForbiddenBody.
  ///
  /// In en, this message translates to:
  /// **'Your account does not have access to this. Ask the IT admin if you need it.'**
  String get errorForbiddenBody;

  /// No description provided for @errorNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get errorNotFoundTitle;

  /// No description provided for @errorNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'What you are looking for is not here. It may have been moved or removed.'**
  String get errorNotFoundBody;

  /// No description provided for @errorServerTitle.
  ///
  /// In en, this message translates to:
  /// **'The server had a problem'**
  String get errorServerTitle;

  /// No description provided for @errorServerBody.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on the server. Try again later; if it keeps happening, tell the IT admin.'**
  String get errorServerBody;

  /// No description provided for @errorUnknownTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorUnknownTitle;

  /// No description provided for @errorUnknownBody.
  ///
  /// In en, this message translates to:
  /// **'This could not be completed. Try again; if it keeps happening, tell the IT admin.'**
  String get errorUnknownBody;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
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

  /// No description provided for @settingsTimeZone.
  ///
  /// In en, this message translates to:
  /// **'Time zone'**
  String get settingsTimeZone;

  /// No description provided for @settingsTimeZoneNow.
  ///
  /// In en, this message translates to:
  /// **'Time now: {time}'**
  String settingsTimeZoneNow(String time);

  /// No description provided for @zoneAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic (this device\'s time zone)'**
  String get zoneAuto;

  /// No description provided for @zoneKampala.
  ///
  /// In en, this message translates to:
  /// **'East Africa Time, Kampala (UTC+3)'**
  String get zoneKampala;

  /// No description provided for @zoneNairobi.
  ///
  /// In en, this message translates to:
  /// **'East Africa Time, Nairobi (UTC+3)'**
  String get zoneNairobi;

  /// No description provided for @zoneUtc.
  ///
  /// In en, this message translates to:
  /// **'UTC'**
  String get zoneUtc;

  /// No description provided for @filtersReset.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get filtersReset;

  /// No description provided for @aboutLegalese.
  ///
  /// In en, this message translates to:
  /// **'Community drinking water monitoring. Licensed under the project licence; open-source components are listed under View licences.'**
  String get aboutLegalese;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @searchClear.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get searchClear;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @refSearch.
  ///
  /// In en, this message translates to:
  /// **'Search parameters, limits, kits and areas'**
  String get refSearch;

  /// No description provided for @refSearchClear.
  ///
  /// In en, this message translates to:
  /// **'Clear the search'**
  String get refSearchClear;

  /// No description provided for @refNoMatch.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches \"{query}\".'**
  String refNoMatch(String query);

  /// No description provided for @refAreasMore.
  ///
  /// In en, this message translates to:
  /// **'Showing {shown} of {count}. Type in the search box to narrow the list.'**
  String refAreasMore(int shown, int count);

  /// No description provided for @refOpenDetails.
  ///
  /// In en, this message translates to:
  /// **'Details and actions'**
  String get refOpenDetails;

  /// No description provided for @mapSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search a place or a source'**
  String get mapSearchHint;

  /// No description provided for @mapLayers.
  ///
  /// In en, this message translates to:
  /// **'Map layers'**
  String get mapLayers;

  /// No description provided for @mapLabels.
  ///
  /// In en, this message translates to:
  /// **'Source names'**
  String get mapLabels;

  /// No description provided for @mapStraight.
  ///
  /// In en, this message translates to:
  /// **'Straight-line distance'**
  String get mapStraight;

  /// No description provided for @mapStraightHint.
  ///
  /// In en, this message translates to:
  /// **'From where you are, as the crow flies'**
  String get mapStraightHint;

  /// No description provided for @mapRoute.
  ///
  /// In en, this message translates to:
  /// **'Route by road'**
  String get mapRoute;

  /// No description provided for @mapRouteHint.
  ///
  /// In en, this message translates to:
  /// **'To the chosen source, with distance and travel time'**
  String get mapRouteHint;

  /// No description provided for @mapVehicle.
  ///
  /// In en, this message translates to:
  /// **'Motorbike/car'**
  String get mapVehicle;

  /// No description provided for @mapWalking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get mapWalking;

  /// No description provided for @mapStraightLine.
  ///
  /// In en, this message translates to:
  /// **'{distance} straight'**
  String mapStraightLine(String distance);

  /// No description provided for @mapByRoad.
  ///
  /// In en, this message translates to:
  /// **'{distance} by road, about {time} ({mode})'**
  String mapByRoad(String distance, String time, String mode);

  /// No description provided for @mapRouteLoading.
  ///
  /// In en, this message translates to:
  /// **'finding the route…'**
  String get mapRouteLoading;

  /// No description provided for @mapRouteNone.
  ///
  /// In en, this message translates to:
  /// **'no route found (or routing is off)'**
  String get mapRouteNone;

  /// No description provided for @installApp.
  ///
  /// In en, this message translates to:
  /// **'Install app'**
  String get installApp;

  /// No description provided for @installAppHint.
  ///
  /// In en, this message translates to:
  /// **'Open WaterCheck from your home screen or app list, also offline.'**
  String get installAppHint;

  /// No description provided for @mapZoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in (R key)'**
  String get mapZoomIn;

  /// No description provided for @mapZoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out (F key)'**
  String get mapZoomOut;

  /// No description provided for @photoClose.
  ///
  /// In en, this message translates to:
  /// **'Close (Esc)'**
  String get photoClose;

  /// No description provided for @photoPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous picture (left arrow)'**
  String get photoPrevious;

  /// No description provided for @photoNext.
  ///
  /// In en, this message translates to:
  /// **'Next picture (right arrow)'**
  String get photoNext;

  /// No description provided for @photoCount.
  ///
  /// In en, this message translates to:
  /// **'Picture {at} of {total}'**
  String photoCount(int at, int total);

  /// No description provided for @photoRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove picture'**
  String get photoRemove;

  /// No description provided for @photoRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this picture?'**
  String get photoRemoveTitle;

  /// No description provided for @photoRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'It disappears from this device and, once synced, from everyone\'s view. You can add a new one after.'**
  String get photoRemoveBody;

  /// No description provided for @photoKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get photoKeep;

  /// No description provided for @photoRemoveFailed.
  ///
  /// In en, this message translates to:
  /// **'The picture could not be removed.'**
  String get photoRemoveFailed;

  /// No description provided for @photoUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This picture can\'t be shown right now (not uploaded yet, or no connection).'**
  String get photoUnavailable;

  /// No description provided for @choiceOther.
  ///
  /// In en, this message translates to:
  /// **'Other (type it)'**
  String get choiceOther;

  /// No description provided for @choiceTypedBefore.
  ///
  /// In en, this message translates to:
  /// **'{value} (typed before)'**
  String choiceTypedBefore(String value);

  /// No description provided for @choiceTypeIt.
  ///
  /// In en, this message translates to:
  /// **'Type it'**
  String get choiceTypeIt;

  /// No description provided for @choiceTypeItHint.
  ///
  /// In en, this message translates to:
  /// **'Used on this device at once; the IT admin may add it to the shared list.'**
  String get choiceTypeItHint;

  /// No description provided for @choiceRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose one, or pick Other and type it.'**
  String get choiceRequired;

  /// No description provided for @choiceTypeItRequired.
  ///
  /// In en, this message translates to:
  /// **'Type what it is.'**
  String get choiceTypeItRequired;

  /// No description provided for @conversationEmpty.
  ///
  /// In en, this message translates to:
  /// **'No messages yet. Write the first one.'**
  String get conversationEmpty;

  /// No description provided for @conversationYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get conversationYou;

  /// No description provided for @conversationFrom.
  ///
  /// In en, this message translates to:
  /// **'Message from {name}'**
  String conversationFrom(String name);

  /// No description provided for @conversationStaff.
  ///
  /// In en, this message translates to:
  /// **'Stakeholder or IT admin'**
  String get conversationStaff;

  /// No description provided for @conversationWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting to send (no connection yet)'**
  String get conversationWaiting;

  /// No description provided for @conversationWrite.
  ///
  /// In en, this message translates to:
  /// **'Write a message'**
  String get conversationWrite;

  /// No description provided for @conversationHint.
  ///
  /// In en, this message translates to:
  /// **'Enter sends; Shift+Enter for a new line. Everyone following this sees it.'**
  String get conversationHint;

  /// No description provided for @conversationSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get conversationSend;

  /// No description provided for @mapMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up (↑ or W; hold to keep moving)'**
  String get mapMoveUp;

  /// No description provided for @mapMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down (↓ or S; hold to keep moving)'**
  String get mapMoveDown;

  /// No description provided for @mapMoveLeft.
  ///
  /// In en, this message translates to:
  /// **'Move left (← or A; hold to keep moving)'**
  String get mapMoveLeft;

  /// No description provided for @mapMoveRight.
  ///
  /// In en, this message translates to:
  /// **'Move right (→ or D; hold to keep moving)'**
  String get mapMoveRight;

  /// No description provided for @legalPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalPrivacy;

  /// No description provided for @legalTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get legalTerms;

  /// No description provided for @legalVersionLine.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String legalVersionLine(int version);

  /// No description provided for @legalAccept.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Use and the Privacy Policy'**
  String get legalAccept;

  /// No description provided for @legalChanged.
  ///
  /// In en, this message translates to:
  /// **'The Privacy Policy or Terms of Use have changed. Please read them and agree again to keep using WaterCheck.'**
  String get legalChanged;

  /// No description provided for @mapPathOpen.
  ///
  /// In en, this message translates to:
  /// **'Show the whole path'**
  String get mapPathOpen;

  /// No description provided for @mapPathFold.
  ///
  /// In en, this message translates to:
  /// **'Fold the path'**
  String get mapPathFold;

  /// No description provided for @mapPathMore.
  ///
  /// In en, this message translates to:
  /// **'+{count}'**
  String mapPathMore(int count);

  /// No description provided for @mapControlsOpen.
  ///
  /// In en, this message translates to:
  /// **'Move and zoom'**
  String get mapControlsOpen;

  /// No description provided for @mapControlsFold.
  ///
  /// In en, this message translates to:
  /// **'Fold the move and zoom buttons'**
  String get mapControlsFold;

  /// No description provided for @mapMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get mapMore;

  /// No description provided for @mapLess.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get mapLess;

  /// No description provided for @tripGo.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get tripGo;

  /// No description provided for @tripGoTooltip.
  ///
  /// In en, this message translates to:
  /// **'Follow me there, live'**
  String get tripGoTooltip;

  /// No description provided for @tripStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get tripStop;

  /// No description provided for @tripDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get tripDone;

  /// No description provided for @tripTo.
  ///
  /// In en, this message translates to:
  /// **'To {name}'**
  String tripTo(String name);

  /// No description provided for @tripArrived.
  ///
  /// In en, this message translates to:
  /// **'You have arrived'**
  String get tripArrived;

  /// No description provided for @tripWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for your position…'**
  String get tripWaiting;

  /// No description provided for @tripRerouting.
  ///
  /// In en, this message translates to:
  /// **'Finding the way again…'**
  String get tripRerouting;

  /// No description provided for @tripLeft.
  ///
  /// In en, this message translates to:
  /// **'{distance} left · arrive about {time} ({duration})'**
  String tripLeft(String distance, String time, String duration);

  /// No description provided for @tripLeftNoTime.
  ///
  /// In en, this message translates to:
  /// **'{distance} left'**
  String tripLeftNoTime(String distance);

  /// No description provided for @tripFollow.
  ///
  /// In en, this message translates to:
  /// **'Follow my position'**
  String get tripFollow;

  /// No description provided for @fixSpeed.
  ///
  /// In en, this message translates to:
  /// **'{value} km/h'**
  String fixSpeed(String value);

  /// No description provided for @fixAltitude.
  ///
  /// In en, this message translates to:
  /// **'{value} m high'**
  String fixAltitude(String value);

  /// No description provided for @fixHeading.
  ///
  /// In en, this message translates to:
  /// **'heading {value}'**
  String fixHeading(String value);

  /// No description provided for @fixAccuracy.
  ///
  /// In en, this message translates to:
  /// **'±{value} m'**
  String fixAccuracy(String value);

  /// No description provided for @photoTaken.
  ///
  /// In en, this message translates to:
  /// **'Taken {when}'**
  String photoTaken(String when);

  /// No description provided for @placeAddHere.
  ///
  /// In en, this message translates to:
  /// **'Add a place here'**
  String get placeAddHere;

  /// No description provided for @placeAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a place that is not on the map'**
  String get placeAddTitle;

  /// No description provided for @placeName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get placeName;

  /// No description provided for @placeKind.
  ///
  /// In en, this message translates to:
  /// **'What is it?'**
  String get placeKind;

  /// No description provided for @placeAddExplain.
  ///
  /// In en, this message translates to:
  /// **'Everyone will find it in searches and on the map, with your name. Admins can correct it.'**
  String get placeAddExplain;

  /// No description provided for @placeAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get placeAdd;

  /// No description provided for @placeAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} added'**
  String placeAdded(String name);

  /// No description provided for @placeAddedBy.
  ///
  /// In en, this message translates to:
  /// **'Added by {name}'**
  String placeAddedBy(String name);

  /// No description provided for @placeOutside.
  ///
  /// In en, this message translates to:
  /// **'This point is not in Uganda\'s areas on this device yet. Choose a point near a known place.'**
  String get placeOutside;

  /// No description provided for @placeKindVillage.
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get placeKindVillage;

  /// No description provided for @placeKindTradingCentre.
  ///
  /// In en, this message translates to:
  /// **'Trading centre'**
  String get placeKindTradingCentre;

  /// No description provided for @placeKindSchool.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get placeKindSchool;

  /// No description provided for @placeKindHealthCentre.
  ///
  /// In en, this message translates to:
  /// **'Health centre'**
  String get placeKindHealthCentre;

  /// No description provided for @placeKindMarket.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get placeKindMarket;

  /// No description provided for @placeKindWorship.
  ///
  /// In en, this message translates to:
  /// **'Place of worship'**
  String get placeKindWorship;

  /// No description provided for @placeKindLandmark.
  ///
  /// In en, this message translates to:
  /// **'Landmark'**
  String get placeKindLandmark;

  /// No description provided for @placeKindOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get placeKindOther;

  /// No description provided for @mapSearchingOnline.
  ///
  /// In en, this message translates to:
  /// **'Searching all of Uganda…'**
  String get mapSearchingOnline;

  /// No description provided for @mapSearchNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get mapSearchNothing;

  /// No description provided for @installAppIos.
  ///
  /// In en, this message translates to:
  /// **'Add WaterCheck to your Home Screen'**
  String get installAppIos;

  /// No description provided for @installAppIosHint.
  ///
  /// In en, this message translates to:
  /// **'In Safari, tap Share, then Add to Home Screen. WaterCheck then opens like an app, full screen.'**
  String get installAppIosHint;
}

class _UiKitLocalizationsDelegate
    extends LocalizationsDelegate<UiKitLocalizations> {
  const _UiKitLocalizationsDelegate();

  @override
  Future<UiKitLocalizations> load(Locale locale) {
    return SynchronousFuture<UiKitLocalizations>(
      lookupUiKitLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_UiKitLocalizationsDelegate old) => false;
}

UiKitLocalizations lookupUiKitLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return UiKitLocalizationsEn();
  }

  throw FlutterError(
    'UiKitLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
