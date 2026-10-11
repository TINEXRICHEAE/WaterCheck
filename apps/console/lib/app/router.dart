import 'package:data/data.dart' show SyncFailureKind;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../features/admin/admin_screen.dart';
import '../features/admin/reference_data_screen.dart';
import '../features/alerts/alert_detail_screen.dart';
import '../features/alerts/alerts_screen.dart';
import '../features/alerts/inbox_button.dart';
import '../features/auth/pin_screens.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/collectors/collectors_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/placeholder_section.dart';
import '../features/profile/profile_screen.dart';
import '../features/sources/source_detail_screen.dart';
import '../features/sources/sources_screen.dart';
import 'console_sync.dart';
import '../l10n/app_localizations.dart';
import 'providers.dart';
import 'session.dart';

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
    routes: [
      GoRoute(path: '/sign-in', builder: (_, _) => const SignInScreen()),
      GoRoute(
        path: '/change-password',
        builder: (_, _) => const ChangePasswordScreen(),
      ),
      GoRoute(path: '/pin', builder: (_, _) => const ChoosePinScreen()),
      GoRoute(path: '/unlock', builder: (_, _) => const UnlockScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _ConsoleShell(shell: shell),
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
              ),
            ],
          ),
          _branch(
            '/reports',
            (l) => PlaceholderSection(
              title: l.navReports,
              hint: l.reportsHint,
              phase: 'P10',
            ),
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

StatefulShellBranch _branch(
  String path,
  Widget Function(AppLocalizations l10n) page,
) => StatefulShellBranch(
  routes: [
    GoRoute(
      path: path,
      builder: (context, _) => page(AppLocalizations.of(context)),
    ),
  ],
);

class _ConsoleShell extends ConsumerWidget {
  const _ConsoleShell({required this.shell});

  final StatefulNavigationShell shell;

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
    return AdaptiveScaffold(
      title: Text(l10n.appTitle),
      selectedIndex: shell.currentIndex,
      onDestinationSelected: (i) =>
          shell.goBranch(i, initialLocation: i == shell.currentIndex),
      actions: [
        SyncIndicator(
          compact: true,
          pending: sync?.pending ?? 0,
          rejected: sync?.rejected ?? 0,
        ),
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
          Expanded(child: shell),
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
          onTap: () => context.go('/dashboard/profile'),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.tune),
            title: Text(l10n.navProfile),
          ),
        ),
        PopupMenuItem<void>(
          onTap: () => ref.read(sessionProvider.notifier).signOut(),
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
