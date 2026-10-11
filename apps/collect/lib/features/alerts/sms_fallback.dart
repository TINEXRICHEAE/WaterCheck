import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/gate.dart';
import '../../app/providers.dart';

/// The verification code of an SMS: the first 6 hex characters of
/// HMAC-SHA256(installation secret, the message before `#`), upper case.
/// Shared with `backend/app/services/sms.py`.
String smsCode(String secret, String message) =>
    Hmac(sha256, utf8.encode(secret))
        .convert(
          utf8.encode(message.split(' ').where((w) => w.isNotEmpty).join(' ')),
        )
        .toString()
        .substring(0, 6)
        .toUpperCase();

const _status = {'unsafe': 'UNSAFE', 'ecoli': 'ECOLI', 'baseline_jump': 'JUMP'};

/// The structured alert SMS (SPEC §8.5), at most 160 characters:
/// `WC1 I:7Q2K ALERT ABIM-ENT-003 20261104T0912Z PH7.1 TDS1820 UNSAFE #1714FE`.
String composeAlertSms({
  required String shortCode,
  required String secret,
  required String sourceCode,
  required DateTime testedAt,
  required String triggerRule,
  List<ReadingInput> readings = const [],
}) {
  final parts = [
    'WC1',
    'I:$shortCode',
    'ALERT',
    sourceCode.toUpperCase(),
    DateFormat("yyyyMMdd'T'HHmm'Z'").format(testedAt.toUtc()),
  ];
  for (final r in readings) {
    final name = r.parameterCode.toUpperCase();
    final value = r.value;
    if (value == null || !RegExp(r'^[A-Z]{1,8}$').hasMatch(name)) continue;
    final token = '$name$value';
    // Keep room for the status and the code.
    if ([...parts, token].join(' ').length > 130) break;
    parts.add(token);
  }
  parts.add(_status[triggerRule] ?? 'UNSAFE');
  final signed = parts.join(' ');
  return '$signed #${smsCode(secret, signed)}';
}

/// An SMS the collector can send for an alert stuck offline.
class SmsOffer {
  const SmsOffer({
    required this.number,
    required this.body,
    required this.hours,
  });

  final String number;
  final String body;

  /// How long the alert has waited to sync.
  final int hours;
}

/// Offered when an alert has not synced for `sms_fallback.after_hours`
/// (default 6) and the IT admin has set the gateway number.
final smsOfferProvider = FutureProvider.autoDispose.family<SmsOffer?, String>((
  ref,
  alertId,
) async {
  final creds = ref.watch(credentialsProvider);
  final short = creds?.shortCode;
  if (creds == null || short == null) return null;
  final alert = await ref.watch(alertRepositoryProvider).alert(alertId);
  if (alert == null) return null;
  if (!await ref.watch(outboxRepositoryProvider).isUnsent('alert', alertId)) {
    return null;
  }
  final config = await ref
      .watch(referenceDataRepositoryProvider)
      .configOrNull('notifications');
  final fallback = (config?['sms_fallback'] as Map?) ?? const {};
  final number = (fallback['gateway_number'] as String?) ?? '';
  final after = (fallback['after_hours'] as num?)?.toInt() ?? 6;
  final waited = ref.watch(clockProvider)().difference(alert.openedAt);
  if (number.isEmpty || waited.inHours < after) return null;
  final source = await ref
      .watch(sourceRepositoryProvider)
      .source(alert.sourceId);
  final resultId = alert.triggerResultId;
  final readings = resultId == null
      ? const <ReadingInput>[]
      : await ref.watch(testingRepositoryProvider).readingsOf(resultId);
  return SmsOffer(
    number: number,
    hours: waited.inHours,
    body: composeAlertSms(
      shortCode: short,
      secret: creds.secret,
      sourceCode: source?.code ?? '',
      testedAt: alert.openedAt,
      triggerRule: alert.triggerRule,
      readings: readings,
    ),
  );
});

/// Opens the phone's SMS app with the message filled in (the collector
/// presses send; no SMS permission is needed).
abstract interface class SmsComposer {
  Future<bool> open(String number, String body);
}

class DeviceSmsComposer implements SmsComposer {
  @override
  Future<bool> open(String number, String body) async {
    if (kIsWeb) return false;
    final uri = Uri(
      scheme: 'sms',
      path: number,
      queryParameters: {'body': body},
    );
    return launchUrl(uri);
  }
}

final smsComposerProvider = Provider<SmsComposer>((ref) => DeviceSmsComposer());

/// Device time, replaceable in tests.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
