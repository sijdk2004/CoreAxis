import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import 'providers/tenant_detail_provider.dart';

class TenantDetailScreen extends ConsumerStatefulWidget {
  final String tenantId;
  const TenantDetailScreen({super.key, required this.tenantId});

  @override
  ConsumerState<TenantDetailScreen> createState() => _TenantDetailScreenState();
}

class _TenantDetailScreenState extends ConsumerState<TenantDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
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
    final asyncState = ref.watch(tenantDetailProvider(widget.tenantId));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Tenant Details'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go('/platform/tenants'),
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
            Tab(text: 'Organizations'),
            Tab(text: 'Users'),
            Tab(text: 'Usage'),
            Tab(text: 'Audit'),
            Tab(text: 'Documents'),
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
              _buildPlaceholderTab('Organizations', LucideIcons.building),
              _buildPlaceholderTab('Users', LucideIcons.users),
              _buildPlaceholderTab('Usage Statistics', LucideIcons.barChart2),
              _buildPlaceholderTab('Audit Logs', LucideIcons.shield),
              _buildPlaceholderTab('Documents', LucideIcons.fileText),
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
        if (val == 'subscription') {
          context.go('/platform/tenants/${widget.tenantId}/subscription');
        } else if (val == 'analytics') {
          context.go('/platform/tenants/${widget.tenantId}/analytics');
        } else if (val == 'settings') {
          context.go('/platform/tenants/${widget.tenantId}/settings');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mock Action: $val')));
        }
      },
      itemBuilder: (ctx) => [
        const PopupMenuItem(value: 'edit', child: Text('Edit Tenant')),
        const PopupMenuItem(value: 'settings', child: Text('Settings')),
        const PopupMenuItem(value: 'subscription', child: Text('Manage Subscription')),
        const PopupMenuItem(value: 'analytics', child: Text('Analytics')),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'suspend', child: Text('Suspend', style: TextStyle(color: Colors.orange))),
        const PopupMenuItem(value: 'activate', child: Text('Activate', style: TextStyle(color: Colors.green))),
      ],
    );
  }

  Widget _buildOverviewTab(BuildContext context, TenantDetailState state, bool isDesktop) {
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
                Expanded(child: _buildUserGrowthChart(context, state)),
                const SizedBox(width: 24),
                Expanded(child: _buildRevenueTrendChart(context, state)),
              ],
            )
          else
            Column(
              children: [
                _buildUserGrowthChart(context, state),
                const SizedBox(height: 24),
                _buildRevenueTrendChart(context, state),
              ],
            ),
          const SizedBox(height: 32),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildRecentActivities(context, state)),
                const SizedBox(width: 24),
                Expanded(child: _buildStorageUsageChart(context, state)),
              ],
            )
          else
            Column(
              children: [
                _buildRecentActivities(context, state),
                const SizedBox(height: 24),
                _buildStorageUsageChart(context, state),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderProfile(BuildContext context, TenantDetailState state) {
    final t = state.tenant;
    Color statusColor = Colors.grey;
    if (t.status == 'Active') statusColor = Colors.green;
    if (t.status == 'Trial') statusColor = Colors.orange;
    if (t.status == 'Suspended') statusColor = Colors.red;

    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage(t.logoUrl),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(t.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(t.status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Tenant Code: ${t.code} • Created: ${DateFormat('MMM dd, yyyy').format(t.createdAt)}', style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(BuildContext context, TenantDetailState state, bool isDesktop) {
    final s = state.stats;
    final cards = [
      GradientKpiCard(title: 'Total Users', value: '${s['total_users']}', subtitle: '${s['active_users']} active', icon: LucideIcons.users, gradientColors: [Colors.blue, Colors.lightBlue]),
      GradientKpiCard(title: 'Subscription', value: state.tenant.subscriptionPlan, subtitle: 'Renews soon', icon: LucideIcons.creditCard, gradientColors: [Colors.purple, Colors.purpleAccent]),
      GradientKpiCard(title: 'Storage Used', value: s['storage_used'], subtitle: 'of ${s['storage_limit']}', icon: LucideIcons.hardDrive, gradientColors: [Colors.teal, Colors.tealAccent]),
      GradientKpiCard(title: 'System Health', value: s['system_health'], subtitle: '${s['api_requests']} API calls', icon: LucideIcons.activity, gradientColors: [Colors.green, Colors.lightGreen]),
    ];

    if (isDesktop) {
      return Row(
        children: cards.asMap().entries.map((e) => Expanded(
          child: Padding(padding: EdgeInsets.only(right: e.key < cards.length - 1 ? 16.0 : 0), child: e.value)
        )).toList(),
      );
    } else {
      return Column(
        children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 16.0), child: c)).toList(),
      );
    }
  }

  Widget _buildUserGrowthChart(BuildContext context, TenantDetailState state) {
    final data = state.charts['user_growth'] as List;
    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('User Growth', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (val, meta) {
                        int idx = val.toInt();
                        if (idx >= 0 && idx < data.length) {
                          return Text(data[idx]['label'], style: const TextStyle(color: Colors.grey, fontSize: 12));
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['value'] as num).toDouble())).toList(),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 4,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.2),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueTrendChart(BuildContext context, TenantDetailState state) {
    final data = state.charts['revenue_trend'] as List;
    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Revenue Trend (MRR)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (val, meta) {
                        int idx = val.toInt();
                        if (idx >= 0 && idx < data.length) {
                          return Text(data[idx]['label'], style: const TextStyle(color: Colors.grey, fontSize: 12));
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: data.asMap().entries.map((e) => BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: (e.value['value'] as num).toDouble(),
                      color: Colors.purple,
                      width: 16,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                    ),
                  ],
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageUsageChart(BuildContext context, TenantDetailState state) {
    final data = state.charts['storage_usage'] as List;
    final colors = [Colors.teal, Colors.blue, Colors.orange, Colors.purple];

    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Storage Usage', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: data.asMap().entries.map((e) {
                        return PieChartSectionData(
                          color: colors[e.key % colors.length],
                          value: (e.value['value'] as num).toDouble(),
                          title: '${e.value['value']}%',
                          radius: 50,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.asMap().entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Container(width: 12, height: 12, color: colors[e.key % colors.length]),
                          const SizedBox(width: 8),
                          Text(e.value['label']),
                        ],
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities(BuildContext context, TenantDetailState state) {
    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Activities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...state.activities.map((item) {
            IconData icon = LucideIcons.activity;
            Color color = Colors.grey;
            if (item['type'] == 'auth') { icon = LucideIcons.logIn; color = Colors.blue; }
            if (item['type'] == 'org') { icon = LucideIcons.building; color = Colors.green; }
            if (item['type'] == 'billing') { icon = LucideIcons.creditCard; color = Colors.purple; }
            if (item['type'] == 'system') { icon = LucideIcons.server; color = Colors.orange; }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(icon, color: color, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        Text(item['time'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTab(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('This section is currently under construction.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
