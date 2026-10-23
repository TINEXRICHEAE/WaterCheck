import 'package:data/data.dart' show SyncFailureKind, ThreadKind;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../features/admin/admin_screen.dart';
import '../features/admin/archived_screen.dart';
import '../features/admin/credentials_screen.dart';
import '../features/admin/typed_values_screen.dart';
import '../features/admin/device_screen.dart';
import '../features/collectors/collector_screen.dart';
import '../features/admin/system_screen.dart';
import '../features/admin/security_screen.dart';
import '../features/admin/routing_screen.dart';
import '../features/admin/places_screen.dart';
import '../features/admin/parameters_screen.dart';
import '../features/admin/cards_screen.dart';
import '../features/admin/chain_screen.dart';
import '../features/admin/phones_screen.dart';
import '../features/admin/users_screen.dart';
import '../features/admin/reference_data_screen.dart';
import '../features/alerts/alert_detail_screen.dart';
import '../features/alerts/alerts_screen.dart';
import '../features/alerts/inbox_button.dart';
import '../features/auth/pin_screens.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/collectors/collectors_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/dashboard/dashboard_state.dart';
import '../features/limits/limit_sets_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/reports/reports_screen.dart';
import '../features/sources/source_detail_screen.dart';
import '../features/sources/test_detail_screen.dart';
import '../features/sources/sources_screen.dart';
import 'console_sync.dart';
import '../l10n/app_localizations.dart';
import 'providers.dart';
import 'session.dart';
import '../features/messages/messages.dart';

/// Shown in "About" (pubspec version).
const consoleVersion = '0.1.1';

const _authRoutes = {'/sign-in', '/change-password', '/pin', '/unlock'};

/// Where the session sends someone trying to open [location], or null.
/// Stakeholders never reach the admin console (F-AUTH-5; the API refuses
/// it too).
String? sessionRedirect(ConsoleSession s, String location) {
  String? only(String route) => location == route ? null : route;
  return switch (s.phase) {
    SessionPhase.signedOut => only('/sign-in'),
    SessionPhase.mustChangePassword => only('/change-password'),
    SessionPhase.choosePin => only('/pin'),
    SessionPhase.locked => only('/unlock'),
    SessionPhase.signedIn when _authRoutes.contains(location) => '/dashboard',
    SessionPhase.signedIn when location.startsWith('/admin') && !s.isAdmin =>
      '/dashboard',
    SessionPhase.signedIn => null,
  };
}

