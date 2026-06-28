import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:intl/intl.dart';

import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import '../domain/models/role.dart';
import 'providers/role_list_provider.dart';

class RolesScreen extends ConsumerStatefulWidget {
  const RolesScreen({super.key});

  @override
  ConsumerState<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends ConsumerState<RolesScreen> {
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Provider auto-initializes.
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showMockDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  IconData _getRoleIcon(Role role) {
    if (role.name.contains('Admin')) return LucideIcons.shield;
    if (role.name.contains('Support')) return LucideIcons.lifeBuoy;
    if (role.name.contains('Sales')) return LucideIcons.briefcase;
    if (role.name.contains('Finance')) return LucideIcons.dollarSign;
    if (role.name.contains('HR')) return LucideIcons.users;
    if (role.name.contains('Production') || role.name.contains('Inventory')) return LucideIcons.package;
    if (role.scope == 'Custom') return LucideIcons.settings;
    return LucideIcons.user;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(roleListProvider);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Role Management'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            tooltip: 'Refresh',
            onPressed: () => ref.read(roleListProvider.notifier).init(),
          ),
          OutlinedButton.icon(
            onPressed: () => _showMockDialog('Exporting Roles...'),
            icon: const Icon(LucideIcons.download, size: 18),
            label: const Text('Export'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: state.selectedRoleIds.length == 1 
                ? () => _showMockDialog('Cloning Role...') 
                : null,
            icon: const Icon(LucideIcons.copy, size: 18),
            label: const Text('Clone Role'),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: FilledButton.icon(
              onPressed: () => context.go('/platform/rbac/roles/new'),
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Create Role'),
            ),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context, state, isDesktop),
    );
  }

