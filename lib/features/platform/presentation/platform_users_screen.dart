import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:intl/intl.dart';
import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import 'providers/platform_user_list_provider.dart';
import '../domain/models/platform_user.dart';

class PlatformUsersScreen extends ConsumerStatefulWidget {
  const PlatformUsersScreen({super.key});

  @override
  ConsumerState<PlatformUsersScreen> createState() => _PlatformUsersScreenState();
}

class _PlatformUsersScreenState extends ConsumerState<PlatformUsersScreen> {
  final _searchController = TextEditingController();
  final _verticalScrollController = ScrollController();
  int _rowsPerPage = 10;
  int _currentPage = 0;

  @override
  void dispose() {
    _searchController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final state = ref.watch(platformUserListProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: OutlinedButton.icon(
              onPressed: () {
                context.go('/platform/users/invitations');
              },
              icon: const Icon(LucideIcons.mail, size: 18),
              label: const Text('Invitations'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: FilledButton.icon(
              onPressed: () => context.go('/platform/users/new'),
              icon: const Icon(LucideIcons.userPlus, size: 18),
              label: const Text('Create User'),
            ),
          ),
        ],
      ),
      body: state.isLoading && state.allUsers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context, state, isDesktop),
    );
  }

  Widget _buildBody(BuildContext context, PlatformUserListState state, bool isDesktop) {
    // Always use SingleChildScrollView for the entire body so that if content
    // exceeds screen height (due to zoom or small screen), it scrolls instead of overflowing.
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStats(state.allUsers, isDesktop),
          const SizedBox(height: 16),
          _buildToolbar(context, state, isDesktop),
          const SizedBox(height: 12),
          if (state.selectedUserIds.isNotEmpty) _buildBulkActionsBar(context, state),
          if (state.selectedUserIds.isNotEmpty) const SizedBox(height: 12),
          _buildTable(context, state, isDesktop),
        ],
      ),
    );
  }


  Widget _buildStats(List<PlatformUser> allUsers, bool isDesktop) {
    final total = allUsers.length;
    final active = allUsers.where((u) => u.status == PlatformUserStatus.active).length;
    final pending = allUsers.where((u) => u.status == PlatformUserStatus.pending).length;
    final locked = allUsers.where((u) => u.status == PlatformUserStatus.locked).length;
    final online = allUsers.where((u) => u.isOnline).length;
    final mfa = allUsers.where((u) => u.isMfaEnabled).length;

    final cards = [
      GradientKpiCard(title: 'Total Users', value: '$total', subtitle: 'All registered', icon: LucideIcons.users, gradientColors: [Colors.blue, Colors.lightBlue]),
      GradientKpiCard(title: 'Active Users', value: '$active', subtitle: 'Currently active', icon: LucideIcons.checkCircle, gradientColors: [Colors.green, Colors.lightGreen]),
      GradientKpiCard(title: 'Pending Invitations', value: '$pending', subtitle: 'Awaiting accept', icon: LucideIcons.mail, gradientColors: [Colors.orange, Colors.amber]),
      GradientKpiCard(title: 'Locked Accounts', value: '$locked', subtitle: 'Requires attention', icon: LucideIcons.lock, gradientColors: [Colors.red, Colors.redAccent]),
      GradientKpiCard(title: 'Online Users', value: '$online', subtitle: 'Active sessions', icon: LucideIcons.activity, gradientColors: [Colors.teal, Colors.tealAccent]),
      GradientKpiCard(title: 'MFA Enabled', value: '$mfa', subtitle: 'Secured accounts', icon: LucideIcons.shield, gradientColors: [Colors.indigo, Colors.indigoAccent]),
    ];

    if (isDesktop) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 16),
              Expanded(child: cards[1]),
              const SizedBox(width: 16),
              Expanded(child: cards[2]),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: cards[3]),
              const SizedBox(width: 16),
              Expanded(child: cards[4]),
              const SizedBox(width: 16),
              Expanded(child: cards[5]),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 16.0), child: c)).toList(),
      );
    }
  }

  Widget _buildToolbar(BuildContext context, PlatformUserListState state, bool isDesktop) {
    final filters = ['All', 'Active', 'Inactive', 'Locked', 'Pending'];
    final mfaFilters = ['All', 'Enabled', 'Disabled'];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 250,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name, email, ID...',
              prefixIcon: const Icon(LucideIcons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            ),
            onChanged: (val) {
              setState(() => _currentPage = 0);
              ref.read(platformUserListProvider.notifier).setSearchQuery(val);
            },
          ),
        ),
        ...filters.map((f) => ChoiceChip(
          label: Text(f),
          selected: state.filterStatus == f,
          onSelected: (selected) {
            if (selected) {
              setState(() => _currentPage = 0);
              ref.read(platformUserListProvider.notifier).setFilterStatus(f);
            }
          },
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: state.filterMfa,
              hint: const Text('MFA Status'),
              items: mfaFilters.map((m) => DropdownMenuItem(value: m, child: Text('MFA: $m'))).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _currentPage = 0);
                  ref.read(platformUserListProvider.notifier).setFilterMfa(val);
                }
              },
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Advanced Filters'),
                content: const Text('Filter by Tenant, Organization, Department, Role, etc.'),
                actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
              )
            );
          },
          icon: const Icon(LucideIcons.sliders, size: 16),
          label: const Text('Advanced'),
        ),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting to CSV...')));
          },
          icon: const Icon(LucideIcons.download, size: 16),
          label: const Text('Export'),
        ),
        IconButton(
          onPressed: () => ref.read(platformUserListProvider.notifier).loadUsers(),
          icon: const Icon(LucideIcons.refreshCw),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildBulkActionsBar(BuildContext context, PlatformUserListState state) {
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
          Text('${state.selectedUserIds.length} Selected', style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              ref.read(platformUserListProvider.notifier).bulkUpdateStatus(PlatformUserStatus.active);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Users activated')));
            },
            icon: const Icon(LucideIcons.checkCircle, color: Colors.green),
            label: const Text('Activate', style: TextStyle(color: Colors.green)),
          ),
          TextButton.icon(
            onPressed: () {
              ref.read(platformUserListProvider.notifier).bulkUpdateStatus(PlatformUserStatus.inactive);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Users deactivated')));
            },
            icon: const Icon(LucideIcons.slash, color: Colors.grey),
            label: const Text('Deactivate', style: TextStyle(color: Colors.grey)),
          ),
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Assigning Roles...')));
            },
            icon: const Icon(LucideIcons.shield),
            label: const Text('Assign Role'),
          ),
          TextButton.icon(
            onPressed: () {
              ref.read(platformUserListProvider.notifier).bulkDelete();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Users deleted')));
            },
            icon: const Icon(LucideIcons.trash2, color: Colors.red),
            label: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  CUSTOM ROW-BASED TABLE  — guaranteed to fit screen width
  // ─────────────────────────────────────────────────────────────

  static const double _checkW  = 48;
  static const double _actionsW = 48;

  Widget _buildTable(BuildContext context, PlatformUserListState state, bool isDesktop) {
    if (state.filteredUsers.isEmpty) {
      return PremiumCard(
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(48.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.users, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No users found.', style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
    }

    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage < state.filteredUsers.length)
        ? startIndex + _rowsPerPage
        : state.filteredUsers.length;
    final currentUsers = state.filteredUsers.sublist(startIndex, endIndex);
    final theme = Theme.of(context);

    return PremiumCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────
          _buildHeaderRow(context, state),
          const Divider(height: 1),
          // ── Rows: shrinkWrap so it sizes itself within the scroll view ──
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: currentUsers.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: theme.dividerColor.withOpacity(0.4),
            ),
            itemBuilder: (context, index) =>
                _buildUserRow(context, currentUsers[index], state, theme),
          ),
          // ── Pagination ───────────────────────────────────────
          const Divider(height: 1),
          _buildPagination(context, state, startIndex, endIndex, theme),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, PlatformUserListState state) {
    final theme = Theme.of(context);
    final bg = theme.colorScheme.surfaceContainerHighest.withOpacity(0.5);
    final style = theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.bold,
      letterSpacing: 0.8,
    );

    bool isAll = state.selectedUserIds.length == state.filteredUsers.length &&
        state.filteredUsers.isNotEmpty;

    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: _checkW,
            child: Checkbox(
              tristate: true,
              value: isAll ? true : state.selectedUserIds.isEmpty ? false : null,
              onChanged: (v) => ref
                  .read(platformUserListProvider.notifier)
                  .selectAll(v ?? false),
            ),
          ),
          Expanded(flex: 22, child: _sortHeader('Name', 'name', state, style)),
          Expanded(flex: 12, child: _sortHeader('Emp. ID', 'employeeId', state, style)),
          Expanded(flex: 20, child: _sortHeader('Contact', 'email', state, style)),
          Expanded(flex: 18, child: _sortHeader('Assignment', 'organization', state, style)),
          Expanded(flex: 13, child: Text('Role', style: style)),
          Expanded(flex: 11, child: Text('Status', style: style)),
          SizedBox(width: _actionsW, child: Text('', style: style)),
        ],
      ),
    );
  }

  Widget _sortHeader(String label, String key, PlatformUserListState state, TextStyle? style) {
    final isActive = state.sortColumn == key;
    return InkWell(
      onTap: () {
        final isAsc = isActive ? !state.sortAscending : true;
        ref.read(platformUserListProvider.notifier).setSort(key, isAsc);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: style),
          if (isActive) ...[
            const SizedBox(width: 4),
            Icon(
              state.sortAscending ? LucideIcons.chevronUp : LucideIcons.chevronDown,
              size: 12,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserRow(
      BuildContext context, PlatformUser user, PlatformUserListState state, ThemeData theme) {
    final isSelected = state.selectedUserIds.contains(user.id);

    return InkWell(
      onTap: () => ref.read(platformUserListProvider.notifier).toggleSelection(user.id),
      child: Container(
        color: isSelected
            ? theme.colorScheme.primaryContainer.withOpacity(0.25)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Checkbox
            SizedBox(
              width: _checkW,
              child: Checkbox(
                value: isSelected,
                onChanged: (_) =>
                    ref.read(platformUserListProvider.notifier).toggleSelection(user.id),
              ),
            ),
            // Name / Avatar
            Expanded(
              flex: 22,
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 17,
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                        child: Text(
                          user.firstName[0],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      if (user.isOnline)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.colorScheme.surface, width: 1.5),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user.fullName,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (user.isMfaEnabled)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.shieldCheck, size: 10, color: Colors.green.shade700),
                              const SizedBox(width: 2),
                              Text('MFA', style: TextStyle(fontSize: 10, color: Colors.green.shade700)),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Employee ID
            Expanded(
              flex: 12,
              child: Text(
                user.employeeId,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Contact
            Expanded(
              flex: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(user.email, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                  if (user.mobile != null)
                    Text(
                      user.mobile!,
                      style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            // Assignment
            Expanded(
              flex: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${user.tenantName}',
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${user.organizationName} • ${user.departmentName}',
                    style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Role badge
            Expanded(
              flex: 13,
              child: _buildRoleBadge(user.role),
            ),
            // Status chip
            Expanded(
              flex: 11,
              child: _buildStatusChip(user.status),
            ),
            // Actions ── always visible, fixed width
            SizedBox(
              width: _actionsW,
              child: _buildActionMenu(user, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination(BuildContext context, PlatformUserListState state,
      int startIndex, int endIndex, ThemeData theme) {
    final totalPages =
        ((state.filteredUsers.length - 1) / _rowsPerPage).floor() + 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      // Use Wrap so it wraps to next line on narrow screens instead of overflowing
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 4,
        children: [
          Text(
            'Showing ${startIndex + 1}–$endIndex of ${state.filteredUsers.length}',
            style: theme.textTheme.bodySmall,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Per page: ', style: TextStyle(fontSize: 12)),
              DropdownButton<int>(
                value: _rowsPerPage,
                underline: const SizedBox.shrink(),
                style: const TextStyle(fontSize: 12),
                items: [10, 20, 50]
                    .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() {
                    _rowsPerPage = v;
                    _currentPage = 0;
                  });
                },
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 28,
                height: 28,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 16,
                  icon: const Icon(LucideIcons.chevronLeft),
                  onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
                ),
              ),
              Text(' ${_currentPage + 1}/$totalPages ', style: const TextStyle(fontSize: 12)),
              SizedBox(
                width: 28,
                height: 28,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 16,
                  icon: const Icon(LucideIcons.chevronRight),
                  onPressed: endIndex < state.filteredUsers.length
                      ? () => setState(() => _currentPage++)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(PlatformUserRole role) {
    Color color;
    String label;
    switch (role) {
      case PlatformUserRole.systemAdmin:
        color = Colors.red;
        label = 'System Admin';
        break;
      case PlatformUserRole.tenantAdmin:
        color = Colors.purple;
        label = 'Tenant Admin';
        break;
      case PlatformUserRole.organizationAdmin:
        color = Colors.indigo;
        label = 'Org Admin';
        break;
      case PlatformUserRole.manager:
        color = Colors.orange;
        label = 'Manager';
        break;
      case PlatformUserRole.user:
        color = Colors.blue;
        label = 'User';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
    );
  }

  Widget _buildStatusChip(PlatformUserStatus status) {
    Color color;
    switch (status) {
      case PlatformUserStatus.active:
        color = Colors.green;
        break;
      case PlatformUserStatus.inactive:
        color = Colors.grey;
        break;
      case PlatformUserStatus.locked:
        color = Colors.red;
        break;
      case PlatformUserStatus.pending:
        color = Colors.orange;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
      child: Text(status.name.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11), overflow: TextOverflow.ellipsis),
    );
  }

  Widget _buildActionMenu(PlatformUser user, BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(LucideIcons.moreVertical, size: 20),
      tooltip: 'Actions',
      onSelected: (val) {
        if (val == 'view') {
          context.go('/platform/users/${user.id}');
        } else if (val == 'activity') {
          context.go('/platform/users/${user.id}/activity');
        } else if (val == 'edit') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Edit user ${user.fullName}')));
        } else if (val == 'reset') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reset password for ${user.fullName}')));
        } else if (val == 'lock') {
          ref.read(platformUserListProvider.notifier).updateStatus(user.id, PlatformUserStatus.locked);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Locked user ${user.fullName}')));
        } else if (val == 'unlock') {
          ref.read(platformUserListProvider.notifier).updateStatus(user.id, PlatformUserStatus.active);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unlocked user ${user.fullName}')));
        } else if (val == 'delete') {
          ref.read(platformUserListProvider.notifier).toggleSelection(user.id);
          ref.read(platformUserListProvider.notifier).bulkDelete();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted user ${user.fullName}')));
        }
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem(value: 'view', child: ListTile(leading: Icon(LucideIcons.eye), title: Text('View Details'))),
        const PopupMenuItem(value: 'activity', child: ListTile(leading: Icon(LucideIcons.activity), title: Text('View Activity', style: TextStyle(color: Colors.blue)))),
        const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(LucideIcons.edit), title: Text('Edit'))),
        const PopupMenuItem(value: 'reset', child: ListTile(leading: Icon(LucideIcons.key), title: Text('Reset Password'))),
        const PopupMenuDivider(),
        if (user.status != PlatformUserStatus.locked)
          const PopupMenuItem(value: 'lock', child: ListTile(leading: Icon(LucideIcons.lock), title: Text('Lock Account')))
        else
          const PopupMenuItem(value: 'unlock', child: ListTile(leading: Icon(LucideIcons.unlock), title: Text('Unlock Account'))),
        const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(LucideIcons.trash2, color: Colors.red), title: Text('Delete', style: TextStyle(color: Colors.red)))),
      ],
    );
  }
}
