import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import 'providers/system_status_provider.dart';
import 'models/system_status_model.dart';

class SystemStatusScreen extends ConsumerStatefulWidget {
  const SystemStatusScreen({super.key});

  @override
  ConsumerState<SystemStatusScreen> createState() => _SystemStatusScreenState();
}

class _SystemStatusScreenState extends ConsumerState<SystemStatusScreen> {
  String _searchQuery = '';
  ServiceStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(systemStatusProvider);
    final notifier = ref.read(systemStatusProvider.notifier);
    final isDark = theme.brightness == Brightness.dark;

    final filteredServices = state.services.where((s) {
      final matchesQuery = s.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                           s.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _filterStatus == null || s.status == _filterStatus;
      return matchesQuery && matchesStatus;
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
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
                          Text(
                            'System Status Center',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Real-time health monitoring and enterprise operations.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Mock refresh
                        },
                        icon: const Icon(LucideIcons.refreshCw, size: 18),
                        label: const Text('Refresh All'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Key Metrics Cards
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 1200 ? 5 : (constraints.maxWidth > 800 ? 3 : 2);
                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 2.5,
                        children: [
                          _buildMetricCard(theme, 'CPU Usage', '${state.metrics.cpuUsage.toStringAsFixed(1)}%', LucideIcons.cpu, Colors.blue),
                          _buildMetricCard(theme, 'Memory', '${state.metrics.memoryUsage.toStringAsFixed(1)}%', LucideIcons.database, Colors.purple),
                          _buildMetricCard(theme, 'Active Conns', NumberFormat.compact().format(state.metrics.activeConnections), LucideIcons.network, Colors.green),
                          _buildMetricCard(theme, 'Request Rate', '${state.metrics.requestRate.toInt()} /s', LucideIcons.activity, Colors.orange),
                          _buildMetricCard(theme, 'Error Rate', '${state.metrics.errorRate.toStringAsFixed(2)}%', LucideIcons.alertTriangle, state.metrics.errorRate > 1.0 ? Colors.red : Colors.teal),
                        ],
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
                    }
                  ),
                  const SizedBox(height: 32),
                  
                  // Charts Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildChartCard(
                          theme: theme, 
                          title: 'System Performance (Latency ms)',
                          data: state.performanceData,
                          color: theme.colorScheme.primary,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _buildChartCard(
                          theme: theme, 
                          title: 'Request Volume',
                          data: state.volumeData,
                          color: Colors.purpleAccent,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                  
                  const SizedBox(height: 32),
                  
                  // Services List
                  Text(
                    'Service Health',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Filters
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search services...',
                            prefixIcon: const Icon(LucideIcons.search, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 200,
                        child: DropdownButtonFormField<ServiceStatus?>(
                          value: _filterStatus,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          items: const [
                            DropdownMenuItem(value: null, child: Text('All Statuses')),
                            DropdownMenuItem(value: ServiceStatus.healthy, child: Text('Healthy')),
                            DropdownMenuItem(value: ServiceStatus.degraded, child: Text('Degraded')),
                            DropdownMenuItem(value: ServiceStatus.down, child: Text('Down')),
                            DropdownMenuItem(value: ServiceStatus.maintenance, child: Text('Maintenance')),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _filterStatus = val;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.dividerColor),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest),
                        columns: const [
                          DataColumn(label: Text('Service')),
                          DataColumn(label: SizedBox(width: 120, child: Text('Status'))),
                          DataColumn(label: SizedBox(width: 80, child: Text('Uptime'))),
                          DataColumn(label: SizedBox(width: 80, child: Text('Latency'))),
                          DataColumn(label: SizedBox(width: 100, child: Text('Actions'))),
                        ],
                        rows: filteredServices.map((service) {
                          final statusColor = _getStatusColor(service.status);
                          final statusText = _getStatusText(service.status);
                          
                          return DataRow(
                            cells: [
                              DataCell(
                                SizedBox(
                                  width: 250,
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(service.icon, size: 16, color: theme.colorScheme.primary),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              service.name, 
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              service.description, 
                                              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: statusColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                              DataCell(Text(service.uptime, style: const TextStyle(fontFamily: 'monospace'))),
                              DataCell(Text(service.latency, style: const TextStyle(fontFamily: 'monospace'))),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(LucideIcons.rotateCw, size: 18),
                                      tooltip: 'Restart Service',
                                      onPressed: () {
                                        notifier.simulateServiceRestart(service.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Restarting ${service.name}...')),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(LucideIcons.fileText, size: 18),
                                      tooltip: 'View Logs',
                                      onPressed: () {
                                        // Mock view logs
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(ThemeData theme, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard({
    required ThemeData theme,
    required String title,
    required List<ChartDataPoint> data,
    required Color color,
    required bool isDark,
  }) {
    if (data.isEmpty) return const SizedBox();
    
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
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.dividerColor,
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
                        reservedSize: 22,
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < 0 || value.toInt() >= data.length) {
                            return const SizedBox();
                          }
                          final date = data[value.toInt()].timestamp;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('HH:mm:ss').format(date),
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              fontSize: 10,
                            ),
                          );
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
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.healthy:
        return Colors.green;
      case ServiceStatus.degraded:
        return Colors.orange;
      case ServiceStatus.down:
        return Colors.red;
      case ServiceStatus.maintenance:
        return Colors.blueGrey;
    }
  }

  String _getStatusText(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.healthy:
        return 'Healthy';
      case ServiceStatus.degraded:
        return 'Degraded';
      case ServiceStatus.down:
        return 'Down';
      case ServiceStatus.maintenance:
        return 'Maintenance';
    }
  }
}
