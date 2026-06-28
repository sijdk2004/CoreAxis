import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import '../domain/models/permission_group.dart';
import 'providers/permission_group_provider.dart';

class PermissionGroupsScreen extends ConsumerStatefulWidget {
  const PermissionGroupsScreen({super.key});

  @override
  ConsumerState<PermissionGroupsScreen> createState() => _PermissionGroupsScreenState();
}

class _PermissionGroupsScreenState extends ConsumerState<PermissionGroupsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showGroupDialog({PermissionGroup? group}) {
    final isEditing = group != null;
    final nameController = TextEditingController(text: group?.name ?? '');
    final descController = TextEditingController(text: group?.description ?? '');
    String status = group?.status ?? 'Active';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Edit Permission Group' : 'Create Permission Group'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Group Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Active', child: Text('Active')),
                  DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                ],
                onChanged: (val) => status = val ?? 'Active',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;

              if (isEditing) {
                ref.read(permissionGroupProvider.notifier).updateGroup(
                  group!.copyWith(
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
                    status: status,
                  )
                );
              } else {
                ref.read(permissionGroupProvider.notifier).addGroup(
                  PermissionGroup(
                    id: 'pg_new_${DateTime.now().millisecondsSinceEpoch}',
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
                    permissionCount: 0,
                    assignedRolesCount: 0,
                    status: status,
                    createdDate: DateTime.now(),
                    mockTopPermissions: [],
                  )
                );
              }
              Navigator.pop(ctx);
            },
            child: Text(isEditing ? 'Save Changes' : 'Create Group'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(PermissionGroup group) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Group'),
        content: Text('Are you sure you want to delete the group "${group.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              ref.read(permissionGroupProvider.notifier).deleteGroup(group.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(permissionGroupProvider);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: state.isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(theme, state),
              _buildToolbar(theme, state),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: _buildGrid(theme, state, isDesktop),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildHeader(ThemeData theme, PermissionGroupState state) {
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
            child: Icon(LucideIcons.folders, color: theme.colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Permission Groups', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Organize permissions into logical collections', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: () => _showGroupDialog(),
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const Text('Create Group'),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(ThemeData theme, PermissionGroupState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => ref.read(permissionGroupProvider.notifier).setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search groups...',
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                isDense: true,
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: DropdownButtonFormField<String>(
              value: state.filterStatus,
              decoration: InputDecoration(
                labelText: 'Filter Status',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                isDense: true,
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All')),
                DropdownMenuItem(value: 'Active', child: Text('Active')),
                DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
              ],
              onChanged: (val) {
                if (val != null) {
                  ref.read(permissionGroupProvider.notifier).setFilterStatus(val);
                }
              },
            ),
          ),
          const Spacer(flex: 3),
          Text(
            '${state.filteredGroups.length} Groups found',
            style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(ThemeData theme, PermissionGroupState state, bool isDesktop) {
    if (state.filteredGroups.isEmpty) {
      return const Center(child: Text('No groups found.'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = isDesktop ? 3 : 1;
        if (constraints.maxWidth > 1400) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 900) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.2,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
          ),
          itemCount: state.filteredGroups.length,
          itemBuilder: (context, index) {
            final group = state.filteredGroups[index];
            return _buildGroupCard(theme, group);
          },
        );
      },
    );
  }

  Widget _buildGroupCard(ThemeData theme, PermissionGroup group) {
    final isActive = group.status == 'Active';

    return PremiumCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5))),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.folderKey, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    group.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(LucideIcons.moreVertical, size: 20),
                  onSelected: (val) {
                    if (val == 'edit') {
                      _showGroupDialog(group: group);
                    } else if (val == 'delete') {
                      _showDeleteDialog(group);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                  ],
                ),
              ],
            ),
          ),
          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.description,
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatBadge(theme, '${group.permissionCount} Perms', LucideIcons.key),
                      _buildStatBadge(theme, '${group.assignedRolesCount} Roles', LucideIcons.shieldCheck),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Expandable area mock using a simple button
                  Divider(color: theme.dividerColor.withOpacity(0.5)),
                  Theme(
                    data: theme.copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: Text('Top Permissions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                      children: group.mockTopPermissions.map((p) => 
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(LucideIcons.checkCircle2, size: 14, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(p, style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
                            ],
                          ),
                        )
                      ).toList(),
                    ),
                  )
                ],
              ),
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.5))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Created: ${DateFormat('MMM d, yyyy').format(group.createdDate)}',
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    group.status,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isActive ? Colors.green : Colors.red),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatBadge(ThemeData theme, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
