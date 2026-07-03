import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../domain/audit_analytics_model.dart';
import 'providers/audit_analytics_provider.dart';

class AuditAnalyticsScreen extends ConsumerWidget {
  const AuditAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(auditAnalyticsProvider);
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
              _buildHeader(context, theme),
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
                      _buildSecondaryCharts(context, theme, data, isDesktop),
                      const SizedBox(height: 32),
                      _buildBottomWidgets(context, theme, data, isDesktop),
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

  Widget _buildHeader(BuildContext context, ThemeData theme) {
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
                Text('Audit Analytics', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Executive insights and trends for audit and compliance data', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting Dashboard...')));
            },
            icon: const Icon(LucideIcons.download),
            label: const Text('Export Dashboard'),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(BuildContext context, ThemeData theme, AuditKpiMetrics kpis, bool isDesktop, bool isTablet) {
    int crossAxisCount = isDesktop ? 6 : (isTablet ? 3 : 2);
    
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isDesktop ? 1.5 : 1.2,
      children: [
        _buildKpiCard(theme, 'Audit Volume', NumberFormat.compact().format(kpis.auditVolume), LucideIcons.database, Colors.blue),
        _buildKpiCard(theme, 'Critical Events', NumberFormat.compact().format(kpis.criticalEvents), LucideIcons.alertOctagon, Colors.red),
        _buildKpiCard(theme, 'Security Incidents', NumberFormat.compact().format(kpis.securityIncidents), LucideIcons.shieldAlert, Colors.orange),
        _buildKpiCard(theme, 'Data Changes', NumberFormat.compact().format(kpis.dataChanges), LucideIcons.fileDiff, Colors.purple),
        _buildKpiCard(theme, 'Login Success', '${kpis.loginSuccessRate}%', LucideIcons.logIn, Colors.green),
        _buildKpiCard(theme, 'Workflow Activities', NumberFormat.compact().format(kpis.workflowActivities), LucideIcons.gitMerge, Colors.teal),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCharts(BuildContext context, ThemeData theme, AuditAnalyticsModel data, bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _buildChartCard(theme, 'Events Trend (7 Days)', _buildLineChart(theme, data.eventsTrend)),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: _buildChartCard(theme, 'Module Comparison', _buildPieChart(theme, data.moduleComparison)),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _buildChartCard(theme, 'Events Trend (7 Days)', _buildLineChart(theme, data.eventsTrend)),
          const SizedBox(height: 24),
          _buildChartCard(theme, 'Module Comparison', _buildPieChart(theme, data.moduleComparison)),
        ],
      );
    }
  }

  Widget _buildSecondaryCharts(BuildContext context, ThemeData theme, AuditAnalyticsModel data, bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildChartCard(theme, 'Peak Activity Heatmap', _buildHeatmap(theme, data.peakActivityHeatmap, Colors.blue)),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: _buildChartCard(theme, 'Security Events Heatmap', _buildHeatmap(theme, data.securityEventsHeatmap, Colors.red)),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _buildChartCard(theme, 'Peak Activity Heatmap', _buildHeatmap(theme, data.peakActivityHeatmap, Colors.blue)),
          const SizedBox(height: 24),
          _buildChartCard(theme, 'Security Events Heatmap', _buildHeatmap(theme, data.securityEventsHeatmap, Colors.red)),
        ],
      );
    }
  }

  Widget _buildBottomWidgets(BuildContext context, ThemeData theme, AuditAnalyticsModel data, bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildTopUsers(theme, data.topUsers),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: _buildMostChangedRecords(theme, data.mostChangedRecords),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: _buildCriticalAlertsAndAi(theme, data),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _buildTopUsers(theme, data.topUsers),
          const SizedBox(height: 24),
          _buildMostChangedRecords(theme, data.mostChangedRecords),
          const SizedBox(height: 24),
          _buildCriticalAlertsAndAi(theme, data),
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
              height: 300,
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

  Widget _buildPieChart(ThemeData theme, List<ChartDataPoint> data) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

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

  Widget _buildHeatmap(ThemeData theme, Map<int, Map<int, double>> data, Color baseColor) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    // Find max value for opacity normalization
    double maxVal = 0;
    for (var dayMap in data.values) {
      for (var val in dayMap.values) {
        if (val > maxVal) maxVal = val;
      }
    }
    if (maxVal == 0) maxVal = 1;

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              // Y-axis labels (Days)
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: days.map((d) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(d, style: theme.textTheme.bodySmall),
                )).toList(),
              ),
              // Heatmap grid
              Expanded(
                child: Column(
                  children: List.generate(7, (dayIndex) {
                    return Expanded(
                      child: Row(
                        children: List.generate(24, (hourIndex) {
                          final val = data[dayIndex]?[hourIndex] ?? 0;
                          final opacity = (val / maxVal).clamp(0.0, 1.0);
                          return Expanded(
                            child: Tooltip(
                              message: '$days[dayIndex] $hourIndex:00 - ${val.toStringAsFixed(1)}',
                              child: Container(
                                margin: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: opacity > 0 ? baseColor.withOpacity(opacity) : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        // X-axis labels (Hours)
        Padding(
          padding: const EdgeInsets.only(left: 32.0, top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('00', style: TextStyle(fontSize: 10)),
              Text('06', style: TextStyle(fontSize: 10)),
              Text('12', style: TextStyle(fontSize: 10)),
              Text('18', style: TextStyle(fontSize: 10)),
              Text('23', style: TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopUsers(ThemeData theme, List<TopUser> users) {
    return _buildListWidget(
      theme,
      title: 'Top Users',
      icon: LucideIcons.users,
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user.avatarUrl),
          ),
          title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(user.role),
          trailing: Text(NumberFormat.compact().format(user.eventCount), style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
        );
      },
    );
  }

  Widget _buildMostChangedRecords(ThemeData theme, List<ChangedRecord> records) {
    return _buildListWidget(
      theme,
      title: 'Most Changed Records',
      icon: LucideIcons.fileDiff,
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(LucideIcons.database, color: theme.colorScheme.primary),
          ),
          title: Text(record.entityName, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(record.entityType),
          trailing: Text(record.changeCount.toString(), style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
        );
      },
    );
  }

  Widget _buildCriticalAlertsAndAi(ThemeData theme, AuditAnalyticsModel data) {
    return Column(
      children: [
        _buildListWidget(
          theme,
          title: 'Critical Alerts',
          icon: LucideIcons.alertOctagon,
          titleColor: Colors.red,
          itemCount: data.criticalAlerts.length,
          itemBuilder: (context, index) {
            final alert = data.criticalAlerts[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(LucideIcons.alertTriangle, size: 16, color: alert.severity == 'critical' ? Colors.red : Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(alert.message, style: const TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text(DateFormat('MMM d, HH:mm').format(alert.time), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildListWidget(
          theme,
          title: 'AI Recommendations',
          icon: LucideIcons.sparkles,
          titleColor: Colors.purple,
          itemCount: data.aiRecommendations.length,
          itemBuilder: (context, index) {
            final ai = data.aiRecommendations[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ai.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(ai.description, style: theme.textTheme.bodySmall),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildListWidget(ThemeData theme, {required String title, required IconData icon, Color? titleColor, required int itemCount, required IndexedWidgetBuilder itemBuilder}) {
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
                Icon(icon, color: titleColor ?? theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: titleColor)),
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
