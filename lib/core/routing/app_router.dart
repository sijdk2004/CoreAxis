import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/auth_provider.dart';
// Placeholder for missing screens

import '../../features/platform_shell/presentation/platform_shell.dart';
import '../../features/platform/presentation/platform_home_screen.dart';
import '../../features/platform/presentation/tenants_screen.dart';
import '../../features/platform/presentation/organizations_screen.dart';
import '../../features/platform/presentation/create_organization_screen.dart';
import '../../features/platform/presentation/organization_detail_screen.dart';
import '../../features/platform/presentation/branch_management_screen.dart';
import '../../features/platform/presentation/department_management_screen.dart';
import '../../features/platform/presentation/organization_analytics_screen.dart';
import '../../features/platform/presentation/create_tenant_screen.dart';
import '../../features/platform/presentation/tenant_detail_screen.dart';
import '../../features/platform/presentation/tenant_analytics_screen.dart';
import '../../features/platform/presentation/tenant_settings_screen.dart';
import '../../features/platform/presentation/subscription_screen.dart';
import '../../features/platform/presentation/platform_users_screen.dart';
import '../../features/platform/presentation/create_user_screen.dart';
import '../../features/platform/presentation/user_detail_screen.dart';
import '../../features/platform/presentation/user_activity_screen.dart';
import '../../features/platform/presentation/user_profile_screen.dart';
import '../../features/platform/presentation/user_sessions_screen.dart';
import '../../features/platform/presentation/user_invitations_screen.dart';
import '../../features/platform/presentation/roles_permissions_screen.dart';
import '../../features/platform/presentation/role_detail_screen.dart';
import '../../features/platform/presentation/permissions_screen.dart';
import '../../features/platform/presentation/role_permission_matrix_screen.dart';
import '../../features/platform/presentation/user_role_assignment_screen.dart';
import '../../features/platform/presentation/permission_groups_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final _platformShellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'platformShell');

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authProvider,
      (_, __) => notifyListeners(),
    );
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    navigatorKey: _rootNavigatorKey,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuth = authState.status == AuthStateStatus.authenticated;
      final isGoingToAuth = state.matchedLocation == '/login' || state.matchedLocation == '/forgot-password';

      if (authState.status == AuthStateStatus.initial) {
        return null; // wait for initial state check
      }

      if (state.matchedLocation == '/') {
        return isAuth ? '/platform/home' : '/login';
      }

      if (!isAuth && !isGoingToAuth) {
        return '/login';
      }
      if (isAuth && isGoingToAuth) {
        return null; // Let the login screen handle specific app routing
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/',
        redirect: (context, state) => '/platform/home',
      ),
      ShellRoute(
        navigatorKey: _platformShellNavigatorKey,
        builder: (context, state, child) {
          return PlatformShell(child: child);
        },
        routes: [
          GoRoute(path: '/platform/home', builder: (context, state) => const PlatformHomeScreen()),

          GoRoute(
            path: '/platform/rbac/roles/:id', 
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return RoleDetailScreen(roleId: id);
            },
          ),
          GoRoute(path: '/platform/rbac/permissions', builder: (context, state) => const PermissionsScreen()),
          GoRoute(path: '/platform/rbac/matrix', builder: (context, state) => const RolePermissionMatrixScreen()),
          GoRoute(path: '/platform/rbac/user-role-assignment', builder: (context, state) => const UserRoleAssignmentScreen()),
          GoRoute(path: '/platform/rbac/permission-groups', builder: (context, state) => const PermissionGroupsScreen()),

          GoRoute(path: '/platform/users', builder: (context, state) => const PlatformUsersScreen()),
          GoRoute(path: '/platform/users/new', builder: (context, state) => const CreateUserScreen()),
          GoRoute(path: '/platform/users/invitations', builder: (context, state) => const UserInvitationsScreen()),
          GoRoute(
            path: '/platform/users/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return UserDetailScreen(userId: id);
            },
          ),
          GoRoute(
            path: '/platform/users/:id/activity',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return UserActivityScreen(userId: id);
            },
          ),
          GoRoute(
            path: '/platform/users/:id/profile',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return UserProfileScreen(userId: id);
            },
          ),
          GoRoute(
            path: '/platform/users/:id/sessions',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return UserSessionsScreen(userId: id);
            },
          ),
          GoRoute(path: '/platform/organizations/new', builder: (context, state) => const CreateOrganizationScreen()),
          GoRoute(
            path: '/platform/organizations/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return OrganizationDetailScreen(orgId: id);
            },
            routes: [
              GoRoute(
                path: 'branches',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return BranchManagementScreen(orgId: id);
                },
              ),
              GoRoute(
                path: 'departments',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return DepartmentManagementScreen(orgId: id);
                },
              ),
              GoRoute(
                path: 'analytics',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return OrganizationAnalyticsScreen(orgId: id);
                },
              ),
            ],
          ),
          GoRoute(path: '/platform/tenants/new', builder: (context, state) => const CreateTenantScreen()),
          GoRoute(
            path: '/platform/tenants/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return TenantDetailScreen(tenantId: id);
            },
            routes: [
              GoRoute(
                path: 'subscription',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return SubscriptionScreen(tenantId: id);
                },
              ),
              GoRoute(
                path: 'analytics',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return TenantAnalyticsScreen(tenantId: id);
                },
              ),
              GoRoute(
                path: 'settings',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return TenantSettingsScreen(tenantId: id);
                },
              ),
            ]
          ),
          GoRoute(path: '/platform/organizations', builder: (context, state) => const OrganizationsScreen()),
          GoRoute(path: '/platform/users', builder: (context, state) => const PlatformUsersScreen()),
          GoRoute(path: '/platform/roles', builder: (context, state) => const RolesPermissionsScreen()),
          GoRoute(path: '/platform/rbac/roles', builder: (context, state) => const RolesPermissionsScreen()),
          GoRoute(path: '/platform/tenants', builder: (context, state) => const TenantsScreen()),

        ],
      ),

    ],
  );
});

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        surfaceTintColor: Colors.transparent,
      ),
      body: Center(child: Text('Building $title...', style: Theme.of(context).textTheme.headlineMedium)),
    );
  }
}
