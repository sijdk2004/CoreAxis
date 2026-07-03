import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'providers/ai_settings_provider.dart';

class AiSettingsScreen extends ConsumerWidget {
  const AiSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(aiSettingsProvider);
    final notifier = ref.read(aiSettingsProvider.notifier);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, theme, state, notifier),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDesktop) _buildSidebar(context, theme, state, notifier),
                if (isDesktop) VerticalDivider(width: 1, color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: _buildContent(context, theme, state, notifier),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, AiSettingsState state, AiSettingsNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.settings, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Settings',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Configure platform-wide AI behavior and limits',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          FilledButton.icon(
            onPressed: state.isSaving ? null : () async {
              await notifier.saveSettings();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings saved successfully')),
                );
              }
            },
            icon: state.isSaving 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(LucideIcons.save, size: 18),
            label: Text(state.isSaving ? 'Saving...' : 'Save Changes'),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, ThemeData theme, AiSettingsState state, AiSettingsNotifier notifier) {
    final tabs = [
      {'title': 'General', 'icon': LucideIcons.sliders},
      {'title': 'Privacy', 'icon': LucideIcons.shieldAlert},
      {'title': 'Security', 'icon': LucideIcons.lock},
      {'title': 'Providers', 'icon': LucideIcons.cpu},
      {'title': 'Prompt Defaults', 'icon': LucideIcons.terminalSquare},
      {'title': 'Usage Limits', 'icon': LucideIcons.activity},
      {'title': 'Logging', 'icon': LucideIcons.fileText},
    ];

    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: ListView.builder(
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isSelected = state.activeTab == tab['title'];
          return ListTile(
            leading: Icon(tab['icon'] as IconData, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
            title: Text(
              tab['title'] as String,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              ),
            ),
            selected: isSelected,
            selectedTileColor: theme.colorScheme.primaryContainer.withOpacity(0.5),
            onTap: () => notifier.setActiveTab(tab['title'] as String),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme, AiSettingsState state, AiSettingsNotifier notifier) {
    switch (state.activeTab) {
      case 'General':
        return _buildGeneralTab(context, theme, state, notifier);
      case 'Privacy':
        return _buildPrivacyTab(context, theme, state, notifier);
      case 'Usage Limits':
        return _buildUsageLimitsTab(context, theme, state, notifier);
      case 'Logging':
        return _buildLoggingTab(context, theme, state, notifier);
      default:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(64.0),
            child: Column(
              children: [
                Icon(LucideIcons.hammer, size: 48, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text('${state.activeTab} settings coming soon', style: theme.textTheme.titleMedium),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildGeneralTab(BuildContext context, ThemeData theme, AiSettingsState state, AiSettingsNotifier notifier) {
    final settings = state.settings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme, 'Core Settings'),
        _buildSwitchListTile(
          title: 'Enable AI Platform-Wide',
          subtitle: 'Turns off all AI features across the ERP when disabled.',
          value: settings.enableAi,
          onChanged: (val) => notifier.updateSettings(settings.copyWith(enableAi: val)),
        ),
        _buildSwitchListTile(
          title: 'Allow File Analysis',
          subtitle: 'Permit AI to read and analyze uploaded documents and spreadsheets.',
          value: settings.allowFileAnalysis,
          onChanged: (val) => notifier.updateSettings(settings.copyWith(allowFileAnalysis: val)),
        ),
        _buildSwitchListTile(
          title: 'Allow Report Generation',
          subtitle: 'Enable automated generation of business reports using AI.',
          value: settings.allowReportGeneration,
          onChanged: (val) => notifier.updateSettings(settings.copyWith(allowReportGeneration: val)),
        ),
        const SizedBox(height: 32),
        _buildSectionTitle(theme, 'Defaults'),
        _buildDropdownSetting(
          title: 'Default Model',
          subtitle: 'The fallback model used when a specific agent does not dictate one.',
          value: settings.defaultModel,
          items: ['GPT-4 Turbo', 'Claude 3 Opus', 'Gemini 1.5 Pro', 'Azure GPT-3.5'],
          onChanged: (val) => notifier.updateSettings(settings.copyWith(defaultModel: val)),
        ),
      ],
    );
  }

  Widget _buildPrivacyTab(BuildContext context, ThemeData theme, AiSettingsState state, AiSettingsNotifier notifier) {
    final settings = state.settings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme, 'Data Privacy'),
        _buildSwitchListTile(
          title: 'Anonymize PII Data',
          subtitle: 'Automatically scrub personally identifiable information before sending to external AI providers.',
          value: settings.anonymizeData,
          onChanged: (val) => notifier.updateSettings(settings.copyWith(anonymizeData: val)),
        ),
        _buildDropdownSetting(
          title: 'Conversation Retention',
          subtitle: 'How long to store AI conversation histories before auto-deletion.',
          value: settings.conversationRetention,
          items: ['30 Days', '90 Days', '1 Year', 'Forever'],
          onChanged: (val) => notifier.updateSettings(settings.copyWith(conversationRetention: val)),
        ),
      ],
    );
  }

  Widget _buildUsageLimitsTab(BuildContext context, ThemeData theme, AiSettingsState state, AiSettingsNotifier notifier) {
    final settings = state.settings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme, 'Quota Management'),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Max Daily Requests (Organization)', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('Hard limit on total AI requests per day.'),
          trailing: SizedBox(
            width: 150,
            child: TextFormField(
              initialValue: settings.maxDailyRequests.toString(),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                final num = int.tryParse(val);
                if (num != null) {
                  notifier.updateSettings(settings.copyWith(maxDailyRequests: num));
                }
              },
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildLoggingTab(BuildContext context, ThemeData theme, AiSettingsState state, AiSettingsNotifier notifier) {
    final settings = state.settings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme, 'Audit & Logging'),
        _buildSwitchListTile(
          title: 'Audit AI Usage',
          subtitle: 'Keep an immutable ledger of all AI interactions for compliance.',
          value: settings.auditAiUsage,
          onChanged: (val) => notifier.updateSettings(settings.copyWith(auditAiUsage: val)),
        ),
        _buildDropdownSetting(
          title: 'Logging Level',
          subtitle: 'Determines the verbosity of AI system logs.',
          value: settings.loggingLevel,
          items: ['Minimal', 'Detailed', 'Debug'],
          onChanged: (val) => notifier.updateSettings(settings.copyWith(loggingLevel: val)),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchListTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownSetting({
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }
}
