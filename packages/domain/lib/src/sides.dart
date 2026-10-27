/// The sides of FieldQuire (ADR-031): separate kinds of field work, each
/// with its own people, pages, records, Privacy Policy and Terms of Use.
/// More may be added later.
enum AppSide {
  water,
  research;

  /// As the server writes it.
  String get wire => name;

  static AppSide? parse(String? v) =>
      values.where((s) => s.name == v).firstOrNull;

  /// The other side (with two sides, the only one).
  AppSide get other => this == water ? research : water;
}

/// The version of each side's Privacy Policy and Terms of Use. Keep in step
/// with the server (`backend/app/core/sides.py`).
const legalVersions = {AppSide.water: 4, AppSide.research: 1};
