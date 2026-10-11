import 'package:api_client/api_client.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr/qr.dart';

import '../../l10n/app_localizations.dart';
import 'admin_api.dart';
import 'area_picker.dart';

/// Collect phones (F-ADM-2): activation codes for an area (typed or QR),
/// the phones activated, and revoking one. Online only.
class PhonesScreen extends ConsumerWidget {
  const PhonesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final phones = ref.watch(adminInstallationsProvider);
    final codes = ref.watch(adminCodesProvider);
    final when = DateFormat('d MMM y, HH:mm');
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _newCode(context, ref),
        icon: const Icon(Icons.qr_code_2),
        label: Text(l10n.phonesNewCode),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          Text(l10n.phonesTitle, style: text.headlineSmall),
          Text(l10n.phonesHint),
          const SizedBox(height: 8),
          ...phones.when(
            loading: () => [const Center(child: CircularProgressIndicator())],
            error: (_, _) => [Text(l10n.adminNeedsConnection)],
            data: (list) => [
              if (list.isEmpty) Text(l10n.phonesNone),
              for (final p in list)
                Card(
                  child: ListTile(
                    leading: Icon(
                      p.revokedAt == null
                          ? Icons.phone_android
                          : Icons.phonelink_erase,
                    ),
                    title: Text(
                      '${p.area.name} (${l10n.areaLevel(p.area.level)})'
                      '${p.shortCode == null ? '' : ' · ${p.shortCode}'}',
                    ),
                    subtitle: Text(
                      [
                        [?p.platform, ?p.appVersion].join(' '),
                        l10n.phonesActivity(p.collectorsSeen, p.tests),
                        p.lastSeenAt == null
                            ? l10n.phonesNeverSynced
                            : l10n.phonesLastSeen(
                                when.format(p.lastSeenAt!.toLocal()),
                              ),
                        if (p.revokedAt != null)
                          l10n.phonesRevokedAt(
                            when.format(p.revokedAt!.toLocal()),
                          ),
                      ].where((s) => s.isNotEmpty).join('\n'),
                    ),
                    isThreeLine: true,
                    trailing: p.revokedAt != null
                        ? null
                        : TextButton.icon(
                            onPressed: () => _revoke(context, ref, p),
                            icon: const Icon(Icons.block),
                            label: Text(l10n.phonesRevoke),
                          ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(l10n.phonesCodes, style: text.titleMedium),
          ...codes.when(
            loading: () => const [],
            error: (_, _) => const [],
            data: (list) => [
              if (list.isEmpty) Text(l10n.phonesNoCodes),
              for (final c in list.take(20))
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.vpn_key_outlined),
                  title: Text(
                    '${c.area.name} (${l10n.areaLevel(c.area.level)})',
                  ),
                  subtitle: Text(
                    l10n.phonesCodeLine(
                      c.usedCount,
                      c.maxInstallations,
                      when.format(c.expiresAt.toLocal()),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _revoke(
    BuildContext context,
    WidgetRef ref,
    InstallationOut p,
  ) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.phonesRevokeTitle),
        content: Text(l10n.phonesRevokeHint),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.phonesRevoke),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref
        .read(adminApiProvider)
        .installations
        .revokeInstallation(installationId: p.id);
    ref.invalidate(adminInstallationsProvider);
  }

  Future<void> _newCode(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final picked = await pickAreas(context, multiple: false);
    if (picked == null || picked.isEmpty || !context.mounted) return;
    final area = picked.single;
    final settings = await showDialog<({int max, int days})>(
      context: context,
      builder: (_) => _CodeSettings(area: area),
    );
    if (settings == null || !context.mounted) return;
    try {
      final issued = await ref
          .read(adminApiProvider)
          .installations
          .newActivationCode(
            body: NewCodeRequest(
              areaCode: area.code,
              maxInstallations: settings.max,
              expiresInDays: settings.days,
            ),
          );
      ref.invalidate(adminCodesProvider);
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _CodeShown(area: area, issued: issued),
      );
    } on Object catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.usersFailed(ApiFailure.from(e).code))),
        );
      }
    }
  }
}

class _CodeSettings extends StatefulWidget {
  const _CodeSettings({required this.area});

  final AdminUnit area;

  @override
  State<_CodeSettings> createState() => _CodeSettingsState();
}

class _CodeSettingsState extends State<_CodeSettings> {
  var _max = 5;
  var _days = 7;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.phonesNewCodeFor(widget.area.name)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.phonesMax(_max)),
          Slider(
            value: _max.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            label: '$_max',
            onChanged: (v) => setState(() => _max = v.round()),
          ),
          Text(l10n.phonesValidDays(_days)),
          Slider(
            value: _days.toDouble(),
            min: 1,
            max: 60,
            divisions: 59,
            label: '$_days',
            onChanged: (v) => setState(() => _days = v.round()),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, (max: _max, days: _days)),
          child: Text(l10n.phonesCreateCode),
        ),
      ],
    );
  }
}

/// The code, shown once, typed or scanned in Collect's activation screen.
class _CodeShown extends StatelessWidget {
  const _CodeShown({required this.area, required this.issued});

  final AdminUnit area;
  final NewCodeResponse issued;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final payload = Uri(
      scheme: 'watercheck',
      host: 'activate',
      queryParameters: {'code': issued.code, 'server': defaultApiUrl()},
    ).toString();
    return AlertDialog(
      title: Text(l10n.phonesCodeTitle(area.name)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.phonesCodeHint),
          const SizedBox(height: 12),
          Semantics(
            label: l10n.phonesQrLabel,
            child: SizedBox.square(
              dimension: 220,
              child: QrView(data: payload),
            ),
          ),
          const SizedBox(height: 12),
          SelectableText(
            issued.code,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontFamily: 'monospace', letterSpacing: 2),
          ),
          Text(
            l10n.phonesCodeLine(
              0,
              issued.maxInstallations,
              DateFormat('d MMM y, HH:mm').format(issued.expiresAt.toLocal()),
            ),
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: () => Clipboard.setData(ClipboardData(text: issued.code)),
          icon: const Icon(Icons.copy),
          label: Text(l10n.credentialsCopy),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.credentialsDone),
        ),
      ],
    );
  }
}

/// A QR code drawn from the `qr` package's module matrix (black on white,
/// with the standard quiet zone).
class QrView extends StatelessWidget {
  const QrView({super.key, required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    final qr = QrImage(
      QrCode.fromData(data: data, errorCorrectLevel: QrErrorCorrectLevel.M),
    );
    return ColoredBox(
      color: Colors.white,
      child: CustomPaint(painter: _QrPainter(qr)),
    );
  }
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.qr);

  final QrImage qr;

  @override
  void paint(Canvas canvas, Size size) {
    const quiet = 4;
    final n = qr.moduleCount + quiet * 2;
    final cell = size.shortestSide / n;
    final dark = Paint()..color = Colors.black;
    for (var y = 0; y < qr.moduleCount; y++) {
      for (var x = 0; x < qr.moduleCount; x++) {
        if (qr.isDark(y, x)) {
          canvas.drawRect(
            Rect.fromLTWH((x + quiet) * cell, (y + quiet) * cell, cell, cell),
            dark,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_QrPainter old) => old.qr != qr;
}
