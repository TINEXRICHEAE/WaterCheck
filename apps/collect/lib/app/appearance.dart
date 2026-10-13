import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import 'gate.dart';
import 'providers.dart';

typedef Appearance = ({ThemeChoice theme, TimeZoneChoice zone});

/// Theme and time zone (2026-10-13). Collectors are not server accounts, so
/// each collector's choice is kept on this phone; the last choice also
/// applies before anyone is chosen (lock and activation screens).
class AppearanceNotifier extends AsyncNotifier<Appearance> {
  static const _device = 'appearance.device';
  static String _key(String collector) => 'appearance.$collector';

  @override
  Future<Appearance> build() async {
    final collector = ref.watch(appGateProvider).activeCollectorKey;
    final settings = ref.read(localSettingsRepositoryProvider);
    final stored =
        (collector == null ? null : await settings.read(_key(collector))) ??
        await settings.read(_device);
    return _parse(stored);
  }

  static Appearance _parse(String? s) {
    final parts = (s ?? '').split('|');
    return (
      theme: ThemeChoice.parse(parts.first),
      zone: TimeZoneChoice.parse(parts.length > 1 ? parts[1] : null),
    );
  }

  Future<void> set(Appearance a) async {
    final value = '${a.theme.name}|${a.zone.stored}';
    final settings = ref.read(localSettingsRepositoryProvider);
    final collector = ref.read(appGateProvider).activeCollectorKey;
    if (collector != null) await settings.write(_key(collector), value);
    await settings.write(_device, value);
    state = AsyncData(a);
  }
}

final appearanceProvider =
    AsyncNotifierProvider<AppearanceNotifier, Appearance>(
      AppearanceNotifier.new,
    );
