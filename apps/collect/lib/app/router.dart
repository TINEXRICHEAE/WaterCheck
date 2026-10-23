import 'package:data/data.dart' show ThreadKind;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:go_router/go_router.dart';

import '../features/activation/activation_screen.dart';
import '../features/activation/scan_screen.dart';
import '../features/alerts/response_card_screen.dart';
import '../features/collectors/collector_form_screen.dart';
import '../features/collectors/who_is_testing_screen.dart';
import '../features/home/home_screen.dart';
import '../features/collectors/recover_profile_screen.dart';
import '../features/map/map_screen.dart';
import '../features/settings/reference_detail_screens.dart';
import '../features/lock/lock_screens.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/reset/reset_screen.dart';
import '../features/settings/reference_data_screen.dart';
import '../features/sources/inspection_screen.dart';
import '../features/sources/source_detail_screen.dart';
import '../features/sources/source_form_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/sync/sync_screen.dart';
import '../features/testing/entry_screen.dart';
import '../features/testing/limits_editor_screen.dart';
import '../features/testing/pick_source_screen.dart';
import '../features/testing/result_screen.dart';
import '../features/testing/review_screen.dart';
import '../features/testing/session_setup_screen.dart';
import '../features/messages/messages.dart';
import '../l10n/app_localizations.dart';
import 'gate.dart';

/// Routes a user must be able to reach before choosing a collector.
bool _isOnboarding(String location) =>
    location == '/welcome' || location.startsWith('/who');

/// Screens that only make sense before the app is ready.
bool _isSetup(String location) =>
    location == '/welcome' ||
    location.startsWith('/activate') ||
    location == '/lock' ||
    location == '/lock/setup';

/// Where the gate sends someone trying to open [location], or null to allow.
/// Order: privacy notice, revoked, activation, lock, PIN choice, collector.
String? gateRedirect(AppGate gate, String location) {
  if (!gate.consented) return location == '/welcome' ? null : '/welcome';
  if (gate.revoked) return location == '/reset' ? null : '/reset';
  if (!gate.activated) {
    return location.startsWith('/activate') ? null : '/activate';
  }
  // Reset erases everything and exports only what the server can read, so
  // it is reachable from the lock screen ("Forgot PIN?").
  if (location == '/reset') return null;
  if (gate.locked) return location == '/lock' ? null : '/lock';
  if (!gate.lockDecided) {
    return location == '/lock/setup' ? null : '/lock/setup';
  }
  if (_isSetup(location)) return '/';
  if (gate.activeCollectorKey == null && !_isOnboarding(location)) {
    return '/who';
  }
  return null;
}

