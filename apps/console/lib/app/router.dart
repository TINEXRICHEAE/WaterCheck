import 'package:data/data.dart' show SyncFailureKind, ThreadKind;
import 'package:domain/domain.dart' show AppSide;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../features/admin/admin_screen.dart';
import '../features/admin/archived_screen.dart';
import '../features/admin/codes_screen.dart';
import '../features/admin/credentials_screen.dart';
import '../features/admin/typed_values_screen.dart';
import '../features/admin/device_screen.dart';
import '../features/collectors/collector_screen.dart';
import '../features/auth/sign_up_screen.dart';
import '../features/auth/switch_side_screen.dart';
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
import '../features/profile/legal_screen.dart';
import '../features/research/research_mode.dart';
import '../features/research/research_analysis.dart';
import '../features/research/research_collector.dart';
import '../features/research/research_collectors.dart';
import '../features/research/research_dashboard.dart';
import '../features/research/research_forms.dart';
import '../features/research/research_more.dart';
import '../features/research/research_records.dart';
import '../features/research/research_state.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/settings_screen.dart';
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

const _authRoutes = {
  '/sign-in',
  '/sign-up',
  '/change-password',
  '/pin',
  '/unlock',
};

/// Where the session sends someone trying to open [location], or null;
/// '/dashboard' stands for the home of the side in use.
/// - Stakeholders never reach the admin pages (F-AUTH-5; the API refuses
///   them too).
/// - Each account stays on its own side (ADR-031): water accounts never see
///   research pages and research accounts never see water pages. IT admins
///   see both.
String? sessionRedirect(ConsoleSession s, String location) {
  String? only(String route) => location == route ? null : route;
  final research = location == '/research' || location.startsWith('/research/');
  final shared =
      location.startsWith('/join/') || location.startsWith('/switch/');
  return switch (s.phase) {
    SessionPhase.signedOut =>
      location == '/sign-in' || location == '/sign-up' ? null : '/sign-in',
    SessionPhase.mustChangePassword => only('/change-password'),
    SessionPhase.choosePin => only('/pin'),
    SessionPhase.locked => only('/unlock'),
    // Each side's current documents, accepted once (ADR-026, ADR-031).
    SessionPhase.signedIn when s.legalDue.isNotEmpty => only('/legal'),
    SessionPhase.signedIn
        when _authRoutes.contains(location) || location == '/legal' =>
      '/dashboard',
    SessionPhase.signedIn
        when (location.startsWith('/admin') ||
                location.startsWith('/research/admin')) &&
            !s.isAdmin =>
      '/dashboard',
    SessionPhase.signedIn when shared => null,
    SessionPhase.signedIn when s.side == AppSide.water && research =>
      '/dashboard',
    SessionPhase.signedIn when s.side == AppSide.research && !research =>
      '/research',
    SessionPhase.signedIn => null,
  };
}

