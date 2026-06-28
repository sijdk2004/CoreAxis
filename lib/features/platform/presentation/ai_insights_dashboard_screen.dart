import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import '../data/ai_insights_dashboard_provider.dart';

class AiInsightsDashboardScreen extends ConsumerStatefulWidget {
  const AiInsightsDashboardScreen({super.key});

  @override
  ConsumerState<AiInsightsDashboardScreen> createState() => _AiInsightsDashboardScreenState();
}

class _AiInsightsDashboardScreenState extends ConsumerState<AiInsightsDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final dashboardState = ref.watch(aiInsightsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: dashboardState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error loading insights: $error')),
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
                      Expanded(flex: 2, child: _buildRevenueForecast(context, charts['revenue_forecast']).animate().fade(delay: 500.ms)),
                      const SizedBox(width: 24),
                      Expanded(flex: 1, child: _buildRiskAlerts(context, widgets['risk_alerts']).animate().fade(delay: 600.ms)),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildRevenueForecast(context, charts['revenue_forecast']).animate().fade(delay: 500.ms),
                      const SizedBox(height: 24),
                      _buildRiskAlerts(context, widgets['risk_alerts']).animate().fade(delay: 600.ms),
                    ],
                  ),
                const SizedBox(height: 32),
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 1, child: _buildWorkflowOptimization(context, widgets['optimization_suggestions']).animate().fade(delay: 700.ms)),
                      const SizedBox(width: 24),
                      Expanded(flex: 1, child: _buildTenantHealth(context, widgets['tenant_health_scores']).animate().fade(delay: 800.ms)),
                      const SizedBox(width: 24),
                      Expanded(flex: 1, child: _buildAiRecommendations(context, widgets['recommendations_feed']).animate().fade(delay: 900.ms)),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildWorkflowOptimization(context, widgets['optimization_suggestions']).animate().fade(delay: 700.ms),
                      const SizedBox(height: 24),
                      _buildTenantHealth(context, widgets['tenant_health_scores']).animate().fade(delay: 800.ms),
                      const SizedBox(height: 24),
                      _buildAiRecommendations(context, widgets['recommendations_feed']).animate().fade(delay: 900.ms),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.sparkles, color: theme.colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Text('AI Insights', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              ],
            ),
            const SizedBox(height: 4),
            Text('Predictive analytics and intelligent recommendations', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600)),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => ref.read(aiInsightsProvider.notifier).refresh(),
          icon: const Icon(LucideIcons.refreshCw, size: 18),
          label: const Text('Refresh Insights'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    ).animate().fade().slideY(begin: -0.2);
  }

  Widget _buildKpiSection(Map<String, dynamic> kpis, bool isDesktop) {
    final cards = [
      GradientKpiCard(title: 'AI Requests', value: '${kpis['ai_requests']}', subtitle: '+${kpis['requests_growth']}%', icon: LucideIcons.bot, gradientColors: [Colors.purple, Colors.purpleAccent]),
      GradientKpiCard(title: 'Saved Time', value: '${kpis['saved_time']}', subtitle: '+${kpis['saved_time_growth']}%', icon: LucideIcons.clock, gradientColors: [Colors.teal, Colors.tealAccent]),
      GradientKpiCard(title: 'Automation Rate', value: '${kpis['automation_rate']}%', subtitle: '+${kpis['automation_growth']}%', icon: LucideIcons.gitMerge, gradientColors: [Colors.blue, Colors.lightBlue]),
      GradientKpiCard(title: 'Predicted Revenue', value: '${kpis['predicted_revenue']}', subtitle: '+${kpis['revenue_growth']}%', icon: LucideIcons.trendingUp, gradientColors: [Colors.green, Colors.lightGreen]),
    ];

    if (isDesktop) {
      return Row(
        children: cards.asMap().entries.map((entry) {
          int idx = entry.key;
          Widget card = entry.value;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: idx < cards.length - 1 ? 16.0 : 0),
              child: card.animate().fade(delay: (100 * (idx + 1)).ms).slideY(begin: 0.1),
            ),
          );
        }).toList(),
      );
    } else {
      return Column(
        children: cards.map((card) => Padding(padding: const EdgeInsets.only(bottom: 16.0), child: card)).toList(),
      );
    }
  }

  Widget _buildRevenueForecast(BuildContext context, List<dynamic> data) {
    final theme = Theme.of(context);
    List<FlSpot> actualSpots = [];
    List<FlSpot> predictedSpots = [];
    List<String> labels = [];
    double maxY = 0;
    
    for (int i = 0; i < data.length; i++) {
      if (data[i]['actual'] != null) {
        double y = (data[i]['actual'] as num).toDouble();
        actualSpots.add(FlSpot(i.toDouble(), y));
        if (y > maxY) maxY = y;
      }
      if (data[i]['predicted'] != null) {
        double y = (data[i]['predicted'] as num).toDouble();
        predictedSpots.add(FlSpot(i.toDouble(), y));
        if (y > maxY) maxY = y;
      }
      labels.add(data[i]['label']);
    }
    
    // Connect the last actual to the first predicted if needed.
    if (actualSpots.isNotEmpty && predictedSpots.isNotEmpty) {
      predictedSpots.insert(0, actualSpots.last);
    }

    maxY = maxY * 1.2;

    return PremiumCard(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        height: 350,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Revenue Forecast', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                Row(
                  children: [
                    Container(width: 12, height: 12, color: Colors.blue, margin: const EdgeInsets.only(right: 8)),
                    const Text('Actual', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 16),
                    Container(width: 12, height: 12, color: Colors.orange, margin: const EdgeInsets.only(right: 8)),
                    const Text('Predicted', style: TextStyle(fontSize: 12)),
                  ],
                )
              ],
            ),
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
                          return SideTitleWidget(meta: meta, child: Text('${value.toInt()}k', style: const TextStyle(color: Colors.grey, fontSize: 11)));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: actualSpots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(radius: 4, color: Colors.white, strokeWidth: 2, strokeColor: Colors.blue);
                      }),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(colors: [Colors.blue.withOpacity(0.3), Colors.blue.withOpacity(0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                      ),
                    ),
                    LineChartBarData(
                      spots: predictedSpots,
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 3,
                      dashArray: [5, 5],
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(radius: 4, color: Colors.white, strokeWidth: 2, strokeColor: Colors.orange);
                      }),
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

  Widget _buildRiskAlerts(BuildContext context, List<dynamic> alerts) {
    final theme = Theme.of(context);
    return PremiumCard(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        height: 350,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Risk Alerts', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: Colors.red)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: alerts.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  Color color = Colors.red;
                  if (alert['severity'] == 'Medium') color = Colors.orange;
                  if (alert['severity'] == 'Low') color = Colors.amber;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(LucideIcons.alertTriangle, color: color, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(alert['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(alert['description'], style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                            ],
                          ),
                        ),
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

  Widget _buildWorkflowOptimization(BuildContext context, List<dynamic> suggestions) {
    final theme = Theme.of(context);
    return PremiumCard(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.lightbulb, color: Colors.amber),
              const SizedBox(width: 8),
              Text('Workflow Optimization', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),
          ...suggestions.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(item['description'], style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text('Impact: ${item['impact']}', style: const TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const Divider(),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTenantHealth(BuildContext context, List<dynamic> scores) {
    final theme = Theme.of(context);
    return PremiumCard(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tenant Health Scores', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),
          ...scores.map((item) {
            final score = item['score'] as int;
            Color color = Colors.green;
            if (score < 80) color = Colors.orange;
            if (score < 60) color = Colors.red;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('$score', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: score / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAiRecommendations(BuildContext context, List<dynamic> recommendations) {
    final theme = Theme.of(context);
    return PremiumCard(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AI Recommendations Feed', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          ...recommendations.map((item) {
            IconData icon = LucideIcons.checkCircle;
            Color color = Colors.blue;
            switch(item['type']) {
              case 'workflow': icon = LucideIcons.gitMerge; color = Colors.orange; break;
              case 'sales': icon = LucideIcons.dollarSign; color = Colors.green; break;
              case 'infra': icon = LucideIcons.server; color = Colors.purple; break;
              case 'legal': icon = LucideIcons.shield; color = Colors.red; break;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(icon, color: color, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(item['time'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
