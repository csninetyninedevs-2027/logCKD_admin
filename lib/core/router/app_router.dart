import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/state/auth_provider.dart';
import '../../features/content/presentation/facility_list_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/foods/presentation/food_list_screen.dart';
import '../../features/system_status/presentation/system_status_screen.dart';
import '../../features/user_map/presentation/user_concentration_screen.dart';
import '../../features/users/presentation/user_detail_screen.dart';
import '../../features/users/presentation/user_list_screen.dart';
import '../../shared/widgets/admin_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: GoRouterRefreshStream(ref),
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LoginScreen(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AdminShell(
            selectedIndex: _selectedIndexForLocation(state.uri.path),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/users',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: UserListScreen(),
            ),
            routes: [
              GoRoute(
                path: ':id',
                pageBuilder: (context, state) => NoTransitionPage(
                  child: UserDetailScreen(
                    userId: state.pathParameters['id']!,
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/facilities',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FacilityListScreen(),
            ),
          ),
          GoRoute(
            path: '/foods',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FoodListScreen(),
            ),
          ),
          GoRoute(
            path: '/user-concentration',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: UserConcentrationScreen(),
            ),
          ),
          GoRoute(
            path: '/system-status',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SystemStatusScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});

int _selectedIndexForLocation(String path) {
  if (path.startsWith('/users')) return 1;
  if (path.startsWith('/facilities')) return 2;
  if (path.startsWith('/foods')) return 3;
  if (path.startsWith('/user-concentration')) return 4;
  if (path.startsWith('/system-status')) return 5;
  return 0;
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Ref ref) {
    ref.listen(
      authStateProvider,
      (previous, next) {
        notifyListeners();
      },
    );
  }
}