/// Console: navigation rail on wide screens, bottom bar on phones (SPEC §11).
final routerProvider = Provider<GoRouter>((ref) {
  final session = ValueNotifier(ref.read(sessionProvider));
  ref
    ..listen(sessionProvider, (_, next) => session.value = next)
    ..onDispose(session.dispose);
  // Water testing or research (ADR-030): each starts on its own page.
  ConsoleMode mode() => ref.read(activeModeProvider);
  final router = GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: session,
    redirect: (context, state) {
      final to = sessionRedirect(session.value, state.matchedLocation);
      return to == '/dashboard' ? homeFor(mode()) : to;
    },
    // An unknown address (a stale bookmark, a typo): a safe page that
    // goes back to the home of the side in use, not a crash.
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go(homeFor(mode()))),
      ),
      body: ErrorView(
        kind: ErrorKind.notFound,
        onHome: () => context.go(homeFor(mode())),
      ),
    ),
    routes: [
      GoRoute(path: '/sign-in', builder: (_, _) => const SignInScreen()),
      GoRoute(path: '/sign-up', builder: (_, _) => const SignUpScreen()),
      // The full switch for someone without an account there (ADR-031).
      GoRoute(
        path: '/switch/:side',
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: () => context.go('/dashboard')),
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: RelativeWidth(
              tablet: 0.8,
              desktop: 0.5,
              child: SwitchSideScreen(
                side:
                    AppSide.parse(state.pathParameters['side']) ??
                    AppSide.research,
              ),
            ),
          ),
        ),
      ),
      // Joining the other side from a signed-in account (ADR-031).
      GoRoute(
        path: '/join/:side',
        builder: (context, state) {
          final side =
              AppSide.parse(state.pathParameters['side']) ?? AppSide.research;
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: () => context.go('/dashboard')),
            ),
            body: Align(
              alignment: Alignment.topCenter,
              child: RelativeWidth(
                tablet: 0.8,
                desktop: 0.5,
                child: JoinSideScreen(side: side),
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: '/change-password',
        builder: (_, _) => const ChangePasswordScreen(),
      ),
      GoRoute(path: '/pin', builder: (_, _) => const ChoosePinScreen()),
      GoRoute(path: '/unlock', builder: (_, _) => const UnlockScreen()),
      GoRoute(path: '/legal', builder: (_, _) => const LegalScreen()),
      // Research (ADR-030): its own menu, laid out like water testing's.
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            _ResearchShell(shell: shell, path: state.uri.path),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/research',
                builder: (_, _) => const ResearchDashboardScreen(),
                routes: [
                  GoRoute(
                    path: 'team',
                    builder: (_, _) => const ResearchTeamScreen(),
                  ),
                  GoRoute(
                    path: 'messages',
                    builder: (_, _) => const ResearchMessagesScreen(),
                  ),
                  GoRoute(
                    path: 'profile',
                    builder: (_, _) => const ProfileScreen(),
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (_, _) => const SettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/research/records',
                builder: (_, state) => ResearchRecordsScreen(
                  key: ValueKey(state.uri.query),
                  formId: state.uri.queryParameters['form'],
                  collectorKey: state.uri.queryParameters['collector'],
                  map: state.uri.queryParameters['map'] == '1',
                ),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (_, state) => ResearchRecordScreen(
                      recordId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/research/forms',
                builder: (_, _) => const ResearchFormsScreen(),
                routes: [
                  GoRoute(
                    path: 'library',
                    builder: (_, _) => const ResearchLibraryScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (_, state) =>
                        ResearchFormScreen(formId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/research/collectors',
                builder: (_, _) => const ResearchCollectorsScreen(),
                routes: [
                  GoRoute(
                    path: ':key',
                    builder: (_, state) => ResearchCollectorScreen(
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
                path: '/research/analysis',
                builder: (_, state) => ResearchAnalysisScreen(
                  formId: state.uri.queryParameters['form'],
                ),
              ),
            ],
          ),
          // Must stay last: only IT admins get it.
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/research/admin',
                builder: (_, _) => const ResearchAdminScreen(),
                // The water admin pages, for research's own people and
                // devices (they read their side from the address).
                routes: [
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
                    path: 'credentials',
                    builder: (_, _) => const CredentialsScreen(),
                  ),
                  GoRoute(
                    path: 'security',
                    builder: (_, _) => const SecurityScreen(),
                  ),
                  GoRoute(
                    path: 'system',
                    builder: (_, _) => const SystemScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
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
                    path: 'settings',
                    builder: (_, _) => const SettingsScreen(),
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
                    path: 'codes',
                    builder: (_, _) => const CodesScreen(),
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
        const SwitchModeButton(to: ConsoleMode.research),
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
                    // Most of a large screen, never a fixed width.
                    child: RelativeWidth(
                      tablet: 1,
                      desktop: 0.94,
                      child: shell,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Research's menu pages: no back button there.
const _researchMenu = {
  '/research',
  '/research/records',
  '/research/forms',
  '/research/collectors',
  '/research/analysis',
  '/research/admin',
};

/// The page above [path] in Research ("/research/records/x" →
/// "/research/records", "/research/team" → "/research"); null on each menu
/// page. Every page below a menu page has a back button.
String? researchParentPath(String path) {
  if (_researchMenu.contains(path)) return null;
  final parts = [
    for (final p in path.split('/'))
      if (p.isNotEmpty) p,
  ];
  if (parts.length < 2) return null;
  return '/${parts.sublist(0, parts.length - 1).join('/')}';
}

/// Research: the same frame as water testing (rail or bottom bar, the same
/// actions), with its own menu (ADR-030; 2026-10-27).
class _ResearchShell extends ConsumerWidget {
  const _ResearchShell({required this.shell, required this.path});

  final StatefulNavigationShell shell;
  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider);
    final parent = researchParentPath(path);
    final wide = MediaQuery.sizeOf(context).width >= 520;
    final project = ref.watch(projectDetailProvider).value;
    return AdaptiveScaffold(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppLogo(size: 28, decorative: wide),
          if (wide) ...[
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                project == null
                    ? l10n.researchAppTitle
                    : '${l10n.researchAppTitle} · ${project.code}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
      onBack: parent == null ? null : () => context.go(parent),
      selectedIndex: shell.currentIndex,
      onDestinationSelected: (i) =>
          shell.goBranch(i, initialLocation: i == shell.currentIndex),
      actions: const [
        SwitchModeButton(to: ConsoleMode.water),
        _RefreshButton(),
        ResearchMessagesButton(),
        _AccountButton(research: true),
      ],
      destinations: [
        AdaptiveDestination(
          icon: Icons.space_dashboard_outlined,
          selectedIcon: Icons.space_dashboard,
          label: l10n.navDashboard,
        ),
        AdaptiveDestination(
          icon: Icons.assignment_outlined,
          selectedIcon: Icons.assignment,
          label: l10n.researchRecords,
        ),
        AdaptiveDestination(
          icon: Icons.dynamic_form_outlined,
          selectedIcon: Icons.dynamic_form,
          label: l10n.researchFormsTitle,
        ),
        AdaptiveDestination(
          icon: Icons.groups_outlined,
          selectedIcon: Icons.groups,
          label: l10n.navCollectors,
        ),
        AdaptiveDestination(
          icon: Icons.insights_outlined,
          selectedIcon: Icons.insights,
          label: l10n.researchAnalysis,
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
          if (session.offline) const _OfflineBanner(),
          Expanded(
            // The records map uses the whole screen, as Sources does.
            child: path == '/research/records'
                ? shell
                : Align(
                    alignment: Alignment.topCenter,
                    child: RelativeWidth(
                      tablet: 1,
                      desktop: 0.94,
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
  const _AccountButton({this.research = false});

  /// In Research: its own profile and settings pages, no limit sets.
  final bool research;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider);
    final me = session.me;
    final home = research ? '/research' : '/dashboard';
    final here = research ? AppSide.research : AppSide.water;
    final names = UiKitLocalizations.of(context);
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
              '${me?.role == 'it_admin' ? l10n.roleAdmin : l10n.roleOnSide(sideName(names, here))}',
            ),
          ),
        ),
        const PopupMenuDivider(),
        // The full switch, for everyone (ADR-031).
        PopupMenuItem<void>(
          onTap: () => switchToSide(context, ref, ConsoleMode.of(here.other)),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.swap_horiz),
            title: Text(l10n.switchTo(sideName(names, here.other))),
          ),
        ),
        if (!research)
          PopupMenuItem<void>(
            onTap: () => context.go('/dashboard/limit-sets'),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.tune),
              title: Text(l10n.navLimitSets),
            ),
          ),
        PopupMenuItem<void>(
          onTap: () => context.go('$home/profile'),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.manage_accounts_outlined),
            title: Text(l10n.navProfile),
          ),
        ),
        PopupMenuItem<void>(
          onTap: () => context.go('$home/settings'),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.settings_outlined),
            title: Text(l10n.navSettings),
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
