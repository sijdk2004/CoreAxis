import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../domain/models/notification_analytics_model.dart';
import 'providers/notification_analytics_provider.dart';

class NotificationAnalyticsScreen extends ConsumerWidget {
  const NotificationAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(notificationAnalyticsProvider);
    final notifier = ref.read(notificationAnalyticsProvider.notifier);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, theme, state, notifier),
                  const SizedBox(height: 32),
                  _buildKpiRow(context, theme, state),
                  const SizedBox(height: 32),
                  _buildMainChartsRow(context, theme, state),
                  const SizedBox(height: 32),
                  _buildInsightsRow(context, theme, state),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, NotificationAnalyticsState state, NotificationAnalyticsNotifier notifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Notification Analytics', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: state.dateRange,
                  icon: const Icon(LucideIcons.calendar, size: 16),
                  onChanged: (val) {
                    if (val != null) notifier.setDateRange(val);
                  },
                  items: ['Today', 'Last 7 Days', 'Last 30 Days', 'Year to Date']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting Dashboard...')));
              },
              icon: const Icon(LucideIcons.download, size: 16),
              label: const Text('Export'),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildKpiRow(BuildContext context, ThemeData theme, NotificationAnalyticsState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200 ? 6 : (constraints.maxWidth > 800 ? 3 : 2);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.0,
          children: [
            _buildStatCard('Success Rate', '${(state.kpis.deliverySuccessRate * 100).toStringAsFixed(1)}%', LucideIcons.checkCircle, Colors.green, theme),
            _buildStatCard('Avg Time', '${state.kpis.averageDeliveryTime.inMilliseconds}ms', LucideIcons.clock, Colors.blue, theme),
            _buildStatCard('Open Rate', '${(state.kpis.openRate * 100).toStringAsFixed(1)}%', LucideIcons.mailOpen, Colors.purple, theme),
            _buildStatCard('Click Rate', '${(state.kpis.clickRate * 100).toStringAsFixed(1)}%', LucideIcons.mousePointerClick, Colors.orange, theme),
            _buildStatCard('Failure Rate', '${(state.kpis.failureRate * 100).toStringAsFixed(1)}%', LucideIcons.xCircle, Colors.red, theme),
            _buildStatCard('Retry Rate', '${(state.kpis.retryRate * 100).toStringAsFixed(1)}%', LucideIcons.refreshCw, Colors.grey, theme),
          ],
        );
      }
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.colorScheme.outlineVariant)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildMainChartsRow(BuildContext context, ThemeData theme, NotificationAnalyticsState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 1000;
        final trendChart = _buildTrendChart(theme, state);
        final pieChart = _buildChannelPieChart(theme, state);

        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: trendChart),
              const SizedBox(width: 24),
              Expanded(flex: 1, child: pieChart),
            ],
          );
        } else {
          return Column(
            children: [
              trendChart,
              const SizedBox(height: 24),
              pieChart,
            ],
          );
        }
      }
    );
  }

  Widget _buildTrendChart(ThemeData theme, NotificationAnalyticsState state) {
    final format = DateFormat('MMM dd');
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.colorScheme.outlineVariant)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delivery Trend & Volume', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < state.dailyTrends.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(format.format(state.dailyTrends[value.toInt()].date), style: const TextStyle(fontSize: 10)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${(value / 1000).toInt()}k', style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: state.dailyTrends.asMap().entries.map((entry) {
                    final index = entry.key;
                    final trend = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: trend.volume.toDouble(),
                          color: theme.colorScheme.primary.withOpacity(0.8),
                          width: 16,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        )
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

  Widget _buildChannelPieChart(ThemeData theme, NotificationAnalyticsState state) {
    final colors = [Colors.blue, Colors.purple, Colors.green, Colors.orange];
    int colorIndex = 0;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.colorScheme.outlineVariant)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Channel Performance', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  sections: state.channelPerformance.entries.map((entry) {
                    final color = colors[colorIndex % colors.length];
                    colorIndex++;
                    return PieChartSectionData(
                      color: color,
                      value: entry.value,
                      title: '${entry.value.toInt()}%',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: state.channelPerformance.keys.map((key) {
                final color = colors[state.channelPerformance.keys.toList().indexOf(key) % colors.length];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 12, height: 12, color: color),
                    const SizedBox(width: 8),
                    Text(key, style: const TextStyle(fontSize: 12)),
                  ],
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsRow(BuildContext context, ThemeData theme, NotificationAnalyticsState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 1000;
        final heatmap = _buildHeatmapGrid(theme, state);
        final recommendations = _buildAiRecommendations(theme, state);
        
        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: heatmap),
              const SizedBox(width: 24),
              Expanded(flex: 1, child: recommendations),
            ],
          );
        } else {
          return Column(
            children: [
              heatmap,
              const SizedBox(height: 24),
              recommendations,
            ],
          );
        }
      }
    );
  }

  Widget _buildHeatmapGrid(ThemeData theme, NotificationAnalyticsState state) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.colorScheme.outlineVariant)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.calendar, size: 18),
                const SizedBox(width: 8),
                Text('Delivery Hours Heatmap', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // Y-axis labels (Days)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    SizedBox(height: 20), // offset for x axis
                    Text('Mon', style: TextStyle(fontSize: 10)), SizedBox(height: 12),
                    Text('Tue', style: TextStyle(fontSize: 10)), SizedBox(height: 12),
                    Text('Wed', style: TextStyle(fontSize: 10)), SizedBox(height: 12),
                    Text('Thu', style: TextStyle(fontSize: 10)), SizedBox(height: 12),
                    Text('Fri', style: TextStyle(fontSize: 10)), SizedBox(height: 12),
                    Text('Sat', style: TextStyle(fontSize: 10)), SizedBox(height: 12),
                    Text('Sun', style: TextStyle(fontSize: 10)),
                  ],
                ),
                const SizedBox(width: 8),
                // Grid
                Expanded(
                  child: Column(
                    children: [
                      // X-axis labels (Hours)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(24, (index) {
                          if (index % 4 == 0) return Text('$index', style: const TextStyle(fontSize: 10));
                          return const SizedBox(width: 10); // Approximation spacer
                        }),
                      ),
                      const SizedBox(height: 8),
                      // Heatmap cells
                      ...List.generate(7, (dayIndex) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            children: List.generate(24, (hourIndex) {
                              final intensity = state.deliveryHeatmap[dayIndex][hourIndex];
                              return Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 1),
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withOpacity(intensity),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Less', style: TextStyle(fontSize: 10)),
                const SizedBox(width: 8),
                Container(width: 12, height: 12, color: theme.colorScheme.primary.withOpacity(0.1)),
                Container(width: 12, height: 12, color: theme.colorScheme.primary.withOpacity(0.4)),
                Container(width: 12, height: 12, color: theme.colorScheme.primary.withOpacity(0.7)),
                Container(width: 12, height: 12, color: theme.colorScheme.primary.withOpacity(1.0)),
                const SizedBox(width: 8),
                const Text('More', style: TextStyle(fontSize: 10)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAiRecommendations(ThemeData theme, NotificationAnalyticsState state) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.primary.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2))),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.sparkles, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('AI Optimization Suggestions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 24),
            ...state.recommendations.map((rec) {
              Color impactColor;
              if (rec.impact == 'High') impactColor = Colors.red;
              else if (rec.impact == 'Medium') impactColor = Colors.orange;
              else impactColor = Colors.blue;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(rec.title, style: const TextStyle(fontWeight: FontWeight.bold))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: impactColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('${rec.impact} Impact', style: TextStyle(color: impactColor, fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(rec.description, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
