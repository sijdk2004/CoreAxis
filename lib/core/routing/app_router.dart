import 'package:flutter/material.dart';
import '../../features/production/presentation/production_tracking_screen.dart';
import '../../features/production/presentation/production_board_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/dashboard/presentation/sales_dashboard_screen.dart';
import '../../features/dashboard/presentation/manufacturing_dashboard_screen.dart';
import '../../features/dashboard/presentation/delivery_dashboard_screen.dart';
import '../../features/catalog/presentation/catalog_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/customers/presentation/customers_screen.dart';
import '../../features/inquiries/presentation/inquiries_screen.dart';
import '../../features/quotations/presentation/quotations_screen.dart';
import '../../features/quotations/presentation/quotation_form_screen.dart';
import '../../features/quotations/presentation/quotation_view_screen.dart';
import '../../features/customers/presentation/customer_form_screen.dart';
import '../../features/customers/presentation/customer_view_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/profile_screen.dart';
import '../../features/settings/presentation/security_screen.dart';
import '../../features/settings/presentation/about_screen.dart';
import '../../features/rol/presentation/roles_screen.dart';
import '../../features/rol/presentation/role_details_screen.dart';
import '../../features/usr/presentation/users_screen.dart';
import '../../features/usr/presentation/user_form_screen.dart';
import '../../features/usr/presentation/user_view_screen.dart';
import '../../features/sales_orders/presentation/sales_orders_screen.dart';
import '../../features/sales_orders/presentation/sales_order_view_screen.dart';
import '../../features/sales_orders/presentation/sales_order_edit_screen.dart';
import '../../features/master_data/presentation/master_data_screen.dart';
import '../../features/bom/presentation/bom_list_screen.dart';
import '../../features/production/presentation/production_order_list_screen.dart';
import '../../features/production/presentation/production_order_create_screen.dart';
import '../../features/production/presentation/production_order_view_screen.dart';
import '../../features/production/presentation/production_board_screen.dart';
import '../../features/production/presentation/production_tracking_screen.dart';
import '../../features/production/presentation/production_tracking_list_screen.dart';
import '../../features/bom/presentation/bom_form_screen.dart';
import '../../features/bom/presentation/bom_view_screen.dart';
import '../../features/production/presentation/production_screen.dart';
import '../../features/job_orders/presentation/job_orders_screen.dart';
import '../../features/inventory/presentation/inventory_screen.dart';
import '../../features/delivery/presentation/delivery_list_screen.dart';
import '../../features/delivery/presentation/delivery_create_screen.dart';
import '../../features/delivery/presentation/delivery_view_screen.dart';
import '../../features/invoices/presentation/invoices_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/finance/presentation/financial_overview_screen.dart';
import '../../features/catalog/presentation/category_list_screen.dart';
import '../../features/catalog/presentation/category_form_screen.dart';
import '../../features/catalog/presentation/category_view_screen.dart';
import '../../features/catalog/presentation/product_form_screen.dart';
import '../../features/catalog/presentation/product_view_screen.dart';
import '../../features/auth/presentation/auth_provider.dart';
// Placeholder for missing screens

