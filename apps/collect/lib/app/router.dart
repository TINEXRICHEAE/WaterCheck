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
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.water_drop_outlined),
            selectedIcon: const Icon(Icons.water_drop),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.cloud_upload_outlined),
            selectedIcon: const Icon(Icons.cloud_upload),
            label: l10n.navSync,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
