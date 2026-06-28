import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import '../domain/models/platform_user.dart';
import '../domain/models/role.dart';
import 'providers/user_role_assignment_provider.dart';

class UserRoleAssignmentScreen extends ConsumerStatefulWidget {
  const UserRoleAssignmentScreen({super.key});

  @override
  ConsumerState<UserRoleAssignmentScreen> createState() => _UserRoleAssignmentScreenState();
}

class _UserRoleAssignmentScreenState extends ConsumerState<UserRoleAssignmentScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAssignRolesDialog(BuildContext context, PlatformUser user, List<Role> allRoles, List<String> currentlyAssignedIds) {
    final selectedRoleIds = List<String>.from(currentlyAssignedIds);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Assign Roles'),
              content: SizedBox(
                width: 400,
                height: 400,
                child: Column(
                  children: [
                    Text('Select roles to assign to ${user.firstName} ${user.lastName}.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: allRoles.length,
                        itemBuilder: (context, index) {
                          final role = allRoles[index];
                          final isSelected = selectedRoleIds.contains(role.id);
                          return CheckboxListTile(
                            title: Text(role.name),
                            subtitle: Text(role.code),
                            value: isSelected,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  selectedRoleIds.add(role.id);
                                } else {
                                  selectedRoleIds.remove(role.id);
                                }
                              });
                            },
                          );
                        },
                      ),
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
                    ref.read(userRoleAssignmentProvider.notifier).assignRoles(user.id, selectedRoleIds);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save Assignments'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(userRoleAssignmentProvider);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: state.isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(theme, state),
              Expanded(
                child: Row(
                  children: [
                    // Left Pane: User List
                    Expanded(
                      flex: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(right: BorderSide(color: theme.dividerColor.withOpacity(0.5))),
                        ),
                        child: Column(
                          children: [
                            _buildLeftToolbar(theme, state),
                            Expanded(child: _buildUserList(theme, state)),
                          ],
                        ),
                      ),
                    ),
                    // Right Pane: Details & Assignment
                    Expanded(
                      flex: 6,
                      child: state.selectedUserId == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(LucideIcons.userCheck, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.2)),
                                const SizedBox(height: 16),
                                Text('Select a user to view or assign roles', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 16)),
                              ],
                            ),
                          )
                        : _buildRightPane(theme, state),
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildHeader(ThemeData theme, UserRoleAssignmentState state) {
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
            child: Icon(LucideIcons.userCog, color: theme.colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('User Role Assignment', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Assign and manage roles for platform users', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeftToolbar(ThemeData theme, UserRoleAssignmentState state) {
    final hasSelection = state.selectedUserIdsForBulk.isNotEmpty;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5))),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (val) => ref.read(userRoleAssignmentProvider.notifier).searchUsers(val),
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: const Icon(LucideIcons.search, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              isDense: true,
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('${state.filteredUsers.length} Users', style: const TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              if (hasSelection) ...[
                Text('${state.selectedUserIdsForBulk.length} selected', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Bulk Assign Roles'),
                        content: const Text('Bulk assignment mock interface.'),
                        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
                      )
                    );
                  },
                  child: const Text('Bulk Assign'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(ThemeData theme, UserRoleAssignmentState state) {
    return ListView.separated(
      itemCount: state.filteredUsers.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final user = state.filteredUsers[index];
        final isSelected = state.selectedUserId == user.id;
        final assignedRoleIds = state.assignedRoles[user.id] ?? [];
        final isBulkSelected = state.selectedUserIdsForBulk.contains(user.id);

        return ListTile(
          selected: isSelected,
          selectedTileColor: theme.colorScheme.primary.withOpacity(0.05),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: isBulkSelected,
                onChanged: (_) => ref.read(userRoleAssignmentProvider.notifier).toggleBulkSelection(user.id),
              ),
              CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text('${user.firstName[0]}${user.lastName[0]}', style: TextStyle(color: theme.colorScheme.primary)),
              ),
            ],
          ),
          title: Text('${user.firstName} ${user.lastName}', style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(user.email, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text('${assignedRoleIds.length} roles', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          onTap: () => ref.read(userRoleAssignmentProvider.notifier).selectUser(user.id),
        );
      },
    );
  }

  Widget _buildRightPane(ThemeData theme, UserRoleAssignmentState state) {
    final user = state.users.firstWhere((u) => u.id == state.selectedUserId);
    final assignedRoleIds = state.assignedRoles[user.id] ?? [];
    final assignedRoles = state.roles.where((r) => assignedRoleIds.contains(r.id)).toList();
    final logs = state.auditLogs[user.id] ?? [];

    int totalPermissions = 0;
    for (var r in assignedRoles) {
      totalPermissions += r.permissionCount;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // User Card
          PremiumCard(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text('${user.firstName[0]}${user.lastName[0]}', style: TextStyle(color: theme.colorScheme.primary, fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${user.firstName} ${user.lastName}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(user.email, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(user.organizationName ?? 'No Org', style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(user.departmentName ?? 'No Dept', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Assignment Area
          PremiumCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Assigned Roles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    FilledButton.icon(
                      onPressed: () => _showAssignRolesDialog(context, user, state.roles, assignedRoleIds),
                      icon: const Icon(LucideIcons.plus, size: 16),
                      label: const Text('Assign Roles'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                if (assignedRoles.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor, style: BorderStyle.solid),
                    ),
                    child: const Column(
                      children: [
                        Icon(LucideIcons.shieldAlert, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No roles assigned', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                      ],
                    ),
                  )
                else
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: assignedRoles.map((role) {
                      return Chip(
                        label: Text(role.name),
                        avatar: const Icon(LucideIcons.shieldCheck, size: 16),
                        backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
                        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
                        deleteIcon: const Icon(LucideIcons.x, size: 16),
                        onDeleted: () {
                          ref.read(userRoleAssignmentProvider.notifier).removeRole(user.id, role.id);
                        },
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.key, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text('Permission Summary:', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This user has access to $totalPermissions cumulative permissions across assigned roles.', 
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant)
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          
          // Audit Timeline
          const Text('Assignment History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (logs.isEmpty)
            const Text('No assignment history found.')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                final isAdd = log.action == 'Assigned Role';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (isAdd ? Colors.green : Colors.red).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(isAdd ? LucideIcons.plus : LucideIcons.minus, size: 16, color: isAdd ? Colors.green : Colors.red),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(log.details, style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('By ${log.performedBy} on ${DateFormat('MMM d, y h:mm a').format(log.timestamp)}', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