/// Console: navigation rail on wide screens, bottom bar on phones (SPEC §11).
final routerProvider = Provider<GoRouter>((ref) {
  final session = ValueNotifier(ref.read(sessionProvider));
  ref
    ..listen(sessionProvider, (_, next) => session.value = next)
    ..onDispose(session.dispose);
  final router = GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: session,
    redirect: (context, state) =>
        sessionRedirect(session.value, state.matchedLocation),
    // An unknown address (a stale bookmark, a typo): a safe page, not a crash.
    errorBuilder: (context, state) => Scaffold(
      body: ErrorView(
        kind: ErrorKind.notFound,
        onHome: () => context.go('/dashboard'),
      ),
    ),
    routes: [
      GoRoute(path: '/sign-in', builder: (_, _) => const SignInScreen()),
      GoRoute(
        path: '/change-password',
        builder: (_, _) => const ChangePasswordScreen(),
      ),
      GoRoute(path: '/pin', builder: (_, _) => const ChoosePinScreen()),
      GoRoute(path: '/unlock', builder: (_, _) => const UnlockScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            _ConsoleShell(shell: shell, path: state.uri.path),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (_, _) => const DashboardScreen(),
                routes: [
                  GoRoute(
                    path: 'profile',
                    builder: (_, _) => const ProfileScreen(),
                  ),
                  GoRoute(
                    path: 'messages',
                    builder: (_, _) => const MessagesScreen(),
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
                    path: 'limit-sets',
                    builder: (_, _) => const LimitSetsScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/sources',
                builder: (_, _) => const SourcesScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (_, state) => SourceDetailScreen(
                      sourceId: state.pathParameters['id']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'tests/:resultId',
                        builder: (_, state) => TestDetailScreen(
                          sourceId: state.pathParameters['id']!,
                          resultId: state.pathParameters['resultId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/alerts',
                builder: (_, _) => const AlertsScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (_, state) =>
                        AlertDetailScreen(alertId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/collectors',
                builder: (_, _) => const CollectorsScreen(),
                routes: [
                  GoRoute(
                    path: ':key',
                    builder: (_, state) => CollectorScreen(
                      collectorKey: state.pathParameters['key']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                builder: (_, _) => const ReportsScreen(),
              ),
            ],
          ),
          // Must stay last: stakeholders get the first five destinations.
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin',
                builder: (_, _) => const AdminScreen(),
                routes: [
                  GoRoute(
                    path: 'reference-data',
                    builder: (_, _) => const ReferenceDataScreen(),
                  ),
                  GoRoute(
                    path: 'people',
                    builder: (_, _) => const UsersScreen(),
                  ),
                  GoRoute(
                    path: 'phones',
                    builder: (_, _) => const PhonesScreen(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        builder: (_, state) => DeviceScreen(
                          installationId: state.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'chain',
                    builder: (_, state) => ChainScreen(
                      initialAreaId: state.uri.queryParameters['area'],
                    ),
                  ),
                  GoRoute(
                    path: 'system',
                    builder: (_, _) => const SystemScreen(),
                  ),
                  GoRoute(
                    path: 'security',
                    builder: (_, _) => const SecurityScreen(),
                  ),
                  GoRoute(
                    path: 'routing',
                    builder: (_, _) => const RoutingScreen(),
                  ),
                  GoRoute(
                    path: 'places',
                    builder: (_, _) => const PlacesScreen(),
                  ),
                  GoRoute(
                    path: 'parameters',
                    builder: (_, _) => const ParametersScreen(),
                  ),
                  GoRoute(
                    path: 'typed-values',
                    builder: (_, _) => const TypedValuesScreen(),
                  ),
                  GoRoute(
                    path: 'cards',
                    builder: (_, _) => const CardsScreen(),
                  ),
                  GoRoute(
                    path: 'credentials',
                    builder: (_, _) => const CredentialsScreen(),
                  ),
                  GoRoute(
                    path: 'archived',
                    builder: (_, _) => const ArchivedScreen(),
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

/// The page above [path] in its section ("/sources/abc" → "/sources"), or
/// null on a section's first page. Every page below the first has a back
/// button (2026-10-13).
String? parentPath(String path) {
  final parts = [
    for (final p in path.split('/'))
      if (p.isNotEmpty) p,
  ];
  if (parts.length < 2) return null;
  return '/${parts.sublist(0, parts.length - 1).join('/')}';
}

/// Fetches everything on screen again: a sync, then every server list
/// (2026-10-22). The same on the web, Windows and Android.
class _RefreshButton extends ConsumerStatefulWidget {
  const _RefreshButton();

  @override
  ConsumerState<_RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends ConsumerState<_RefreshButton> {
  var _busy = false;

  Future<void> _refresh() async {
    setState(() => _busy = true);
    try {
      await ref.read(consoleSyncProvider.notifier).run(force: true);
    } finally {
      ref.read(dataVersionProvider.notifier).bump();
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: AppLocalizations.of(context).refresh,
    onPressed: _busy ? null : _refresh,
    icon: _busy
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.refresh),
  );
}

class _ConsoleShell extends ConsumerWidget {
  const _ConsoleShell({required this.shell, required this.path});

  final StatefulNavigationShell shell;
  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sync = ref.watch(syncSummaryProvider).value;
    final session = ref.watch(sessionProvider);
    final lost = ref.watch(
      consoleSyncProvider.select(
        (s) => s.last?.failure?.kind == SyncFailureKind.offline,
      ),
    );
    final parent = parentPath(path);
    final wide = MediaQuery.sizeOf(context).width >= 520;
    return AdaptiveScaffold(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // On a phone the actions need the room; the logo says enough, and
          // then names the app for screen readers.
          AppLogo(size: 28, decorative: wide),
          if (wide) ...[
            const SizedBox(width: 10),
            Flexible(
              child: Text(l10n.appTitle, overflow: TextOverflow.ellipsis),
            ),
          ],
        ],
      ),
      onBack: parent == null ? null : () => context.go(parent),
      selectedIndex: shell.currentIndex,
      onDestinationSelected: (i) =>
          shell.goBranch(i, initialLocation: i == shell.currentIndex),
      actions: [
        SyncIndicator(
          compact: true,
          pending: sync?.pending ?? 0,
          rejected: sync?.rejected ?? 0,
        ),
        const _RefreshButton(),
        const MessagesButton(),
        const InboxButton(),
        const _AccountButton(),
      ],
      destinations: [
        AdaptiveDestination(
          icon: Icons.space_dashboard_outlined,
          selectedIcon: Icons.space_dashboard,
          label: l10n.navDashboard,
        ),
        AdaptiveDestination(
          icon: Icons.water_drop_outlined,
          selectedIcon: Icons.water_drop,
          label: l10n.navSources,
        ),
        AdaptiveDestination(
          icon: Icons.notifications_outlined,
          selectedIcon: Icons.notifications,
          label: l10n.navAlerts,
        ),
        AdaptiveDestination(
          icon: Icons.groups_outlined,
          selectedIcon: Icons.groups,
          label: l10n.navCollectors,
        ),
        AdaptiveDestination(
          icon: Icons.description_outlined,
          selectedIcon: Icons.description,
          label: l10n.navReports,
        ),
        if (session.isAdmin)
          AdaptiveDestination(
            icon: Icons.admin_panel_settings_outlined,
            selectedIcon: Icons.admin_panel_settings,
            label: l10n.navAdmin,
          ),
      ],
      body: Column(
        children: [
          if (session.offline)
            const _OfflineBanner()
          else if (lost)
            const _ConnectionLostBanner(),
          Expanded(
            // Very large screens: pages keep a readable width, centred;
            // the sources page (and its map) uses the whole screen.
            child: path == '/sources'
                ? shell
                : Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1440),
                      child: shell,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _OfflineBanner extends ConsumerWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Icon(Icons.cloud_off, color: scheme.onTertiaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.offlineBanner,
                style: TextStyle(color: scheme.onTertiaryContainer),
              ),
            ),
            TextButton(
              onPressed: () => ref.read(sessionProvider.notifier).reconnect(),
              child: Text(l10n.offlineRetry),
            ),
          ],
        ),
      ),
    );
  }
}

/// The server stopped answering mid-session (web especially): the screens
/// keep showing the last synced data, read-only changes queue up.
class _ConnectionLostBanner extends ConsumerWidget {
  const _ConnectionLostBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: Material(
        color: scheme.tertiaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Icon(Icons.cloud_off, color: scheme.onTertiaryContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.connectionLost,
                  style: TextStyle(color: scheme.onTertiaryContainer),
                ),
              ),
              TextButton(
                onPressed: () =>
                    ref.read(consoleSyncProvider.notifier).run(force: true),
                child: Text(l10n.offlineRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountButton extends ConsumerWidget {
  const _AccountButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(sessionProvider).me;
    return PopupMenuButton<void>(
      tooltip: l10n.accountMenu,
      icon: const Icon(Icons.account_circle_outlined),
      itemBuilder: (context) => [
        PopupMenuItem<void>(
          enabled: false,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(me?.fullName ?? ''),
            subtitle: Text(
              '${me?.username ?? ''}\n'
              '${me?.role == 'it_admin' ? l10n.roleAdmin : l10n.roleStakeholder}',
            ),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<void>(
          onTap: () => context.go('/dashboard/limit-sets'),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.tune),
            title: Text(l10n.navLimitSets),
          ),
        ),
        PopupMenuItem<void>(
          onTap: () => context.go('/dashboard/profile'),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.manage_accounts_outlined),
            title: Text(l10n.navProfile),
          ),
        ),
        PopupMenuItem<void>(
          onTap: () => showWaterCheckAbout(
            context,
            appName: l10n.appTitle,
            version: consoleVersion,
          ),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.accountAbout),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<void>(
          onTap: () async {
            // Unsent changes are lost when the web session ends.
            final pending = ref.read(syncSummaryProvider).value?.pending ?? 0;
            if (pending > 0 &&
                !await confirmAction(
                  context,
                  title: l10n.signOutConfirmTitle,
                  message: l10n.signOutConfirmBody(pending),
                  confirm: l10n.accountSignOut,
                  destructive: true,
                )) {
              return;
            }
            await ref.read(sessionProvider.notifier).signOut();
          },
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout),
            title: Text(l10n.accountSignOut),
          ),
        ),
      ],
    );
  }
}
