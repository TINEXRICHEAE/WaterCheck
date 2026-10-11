import 'package:api_client/api_client.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watercheck_console/features/dashboard/dashboard_view.dart';
import 'package:watercheck_console/features/map/sources_map.dart';

void main() {
  test('the server summary becomes the dashboard view (web, before sync)', () {
    final s = DashboardSummary.fromJson({
      'sources': 50,
      'tested_in_period': 40,
      'unsafe_in_period': 5,
      'open_alerts': 3,
      'median_ack_seconds': 5400.0,
      'overdue': [
        {
          'id': 's-1',
          'code': 'ABIM-ENT-P001',
          'name': 'Perf source 01',
          'due_date': '2026-10-01',
          'latest_overall': 'safe',
        },
      ],
      'collectors': [
        {
          'collector_key': 'c-1',
          'name': 'Perf collector 1',
          'submissions': 12,
          'last_submission': '2026-10-10T08:00:00Z',
          'mark': 'known',
        },
      ],
      'latest_tests': [
        {
          'source_id': 's-2',
          'code': 'ABIM-ENT-P002',
          'name': null,
          'tested_at': '2026-10-10T08:00:00Z',
          'overall': 'unsafe',
          'collector_name': 'Perf collector 1',
          'custom_limits': false,
        },
      ],
      'latest_issue': {
        'source_id': 's-2',
        'code': 'ABIM-ENT-P002',
        'name': null,
        'lat': 2.7,
        'lon': 33.6,
        'trigger_rule': 'unsafe',
        'severity': 'high',
        'at': '2026-10-10T08:00:00Z',
      },
    });
    final v = DashboardView.server(s);
    expect(v.fromServer, isTrue);
    expect((v.sources, v.tested, v.unsafe, v.openAlerts), (50, 40, 5, 3));
    expect(v.unsafeShare, closeTo(0.125, 1e-9));
    expect(v.medianAck, const Duration(minutes: 90));
    expect(v.overdue.single.latest, OverallStatus.safe);
    expect(v.collectors.single.mark, 'known');
    expect(v.latestTests.single.overall, OverallStatus.unsafe);
    expect(v.issue!.point.status, MapStatus.unsafe);
    expect((v.issue!.point.lat, v.issue!.rule), (2.7, 'unsafe'));
    expect(v.profileCode, isNull);
  });
}
