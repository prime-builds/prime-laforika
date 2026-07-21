import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:laforika/app/router/routes.dart';
import 'package:laforika/features/home/home.dart';

/// Single application [GoRouter] owned by the composition root.
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(initialLocation: homeRoutePath, routes: appRoutes());
});
