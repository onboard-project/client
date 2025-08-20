import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onboard_client/src/utils/router/shellnavigation.dart';

class OnboardRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();

  BuildContext context;

  OnboardRouter({required this.context});

  static GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    onException: (context, state, router) {
      router.go('/404');
    },
    routes: _routes,
  );

  static final List<RouteBase> _routes = [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ShellNavigation(
          pageData: _pages(context),
          fixedActions: [
            MenuAnchor(
              builder: (context, controller, child) {
                return IconButton(
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  icon: const Icon(Icons.more_vert),
                );
              },
              menuChildren: [
                MenuItemButton(
                  child: const Text('Impostazioni'),
                  onPressed: () {
                    context.push('/settings');
                  },
                ),
              ],
            ),
          ],
          child: child,
        );
      },
      routes: [
        // This screen is displayed on the ShellRoute's Navigator.
        GoRoute(
          path: '/',
          builder: (context, state) {
            return ListView.builder(
              itemCount: 10,
              itemBuilder: (context, i) {
                return SizedBox(
                  height: 100,
                  child: Card(child: Text(i.toString())),
                );
              },
            );
          },
        ),
        // Displayed ShellRoute's Navigator.
        GoRoute(
          path: '/search',
          builder: (BuildContext context, GoRouterState state) {
            return Placeholder();
          },
        ),
        GoRoute(
          path: '/realtime',
          builder: (BuildContext context, GoRouterState state) {
            return Placeholder();
          },
        ),
      ],
    ),
  ];

  static List<ShellNavigationDest> _pages(BuildContext context) {
    return [
      ShellNavigationDest(
        appBarTitle: const Text("Home"),
        text: 'Home',
        icon: const Icon(Icons.home_rounded),
        route: '/',
        fab: ShellNavigationFAB(
          icon: Icon(Icons.abc),
          label: "Letsgo",
          onPressed: () {},
        ),
      ),
      ShellNavigationDest(
        appBarTitle: const Text("Libri"),
        text: 'Cerca',
        icon: const Icon(Icons.bookmark_rounded),
        route: '/search',
      ),
      ShellNavigationDest(
        appBarTitle: const Text("Prestiti"),
        text: 'Realtime',
        icon: const Icon(Icons.schedule_rounded),
        route: '/realtime',
      ),
    ];
  }
}
