import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../domain/models/broadcast_campaign_model.dart';
import 'providers/broadcast_campaign_provider.dart';

class CampaignBuilderScreen extends ConsumerStatefulWidget {
  const CampaignBuilderScreen({super.key});

  @override
  ConsumerState<CampaignBuilderScreen> createState() => _CampaignBuilderScreenState();
}

class _CampaignBuilderScreenState extends ConsumerState<CampaignBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();

  String _selectedType = 'Announcement';
  String _selectedPriority = 'Normal';
  String _selectedChannel = 'Email';
  
  final List<String> _selectedAudiences = [];
  final _availableAudiences = ['Platform Users', 'Tenant Users', 'Organization Users', 'Role Based', 'Department Based'];

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendCampaign(bool isDraft) {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAudiences.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one target audience.')));
      return;
    }

    final campaign = BroadcastCampaign(
      id: 'CMP_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      type: _selectedType,
      audience: List.from(_selectedAudiences),
      channel: _selectedChannel,
      status: isDraft ? 'Draft' : 'Sent',
      priority: _selectedPriority,
      message: _messageController.text,
      recipients: isDraft ? 0 : 450,
      delivered: 0,
      opened: 0,
      failed: 0,
      createdAt: DateTime.now(),
    );

    ref.read(broadcastCampaignProvider.notifier).addCampaign(campaign);
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isDraft ? 'Campaign saved as draft.' : 'Campaign broadcasted successfully!')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Campaign Builder'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => _sendCampaign(true),
            child: const Text('Save Draft'),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8, bottom: 8),
            child: FilledButton.icon(
              onPressed: () => _sendCampaign(false),
              icon: const Icon(LucideIcons.send, size: 16),
              label: const Text('Send Now'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard(
                theme: theme,
                title: 'Basic Information',
                icon: LucideIcons.info,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration(theme, 'Campaign Name'),
                      validator: (v) => v == null || v.isEmpty ? 'Required field' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedType,
                            decoration: _inputDecoration(theme, 'Campaign Type'),
                            items: ['Announcement', 'Maintenance', 'Reminder', 'Marketing', 'Emergency', 'System Update']
                                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedType = v!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedPriority,
                            decoration: _inputDecoration(theme, 'Priority'),
                            items: ['Low', 'Normal', 'High', 'Critical']
                                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedPriority = v!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionCard(
                theme: theme,
                title: 'Audience Targeting',
                icon: LucideIcons.users,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select Target Groups', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableAudiences.map((audience) {
                        final isSelected = _selectedAudiences.contains(audience);
                        return FilterChip(
                          label: Text(audience),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) _selectedAudiences.add(audience);
                              else _selectedAudiences.remove(audience);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionCard(
                theme: theme,
                title: 'Message Content',
                icon: LucideIcons.fileText,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedChannel,
                      decoration: _inputDecoration(theme, 'Delivery Channel'),
                      items: ['Email', 'SMS', 'Push', 'WhatsApp', 'In-App']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedChannel = v!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _messageController,
                      maxLines: 8,
                      decoration: _inputDecoration(theme, 'Broadcast Message').copyWith(
                        hintText: 'Type your message here... You can use {{UserName}} variables.',
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Required field' : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required ThemeData theme, required String title, required IconData icon, required Widget child}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.colorScheme.outlineVariant)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 32),
            child,
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(ThemeData theme, String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    );
  }
}
