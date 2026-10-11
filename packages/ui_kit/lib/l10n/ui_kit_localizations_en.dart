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
}
