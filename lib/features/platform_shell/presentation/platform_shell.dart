import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';
import '../../notifications/presentation/notification_drawer.dart';
import '../../ai_assistant/presentation/ai_assistant_panel.dart';
import '../../auth/presentation/auth_provider.dart';

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

  final _menuHierarchy = [
    {
      'group': 'Main',
      'items': [
        {'title': 'Dashboard', 'icon': LucideIcons.layoutDashboard, 'route': '/platform/dashboard'},
        {'title': 'Operations', 'icon': LucideIcons.activity, 'route': '/platform/dashboard/operations'},
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
      'group': 'Workflow & Automation',
      'items': [
        {'title': 'Workflow Engine', 'icon': LucideIcons.gitMerge, 'route': '/platform/workflows'},
        {'title': 'Approval Engine', 'icon': LucideIcons.checkSquare, 'route': '/platform/approvals'},
        {'title': 'Notifications', 'icon': LucideIcons.bellRing, 'route': '/platform/notifications'},
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
        {'title': 'AI Insights', 'icon': LucideIcons.brain, 'route': '/platform/dashboard/ai-insights'},
        {'title': 'AI Assistant', 'icon': LucideIcons.sparkles, 'route': '/platform/ai'},
      ]
    },
    {
      'group': 'Industry Packs',
      'items': [
        {'title': 'FurniFlow', 'icon': LucideIcons.sofa, 'route': '/platform/pack/furniflow'},
        {'title': 'SteelFlow', 'icon': LucideIcons.anvil, 'route': '/platform/pack/steelflow'},
        {'title': 'GarmentFlow', 'icon': LucideIcons.shirt, 'route': '/platform/pack/garmentflow'},
        {'title': 'KitchenFlow', 'icon': LucideIcons.chefHat, 'route': '/platform/pack/kitchenflow'},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final theme = Theme.of(context);

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
              title: const Text('CoreAxis ERP'),
              actions: _buildAppBarActions(),
            ),
      drawer: isDesktop ? null : _buildDrawer(context, theme),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(context, theme),
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
                Icon(LucideIcons.boxes, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'CoreAxis ERP',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 48),
            // Global Search
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: TextField(
                  readOnly: true,
                  onTap: () => _showCommandPaletteDialog(context),
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
          Icon(LucideIcons.home, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text('Platform', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          for (var i = 0; i < segments.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(LucideIcons.chevronRight, size: 16, color: theme.colorScheme.onSurfaceVariant),
            ),
            Text(
              segments[i].replaceAll('-', ' ').toUpperCase(),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: i == segments.length - 1 ? FontWeight.bold : FontWeight.normal,
                color: i == segments.length - 1 ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, ThemeData theme) {
    return Drawer(
      child: _buildSidebarContent(context, theme),
    );
  }

  Widget _buildSidebar(BuildContext context, ThemeData theme) {
    return Material(
      color: theme.colorScheme.surface,
      child: SizedBox(
        width: 260,
        child: _buildSidebarContent(context, theme),
      ),
    );
  }

  Widget _buildSidebarContent(BuildContext context, ThemeData theme) {
    final currentPath = GoRouterState.of(context).uri.path;

    return Column(
      children: [
        const SizedBox(height: 24),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              for (final group in _menuHierarchy)
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

  void _showCommandPaletteDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.only(top: 100, left: 16, right: 16),
        alignment: Alignment.topCenter,
        child: Container(
          width: 600,
          constraints: const BoxConstraints(maxHeight: 500),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade300),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40, spreadRadius: 10),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search tenants, users, workflows...',
                    prefixIcon: const Icon(LucideIcons.search, size: 24),
                    border: InputBorder.none,
                    isDense: true,
                    hintStyle: TextStyle(fontSize: 18, color: Colors.grey.shade500),
                  ),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildCommandSection('QUICK ACTIONS', theme),
                    _buildCommandItem(LucideIcons.building, 'Create New Tenant', 'Administration', theme, context),
                    _buildCommandItem(LucideIcons.users, 'Invite New User', 'Administration', theme, context),
                    
                    _buildCommandSection('RECENT', theme),
                    _buildCommandItem(LucideIcons.gitMerge, 'Purchase Order Approval Flow', 'Workflow', theme, context),
                    
                    _buildCommandSection('SUGGESTED', theme),
                    _buildCommandItem(LucideIcons.pieChart, 'Platform Usage Analytics', 'Report', theme, context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommandSection(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.5),
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCommandItem(IconData icon, String title, String subtitle, ThemeData theme, BuildContext context, {bool isHighlight = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: isHighlight ? theme.colorScheme.primary : theme.iconTheme.color?.withOpacity(0.7)),
      title: Text(title, style: TextStyle(fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500, color: isHighlight ? theme.colorScheme.primary : theme.colorScheme.onSurface)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: theme.colorScheme.onSurface.withOpacity(0.05), borderRadius: BorderRadius.circular(4)),
        child: Text(subtitle, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6))),
      ),
      hoverColor: theme.colorScheme.primary.withOpacity(0.05),
      onTap: () => Navigator.pop(context),
    );
  }
}
