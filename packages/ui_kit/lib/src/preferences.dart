import 'package:flutter/material.dart';

/// Light, dark or follow the device; chosen by each user.
enum ThemeChoice {
  system,
  light,
  dark;

  ThemeMode get mode => switch (this) {
    ThemeChoice.system => ThemeMode.system,
    ThemeChoice.light => ThemeMode.light,
    ThemeChoice.dark => ThemeMode.dark,
  };

  static ThemeChoice parse(String? s) =>
      values.where((v) => v.name == s).firstOrNull ?? ThemeChoice.system;
}

/// The time zone times are shown in. East Africa Time has no daylight
/// saving, so a fixed offset is exact. [auto] follows the device.
enum TimeZoneChoice {
  auto(null, null),
  kampala('Africa/Kampala', Duration(hours: 3)),
  nairobi('Africa/Nairobi', Duration(hours: 3)),
  utc('UTC', Duration.zero);

  const TimeZoneChoice(this.id, this.offset);

  /// IANA name, stored on the server and on the device; null for [auto].
  final String? id;
  final Duration? offset;

  /// The default for Uganda (the lead, 2026-10-13).
  static const fallback = TimeZoneChoice.kampala;

  static TimeZoneChoice parse(String? s) => s == 'auto'
      ? TimeZoneChoice.auto
      : values.where((v) => v.id != null && v.id == s).firstOrNull ?? fallback;

  String get stored => id ?? 'auto';
}

/// Shows times in the chosen zone. Set by the app when the user's choice
/// changes; widgets that format times call [WcTime.local] (and depend on
/// [TimeZoneScope], so they rebuild).
abstract final class WcTime {
  static TimeZoneChoice zone = TimeZoneChoice.fallback;

  /// The wall-clock time of [t] in the chosen zone.
  static DateTime local(DateTime t, [BuildContext? context]) {
    if (context != null) TimeZoneScope.of(context);
    final offset = zone.offset;
    if (offset == null) return t.toLocal();
    final u = t.toUtc().add(offset);
    return DateTime(
      u.year,
      u.month,
      u.day,
      u.hour,
      u.minute,
      u.second,
      u.millisecond,
    );
  }

  /// A wall-clock time picked on screen (in the chosen zone), as UTC.
  static DateTime toUtc(DateTime wall) {
    final offset = zone.offset;
    if (offset == null) return wall.toUtc();
    return DateTime.utc(
      wall.year,
      wall.month,
      wall.day,
      wall.hour,
      wall.minute,
      wall.second,
      wall.millisecond,
    ).subtract(offset);
  }

  /// Now, as a wall-clock time in the chosen zone.
  static DateTime now() => local(DateTime.now());

  /// "EAT (UTC+3)", "UTC" or the device's zone name.
  static String label() {
    final offset = zone.offset;
    if (offset == null) return DateTime.now().timeZoneName;
    return offset == Duration.zero ? 'UTC' : 'EAT (UTC+${offset.inHours})';
  }
}

/// Rebuilds time-showing widgets when the zone changes.
class TimeZoneScope extends InheritedWidget {
  const TimeZoneScope({super.key, required this.zone, required super.child});

  final TimeZoneChoice zone;

  static TimeZoneChoice of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TimeZoneScope>()?.zone ??
      WcTime.zone;

  @override
  bool updateShouldNotify(TimeZoneScope oldWidget) => zone != oldWidget.zone;
}
