import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import '../domain/models/platform_user.dart';
import 'providers/user_detail_provider.dart';

class UserDetailScreen extends ConsumerStatefulWidget {
  final String userId;
  const UserDetailScreen({super.key, required this.userId});

  @override
  ConsumerState<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends ConsumerState<UserDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final asyncState = ref.watch(userDetailProvider(widget.userId));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go('/platform/users'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: _buildQuickActions(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Profile'),
            Tab(text: 'Roles'),
            Tab(text: 'Permissions'),
            Tab(text: 'Sessions'),
            Tab(text: 'Activity'),
            Tab(text: 'Documents'),
            Tab(text: 'Audit Logs'),
            Tab(text: 'Timeline'),
          ],
        ),
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(context, state, isDesktop),
              _buildPlaceholderTab('Profile Details', LucideIcons.user),
              _buildPlaceholderTab('Roles', LucideIcons.shield),
              _buildPlaceholderTab('Permissions', LucideIcons.key),
              _buildPlaceholderTab('Active Sessions', LucideIcons.monitor),
              _buildPlaceholderTab('User Activity', LucideIcons.activity),
              _buildPlaceholderTab('Documents', LucideIcons.fileText),
              _buildPlaceholderTab('Audit Logs', LucideIcons.clipboardList),
              _buildPlaceholderTab('Timeline', LucideIcons.clock),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(LucideIcons.moreVertical),
      onSelected: (val) {
        if (val == 'activity_log') {
          context.push('/platform/users/${widget.userId}/activity');
        } else if (val == 'edit') {
          context.push('/platform/users/${widget.userId}/profile');
        } else if (val == 'sessions') {
          context.push('/platform/users/${widget.userId}/sessions');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mock Action: $val')));
        }
      },
      itemBuilder: (ctx) => [
        const PopupMenuItem(value: 'edit', child: Text('Edit Profile')),
        const PopupMenuItem(value: 'reset_password', child: Text('Reset Password')),
        const PopupMenuItem(value: 'assign_roles', child: Text('Assign Roles')),
        const PopupMenuItem(value: 'sessions', child: Text('View Active Sessions', style: TextStyle(color: Colors.deepPurple))),
        const PopupMenuItem(value: 'activity_log', child: Text('View Activity Log', style: TextStyle(color: Colors.blue))),
        const PopupMenuItem(value: 'send_invite', child: Text('Send Invitation')),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'lock', child: Text('Lock Account', style: TextStyle(color: Colors.orange))),
        const PopupMenuItem(value: 'deactivate', child: Text('Deactivate', style: TextStyle(color: Colors.red))),
      ],
    );
  }

  Widget _buildOverviewTab(BuildContext context, UserDetailState state, bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderProfile(context, state),
          const SizedBox(height: 32),
          _buildSummaryCards(context, state, isDesktop),
          const SizedBox(height: 32),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildLoginTrendChart(context, state)),
                const SizedBox(width: 24),
                Expanded(child: _buildDepartmentChart(context, state)),
              ],
            )
          else
            Column(
              children: [
                _buildLoginTrendChart(context, state),
                const SizedBox(height: 24),
                _buildDepartmentChart(context, state),
              ],
            ),
          const SizedBox(height: 32),
          _buildActivityTimelineChart(context, state),
        ],
      ),
    );
  }

  Widget _buildHeaderProfile(BuildContext context, UserDetailState state) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                '${state.user.firstName[0]}${state.user.lastName[0]}',
                style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('${state.user.firstName} ${state.user.lastName}', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      _buildStatusBadge(state.user.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(state.user.email, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(LucideIcons.badgeCheck, 'ID: ${state.user.employeeId}', theme),
                      _buildInfoChip(LucideIcons.shield, _getRoleName(state.user.role), theme),
                      _buildInfoChip(LucideIcons.building, state.user.organizationName ?? 'No Org', theme),
                      _buildInfoChip(LucideIcons.users, state.user.departmentName ?? 'No Dept', theme),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildStatusBadge(PlatformUserStatus status) {
    Color color;
    String label;
    switch (status) {
      case PlatformUserStatus.active:
        color = Colors.green;
        label = 'Active';
        break;
      case PlatformUserStatus.inactive:
        color = Colors.grey;
        label = 'Inactive';
        break;
      case PlatformUserStatus.locked:
        color = Colors.red;
        label = 'Locked';
        break;
      case PlatformUserStatus.pending:
        color = Colors.orange;
        label = 'Pending';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSummaryCards(BuildContext context, UserDetailState state, bool isDesktop) {
    final cards = [
      GradientKpiCard(
        title: 'Security Score',
        value: '${state.securityScore}%',
        icon: LucideIcons.shieldCheck,
        subtitle: '+5% this month',
        gradientColors: state.securityScore > 80 ? [Colors.green.shade700, Colors.green] : [Colors.orange.shade700, Colors.orange],
      ),
      GradientKpiCard(
        title: 'MFA Status',
        value: state.isMfaEnabled ? 'Enabled' : 'Disabled',
        icon: LucideIcons.smartphone,
        subtitle: state.isMfaEnabled ? '+ Secured' : 'Action Required',
        gradientColors: state.isMfaEnabled ? [Colors.blue.shade700, Colors.blue] : [Colors.red.shade700, Colors.red],
      ),
      GradientKpiCard(
        title: 'Last Login',
        value: state.lastLoginTime,
        icon: LucideIcons.logIn,
        subtitle: '+ ${state.lastLoginLocation}',
        gradientColors: [Colors.purple.shade700, Colors.purple],
      ),
      GradientKpiCard(
        title: 'Storage Used',
        value: '${state.storageUsedGb} GB',
        icon: LucideIcons.database,
        subtitle: (state.storageUsedGb / state.storageTotalGb) < 0.8 ? '+ of ${state.storageTotalGb} GB total' : 'of ${state.storageTotalGb} GB total',
        gradientColors: [Colors.teal.shade700, Colors.teal],
      ),
    ];

    if (isDesktop) {
      return Row(
        children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 16.0), child: c))).toList(),
      );
    } else {
      return Column(
        children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 16.0), child: c)).toList(),
      );
    }
  }

  Widget _buildLoginTrendChart(BuildContext context, UserDetailState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Login Trend (Last 7 Days)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          if (value.toInt() >= 0 && value.toInt() < days.length) {
                            return Text(days[value.toInt()]);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: state.loginTrend.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentChart(BuildContext context, UserDetailState state) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red];
    int colorIndex = 0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Department Participation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: state.departmentParticipation.entries.map((e) {
                    final color = colors[colorIndex % colors.length];
                    colorIndex++;
                    return PieChartSectionData(
                      color: color,
                      value: e.value,
                      title: '${e.value.toInt()}%',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTimelineChart(BuildContext context, UserDetailState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Activity Timeline (Today)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value % 2 == 0) {
                            return Text('${(value.toInt() * 2).toString().padLeft(2, '0')}:00');
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: state.activityTimeline.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value,
                          color: Theme.of(context).colorScheme.tertiary,
                          width: 12,
                          borderRadius: BorderRadius.circular(4),
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
    );
  }

  Widget _buildPlaceholderTab(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 24, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('This section is under development', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  String _getRoleName(PlatformUserRole role) {
    switch (role) {
      case PlatformUserRole.systemAdmin: return 'System Admin';
      case PlatformUserRole.tenantAdmin: return 'Tenant Admin';
      case PlatformUserRole.organizationAdmin: return 'Org Admin';
      case PlatformUserRole.manager: return 'Manager';
      case PlatformUserRole.user: return 'User';
    }
  }
}