/// Collect: phone-first, task-focused, bottom navigation (SPEC §11).
final routerProvider = Provider<GoRouter>((ref) {
  final gate = ValueNotifier(ref.read(appGateProvider));
  ref
    ..listen(appGateProvider, (_, next) => gate.value = next)
    ..onDispose(gate.dispose);
  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: gate,
    redirect: (context, state) =>
        gateRedirect(gate.value, state.matchedLocation),
    // An unknown address: a safe page, not a crash.
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(),
      body: ErrorView(kind: ErrorKind.notFound, onHome: () => context.go('/')),
    ),
    routes: [
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
      GoRoute(
        path: '/activate',
        builder: (_, _) => const ActivationScreen(),
        routes: [GoRoute(path: 'scan', builder: (_, _) => const ScanScreen())],
      ),
      GoRoute(
        path: '/lock',
        builder: (_, _) => const LockScreen(),
        routes: [
          GoRoute(path: 'setup', builder: (_, _) => const LockSetupScreen()),
        ],
      ),
      GoRoute(path: '/reset', builder: (_, _) => const ResetScreen()),
      GoRoute(path: '/pin', builder: (_, _) => const ChangePinScreen()),
      GoRoute(
        path: '/pin/off',
        builder: (_, _) => const ChangePinScreen(turnOff: true),
      ),
      GoRoute(
        path: '/who',
        builder: (_, _) => const WhoIsTestingScreen(),
        routes: [
          GoRoute(path: 'new', builder: (_, _) => const CollectorFormScreen()),
          GoRoute(
            path: 'recover',
            builder: (_, _) => const RecoverProfileScreen(),
          ),
          GoRoute(
            path: ':key/edit',
            builder: (_, state) =>
                CollectorFormScreen(collectorKey: state.pathParameters['key']),
          ),
        ],
      ),
      GoRoute(
        path: '/test',
        builder: (_, _) => const PickSourceScreen(),
        routes: [
          GoRoute(path: 'setup', builder: (_, _) => const SessionSetupScreen()),
          GoRoute(
            path: 'limits',
            builder: (_, _) => const LimitsEditorScreen(),
          ),
          GoRoute(path: 'entry', builder: (_, _) => const EntryScreen()),
          GoRoute(path: 'review', builder: (_, _) => const ReviewScreen()),
          GoRoute(
            path: 'result/:id',
            builder: (_, state) =>
                ResultScreen(resultId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/messages',
        builder: (_, _) => const InboxScreen(),
        routes: [
          GoRoute(
            path: ':kind/:id',
            builder: (_, state) => ThreadScreen(
              kind:
                  ThreadKind.parse(state.pathParameters['kind']!) ??
                  ThreadKind.source,
              subjectId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/alerts/:id',
        builder: (_, state) =>
            ResponseCardScreen(alertId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/sources/new',
        builder: (_, _) => const SourceFormScreen(),
      ),
      GoRoute(
        path: '/sources/:id',
        builder: (_, state) =>
            SourceDetailScreen(sourceId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (_, state) =>
                SourceFormScreen(sourceId: state.pathParameters['id']),
          ),
          GoRoute(
            path: 'inspection',
            builder: (_, state) =>
                InspectionScreen(sourceId: state.pathParameters['id']!),
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _CollectShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/', builder: (_, _) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                builder: (_, state) => MapScreen(
                  areaId: state.uri.queryParameters['area'],
                  sourceId: state.uri.queryParameters['source'],
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/sync', builder: (_, _) => const SyncScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (_, _) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'reference-data',
                    builder: (_, _) => const ReferenceDataScreen(),
                    routes: [
                      GoRoute(
                        path: 'rules',
                        builder: (_, _) => const RulesScreen(),
                      ),
                      GoRoute(
                        path: 'limits/:id',
                        builder: (_, state) => LimitSetScreen(
                          profileId: state.pathParameters['id']!,
                        ),
                      ),
                      GoRoute(
                        path: 'parameter/:code',
                        builder: (_, state) => ParameterScreen(
                          code: state.pathParameters['code']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

class _CollectShell extends StatelessWidget {
  const _CollectShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = [
      (Icons.water_drop_outlined, Icons.water_drop, l10n.navHome),
      (Icons.map_outlined, Icons.map, l10n.navMap),
      (Icons.cloud_upload_outlined, Icons.cloud_upload, l10n.navSync),
      (Icons.settings_outlined, Icons.settings, l10n.navSettings),
    ];
    void go(int i) =>
        shell.goBranch(i, initialLocation: i == shell.currentIndex);
    // Tablets and computers: a side rail; phones: the bottom bar.
    if (MediaQuery.sizeOf(context).width >= 800) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: shell.currentIndex,
              onDestinationSelected: go,
              labelType: NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: AppLogo(size: 36),
              ),
              destinations: [
                for (final (icon, selected, label) in items)
                  NavigationRailDestination(
                    icon: Icon(icon),
                    selectedIcon: Icon(selected),
                    label: Text(label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: shell),
          ],
        ),
      );
    }
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: go,
        destinations: [
          for (final (icon, selected, label) in items)
            NavigationDestination(
              icon: Icon(icon),
              selectedIcon: Icon(selected),
              label: label,
            ),
        ],
      ),
    );
  }
}
