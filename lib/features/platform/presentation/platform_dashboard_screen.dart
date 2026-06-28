import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import '../data/platform_dashboard_provider.dart';

class PlatformDashboardScreen extends ConsumerStatefulWidget {
  const PlatformDashboardScreen({super.key});

  @override
  ConsumerState<PlatformDashboardScreen> createState() => _PlatformDashboardScreenState();
}

class _PlatformDashboardScreenState extends ConsumerState<PlatformDashboardScreen> {
  final List<String> _timeframes = ['1M', '3M', 'YTD', '1Y'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final dashboardState = ref.watch(platformDashboardNotifierProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: dashboardState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error loading dashboard: $error')),
        data: (state) {
          final kpis = state.kpis;
          final charts = state.charts;
          final widgets = state.widgets;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, theme),
                const SizedBox(height: 32),
                _buildExecutiveSummary(context),
                const SizedBox(height: 32),
                _buildKpiSection(kpis, isDesktop),
                const SizedBox(height: 32),
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildLineChart(context, 'Tenant Growth Trend', charts['tenant_growth_trend']).animate().fade(delay: 500.ms)),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: _buildLineChart(context, 'User Activity Trend', charts['user_activity_trend'], Colors.blue).animate().fade(delay: 600.ms)),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildLineChart(context, 'Tenant Growth Trend', charts['tenant_growth_trend']).animate().fade(delay: 500.ms),
                      const SizedBox(height: 24),
                      _buildLineChart(context, 'User Activity Trend', charts['user_activity_trend'], Colors.blue).animate().fade(delay: 600.ms),
                    ],
                  ),
                const SizedBox(height: 32),
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildBarChart(context, 'Workflow Execution Trend', charts['workflow_execution_trend'], Colors.purple).animate().fade(delay: 700.ms)),
                      const SizedBox(width: 24),
                      Expanded(flex: 1, child: _buildTopTenants(context, widgets['top_tenants']).animate().fade(delay: 800.ms)),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildBarChart(context, 'Workflow Execution Trend', charts['workflow_execution_trend'], Colors.purple).animate().fade(delay: 700.ms),
                      const SizedBox(height: 24),
                      _buildTopTenants(context, widgets['top_tenants']).animate().fade(delay: 800.ms),
                    ],
                  ),
                const SizedBox(height: 32),
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 1, child: _buildRecentActivities(context, widgets['recent_activities']).animate().fade(delay: 900.ms)),
                      const SizedBox(width: 24),
                      Expanded(flex: 1, child: _buildPendingTasks(context, widgets['pending_tasks']).animate().fade(delay: 1000.ms)),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildRecentActivities(context, widgets['recent_activities']).animate().fade(delay: 900.ms),
                      const SizedBox(height: 24),
                      _buildPendingTasks(context, widgets['pending_tasks']).animate().fade(delay: 1000.ms),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Executive Dashboard', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            const SizedBox(height: 4),
            Text('ERP Platform Health & Adoption', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600)),
          ],
        ),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildTimeframeFilters(),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(LucideIcons.download, size: 18),
              label: const Text('Export Report'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ],
    ).animate().fade().slideY(begin: -0.2);
  }

  Widget _buildTimeframeFilters() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _timeframes.map((tf) {
          final isSelected = ref.watch(platformDashboardNotifierProvider).value?.timeframe == tf;
          return GestureDetector(
            onTap: () => ref.read(platformDashboardNotifierProvider.notifier).setTimeframe(tf),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : [],
              ),
              child: Text(
                tf,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.black : Colors.grey.shade600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExecutiveSummary(BuildContext context) {
    final theme = Theme.of(context);
    return PremiumCard(
      padding: const EdgeInsets.all(24),
      gradient: LinearGradient(colors: [Colors.blue.shade900, Colors.purple.shade900]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.sparkles, color: Colors.yellowAccent),
              const SizedBox(width: 8),
              Text('Platform AI Insights', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              const InsightPill(text: 'Tenant onboarding is up 12.5% this quarter.', icon: Icons.trending_up, color: Colors.greenAccent),
              const InsightPill(text: 'Workflow executions reached peak capacity.', icon: Icons.speed, color: Colors.orangeAccent),
              const InsightPill(text: 'AI feature adoption is growing rapidly.', icon: Icons.star, color: Colors.yellowAccent),
            ],
          ),
        ],
      ),
    ).animate().fade(delay: 50.ms).slideY(begin: 0.1);
  }

  Widget _buildKpiSection(Map<String, dynamic> kpis, bool isDesktop) {
    final revenueFormatted = (kpis['monthly_revenue'] / 1000).toStringAsFixed(1);
    
    if (isDesktop) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: GradientKpiCard(title: 'Total Tenants', value: '${kpis['total_tenants']}', subtitle: '+${kpis['tenants_growth']}%', icon: LucideIcons.building, gradientColors: [Colors.teal, Colors.teal]).animate().fade(delay: 100.ms).slideY(begin: 0.1)),
              const SizedBox(width: 16),
              Expanded(child: GradientKpiCard(title: 'Active Orgs', value: '${kpis['active_organizations']}', subtitle: '+${kpis['orgs_growth']}%', icon: LucideIcons.building2, gradientColors: [Colors.blue, Colors.blue]).animate().fade(delay: 200.ms).slideY(begin: 0.1)),
              const SizedBox(width: 16),
              Expanded(child: GradientKpiCard(title: 'Active Users', value: '${kpis['active_users']}', subtitle: '+${kpis['users_growth']}%', icon: LucideIcons.users, gradientColors: [Colors.purple, Colors.purple]).animate().fade(delay: 300.ms).slideY(begin: 0.1)),
              const SizedBox(width: 16),
              Expanded(child: GradientKpiCard(title: 'Workflows', value: '${kpis['workflow_executions']}', subtitle: '+${kpis['workflows_growth']}%', icon: LucideIcons.gitBranch, gradientColors: [Colors.orange, Colors.orange]).animate().fade(delay: 400.ms).slideY(begin: 0.1)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: GradientKpiCard(title: 'Pending Approvals', value: '${kpis['pending_approvals']}', subtitle: '${kpis['approvals_growth']}%', icon: LucideIcons.checkSquare, gradientColors: [Colors.indigo, Colors.indigo], isNegativeGood: true).animate().fade(delay: 500.ms).slideY(begin: 0.1)),
              const SizedBox(width: 16),
              Expanded(child: GradientKpiCard(title: 'Docs Stored', value: '${kpis['documents_stored']}k', subtitle: '+${kpis['documents_growth']}%', icon: LucideIcons.fileText, gradientColors: [Colors.green, Colors.green]).animate().fade(delay: 600.ms).slideY(begin: 0.1)),
              const SizedBox(width: 16),
              Expanded(child: GradientKpiCard(title: 'AI Requests', value: '${kpis['ai_requests']}', subtitle: '+${kpis['ai_requests_growth']}%', icon: LucideIcons.bot, gradientColors: [Colors.lightBlue, Colors.lightBlue]).animate().fade(delay: 700.ms).slideY(begin: 0.1)),
              const SizedBox(width: 16),
              Expanded(child: GradientKpiCard(title: 'Monthly Revenue', value: '\$${revenueFormatted}k', subtitle: '+${kpis['revenue_growth']}%', icon: LucideIcons.dollarSign, gradientColors: [Colors.pink, Colors.pink]).animate().fade(delay: 800.ms).slideY(begin: 0.1)),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: [
          GradientKpiCard(title: 'Total Tenants', value: '${kpis['total_tenants']}', subtitle: '+${kpis['tenants_growth']}%', icon: LucideIcons.building, gradientColors: [Colors.teal, Colors.teal]),
          const SizedBox(height: 16),
          GradientKpiCard(title: 'Active Orgs', value: '${kpis['active_organizations']}', subtitle: '+${kpis['orgs_growth']}%', icon: LucideIcons.building2, gradientColors: [Colors.blue, Colors.blue]),
          const SizedBox(height: 16),
          GradientKpiCard(title: 'Active Users', value: '${kpis['active_users']}', subtitle: '+${kpis['users_growth']}%', icon: LucideIcons.users, gradientColors: [Colors.purple, Colors.purple]),
          const SizedBox(height: 16),
          GradientKpiCard(title: 'Workflows', value: '${kpis['workflow_executions']}', subtitle: '+${kpis['workflows_growth']}%', icon: LucideIcons.gitBranch, gradientColors: [Colors.orange, Colors.orange]),
          const SizedBox(height: 16),
          GradientKpiCard(title: 'Pending Approvals', value: '${kpis['pending_approvals']}', subtitle: '${kpis['approvals_growth']}%', icon: LucideIcons.checkSquare, gradientColors: [Colors.indigo, Colors.indigo], isNegativeGood: true),
          const SizedBox(height: 16),
          GradientKpiCard(title: 'Docs Stored', value: '${kpis['documents_stored']}k', subtitle: '+${kpis['documents_growth']}%', icon: LucideIcons.fileText, gradientColors: [Colors.green, Colors.green]),
          const SizedBox(height: 16),
          GradientKpiCard(title: 'AI Requests', value: '${kpis['ai_requests']}', subtitle: '+${kpis['ai_requests_growth']}%', icon: LucideIcons.bot, gradientColors: [Colors.lightBlue, Colors.lightBlue]),
          const SizedBox(height: 16),
          GradientKpiCard(title: 'Monthly Revenue', value: '\$${revenueFormatted}k', subtitle: '+${kpis['revenue_growth']}%', icon: LucideIcons.dollarSign, gradientColors: [Colors.pink, Colors.pink]),
        ],
      );
    }
  }

  Widget _buildLineChart(BuildContext context, String title, List<dynamic> data, [Color color = Colors.teal]) {
    final theme = Theme.of(context);
    List<FlSpot> spots = [];
    List<String> labels = [];
    double maxY = 0;
    
    for (int i = 0; i < data.length; i++) {
      double y = (data[i]['value'] as num).toDouble();
      spots.add(FlSpot(i.toDouble(), y));
      labels.add(data[i]['month']);
      if (y > maxY) maxY = y;
    }
    
    maxY = maxY * 1.2;

    return PremiumCard(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 24),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1)),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < labels.length) {
                            return SideTitleWidget(meta: meta, child: Text(labels[value.toInt()], style: const TextStyle(color: Colors.grey, fontSize: 12)));
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(meta: meta, child: Text(value >= 1000 ? '${(value/1000).toInt()}k' : value.toInt().toString(), style: const TextStyle(color: Colors.grey, fontSize: 11)));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(radius: 4, color: Colors.white, strokeWidth: 2, strokeColor: color);
                      }),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(colors: [color.withOpacity(0.3), color.withOpacity(0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
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

  Widget _buildBarChart(BuildContext context, String title, List<dynamic> data, Color color) {
    final theme = Theme.of(context);
    List<BarChartGroupData> barGroups = [];
    List<String> labels = [];
    double maxY = 0;
    
    for (int i = 0; i < data.length; i++) {
      double y = (data[i]['value'] as num).toDouble();
      barGroups.add(BarChartGroupData(
        x: i,
        barRods: [BarChartRodData(toY: y, color: color, width: 24, borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)))],
      ));
      labels.add(data[i]['month']);
      if (y > maxY) maxY = y;
    }
    
    maxY = maxY * 1.2;

    return PremiumCard(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 24),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1)),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < labels.length) {
                            return SideTitleWidget(meta: meta, child: Text(labels[value.toInt()], style: const TextStyle(color: Colors.grey, fontSize: 12)));
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(meta: meta, child: Text(value >= 1000 ? '${(value/1000).toInt()}k' : value.toInt().toString(), style: const TextStyle(color: Colors.grey, fontSize: 11)));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: barGroups,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopTenants(BuildContext context, List<dynamic> tenants) {
    final theme = Theme.of(context);
    return PremiumCard(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Text('Top Tenants', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                TextButton(onPressed: () {}, child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: tenants.length,
                separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final tenant = tenants[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(backgroundColor: Colors.blue.shade100, child: Text(tenant['name'][0], style: const TextStyle(color: Colors.blue))),
                    title: Text(tenant['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${tenant['users']} Users'),
                    trailing: Text(tenant['revenue'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities(BuildContext context, List<dynamic> activities) {
    final theme = Theme.of(context);
    return PremiumCard(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        height: 350,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Activities', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: activities.length,
                separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  IconData icon;
                  Color color;
                  switch (activity['type']) {
                    case 'error': icon = LucideIcons.alertTriangle; color = Colors.red; break;
                    case 'ai': icon = LucideIcons.bot; color = Colors.purple; break;
                    case 'system': icon = LucideIcons.hardDrive; color = Colors.blue; break;
                    case 'security': icon = LucideIcons.shieldAlert; color = Colors.orange; break;
                    default: icon = LucideIcons.building; color = Colors.teal;
                  }
                  
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    title: Text(activity['action'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(activity['entity']),
                    trailing: Text(activity['time'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingTasks(BuildContext context, List<dynamic> tasks) {
    final theme = Theme.of(context);
    return PremiumCard(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        height: 350,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pending Tasks', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: tasks.length,
                separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  Color priorityColor;
                  switch (task['priority']) {
                    case 'High': priorityColor = Colors.red; break;
                    case 'Medium': priorityColor = Colors.orange; break;
                    default: priorityColor = Colors.green;
                  }
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Checkbox(value: false, onChanged: (v) {}),
                    title: Text(task['task'], style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: priorityColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                          child: Text(task['priority'], style: TextStyle(color: priorityColor, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Text(task['due'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
