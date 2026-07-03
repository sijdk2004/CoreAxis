import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../domain/models/delegation_record.dart';
import 'providers/delegation_provider.dart';

class DelegationScreen extends ConsumerStatefulWidget {
  const DelegationScreen({super.key});

  @override
  ConsumerState<DelegationScreen> createState() => _DelegationScreenState();
}

class _DelegationScreenState extends ConsumerState<DelegationScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(delegationProvider);
    final notifier = ref.read(delegationProvider.notifier);
    final records = notifier.filteredRecords;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delegation Management', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Manage and configure approval authority delegations.', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 32),
            
            _buildToolbar(context, theme, state, notifier),
            const SizedBox(height: 24),
            
            _buildTableView(context, theme, records, notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, ThemeData theme, DelegationState state, DelegationNotifier notifier) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () => _showCreateDelegationDialog(context, notifier),
          icon: const Icon(LucideIcons.plus),
          label: const Text('Create Delegation'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
        SizedBox(
          width: 300,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search delegator or delegate...',
              prefixIcon: const Icon(LucideIcons.search, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
            onChanged: notifier.setSearchQuery,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              hint: const Text('Status Filter'),
              value: state.statusFilter,
              icon: const Icon(LucideIcons.chevronDown, size: 16),
              items: ['All', 'Active', 'Scheduled', 'Expired', 'Revoked']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: notifier.setStatusFilter,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableView(BuildContext context, ThemeData theme, List<DelegationRecord> records, DelegationNotifier notifier) {
    if (records.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(64.0),
          child: Column(
            children: [
              Icon(LucideIcons.users, size: 48, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text('No delegations found', style: theme.textTheme.titleMedium),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: constraints.maxWidth > 1000 ? constraints.maxWidth : 1000,
              child: DataTable(
                headingTextStyle: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                columnSpacing: 24,
                columns: const [
                  DataColumn(label: Text('Delegator')),
                  DataColumn(label: Text('Delegate')),
                  DataColumn(label: Text('From Date')),
                  DataColumn(label: Text('To Date')),
                  DataColumn(label: Text('Reason')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: records.map((r) => DataRow(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                            child: Text(r.delegator[0], style: TextStyle(fontSize: 12, color: theme.colorScheme.primary)),
                          ),
                          const SizedBox(width: 8),
                          Text(r.delegator, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      )
                    ),
                    DataCell(
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.teal.withOpacity(0.2),
                            child: Text(r.delegate[0], style: const TextStyle(fontSize: 12, color: Colors.teal)),
                          ),
                          const SizedBox(width: 8),
                          Text(r.delegate),
                        ],
                      )
                    ),
                    DataCell(Text(DateFormat('MMM dd, yyyy').format(r.fromDate))),
                    DataCell(Text(DateFormat('MMM dd, yyyy').format(r.toDate))),
                    DataCell(SizedBox(width: 150, child: Text(r.reason, maxLines: 1, overflow: TextOverflow.ellipsis))),
                    DataCell(_buildStatusBadge(r.status, theme)),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(LucideIcons.edit, size: 18),
                            onPressed: () {},
                            tooltip: 'Edit Delegation',
                          ),
                          if (r.status == 'Active' || r.status == 'Scheduled')
                            IconButton(
                              icon: Icon(LucideIcons.xOctagon, size: 18, color: theme.colorScheme.error),
                              onPressed: () => notifier.revokeDelegation(r.id),
                              tooltip: 'Revoke',
                            ),
                        ],
                      ),
                    ),
                  ],
                )).toList(),
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildStatusBadge(String status, ThemeData theme) {
    Color bgColor;
    Color fgColor;
    
    switch (status) {
      case 'Active': bgColor = Colors.green.withOpacity(0.1); fgColor = Colors.green.shade700; break;
      case 'Scheduled': bgColor = Colors.blue.withOpacity(0.1); fgColor = Colors.blue.shade700; break;
      case 'Expired': bgColor = Colors.grey.withOpacity(0.1); fgColor = Colors.grey.shade700; break;
      case 'Revoked': bgColor = Colors.red.withOpacity(0.1); fgColor = Colors.red.shade700; break;
      default: bgColor = theme.colorScheme.surfaceVariant; fgColor = theme.colorScheme.onSurface;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: theme.textTheme.labelSmall?.copyWith(color: fgColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showCreateDelegationDialog(BuildContext context, DelegationNotifier notifier) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CreateDelegationDialog(notifier: notifier),
    );
  }
}

class _CreateDelegationDialog extends StatefulWidget {
  final DelegationNotifier notifier;

  const _CreateDelegationDialog({required this.notifier});

  @override
  State<_CreateDelegationDialog> createState() => _CreateDelegationDialogState();
}

class _CreateDelegationDialogState extends State<_CreateDelegationDialog> {
  final _formKey = GlobalKey<FormState>();
  String _delegator = 'John Doe';
  String? _delegate;
  DateTime? _fromDate;
  DateTime? _toDate;
  final TextEditingController _reasonController = TextEditingController();
  bool _autoExpire = true;
  bool _notifyEmail = true;
  final List<String> _approvalTypes = [];
  String? _conflictWarning;

  final List<String> _users = ['John Doe', 'Jane Smith', 'Sarah Williams', 'Mike Johnson', 'Robert Chen'];
  final List<String> _availableApprovalTypes = ['Purchase Orders', 'Leave Requests', 'Expense Reports', 'Contracts', 'Vendor Onboarding'];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _checkConflicts() {
    if (_fromDate != null && _toDate != null) {
      final hasConflict = widget.notifier.checkConflict(_delegator, _fromDate!, _toDate!);
      setState(() {
        if (hasConflict) {
          _conflictWarning = 'Warning: This date range overlaps with an existing active delegation for $_delegator.';
        } else {
          _conflictWarning = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 800),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Create Delegation', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(LucideIcons.x), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_conflictWarning != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            border: Border.all(color: Colors.amber),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.alertTriangle, color: Colors.amber),
                              const SizedBox(width: 12),
                              Expanded(child: Text(_conflictWarning!, style: TextStyle(color: Colors.amber.shade900))),
                            ],
                          ),
                        ),
                        
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(labelText: 'Delegator', border: OutlineInputBorder()),
                              value: _delegator,
                              items: _users.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (val) {
                                setState(() => _delegator = val!);
                                _checkConflicts();
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(labelText: 'Delegate To', border: OutlineInputBorder()),
                              value: _delegate,
                              items: _users.where((u) => u != _delegator).map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (val) => setState(() => _delegate = val),
                              validator: (val) => val == null ? 'Please select a delegate' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      Text('Duration', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (date != null) {
                                  setState(() => _fromDate = date);
                                  _checkConflicts();
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(labelText: 'From Date', border: OutlineInputBorder()),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_fromDate != null ? DateFormat('MMM dd, yyyy').format(_fromDate!) : 'Select date'),
                                    const Icon(LucideIcons.calendar, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _fromDate ?? DateTime.now(),
                                  firstDate: _fromDate ?? DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (date != null) {
                                  setState(() => _toDate = date);
                                  _checkConflicts();
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'To Date', 
                                  border: const OutlineInputBorder(),
                                  errorText: (_fromDate != null && _toDate != null && _toDate!.isBefore(_fromDate!)) 
                                      ? 'Must be after From Date' : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_toDate != null ? DateFormat('MMM dd, yyyy').format(_toDate!) : 'Select date'),
                                    const Icon(LucideIcons.calendar, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      Text('Approval Types', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _availableApprovalTypes.map((type) {
                          final isSelected = _approvalTypes.contains(type);
                          return FilterChip(
                            label: Text(type),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _approvalTypes.add(type);
                                } else {
                                  _approvalTypes.remove(type);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      
                      TextFormField(
                        controller: _reasonController,
                        decoration: const InputDecoration(
                          labelText: 'Reason',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., Annual Leave, Business Trip',
                        ),
                        validator: (val) => val == null || val.isEmpty ? 'Please enter a reason' : null,
                      ),
                      const SizedBox(height: 24),
                      
                      Text('Options', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      SwitchListTile(
                        title: const Text('Auto-Expire'),
                        subtitle: const Text('Automatically revoke delegation when To Date passes.'),
                        value: _autoExpire,
                        onChanged: (val) => setState(() => _autoExpire = val),
                        contentPadding: EdgeInsets.zero,
                      ),
                      SwitchListTile(
                        title: const Text('Email Notifications'),
                        subtitle: const Text('Notify delegate about pending approvals.'),
                        value: _notifyEmail,
                        onChanged: (val) => setState(() => _notifyEmail = val),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() && _fromDate != null && _toDate != null && _toDate!.isAfter(_fromDate!.subtract(const Duration(days: 1)))) {
                        final newDelegation = DelegationRecord(
                          id: 'DEL-${Random().nextInt(900) + 100}',
                          delegator: _delegator,
                          delegate: _delegate!,
                          fromDate: _fromDate!,
                          toDate: _toDate!,
                          reason: _reasonController.text,
                          status: _fromDate!.isAfter(DateTime.now()) ? 'Scheduled' : 'Active',
                          approvalTypes: _approvalTypes,
                          autoExpire: _autoExpire,
                          notifyEmail: _notifyEmail,
                        );
                        widget.notifier.addDelegation(newDelegation);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delegation created successfully')));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    child: const Text('Save Delegation'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
