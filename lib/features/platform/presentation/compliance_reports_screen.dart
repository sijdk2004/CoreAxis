import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../domain/compliance_reports_model.dart';
import 'providers/compliance_reports_provider.dart';

class ComplianceReportsScreen extends ConsumerStatefulWidget {
  const ComplianceReportsScreen({super.key});

  @override
  ConsumerState<ComplianceReportsScreen> createState() => _ComplianceReportsScreenState();
}

class _ComplianceReportsScreenState extends ConsumerState<ComplianceReportsScreen> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(complianceReportsProvider);
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (data) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, theme),
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      Container(
                        color: theme.colorScheme.surface,
                        child: TabBar(
                          onTap: (index) => setState(() => _currentTabIndex = index),
                          tabs: const [
                            Tab(text: 'Generate Report'),
                            Tab(text: 'Report History'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildGenerateReportTab(context, theme, data, isDesktop),
                            _buildHistoryTab(context, theme, data),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.fileSignature, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Compliance Reports', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Generate, schedule, and review compliance-ready audit reports', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateReportTab(BuildContext context, ThemeData theme, ComplianceReportsModel data, bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTemplatesSection(context, theme, data),
                  const SizedBox(height: 32),
                  _buildFiltersSection(context, theme, data),
                ],
              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: _buildPreviewSection(context, theme, data).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: 0.05),
            ),
          ),
        ],
      );
    } else {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTemplatesSection(context, theme, data),
            const SizedBox(height: 24),
            _buildFiltersSection(context, theme, data),
            const SizedBox(height: 24),
            _buildPreviewSection(context, theme, data),
          ],
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),
      );
    }
  }

  Widget _buildTemplatesSection(BuildContext context, ThemeData theme, ComplianceReportsModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Report Templates', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300,
            mainAxisExtent: 100,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: data.templates.length,
          itemBuilder: (context, index) {
            final template = data.templates[index];
            final isSelected = template.id == data.selectedTemplateId;
            return InkWell(
              onTap: () {
                ref.read(complianceReportsProvider.notifier).selectTemplate(template.id);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : theme.colorScheme.surface,
                  border: Border.all(
                    color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(template.icon, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(template.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: isSelected ? theme.colorScheme.primary : null)),
                          const SizedBox(height: 4),
                          Text(
                            template.standard,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFiltersSection(BuildContext context, ThemeData theme, ComplianceReportsModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Report Parameters', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField(theme, 'Organization', 'All Organizations'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdownField(theme, 'Department', 'All Departments'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField(theme, 'Module', 'All Modules'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date Range', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(LucideIcons.calendar),
                            label: Text(
                              '${DateFormat('MMM d, y').format(data.filterStartDate ?? DateTime.now())} - ${DateFormat('MMM d, y').format(data.filterEndDate ?? DateTime.now())}',
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                              alignment: Alignment.centerLeft,
                              minimumSize: const Size.fromHeight(50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(ThemeData theme, String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          hint: Text(hint),
          items: const [],
          onChanged: (value) {},
        ),
      ],
    );
  }

  Widget _buildPreviewSection(BuildContext context, ThemeData theme, ComplianceReportsModel data) {
    final template = data.templates.firstWhere((t) => t.id == data.selectedTemplateId, orElse: () => data.templates.first);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Preview & Generate', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report scheduled successfully')));
                  },
                  icon: const Icon(LucideIcons.calendarClock),
                  label: const Text('Schedule'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generating PDF Report...')));
                  },
                  icon: const Icon(LucideIcons.download),
                  label: const Text('Export PDF'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(template.icon, size: 64, color: theme.colorScheme.primary),
                const SizedBox(height: 24),
                Text(template.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Standard: ${template.standard}', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
                const SizedBox(height: 24),
                Text(template.description, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                _buildPreviewLine(theme, 'Parameters Included:', 'Date Range, Organization'),
                _buildPreviewLine(theme, 'Estimated Pages:', '~15-20 pages'),
                _buildPreviewLine(theme, 'Format Supported:', 'PDF, Excel, CSV'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewLine(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context, ThemeData theme, ComplianceReportsModel data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant),
                columns: const [
                  DataColumn(label: Text('Report ID')),
                  DataColumn(label: Text('Template')),
                  DataColumn(label: Text('Generated On')),
                  DataColumn(label: Text('Generated By')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: data.history.map((report) {
                  return DataRow(
                    cells: [
                      DataCell(Text(report.id, style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(report.templateName)),
                      DataCell(Text(DateFormat('MMM d, y HH:mm').format(report.generatedOn))),
                      DataCell(Text(report.generatedBy)),
                      DataCell(_buildStatusBadge(context, report.status)),
                      DataCell(
                        Row(
                          children: [
                            if (report.status == ReportStatus.completed)
                              IconButton(
                                icon: const Icon(LucideIcons.download, size: 20),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading report...')));
                                },
                                tooltip: 'Download',
                              ),
                            if (report.status == ReportStatus.scheduled)
                              IconButton(
                                icon: const Icon(LucideIcons.edit2, size: 20),
                                onPressed: () {},
                                tooltip: 'Edit Schedule',
                              ),
                            IconButton(
                              icon: const Icon(LucideIcons.trash2, size: 20, color: Colors.red),
                              onPressed: () {},
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),
    );
  }

  Widget _buildStatusBadge(BuildContext context, ReportStatus status) {
    Color color;
    String text;

    switch (status) {
      case ReportStatus.completed:
        color = Colors.green;
        text = 'Completed';
        break;
      case ReportStatus.failed:
        color = Colors.red;
        text = 'Failed';
        break;
      case ReportStatus.processing:
        color = Colors.orange;
        text = 'Processing';
        break;
      case ReportStatus.scheduled:
        color = Colors.blue;
        text = 'Scheduled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
