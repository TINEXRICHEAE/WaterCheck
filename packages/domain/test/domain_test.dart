import 'package:domain/domain.dart';
import 'package:test/test.dart';

import 'support/seed.dart';

/// Unit tests for behaviour not covered by the shared vectors.
void main() {
  final seed = Seed.load();
  Decimal d(String s) => Decimal.parse(s);

  group('OverallStatus', () {
    test('round-trips its wire code', () {
      for (final s in OverallStatus.values) {
        expect(OverallStatus.fromCode(s.name), s);
      }
    });
    test('rejects unknown codes', () {
      expect(() => OverallStatus.fromCode('fine'), throwsArgumentError);
    });
  });

  group('ReadingResult', () {
    test('round-trips codes and knows abnormal results', () {
      for (final r in ReadingResult.values) {
        expect(ReadingResult.fromCode(r.code), r);
      }
      expect(ReadingResult.high.isAbnormal, isTrue);
      expect(ReadingResult.notAssessed.isAbnormal, isFalse);
      expect(() => ReadingResult.fromCode('bad'), throwsArgumentError);
    });
  });

  group('catalogue', () {
    test('core four come first in spec order', () {
      expect(seed.catalogue.core.map((p) => p.code), [
        'temp',
        'ph',
        'ec',
        'tds',
      ]);
    });

    test('category panels list non-core parameters in order', () {
      final physical = seed.catalogue.inCategory('physical').map((p) => p.code);
      expect(physical, ['turbidity', 'colour', 'odour', 'taste', 'tss']);
      expect(seed.catalogue.categories.first.code, 'physical');
      expect(seed.catalogue['ecoli']!.valueType, ValueType.presence);
    });

    test('custom parameters need a custom: code and must be new', () {
      const bad = ParameterDefinition(
        code: 'silica',
        name: 'Silica',
        categoryCode: 'chemical',
        defaultUnit: 'mg/L',
        valueType: ValueType.numeric,
        isCustom: true,
      );
      expect(
        () => seed.catalogue.withCustomParameter(bad),
        throwsArgumentError,
      );

      const good = ParameterDefinition(
        code: 'custom:silica',
        name: 'Silica',
        categoryCode: 'chemical',
        defaultUnit: 'mg/L',
        valueType: ValueType.numeric,
        isCustom: true,
      );
      final extended = seed.catalogue.withCustomParameter(good);
      expect(extended['custom:silica'], isNotNull);
      expect(seed.catalogue['custom:silica'], isNull, reason: 'unchanged');
      expect(() => extended.withCustomParameter(good), throwsArgumentError);
    });

    test('rejects duplicate codes and unknown categories', () {
      final cat = [
        const ParameterCategory(code: 'a', name: 'A', displayOrder: 1),
      ];
      const p = ParameterDefinition(
        code: 'x',
        name: 'X',
        categoryCode: 'a',
        defaultUnit: '',
        valueType: ValueType.text,
      );
      expect(
        () => ParameterCatalogue(categories: cat, parameters: [p, p]),
        throwsFormatException,
      );
      expect(
        () => ParameterCatalogue(categories: const [], parameters: const [p]),
        throwsFormatException,
      );
      expect(() => ValueType.fromCode('blob'), throwsFormatException);
    });
  });

  group('tester profiles', () {
    test('generic 4-in-1 pen lists the core four with a TDS factor', () {
      final profiles = TesterProfile.listFromJson(
        seedJson('tester_profiles.json'),
      );
      final pen = profiles.single;
      expect(pen.parameterCodes, ['temp', 'ph', 'ec', 'tds']);
      expect(pen.tdsFactor, d('0.7'));
      expect(pen.model, 'generic');
    });
  });

  group('reference profiles', () {
    final c2 = seed.profiles['US201-2008-ClassII']!;

    test('customize needs a reason and leaves the original unchanged', () {
      final override = ParameterLimit(
        parameterCode: 'tds',
        unit: 'mg/L',
        max: d('1000'),
      );
      expect(
        () => c2.customize(
          id: 'x',
          code: 'CUSTOM-X',
          reason: '  ',
          overrides: [override],
        ),
        throwsArgumentError,
      );
      final custom = c2.customize(
        id: 'x',
        code: 'CUSTOM-X',
        reason: 'District advisory',
        overrides: [override],
      );
      expect(custom.isCustom, isTrue);
      expect(c2.isProvisional, isTrue, reason: 'seeded defaults (D-MN)');
      expect(custom.isProvisional, isFalse);
      expect(custom.basedOnId, c2.id);
      expect(custom.title, '${c2.title} (custom)');
      expect(custom.limitFor('tds')!.max, d('1000'));
      expect(c2.limitFor('tds')!.max, d('1500'));
    });

    test('differencesFrom lists only changed limits', () {
      final custom = c2.customize(
        id: 'x',
        code: 'CUSTOM-X',
        reason: 'r',
        title: 'Mine',
        overrides: [
          ParameterLimit(parameterCode: 'tds', unit: 'mg/L', max: d('1000')),
          ParameterLimit(parameterCode: 'zinc', unit: 'mg/L', max: d('3')),
          ParameterLimit(
            parameterCode: 'ph',
            unit: 'pH',
            min: d('6.5'),
            max: d('8.5'),
          ),
        ],
      );
      final changes = custom.differencesFrom(c2);
      expect(changes.map((c) => c.parameterCode).toSet(), {'tds', 'zinc'});
      final zinc = changes.firstWhere((c) => c.parameterCode == 'zinc');
      expect(zinc.before, isNull);
      expect(custom.title, 'Mine');
    });

    test('rejects duplicate limits', () {
      final l = ParameterLimit(parameterCode: 'ph', unit: 'pH', max: d('8'));
      expect(
        () => ReferenceProfile(
          id: 'i',
          code: 'c',
          title: 't',
          version: 1,
          limits: [l, l],
        ),
        throwsFormatException,
      );
    });

    test('every seeded limit cites its source', () {
      for (final profile in seed.profiles.values) {
        for (final limit in profile.limits) {
          expect(limit.source, isNotNull, reason: limit.parameterCode);
        }
      }
    });
  });

  group('classifier', () {
    final classifier = Classifier(catalogue: seed.catalogue, rules: seed.rules);
    final c2 = seed.profiles['US201-2008-ClassII']!;

    test('duplicate readings for one parameter are a programming error', () {
      final r = ReadingInput(parameterCode: 'ph', unit: 'pH', value: d('7'));
      expect(
        () => classifier.classify(readings: [r, r], profile: c2),
        throwsArgumentError,
      );
    });

    test('plausibility warning used on entry', () {
      expect(
        classifier.isPlausible(
          ReadingInput(parameterCode: 'ph', unit: 'pH', value: d('14.1')),
        ),
        isFalse,
      );
      expect(
        classifier.isPlausible(
          ReadingInput(parameterCode: 'ph', unit: 'pH', value: d('7')),
        ),
        isTrue,
      );
      expect(
        classifier.isPlausible(
          ReadingInput(parameterCode: 'ecoli', value: d('-1')),
        ),
        isFalse,
      );
      expect(
        classifier.isPlausible(const ReadingInput(parameterCode: 'nope')),
        isTrue,
      );
    });

    test('reasons explain not_assessed results', () {
      final noLimit = classifier.assess(
        ReadingInput(parameterCode: 'zinc', unit: 'mg/L', value: d('1')),
        c2,
      );
      expect(noLimit.reason, ResultReason.noLimit);
      final mismatch = classifier.assess(
        ReadingInput(parameterCode: 'tds', unit: 'g/L', value: d('1')),
        c2,
      );
      expect(mismatch.reason, ResultReason.unitMismatch);
    });

    test('median handles even counts exactly', () {
      expect(median([d('1'), d('2')]), Rational.parse('1.5'));
      expect(median([d('3'), d('1'), d('2')]), Rational.fromInt(2));
      expect(() => median(const []), throwsArgumentError);
    });

    test('TDS from EC uses exact decimals', () {
      expect(
        deriveTdsFromEc(d('1234'), seed.rules.tdsFromEcFactor),
        d('863.8'),
      );
    });
  });

  group('units', () {
    test('aliases normalise, unknown units pass through trimmed', () {
      final u = seed.rules.units;
      expect(u.normalize('uS/cm'), 'µS/cm');
      expect(u.normalize(' PPM '), 'mg/L');
      expect(u.normalize(null), '');
      expect(u.normalize(' mS/cm '), 'mS/cm');
      expect(u.same('C', '°C'), isTrue);
      expect(u.same('mS/cm', 'µS/cm'), isFalse);
    });
  });

  group('json helpers', () {
    test('decimals are exact and types are checked', () {
      expect(decimalOrNull(0.001), d('0.001'));
      expect(decimalOrNull('2.50'), d('2.5'));
      expect(decimalOrNull(3), d('3'));
      expect(decimalOrNull(null), isNull);
      expect(() => decimalOrNull(true), throwsFormatException);
      expect(() => decimal(null), throwsFormatException);
    });

    test('rules reject unknown baseline modes', () {
      expect(
        () => BaselineRule.fromJson({
          'parameter_code': 'tds',
          'mode': 'weird',
          'threshold': 1,
        }),
        throwsFormatException,
      );
    });
  });

  group('alert triggers', () {
    final classifier = Classifier(catalogue: seed.catalogue, rules: seed.rules);
    final c2 = seed.profiles['US201-2008-ClassII']!;
    List<ReadingInput> core({String tds = '560'}) => [
      ReadingInput(parameterCode: 'temp', unit: '°C', value: d('25')),
      ReadingInput(parameterCode: 'ph', unit: 'pH', value: d('7')),
      ReadingInput(parameterCode: 'ec', unit: 'µS/cm', value: d('800')),
      ReadingInput(parameterCode: 'tds', unit: 'mg/L', value: d(tds)),
    ];

    test('safe results raise nothing', () {
      expect(
        alertTriggers(classifier.classify(readings: core(), profile: c2)),
        isEmpty,
      );
    });

    test('unsafe raises unsafe; E. coli comes first', () {
      final unsafe = classifier.classify(
        readings: core(tds: '1600'),
        profile: c2,
      );
      expect(alertTriggers(unsafe), [AlertTrigger.unsafe]);
      final ecoli = classifier.classify(
        readings: [
          ...core(),
          const ReadingInput(parameterCode: 'ecoli', detected: true),
        ],
        profile: c2,
      );
      expect(alertTriggers(ecoli), [AlertTrigger.ecoli, AlertTrigger.unsafe]);
      expect(AlertTrigger.ecoli.severity, 'critical');
    });

    test('a baseline jump on a safe result raises baseline_jump', () {
      final jump = classifier.classify(
        readings: core(tds: '1000'),
        profile: c2,
        safeHistory: {
          'tds': [d('700'), d('700'), d('700')],
        },
      );
      expect(jump.overall, OverallStatus.safe);
      expect(alertTriggers(jump), [AlertTrigger.baselineJump]);
    });

    test('inconclusive results raise nothing', () {
      final inconclusive = classifier.classify(
        readings: core().take(2).toList(),
        profile: c2,
      );
      expect(alertTriggers(inconclusive), isEmpty);
    });
  });

  group('alert status', () {
    test('follows the lifecycle and stops at terminal states', () {
      expect(
        AlertStatus.open.canTransitionTo(AlertStatus.acknowledged),
        isTrue,
      );
      expect(AlertStatus.open.canTransitionTo(AlertStatus.closed), isFalse);
      expect(
        AlertStatus.acknowledged.canTransitionTo(AlertStatus.actionInProgress),
        isTrue,
      );
      expect(AlertStatus.closed.nextStates, isEmpty);
      expect(AlertStatus.falseAlarm.isTerminal, isTrue);
      expect(
        AlertStatus.fromCode('action_in_progress'),
        AlertStatus.actionInProgress,
      );
      expect(() => AlertStatus.fromCode('x'), throwsArgumentError);
    });
  });

  group('JSON round trips', () {
    test('reference profiles survive toJson/fromJson exactly', () {
      for (final profile in seed.profiles.values) {
        final copy = ReferenceProfile.fromJson(profile.toJson());
        expect(copy.differencesFrom(profile), isEmpty, reason: profile.code);
        expect(copy.isProvisional, profile.isProvisional);
        expect(copy.limitFor('mercury')!.max, d('0.001'));
      }
    });

    test('parameter definitions survive toJson/fromJson', () {
      for (final p in seed.catalogue.parameters) {
        final copy = ParameterDefinition.fromJson(p.toJson());
        expect(copy.code, p.code);
        expect(copy.valueType, p.valueType);
        expect(copy.plausibleMax, p.plausibleMax);
      }
    });

    test('collector snapshots survive toJson/fromJson', () {
      const snapshot = CollectorSnapshot(
        collectorKey: 'k',
        profileVersion: 2,
        fullName: 'Example Collector',
        phone: '+256700000000',
        collectorType: 'vht',
        village: 'Entebbe',
        parish: 'P',
        subcounty: 'S',
        district: 'Abim',
      );
      final copy = CollectorSnapshot.fromJson(snapshot.toJson());
      expect(copy.toJson(), snapshot.toJson());
    });
  });

  group('geo', () {
    test('distance in metres matches known values', () {
      const a = GeoPoint(lat: 2.7, lon: 33.6);
      // 0.001 degree of latitude is about 111 m.
      expect(
        distanceMetres(a, const GeoPoint(lat: 2.701, lon: 33.6)),
        closeTo(111.2, 0.5),
      );
      expect(distanceMetres(a, a), 0);
      expect(isValidCoordinate(a), isTrue);
      expect(isValidCoordinate(const GeoPoint(lat: 95, lon: 0)), isFalse);
    });
  });

  group('phone numbers', () {
    test('Ugandan numbers normalise to +256 form', () {
      for (final input in [
        '0772 123456',
        '+256 772 123 456',
        '256772123456',
        '00256-772-123-456',
        '(0772) 123 456',
      ]) {
        expect(normalizeUgandaPhone(input), '+256772123456', reason: input);
      }
    });

    test('invalid numbers are refused', () {
      for (final input in [
        '',
        '12345',
        '0772 12345',
        '+254772123456',
        '+2560772123456',
        'phone',
      ]) {
        expect(normalizeUgandaPhone(input), isNull, reason: input);
      }
    });
  });

  group('entities', () {
    test('an amendment needs a reason', () {
      expect(
        () => TestResult(
          id: 'r2',
          sessionId: 's',
          standardId: 'p',
          overall: OverallStatus.safe,
          readings: const [],
          amendmentOf: 'r1',
        ),
        throwsArgumentError,
      );
      final amended = TestResult(
        id: 'r2',
        sessionId: 's',
        standardId: 'p',
        overall: OverallStatus.safe,
        readings: const [],
        amendmentOf: 'r1',
        amendmentReason: 'Typed 7.1 as 71',
      );
      expect(amended.isAmendment, isTrue);
    });
  });
}
