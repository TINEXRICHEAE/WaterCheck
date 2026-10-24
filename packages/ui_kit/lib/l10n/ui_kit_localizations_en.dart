// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'ui_kit_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class UiKitLocalizationsEn extends UiKitLocalizations {
  UiKitLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get statusSafe => 'SAFE';

  @override
  String get statusUnsafe => 'UNSAFE';

  @override
  String get statusInconclusive => 'INCONCLUSIVE';

  @override
  String get statusNotTested => 'NOT TESTED';

  @override
  String get statusDueSoon => 'DUE';

  @override
  String get statusOverdue => 'OVERDUE';

  @override
  String get syncAllSent => 'Everything is sent';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items waiting to send',
      one: '1 item waiting to send',
    );
    return '$_temp0';
  }

  @override
  String syncRejected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items were refused',
      one: '1 item was refused',
    );
    return '$_temp0';
  }

  @override
  String get syncOfflineHint =>
      'Saved on this phone. It will be sent when the internet returns.';

  @override
  String get syncNeverSent => 'Not sent yet';

  @override
  String syncLastSent(String when) {
    return 'Last sent $when';
  }

  @override
  String get provisionalLimits => 'Provisional limits';

  @override
  String get customLimits => 'Custom limits';

  @override
  String get refDataTitle => 'Reference data';

  @override
  String get refDataIntro =>
      'Loaded on this device from the bundled seed. Works offline.';

  @override
  String refParameters(int count) {
    return 'Parameters ($count)';
  }

  @override
  String get refCore => 'Core (always shown first)';

  @override
  String refProfiles(int count) {
    return 'Reference profiles ($count)';
  }

  @override
  String refLimitCount(int count) {
    return '$count limits';
  }

  @override
  String get refTesterProfiles => 'Tester profiles';

  @override
  String get refAreas => 'Areas';

  @override
  String get refRules => 'Rules';

  @override
  String refRequired(String list) {
    return 'Required: $list';
  }

  @override
  String refSchedule(int routine, int rainy, int abnormal) {
    return 'Test every $routine days; $rainy days in the rainy season; $abnormal days after an abnormal result';
  }

  @override
  String get refNoLimit => 'no limit';

  @override
  String get refMustBeAbsent => 'must be absent';

  @override
  String get refMustBeAcceptable => 'must be acceptable';

  @override
  String get pinEnter => 'Enter your PIN';

  @override
  String get pinChoose => 'Choose a PIN';

  @override
  String get pinChooseHint =>
      '4 to 8 digits. You will need it to open the app.';

  @override
  String get pinConfirm => 'Enter the same PIN again';

  @override
  String get pinMismatch => 'The PINs did not match. Try again.';

  @override
  String pinWrong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wrong PIN. $count more tries before a wait.',
      one: 'Wrong PIN. 1 more try before a wait.',
      zero: 'Wrong PIN.',
    );
    return '$_temp0';
  }

  @override
  String pinWait(int seconds) {
    return 'Too many wrong PINs. Try again in $seconds seconds.';
  }

  @override
  String get pinOk => 'OK';

  @override
  String get pinDelete => 'Delete last digit';

  @override
  String get pinUseBiometric => 'Use fingerprint or face';

  @override
  String pinDigitsEntered(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count digits entered',
      one: '1 digit entered',
      zero: 'No digits entered',
    );
    return '$_temp0';
  }

  @override
  String get trendTitle => 'Trend';

  @override
  String get trendLimit => 'Limit';

  @override
  String get appLogo => 'WaterCheck logo';

  @override
  String get passwordShow => 'Show password';

  @override
  String get passwordHide => 'Hide password';

  @override
  String get loading => 'Loading';

  @override
  String get errorRetry => 'Try again';

  @override
  String get errorHome => 'Go to the start page';

  @override
  String get errorOfflineTitle => 'No connection';

  @override
  String get errorOfflineBody =>
      'The server cannot be reached. Check the internet connection and try again. Work saved on this device is kept.';

  @override
  String get errorTimeoutTitle => 'This is taking too long';

  @override
  String get errorTimeoutBody =>
      'The server did not answer in time. The connection may be slow; try again in a moment.';

  @override
  String get errorSignedOutTitle => 'Please sign in again';

  @override
  String get errorSignedOutBody =>
      'Your session has ended. Sign in again to continue.';

  @override
  String get errorForbiddenTitle => 'Not allowed';

  @override
  String get errorForbiddenBody =>
      'Your account does not have access to this. Ask the IT admin if you need it.';

  @override
  String get errorNotFoundTitle => 'Page not found';

  @override
  String get errorNotFoundBody =>
      'What you are looking for is not here. It may have been moved or removed.';

  @override
  String get errorServerTitle => 'The server had a problem';

  @override
  String get errorServerBody =>
      'Something went wrong on the server. Try again later; if it keeps happening, tell the IT admin.';

  @override
  String get errorUnknownTitle => 'Something went wrong';

  @override
  String get errorUnknownBody =>
      'This could not be completed. Try again; if it keeps happening, tell the IT admin.';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsTimeZone => 'Time zone';

  @override
  String settingsTimeZoneNow(String time) {
    return 'Time now: $time';
  }

  @override
  String get zoneAuto => 'Automatic (this device\'s time zone)';

  @override
  String get zoneKampala => 'East Africa Time, Kampala (UTC+3)';

  @override
  String get zoneNairobi => 'East Africa Time, Nairobi (UTC+3)';

  @override
  String get zoneUtc => 'UTC';

  @override
  String get filtersReset => 'Reset filters';

  @override
  String get aboutLegalese =>
      'Community drinking water monitoring. Licensed under the project licence; open-source components are listed under View licences.';

  @override
  String get cancel => 'Cancel';

  @override
  String get searchClear => 'Clear search';

  @override
  String get filterAll => 'All';

  @override
  String get refSearch => 'Search parameters, limits, kits and areas';

  @override
  String get refSearchClear => 'Clear the search';

  @override
  String refNoMatch(String query) {
    return 'Nothing matches \"$query\".';
  }

  @override
  String refAreasMore(int shown, int count) {
    return 'Showing $shown of $count. Type in the search box to narrow the list.';
  }

  @override
  String get refOpenDetails => 'Details and actions';

  @override
  String get mapSearchHint => 'Search a place or a source';

  @override
  String get mapLayers => 'Map layers';

  @override
  String get mapLabels => 'Source names';

  @override
  String get mapStraight => 'Straight-line distance';

  @override
  String get mapStraightHint => 'From where you are, as the crow flies';

  @override
  String get mapRoute => 'Route by road';

  @override
  String get mapRouteHint =>
      'To the chosen source, with distance and travel time';

  @override
  String get mapVehicle => 'Motorbike/car';

  @override
  String get mapWalking => 'Walking';

  @override
  String mapStraightLine(String distance) {
    return '$distance straight';
  }

  @override
  String mapByRoad(String distance, String time, String mode) {
    return '$distance by road, about $time ($mode)';
  }

  @override
  String get mapRouteLoading => 'finding the route…';

  @override
  String get mapRouteNone => 'no route found (or routing is off)';

  @override
  String get installApp => 'Install app';

  @override
  String get installAppHint =>
      'Open WaterCheck from your home screen or app list, also offline.';

  @override
  String get mapZoomIn => 'Zoom in (R key)';

  @override
  String get mapZoomOut => 'Zoom out (F key)';

  @override
  String get photoClose => 'Close (Esc)';

  @override
  String get photoPrevious => 'Previous picture (left arrow)';

  @override
  String get photoNext => 'Next picture (right arrow)';

  @override
  String photoCount(int at, int total) {
    return 'Picture $at of $total';
  }

  @override
  String get photoRemove => 'Remove picture';

  @override
  String get photoRemoveTitle => 'Remove this picture?';

  @override
  String get photoRemoveBody =>
      'It disappears from this device and, once synced, from everyone\'s view. You can add a new one after.';

  @override
  String get photoKeep => 'Keep it';

  @override
  String get photoRemoveFailed => 'The picture could not be removed.';

  @override
  String get photoUnavailable =>
      'This picture can\'t be shown right now (not uploaded yet, or no connection).';

  @override
  String get choiceOther => 'Other (type it)';

  @override
  String choiceTypedBefore(String value) {
    return '$value (typed before)';
  }

  @override
  String get choiceTypeIt => 'Type it';

  @override
  String get choiceTypeItHint =>
      'Used on this device at once; the IT admin may add it to the shared list.';

  @override
  String get choiceRequired => 'Choose one, or pick Other and type it.';

  @override
  String get choiceTypeItRequired => 'Type what it is.';

  @override
  String get conversationEmpty => 'No messages yet. Write the first one.';

  @override
  String get conversationYou => 'You';

  @override
  String conversationFrom(String name) {
    return 'Message from $name';
  }

  @override
  String get conversationStaff => 'Stakeholder or IT admin';

  @override
  String get conversationWaiting => 'Waiting to send (no connection yet)';

  @override
  String get conversationWrite => 'Write a message';

  @override
  String get conversationHint =>
      'Enter sends; Shift+Enter for a new line. Everyone following this sees it.';

  @override
  String get conversationSend => 'Send';

  @override
  String get mapMoveUp => 'Move up (↑ or W; hold to keep moving)';

  @override
  String get mapMoveDown => 'Move down (↓ or S; hold to keep moving)';

  @override
  String get mapMoveLeft => 'Move left (← or A; hold to keep moving)';

  @override
  String get mapMoveRight => 'Move right (→ or D; hold to keep moving)';

  @override
  String get legalPrivacy => 'Privacy Policy';

  @override
  String get legalTerms => 'Terms of Use';

  @override
  String legalVersionLine(int version) {
    return 'Version $version';
  }

  @override
  String get legalAccept =>
      'I agree to the Terms of Use and the Privacy Policy';

  @override
  String get legalChanged =>
      'The Privacy Policy or Terms of Use have changed. Please read them and agree again to keep using WaterCheck.';
}
