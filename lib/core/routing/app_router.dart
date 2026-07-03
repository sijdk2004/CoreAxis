import 'package:flutter/material.dart';
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
import '../../features/platform/presentation/design_system_audit_screen.dart';
import '../../features/platform/presentation/empty_state_library_screen.dart';
import '../../features/platform/presentation/skeleton_loading_library_screen.dart';
import '../../features/platform/presentation/feedback_center_screen.dart';
import '../../features/platform/presentation/toast_playground_screen.dart';
import '../../features/platform/presentation/keyboard_shortcut_center_screen.dart';
import '../../features/platform/presentation/responsive_preview_center_screen.dart';
import '../../features/platform/presentation/demo_mode_manager_screen.dart';
import '../../features/platform/presentation/onboarding_screen.dart';
import '../../features/platform/presentation/product_tour_launcher_screen.dart';
import '../../features/platform/presentation/mock_tour_screen.dart';
import '../../features/platform/presentation/motion_design_library_screen.dart';
import '../../features/platform/presentation/accessibility_center_screen.dart';
import '../../features/platform/presentation/help_center_screen.dart';
import '../../features/platform/presentation/ux_preferences_screen.dart';
import '../../features/platform/presentation/demo_story_screen.dart';
import '../../features/platform/presentation/presentation_mode_screen.dart';
import '../../features/platform/presentation/industry_scenario_switcher_screen.dart';
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
import '../../features/platform/presentation/platform_home_screen.dart';
import '../../features/platform/presentation/marketplace_screen.dart';
import '../../features/platform/presentation/module_catalog_screen.dart';
import '../../features/platform/presentation/workspace_manager_screen.dart';
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
import '../../features/platform/presentation/workflow_dashboard_screen.dart';
import '../../features/platform/presentation/workflow_list_screen.dart';
import '../../features/platform/presentation/workflow_analytics_screen.dart';
import '../../features/platform/presentation/approval_dashboard_screen.dart';
import '../../features/platform/presentation/pending_approvals_screen.dart';
import '../../features/platform/presentation/approval_rules_screen.dart';
import '../../features/platform/presentation/approval_history_screen.dart';
import '../../features/platform/presentation/delegation_screen.dart';
import '../../features/platform/presentation/approval_analytics_screen.dart';
import '../../features/platform/presentation/notification_dashboard_screen.dart';
import '../../features/platform/presentation/notification_center_screen.dart';
import '../../features/platform/presentation/notification_template_screen.dart';
import '../../features/platform/presentation/notification_template_editor_screen.dart';
import '../../features/platform/presentation/notification_channel_screen.dart';
import '../../features/platform/presentation/broadcast_center_screen.dart';
import '../../features/platform/presentation/campaign_builder_screen.dart';
import '../../features/platform/presentation/delivery_queue_screen.dart';
import '../../features/platform/presentation/delivery_history_screen.dart';
import '../../features/platform/presentation/notification_analytics_screen.dart';
import '../../features/platform/presentation/document_dashboard_screen.dart';
import '../../features/platform/presentation/document_repository_screen.dart';
import '../../features/platform/presentation/document_category_screen.dart';
import '../../features/platform/presentation/document_upload_screen.dart';
import '../../features/platform/presentation/folder_management_screen.dart';
import '../../features/platform/presentation/document_viewer_screen.dart';
import '../../features/platform/presentation/audit_dashboard_screen.dart';
import '../../features/platform/presentation/audit_explorer_screen.dart';
import '../../features/platform/presentation/user_activity_audit_screen.dart';
import '../../features/platform/presentation/security_events_audit_screen.dart';
import '../../features/platform/presentation/data_history_screen.dart';
import '../../features/platform/presentation/compliance_reports_screen.dart';
import '../../features/platform/presentation/audit_analytics_screen.dart';
import '../../features/platform/presentation/entity_timeline_screen.dart';
import '../../features/platform/presentation/document_version_screen.dart';
import '../../features/platform/presentation/document_sharing_screen.dart';
import '../../features/platform/presentation/document_analytics_screen.dart';
import '../../features/platform/presentation/approval_chain_designer_screen.dart';
import '../../features/platform/presentation/workflow_settings_screen.dart';
import '../../features/platform/presentation/workflow_designer_screen.dart';
import '../../features/platform/presentation/workflow_detail_screen.dart';
import '../../features/platform/presentation/workflow_engine_screen.dart';
import '../../features/platform/presentation/workflow_template_library_screen.dart';
import '../../features/platform/presentation/workflow_execution_screen.dart';
import '../../features/platform/presentation/approval_engine_screen.dart';
import '../../features/platform/presentation/platform_notifications_screen.dart';
import '../../features/platform/presentation/documents_screen.dart';
import '../../features/platform/presentation/audit_logs_screen.dart';
import '../../features/platform/presentation/platform_reports_screen.dart';
import '../../features/platform/presentation/report_catalog_screen.dart';
import '../../features/platform/presentation/report_builder_screen.dart';
import '../../features/platform/presentation/saved_reports_screen.dart';
import '../../features/platform/presentation/scheduled_reports_screen.dart';
import '../../features/platform/presentation/report_templates_screen.dart';
import '../../features/platform/presentation/report_sharing_screen.dart';
import '../../features/platform/presentation/data_explorer_screen.dart';
import '../../features/platform/presentation/kpi_designer_screen.dart';
import '../../features/platform/presentation/report_analytics_dashboard_screen.dart';
import '../../features/platform/presentation/export_center_screen.dart';
import '../../features/platform/presentation/dashboard_builder_screen.dart';
import '../../features/platform/presentation/ai_assistant_screen.dart';
import '../../features/platform/presentation/ai_executive_dashboard_screen.dart';
import '../../features/platform/presentation/ai_copilot_screen.dart';
import '../../features/platform/presentation/platform_settings_screen.dart';
import '../../features/platform/presentation/industry_pack_launcher_screen.dart';
import '../../features/platform/presentation/installed_industry_packs_screen.dart';
import '../../features/platform/presentation/industry_pack_details_screen.dart';
import '../../features/platform/presentation/module_enablement_screen.dart';
import '../../features/platform/presentation/industry_branding_screen.dart';
import '../../features/platform/presentation/industry_dashboard_screen.dart';
import '../../features/platform/presentation/industry_settings_screen.dart';
import '../../features/platform/presentation/industry_pack_configuration_screen.dart';
import '../../features/platform/presentation/navigation_builder_screen.dart';
import '../../features/platform/presentation/system_status_screen.dart';
import '../../features/platform/presentation/ai_insights_center_screen.dart';
import '../../features/platform/presentation/ai_predictions_dashboard_screen.dart';
import '../../features/platform/presentation/ai_workflow_assistant_screen.dart';
import '../../features/platform/presentation/ai_report_generator_screen.dart';
import '../../features/platform/presentation/ai_knowledge_hub_screen.dart';
import '../../features/platform/presentation/ai_prompt_library_screen.dart';
import '../../features/platform/presentation/ai_automation_studio_screen.dart';
import '../../features/platform/presentation/ai_agents_management_screen.dart';
import '../../features/platform/presentation/ai_model_center_screen.dart';
import '../../features/platform/presentation/ai_settings_screen.dart';
import '../../features/platform/presentation/furni_flow_pack_screen.dart';
import '../../features/platform/presentation/steel_flow_pack_screen.dart';
import '../../features/platform/presentation/garment_flow_pack_screen.dart';
import '../../features/platform/presentation/kitchen_flow_pack_screen.dart';
import '../../features/platform/presentation/kpi_generator_screen.dart';
import '../../features/platform/presentation/demo_data_generator_screen.dart';
import '../../features/platform/presentation/ai_demo_scenarios_screen.dart';
import '../../features/platform/presentation/executive_dashboard_screen.dart';
import '../../features/platform/presentation/roadmap_screen.dart';
import '../../features/platform/presentation/whats_new_screen.dart';
import '../../features/platform/presentation/feature_discovery_screen.dart';
import '../../features/platform/presentation/release_showcase_screen.dart';
import '../../features/platform/presentation/demo_reset_center_screen.dart';
import '../../features/platform/presentation/business_journey_screen.dart';
import '../../features/platform/presentation/live_activity_simulation_screen.dart';

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
      GoRoute(
        path: '/platform/demo/presentation',
        builder: (context, state) => const PresentationModeScreen(),
      ),
      ShellRoute(
        navigatorKey: _platformShellNavigatorKey,
        builder: (context, state, child) {
          return PlatformShell(child: child);
        },
        routes: [
          GoRoute(path: '/platform/home', builder: (context, state) => const PlatformHomeScreen()),
          GoRoute(path: '/platform/roadmap', builder: (context, state) => const RoadmapScreen()),
          GoRoute(path: '/platform/whats-new', builder: (context, state) => const WhatsNewScreen()),
          GoRoute(path: '/platform/discovery', builder: (context, state) => const FeatureDiscoveryScreen()),
          GoRoute(path: '/platform/release-showcase', builder: (context, state) => const ReleaseShowcaseScreen()),
          GoRoute(path: '/platform/marketplace', builder: (context, state) => const MarketplaceScreen()),
          GoRoute(path: '/platform/modules', builder: (context, state) => const ModuleCatalogScreen()),
          GoRoute(path: '/platform/workspaces', builder: (context, state) => const WorkspaceManagerScreen()),
          GoRoute(path: '/platform/settings', builder: (context, state) => const PlatformSettingsScreen()),
          GoRoute(path: '/platform/design-system', builder: (context, state) => const DesignSystemAuditScreen()),
          GoRoute(path: '/platform/ux/empty-states', builder: (context, state) => const EmptyStateLibraryScreen()),
          GoRoute(path: '/platform/ux/loading', builder: (context, state) => const SkeletonLoadingLibraryScreen()),
          GoRoute(path: '/platform/ux/feedback', builder: (context, state) => const FeedbackCenterScreen()),
          GoRoute(path: '/platform/ux/toast', builder: (context, state) => const ToastPlaygroundScreen()),
          GoRoute(path: '/platform/ux/motion', builder: (context, state) => const MotionDesignLibraryScreen()),
          GoRoute(path: '/platform/accessibility', builder: (context, state) => const AccessibilityCenterScreen()),
          GoRoute(path: '/platform/help', builder: (context, state) => const HelpCenterScreen()),
          GoRoute(path: '/platform/preferences', builder: (context, state) => const UxPreferencesScreen()),
          GoRoute(path: '/platform/demo/scenarios', builder: (context, state) => const IndustryScenarioSwitcherScreen()),
          GoRoute(path: '/platform/demo/business-flow', builder: (context, state) => const BusinessJourneyScreen()),
          GoRoute(path: '/platform/demo/data', builder: (context, state) => const DemoDataGeneratorScreen()),
          GoRoute(path: '/platform/demo/ai', builder: (context, state) => const AiDemoScenariosScreen()),
          GoRoute(path: '/platform/demo/executive', builder: (context, state) => const ExecutiveDashboardScreen()),
          GoRoute(path: '/platform/demo/kpis', builder: (context, state) => const KpiGeneratorScreen()),
          GoRoute(path: '/platform/demo/activity', builder: (context, state) => const LiveActivitySimulationScreen()),
          GoRoute(path: '/platform/demo/reset', builder: (context, state) => const DemoResetCenterScreen()),
          GoRoute(path: '/platform/demo/story-mode', builder: (context, state) => const DemoStoryScreen()),
          GoRoute(path: '/platform/responsive', builder: (context, state) => const ResponsivePreviewCenterScreen()),
          GoRoute(path: '/platform/shortcuts', builder: (context, state) => const KeyboardShortcutCenterScreen()),
          GoRoute(path: '/platform/demo-mode', builder: (context, state) => const DemoModeManagerScreen()),
          GoRoute(path: '/platform/onboarding', builder: (context, state) => const OnboardingScreen()),
          GoRoute(path: '/platform/tours', builder: (context, state) => const ProductTourLauncherScreen()),
          GoRoute(path: '/platform/tours/:id', builder: (context, state) => MockTourScreen(tourId: state.pathParameters['id']!)),
          GoRoute(path: '/platform/industry-packs', builder: (context, state) => const IndustryPackLauncherScreen()),
          GoRoute(path: '/platform/industry-packs/installed', builder: (context, state) => const InstalledIndustryPacksScreen()),
          GoRoute(
            path: '/platform/industry-packs/:id', 
            builder: (context, state) => IndustryPackDetailsScreen(packId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/platform/industry-packs/:id/modules', 
            builder: (context, state) => ModuleEnablementScreen(packId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/platform/industry-packs/:id/branding',
            builder: (context, state) => IndustryBrandingScreen(packId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/platform/industry-packs/:id/dashboard',
            builder: (context, state) => IndustryDashboardScreen(packId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/platform/industry-packs/:id/settings',
            builder: (context, state) => IndustrySettingsScreen(packId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/platform/industry-packs/:id/configuration',
            builder: (context, state) => IndustryPackConfigurationScreen(packId: state.pathParameters['id']!),
          ),
          GoRoute(path: '/platform/navigation-builder', builder: (context, state) => const NavigationBuilderScreen()),
          GoRoute(path: '/platform/dashboard', builder: (context, state) => const PlatformDashboardScreen()),
          GoRoute(path: '/platform/system-status', builder: (context, state) => const SystemStatusScreen()),
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
          GoRoute(path: '/platform/workflows', builder: (context, state) => const WorkflowDashboardScreen()),
          GoRoute(path: '/platform/workflows/list', builder: (context, state) => const WorkflowListScreen()),
          GoRoute(path: '/platform/workflows/designer', builder: (context, state) => const WorkflowDesignerScreen()),
          GoRoute(path: '/platform/workflows/templates', builder: (context, state) => const WorkflowTemplateLibraryScreen()),
          GoRoute(path: '/platform/workflows/executions', builder: (context, state) => const WorkflowExecutionScreen()),
          GoRoute(path: '/platform/approvals', builder: (context, state) => const ApprovalDashboardScreen()),
          GoRoute(path: '/platform/approvals/pending', builder: (context, state) => const PendingApprovalsScreen()),
          GoRoute(path: '/platform/approvals/rules', builder: (context, state) => const ApprovalRulesScreen()),
          GoRoute(path: '/platform/approvals/delegations', builder: (context, state) => const DelegationScreen()),
          GoRoute(path: '/platform/approvals/history', builder: (context, state) => const ApprovalHistoryScreen()),
          GoRoute(path: '/platform/approvals/analytics', builder: (context, state) => const ApprovalAnalyticsScreen()),
          GoRoute(path: '/platform/notifications', builder: (context, state) => const NotificationDashboardScreen()),
          GoRoute(path: '/platform/notifications/center', builder: (context, state) => const NotificationCenterScreen()),
          GoRoute(path: '/platform/notifications/templates', builder: (context, state) => const NotificationTemplateScreen()),
          GoRoute(
            path: '/platform/notifications/templates/editor/:id', 
            builder: (context, state) => NotificationTemplateEditorScreen(templateId: state.pathParameters['id']!),
          ),
          GoRoute(path: '/platform/notifications/channels', builder: (context, state) => const NotificationChannelScreen()),
          GoRoute(path: '/platform/notifications/broadcast', builder: (context, state) => const BroadcastCenterScreen()),
          GoRoute(path: '/platform/notifications/broadcast/new', builder: (context, state) => const CampaignBuilderScreen()),
          GoRoute(path: '/platform/notifications/queue', builder: (context, state) => const DeliveryQueueScreen()),
          GoRoute(path: '/platform/notifications/history', builder: (context, state) => const DeliveryHistoryScreen()),
          GoRoute(path: '/platform/notifications/analytics', builder: (context, state) => const NotificationAnalyticsScreen()),
          GoRoute(path: '/platform/documents', builder: (context, state) => const DocumentDashboardScreen()),
          GoRoute(path: '/platform/documents/analytics', builder: (context, state) => const DocumentAnalyticsScreen()),
          GoRoute(path: '/platform/documents/repository', builder: (context, state) => const DocumentRepositoryScreen()),
          GoRoute(path: '/platform/documents/categories', builder: (context, state) => const DocumentCategoryScreen()),
          GoRoute(path: '/platform/documents/upload', builder: (context, state) => const DocumentUploadScreen()),
          GoRoute(path: '/platform/documents/folders', builder: (context, state) => const FolderManagementScreen()),
          GoRoute(path: '/platform/documents/:id/sharing', builder: (context, state) => DocumentSharingScreen(documentId: state.pathParameters['id']!)),
          GoRoute(path: '/platform/documents/:id/versions', builder: (context, state) => DocumentVersionScreen(documentId: state.pathParameters['id']!)),
          GoRoute(path: '/platform/documents/:id', builder: (context, state) => DocumentViewerScreen(documentId: state.pathParameters['id']!)),
          GoRoute(path: '/platform/approvals/chains', builder: (context, state) => const ApprovalChainDesignerScreen()),
          GoRoute(path: '/platform/workflows/analytics', builder: (context, state) => const WorkflowAnalyticsDashboardScreen()),
          GoRoute(path: '/platform/workflows/settings', builder: (context, state) => const WorkflowSettingsScreen()),
          GoRoute(
            path: '/platform/workflows/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? 'w1';
              return WorkflowDetailScreen(workflowId: id);
            },
          ),
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
          GoRoute(path: '/platform/workflows/engine', builder: (context, state) => const WorkflowEngineScreen()),
          GoRoute(path: '/platform/workflows/approvals', builder: (context, state) => const ApprovalEngineScreen()),
          GoRoute(path: '/platform/notifications', builder: (context, state) => const PlatformNotificationsScreen()),
          GoRoute(path: '/platform/documents', builder: (context, state) => const DocumentsScreen()),
          GoRoute(path: '/platform/audit', builder: (context, state) => const AuditDashboardScreen()),
          GoRoute(path: '/platform/audit/explorer', builder: (context, state) => const AuditExplorerScreen()),
          GoRoute(path: '/platform/audit/users', builder: (context, state) => const UserActivityAuditScreen()),
          GoRoute(path: '/platform/audit/security', builder: (context, state) => const SecurityEventsAuditScreen()),
          GoRoute(path: '/platform/audit/data-history', builder: (context, state) => const DataHistoryScreen()),
          GoRoute(path: '/platform/audit/compliance', builder: (context, state) => const ComplianceReportsScreen()),
          GoRoute(path: '/platform/audit/analytics', builder: (context, state) => const AuditAnalyticsScreen()),
          GoRoute(path: '/platform/audit/entity/:id', builder: (context, state) => EntityTimelineScreen(entityId: state.pathParameters['id'] ?? '')),
          GoRoute(path: '/platform/audit-logs', builder: (context, state) => const AuditLogsScreen()),
          GoRoute(path: '/platform/reports', builder: (context, state) => const PlatformReportsScreen()),
          GoRoute(path: '/platform/reports/saved', builder: (context, state) => const SavedReportsScreen()),
          GoRoute(path: '/platform/reports/schedules', builder: (context, state) => const ScheduledReportsScreen()),
          GoRoute(path: '/platform/reports/templates', builder: (context, state) => const ReportTemplatesScreen()),
          GoRoute(path: '/platform/reports/sharing', builder: (context, state) => const ReportSharingScreen()),
          GoRoute(path: '/platform/reports/data-explorer', builder: (context, state) => const DataExplorerScreen()),
          GoRoute(path: '/platform/reports/kpis', builder: (context, state) => const KpiDesignerScreen()),
          GoRoute(path: '/platform/reports/analytics', builder: (context, state) => const ReportAnalyticsDashboardScreen()),
          GoRoute(path: '/platform/reports/export-center', builder: (context, state) => const ExportCenterScreen()),
          GoRoute(path: '/platform/reports/catalog', builder: (context, state) => const ReportCatalogScreen()),
          GoRoute(path: '/platform/reports/builder', builder: (context, state) => const ReportBuilderScreen()),
          GoRoute(path: '/platform/reports/dashboard-builder', builder: (context, state) => const DashboardBuilderScreen()),
          GoRoute(path: '/platform/ai', builder: (context, state) => const AiExecutiveDashboardScreen()),
          GoRoute(path: '/platform/ai/chat', builder: (context, state) => const AiAssistantScreen()),
          GoRoute(path: '/platform/ai/copilot', builder: (context, state) => const AiCopilotScreen()),
          GoRoute(path: '/platform/ai/insights', builder: (context, state) => const AiInsightsCenterScreen()),
          GoRoute(path: '/platform/ai/predictions', builder: (context, state) => const AiPredictionsDashboardScreen()),
          GoRoute(path: '/platform/ai/workflows', builder: (context, state) => const AiWorkflowAssistantScreen()),
          GoRoute(path: '/platform/ai/reports', builder: (context, state) => const AIReportGeneratorScreen()),
          GoRoute(path: '/platform/ai/knowledge', builder: (context, state) => const AiKnowledgeHubScreen()),
          GoRoute(path: '/platform/ai/prompts', builder: (context, state) => const AiPromptLibraryScreen()),
          GoRoute(path: '/platform/ai/automation', builder: (context, state) => const AiAutomationStudioScreen()),
          GoRoute(path: '/platform/ai/agents', builder: (context, state) => const AiAgentsManagementScreen()),
          GoRoute(path: '/platform/ai/models', builder: (context, state) => const AiModelCenterScreen()),
          GoRoute(path: '/platform/ai/settings', builder: (context, state) => const AiSettingsScreen()),
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
