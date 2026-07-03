import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../domain/models/approval_analytics_data.dart';
import 'providers/approval_analytics_provider.dart';

class ApprovalAnalyticsScreen extends ConsumerStatefulWidget {
  const ApprovalAnalyticsScreen({super.key});

  @override
  ConsumerState<ApprovalAnalyticsScreen> createState() => _ApprovalAnalyticsScreenState();
}

class _ApprovalAnalyticsScreenState extends ConsumerState<ApprovalAnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(approvalAnalyticsProvider);
    final notifier = ref.read(approvalAnalyticsProvider.notifier);
    final data = state.data;

    if (data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Approval Analytics', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Executive insights into approval performance and bottlenecks.', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
                _buildToolbar(context, theme, state, notifier),
              ],
            ),
            const SizedBox(height: 32),
            
            _buildKPIGrid(context, theme, data.kpis),
            const SizedBox(height: 32),
            
            _buildChartsRow(context, theme, data),
            const SizedBox(height: 32),
            
            _buildSecondaryChartsRow(context, theme, data),
            const SizedBox(height: 32),
            
            _buildWidgetsRow(context, theme, data),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, ThemeData theme, ApprovalAnalyticsState state, ApprovalAnalyticsNotifier notifier) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
            color: theme.colorScheme.surface,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: state.dateRange,
              icon: const Icon(LucideIcons.calendar, size: 16),
              items: ['Last 7 Days', 'Last 30 Days', 'Last 90 Days']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => notifier.setDateRange(val!),
            ),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting Dashboard...')));
          },
          icon: const Icon(LucideIcons.download, size: 16),
          label: const Text('Export'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildKPIGrid(BuildContext context, ThemeData theme, Map<String, String> kpis) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200 ? 6 : (constraints.maxWidth > 800 ? 3 : 2);
        final cardWidth = (constraints.maxWidth - (crossAxisCount - 1) * 16) / crossAxisCount;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: kpis.entries.map((e) {
            IconData icon;
            Color color;
            switch (e.key) {
              case 'Approval Volume': icon = LucideIcons.files; color = Colors.blue; break;
              case 'Average SLA': icon = LucideIcons.clock; color = Colors.purple; break;
              case 'Escalation Rate': icon = LucideIcons.trendingUp; color = Colors.orange; break;
              case 'Approval Duration': icon = LucideIcons.timer; color = Colors.indigo; break;
              case 'Rejection Rate': icon = LucideIcons.xCircle; color = Colors.red; break;
              case 'Delegation Rate': icon = LucideIcons.users; color = Colors.teal; break;
              default: icon = LucideIcons.activity; color = theme.colorScheme.primary;
            }

            return SizedBox(
              width: cardWidth,
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(child: Text(e.key, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          Icon(icon, color: color, size: 20),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(e.value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildChartsRow(BuildContext context, ThemeData theme, ApprovalAnalyticsData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;
        
        final trendChart = _buildChartCard(
          theme: theme,
          title: 'Approval Trend',
          child: _buildTrendLineChart(theme, data.trendData),
        );
        
        final departmentChart = _buildChartCard(
          theme: theme,
          title: 'Department Comparison',
          child: _buildDepartmentBarChart(theme, data.departmentData),
        );

        if (isDesktop) {
          return Row(
            children: [
              Expanded(flex: 2, child: trendChart),
              const SizedBox(width: 16),
              Expanded(flex: 1, child: departmentChart),
            ],
          );
        } else {
          return Column(
            children: [
              trendChart,
              const SizedBox(height: 16),
              departmentChart,
            ],
          );
        }
      }
    );
  }

  Widget _buildSecondaryChartsRow(BuildContext context, ThemeData theme, ApprovalAnalyticsData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;
        
        final slaChart = _buildChartCard(
          theme: theme,
          title: 'SLA Compliance',
          child: _buildSLAPieChart(theme, data.slaCompliance),
        );
        
        final approverChart = _buildChartCard(
          theme: theme,
          title: 'Approver Efficiency (Vol vs Time)',
          child: _buildApproverScatterChart(theme, data.approverPerformance),
        );

        final heatmapChart = _buildChartCard(
          theme: theme,
          title: 'Approval Activity Heatmap',
          child: _buildMockHeatmap(theme, data.activityHeatmap),
        );

        if (isDesktop) {
          return Row(
            children: [
              Expanded(child: slaChart),
              const SizedBox(width: 16),
              Expanded(child: approverChart),
              const SizedBox(width: 16),
              Expanded(child: heatmapChart),
            ],
          );
        } else {
          return Column(
            children: [
              slaChart,
              const SizedBox(height: 16),
              approverChart,
              const SizedBox(height: 16),
              heatmapChart,
            ],
          );
        }
      }
    );
  }

  Widget _buildWidgetsRow(BuildContext context, ThemeData theme, ApprovalAnalyticsData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 1000;
        
        final aiWidget = _buildListWidget(
          theme: theme,
          title: 'AI Recommendations',
          icon: LucideIcons.sparkles,
          iconColor: Colors.purple,
          items: data.aiRecommendations,
        );
        
        final bottlenecksWidget = _buildListWidget(
          theme: theme,
          title: 'Top Bottlenecks',
          icon: LucideIcons.alertTriangle,
          iconColor: Colors.orange,
          items: data.topBottlenecks,
        );

        final performanceWidget = _buildListWidget(
          theme: theme,
          title: 'Fastest Approvers',
          icon: LucideIcons.zap,
          iconColor: Colors.amber,
          items: data.fastestApprovers,
        );

        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: aiWidget),
              const SizedBox(width: 16),
              Expanded(flex: 1, child: bottlenecksWidget),
              const SizedBox(width: 16),
              Expanded(flex: 1, child: performanceWidget),
            ],
          );
        } else {
          return Column(
            children: [
              aiWidget,
              const SizedBox(height: 16),
              bottlenecksWidget,
              const SizedBox(height: 16),
              performanceWidget,
            ],
          );
        }
      }
    );
  }

  Widget _buildChartCard({required ThemeData theme, required String title, required Widget child}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListWidget({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<String> items,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6, right: 12),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(child: Text(item, style: theme.textTheme.bodyMedium)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  // --- Charts Implementation using fl_chart ---

  Widget _buildTrendLineChart(ThemeData theme, List<ChartDataPoint> data) {
    if (data.isEmpty) return const SizedBox();
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) => FlLine(color: theme.dividerColor, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
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

  Widget _buildDepartmentBarChart(ThemeData theme, List<CategoryDataPoint> data) {
    if (data.isEmpty) return const SizedBox();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: data.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(data[value.toInt()].category.substring(0, min(3, data[value.toInt()].category.length)), style: theme.textTheme.bodySmall),
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
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.value,
                color: theme.colorScheme.secondary,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              )
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSLAPieChart(ThemeData theme, List<CategoryDataPoint> data) {
    if (data.isEmpty) return const SizedBox();

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: data.map((e) {
          return PieChartSectionData(
            color: e.colorHex == '#4CAF50' ? Colors.green : (e.colorHex == '#F44336' ? Colors.red : theme.colorScheme.primary),
            value: e.value,
            title: '${e.value.toInt()}%',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildApproverScatterChart(ThemeData theme, List<PerformanceDataPoint> data) {
    if (data.isEmpty) return const SizedBox();

    return ScatterChart(
      ScatterChartData(
        scatterSpots: data.map((e) {
          return ScatterSpot(
            e.volume, // X axis: Volume
            e.averageTimeHours, // Y axis: Time
            dotPainter: FlDotCirclePainter(
              radius: 6,
              color: e.averageTimeHours > 5 ? Colors.orange : Colors.teal,
            ),
          );
        }).toList(),
        minX: 0,
        maxX: data.map((e) => e.volume).reduce((a, b) => a > b ? a : b) * 1.2,
        minY: 0,
        maxY: data.map((e) => e.averageTimeHours).reduce((a, b) => a > b ? a : b) * 1.2,
        titlesData: const FlTitlesData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) => FlLine(color: theme.dividerColor, strokeWidth: 1),
          getDrawingVerticalLine: (value) => FlLine(color: theme.dividerColor, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildMockHeatmap(ThemeData theme, List<HeatmapDataPoint> data) {
    // Simple visual mock of a heatmap using a grid
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Mon', style: TextStyle(fontSize: 10)),
            Text('Wed', style: TextStyle(fontSize: 10)),
            Text('Fri', style: TextStyle(fontSize: 10)),
            Text('Sun', style: TextStyle(fontSize: 10)),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, // Days of week
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 28, // 4 weeks mock
            itemBuilder: (context, index) {
              // Mock intensity color
              final intensity = index % 5;
              Color color;
              if (intensity == 0) color = theme.colorScheme.surfaceVariant;
              else if (intensity == 1) color = Colors.indigo.shade100;
              else if (intensity == 2) color = Colors.indigo.shade300;
              else if (intensity == 3) color = Colors.indigo.shade500;
              else color = Colors.indigo.shade700;

              return Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
