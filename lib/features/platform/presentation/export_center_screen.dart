import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:intl/intl.dart';

import 'providers/export_center_provider.dart';
import '../domain/export_center_model.dart';

class ExportCenterScreen extends ConsumerStatefulWidget {
  const ExportCenterScreen({super.key});

  @override
  ConsumerState<ExportCenterScreen> createState() => _ExportCenterScreenState();
}

class _ExportCenterScreenState extends ConsumerState<ExportCenterScreen> {
  String _searchQuery = '';
  String _selectedStatus = 'All';
  int _rowsPerPage = 10;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(exportCenterProvider);
    final isDesktop = ResponsiveBreakpoints.of(context).largerOrEqualTo(DESKTOP);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Export Center', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Manage report exports.', style: theme.textTheme.bodyMedium),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.refreshCw, size: 18),
                  label: const Text('Refresh'),
                ),
              ],
            ).animate().fade().slideY(begin: -0.2),
            const SizedBox(height: 24),

            // Statistics Cards
            Flex(
              direction: isDesktop ? Axis.horizontal : Axis.vertical,
              children: [
                Expanded(
                  flex: isDesktop ? 1 : 0,
                  child: _buildStatCard(context, 'Exports Today', state.statistics.exportsToday.toString(), LucideIcons.downloadCloud, Colors.blue),
                ),
                if (isDesktop) const SizedBox(width: 16),
                if (!isDesktop) const SizedBox(height: 16),
                Expanded(
                  flex: isDesktop ? 1 : 0,
                  child: _buildStatCard(context, 'Average Time', '${state.statistics.averageTimeMs}ms', LucideIcons.clock, Colors.orange),
                ),
                if (isDesktop) const SizedBox(width: 16),
                if (!isDesktop) const SizedBox(height: 16),
                Expanded(
                  flex: isDesktop ? 1 : 0,
                  child: _buildStatCard(context, 'Failures', state.statistics.failures.toString(), LucideIcons.alertTriangle, Colors.red),
                ),
              ],
            ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
            const SizedBox(height: 24),

            // Main Content Area
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  // Toolbar (Search & Filter)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(
                          width: 300,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search exports...',
                              prefixIcon: const Icon(LucideIcons.search, size: 18),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onChanged: (val) => setState(() => _searchQuery = val),
                          ),
                        ),
                        DropdownMenu<String>(
                          initialSelection: _selectedStatus,
                          onSelected: (val) {
                            if (val != null) setState(() => _selectedStatus = val);
                          },
                          dropdownMenuEntries: const [
                            DropdownMenuEntry(value: 'All', label: 'All Statuses'),
                            DropdownMenuEntry(value: 'Completed', label: 'Completed'),
                            DropdownMenuEntry(value: 'Processing', label: 'Processing'),
                            DropdownMenuEntry(value: 'Scheduled', label: 'Scheduled'),
                            DropdownMenuEntry(value: 'Failed', label: 'Failed'),
                          ],
                        ),
                        DropdownMenu<int>(
                          initialSelection: _rowsPerPage,
                          label: const Text('Rows per page'),
                          onSelected: (val) {
                            if (val != null) setState(() => _rowsPerPage = val);
                          },
                          dropdownMenuEntries: const [
                            DropdownMenuEntry(value: 5, label: '5'),
                            DropdownMenuEntry(value: 10, label: '10'),
                            DropdownMenuEntry(value: 20, label: '20'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Table
                  SizedBox(
                    width: double.infinity,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
                        columns: const [
                          DataColumn(label: Text('Report')),
                          DataColumn(label: Text('Requested By')),
                          DataColumn(label: Text('Requested At')),
                          DataColumn(label: Text('Format')),
                          DataColumn(label: Text('Size')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: _buildRows(state.tasks),
                      ),
                    ),
                  ),

                  // Pagination Footer
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Page ${_currentPage + 1}'),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(LucideIcons.chevronLeft),
                          onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.chevronRight),
                          onPressed: () => setState(() => _currentPage++), // Mock pagination next
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: theme.textTheme.titleMedium?.copyWith(color: theme.textTheme.bodySmall?.color)),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  List<DataRow> _buildRows(List<ExportTask> tasks) {
    var filteredTasks = tasks.where((t) {
      final matchesSearch = t.reportName.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                            t.id.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _selectedStatus == 'All' || t.status == _selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();

    // Mock pagination
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage < filteredTasks.length) ? startIndex + _rowsPerPage : filteredTasks.length;
    if (startIndex < filteredTasks.length) {
      filteredTasks = filteredTasks.sublist(startIndex, endIndex);
    } else {
      filteredTasks = [];
    }

    return filteredTasks.map((task) {
      return DataRow(
        cells: [
          DataCell(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(task.reportName, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(task.id, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          )),
          DataCell(Text(task.requestedBy)),
          DataCell(Text(DateFormat('MMM dd, yyyy HH:mm').format(task.requestedAt))),
          DataCell(_buildFormatBadge(task.format)),
          DataCell(Text(task.size)),
          DataCell(_buildStatusBadge(task.status)),
          DataCell(Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (task.status == 'Completed')
                IconButton(
                  icon: const Icon(LucideIcons.download, size: 18),
                  tooltip: 'Download',
                  onPressed: () {},
                ),
              if (task.status == 'Failed' || task.status == 'Completed')
                IconButton(
                  icon: const Icon(LucideIcons.refreshCcw, size: 18),
                  tooltip: 'Retry',
                  onPressed: () {
                    ref.read(exportCenterProvider.notifier).retryTask(task.id);
                  },
                ),
              IconButton(
                icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.red),
                tooltip: 'Delete',
                onPressed: () {
                  ref.read(exportCenterProvider.notifier).deleteTask(task.id);
                },
              ),
            ],
          )),
        ],
      );
    }).toList();
  }

  Widget _buildFormatBadge(String format) {
    Color bgColor;
    Color textColor;

    switch (format.toLowerCase()) {
      case 'pdf':
        bgColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        break;
      case 'excel':
        bgColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
        break;
      case 'csv':
        bgColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue;
        break;
      case 'powerpoint':
        bgColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        break;
      case 'json':
      default:
        bgColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(format, style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'completed':
        bgColor = Colors.teal.withValues(alpha: 0.1);
        textColor = Colors.teal;
        break;
      case 'failed':
        bgColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        break;
      case 'scheduled':
        bgColor = Colors.purple.withValues(alpha: 0.1);
        textColor = Colors.purple;
        break;
      case 'processing':
        bgColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue;
        break;
      default:
        bgColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status.toLowerCase() == 'processing') ...[
            SizedBox(
              width: 10, 
              height: 10, 
              child: CircularProgressIndicator(strokeWidth: 2, color: textColor)
            ),
            const SizedBox(width: 6),
          ],
          Text(status, style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
