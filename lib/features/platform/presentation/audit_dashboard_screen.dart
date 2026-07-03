import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../domain/models/audit_dashboard_model.dart';
import 'providers/audit_dashboard_provider.dart';
import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';

class AuditDashboardScreen extends ConsumerStatefulWidget {
  const AuditDashboardScreen({super.key});

  @override
  ConsumerState<AuditDashboardScreen> createState() => _AuditDashboardScreenState();
}

class _AuditDashboardScreenState extends ConsumerState<AuditDashboardScreen> {
  String _selectedFilter = 'This Week';
  final List<String> _filters = ['Today', 'This Week', 'This Month', 'Module', 'Organization', 'Tenant'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final asyncState = ref.watch(auditDashboardProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Audit Engine Dashboard'),
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: FilledButton.icon(
              onPressed: () {
                ref.read(auditDashboardProvider.notifier).refresh();
              },
              icon: const Icon(LucideIcons.refreshCw, size: 18),
              label: const Text('Refresh'),
            ),
          ),
        ],
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildFilters(context),
                const SizedBox(height: 32),
                _buildKpiGrid(context, state, isDesktop),
                const SizedBox(height: 32),
                _buildChartsRow1(context, state, isDesktop),
                const SizedBox(height: 32),
                _buildChartsRow2(context, state, isDesktop),
                const SizedBox(height: 32),
                _buildInsightsRow1(context, state, isDesktop),
                const SizedBox(height: 32),
                _buildInsightsRow2(context, state, isDesktop),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms);
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(LucideIcons.shieldCheck, size: 28, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Audit & Compliance Dashboard', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const Text('Executive overview of platform-wide audit activities.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _filters.map((f) => ChoiceChip(
        label: Text(f),
        selected: _selectedFilter == f,
        onSelected: (selected) {
          if (selected) setState(() => _selectedFilter = f);
        },
      )).toList(),
    );
  }

  Widget _buildKpiGrid(BuildContext context, AuditDashboardModel state, bool isDesktop) {
    final cards = [
      GradientKpiCard(title: 'Total Audit Events', value: state.kpis['Total Audit Events']!, subtitle: 'Platform-wide', icon: LucideIcons.activity, gradientColors: [Colors.blue.shade700, Colors.blue.shade400]),
      GradientKpiCard(title: 'Today\'s Events', value: state.kpis['Today\'s Events']!, subtitle: 'Active logging', icon: LucideIcons.calendar, gradientColors: [Colors.indigo.shade700, Colors.indigo.shade400]),
      GradientKpiCard(title: 'Security Events', value: state.kpis['Security Events']!, subtitle: 'Requires attention', icon: LucideIcons.shieldAlert, gradientColors: [Colors.red.shade700, Colors.red.shade400]),
      GradientKpiCard(title: 'Failed Logins', value: state.kpis['Failed Login Attempts']!, subtitle: 'Potential threats', icon: LucideIcons.userX, gradientColors: [Colors.orange.shade700, Colors.orange.shade400]),
      GradientKpiCard(title: 'Data Changes', value: state.kpis['Data Changes']!, subtitle: 'Records updated', icon: LucideIcons.database, gradientColors: [Colors.teal.shade700, Colors.teal.shade400]),
      GradientKpiCard(title: 'Workflow Activities', value: state.kpis['Workflow Activities']!, subtitle: 'Executions', icon: LucideIcons.workflow, gradientColors: [Colors.purple.shade700, Colors.purple.shade400]),
      GradientKpiCard(title: 'Approval Activities', value: state.kpis['Approval Activities']!, subtitle: 'Decisions made', icon: LucideIcons.checkSquare, gradientColors: [Colors.green.shade700, Colors.green.shade400]),
      GradientKpiCard(title: 'Document Activities', value: state.kpis['Document Activities']!, subtitle: 'Files accessed', icon: LucideIcons.fileText, gradientColors: [Colors.cyan.shade700, Colors.cyan.shade400]),
    ];

    return GridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 140,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cards,
    );
  }

  Widget _buildChartsRow1(BuildContext context, AuditDashboardModel state, bool isDesktop) {
    final content = [
      Expanded(
        child: _buildChartCard(
          context,
          'Audit Events Trend',
          'Last 7 Days',
          _buildLineChart(state.auditEventsTrend, Theme.of(context).colorScheme.primary),
        ),
      ),
      if (isDesktop) const SizedBox(width: 24) else const SizedBox(height: 24),
      Expanded(
        child: _buildChartCard(
          context,
          'User Activity Trend',
          'Active hours today',
          _buildLineChart(state.userActivityTrend, Colors.teal),
        ),
      ),
    ];

    return isDesktop ? Row(children: content) : Column(children: content);
  }

  Widget _buildChartsRow2(BuildContext context, AuditDashboardModel state, bool isDesktop) {
    final content = [
      Expanded(
        child: _buildChartCard(
          context,
          'Events by Module',
          'Distribution across platform',
          _buildBarChart(state.eventsByModule, Colors.indigo),
        ),
      ),
      if (isDesktop) const SizedBox(width: 24) else const SizedBox(height: 24),
      Expanded(
        child: _buildChartCard(
          context,
          'Security Events',
          'Categorized by type',
          _buildPieChart(state.securityEvents),
        ),
      ),
    ];

    return isDesktop ? Row(children: content) : Column(children: content);
  }

  Widget _buildInsightsRow1(BuildContext context, AuditDashboardModel state, bool isDesktop) {
    final content = [
      Expanded(child: _buildLogList(context, 'Recent Audit Events', state.recentAuditEvents, LucideIcons.clock)),
      if (isDesktop) const SizedBox(width: 24) else const SizedBox(height: 24),
      Expanded(child: _buildLogList(context, 'Critical Events', state.criticalEvents, LucideIcons.alertTriangle, isCritical: true)),
    ];
    
    return isDesktop ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: content) : Column(children: content);
  }
  
  Widget _buildInsightsRow2(BuildContext context, AuditDashboardModel state, bool isDesktop) {
    final content = [
      Expanded(child: _buildActiveUsersList(context, state.mostActiveUsers)),
      if (isDesktop) const SizedBox(width: 24) else const SizedBox(height: 24),
      Expanded(child: _buildRecentLoginsList(context, state.recentLogins)),
      if (isDesktop) const SizedBox(width: 24) else const SizedBox(height: 24),
      Expanded(child: _buildModuleActivityList(context, state.moduleActivity)),
    ];
    
    return isDesktop ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: content) : Column(children: content);
  }

  Widget _buildChartCard(BuildContext context, String title, String subtitle, Widget chart) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 24),
          SizedBox(height: 200, child: chart),
        ],
      ),
    );
  }

  Widget _buildLogList(BuildContext context, String title, List<AuditLogItem> items, IconData icon, {bool isCritical = false}) {
    final theme = Theme.of(context);
    final borderColor = isCritical ? Colors.red.withOpacity(0.3) : theme.colorScheme.outlineVariant;
    final headerColor = isCritical ? Colors.red : theme.colorScheme.primary;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: headerColor),
                const SizedBox(width: 12),
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: isCritical ? Colors.red.shade700 : null)),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: item.severity == 'critical' ? Colors.red.withOpacity(0.1) : 
                             (item.severity == 'warning' ? Colors.orange.withOpacity(0.1) : theme.colorScheme.surfaceContainerHighest),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      item.severity == 'critical' ? LucideIcons.alertCircle : 
                      (item.severity == 'warning' ? LucideIcons.alertTriangle : LucideIcons.info),
                      size: 16, 
                      color: item.severity == 'critical' ? Colors.red : 
                             (item.severity == 'warning' ? Colors.orange : theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.action, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(item.user, style: TextStyle(color: theme.colorScheme.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                            Text(' • ${item.module} • ${item.timestamp}', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveUsersList(BuildContext context, List<ActiveUserItem> items) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.users, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text('Most Active Users', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(item.username.substring(0, 1).toUpperCase(), style: TextStyle(fontSize: 12, color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.username, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        Text(item.role, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 11)),
                      ],
                    ),
                  ),
                  Text(item.eventCount, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentLoginsList(BuildContext context, List<LoginItem> items) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.logIn, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text('Recent Logins', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: item.status == 'Success' ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.username, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        Text('${item.ipAddress} • ${item.timestamp}', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleActivityList(BuildContext context, List<ModuleActivityItem> items) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.layers, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text('Module Activity', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map((item) {
              final isPositive = item.trend.startsWith('+');
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.module, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(item.eventCount, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 11)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(item.trend, style: TextStyle(color: isPositive ? Colors.green : Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Charts implementation
  Widget _buildLineChart(List<ChartDataPoint> data, Color color) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                if (val.toInt() >= 0 && val.toInt() < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(data[val.toInt()].label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<ChartDataPoint> data, Color color) {
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                if (val.toInt() >= 0 && val.toInt() < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(data[val.toInt()].label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((e) => BarChartGroupData(
          x: e.key,
          barRods: [
            BarChartRodData(
              toY: e.value.value,
              color: color,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            )
          ],
        )).toList(),
      ),
    );
  }

  Widget _buildPieChart(List<PieChartDataPoint> data) {
    final colors = [Colors.red, Colors.orange, Colors.blue, Colors.grey];
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: data.asMap().entries.map((e) {
          final isLarge = e.value.percentage > 10;
          return PieChartSectionData(
            color: colors[e.key % colors.length],
            value: e.value.percentage,
            title: isLarge ? '${e.value.percentage.toInt()}%' : '',
            radius: isLarge ? 50 : 40,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            badgeWidget: isLarge ? null : _Badge(e.value.category, colors[e.key % colors.length]),
            badgePositionPercentageOffset: 1.5,
          );
        }).toList(),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold)),
    );
  }
}
