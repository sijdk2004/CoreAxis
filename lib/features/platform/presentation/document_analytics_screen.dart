import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../domain/models/document_analytics_model.dart';
import 'providers/document_analytics_provider.dart';
import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';

class DocumentAnalyticsScreen extends ConsumerStatefulWidget {
  const DocumentAnalyticsScreen({super.key});

  @override
  ConsumerState<DocumentAnalyticsScreen> createState() => _DocumentAnalyticsScreenState();
}

class _DocumentAnalyticsScreenState extends ConsumerState<DocumentAnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final asyncState = ref.watch(documentAnalyticsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Document Analytics Dashboard'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/platform/documents');
            }
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting Analytics Dashboard to PDF...')),
                );
              },
              icon: const Icon(LucideIcons.download, size: 18),
              label: const Text('Export Dashboard'),
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
                const SizedBox(height: 32),
                _buildKpiGrid(context, state, isDesktop),
                const SizedBox(height: 32),
                _buildChartsRow1(context, state, isDesktop),
                const SizedBox(height: 32),
                _buildChartsRow2(context, state, isDesktop),
                const SizedBox(height: 32),
                _buildInsightsRow(context, state, isDesktop),
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
          child: Icon(LucideIcons.barChart2, size: 28, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Document Engine Analytics', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const Text('Comprehensive overview of document usage and storage insights.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiGrid(BuildContext context, DocumentAnalyticsModel state, bool isDesktop) {
    final cards = [
      GradientKpiCard(title: 'Documents', value: state.kpis['Documents']!, subtitle: 'Total managed', icon: LucideIcons.fileText, gradientColors: [Colors.blue.shade700, Colors.blue.shade400]),
      GradientKpiCard(title: 'Storage', value: state.kpis['Storage']!, subtitle: 'Active usage', icon: LucideIcons.hardDrive, gradientColors: [Colors.purple.shade700, Colors.purple.shade400]),
      GradientKpiCard(title: 'Downloads', value: state.kpis['Downloads']!, subtitle: 'This month', icon: LucideIcons.downloadCloud, gradientColors: [Colors.green.shade700, Colors.green.shade400]),
      GradientKpiCard(title: 'Shares', value: state.kpis['Shares']!, subtitle: 'Active links', icon: LucideIcons.share2, gradientColors: [Colors.orange.shade700, Colors.orange.shade400]),
      GradientKpiCard(title: 'Versions', value: state.kpis['Versions']!, subtitle: 'Total tracked', icon: LucideIcons.gitCommit, gradientColors: [Colors.teal.shade700, Colors.teal.shade400]),
      GradientKpiCard(title: 'Archive Rate', value: state.kpis['Archive Rate']!, subtitle: 'vs active', icon: LucideIcons.archive, gradientColors: [Colors.indigo.shade700, Colors.indigo.shade400]),
    ];

    return GridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 140,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cards,
    );
  }

  Widget _buildChartsRow1(BuildContext context, DocumentAnalyticsModel state, bool isDesktop) {
    final content = [
      Expanded(
        child: _buildChartCard(
          context,
          'Storage Trend (TB)',
          'Last 6 Months',
          _buildLineChart(state.storageTrend, Theme.of(context).colorScheme.primary),
        ),
      ),
      if (isDesktop) const SizedBox(width: 24) else const SizedBox(height: 24),
      Expanded(
        child: _buildChartCard(
          context,
          'Downloads Trend',
          'Last 6 Months',
          _buildBarChart(state.downloadTrend, Colors.green),
        ),
      ),
    ];

    return isDesktop ? Row(children: content) : Column(children: content);
  }

  Widget _buildChartsRow2(BuildContext context, DocumentAnalyticsModel state, bool isDesktop) {
    final content = [
      Expanded(
        child: _buildChartCard(
          context,
          'Category Usage',
          'Distribution by type',
          _buildPieChart(state.categoryUsage),
        ),
      ),
      if (isDesktop) const SizedBox(width: 24) else const SizedBox(height: 24),
      Expanded(
        child: _buildChartCard(
          context,
          'Organization Comparison',
          'Storage (GB) vs Documents',
          _buildDoubleBarChart(state.organizationComparison, Colors.purple, Colors.orange),
        ),
      ),
    ];

    return isDesktop ? Row(children: content) : Column(children: content);
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

  Widget _buildInsightsRow(BuildContext context, DocumentAnalyticsModel state, bool isDesktop) {
    final content = [
      Expanded(child: _buildTopList(context, 'Most Viewed Documents', state.mostViewedDocuments, LucideIcons.eye)),
      if (isDesktop) const SizedBox(width: 24) else const SizedBox(height: 24),
      Expanded(child: _buildTopList(context, 'Largest Files', state.largestFiles, LucideIcons.hardDrive)),
      if (isDesktop) const SizedBox(width: 24) else const SizedBox(height: 24),
      Expanded(child: _buildAiRecommendations(context, state.aiRecommendations)),
    ];
    
    return isDesktop ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: content) : Column(children: content);
  }

  Widget _buildTopList(BuildContext context, String title, List<DocumentItem> items, IconData icon) {
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
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(LucideIcons.file, size: 16, color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis),
                        Text(item.id, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 11)),
                      ],
                    ),
                  ),
                  Text(item.metric, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildAiRecommendations(BuildContext context, List<String> recommendations) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.sparkles, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text('AI Insights', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 16),
            ...recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(LucideIcons.lightbulb, size: 16, color: Colors.orange.shade400),
                  const SizedBox(width: 12),
                  Expanded(child: Text(rec, style: const TextStyle(fontSize: 13, height: 1.4))),
                ],
              ),
            )),
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
              color: color.withValues(alpha: 0.1),
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
    final colors = [Colors.blue, Colors.purple, Colors.orange, Colors.green, Colors.grey];
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

  Widget _buildDoubleBarChart(List<BarChartDataPoint> data, Color color1, Color color2) {
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
                    child: Text(data[val.toInt()].label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
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
              toY: e.value.value1,
              color: color1,
              width: 12,
              borderRadius: BorderRadius.circular(2),
            ),
            BarChartRodData(
              toY: e.value.value2,
              color: color2,
              width: 12,
              borderRadius: BorderRadius.circular(2),
            )
          ],
        )).toList(),
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
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold)),
    );
  }
}
