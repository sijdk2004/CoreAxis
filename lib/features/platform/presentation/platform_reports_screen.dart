import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../domain/platform_reports_model.dart';
import 'providers/platform_reports_provider.dart';

class PlatformReportsScreen extends ConsumerWidget {
  const PlatformReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(platformReportsProvider);
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final isTablet = ResponsiveBreakpoints.of(context).largerThan(MOBILE) && !isDesktop;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (data) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, theme, data, ref),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildKpiGrid(context, theme, data.kpis, isDesktop, isTablet),
                      const SizedBox(height: 32),
                      _buildMainCharts(context, theme, data, isDesktop),
                      const SizedBox(height: 32),
                      _buildWidgetsRow(context, theme, data, isDesktop),
                    ],
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, PlatformReportsModel data, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.barChart2, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Executive Reporting Dashboard', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Overview of reporting usage, schedules, and active dashboards across the platform', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          _buildFilterDropdown(
            theme,
            value: data.filterTimeRange,
            items: const ['Today', 'This Week', 'This Month'],
            onChanged: (val) => ref.read(platformReportsProvider.notifier).updateFilters(timeRange: val),
          ),
          const SizedBox(width: 16),
          _buildFilterDropdown(
            theme,
            value: data.filterDepartment,
            items: const ['All Departments', 'Finance', 'Sales', 'IT', 'HR'],
            onChanged: (val) => ref.read(platformReportsProvider.notifier).updateFilters(department: val),
          ),
          const SizedBox(width: 16),
          _buildFilterDropdown(
            theme,
            value: data.filterOrganization,
            items: const ['All Organizations', 'Acme Corp', 'Globex', 'Initech'],
            onChanged: (val) => ref.read(platformReportsProvider.notifier).updateFilters(organization: val),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(ThemeData theme, {required String value, required List<String> items, required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(LucideIcons.chevronDown, size: 16),
          style: theme.textTheme.bodyMedium,
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildKpiGrid(BuildContext context, ThemeData theme, ReportKpiMetrics kpis, bool isDesktop, bool isTablet) {
    int crossAxisCount = isDesktop ? 4 : (isTablet ? 2 : 1);
    
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isDesktop ? 2.5 : 2.0,
      children: [
        _buildKpiCard(theme, 'Total Reports', NumberFormat.compact().format(kpis.totalReports), LucideIcons.fileText, Colors.blue),
        _buildKpiCard(theme, 'Dashboards', NumberFormat.compact().format(kpis.dashboards), LucideIcons.layoutDashboard, Colors.indigo),
        _buildKpiCard(theme, 'Scheduled Reports', NumberFormat.compact().format(kpis.scheduledReports), LucideIcons.calendarClock, Colors.purple),
        _buildKpiCard(theme, 'Executions Today', NumberFormat.compact().format(kpis.executionsToday), LucideIcons.play, Colors.green),
        _buildKpiCard(theme, 'Shared Reports', NumberFormat.compact().format(kpis.sharedReports), LucideIcons.share2, Colors.orange),
        _buildKpiCard(theme, 'Export Count', NumberFormat.compact().format(kpis.exportCount), LucideIcons.download, Colors.teal),
        _buildKpiCard(theme, 'Data Sources', NumberFormat.compact().format(kpis.dataSources), LucideIcons.database, Colors.red),
        _buildKpiCard(theme, 'Active Users', NumberFormat.compact().format(kpis.activeUsers), LucideIcons.users, Colors.pink),
      ],
    );
  }

  Widget _buildKpiCard(ThemeData theme, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCharts(BuildContext context, ThemeData theme, PlatformReportsModel data, bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _buildChartCard(theme, 'Report Usage Trend', _buildLineChart(theme, data.usageTrend)),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 2,
            child: _buildChartCard(theme, 'Most Viewed Reports', _buildBarChart(theme, data.mostViewedReports, Colors.blue)),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _buildChartCard(theme, 'Report Usage Trend', _buildLineChart(theme, data.usageTrend)),
          const SizedBox(height: 24),
          _buildChartCard(theme, 'Most Viewed Reports', _buildBarChart(theme, data.mostViewedReports, Colors.blue)),
        ],
      );
    }
  }

  Widget _buildWidgetsRow(BuildContext context, ThemeData theme, PlatformReportsModel data, bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildChartCard(theme, 'Department Usage', _buildPieChart(theme, data.departmentUsage)),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: _buildListWidget(
              theme,
              title: 'Scheduled Jobs',
              icon: LucideIcons.calendarClock,
              itemCount: data.scheduledJobs.length,
              itemBuilder: (context, index) {
                final job = data.scheduledJobs[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(LucideIcons.clock, color: theme.colorScheme.primary),
                  title: Text(job.reportName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(job.schedule),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: job.status == 'Active' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(job.status, style: TextStyle(color: job.status == 'Active' ? Colors.green : Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: _buildListWidget(
              theme,
              title: 'Favorite & Recent Reports',
              icon: LucideIcons.star,
              itemCount: data.favoriteReports.length + data.recentReports.length,
              itemBuilder: (context, index) {
                final isFav = index < data.favoriteReports.length;
                final report = isFav ? data.favoriteReports[index] : data.recentReports[index - data.favoriteReports.length];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(report.icon, color: report.color),
                  title: Text(report.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(report.category),
                  trailing: Icon(isFav ? LucideIcons.star : LucideIcons.history, size: 16, color: isFav ? Colors.amber : theme.colorScheme.onSurfaceVariant),
                );
              },
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _buildChartCard(theme, 'Department Usage', _buildPieChart(theme, data.departmentUsage)),
          const SizedBox(height: 24),
          _buildListWidget(
            theme,
            title: 'Scheduled Jobs',
            icon: LucideIcons.calendarClock,
            itemCount: data.scheduledJobs.length,
            itemBuilder: (context, index) {
              // Same as above
              return const SizedBox();
            },
          ),
        ],
      );
    }
  }

  Widget _buildChartCard(ThemeData theme, String title, Widget chart) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: chart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(ThemeData theme, List<ChartDataPoint> data) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(color: theme.dividerColor, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(data[value.toInt()].label, style: theme.textTheme.bodySmall),
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
            color: theme.colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(ThemeData theme, List<ChartDataPoint> data, Color color) {
    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(color: theme.dividerColor, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      data[value.toInt()].label, 
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.value,
                color: color,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPieChart(ThemeData theme, List<ChartDataPoint> data) {
    final colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple];

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: data.asMap().entries.map((e) {
                return PieChartSectionData(
                  color: colors[e.key % colors.length],
                  value: e.value.value,
                  title: '${e.value.value.toInt()}%',
                  radius: 50,
                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.asMap().entries.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[e.key % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e.value.label,
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildListWidget(ThemeData theme, {required String title, required IconData icon, required int itemCount, required IndexedWidgetBuilder itemBuilder}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: itemBuilder,
            ),
          ],
        ),
      ),
    );
  }
}
