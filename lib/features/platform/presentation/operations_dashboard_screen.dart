import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import '../data/operations_dashboard_provider.dart';

class OperationsDashboardScreen extends ConsumerStatefulWidget {
  const OperationsDashboardScreen({super.key});

  @override
  ConsumerState<OperationsDashboardScreen> createState() => _OperationsDashboardScreenState();
}

class _OperationsDashboardScreenState extends ConsumerState<OperationsDashboardScreen> {
  final List<String> _timeframes = ['Today', 'This Week', 'This Month', 'Custom Range'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final dashboardState = ref.watch(operationsDashboardNotifierProvider);

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
                _buildKpiSection(kpis, isDesktop),
                const SizedBox(height: 32),
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildLineChart(context, 'Workflow Performance', charts['workflow_performance']).animate().fade(delay: 500.ms)),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: _buildBarChart(context, 'Approval Trends', charts['approval_trends'], Colors.blue).animate().fade(delay: 600.ms)),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildLineChart(context, 'Workflow Performance', charts['workflow_performance']).animate().fade(delay: 500.ms),
                      const SizedBox(height: 24),
                      _buildBarChart(context, 'Approval Trends', charts['approval_trends'], Colors.blue).animate().fade(delay: 600.ms),
                    ],
                  ),
                const SizedBox(height: 32),
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildLineChart(context, 'Notification Delivery Trends', charts['notification_delivery'], Colors.purple).animate().fade(delay: 700.ms)),
                      const SizedBox(width: 24),
                      Expanded(flex: 1, child: _buildRecentActivities(context, widgets['recent_activities']).animate().fade(delay: 800.ms)),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildLineChart(context, 'Notification Delivery Trends', charts['notification_delivery'], Colors.purple).animate().fade(delay: 700.ms),
                      const SizedBox(height: 24),
                      _buildRecentActivities(context, widgets['recent_activities']).animate().fade(delay: 800.ms),
                    ],
                  ),
                const SizedBox(height: 32),
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 1, child: _buildFailedNotifications(context, widgets['failed_notifications_list']).animate().fade(delay: 900.ms)),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildFailedNotifications(context, widgets['failed_notifications_list']).animate().fade(delay: 900.ms),
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
            Text('Operations Dashboard', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            const SizedBox(height: 4),
            Text('Real-time operational activities & performance', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600)),
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
              icon: const Icon(LucideIcons.refreshCw, size: 18),
              label: const Text('Refresh'),
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
          final isSelected = ref.watch(operationsDashboardNotifierProvider).value?.timeframe == tf;
          return GestureDetector(
            onTap: () => ref.read(operationsDashboardNotifierProvider.notifier).setTimeframe(tf),
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

  Widget _buildKpiSection(Map<String, dynamic> kpis, bool isDesktop) {
    if (isDesktop) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: GradientKpiCard(title: 'Workflow Queue', value: '${kpis['workflow_queue']}', subtitle: '+${kpis['workflow_growth']}%', icon: LucideIcons.gitBranch, gradientColors: [Colors.teal, Colors.teal]).animate().fade(delay: 100.ms).slideY(begin: 0.1)),
              const SizedBox(width: 16),
              Expanded(child: GradientKpiCard(title: 'Pending Approvals', value: '${kpis['pending_approvals']}', subtitle: '${kpis['approvals_growth']}%', icon: LucideIcons.checkSquare, gradientColors: [Colors.orange, Colors.orange], isNegativeGood: true).animate().fade(delay: 200.ms).slideY(begin: 0.1)),
              const SizedBox(width: 16),
              Expanded(child: GradientKpiCard(title: 'Notification Status', value: '${kpis['notification_status']}%', subtitle: 'Success Rate', icon: LucideIcons.bellRing, gradientColors: [Colors.blue, Colors.blue]).animate().fade(delay: 300.ms).slideY(begin: 0.1)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: GradientKpiCard(title: 'Failed Notifications', value: '${kpis['failed_notifications']}', subtitle: '${kpis['failed_growth']}%', icon: LucideIcons.bellOff, gradientColors: [Colors.red, Colors.redAccent], isNegativeGood: true).animate().fade(delay: 400.ms).slideY(begin: 0.1)),
              const SizedBox(width: 16),
              Expanded(child: GradientKpiCard(title: 'Docs Processing', value: '${kpis['docs_processing']}', subtitle: '+${kpis['docs_growth']}%', icon: LucideIcons.fileText, gradientColors: [Colors.indigo, Colors.indigo]).animate().fade(delay: 500.ms).slideY(begin: 0.1)),
              const SizedBox(width: 16),
              Expanded(child: GradientKpiCard(title: 'Active Sessions', value: '${kpis['active_sessions']}', subtitle: '+${kpis['sessions_growth']}%', icon: LucideIcons.users, gradientColors: [Colors.purple, Colors.purple]).animate().fade(delay: 600.ms).slideY(begin: 0.1)),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: [
          GradientKpiCard(title: 'Workflow Queue', value: '${kpis['workflow_queue']}', subtitle: '+${kpis['workflow_growth']}%', icon: LucideIcons.gitBranch, gradientColors: [Colors.teal, Colors.teal]),
          const SizedBox(height: 16),
          GradientKpiCard(title: 'Pending Approvals', value: '${kpis['pending_approvals']}', subtitle: '${kpis['approvals_growth']}%', icon: LucideIcons.checkSquare, gradientColors: [Colors.orange, Colors.orange], isNegativeGood: true),
          const SizedBox(height: 16),
          GradientKpiCard(title: 'Notification Status', value: '${kpis['notification_status']}%', subtitle: 'Success Rate', icon: LucideIcons.bellRing, gradientColors: [Colors.blue, Colors.blue]),
          const SizedBox(height: 16),
          GradientKpiCard(title: 'Failed Notifications', value: '${kpis['failed_notifications']}', subtitle: '${kpis['failed_growth']}%', icon: LucideIcons.bellOff, gradientColors: [Colors.red, Colors.redAccent], isNegativeGood: true),
          const SizedBox(height: 16),
          GradientKpiCard(title: 'Docs Processing', value: '${kpis['docs_processing']}', subtitle: '+${kpis['docs_growth']}%', icon: LucideIcons.fileText, gradientColors: [Colors.indigo, Colors.indigo]),
          const SizedBox(height: 16),
          GradientKpiCard(title: 'Active Sessions', value: '${kpis['active_sessions']}', subtitle: '+${kpis['sessions_growth']}%', icon: LucideIcons.users, gradientColors: [Colors.purple, Colors.purple]),
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
      labels.add(data[i]['label']);
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
      labels.add(data[i]['label']);
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

  Widget _buildRecentActivities(BuildContext context, List<dynamic> activities) {
    final theme = Theme.of(context);
    return PremiumCard(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent User Activities', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
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
                    case 'approval': icon = LucideIcons.checkCircle; color = Colors.green; break;
                    case 'system': icon = LucideIcons.hardDrive; color = Colors.blue; break;
                    case 'workflow': icon = LucideIcons.gitBranch; color = Colors.orange; break;
                    case 'document': icon = LucideIcons.fileText; color = Colors.indigo; break;
                    default: icon = LucideIcons.user; color = Colors.grey;
                  }
                  
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    title: Text(activity['action'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text(activity['user'], style: const TextStyle(fontSize: 12)),
                    trailing: Text(activity['time'], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFailedNotifications(BuildContext context, List<dynamic> list) {
    final theme = Theme.of(context);
    return PremiumCard(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Text('Failed Notifications (Requires Action)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: Colors.red)),
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
          ),
          const SizedBox(height: 16),
          if (list.isEmpty)
             const Padding(padding: EdgeInsets.all(16), child: Text("No failed notifications."))
          else
            ...list.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                tileColor: Colors.red.withOpacity(0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(LucideIcons.alertCircle, color: Colors.red),
                title: Text(item['recipient'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('Reason: ${item['reason']}'),
                trailing: Text(item['time'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ),
            )),
        ],
      ),
    );
  }
}
