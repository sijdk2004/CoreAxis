import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';

import '../../auth/presentation/auth_provider.dart';
import 'global_search_dialog.dart';
import 'package:flutter/services.dart';


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
          {'title': 'Business Marketplace', 'icon': LucideIcons.store, 'route': '/marketplace'},
          {'title': 'Solution Blueprints', 'icon': LucideIcons.fileCode, 'route': '/blueprint'},
          {'title': 'Solution Composer', 'icon': LucideIcons.blocks, 'route': '/composer'},
          {'title': 'Solution Management', 'icon': LucideIcons.layers, 'route': '/solution-management'},
          {'title': 'Customer Provisioning', 'icon': LucideIcons.truck, 'route': '/provisioning'},
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