  Widget _buildBody(BuildContext context, RoleListState state, bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStats(state.allRoles, isDesktop),
          const SizedBox(height: 24),
          _buildToolbar(context, state, isDesktop),
          const SizedBox(height: 16),
          if (state.selectedRoleIds.isNotEmpty) ...[
            _buildBulkActionsBar(context, state),
            const SizedBox(height: 16),
          ],
          _buildTable(context, state, isDesktop),
        ],
      ),
    );
  }

  Widget _buildStats(List<Role> allRoles, bool isDesktop) {
    final platformRoles = allRoles.where((r) => r.scope == 'Platform').length;
    final tenantRoles = allRoles.where((r) => r.scope == 'Tenant').length;
    final customRoles = allRoles.where((r) => r.scope == 'Custom').length;
    final activeRoles = allRoles.where((r) => r.status == 'Active').length;
    final assignedRoles = allRoles.where((r) => r.usersAssigned > 0).length;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatCard('Total Roles', allRoles.length.toString(), LucideIcons.layers, Colors.blue, isDesktop),
        _buildStatCard('Platform Roles', platformRoles.toString(), LucideIcons.server, Colors.indigo, isDesktop),
        _buildStatCard('Tenant Roles', tenantRoles.toString(), LucideIcons.building, Colors.teal, isDesktop),
        _buildStatCard('Custom Roles', customRoles.toString(), LucideIcons.sliders, Colors.orange, isDesktop),
        _buildStatCard('Active Roles', activeRoles.toString(), LucideIcons.checkCircle, Colors.green, isDesktop),
        _buildStatCard('Assigned Roles', assignedRoles.toString(), LucideIcons.users, Colors.purple, isDesktop),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDesktop) {
    return SizedBox(
      width: isDesktop ? 220 : double.infinity,
      child: PremiumCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, RoleListState state, bool isDesktop) {
    final filters = ['All', 'Platform Roles', 'Tenant Roles', 'System Roles', 'Custom Roles', 'Active', 'Inactive'];
    
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: isDesktop ? 300 : double.infinity,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search roles...',
              prefixIcon: const Icon(LucideIcons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (val) {
              setState(() => _currentPage = 0);
              ref.read(roleListProvider.notifier).setSearchQuery(val);
            },
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters.map((filter) {
              final isSelected = state.selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _currentPage = 0);
                      ref.read(roleListProvider.notifier).setFilter(filter);
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBulkActionsBar(BuildContext context, RoleListState state) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text('\${state.selectedRoleIds.length} Selected', style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          TextButton.icon(
            onPressed: () => ref.read(roleListProvider.notifier).bulkUpdateStatus('Active'),
            icon: const Icon(LucideIcons.checkCircle, color: Colors.green, size: 18),
            label: const Text('Activate', style: TextStyle(color: Colors.green)),
          ),
          TextButton.icon(
            onPressed: () => ref.read(roleListProvider.notifier).bulkUpdateStatus('Inactive'),
            icon: const Icon(LucideIcons.slash, color: Colors.grey, size: 18),
            label: const Text('Deactivate', style: TextStyle(color: Colors.grey)),
          ),
          TextButton.icon(
            onPressed: () => _showMockDialog('Exporting Selected Roles...'),
            icon: const Icon(LucideIcons.download, size: 18),
            label: const Text('Export'),
          ),
          TextButton.icon(
            onPressed: () {
              ref.read(roleListProvider.notifier).bulkDelete();
              _showMockDialog('Selected roles deleted.');
            },
            icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 18),
            label: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context, RoleListState state, bool isDesktop) {
    final theme = Theme.of(context);
    final roles = state.filteredRoles;
    
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, roles.length);
    final currentList = roles.sublist(startIndex, endIndex);

    final allSelected = currentList.isNotEmpty && currentList.every((r) => state.selectedRoleIds.contains(r.id));
    final someSelected = currentList.any((r) => state.selectedRoleIds.contains(r.id)) && !allSelected;

    return PremiumCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderRow(context, allSelected, someSelected, currentList.isNotEmpty),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: currentList.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: theme.dividerColor.withOpacity(0.4)),
            itemBuilder: (context, index) => _buildRow(context, currentList[index], theme, state.selectedRoleIds.contains(currentList[index].id)),
          ),
          if (roles.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: Text('No roles found.')),
            ),
          const Divider(height: 1),
          _buildPagination(context, roles.length, startIndex, endIndex, theme),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, bool allSelected, bool someSelected, bool hasItems) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Checkbox(
            value: hasItems ? allSelected : false,
            tristate: true,
            onChanged: hasItems ? (val) {
              ref.read(roleListProvider.notifier).selectAll(val == true || val == null);
            } : null,
          ),
          Expanded(flex: 3, child: _headerText('Role')),
          Expanded(flex: 1, child: _headerText('Scope')),
          Expanded(flex: 3, child: _headerText('Description')),
          Expanded(flex: 1, child: _headerText('Users')),
          Expanded(flex: 1, child: _headerText('Permissions')),
          Expanded(flex: 1, child: _headerText('Status')),
          Expanded(flex: 1, child: _headerText('Created')),
          const SizedBox(width: 48), // Actions
        ],
      ),
    );
  }

  Widget _headerText(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildRow(BuildContext context, Role role, ThemeData theme, bool isSelected) {
    return Container(
      color: isSelected ? theme.colorScheme.primaryContainer.withOpacity(0.1) : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            onChanged: (val) {
              ref.read(roleListProvider.notifier).toggleRoleSelection(role.id, val == true);
            },
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(_getRoleIcon(role), size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(role.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(role.code, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 1, child: Text(role.scope)),
          Expanded(flex: 3, child: Text(role.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))),
          Expanded(flex: 1, child: Text(role.usersAssigned.toString(), style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 1, child: Text(role.permissionCount.toString(), style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(
            flex: 1,
            child: _buildStatusBadge(role.status),
          ),
          Expanded(flex: 1, child: Text(DateFormat('MMM d, y').format(role.createdDate), style: const TextStyle(fontSize: 13))),
          SizedBox(
            width: 48,
            child: PopupMenuButton<String>(
              icon: const Icon(LucideIcons.moreVertical),
              onSelected: (val) {
                if (val == 'view') context.go('/platform/rbac/roles/${role.id}');
                if (val == 'edit') context.go('/platform/rbac/roles/${role.id}/edit');
                if (val == 'clone') _showMockDialog('Clone Role \${role.name}');
                if (val == 'permissions') _showMockDialog('Manage Permissions for \${role.name}');
                if (val == 'users') _showMockDialog('View Users assigned to \${role.name}');
                if (val == 'activate') ref.read(roleListProvider.notifier).activateRole(role.id);
                if (val == 'deactivate') ref.read(roleListProvider.notifier).deactivateRole(role.id);
                if (val == 'delete') {
                  ref.read(roleListProvider.notifier).deleteRole(role.id);
                  _showMockDialog('Role deleted.');
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 'view', child: Text('View')),
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'clone', child: Text('Clone')),
                const PopupMenuDivider(),
                const PopupMenuItem(value: 'permissions', child: Text('Manage Permissions', style: TextStyle(color: Colors.deepPurple))),
                const PopupMenuItem(value: 'users', child: Text('View Users', style: TextStyle(color: Colors.blue))),
                const PopupMenuDivider(),
                if (role.status == 'Inactive')
                  const PopupMenuItem(value: 'activate', child: Text('Activate', style: TextStyle(color: Colors.green))),
                if (role.status == 'Active')
                  const PopupMenuItem(value: 'deactivate', child: Text('Deactivate', style: TextStyle(color: Colors.grey))),
                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = status == 'Active' ? Colors.green : Colors.grey;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildPagination(BuildContext context, int totalItems, int startIndex, int endIndex, ThemeData theme) {
    final totalPages = (totalItems / _itemsPerPage).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing \${totalItems > 0 ? startIndex + 1 : 0} to \$endIndex of \$totalItems entries',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
          ),
          if (totalPages > 1)
            Row(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.chevronLeft, size: 20),
                  onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
                ),
                const SizedBox(width: 8),
                Text('Page \${_currentPage + 1} of \$totalPages', style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(LucideIcons.chevronRight, size: 20),
                  onPressed: _currentPage < totalPages - 1 ? () => setState(() => _currentPage++) : null,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
