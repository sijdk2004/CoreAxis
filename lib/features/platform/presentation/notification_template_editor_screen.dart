import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../domain/models/notification_template_model.dart';
import 'providers/notification_template_provider.dart';

class NotificationTemplateEditorScreen extends ConsumerStatefulWidget {
  final String templateId;

  const NotificationTemplateEditorScreen({super.key, required this.templateId});

  @override
  ConsumerState<NotificationTemplateEditorScreen> createState() => _NotificationTemplateEditorScreenState();
}

class _NotificationTemplateEditorScreenState extends ConsumerState<NotificationTemplateEditorScreen> {
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _subjectController;
  late TextEditingController _bodyController;

  String _selectedChannel = 'Email';
  String _selectedCategory = 'Workflow';
  String _selectedStatus = 'Draft';

  final List<String> _variables = [
    '{{UserName}}',
    '{{WorkflowName}}',
    '{{ApprovalStatus}}',
    '{{TenantName}}',
    '{{Organization}}',
    '{{CurrentDate}}'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _codeController = TextEditingController();
    _subjectController = TextEditingController();
    _bodyController = TextEditingController();

    // Defer initialization to after first build to read provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.templateId != 'new') {
        final state = ref.read(notificationTemplateProvider);
        try {
          final template = state.templates.firstWhere((t) => t.id == widget.templateId);
          setState(() {
            _nameController.text = template.name;
            _codeController.text = template.code;
            _subjectController.text = template.subject;
            _bodyController.text = template.body;
            _selectedChannel = template.channel;
            _selectedCategory = template.category;
            _selectedStatus = template.status;
          });
        } catch (e) {
          // Template not found
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Template not found.')));
          context.go('/platform/notifications/templates');
        }
      }
    });

    _bodyController.addListener(() => setState(() {}));
    _subjectController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _insertVariable(String variable) {
    final text = _bodyController.text;
    final selection = _bodyController.selection;
    
    if (selection.start >= 0) {
      final newText = text.replaceRange(selection.start, selection.end, variable);
      _bodyController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + variable.length),
      );
    } else {
      _bodyController.text = text + variable;
      _bodyController.selection = TextSelection.collapsed(offset: _bodyController.text.length);
    }
  }

  void _saveTemplate() {
    final notifier = ref.read(notificationTemplateProvider.notifier);
    
    final template = NotificationTemplate(
      id: widget.templateId == 'new' ? 'TPL_${DateTime.now().millisecondsSinceEpoch}' : widget.templateId,
      name: _nameController.text.isEmpty ? 'Untitled Template' : _nameController.text,
      code: _codeController.text.isEmpty ? 'TEMP_${DateTime.now().millisecondsSinceEpoch}' : _codeController.text,
      channel: _selectedChannel,
      language: 'en',
      category: _selectedCategory,
      status: _selectedStatus,
      subject: _subjectController.text,
      body: _bodyController.text,
      updatedAt: DateTime.now(),
    );

    if (widget.templateId == 'new') {
      notifier.addTemplate(template);
    } else {
      notifier.updateTemplate(template);
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Template saved successfully.')));
    context.go('/platform/notifications/templates');
  }

  String _renderPreview(String text) {
    return text
        .replaceAll('{{UserName}}', 'John Doe')
        .replaceAll('{{WorkflowName}}', 'Q3 Financial Review')
        .replaceAll('{{ApprovalStatus}}', 'Pending')
        .replaceAll('{{TenantName}}', 'Acme Corp')
        .replaceAll('{{Organization}}', 'Acme Corp HQ')
        .replaceAll('{{CurrentDate}}', DateFormat('MMMM dd, yyyy').format(DateTime.now()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(widget.templateId == 'new' ? 'Create Template' : 'Edit Template', style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go('/platform/notifications/templates'),
        ),
        actions: [
          TextButton(
            onPressed: () => context.go('/platform/notifications/templates'),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: _saveTemplate,
            icon: const Icon(LucideIcons.save, size: 16),
            label: const Text('Save Template'),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 900;

          if (isDesktop) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildEditor(theme)),
                Container(width: 1, color: theme.colorScheme.outlineVariant),
                Expanded(flex: 2, child: _buildPreview(theme)),
              ],
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildEditor(theme),
                  const Divider(height: 1),
                  SizedBox(
                    height: 500, // Fixed height for preview on mobile/tablet
                    child: _buildPreview(theme),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildEditor(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Basic Information', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField('Template Name', _nameController, 'e.g., Welcome Email'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField('Template Code', _codeController, 'e.g., WLCM_001'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdown('Category', _selectedCategory, ['Workflow', 'Approval', 'Sales', 'Inventory', 'Finance', 'Production', 'System', 'AI'], (v) => setState(() => _selectedCategory = v!)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown('Channel', _selectedChannel, ['Email', 'SMS', 'Push', 'WhatsApp'], (v) => setState(() => _selectedChannel = v!)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown('Status', _selectedStatus, ['Draft', 'Active', 'Inactive'], (v) => setState(() => _selectedStatus = v!)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text('Message Content', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_selectedChannel == 'Email') ...[
            _buildTextField('Subject', _subjectController, 'Email Subject Line'),
            const SizedBox(height: 16),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Message Body', style: theme.textTheme.labelLarge),
              TextButton.icon(
                onPressed: () {
                  // Mock generate AI text
                  _bodyController.text = 'Dear {{UserName}},\n\nThis is an AI generated draft for {{WorkflowName}}.\n\nBest regards,\n{{TenantName}}';
                },
                icon: const Icon(LucideIcons.sparkles, size: 14),
                label: const Text('Generate with AI'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _bodyController,
            maxLines: 15,
            decoration: InputDecoration(
              hintText: 'Enter your message here...',
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.colorScheme.outlineVariant)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.colorScheme.outlineVariant)),
            ),
            style: const TextStyle(fontFamily: 'monospace'),
          ),
          const SizedBox(height: 24),
          Text('Available Variables', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _variables.map((v) => ActionChip(
              label: Text(v, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
              onPressed: () => _insertVariable(v),
              avatar: const Icon(LucideIcons.plus, size: 14),
              backgroundColor: theme.colorScheme.surfaceVariant,
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            color: theme.colorScheme.surface,
            width: double.infinity,
            child: Row(
              children: [
                Icon(LucideIcons.eye, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Live Preview', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedChannel == 'Email') ...[
                      Row(
                        children: [
                          const Text('Subject: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                          Expanded(child: Text(_subjectController.text.isEmpty ? 'No Subject' : _renderPreview(_subjectController.text))),
                        ],
                      ),
                      const Divider(height: 32),
                    ],
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          _bodyController.text.isEmpty ? 'Message body will appear here...' : _renderPreview(_bodyController.text),
                          style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: theme.colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.colorScheme.outlineVariant)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.colorScheme.outlineVariant)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
            color: theme.colorScheme.surface,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              icon: const Icon(LucideIcons.chevronDown, size: 16),
              style: theme.textTheme.bodyMedium,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
