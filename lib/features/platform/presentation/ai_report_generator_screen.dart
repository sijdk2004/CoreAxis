import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'providers/ai_report_provider.dart';
import 'models/ai_report_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AIReportGeneratorScreen extends ConsumerStatefulWidget {
  const AIReportGeneratorScreen({super.key});

  @override
  ConsumerState<AIReportGeneratorScreen> createState() => _AIReportGeneratorScreenState();
}

class _AIReportGeneratorScreenState extends ConsumerState<AIReportGeneratorScreen> {
  final TextEditingController _promptController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _generateReport(String prompt) {
    if (prompt.trim().isEmpty) return;
    ref.read(aiReportProvider.notifier).generateReport(prompt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(aiReportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Report Generator'),
        actions: [
          if (state.currentReport != null) ...[
            IconButton(
              icon: const Icon(LucideIcons.edit3),
              tooltip: 'Edit Report',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit mode activated (Mock)')));
              },
            ),
            IconButton(
              icon: const Icon(LucideIcons.fileText),
              tooltip: 'Export PDF',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting to PDF (Mock)')));
              },
            ),
            IconButton(
              icon: const Icon(LucideIcons.fileSpreadsheet),
              tooltip: 'Export Excel',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting to Excel (Mock)')));
              },
            ),
            IconButton(
              icon: const Icon(LucideIcons.save),
              tooltip: 'Save Report',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report saved (Mock)')));
              },
            ),
          ]
        ],
      ),
      body: Row(
        children: [
          // Prompt & History Sidebar (Visible on desktop/tablet)
          if (ResponsiveBreakpoints.of(context).largerThan(MOBILE))
            Container(
              width: 300,
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: theme.dividerColor)),
                color: theme.colorScheme.surface,
              ),
              child: _buildPromptPanel(theme, state),
            ),
          
          // Main Content Area
          Expanded(
            child: state.isGenerating
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 24),
                        Text('Analyzing data and generating report...'),
                      ],
                    ),
                  )
                : state.currentReport != null
                    ? _buildReportView(theme, state.currentReport!)
                    : _buildEmptyState(theme, state),
          ),
        ],
      ),
      // FAB for mobile to open prompt
      floatingActionButton: ResponsiveBreakpoints.of(context).equals(MOBILE) && !state.isGenerating
          ? FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: _buildPromptPanel(theme, state),
                    ),
                  ),
                );
              },
              icon: const Icon(LucideIcons.sparkles),
              label: const Text('Generate'),
            )
          : null,
    );
  }

  Widget _buildPromptPanel(ThemeData theme, AIReportState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('What kind of report do you need?', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: _promptController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'e.g., Generate a monthly tenant activity report with workflow statistics...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                ),
                onSubmitted: _generateReport,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: state.isGenerating ? null : () => _generateReport(_promptController.text),
                icon: const Icon(LucideIcons.sparkles, size: 18),
                label: const Text('Generate Report'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Example Requests', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: state.history.length,
            itemBuilder: (context, index) {
              final prompt = state.history[index];
              return ListTile(
                leading: const Icon(LucideIcons.messageSquare, size: 16),
                title: Text(prompt, style: theme.textTheme.bodyMedium),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                onTap: () {
                  _promptController.text = prompt;
                  _generateReport(prompt);
                  if (ResponsiveBreakpoints.of(context).equals(MOBILE)) {
                    Navigator.pop(context); // Close bottom sheet if on mobile
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme, AIReportState state) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.fileBarChart2, size: 64, color: theme.colorScheme.primary),
            ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 32),
            Text(
              'AI Report Generator',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 16),
            Text(
              'Describe the data you want to analyze and let our AI instantly generate a comprehensive, interactive report.',
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 600.ms),
            
            if (state.error != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.alertCircle, color: theme.colorScheme.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.error!,
                        style: TextStyle(color: theme.colorScheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildReportView(ThemeData theme, AIReport report) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.title, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Generated from: "${report.prompt}"', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic)),
              ],
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),
          ),
        ),
        
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final section = report.sections[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: _buildReportSection(theme, section)
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: 200 + (index * 100)))
                    .slideY(begin: 0.1, end: 0),
                );
              },
              childCount: report.sections.length,
            ),
          ),
        ),
        
        const SliverPadding(padding: EdgeInsets.only(bottom: 64)),
      ],
    );
  }

  Widget _buildReportSection(ThemeData theme, AIReportSection section) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(section.title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            if (section.type == 'kpi' && section.kpis != null)
              _buildKpiGrid(theme, section.kpis!),
            if (section.type == 'chart' && section.chartData != null)
              _buildChartMock(theme, section.chartData!),
            if (section.type == 'table' && section.tableColumns != null && section.tableData != null)
              _buildTableMock(theme, section.tableColumns!, section.tableData!),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiGrid(ThemeData theme, List<AIReportKpi> kpis) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 800 ? 4 : (constraints.maxWidth > 500 ? 2 : 1);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 2.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: kpis.length,
          itemBuilder: (context, index) {
            final kpi = kpis[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(kpi.label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(kpi.value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: kpi.isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(kpi.isPositive ? LucideIcons.trendingUp : LucideIcons.trendingDown, size: 12, color: kpi.isPositive ? Colors.green : Colors.red),
                            const SizedBox(width: 4),
                            Text(kpi.trend, style: theme.textTheme.labelSmall?.copyWith(color: kpi.isPositive ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }
    );
  }

  Widget _buildChartMock(ThemeData theme, List<AIReportChartData> data) {
    // Simple bar chart mock using containers
    double maxValue = data.fold(0.0, (max, e) => e.value > max ? e.value : max);
    if (maxValue == 0) maxValue = 1;

    return SizedBox(
      height: 250,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: data.map((d) {
          final heightFactor = d.value / maxValue;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('${d.value.toInt()}', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 180 * heightFactor,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.8),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ),
              const SizedBox(height: 8),
              Text(d.label, style: theme.textTheme.labelMedium),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTableMock(ThemeData theme, List<AIReportTableColumn> columns, List<Map<String, dynamic>> data) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
          columns: columns.map((c) => DataColumn(label: Text(c.label))).toList(),
          rows: data.map((row) {
            return DataRow(
              cells: columns.map((c) {
                final val = row[c.key]?.toString() ?? '';
                // Add some basic styling for status badges
                if (c.key == 'status') {
                  return DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(val).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(val, style: theme.textTheme.labelSmall?.copyWith(color: _getStatusColor(val), fontWeight: FontWeight.bold)),
                    ),
                  );
                }
                return DataCell(Text(val));
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'in progress': return Colors.blue;
      default: return Colors.grey;
    }
  }
}
