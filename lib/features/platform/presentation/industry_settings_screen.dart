import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'industry_pack_details_screen.dart';

class IndustrySettingsScreen extends ConsumerStatefulWidget {
  final String packId;
  const IndustrySettingsScreen({super.key, required this.packId});

  @override
  ConsumerState<IndustrySettingsScreen> createState() => _IndustrySettingsScreenState();
}

class _IndustrySettingsScreenState extends ConsumerState<IndustrySettingsScreen> {
  int _selectedTabIndex = 0;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _tabs = [
    {'title': 'General', 'icon': LucideIcons.settings},
    {'title': 'Modules', 'icon': LucideIcons.blocks},
    {'title': 'Localization', 'icon': LucideIcons.globe},
    {'title': 'Workflow', 'icon': LucideIcons.gitBranch},
    {'title': 'Notifications', 'icon': LucideIcons.bell},
    {'title': 'AI', 'icon': LucideIcons.sparkles},
    {'title': 'Permissions', 'icon': LucideIcons.shield},
    {'title': 'Branding', 'icon': LucideIcons.palette},
    {'title': 'Storage', 'icon': LucideIcons.hardDrive},
    {'title': 'Reports', 'icon': LucideIcons.barChart3},
  ];

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 1)); // Mock save delay
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pack = ref.watch(industryPackDetailProvider(widget.packId));
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    if (pack == null) {
      return const Scaffold(body: Center(child: Text('Pack not found')));
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('${pack.name} Settings'),
        backgroundColor: theme.colorScheme.surface,
        scrolledUnderElevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _handleSave,
              icon: _isSaving 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(LucideIcons.save, size: 16),
              label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
              style: FilledButton.styleFrom(
                backgroundColor: pack.themeColor,
              ),
            ),
          )
        ],
      ),
      body: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSidebar(theme, pack),
                const VerticalDivider(width: 1),
                Expanded(child: _buildContentArea(theme, pack)),
              ],
            )
          : Column(
              children: [
                _buildHorizontalTabs(theme, pack),
                const Divider(height: 1),
                Expanded(child: _buildContentArea(theme, pack)),
              ],
            ),
    );
  }

  Widget _buildSidebar(ThemeData theme, IndustryPackDetail pack) {
    return Container(
      width: 250,
      color: theme.colorScheme.surface,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final tab = _tabs[index];
          final isSelected = _selectedTabIndex == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: InkWell(
              onTap: () => setState(() => _selectedTabIndex = index),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? pack.themeColor.withValues(alpha: 0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      size: 20,
                      color: isSelected ? pack.themeColor : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      tab['title'] as String,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? pack.themeColor : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalTabs(ThemeData theme, IndustryPackDetail pack) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final tab = _tabs[index];
          final isSelected = _selectedTabIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(tab['title'] as String),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedTabIndex = index),
              selectedColor: pack.themeColor.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? pack.themeColor : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContentArea(ThemeData theme, IndustryPackDetail pack) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: ListView(
        padding: const EdgeInsets.all(32),
        children: [
          Text(
            _tabs[_selectedTabIndex]['title'] as String,
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildCurrentTabContent(theme, pack),
        ],
      ),
    );
  }

  Widget _buildCurrentTabContent(ThemeData theme, IndustryPackDetail pack) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildGeneralTab(theme, pack);
      case 1:
        return _buildGenericTab(theme, pack, 'Modules Configuration', 'Enable and configure installed modules for this environment.');
      case 2:
        return _buildGenericTab(theme, pack, 'Localization Settings', 'Configure date formats, timezone, and default currencies.');
      case 3:
        return _buildGenericTab(theme, pack, 'Workflow Engine', 'Configure automated triggers and approval rules.');
      case 4:
        return _buildNotificationsTab(theme, pack);
      case 5:
        return _buildAITab(theme, pack);
      case 6:
        return _buildGenericTab(theme, pack, 'Role Permissions', 'Define what different user roles can access within this pack.');
      case 7:
        return _buildGenericTab(theme, pack, 'Theme & Branding', 'Override default colors, logos, and UI density.');
      case 8:
        return _buildGenericTab(theme, pack, 'Data Storage', 'Manage backup schedules and data retention policies.');
      case 9:
        return _buildGenericTab(theme, pack, 'Reporting Engines', 'Configure analytics data sources and export formats.');
      default:
        return const SizedBox();
    }
  }

  Widget _buildGeneralTab(ThemeData theme, IndustryPackDetail pack) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          theme,
          'Environment details',
          [
            _buildTextField(theme, 'Environment Name', defaultValue: '${pack.name} Production'),
            const SizedBox(height: 16),
            _buildTextField(theme, 'Admin Contact Email', defaultValue: 'admin@coreaxis.com'),
            const SizedBox(height: 16),
            _buildDropdownField(theme, 'Default Startup Screen', ['Dashboard', 'CRM', 'Reports', 'Inventory'], 'Dashboard'),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionCard(
          theme,
          'Maintenance Mode',
          [
            _buildSwitchTile(theme, 'Enable Maintenance Mode', 'Restrict access to administrators only while upgrading.', false, pack.themeColor),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationsTab(ThemeData theme, IndustryPackDetail pack) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          theme,
          'Delivery Channels',
          [
            _buildSwitchTile(theme, 'In-App Notifications', 'Show a badge and popup in the top bar.', true, pack.themeColor),
            const Divider(),
            _buildSwitchTile(theme, 'Email Digests', 'Send a daily summary of system activity.', false, pack.themeColor),
            const Divider(),
            _buildSwitchTile(theme, 'SMS Alerts', 'Critical system warnings only.', true, pack.themeColor),
          ],
        ),
      ],
    );
  }

  Widget _buildAITab(ThemeData theme, IndustryPackDetail pack) {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          theme,
          'AI Copilot',
          [
            _buildSwitchTile(theme, 'Enable AI Assistant', 'Allow users to query data using natural language.', true, pack.themeColor),
            const SizedBox(height: 16),
            _buildDropdownField(theme, 'Default Intelligence Model', ['GPT-4 Turbo', 'Claude 3 Opus', 'Llama 3 70B'], 'GPT-4 Turbo'),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionCard(
          theme,
          'Data Privacy',
          [
             _buildSwitchTile(theme, 'Anonymize User Data', 'Strip PII before sending context to AI models.', true, pack.themeColor),
          ]
        )
      ],
    );
  }

  Widget _buildGenericTab(ThemeData theme, IndustryPackDetail pack, String title, String description) {
    return _buildSectionCard(
      theme,
      title,
      [
        Text(description, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.dividerColor, style: BorderStyle.solid),
          ),
          alignment: Alignment.center,
          child: Column(
            children: [
              Icon(LucideIcons.construction, size: 48, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text('Configuration panel under construction', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSectionCard(ThemeData theme, String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(ThemeData theme, String label, {String? defaultValue}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: defaultValue,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(ThemeData theme, String label, List<String> options, String selected) {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selected,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: (val) {},
        ),
      ],
    );
  }

  Widget _buildSwitchTile(ThemeData theme, String title, String subtitle, bool initialValue, Color activeColor) {
    return StatefulBuilder(
      builder: (context, setState) {
        return SwitchListTile(
          value: initialValue,
          onChanged: (val) => setState(() => initialValue = val),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          activeThumbColor: activeColor,
          contentPadding: EdgeInsets.zero,
        );
      }
    );
  }
}