import '../../features/platform_shell/presentation/platform_shell.dart';
import '../../features/platform/presentation/organizations_screen.dart';
import '../../features/platform/presentation/create_organization_screen.dart';
import '../../features/platform/presentation/organization_detail_screen.dart';
import '../../features/platform/presentation/branch_management_screen.dart';
import '../../features/platform/presentation/department_management_screen.dart';
import '../../features/platform/presentation/organization_analytics_screen.dart';
import '../../features/platform/presentation/platform_dashboard_screen.dart';
import '../../features/platform/presentation/operations_dashboard_screen.dart';
import '../../features/platform/presentation/ai_insights_dashboard_screen.dart';
import '../../features/platform/presentation/tenants_screen.dart';
import '../../features/platform/presentation/create_tenant_screen.dart';
import '../../features/platform/presentation/tenant_detail_screen.dart';
import '../../features/platform/presentation/tenant_analytics_screen.dart';
import '../../features/platform/presentation/tenant_settings_screen.dart';
import '../../features/platform/presentation/subscription_screen.dart';
import '../../features/platform/presentation/organizations_screen.dart';
import '../../features/platform/presentation/platform_users_screen.dart';
import '../../features/platform/presentation/create_user_screen.dart';
import '../../features/platform/presentation/user_detail_screen.dart';
import '../../features/platform/presentation/user_activity_screen.dart';
import '../../features/platform/presentation/user_profile_screen.dart';
import '../../features/platform/presentation/user_sessions_screen.dart';
import '../../features/platform/presentation/user_invitations_screen.dart';
import '../../features/platform/presentation/roles_permissions_screen.dart';
import '../../features/platform/presentation/roles_screen.dart' as platform_roles;
import '../../features/platform/presentation/role_form_screen.dart';
import '../../features/platform/presentation/role_detail_screen.dart';
import '../../features/platform/presentation/permissions_screen.dart';
import '../../features/platform/presentation/role_permission_matrix_screen.dart';
import '../../features/platform/presentation/user_role_assignment_screen.dart';
import '../../features/platform/presentation/permission_groups_screen.dart';
import '../../features/platform/presentation/permission_simulator_screen.dart';
import '../../features/platform/presentation/access_policy_viewer_screen.dart';
import '../../features/platform/presentation/workflow_engine_screen.dart';
import '../../features/platform/presentation/approval_engine_screen.dart';
import '../../features/platform/presentation/platform_notifications_screen.dart';
import '../../features/platform/presentation/documents_screen.dart';
import '../../features/platform/presentation/audit_logs_screen.dart';
import '../../features/platform/presentation/platform_reports_screen.dart';
import '../../features/platform/presentation/ai_assistant_screen.dart';
import '../../features/platform/presentation/furni_flow_pack_screen.dart';
import '../../features/platform/presentation/steel_flow_pack_screen.dart';
import '../../features/platform/presentation/garment_flow_pack_screen.dart';
import '../../features/platform/presentation/kitchen_flow_pack_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();
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
        return isAuth ? '/dashboard' : '/login';
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
        redirect: (context, state) => '/dashboard',
      ),
      ShellRoute(
        navigatorKey: _platformShellNavigatorKey,
        builder: (context, state, child) {
          return PlatformShell(child: child);
        },
        routes: [
          GoRoute(path: '/platform/dashboard', builder: (context, state) => const PlatformDashboardScreen()),
          GoRoute(path: '/platform/dashboard/operations', builder: (context, state) => const OperationsDashboardScreen()),
          GoRoute(path: '/platform/dashboard/ai-insights', builder: (context, state) => const AiInsightsDashboardScreen()),
          GoRoute(path: '/platform/tenants', builder: (context, state) => const TenantsScreen()),
          GoRoute(path: '/platform/organizations', builder: (context, state) => const OrganizationsScreen()),
          GoRoute(path: '/platform/rbac/roles', builder: (context, state) => const platform_roles.RolesScreen()),
          GoRoute(path: '/platform/rbac/roles/new', builder: (context, state) => const RoleFormScreen(roleId: 'new')),
          GoRoute(
            path: '/platform/rbac/roles/:id/edit', 
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return RoleFormScreen(roleId: id);
            },
          ),
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
          GoRoute(path: '/platform/rbac/simulator', builder: (context, state) => const PermissionSimulatorScreen()),
          GoRoute(path: '/platform/rbac/policies', builder: (context, state) => const AccessPolicyViewerScreen()),
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
          GoRoute(path: '/platform/workflows', builder: (context, state) => const WorkflowEngineScreen()),
          GoRoute(path: '/platform/approvals', builder: (context, state) => const ApprovalEngineScreen()),
          GoRoute(path: '/platform/notifications', builder: (context, state) => const PlatformNotificationsScreen()),
          GoRoute(path: '/platform/documents', builder: (context, state) => const DocumentsScreen()),
          GoRoute(path: '/platform/audit-logs', builder: (context, state) => const AuditLogsScreen()),
          GoRoute(path: '/platform/reports', builder: (context, state) => const PlatformReportsScreen()),
          GoRoute(path: '/platform/ai', builder: (context, state) => const AiAssistantScreen()),
          GoRoute(path: '/platform/pack/furniflow', builder: (context, state) => const FurniFlowPackScreen()),
          GoRoute(path: '/platform/pack/steelflow', builder: (context, state) => const SteelFlowPackScreen()),
          GoRoute(path: '/platform/pack/garmentflow', builder: (context, state) => const GarmentFlowPackScreen()),
          GoRoute(path: '/platform/pack/kitchenflow', builder: (context, state) => const KitchenFlowPackScreen()),
        ],
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/sales-dashboard',
            name: 'sales_dashboard',
            builder: (context, state) => const SalesDashboardScreen(),
          ),
          GoRoute(
            path: '/manufacturing-dashboard',
            name: 'manufacturing_dashboard',
            builder: (context, state) => const ManufacturingDashboardScreen(),
          ),
          GoRoute(
            path: '/delivery-dashboard',
            name: 'delivery_dashboard',
            builder: (context, state) => const DeliveryDashboardScreen(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) => const UsersScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const UserFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) => UserFormScreen(id: state.pathParameters['id']),
              ),
              GoRoute(
                path: 'view/:id',
                builder: (context, state) => UserViewScreen(id: state.pathParameters['id']!),
              ),
            ]
          ),
          GoRoute(
            path: '/roles',
            builder: (context, state) => const RolesScreen(),
            routes: [
              GoRoute(
                path: 'view/:id',
                builder: (context, state) => RoleDetailsScreen(roleId: state.pathParameters['id']!),
              ),
            ]
          ),
          GoRoute(
            path: '/master-data',
            builder: (context, state) => const MasterDataScreen(),
          ),
          GoRoute(
            path: '/customers',
            builder: (context, state) => const CustomersScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CustomerFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) => CustomerFormScreen(id: state.pathParameters['id']),
              ),
              GoRoute(
                path: 'view/:id',
                builder: (context, state) => CustomerViewScreen(id: state.pathParameters['id']!),
              ),
            ]
          ),
          GoRoute(
            path: '/inquiries',
            name: 'inquiries',
            builder: (context, state) => const InquiriesScreen(),
          ),
          GoRoute(
            path: '/quotations',
            name: 'quotations',
            builder: (context, state) => const QuotationsScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const QuotationFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) => QuotationFormScreen(id: state.pathParameters['id']),
              ),
              GoRoute(
                path: 'view/:id',
                builder: (context, state) => QuotationViewScreen(id: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/sales-orders',
            name: 'sales_orders',
            builder: (context, state) => const SalesOrdersScreen(),
            routes: [
              GoRoute(
                path: 'view/:id',
                builder: (context, state) => SalesOrderViewScreen(orderId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) => SalesOrderEditScreen(orderId: state.pathParameters['id']!),
              ),
            ]
          ),
          GoRoute(
            path: '/catalog',
            builder: (context, state) => const CatalogScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const ProductFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) => ProductFormScreen(id: state.pathParameters['id']),
              ),
              GoRoute(
                path: 'view/:id',
                builder: (context, state) => ProductViewScreen(id: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'categories',
                builder: (context, state) => const CategoryListScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    builder: (context, state) => const CategoryFormScreen(),
                  ),
                  GoRoute(
                    path: 'edit/:id',
                    builder: (context, state) => CategoryFormScreen(id: state.pathParameters['id']),
                  ),
                  GoRoute(
                    path: 'view/:id',
                    builder: (context, state) => CategoryViewScreen(id: state.pathParameters['id']!),
                  ),
                ],
              ),
            ]
          ),
          GoRoute(
            path: '/bom',
            name: 'bom',
            builder: (context, state) => const BomListScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const BomFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) => BomFormScreen(bomId: state.pathParameters['id']),
              ),
              GoRoute(
                path: 'view/:id',
                builder: (context, state) => BomViewScreen(bomId: state.pathParameters['id']!),
              ),
            ]
          ),
          GoRoute(
            path: '/production',
            name: 'production',
            builder: (context, state) => const ProductionOrderListScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const ProductionOrderCreateScreen(),
              ),
              GoRoute(
                path: 'view/:id',
                builder: (context, state) => ProductionOrderViewScreen(orderId: state.pathParameters['id']!),
              ),
            ]
          ),
          GoRoute(
            path: '/tracking/board',
            builder: (context, state) => const ProductionBoardScreen(),
          ),
          GoRoute(
            path: '/tracking',
            builder: (context, state) => const ProductionTrackingListScreen(),
          ),
          GoRoute(
            path: '/tracking/view/:id',
            builder: (context, state) => ProductionTrackingScreen(trackingId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/job_orders',
            name: 'job_orders',
            builder: (context, state) => const JobOrdersScreen(),
          ),
          GoRoute(
            path: '/inventory',
            name: 'inventory',
            builder: (context, state) => const InventoryScreen(),
          ),
          GoRoute(
            path: '/delivery',
            builder: (context, state) => const DeliveryListScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const DeliveryCreateScreen(),
              ),
              GoRoute(
                path: 'view/:id',
                builder: (context, state) => DeliveryViewScreen(id: state.pathParameters['id']!),
              ),
            ]
          ),
          GoRoute(
            path: '/invoices',
            name: 'invoices',
            builder: (context, state) => const InvoicesScreen(),
          ),
          GoRoute(
            path: '/financial-overview',
            name: 'financial_overview',
            builder: (context, state) => const FinancialOverviewScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'profile',
                name: 'settings_profile',
                builder: (context, state) => const ProfileScreen(),
              ),
              GoRoute(
                path: 'security',
                name: 'settings_security',
                builder: (context, state) => const SecurityScreen(),
              ),
              GoRoute(
                path: 'about',
                name: 'settings_about',
                builder: (context, state) => const AboutScreen(),
              ),
            ],
          ),
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
