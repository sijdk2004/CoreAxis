import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'providers/executive_dashboard_provider.dart';

class ExecutiveDashboardScreen extends ConsumerWidget {
  const ExecutiveDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(executiveDashboardProvider);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final isTablet = ResponsiveBreakpoints.of(context).equals(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Executive Presentation'),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Chip(
              avatar: const Icon(LucideIcons.checkCircle2, color: Colors.green, size: 18),
              label: Text('System Health: ${state.systemUptime}%'),
              backgroundColor: Colors.green.withValues(alpha: 0.1),
              side: BorderSide.none,
            ).animate().fadeIn().scale(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Global Performance Overview',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
            Text(
              'Live metrics and AI insights for ${DateFormat('MMMM yyyy').format(DateTime.now())}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0),
            
            const SizedBox(height: 32),

            // Top KPI Cards
            GridView.count(
              crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 1),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: isDesktop ? 1.8 : 2.0,
              children: [
                _buildKpiCard(
                  context: context,
                  title: 'Annual Revenue',
                  value: '\$${(state.annualRevenue / 1000000).toStringAsFixed(1)}M',
                  trend: '+${state.growthPercentage}%',
                  icon: LucideIcons.dollarSign,
                  color: Colors.blue,
                  delay: 100.ms,
                ),
                _buildKpiCard(
                  context: context,
                  title: 'Active Users',
                  value: NumberFormat.compact().format(state.activeUsers),
                  trend: '+12%',
                  icon: LucideIcons.users,
                  color: Colors.purple,
                  delay: 200.ms,
                ),
                _buildKpiCard(
                  context: context,
                  title: 'Workflows Automated',
                  value: NumberFormat.compact().format(state.workflowCompletions),
                  trend: '+45%',
                  icon: LucideIcons.gitMerge,
                  color: Colors.orange,
                  delay: 300.ms,
                ),
                _buildKpiCard(
                  context: context,
                  title: 'AI Insights Generated',
                  value: NumberFormat.compact().format(state.aiInsightsGenerated),
                  trend: '+89%',
                  icon: LucideIcons.sparkles,
                  color: Colors.green,
                  delay: 400.ms,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Main Charts Section
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildRevenueChart(context, theme, state).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1, end: 0),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        _buildAiInsightsWidget(context, theme, state).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1, end: 0),
                        const SizedBox(height: 24),
                        _buildStorageHealthWidget(context, theme, state).animate().fadeIn(delay: 700.ms).slideX(begin: 0.1, end: 0),
                      ],
                    ),
                  ),
                ],
              )
            else ...[
              _buildRevenueChart(context, theme, state).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 24),
              _buildAiInsightsWidget(context, theme, state).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 24),
              _buildStorageHealthWidget(context, theme, state).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1, end: 0),
            ],
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required BuildContext context,
    required String title,
    required String value,
    required String trend,
    required IconData icon,
    required Color color,
    required Duration delay,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              color.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.trendingUp, size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        trend,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay).scale(delay: delay, curve: Curves.easeOutBack);
  }

  Widget _buildRevenueChart(BuildContext context, ThemeData theme, ExecutiveDashboardState state) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Revenue Growth (Last 12 Months)',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.moreHorizontal),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                          if (value.toInt() >= 0 && value.toInt() < months.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                months[value.toInt()],
                                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 2,
                        reservedSize: 42,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toInt()}M',
                            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 11,
                  minY: 6,
                  maxY: 14,
                  lineBarsData: [
                    LineChartBarData(
                      spots: state.revenueHistory.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                      isCurved: true,
                      color: theme.colorScheme.primary,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: theme.colorScheme.surface,
                            strokeWidth: 2,
                            strokeColor: theme.colorScheme.primary,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.3),
                            theme.colorScheme.primary.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
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

  Widget _buildAiInsightsWidget(BuildContext context, ThemeData theme, ExecutiveDashboardState state) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.sparkles, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'CoreAxis AI Insights',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...state.recentAiInsights.map((insight) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.lightbulb, size: 18, color: Colors.orange.shade400),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        insight,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () {},
                child: const Text('View All Insights'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageHealthWidget(BuildContext context, ThemeData theme, ExecutiveDashboardState state) {
    final storagePercent = state.storageUsedTb / state.storageTotalTb;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.database, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Storage & Health',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              '${state.storageUsedTb} TB / ${state.storageTotalTb} TB',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: storagePercent,
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  storagePercent > 0.8 ? Colors.red : theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reports Generated', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text(NumberFormat.compact().format(state.reportsViewed), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Notifications', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text(NumberFormat.compact().format(state.notificationsSent), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
