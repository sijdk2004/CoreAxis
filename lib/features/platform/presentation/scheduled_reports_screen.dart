import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../domain/scheduled_report_model.dart';
import 'providers/scheduled_reports_provider.dart';

class ScheduledReportsScreen extends ConsumerWidget {
  const ScheduledReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(scheduledReportsProvider);
    final notifier = ref.read(scheduledReportsProvider.notifier);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, theme),
          const Divider(height: 1),
          _buildToolbar(context, theme, state, notifier),
          const Divider(height: 1),
          Expanded(
            child: _buildTable(context, theme, state, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scheduled Reports',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Automatically schedule and distribute reports to your team.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, ThemeData theme, ScheduledReportsState state, ScheduledReportsNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        children: [
          SizedBox(
            width: 300,
            child: TextField(
              onChanged: (value) => notifier.setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search schedules...',
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          _buildFilterChip(theme, state, notifier, 'All', 'all'),
          const SizedBox(width: 8),
          _buildFilterChip(theme, state, notifier, 'Active', 'active'),
          const SizedBox(width: 8),
          _buildFilterChip(theme, state, notifier, 'Paused', 'paused'),
          const SizedBox(width: 8),
          _buildFilterChip(theme, state, notifier, 'Failed', 'failed'),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => _showScheduleWizard(context, notifier),
            icon: const Icon(LucideIcons.calendarPlus, size: 16),
            label: const Text('Create Schedule'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(ThemeData theme, ScheduledReportsState state, ScheduledReportsNotifier notifier, String label, String filterValue) {
    final isSelected = state.filter == filterValue;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => notifier.setFilter(filterValue),
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primary.withAlpha(25),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
        ),
      ),
    );
  }

  Widget _buildTable(BuildContext context, ThemeData theme, ScheduledReportsState state, ScheduledReportsNotifier notifier) {
    final schedules = state.filteredSchedules;

    if (schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.calendarClock, size: 64, color: theme.dividerColor),
            const SizedBox(height: 16),
            Text('No schedules found', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('Create a new schedule or adjust your filters.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(theme.colorScheme.surface),
            dividerThickness: 1,
            dataRowMaxHeight: 64,
            columns: const [
              DataColumn(label: Text('Schedule', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Report', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Frequency', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Recipients', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Format', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Last Run', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Next Run', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: schedules.map((schedule) {
              return DataRow(
                cells: [
                  DataCell(
                    Row(
                      children: [
                        Icon(LucideIcons.calendar, size: 20, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(schedule.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        Icon(LucideIcons.fileText, size: 16, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text(schedule.reportName, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  DataCell(Text(_capitalize(schedule.frequency.name))),
                  DataCell(
                    Tooltip(
                      message: schedule.recipients.join('\n'),
                      child: Row(
                        children: [
                          Icon(LucideIcons.users, size: 16, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Text('${schedule.recipients.length} recipients'),
                        ],
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        schedule.exportFormat.name.toUpperCase(),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataCell(Text(schedule.lastRun != null ? DateFormat('MMM dd, yyyy HH:mm').format(schedule.lastRun!) : 'Never')),
                  DataCell(Text(DateFormat('MMM dd, yyyy HH:mm').format(schedule.nextRun))),
                  DataCell(_buildStatusBadge(theme, schedule.status)),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            schedule.status == ScheduleStatus.active ? LucideIcons.pauseCircle : LucideIcons.playCircle,
                            size: 18,
                          ),
                          tooltip: schedule.status == ScheduleStatus.active ? 'Pause' : 'Resume',
                          onPressed: () => notifier.toggleScheduleStatus(schedule.id),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.red),
                          tooltip: 'Delete',
                          onPressed: () => notifier.deleteSchedule(schedule.id),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme, ScheduleStatus status) {
    Color color;
    String text;

    switch (status) {
      case ScheduleStatus.active:
        color = Colors.green;
        text = 'Active';
        break;
      case ScheduleStatus.paused:
        color = Colors.orange;
        text = 'Paused';
        break;
      case ScheduleStatus.failed:
        color = Colors.red;
        text = 'Failed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _capitalize(String s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '';

  void _showScheduleWizard(BuildContext context, ScheduledReportsNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => _ScheduleWizardDialog(notifier: notifier),
    );
  }
}

class _ScheduleWizardDialog extends StatefulWidget {
  final ScheduledReportsNotifier notifier;

  const _ScheduleWizardDialog({required this.notifier});

  @override
  State<_ScheduleWizardDialog> createState() => _ScheduleWizardDialogState();
}

class _ScheduleWizardDialogState extends State<_ScheduleWizardDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _reportNameController = TextEditingController();
  final _recipientsController = TextEditingController();

  ScheduleFrequency _frequency = ScheduleFrequency.weekly;
  ExportFormat _exportFormat = ExportFormat.pdf;
  final Set<DeliveryMethod> _deliveryMethods = {DeliveryMethod.email};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Create Schedule'),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Schedule Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _reportNameController,
                  decoration: const InputDecoration(
                    labelText: 'Report Source Name',
                    border: OutlineInputBorder(),
                    helperText: 'Mock input for the report to be sent.',
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),
                Text('Frequency', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  children: ScheduleFrequency.values.map((freq) {
                    return ChoiceChip(
                      label: Text(freq.name.toUpperCase()),
                      selected: _frequency == freq,
                      onSelected: (selected) {
                        if (selected) setState(() => _frequency = freq);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Text('Recipients (Comma separated emails)', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _recipientsController,
                  decoration: const InputDecoration(
                    hintText: 'e.g., team@example.com, hr@example.com',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),
                Text('Delivery Method', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  children: DeliveryMethod.values.map((method) {
                    final isSelected = _deliveryMethods.contains(method);
                    return FilterChip(
                      label: Text(method.name.toUpperCase()),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _deliveryMethods.add(method);
                          } else {
                            if (_deliveryMethods.length > 1) {
                              _deliveryMethods.remove(method);
                            }
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Text('Export Format', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                DropdownButtonFormField<ExportFormat>(
                  initialValue: _exportFormat,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: ExportFormat.values.map((format) {
                    return DropdownMenuItem(
                      value: format,
                      child: Text(format.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _exportFormat = value);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final recipients = _recipientsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
              widget.notifier.createNewSchedule(
                name: _nameController.text,
                reportName: _reportNameController.text,
                frequency: _frequency,
                recipients: recipients,
                deliveryMethods: _deliveryMethods.toList(),
                exportFormat: _exportFormat,
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _reportNameController.dispose();
    _recipientsController.dispose();
    super.dispose();
  }
}
