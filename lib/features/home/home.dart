import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:laforika/features/home/presentation/home_screen.dart';

export 'package:laforika/features/home/presentation/home_screen.dart'
    show HomeScreen;

/// Public Home route name constant.
const String homeRouteName = 'home';

/// Public Home route path constant.
const String homeRoutePath = '/';

/// Registered internal paths owned by the Home feature.
Set<String> get homeRegisteredPaths => <String>{homeRoutePath};

/// Guest-accessible public paths owned by the Home feature.
Set<String> get homePublicPaths => <String>{homeRoutePath};

/// Home feature route registry for `app/router` aggregation.
List<RouteBase> homeRoutes() {
  return <RouteBase>[
    GoRoute(
      name: homeRouteName,
      path: homeRoutePath,
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
  ];
}
