import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'providers/ai_predictions_provider.dart';
import '../domain/ai_predictions_model.dart';

class AiPredictionsDashboardScreen extends ConsumerWidget {
  const AiPredictionsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aiPredictionsProvider);
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerOrEqualTo(DESKTOP);
    final isTablet = ResponsiveBreakpoints.of(context).largerOrEqualTo(TABLET);

    return Scaffold(
      body: state.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, ref, state),
                const SizedBox(height: 24),
                
                // Prediction Metrics Grid
                GridView.count(
                  crossAxisCount: isDesktop ? 3 : isTablet ? 2 : 1,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: isDesktop ? 2.5 : 2.0,
                  children: state.metrics.map((m) => _buildMetricCard(context, m)).toList(),
                ).animate().fade().slideY(begin: 0.1),
                const SizedBox(height: 24),

                // Charts Row
                Flex(
                  direction: isDesktop ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: isDesktop ? 2 : 0,
                      child: _buildChartCard(
                        context, 
                        'Forecast Trend (Historical vs Predicted)', 
                        _buildForecastChart(theme, state.forecastTrend),
                      ),
                    ),
                    if (isDesktop) const SizedBox(width: 16),
                    if (!isDesktop) const SizedBox(height: 16),
                    Expanded(
                      flex: isDesktop ? 1 : 0,
                      child: _buildRiskAlerts(context, state.riskAlerts),
                    ),
                  ],
                ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
                const SizedBox(height: 24),

                // Widgets Row
                Flex(
                  direction: isDesktop ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: isDesktop ? 1 : 0,
                      child: _buildRecommendations(context, state.recommendations),
                    ),
                    if (isDesktop) const SizedBox(width: 16),
                    if (!isDesktop) const SizedBox(height: 16),
                    Expanded(
                      flex: isDesktop ? 1 : 0,
                      child: _buildCapacityPlanning(context),
                    ),
                  ],
                ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
              ],
            ),
          ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, AiPredictionsState state) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(LucideIcons.trendingUp, size: 28, color: Colors.purple),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Predictive Analytics', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Future forecasting and capacity planning.', style: theme.textTheme.bodyMedium),
              ],
            ),
          ],
        ),
        Row(
          children: [
            _buildFilterDropdown(
              context,
              value: state.timeframeFilter,
              items: ['Next 30 Days', 'Next Quarter', 'Next Year'],
              onChanged: (val) {
                if (val != null) {
                  ref.read(aiPredictionsProvider.notifier).updateTimeframe(val);
                }
              },
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(LucideIcons.refreshCw, size: 18),
              label: const Text('Recalculate'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(BuildContext context, {required String value, required List<String> items, required Function(String?) onChanged}) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(LucideIcons.chevronDown, size: 16),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, PredictionMetric metric) {
    final theme = Theme.of(context);
    final isTrendPositive = metric.isPositive;
    // For things like Growth, positive is good (green). For Delays/Load, positive is bad (red/orange).
    // Let's assume standard logic: if it's "Growth" or "Revenue", green is good. 
    // If it's "Load" or "Delay", red is bad. We use isPositive to denote "desirable" increase vs "undesirable".
    final trendColor = isTrendPositive ? Colors.green : Colors.orange;
    final trendIcon = metric.trend.startsWith('+') ? LucideIcons.trendingUp : LucideIcons.trendingDown;

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
                Expanded(child: Text(metric.title, style: theme.textTheme.titleSmall?.copyWith(color: theme.textTheme.bodySmall?.color))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(metric.expectedTimeframe, style: const TextStyle(fontSize: 10)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(metric.value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                Row(
                  children: [
                    Icon(trendIcon, size: 16, color: trendColor),
                    const SizedBox(width: 4),
                    Text(metric.trend, style: TextStyle(color: trendColor, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(BuildContext context, String title, Widget chart) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(height: 300, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastChart(ThemeData theme, List<ForecastDataPoint> data) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: theme.dividerColor, strokeWidth: 1)),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(data[value.toInt()].date, style: const TextStyle(fontSize: 12)),
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
                return Text('${(value / 1000).toStringAsFixed(1)}k', style: const TextStyle(fontSize: 12));
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          // Historical Line
          LineChartBarData(
            spots: data.where((d) => d.historicalValue > 0).map((d) {
              return FlSpot(data.indexOf(d).toDouble(), d.historicalValue);
            }).toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
          ),
          // Predicted Line
          LineChartBarData(
            spots: data.where((d) => d.predictedValue > 0 && data.indexOf(d) >= 3).map((d) {
              return FlSpot(data.indexOf(d).toDouble(), d.predictedValue);
            }).toList(),
            isCurved: true,
            color: Colors.purple,
            barWidth: 3,
            dashArray: [5, 5], // Dashed line for prediction
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
          ),
          // Prediction Bounds (Confidence Interval)
          LineChartBarData(
            spots: data.where((d) => d.upperBound > 0).map((d) {
              return FlSpot(data.indexOf(d).toDouble(), d.upperBound);
            }).toList(),
            isCurved: true,
            color: Colors.transparent,
            barWidth: 0,
            dotData: const FlDotData(show: false),
          ),
          LineChartBarData(
            spots: data.where((d) => d.lowerBound > 0).map((d) {
              return FlSpot(data.indexOf(d).toDouble(), d.lowerBound);
            }).toList(),
            isCurved: true,
            color: Colors.transparent,
            barWidth: 0,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.purple.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskAlerts(BuildContext context, List<RiskAlert> alerts) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.alertTriangle, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text('Predicted Risk Alerts', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...alerts.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(8),
                  color: a.severity == 'Critical' ? Colors.red.withValues(alpha: 0.05) : theme.colorScheme.surface,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('${a.probability}% Prob.', style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(a.description, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context, List<String> recommendations) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.lightbulb, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text('AI Recommendations', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...recommendations.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.checkCircle2, color: Colors.green, size: 16),
                  const SizedBox(width: 12),
                  Expanded(child: Text(r, style: const TextStyle(height: 1.4))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildCapacityPlanning(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.database, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text('Capacity Planning', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 24),
            _buildCapacityBar(context, 'Storage (Global)', 78, 95),
            const SizedBox(height: 16),
            _buildCapacityBar(context, 'API Usage Limit', 65, 80),
            const SizedBox(height: 16),
            _buildCapacityBar(context, 'Compute Nodes', 45, 60),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCapacityBar(BuildContext context, String label, int currentPct, int predictedPct) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('Predict: $predictedPct%', style: TextStyle(color: theme.colorScheme.error, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Predicted (Background)
            FractionallySizedBox(
              widthFactor: predictedPct / 100,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            // Current (Foreground)
            FractionallySizedBox(
              widthFactor: currentPct / 100,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
