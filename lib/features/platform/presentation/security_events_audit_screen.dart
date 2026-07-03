import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../domain/models/security_events_audit_model.dart';
import 'providers/security_events_audit_provider.dart';

class SecurityEventsAuditScreen extends ConsumerStatefulWidget {
  const SecurityEventsAuditScreen({super.key});

  @override
  ConsumerState<SecurityEventsAuditScreen> createState() => _SecurityEventsAuditScreenState();
}

class _SecurityEventsAuditScreenState extends ConsumerState<SecurityEventsAuditScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final asyncState = ref.watch(securityEventsAuditProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Login & Security Events'),
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: FilledButton.icon(
              onPressed: () => ref.read(securityEventsAuditProvider.notifier).refresh(),
              icon: const Icon(LucideIcons.refreshCw, size: 18),
              label: const Text('Refresh'),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMetricsRow(context, state, isDesktop),
                const SizedBox(height: 24),
                _buildChartsRow(context, state, isDesktop),
                const SizedBox(height: 24),
                _buildWidgetsRow(context, state, isDesktop),
                const SizedBox(height: 24),
                _buildDataTable(context, state),
              ],
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),
          );
        },
      ),
    );
  }

  Widget _buildMetricsRow(BuildContext context, SecurityEventsAuditModel state, bool isDesktop) {
    return GridView.count(
      crossAxisCount: isDesktop ? 6 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isDesktop ? 1.5 : 2,
      children: [
        _buildMetricCard(context, 'Successful Logins', state.successfulLogins.toString(), LucideIcons.checkCircle, Colors.green),
        _buildMetricCard(context, 'Failed Logins', state.failedLogins.toString(), LucideIcons.xCircle, Colors.red),
        _buildMetricCard(context, 'Locked Accounts', state.lockedAccounts.toString(), LucideIcons.lock, Colors.orange),
        _buildMetricCard(context, 'Password Changes', state.passwordChanges.toString(), LucideIcons.key, Colors.blue),
        _buildMetricCard(context, 'MFA Events', state.mfaEvents.toString(), LucideIcons.smartphone, Colors.purple),
        _buildMetricCard(context, 'Active Sessions', state.activeSessions.toString(), LucideIcons.activity, Colors.teal),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
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
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title, 
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsRow(BuildContext context, SecurityEventsAuditModel state, bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 350,
              child: _buildTrendChart(context, state.loginTrend, state.failedLoginTrend),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 350,
              child: _buildRiskDistributionChart(context, state.riskDistribution),
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 350,
            child: _buildTrendChart(context, state.loginTrend, state.failedLoginTrend),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 350,
            child: _buildRiskDistributionChart(context, state.riskDistribution),
          ),
        ],
      );
    }
  }

  Widget _buildTrendChart(BuildContext context, List<ChartDataPoint> loginData, List<ChartDataPoint> failedData) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Login Trends', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    _buildLegendItem(theme.colorScheme.primary, 'Success'),
                    const SizedBox(width: 16),
                    _buildLegendItem(Colors.red, 'Failed'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < loginData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(loginData[value.toInt()].label, style: const TextStyle(fontSize: 10)),
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
                      spots: loginData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
                      isCurved: true,
                      color: theme.colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: failedData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
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

  Widget _buildRiskDistributionChart(BuildContext context, List<CategoryDataPoint> data) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Risk Distribution', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Expanded(
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: data.map((e) {
                    final color = Color(int.parse(e.colorHex.replaceFirst('#', '0xFF')));
                    return PieChartSectionData(
                      color: color,
                      value: e.value,
                      title: '${e.value.toInt()}%',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
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
              children: data.map((e) {
                final color = Color(int.parse(e.colorHex.replaceFirst('#', '0xFF')));
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text(e.category, style: const TextStyle(fontSize: 12)),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildWidgetsRow(BuildContext context, SecurityEventsAuditModel state, bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildSuspiciousActivityWidget(context, state.suspiciousActivities)),
          const SizedBox(width: 24),
          Expanded(child: _buildRecentSessionsWidget(context, state.recentSessions)),
          const SizedBox(width: 24),
          Expanded(child: _buildSecurityAlertsWidget(context, state.securityAlerts)),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSuspiciousActivityWidget(context, state.suspiciousActivities),
          const SizedBox(height: 24),
          _buildRecentSessionsWidget(context, state.recentSessions),
          const SizedBox(height: 24),
          _buildSecurityAlertsWidget(context, state.securityAlerts),
        ],
      );
    }
  }

  Widget _buildSuspiciousActivityWidget(BuildContext context, List<SuspiciousActivity> activities) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.alertTriangle, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text('Suspicious Activity', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...activities.map((activity) {
              Color severityColor = activity.severity == 'Critical' ? Colors.red : Colors.orange;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(activity.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: severityColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(activity.severity, style: TextStyle(color: severityColor, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(activity.description, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(activity.timeAgo, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 10)),
                    const Divider(),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSessionsWidget(BuildContext context, List<RecentSession> sessions) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.monitor, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text('Recent Sessions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...sessions.map((session) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Text(session.user.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 12)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(session.user, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(session.ipAddress, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: session.isActive ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(session.duration, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityAlertsWidget(BuildContext context, List<SecurityAlert> alerts) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.bell, color: Colors.purple, size: 20),
                const SizedBox(width: 8),
                Text('Security Alerts', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...alerts.map((alert) {
              Color iconColor;
              IconData icon;
              if (alert.type == 'Warning') {
                iconColor = Colors.orange;
                icon = LucideIcons.alertCircle;
              } else if (alert.type == 'Error') {
                iconColor = Colors.red;
                icon = LucideIcons.xCircle;
              } else {
                iconColor = Colors.blue;
                icon = LucideIcons.info;
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: iconColor, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(alert.message, style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(BuildContext context, SecurityEventsAuditModel state) {
    final theme = Theme.of(context);
    
    var filteredRows = state.tableRows.where((row) => 
      row.user.toLowerCase().contains(_searchQuery.toLowerCase()) || 
      row.eventType.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Security Events Log', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search events or users...',
                      prefixIcon: const Icon(LucideIcons.search, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
              columns: const [
                DataColumn(label: Text('Timestamp')),
                DataColumn(label: Text('User')),
                DataColumn(label: Text('IP Address')),
                DataColumn(label: Text('Browser')),
                DataColumn(label: Text('Location (Mock)')),
                DataColumn(label: Text('Device')),
                DataColumn(label: Text('Event Type')),
                DataColumn(label: Text('Result')),
                DataColumn(label: Text('Risk Level')),
                DataColumn(label: Text('Actions')),
              ],
              rows: filteredRows.map((row) {
                return DataRow(
                  cells: [
                    DataCell(Text(row.timestamp)),
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Text(row.user.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 10)),
                        ),
                        const SizedBox(width: 8),
                        Text(row.user, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    )),
                    DataCell(Text(row.ipAddress)),
                    DataCell(Text(row.browser)),
                    DataCell(Text(row.location)),
                    DataCell(Text(row.device)),
                    DataCell(Text(row.eventType)),
                    DataCell(_buildResultBadge(row.result)),
                    DataCell(_buildRiskLevelBadge(row.riskLevel)),
                    DataCell(
                      IconButton(
                        icon: const Icon(LucideIcons.eye, size: 18),
                        onPressed: () => context.push('/platform/audit/entity/${row.userId}'),
                        tooltip: 'View User Timeline',
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Showing ${filteredRows.length} events', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultBadge(String result) {
    Color color = result == 'Success' ? Colors.green : (result == 'Blocked' ? Colors.orange : Colors.red);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        result,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildRiskLevelBadge(String level) {
    Color color;
    switch (level) {
      case 'Low': color = Colors.green; break;
      case 'Medium': color = Colors.orange; break;
      case 'High': color = Colors.deepOrange; break;
      case 'Critical': color = Colors.red; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        level,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
