import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../domain/models/document_dashboard_model.dart';
import 'providers/document_dashboard_provider.dart';

class DocumentDashboardScreen extends ConsumerWidget {
  const DocumentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncState = ref.watch(documentDashboardProvider);
    final notifier = ref.read(documentDashboardProvider.notifier);

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
                  _buildHeader(context, theme, asyncState.value, notifier),
                  const SizedBox(height: 32),
                  asyncState.when(
                    data: (state) {
                      if (state.kpis.totalDocuments == 0) {
                        return _buildEmptyState(theme, notifier);
                      }
                      return _buildDashboardContent(context, theme, state);
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.all(64.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, stack) => _buildErrorState(theme, error.toString(), notifier),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, DocumentDashboardNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(64.0),
        child: Column(
          children: [
            Icon(LucideIcons.fileSearch, size: 64, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 24),
            Text('No Documents Found', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('There are no documents matching your selected filters.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => notifier.setFilters(org: 'All Organizations'),
              child: const Text('Clear Filters'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String error, DocumentDashboardNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(64.0),
        child: Column(
          children: [
            Icon(LucideIcons.alertTriangle, size: 64, color: Colors.red.withOpacity(0.8)),
            const SizedBox(height: 24),
            Text('Failed to load Dashboard', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(error, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => notifier.setFilters(org: 'All Organizations'),
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Retry'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, DocumentDashboardState? state, DocumentDashboardNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Document Engine Dashboard', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            Row(
              children: [
                _buildFilterDropdown(
                  theme,
                  LucideIcons.calendar,
                  state?.dateFilter ?? 'This Month',
                  ['Today', 'This Week', 'This Month', 'This Year'],
                  (val) => notifier.setFilters(date: val),
                ),
                const SizedBox(width: 16),
                _buildFilterDropdown(
                  theme,
                  LucideIcons.building2,
                  state?.orgFilter ?? 'All Organizations',
                  ['All Organizations', 'Acme Corp', 'Globex', 'Simulate Error', 'Simulate Empty'],
                  (val) => notifier.setFilters(org: val),
                ),
                const SizedBox(width: 16),
                _buildFilterDropdown(
                  theme,
                  LucideIcons.tag,
                  state?.categoryFilter ?? 'All Categories',
                  ['All Categories', 'Financials', 'Legal', 'HR'],
                  (val) => notifier.setFilters(category: val),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(ThemeData theme, IconData icon, String value, List<String> items, Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, ThemeData theme, DocumentDashboardState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildKpiGrid(theme, state),
        const SizedBox(height: 32),
        _buildChartsGrid(theme, state),
        const SizedBox(height: 32),
        _buildWidgetsGrid(theme, state),
      ],
    );
  }

  Widget _buildKpiGrid(ThemeData theme, DocumentDashboardState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1400 ? 4 : (constraints.maxWidth > 800 ? 2 : 1);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 3.5,
          children: [
            _buildStatCard('Total Documents', NumberFormat.compact().format(state.kpis.totalDocuments), LucideIcons.files, Colors.blue, theme),
            _buildStatCard('Storage Used', '${state.kpis.storageUsedGb.toStringAsFixed(1)} GB', LucideIcons.database, Colors.purple, theme),
            _buildStatCard('New Today', '+${state.kpis.newDocumentsToday}', LucideIcons.filePlus, Colors.green, theme),
            _buildStatCard('Shared externally', NumberFormat.compact().format(state.kpis.sharedDocuments), LucideIcons.share2, Colors.orange, theme),
            _buildStatCard('Versioned', NumberFormat.compact().format(state.kpis.versionedDocuments), LucideIcons.gitCommit, Colors.teal, theme),
            _buildStatCard('Expiring Soon', state.kpis.expiringDocuments.toString(), LucideIcons.clock, Colors.red, theme),
            _buildStatCard('Archived', NumberFormat.compact().format(state.kpis.archivedDocuments), LucideIcons.archive, Colors.grey, theme),
            _buildStatCard('Avg File Size', '${state.kpis.averageFileSizeMb.toStringAsFixed(1)} MB', LucideIcons.fileSearch, Colors.indigo, theme),
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
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsGrid(ThemeData theme, DocumentDashboardState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 1200;
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: isDesktop ? 2 : 1, child: _buildLineChartCard('Storage Growth (GB)', state.storageGrowth, theme)),
                if (isDesktop) const SizedBox(width: 24),
                if (isDesktop) Expanded(flex: 1, child: _buildCategoryPieChart(theme, state)),
              ],
            ),
            if (!isDesktop) const SizedBox(height: 24),
            if (!isDesktop) _buildCategoryPieChart(theme, state),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildBarChartCard('Upload Trend', state.uploadTrend, theme, Colors.green)),
                const SizedBox(width: 24),
                Expanded(child: _buildBarChartCard('Document Access Trend', state.accessTrend, theme, Colors.blue)),
              ],
            )
          ],
        );
      }
    );
  }

  Widget _buildLineChartCard(String title, List<DocumentTrendData> data, ThemeData theme) {
    final format = DateFormat('MMM');
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.colorScheme.outlineVariant)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: theme.colorScheme.outlineVariant, strokeWidth: 1)),
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
                            if (value.toInt() % 2 == 0) return const Text('');
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(format.format(data[value.toInt()].date), style: const TextStyle(fontSize: 10)),
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
                      spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.volume)).toList(),
                      isCurved: true,
                      color: Colors.purple,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: Colors.purple.withOpacity(0.1)),
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

  Widget _buildBarChartCard(String title, List<DocumentTrendData> data, ThemeData theme, Color color) {
    final format = DateFormat('MM/dd');
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.colorScheme.outlineVariant)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
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
                            if (value.toInt() % 3 != 0) return const Text('');
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(format.format(data[value.toInt()].date), style: const TextStyle(fontSize: 10)),
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
                        toY: e.value.volume,
                        color: color.withOpacity(0.8),
                        width: 12,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      )
                    ]
                  )).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart(ThemeData theme, DocumentDashboardState state) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.grey];
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.colorScheme.outlineVariant)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Documents by Category', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  sections: state.categoryStats.asMap().entries.map((entry) {
                    final color = colors[entry.key % colors.length];
                    return PieChartSectionData(
                      color: color,
                      value: entry.value.count,
                      title: '${entry.value.count.toInt()}%',
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
              children: state.categoryStats.asMap().entries.map((entry) {
                final color = colors[entry.key % colors.length];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 12, height: 12, color: color),
                    const SizedBox(width: 8),
                    Text(entry.value.category, style: const TextStyle(fontSize: 12)),
                  ],
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetsGrid(ThemeData theme, DocumentDashboardState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200 ? 3 : (constraints.maxWidth > 800 ? 2 : 1);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 1.2,
          children: [
            _buildListWidget('Recent Uploads', LucideIcons.uploadCloud, state.recentUploads, theme),
            _buildListWidget('Recently Viewed', LucideIcons.eye, state.recentlyViewed, theme),
            _buildListWidget('Pending Approval', LucideIcons.clipboardCheck, state.pendingApproval, theme),
            _buildListWidget('Favorites', LucideIcons.star, state.favoriteDocuments, theme),
            _buildListWidget('Recently Shared', LucideIcons.share, state.recentlyShared, theme),
          ],
        );
      }
    );
  }

  Widget _buildListWidget(String title, IconData icon, List<DocumentWidgetListItem> items, ThemeData theme) {
    final format = DateFormat('MMM dd, HH:mm');
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.colorScheme.outlineVariant)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All', style: TextStyle(fontSize: 12)),
                )
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                IconData typeIcon;
                Color typeColor;
                switch (item.type) {
                  case 'pdf': typeIcon = LucideIcons.fileText; typeColor = Colors.red; break;
                  case 'xls': typeIcon = LucideIcons.fileSpreadsheet; typeColor = Colors.green; break;
                  case 'img': typeIcon = LucideIcons.image; typeColor = Colors.purple; break;
                  default: typeIcon = LucideIcons.file; typeColor = Colors.blue;
                }

                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Icon(typeIcon, color: typeColor, size: 20),
                  ),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), overflow: TextOverflow.ellipsis),
                  subtitle: Text('${item.author} • ${format.format(item.date)}', style: const TextStyle(fontSize: 12)),
                  trailing: Text('${item.sizeMb.toStringAsFixed(1)} MB', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                  onTap: () {},
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
