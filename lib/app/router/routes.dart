import 'package:go_router/go_router.dart';

import 'package:laforika/features/home/home.dart';

/// Aggregates feature public route registries into one list.
List<RouteBase> appRoutes() => <RouteBase>[...homeRoutes()];
