import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:watercheck_collect/features/collectors/area_fields.dart';
import 'package:watercheck_collect/features/sources/online_search.dart';
import 'package:watercheck_collect/l10n/app_localizations.dart';

AdminUnit _unit(String id, String level, String name, String? parent) => (
  id: id,
  level: level,
  name: name,
  code: id,
  parentId: parent,
  lat: null,
  lon: null,
);

final _units = [
  _unit('ug', 'country', 'Uganda', null),
  _unit('east', 'region', 'Eastern', 'ug'),
  _unit('jinja', 'district', 'Jinja', 'east'),
  _unit('budondo', 'subcounty', 'Budondo', 'jinja'),
];

void main() {
  testWidgets('villages and parishes from all of Uganda follow the local '
      'suggestions and fill the sub-county (2026-10-25)', (tester) async {
    final asked = <String>[];
    Future<List<OnlinePlace>> online(String text) async {
      asked.add(text);
      return [
        (
          id: 'p-1',
          name: 'Kyabirwa Landing',
          kind: 'locality',
          source: 'map',
          lat: 0.5,
          lon: 33.1,
          subcountyId: 'budondo',
          addedBy: null,
        ),
        (
          id: 'p-2',
          name: 'Kyabirwa Parish',
          kind: 'parish',
          source: 'official',
          lat: null,
          lon: null,
          subcountyId: 'budondo',
          addedBy: null,
        ),
      ];
    }

    final village = TextEditingController();
    final parish = TextEditingController();
    final subcounty = TextEditingController();
    final district = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          ...AppLocalizations.localizationsDelegates,
          UiKitLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: AreaFields(
              units: _units,
              village: village,
              parish: parish,
              subcounty: subcounty,
              district: district,
              online: online,
            ),
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextFormField).at(0), 'kyabir');
    await tester.pump();
    expect(find.text('Searching all of Uganda…'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(asked, ['kyabir']);
    // A village field offers the place, not the parish.
    expect(find.text('Kyabirwa Landing'), findsOneWidget);
    expect(find.text('Kyabirwa Parish'), findsNothing);
    await tester.tap(find.text('Kyabirwa Landing'));
    await tester.pumpAndSettle();
    expect(village.text, 'Kyabirwa Landing');
    expect((subcounty.text, district.text), ('Budondo', 'Jinja'));

    await tester.enterText(find.byType(TextFormField).at(1), 'kyabir');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    await tester.tap(find.text('Kyabirwa Parish'));
    await tester.pumpAndSettle();
    expect(parish.text, 'Kyabirwa Parish');
  });
}
