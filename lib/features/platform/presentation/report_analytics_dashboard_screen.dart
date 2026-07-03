import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'providers/report_analytics_provider.dart';
import '../domain/report_analytics_model.dart';

class ReportAnalyticsDashboardScreen extends ConsumerWidget {
  const ReportAnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(reportAnalyticsProvider);
    final isDesktop = ResponsiveBreakpoints.of(context).largerOrEqualTo(DESKTOP);
    final isTablet = ResponsiveBreakpoints.of(context).largerOrEqualTo(TABLET) && !isDesktop;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Report Analytics', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Analyze reporting usage and performance', style: theme.textTheme.bodyMedium),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(LucideIcons.calendar, size: 18),
                      label: const Text('Last 30 Days'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(LucideIcons.download, size: 18),
                      label: const Text('Export Report'),
                    ),
                  ],
                ),
              ],
            ).animate().fade().slideY(begin: -0.2),
            const SizedBox(height: 24),

            // AI Recommendations
            _buildAiRecommendations(context, state.recommendations).animate().fade(delay: 100.ms).slideY(begin: 0.1),
            const SizedBox(height: 24),

            // KPIs
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = isDesktop ? 5 : (isTablet ? 3 : 2);
                double childAspectRatio = isDesktop ? 1.5 : 1.2;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: childAspectRatio,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildKpiCard(context, 'Total Views', state.kpis.totalViews.toString(), LucideIcons.eye, Colors.blue),
                    _buildKpiCard(context, 'Exports', state.kpis.totalExports.toString(), LucideIcons.downloadCloud, Colors.green),
                    _buildKpiCard(context, 'Shares', state.kpis.totalShares.toString(), LucideIcons.share2, Colors.purple),
                    _buildKpiCard(context, 'Favorites', state.kpis.totalFavorites.toString(), LucideIcons.heart, Colors.red),
                    _buildKpiCard(context, 'Avg. Exec Time', '${state.kpis.avgExecutionTimeMs}ms', LucideIcons.timer, Colors.orange),
                  ],
                );
              }
            ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
            const SizedBox(height: 24),

            // Charts
            Flex(
              direction: isDesktop ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: isDesktop ? 2 : 0,
                  child: SizedBox(
                    height: 400,
                    child: _buildUsageTrendChart(context, state.usageTrends),
                  ),
                ),
                if (isDesktop) const SizedBox(width: 24),
                if (!isDesktop) const SizedBox(height: 24),
                Expanded(
                  flex: isDesktop ? 1 : 0,
                  child: SizedBox(
                    height: 400,
                    child: _buildDepartmentUsageChart(context, state.departmentUsage),
                  ),
                ),
              ],
            ).animate().fade(delay: 300.ms).slideY(begin: 0.1),
            const SizedBox(height: 24),

            // Tables
            Flex(
              direction: isDesktop ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: _buildReportTable(context, 'Popular Reports', state.topReports),
                ),
                if (isDesktop) const SizedBox(width: 24),
                if (!isDesktop) const SizedBox(height: 24),
                Expanded(
                  flex: 1,
                  child: _buildReportTable(context, 'Inactive Reports', state.inactiveReports),
                ),
              ],
            ).animate().fade(delay: 400.ms).slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildAiRecommendations(BuildContext context, List<AiRecommendation> recommendations) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.sparkles, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('AI Recommendations', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 12),
            ...recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Icon(LucideIcons.arrowRightCircle, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(rec.message, style: theme.textTheme.bodyMedium)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(title, style: theme.textTheme.titleSmall?.copyWith(color: theme.textTheme.bodySmall?.color))),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const Spacer(),
            Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageTrendChart(BuildContext context, List<ReportUsageTrend> data) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Usage Trend', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < data.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(data[value.toInt()].date, style: theme.textTheme.bodySmall),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.views.toDouble())).toList(),
                      isCurved: true,
                      color: theme.colorScheme.primary,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
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

  Widget _buildDepartmentUsageChart(BuildContext context, List<DepartmentUsage> data) {
    final theme = Theme.of(context);
    final colors = [
      theme.colorScheme.primary,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.grey,
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Department Usage', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      sections: data.asMap().entries.map((e) {
                        return PieChartSectionData(
                          color: colors[e.key % colors.length],
                          value: e.value.percentage,
                          title: '${e.value.percentage.toInt()}%',
                          radius: 40,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        );
                      }).toList(),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Total', style: theme.textTheme.bodySmall),
                      Text('100%', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: data.asMap().entries.map((e) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: colors[e.key % colors.length], shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(e.value.department, style: theme.textTheme.bodySmall),
                ],
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTable(BuildContext context, String title, List<ReportStats> reports) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
              columns: const [
                DataColumn(label: Text('Report')),
                DataColumn(label: Text('Views')),
                DataColumn(label: Text('Trend')),
                DataColumn(label: Text('Status')),
              ],
              rows: reports.map((r) => DataRow(
                cells: [
                  DataCell(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(r.id, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                    ],
                  )),
                  DataCell(Text(r.views.toString())),
                  DataCell(Text(r.trend, style: TextStyle(color: r.trend.startsWith('+') ? Colors.green : (r.trend.startsWith('-') ? Colors.red : Colors.grey)))),
                  DataCell(Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: r.status == 'Active' ? Colors.teal.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(r.status, style: TextStyle(fontSize: 12, color: r.status == 'Active' ? Colors.teal : Colors.grey)),
                  )),
                ],
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
