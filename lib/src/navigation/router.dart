import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:onboard_client/pages/main/aroundme.page.dart';
import 'package:onboard_client/pages/main/realtime.page.dart';
import 'package:onboard_client/pages/main/servicechanges.page.dart';
import 'package:onboard_client/pages/other/404.page.dart';
import 'package:onboard_client/pages/other/details/branch.line.page.dart';
import 'package:onboard_client/pages/other/details/line.page.dart';
import 'package:onboard_client/pages/other/details/stop.page.dart';
import 'package:onboard_client/pages/other/search.page.dart';
import 'package:onboard_client/pages/other/settings/add.notifications.settings.page.dart'; // Import for AddNotificationPage
import 'package:onboard_client/pages/other/settings/favourites.settings.page.dart';
import 'package:onboard_client/pages/other/settings/linesinfo.settings.page.dart';
import 'package:onboard_client/pages/other/settings/notifications.settings.page.dart';
import 'package:onboard_client/pages/other/settings/permissions.settings.page.dart';
import 'package:onboard_client/pages/other/settings/settings.page.dart';
import 'package:onboard_client/pages/other/status/metro.status.page.dart';
import 'package:onboard_client/pages/other/status/surface.status.page.dart';
import 'package:onboard_client/src/navigation/shellnav.dart'; // Your rewritten SystemShell
import 'package:onboard_sdk/onboard_sdk.dart';

import 'src/shellnav.sub.widget.dart';

class OnboardRouter {
  // --- Navigator Keys ---
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKeyRealtime = GlobalKey<NavigatorState>(
    debugLabel: 'ShellRealtime',
  );
  static final _shellNavigatorKeyAroundMe = GlobalKey<NavigatorState>(
    debugLabel: 'ShellAroundMe',
  );
  static final _shellNavigatorKeyServiceChanges = GlobalKey<NavigatorState>(
    debugLabel: 'ShellServiceChanges',
  );

  static final _shellSubNavigatorKeyStopDetails = GlobalKey<NavigatorState>(
    debugLabel: 'ShellStopDetails',
  );
  static final _shellSubNavigatorKeyLineDetails = GlobalKey<NavigatorState>(
    debugLabel: 'ShellLineDetails',
  );
  static final _shellSubNavigatorKeyMetroStatus = GlobalKey<NavigatorState>(
    debugLabel: 'ShellMetroStatus',
  );

  // --- Navigation Data ---
  static final List<ShellNavigationDest> _pageDestinations = [
    ShellNavigationDest(
      text: 'Realtime',
      icon: const Icon(opticalSize: 24, Symbols.crisis_alert_rounded),
      route: '/',
    ),
    ShellNavigationDest(
      text: 'Intorno a te',
      icon: const Icon(opticalSize: 24, Symbols.near_me_rounded),
      route: '/aroundme',
    ),
    ShellNavigationDest(
      text: 'Cambiamenti',
      icon: const Icon(opticalSize: 24, Symbols.campaign_rounded),
      route: '/servicechanges',
    ),
  ];

  // --- The GoRouter instance ---
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    onException: (_, _, router) => router.go('/404'),
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return SystemShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/404',
            builder: (context, state) {
              return const Page404();
            },
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) {
              return const SettingsPage();
            },
          ),
          GoRoute(
            path: '/settings/linesinformations',
            builder: (context, state) => LinesInfoPage(),
          ),
          GoRoute(
            path: '/settings/favourites',
            builder: (context, state) => FavouritesSettingsPage(),
          ),
          GoRoute(
            path: '/settings/permissions',
            builder: (context, state) => PermissionsSettingsPage(),
          ),
          GoRoute(
            path: '/settings/notifications',
            builder: (context, state) => NotificationsSettingsPage(),
          ),
          GoRoute(
            // New route for adding notifications
            path: '/settings/notifications/add',
            builder: (context, state) => const AddNotificationsSettingsPage(),
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) {
              return const SearchPage();
            },
          ),
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return ShellNavigation(
                navigationShell: navigationShell,
                pageData: _pageDestinations,
              );
            },
            branches: [
              StatefulShellBranch(
                navigatorKey: _shellNavigatorKeyRealtime,
                routes: [
                  GoRoute(
                    path: '/',
                    pageBuilder: (context, state) =>
                        const NoTransitionPage(child: RealtimePage()),
                  ),
                ],
              ),
              StatefulShellBranch(
                navigatorKey: _shellNavigatorKeyAroundMe,
                routes: [
                  GoRoute(
                    path: '/aroundme',
                    pageBuilder: (context, state) =>
                        const NoTransitionPage(child: AroundMePage()),
                  ),
                ],
              ),
              StatefulShellBranch(
                navigatorKey: _shellNavigatorKeyServiceChanges,
                routes: [
                  GoRoute(
                    path: '/servicechanges',
                    pageBuilder: (context, state) =>
                        const NoTransitionPage(child: ServiceChangesPage()),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/details/stops/:stopId',
            pageBuilder: (context, state) => NoTransitionPage(
              child: StopDetailsPage(stopId: state.pathParameters['stopId']!),
            ),
          ),
          GoRoute(
            path: '/details/lines/:lineId',
            pageBuilder: (context, state) {
              final bool =
                  state.uri.queryParameters["showBranches"].toString() ==
                  'true';
              if (bool) {
                return NoTransitionPage(
                  child: BranchedLineDetailsPage(
                    lineId: state.pathParameters['lineId']!,
                  ),
                );
              }
              return NoTransitionPage(
                child: LineDetailsPage(lineId: state.pathParameters['lineId']!),
              );
            },
          ),
          GoRoute(
            path: '/status/metro',
            pageBuilder: (context, state) => NoTransitionPage(
              child: ShellSubNavigation(
                child: MetroStatusPage(status: state.extra as MetroStatus),
              ),
            ),
          ),
          GoRoute(
            path: '/status/surface',
            pageBuilder: (context, state) =>
                NoTransitionPage(child: SurfaceStatusPage()),
          ),
        ],
      ),
    ],
  );
}
