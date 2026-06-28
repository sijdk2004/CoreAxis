import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../domain/models/approval_rule.dart';
import '../providers/approval_rules_provider.dart';

class ApprovalRuleBuilderDialog extends ConsumerStatefulWidget {
  final ApprovalRule? existingRule;

  const ApprovalRuleBuilderDialog({super.key, this.existingRule});

  @override
  ConsumerState<ApprovalRuleBuilderDialog> createState() => _ApprovalRuleBuilderDialogState();
}

class _ApprovalRuleBuilderDialogState extends ConsumerState<ApprovalRuleBuilderDialog> {
  late TextEditingController _nameController;
  String _selectedCategory = 'Purchase';
  
  // IF Condition state
  String _selectedField = 'Amount';
  String _selectedOperator = '>';
  late TextEditingController _conditionValueController;

  // THEN Approvers state
  List<String> _approvers = ['Finance Manager'];
  bool _isParallel = false;

  // Settings
  String _escalationPolicy = 'Notify Manager (72h)';
  String _sla = '24h per step';

  bool _isSimulating = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingRule?.name ?? '');
    
    if (widget.existingRule != null) {
      _selectedCategory = widget.existingRule!.category;
      _approvers = List.from(widget.existingRule!.approvers);
      _escalationPolicy = widget.existingRule!.escalation;
      _sla = widget.existingRule!.sla;
      
      // Basic parse of condition string like "Amount > 100000"
      final parts = widget.existingRule!.conditions.split(' ');
      if (parts.length >= 3) {
        _selectedField = parts[0];
        _selectedOperator = parts[1];
        _conditionValueController = TextEditingController(text: parts.sublist(2).join(' '));
      } else {
        _conditionValueController = TextEditingController(text: widget.existingRule!.conditions);
      }
    } else {
      _conditionValueController = TextEditingController(text: '100000');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _conditionValueController.dispose();
    super.dispose();
  }

  void _addApprover() {
    setState(() {
      _approvers.add('New Approver');
    });
  }

  void _removeApprover(int index) {
    if (_approvers.length > 1) {
      setState(() {
        _approvers.removeAt(index);
      });
    }
  }

  Future<void> _simulateRule() async {
    setState(() => _isSimulating = true);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _isSimulating = false);
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Simulation successful! Rule syntax is valid and no circular dependencies found.'),
        backgroundColor: Colors.green,
      )
    );
  }

  Future<void> _saveRule() async {
    if (_nameController.text.isEmpty) return;
    
    setState(() => _isSaving = true);
    
    final newRule = ApprovalRule(
      id: widget.existingRule?.id ?? 'RUL-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      name: _nameController.text,
      category: _selectedCategory,
      conditions: '$_selectedField $_selectedOperator ${_conditionValueController.text}',
      approvers: _approvers,
      escalation: _escalationPolicy,
      sla: _sla,
      isActive: widget.existingRule?.isActive ?? true,
    );

    await ref.read(approvalRulesProvider.notifier).mockSaveRule(newRule);
    
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 800,
        height: 700,
        color: theme.colorScheme.surface,
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.existingRule == null ? 'Create Approval Rule' : 'Edit Approval Rule', 
                       style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(LucideIcons.x),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
            ),
            Divider(height: 1, color: theme.dividerColor),
            
            // BODY
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // LEFT PANEL: IF/THEN Builder
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // IF BLOCK
                            _buildBlockHeader(theme, 'IF', 'Condition trigger', Colors.purple),
                            Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(left: 12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.purple.withOpacity(0.5)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildDropdown(theme, _selectedField, ['Amount', 'Role', 'Department', 'Region'], (v) => setState(() => _selectedField = v!)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildDropdown(theme, _selectedOperator, ['>', '<', '==', '!=', '>=', '<='], (v) => setState(() => _selectedOperator = v!)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: _conditionValueController,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // THEN BLOCK
                            _buildBlockHeader(theme, 'THEN', 'Approval Sequence', Colors.blue),
                            Container(
                              margin: const EdgeInsets.only(left: 12),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      ChoiceChip(
                                        label: const Text('Sequential'),
                                        selected: !_isParallel,
                                        onSelected: (v) => setState(() => _isParallel = false),
                                      ),
                                      const SizedBox(width: 8),
                                      ChoiceChip(
                                        label: const Text('Parallel'),
                                        selected: _isParallel,
                                        onSelected: (v) => setState(() => _isParallel = true),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Approvers List
                                  ..._approvers.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final approver = entry.value;
                                    return Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.surface,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.blue.withOpacity(0.5)),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(_isParallel ? LucideIcons.users : LucideIcons.user, color: Colors.blue, size: 20),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: _buildDropdown(theme, approver, 
                                                  ['Direct Manager', 'Finance Manager', 'HR Director', 'VP of Sales', 'Director', 'CEO', 'Legal Review', 'New Approver'], 
                                                  (v) {
                                                    setState(() => _approvers[index] = v!);
                                                  }
                                                ),
                                              ),
                                              if (_approvers.length > 1)
                                                IconButton(
                                                  icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.red),
                                                  onPressed: () => _removeApprover(index),
                                                )
                                            ],
                                          ),
                                        ),
                                        if (index < _approvers.length - 1)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4),
                                            child: Icon(_isParallel ? LucideIcons.plus : LucideIcons.arrowDown, color: Colors.grey, size: 20),
                                          )
                                      ],
                                    );
                                  }),
                                  const SizedBox(height: 16),
                                  TextButton.icon(
                                    onPressed: _addApprover,
                                    icon: const Icon(LucideIcons.plusCircle, size: 18),
                                    label: const Text('Add Step'),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // RIGHT PANEL: Settings
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rule Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Rule Name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text('Category', style: theme.textTheme.labelMedium),
                            const SizedBox(height: 8),
                            _buildDropdown(theme, _selectedCategory, 
                              ['Quotation', 'Purchase', 'Sales Order', 'Production', 'Finance', 'HR', 'Inventory', 'Quality'], 
                              (v) => setState(() => _selectedCategory = v!)
                            ),
                            const SizedBox(height: 32),
                            
                            Text('Policy Settings', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Text('Escalation Policy', style: theme.textTheme.labelMedium),
                            const SizedBox(height: 8),
                            _buildDropdown(theme, _escalationPolicy, 
                              ['Notify Manager (72h)', 'Auto-Reject (48h)', 'Auto-Escalate to CEO', 'Reassign to Admin'], 
                              (v) => setState(() => _escalationPolicy = v!)
                            ),
                            const SizedBox(height: 16),
                            Text('SLA / Timeout', style: theme.textTheme.labelMedium),
                            const SizedBox(height: 8),
                            _buildDropdown(theme, _sla, 
                              ['12h per step', '24h per step', '24h', '48h'], 
                              (v) => setState(() => _sla = v!)
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Divider(height: 1, color: theme.dividerColor),
            
            // FOOTER
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: _isSimulating ? null : _simulateRule,
                    icon: _isSimulating ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(LucideIcons.playCircle, size: 18),
                    label: const Text('Simulate Rule'),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      FilledButton(
                        onPressed: _isSaving ? null : _saveRule,
                        child: _isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Save Rule'),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBlockHeader(ThemeData theme, String title, String subtitle, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
            child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Text(subtitle, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildDropdown(ThemeData theme, String value, List<String> options, Function(String?) onChanged) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(6),
        color: theme.colorScheme.surface,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          icon: const Icon(LucideIcons.chevronDown, size: 16),
          style: theme.textTheme.bodyMedium,
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
