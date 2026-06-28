import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import 'providers/permission_list_provider.dart';
import '../domain/models/permission.dart';

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Identity', 'Tenant', 'Organization', 'User', 'Role', 
    'Workflow', 'Approval', 'Notification', 'Documents', 
    'Reports', 'Audit', 'AI', 'Furniture', 'Garments', 
    'Steel', 'Inventory', 'Production', 'Sales', 'Finance'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showMockDialog(String title, [String? content]) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: content != null ? Text(content) : const Text('This feature is currently mocked for the UI prototype.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(permissionListProvider);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: state.isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(theme),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStatistics(state, isDesktop),
                      const SizedBox(height: 24),
                      _buildPermissionsTable(state, theme),
                    ],
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.key, color: theme.colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Permission Registry', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Manage all system and industry pack permissions', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(PermissionListState state, bool isDesktop) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatCard('Total Permissions', state.totalPermissions.toString(), LucideIcons.key, Colors.indigo, isDesktop),
        _buildStatCard('Platform Permissions', state.platformPermissions.toString(), LucideIcons.layers, Colors.teal, isDesktop),
        _buildStatCard('Industry Permissions', state.industryPermissions.toString(), LucideIcons.briefcase, Colors.orange, isDesktop),
        _buildStatCard('Assigned Permissions', state.assignedPermissions.toString(), LucideIcons.shieldCheck, Colors.green, isDesktop),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDesktop) {
    return SizedBox(
      width: isDesktop ? 260 : double.infinity,
      child: PremiumCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
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

  Widget _buildPermissionsTable(PermissionListState state, ThemeData theme) {
    return PremiumCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Toolbar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => ref.read(permissionListProvider.notifier).setSearchQuery(value),
                    decoration: InputDecoration(
                      hintText: 'Search permissions by code, name or description...',
                      prefixIcon: const Icon(LucideIcons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: state.selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(permissionListProvider.notifier).setCategoryFilter(val);
                      }
                    },
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => _showMockDialog('Export Data'),
                  icon: const Icon(LucideIcons.download, size: 16),
                  label: const Text('Export'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => ref.read(permissionListProvider.notifier).refresh(),
                  icon: const Icon(LucideIcons.refreshCw),
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text('CODE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(flex: 3, child: Text('NAME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(flex: 1, child: Text('MODULE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(flex: 1, child: Text('CATEGORY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(flex: 1, child: Text('ROLES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(flex: 1, child: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                SizedBox(width: 48),
              ],
            ),
          ),
          const Divider(height: 1),
          // Table Body
          if (state.filteredPermissions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(48.0),
              child: Center(child: Text('No permissions found matching the criteria.')),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.filteredPermissions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final perm = state.filteredPermissions[index];
                return InkWell(
                  onTap: () => _showMockDialog('Permission Details', perm.description),
                  hoverColor: theme.colorScheme.primary.withOpacity(0.05),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: Text(perm.code, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'monospace', fontSize: 13))),
                        Expanded(
                          flex: 3, 
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(perm.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              Text(perm.description, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          )
                        ),
                        Expanded(flex: 1, child: _buildModuleBadge(perm.module, theme)),
                        Expanded(flex: 1, child: Text(perm.category)),
                        Expanded(flex: 1, child: Text(perm.assignedRolesCount.toString())),
                        Expanded(flex: 1, child: _buildStatusBadge(perm.status)),
                        SizedBox(
                          width: 48,
                          child: PopupMenuButton<String>(
                            icon: const Icon(LucideIcons.moreVertical),
                            onSelected: (val) {
                              if (val == 'view') _showMockDialog('Permission Details', perm.description);
                              if (val == 'edit') _showMockDialog('Edit Permission', 'Mock edit action for ${perm.name}.');
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(value: 'view', child: Text('View Details')),
                              const PopupMenuItem(value: 'edit', child: Text('Edit (Mock)')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = status == 'Active' ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildModuleBadge(String module, ThemeData theme) {
    final isPlatform = module == 'Platform';
    final color = isPlatform ? Colors.indigo : Colors.orange;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(isPlatform ? LucideIcons.layers : LucideIcons.briefcase, size: 14, color: color),
        const SizedBox(width: 4),
        Text(module, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
