import '../../l10n/app_localizations.dart';

const _sourceTypes = {
  'borehole',
  'shallow_well',
  'protected_spring',
  'tap',
  'rain_tank',
  'other',
};
const _collectorTypes = {'vht', 'lc1', 'resident', 'student', 'other'};

/// A source type's name; a typed one (ADR-022) is its own name.
String sourceTypeLabel(AppLocalizations l10n, String type) =>
    _sourceTypes.contains(type) ? l10n.sourceType(type) : type;

/// A collector type's name; a typed one (ADR-022) is its own name.
String collectorTypeLabel(AppLocalizations l10n, String type) =>
    _collectorTypes.contains(type) ? l10n.collectorType(type) : type;
