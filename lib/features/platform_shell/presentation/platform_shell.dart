import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';
import '../../notifications/presentation/notification_drawer.dart';
import '../../auth/presentation/auth_provider.dart';
import 'global_search_dialog.dart';
import 'package:flutter/services.dart';
import 'widgets/industry_context_switcher.dart';

class PlatformShell extends ConsumerStatefulWidget {
  final Widget child;

  const PlatformShell({super.key, required this.child});

  @override
  ConsumerState<PlatformShell> createState() => _PlatformShellState();
}

class _PlatformShellState extends ConsumerState<PlatformShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Widget? _currentEndDrawer;
  
  final Map<String, bool> _expandedGroups = {};
  bool _isCommandPaletteOpen = false;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyK &&
          (HardwareKeyboard.instance.isControlPressed || HardwareKeyboard.instance.isMetaPressed)) {
        
        _showGlobalSearchDialog(context);
        return true; // Return true to mark as handled and prevent browser default
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final theme = Theme.of(context);

    final _menuHierarchy = [
      {
        'group': 'Core Platform',
        'items': [
          {'title': 'Platform Home', 'icon': LucideIcons.home, 'route': '/platform/home'},
          {'title': 'Product Roadmap', 'icon': LucideIcons.map, 'route': '/platform/roadmap'},
          {'title': 'What\'s New', 'icon': LucideIcons.sparkles, 'route': '/platform/whats-new'},
          {'title': 'Release Showcase', 'icon': LucideIcons.star, 'route': '/platform/release-showcase'},
          {'title': 'Dashboard', 'icon': LucideIcons.layoutDashboard, 'route': '/platform/dashboard'},
          {'title': 'Workspace Manager', 'icon': LucideIcons.layoutTemplate, 'route': '/platform/workspaces'},
          {'title': 'Module Catalog', 'icon': LucideIcons.grid, 'route': '/platform/modules'},
          {'title': 'System Status', 'icon': LucideIcons.activity, 'route': '/platform/system-status'},
        ]
      },
      {
        'group': 'Onboarding & Support',
        'items': [
          {'title': 'First Time Onboarding', 'icon': LucideIcons.partyPopper, 'route': '/platform/onboarding'},
          {'title': 'Feature Discovery', 'icon': LucideIcons.compass, 'route': '/platform/discovery'},
          {'title': 'Guided Tours', 'icon': LucideIcons.mousePointerClick, 'route': '/platform/tours'},
          {'title': 'Demo Mode Manager', 'icon': LucideIcons.presentation, 'route': '/platform/demo-mode'},
          {'title': 'Demo Reset Center', 'icon': LucideIcons.refreshCw, 'route': '/platform/demo/reset'},
          {'title': 'Demo Story Mode', 'icon': LucideIcons.bookOpen, 'route': '/platform/demo/story-mode'},
          {'title': 'Demo Data Generator', 'icon': LucideIcons.databaseZap, 'route': '/platform/demo/data'},
          {'title': 'Executive Dashboard', 'icon': LucideIcons.pieChart, 'route': '/platform/demo/executive'},
          {'title': 'AI Scenarios', 'icon': LucideIcons.bot, 'route': '/platform/demo/ai'},
          {'title': 'Presentation Mode', 'icon': LucideIcons.monitorPlay, 'route': '/platform/demo/presentation'},
          {'title': 'Guided Journey', 'icon': LucideIcons.map, 'route': '/platform/demo/business-flow'},
          {'title': 'Scenario Switcher', 'icon': LucideIcons.factory, 'route': '/platform/demo/scenarios'},
          {'title': 'Live KPI Generator', 'icon': LucideIcons.activity, 'route': '/platform/demo/kpis'},
          {'title': 'Live Activity Sim', 'icon': LucideIcons.radioReceiver, 'route': '/platform/demo/activity'},
          {'title': 'Help Center', 'icon': LucideIcons.helpCircle, 'route': '/platform/help'},
          {'title': 'Keyboard Shortcuts', 'icon': LucideIcons.keyboard, 'route': '/platform/shortcuts'},
        ]
      },
      {
        'group': 'User Experience',
        'items': [
          {'title': 'UX Preferences', 'icon': LucideIcons.slidersHorizontal, 'route': '/platform/preferences'},
          {'title': 'Accessibility Center', 'icon': LucideIcons.accessibility, 'route': '/platform/accessibility'},
          {'title': 'Design System Audit', 'icon': LucideIcons.palette, 'route': '/platform/design-system'},
          {'title': 'Global Feedback Center', 'icon': LucideIcons.messageSquareHeart, 'route': '/platform/ux/feedback'},
          {'title': 'Responsive Preview', 'icon': LucideIcons.monitorSmartphone, 'route': '/platform/responsive'},
          {'title': 'Empty State Library', 'icon': LucideIcons.boxSelect, 'route': '/platform/ux/empty-states'},
          {'title': 'Skeleton Loading Library', 'icon': LucideIcons.loader, 'route': '/platform/ux/loading'},
          {'title': 'Toast Notifications', 'icon': LucideIcons.bellRing, 'route': '/platform/ux/toast'},
          {'title': 'Motion Design Library', 'icon': LucideIcons.clapperboard, 'route': '/platform/ux/motion'},
        ]
      },
      {
        'group': 'Configuration',
        'items': [
          {'title': 'Settings Center', 'icon': LucideIcons.settings, 'route': '/platform/settings'},
        ]
      },
      {
        'group': 'Platform Administration',
        'items': [
          {'title': 'Tenants', 'icon': LucideIcons.building, 'route': '/platform/tenants'},
          {'title': 'Organizations', 'icon': LucideIcons.network, 'route': '/platform/organizations'},
          {'title': 'Users', 'icon': LucideIcons.users, 'route': '/platform/users'},
          {'title': 'Roles', 'icon': LucideIcons.shieldCheck, 'route': '/platform/rbac/roles'},
          {'title': 'Permissions', 'icon': LucideIcons.key, 'route': '/platform/rbac/permissions'},
          {'title': 'Permission Groups', 'icon': LucideIcons.folders, 'route': '/platform/rbac/permission-groups'},
          {'title': 'Permission Matrix', 'icon': LucideIcons.grid, 'route': '/platform/rbac/matrix'},
          {'title': 'User Role Assignment', 'icon': LucideIcons.userCog, 'route': '/platform/rbac/user-role-assignment'},
          {'title': 'Permission Simulator', 'icon': LucideIcons.flaskConical, 'route': '/platform/rbac/simulator'},
          {'title': 'Access Policies', 'icon': LucideIcons.gitCommit, 'route': '/platform/rbac/policies'},
        ]
      },
      {
        'group': 'Document Engine',
        'items': [
          {'title': 'Dashboard', 'icon': LucideIcons.fileSearch, 'route': '/platform/documents'},
          {'title': 'Analytics', 'icon': LucideIcons.pieChart, 'route': '/platform/documents/analytics'},
          {'title': 'Repository', 'icon': LucideIcons.folderKanban, 'route': '/platform/documents/repository'},
          {'title': 'Categories', 'icon': LucideIcons.tags, 'route': '/platform/documents/categories'},
          {'title': 'Upload Center', 'icon': LucideIcons.uploadCloud, 'route': '/platform/documents/upload'},
          {'title': 'Folder Management', 'icon': LucideIcons.folderCog, 'route': '/platform/documents/folders'},
          {'title': 'Sharing & Permissions', 'icon': LucideIcons.share2, 'route': '/platform/documents/DOC-1234/sharing'},
        ]
      },
      {
        'group': 'Workflow Automation',
        'items': [
          {'title': 'Workflows Dashboard', 'icon': LucideIcons.workflow, 'route': '/platform/workflows'},
          {'title': 'Analytics Dashboard', 'icon': LucideIcons.barChart2, 'route': '/platform/workflows/analytics'},
          {'title': 'Workflow List', 'icon': LucideIcons.listTree, 'route': '/platform/workflows/list'},
          {'title': 'Designer', 'icon': LucideIcons.penTool, 'route': '/platform/workflows/designer'},
          {'title': 'Templates', 'icon': LucideIcons.copy, 'route': '/platform/workflows/templates'},
          {'title': 'Execution History', 'icon': LucideIcons.history, 'route': '/platform/workflows/executions'},
          {'title': 'Settings', 'icon': LucideIcons.settings, 'route': '/platform/workflows/settings'},
          {'title': 'Rules Engine', 'icon': LucideIcons.settings, 'route': '/platform/workflows/rules'},
        ]
      },
      {
        'group': 'Notification Engine',
        'items': [
          {'title': 'Dashboard', 'icon': LucideIcons.barChart2, 'route': '/platform/notifications'},
          {'title': 'Notification Center', 'icon': LucideIcons.bell, 'route': '/platform/notifications/center'},
          {'title': 'Templates', 'icon': LucideIcons.fileCode, 'route': '/platform/notifications/templates'},
          {'title': 'Channels', 'icon': LucideIcons.radio, 'route': '/platform/notifications/channels'},
          {'title': 'Broadcast Center', 'icon': LucideIcons.send, 'route': '/platform/notifications/broadcast'},
          {'title': 'Delivery Queue', 'icon': LucideIcons.list, 'route': '/platform/notifications/queue'},
          {'title': 'Delivery History', 'icon': LucideIcons.history, 'route': '/platform/notifications/history'},
          {'title': 'Analytics Dashboard', 'icon': LucideIcons.barChart2, 'route': '/platform/notifications/analytics'},
        ]
      },
      {
        'group': 'Approval Engine',
        'items': [
          {'title': 'Dashboard', 'icon': LucideIcons.checkSquare, 'route': '/platform/approvals'},
          {'title': 'Pending Approvals', 'icon': LucideIcons.clock, 'route': '/platform/approvals/pending'},
          {'title': 'Approval Rules', 'icon': LucideIcons.checkCircle, 'route': '/platform/approvals/rules'},
          {'title': 'Delegations', 'icon': LucideIcons.users, 'route': '/platform/approvals/delegations'},
          {'title': 'Approval Chains', 'icon': LucideIcons.gitCommit, 'route': '/platform/approvals/chains'},
          {'title': 'Approval History', 'icon': LucideIcons.history, 'route': '/platform/approvals/history'},
          {'title': 'Analytics', 'icon': LucideIcons.barChart2, 'route': '/platform/approvals/analytics'},
        ]
      },
      {
          'group': 'Audit Engine',
          'items': [
            {'title': 'Dashboard', 'icon': LucideIcons.shieldCheck, 'route': '/platform/audit'},
            {'title': 'Analytics', 'icon': LucideIcons.barChart2, 'route': '/platform/audit/analytics'},
            {'title': 'Explorer', 'icon': LucideIcons.search, 'route': '/platform/audit/explorer'},
            {'title': 'User Activity', 'icon': LucideIcons.users, 'route': '/platform/audit/users'},
            {'title': 'Security Events', 'icon': LucideIcons.shieldAlert, 'route': '/platform/audit/security'},
            {'title': 'Data History', 'icon': LucideIcons.history, 'route': '/platform/audit/data-history'},
            {'title': 'Compliance Reports', 'icon': LucideIcons.fileSignature, 'route': '/platform/audit/compliance'},
          ]
        },
      {
        'group': 'Content & Documents',
        'items': [
          {'title': 'Documents', 'icon': LucideIcons.fileText, 'route': '/platform/documents'},
          {'title': 'Audit Logs', 'icon': LucideIcons.history, 'route': '/platform/audit-logs'},
        ]
      },
      {
        'group': 'Analytics',
        'items': [
          {'title': 'Reports', 'icon': LucideIcons.pieChart, 'route': '/platform/reports'},
          {'title': 'Saved Reports', 'icon': LucideIcons.bookmark, 'route': '/platform/reports/saved'},
          {'title': 'Scheduled Reports', 'icon': LucideIcons.calendarClock, 'route': '/platform/reports/schedules'},
          {'title': 'Report Templates', 'icon': LucideIcons.layoutTemplate, 'route': '/platform/reports/templates'},
          {'title': 'Report Sharing', 'icon': LucideIcons.share2, 'route': '/platform/reports/sharing'},
          {'title': 'Data Explorer', 'icon': LucideIcons.compass, 'route': '/platform/reports/data-explorer'},
          {'title': 'KPI Designer', 'icon': LucideIcons.activity, 'route': '/platform/reports/kpis'},
          {'title': 'Report Analytics', 'icon': LucideIcons.barChart2, 'route': '/platform/reports/analytics'},
          {'title': 'Export Center', 'icon': LucideIcons.downloadCloud, 'route': '/platform/reports/export-center'},
          {'title': 'Report Catalog', 'icon': LucideIcons.library, 'route': '/platform/reports/catalog'},
          {'title': 'Report Builder', 'icon': LucideIcons.penTool, 'route': '/platform/reports/builder'},
          {'title': 'Dashboard Builder', 'icon': LucideIcons.layoutDashboard, 'route': '/platform/reports/dashboard-builder'},
        ]
      },
      {
        'group': 'Intelligence Engine',
        'items': [
          {'title': 'AI Dashboard', 'icon': LucideIcons.layoutDashboard, 'route': '/platform/ai'},
          {'title': 'AI Insights', 'icon': LucideIcons.brain, 'route': '/platform/ai/insights'},
          {'title': 'AI Predictions', 'icon': LucideIcons.trendingUp, 'route': '/platform/ai/predictions'},
          {'title': 'AI Copilot', 'icon': LucideIcons.sparkles, 'route': '/platform/ai/copilot'},
          {'title': 'AI Workflow Assistant', 'icon': LucideIcons.bot, 'route': '/platform/ai/workflows'},
          {'title': 'AI Report Generator', 'icon': LucideIcons.fileText, 'route': '/platform/ai/reports'},
          {'title': 'AI Knowledge Hub', 'icon': LucideIcons.bookOpen, 'route': '/platform/ai/knowledge'},
          {'title': 'AI Prompt Library', 'icon': LucideIcons.terminal, 'route': '/platform/ai/prompts'},
          {'title': 'AI Automation Studio', 'icon': LucideIcons.workflow, 'route': '/platform/ai/automation'},
          {'title': 'AI Agents Management', 'icon': LucideIcons.users, 'route': '/platform/ai/agents'},
          {'title': 'AI Model Center', 'icon': LucideIcons.cpu, 'route': '/platform/ai/models'},
          {'title': 'AI Settings', 'icon': LucideIcons.settings, 'route': '/platform/ai/settings'},
        ]
      },
      {
        'group': 'Industry Packs',
        'items': [
          {'title': 'Launcher', 'icon': LucideIcons.layoutGrid, 'route': '/platform/industry-packs'},
          {'title': 'Installed Packs', 'icon': LucideIcons.packageCheck, 'route': '/platform/industry-packs/installed'},
          {'title': 'Navigation Builder', 'icon': LucideIcons.network, 'route': '/platform/navigation-builder'},
          {'title': 'Marketplace', 'icon': LucideIcons.store, 'route': '/platform/marketplace'},
          {'title': 'FurniFlow', 'icon': LucideIcons.sofa, 'route': '/platform/pack/furniflow'},
          {'title': 'SteelFlow', 'icon': LucideIcons.anvil, 'route': '/platform/pack/steelflow'},
          {'title': 'GarmentFlow', 'icon': LucideIcons.shirt, 'route': '/platform/pack/garmentflow'},
          {'title': 'KitchenFlow', 'icon': LucideIcons.chefHat, 'route': '/platform/pack/kitchenflow'},
        ]
      },
    ];

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _currentEndDrawer,
      appBar: isDesktop
          ? _buildTopNavigation(context, theme)
          : AppBar(
              leading: IconButton(
                icon: const Icon(LucideIcons.menu),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              title: const Text('CoreAxis ERP', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
      drawer: isDesktop ? null : _buildDrawer(context, theme, _menuHierarchy),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(context, theme, _menuHierarchy),
          if (isDesktop) const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                _buildBreadcrumbs(context, theme),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildTopNavigation(BuildContext context, ThemeData theme) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(bottom: BorderSide(color: theme.dividerColor)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Row(
              children: [
                const IndustryContextSwitcher(),
              ],
            ),
            const SizedBox(width: 48),
            // Global Search
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: TextField(
                  readOnly: true,
                  onTap: () => _showGlobalSearchDialog(context),
                  decoration: InputDecoration(
                    hintText: 'Search platform (Cmd+K)...',
                    prefixIcon: const Icon(LucideIcons.search, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.scaffoldBackgroundColor,
                  ),
                ),
              ),
            ),
            const Spacer(),
            ..._buildAppBarActions(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    final theme = Theme.of(context);
    return [
      IconButton(
        icon: Icon(theme.brightness == Brightness.dark ? LucideIcons.sun : LucideIcons.moon),
        tooltip: 'Toggle Theme',
        onPressed: () {
          ref.read(themeModeProvider.notifier).toggle(theme.brightness != Brightness.dark);
        },
      ),
      const SizedBox(width: 8),
      IconButton(
        icon: const Icon(LucideIcons.bell),
        tooltip: 'Notifications',
        onPressed: () {
          setState(() => _currentEndDrawer = NotificationDrawer(onClose: () => _scaffoldKey.currentState?.closeEndDrawer()));
          _scaffoldKey.currentState?.openEndDrawer();
        },
      ),
      const SizedBox(width: 8),
      IconButton(
        icon: const Icon(LucideIcons.user),
        onPressed: () => _showProfileDialog(context),
      ),
    ];
  }

  Widget _buildBreadcrumbs(BuildContext context, ThemeData theme) {
    final path = GoRouterState.of(context).uri.path;
    final segments = path.split('/').where((s) => s.isNotEmpty && s != 'platform').toList();
    
    if (segments.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.go('/platform/home'),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.home, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('Platform', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
          for (var i = 0; i < segments.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(LucideIcons.chevronRight, size: 16, color: theme.colorScheme.onSurfaceVariant),
            ),
            InkWell(
              onTap: () {
                final route = '/platform/${segments.sublist(0, i + 1).join('/')}';
                context.go(route);
              },
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  segments[i].replaceAll('-', ' ').toUpperCase(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: i == segments.length - 1 ? FontWeight.bold : FontWeight.w500,
                    color: i == segments.length - 1 ? theme.colorScheme.onSurface : theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, ThemeData theme, List<Map<String, dynamic>> menuHierarchy) {
    return Drawer(
      child: _buildSidebarContent(context, theme, menuHierarchy),
    );
  }

  Widget _buildSidebar(BuildContext context, ThemeData theme, List<Map<String, dynamic>> menuHierarchy) {
    return Material(
      color: theme.colorScheme.surface,
      child: SizedBox(
        width: 260,
        child: _buildSidebarContent(context, theme, menuHierarchy),
      ),
    );
  }

  Widget _buildSidebarContent(BuildContext context, ThemeData theme, List<Map<String, dynamic>> menuHierarchy) {
    final currentPath = GoRouterState.of(context).uri.path;

    return Column(
      children: [
        const SizedBox(height: 24),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              for (final group in menuHierarchy)
                _buildMenuGroup(context, theme, group['group'] as String, group['items'] as List<Map<String, dynamic>>, currentPath),
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ListTile(
            leading: const Icon(LucideIcons.logOut, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            onTap: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMenuGroup(BuildContext context, ThemeData theme, String groupName, List<Map<String, dynamic>> items, String currentPath) {
    final hasActiveChild = items.any((m) => currentPath == m['route'] || currentPath.startsWith(m['route'] + '/'));

    if (groupName == 'Main') {
      return Column(
        children: items.map((m) => _buildNavItem(context, m['title'], m['icon'], m['route'], currentPath)).toList(),
      );
    }

    if (hasActiveChild && !_expandedGroups.containsKey(groupName)) {
      _expandedGroups[groupName] = true;
    }
    
    final isExpanded = _expandedGroups[groupName] ?? false;

    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            _expandedGroups[groupName] = expanded;
          });
        },
        leading: Icon(LucideIcons.layers, color: hasActiveChild ? theme.colorScheme.primary : theme.iconTheme.color, size: 20),
        title: Text(
          groupName,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: hasActiveChild ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            fontWeight: hasActiveChild ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        childrenPadding: const EdgeInsets.only(left: 24),
        children: items.map((m) => _buildNavItem(context, m['title'], m['icon'], m['route'], currentPath)).toList(),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String title, IconData icon, String path, String currentPath) {
    final isSelected = currentPath == path || (currentPath.startsWith(path) && !currentPath.startsWith('$path/'));
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? theme.colorScheme.primary : theme.iconTheme.color, size: 20),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: theme.colorScheme.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () {
          context.go(path);
          if (_scaffoldKey.currentState?.isDrawerOpen == true) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('My Profile'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(radius: 40, backgroundColor: Colors.indigo, child: Text('CA', style: TextStyle(fontSize: 24, color: Colors.white))),
              const SizedBox(height: 16),
              const Text('System Administrator', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text('admin@coreaxis.com', style: TextStyle(color: Colors.grey)),
              const Divider(height: 32),
              const ListTile(leading: Icon(LucideIcons.building), title: Text('Tenant'), subtitle: Text('SYSTEM_TENANT')),
              const ListTile(leading: Icon(LucideIcons.shieldCheck), title: Text('Role'), subtitle: Text('Platform Admin')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Settings')),
        ],
      ),
    );
  }

  void _showGlobalSearchDialog(BuildContext context) {
    if (_isCommandPaletteOpen) return;
    _isCommandPaletteOpen = true;
    
    showDialog(
      context: context,
      builder: (context) => const GlobalSearchDialog(),
    ).then((_) {
      if (mounted) {
        _isCommandPaletteOpen = false;
      }
    });
  }
}
