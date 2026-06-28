import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'providers/workflow_settings_provider.dart';

class WorkflowSettingsScreen extends ConsumerStatefulWidget {
  const WorkflowSettingsScreen({super.key});

  @override
  ConsumerState<WorkflowSettingsScreen> createState() => _WorkflowSettingsScreenState();
}

class _WorkflowSettingsScreenState extends ConsumerState<WorkflowSettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(workflowSettingsProvider);
    final notifier = ref.read(workflowSettingsProvider.notifier);
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    // Show a snackbar if saveSuccess is true
    ref.listen<WorkflowSettingsState>(workflowSettingsProvider, (previous, next) {
      if (!previous!.saveSuccess && next.saveSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: const Text('Workflow Settings'),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: FilledButton.icon(
              onPressed: state.isSaving ? null : () => notifier.saveSettings(),
              icon: state.isSaving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(LucideIcons.save, size: 18),
              label: Text(state.isSaving ? 'Saving...' : 'Save Settings'),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: !isDesktop,
          tabs: const [
            Tab(text: 'General'),
            Tab(text: 'Execution'),
            Tab(text: 'Notifications'),
            Tab(text: 'Escalations'),
            Tab(text: 'Versioning'),
            Tab(text: 'Security'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralTab(theme, state, notifier, isDesktop),
          _buildExecutionTab(theme, state, notifier, isDesktop),
          _buildNotificationsTab(theme, state, notifier, isDesktop),
          _buildEscalationsTab(theme, state, notifier, isDesktop),
          _buildVersioningTab(theme, state, notifier, isDesktop),
          _buildSecurityTab(theme, state, notifier, isDesktop),
        ],
      ),
    );
  }

  Widget _buildTabContainer(bool isDesktop, List<Widget> children) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 32 : 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0, top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(description, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildGeneralTab(ThemeData theme, WorkflowSettingsState state, WorkflowSettingsNotifier notifier, bool isDesktop) {
    return _buildTabContainer(isDesktop, [
      _buildSectionHeader(theme, 'General Settings', 'Configure default workflow behavior and business hours.'),
      _buildDropdown(theme, 'Default Timeout (Hours)', state.defaultTimeoutHours.toString(), ['12', '24', '48', '72', '168'], (val) {
        notifier.updateSetting(defaultTimeoutHours: int.parse(val!));
      }),
      _buildDropdown(theme, 'Business Calendar', state.businessCalendar, ['Standard 5-Day', '24/7 Operations', '4-Day Week'], (val) {
        notifier.updateSetting(businessCalendar: val);
      }),
      Row(
        children: [
          Expanded(
            child: _buildDropdown(theme, 'Working Hours Start', state.workingHoursStart, ['08:00', '09:00', '10:00'], (val) {
              notifier.updateSetting(workingHoursStart: val);
            }),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDropdown(theme, 'Working Hours End', state.workingHoursEnd, ['17:00', '18:00', '19:00'], (val) {
              notifier.updateSetting(workingHoursEnd: val);
            }),
          ),
        ],
      ),
    ]);
  }

  Widget _buildExecutionTab(ThemeData theme, WorkflowSettingsState state, WorkflowSettingsNotifier notifier, bool isDesktop) {
    return _buildTabContainer(isDesktop, [
      _buildSectionHeader(theme, 'Execution Settings', 'Control how workflow instances are processed by the engine.'),
      _buildSwitchTile(theme, 'Parallel Processing', 'Allow branches to execute concurrently', state.parallelProcessing, (val) {
        notifier.updateSetting(parallelProcessing: val);
      }),
      const SizedBox(height: 16),
      _buildDropdown(theme, 'Default Retry Count', state.retryCount.toString(), ['0', '1', '3', '5'], (val) {
        notifier.updateSetting(retryCount: int.parse(val!));
      }),
      _buildDropdown(theme, 'Queue Strategy', state.queueStrategy, ['FIFO', 'Priority-based', 'Round-robin'], (val) {
        notifier.updateSetting(queueStrategy: val);
      }),
    ]);
  }

  Widget _buildNotificationsTab(ThemeData theme, WorkflowSettingsState state, WorkflowSettingsNotifier notifier, bool isDesktop) {
    return _buildTabContainer(isDesktop, [
      _buildSectionHeader(theme, 'Notification Channels', 'Enable or disable global communication channels for workflows.'),
      _buildSwitchTile(theme, 'Email Notifications', 'Send updates via email', state.emailEnabled, (val) {
        notifier.updateSetting(emailEnabled: val);
      }),
      _buildSwitchTile(theme, 'Push Notifications', 'Send mobile and web push notifications', state.pushEnabled, (val) {
        notifier.updateSetting(pushEnabled: val);
      }),
      _buildSwitchTile(theme, 'SMS Notifications', 'Send critical alerts via SMS text', state.smsEnabled, (val) {
        notifier.updateSetting(smsEnabled: val);
      }),
      _buildSwitchTile(theme, 'WhatsApp Notifications', 'Send messages via WhatsApp Business API', state.whatsappEnabled, (val) {
        notifier.updateSetting(whatsappEnabled: val);
      }),
    ]);
  }

  Widget _buildEscalationsTab(ThemeData theme, WorkflowSettingsState state, WorkflowSettingsNotifier notifier, bool isDesktop) {
    return _buildTabContainer(isDesktop, [
      _buildSectionHeader(theme, 'Escalations & Reminders', 'Configure what happens when tasks are delayed.'),
      _buildDropdown(theme, 'Reminder Interval (Hours)', state.reminderIntervalHours.toString(), ['2', '4', '8', '24'], (val) {
        notifier.updateSetting(reminderIntervalHours: int.parse(val!));
      }),
      _buildDropdown(theme, 'Default Escalation Rule', state.defaultEscalationRule, ['Manager Review', 'Auto-Approve', 'Auto-Reject', 'Reassign to Admin'], (val) {
        notifier.updateSetting(defaultEscalationRule: val);
      }),
    ]);
  }

  Widget _buildVersioningTab(ThemeData theme, WorkflowSettingsState state, WorkflowSettingsNotifier notifier, bool isDesktop) {
    return _buildTabContainer(isDesktop, [
      _buildSectionHeader(theme, 'Versioning & Drafts', 'Manage workflow template versions and active drafts.'),
      _buildSwitchTile(theme, 'Auto-Version on Publish', 'Automatically increment version number when publishing changes', state.autoVersion, (val) {
        notifier.updateSetting(autoVersion: val);
      }),
      const SizedBox(height: 16),
      _buildDropdown(theme, 'Draft Handling', state.draftHandling, ['Keep indefinitely', 'Delete after 30 days', 'Delete after 90 days'], (val) {
        notifier.updateSetting(draftHandling: val);
      }),
    ]);
  }

  Widget _buildSecurityTab(ThemeData theme, WorkflowSettingsState state, WorkflowSettingsNotifier notifier, bool isDesktop) {
    return _buildTabContainer(isDesktop, [
      _buildSectionHeader(theme, 'Security & Compliance', 'Configure access control and audit trails.'),
      _buildSwitchTile(theme, 'Inherit Permissions', 'Workflows inherit permissions from parent folder/department', state.inheritPermissions, (val) {
        notifier.updateSetting(inheritPermissions: val);
      }),
      _buildSwitchTile(theme, 'Audit Logging', 'Maintain a detailed immutable log of all workflow actions', state.auditLogging, (val) {
        notifier.updateSetting(auditLogging: val);
      }),
    ]);
  }

  Widget _buildDropdown(ThemeData theme, String label, String value, List<String> options, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(8),
              color: theme.colorScheme.surface,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: value,
                icon: const Icon(LucideIcons.chevronDown, size: 20),
                style: theme.textTheme.bodyLarge,
                items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(ThemeData theme, String title, String subtitle, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
          color: theme.colorScheme.surface,
        ),
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          value: value,
          onChanged: onChanged,
          activeColor: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
