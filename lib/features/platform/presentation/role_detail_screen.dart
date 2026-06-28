import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import 'providers/role_detail_provider.dart';

class RoleDetailScreen extends ConsumerStatefulWidget {
  final String roleId;

  const RoleDetailScreen({super.key, required this.roleId});

  @override
  ConsumerState<RoleDetailScreen> createState() => _RoleDetailScreenState();
}

class _RoleDetailScreenState extends ConsumerState<RoleDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    Future.microtask(() => ref.read(roleDetailProvider.notifier).init(widget.roleId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showMockDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(roleDetailProvider);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    if (state.isLoading) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.role == null) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: const Center(child: Text('Role not found')),
      );
    }

    final role = state.role!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Role Details'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go('/platform/rbac/roles'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderCard(role, theme),
            const SizedBox(height: 24),
            _buildTabBar(theme),
            const SizedBox(height: 24),
            SizedBox(
              height: 800, // Fixed height for tab views in scroll view
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(state, theme, isDesktop),
                  _buildPermissionsTab(state, theme),
                  _buildUsersTab(state, theme),
                  _buildAuditTab(state, theme),
                  _buildTimelineTab(state, theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(role, ThemeData theme) {
    return PremiumCard(
      padding: const EdgeInsets.all(32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(LucideIcons.shieldCheck, size: 48, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(role.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    _buildStatusBadge(role.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Code: ${role.code} • Scope: ${role.scope}', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
                const SizedBox(height: 16),
                Text(role.description, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FilledButton.icon(
                onPressed: () => context.go('/platform/rbac/roles/${role.id}/edit'),
                icon: const Icon(LucideIcons.edit, size: 16),
                label: const Text('Edit Role'),
              ),
              const SizedBox(height: 8),
              PopupMenuButton<String>(
                child: OutlinedButton.icon(
                  onPressed: null, // Let PopupMenu handle the tap
                  icon: const Icon(LucideIcons.zap, size: 16),
                  label: const Text('Quick Actions'),
                ),
                onSelected: (val) {
                  if (val == 'clone') _showMockDialog('Clone Role ${role.name}');
                  if (val == 'users') _showMockDialog('Assign Users Wizard');
                  if (val == 'permissions') _showMockDialog('Manage Permissions Wizard');
                  if (val == 'deactivate') {
                    ref.read(roleDetailProvider.notifier).deactivateRole();
                    _showMockDialog('Role Deactivated');
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'clone', child: Text('Clone Role')),
                  const PopupMenuItem(value: 'users', child: Text('Assign Users')),
                  const PopupMenuItem(value: 'permissions', child: Text('Manage Permissions')),
                  const PopupMenuDivider(),
                  if (role.status == 'Active')
                    const PopupMenuItem(value: 'deactivate', child: Text('Deactivate Role', style: TextStyle(color: Colors.red))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = status == 'Active' ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Permissions'),
          Tab(text: 'Assigned Users'),
          Tab(text: 'Audit Log'),
          Tab(text: 'Timeline'),
        ],
      ),
    );
  }

  // --- TAB 1: OVERVIEW ---

  Widget _buildOverviewTab(RoleDetailState state, ThemeData theme, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildStatCard('Permission Summary', '${state.permissions.where((p) => p['isGranted']).length} / ${state.permissions.length}', LucideIcons.key, Colors.indigo, isDesktop),
            _buildStatCard('Users Assigned', '${state.assignedUsers.length}', LucideIcons.users, Colors.teal, isDesktop),
            _buildStatCard('Recently Modified', DateFormat('MMM d, y').format(state.auditLogs.first['timestamp']), LucideIcons.calendar, Colors.orange, isDesktop),
            _buildStatCard('Security Score', 'A+', LucideIcons.shieldCheck, Colors.green, isDesktop),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: PremiumCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Permission Distribution', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 250,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 60,
                          sections: state.permissionDistribution.entries.map((e) {
                            final color = e.key == 'Read' ? Colors.blue : e.key == 'Write' ? Colors.orange : e.key == 'Delete' ? Colors.red : Colors.purple;
                            return PieChartSectionData(
                              value: e.value,
                              title: '${e.value.toInt()}%',
                              color: color,
                              radius: 40,
                              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: state.permissionDistribution.keys.map((k) {
                        final color = k == 'Read' ? Colors.blue : k == 'Write' ? Colors.orange : k == 'Delete' ? Colors.red : Colors.purple;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            children: [
                              Container(width: 12, height: 12, color: color),
                              const SizedBox(width: 4),
                              Text(k, style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: PremiumCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Assigned Users by Organization', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 250,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 60,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final names = state.usersByOrganization.keys.toList();
                                  if (value.toInt() < names.length) {
                                    return Padding(padding: const EdgeInsets.only(top: 8), child: Text(names[value.toInt()], style: const TextStyle(fontSize: 10)));
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: state.usersByOrganization.entries.toList().asMap().entries.map((e) {
                            return BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(
                                  toY: e.value.value.toDouble(),
                                  color: theme.colorScheme.primary,
                                  width: 22,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDesktop) {
    return SizedBox(
      width: isDesktop ? 250 : double.infinity,
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

  // --- TAB 2: PERMISSIONS ---

  Widget _buildPermissionsTab(RoleDetailState state, ThemeData theme) {
    return PremiumCard(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        itemCount: state.permissions.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final perm = state.permissions[index];
          return ListTile(
            title: Text(perm['name']),
            subtitle: Text(perm['description']),
            trailing: Switch(
              value: perm['isGranted'],
              onChanged: (val) => _showMockDialog('Manage Permissions Wizard Required'),
            ),
          );
        },
      ),
    );
  }

  // --- TAB 3: USERS ---

  Widget _buildUsersTab(RoleDetailState state, ThemeData theme) {
    return PremiumCard(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        itemCount: state.assignedUsers.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final user = state.assignedUsers[index];
          return ListTile(
            leading: CircleAvatar(child: Text(user['name'].substring(0, 1))),
            title: Text(user['name']),
            subtitle: Text('${user['email']} • ${user['organization']}'),
            trailing: IconButton(
              icon: const Icon(LucideIcons.userMinus, color: Colors.red),
              onPressed: () => _showMockDialog('Unassign User'),
            ),
          );
        },
      ),
    );
  }

  // --- TAB 4 & 5: AUDIT & TIMELINE ---

  Widget _buildAuditTab(RoleDetailState state, ThemeData theme) {
    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: ListView.separated(
        itemCount: state.auditLogs.length,
        separatorBuilder: (_, __) => const Divider(height: 32),
        itemBuilder: (context, index) {
          final log = state.auditLogs[index];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, shape: BoxShape.circle),
                child: Icon(LucideIcons.activity, size: 16, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(log['action'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(log['details'], style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text('By ${log['user']} on ${DateFormat('MMM d, y h:mm a').format(log['timestamp'])}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimelineTab(RoleDetailState state, ThemeData theme) {
    // Reusing audit tab UI for Timeline conceptually
    return _buildAuditTab(state, theme);
  }
}
