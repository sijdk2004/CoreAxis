import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'models/ux_preferences_model.dart';
import 'providers/ux_preferences_provider.dart';

class UxPreferencesScreen extends ConsumerStatefulWidget {
  const UxPreferencesScreen({super.key});

  @override
  ConsumerState<UxPreferencesScreen> createState() => _UxPreferencesScreenState();
}

class _UxPreferencesScreenState extends ConsumerState<UxPreferencesScreen> {
  int _selectedIndex = 0;
  
  final _appearanceKey = GlobalKey();
  final _layoutKey = GlobalKey();
  final _localizationKey = GlobalKey();
  final _systemKey = GlobalKey();

  void _scrollTo(int index, GlobalKey key) {
    setState(() => _selectedIndex = index);
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final prefs = ref.watch(uxPreferencesProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('User Experience Settings'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDesktop)
                  Container(
                    width: 250,
                    decoration: BoxDecoration(
                      border: Border(right: BorderSide(color: theme.dividerColor)),
                      color: theme.colorScheme.surfaceContainerLowest,
                    ),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      children: [
                        _buildNavTile(theme, 'Appearance', LucideIcons.palette, _selectedIndex == 0, () => _scrollTo(0, _appearanceKey)),
                        _buildNavTile(theme, 'Layout & Behavior', LucideIcons.layout, _selectedIndex == 1, () => _scrollTo(1, _layoutKey)),
                        _buildNavTile(theme, 'Localization', LucideIcons.globe, _selectedIndex == 2, () => _scrollTo(2, _localizationKey)),
                        _buildNavTile(theme, 'System & Accessibility', LucideIcons.settings, _selectedIndex == 3, () => _scrollTo(3, _systemKey)),
                      ],
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32.0),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(theme, 'Appearance', key: _appearanceKey),
                          _buildThemeSelector(theme, ref, prefs),
                          const SizedBox(height: 24),
                          _buildDropdownRow<DensityPreference>(
                            theme: theme,
                            title: 'UI Density',
                            subtitle: 'Control the compactness of lists and tables.',
                            value: prefs.density,
                            items: const [
                              DropdownMenuItem(value: DensityPreference.compact, child: Text('Compact')),
                              DropdownMenuItem(value: DensityPreference.comfortable, child: Text('Comfortable')),
                              DropdownMenuItem(value: DensityPreference.spacious, child: Text('Spacious')),
                            ],
                            onChanged: (val) => ref.read(uxPreferencesProvider.notifier).updateDensity(val!),
                          ),
                          const SizedBox(height: 48),

                          _buildSectionHeader(theme, 'Layout & Behavior', key: _layoutKey),
                          _buildDropdownRow<SidebarPreference>(
                            theme: theme,
                            title: 'Sidebar Default State',
                            subtitle: 'Choose how the main navigation appears on launch.',
                            value: prefs.sidebar,
                            items: const [
                              DropdownMenuItem(value: SidebarPreference.expanded, child: Text('Expanded (Default)')),
                              DropdownMenuItem(value: SidebarPreference.collapsed, child: Text('Collapsed (Icons only)')),
                              DropdownMenuItem(value: SidebarPreference.floating, child: Text('Floating (Auto-hide)')),
                            ],
                            onChanged: (val) => ref.read(uxPreferencesProvider.notifier).updateSidebar(val!),
                          ),
                          const SizedBox(height: 24),
                          _buildDropdownRow<DashboardLayoutPreference>(
                            theme: theme,
                            title: 'Dashboard Layout',
                            subtitle: 'Select the default widget arrangement for your dashboard.',
                            value: prefs.dashboardLayout,
                            items: const [
                              DropdownMenuItem(value: DashboardLayoutPreference.standard, child: Text('Standard')),
                              DropdownMenuItem(value: DashboardLayoutPreference.compact, child: Text('Compact Data View')),
                              DropdownMenuItem(value: DashboardLayoutPreference.analytical, child: Text('Analytical (Charts focused)')),
                            ],
                            onChanged: (val) => ref.read(uxPreferencesProvider.notifier).updateDashboardLayout(val!),
                          ),
                          const SizedBox(height: 48),

                          _buildSectionHeader(theme, 'Localization', key: _localizationKey),
                          _buildDropdownRow<String>(
                            theme: theme,
                            title: 'Platform Language',
                            subtitle: 'Change the primary display language.',
                            value: prefs.language,
                            items: const [
                              DropdownMenuItem(value: 'English (US)', child: Text('English (US)')),
                              DropdownMenuItem(value: 'English (UK)', child: Text('English (UK)')),
                              DropdownMenuItem(value: 'Spanish', child: Text('Spanish')),
                              DropdownMenuItem(value: 'French', child: Text('French')),
                            ],
                            onChanged: (val) => ref.read(uxPreferencesProvider.notifier).updateLanguage(val!),
                          ),
                          const SizedBox(height: 24),
                          _buildDropdownRow<String>(
                            theme: theme,
                            title: 'Date Format',
                            subtitle: 'Choose how dates are displayed across the platform.',
                            value: prefs.dateFormat,
                            items: const [
                              DropdownMenuItem(value: 'MM/DD/YYYY', child: Text('MM/DD/YYYY')),
                              DropdownMenuItem(value: 'DD/MM/YYYY', child: Text('DD/MM/YYYY')),
                              DropdownMenuItem(value: 'YYYY-MM-DD', child: Text('YYYY-MM-DD')),
                            ],
                            onChanged: (val) => ref.read(uxPreferencesProvider.notifier).updateDateFormat(val!),
                          ),
                          const SizedBox(height: 24),
                          _buildDropdownRow<String>(
                            theme: theme,
                            title: 'Time Zone',
                            subtitle: 'Your local time zone for scheduling and timestamps.',
                            value: prefs.timeZone,
                            items: const [
                              DropdownMenuItem(value: 'UTC -08:00 (Pacific Time)', child: Text('UTC -08:00 (Pacific Time)')),
                              DropdownMenuItem(value: 'UTC -05:00 (Eastern Time)', child: Text('UTC -05:00 (Eastern Time)')),
                              DropdownMenuItem(value: 'UTC +00:00 (GMT)', child: Text('UTC +00:00 (GMT)')),
                            ],
                            onChanged: (val) => ref.read(uxPreferencesProvider.notifier).updateTimeZone(val!),
                          ),
                          const SizedBox(height: 48),

                          _buildSectionHeader(theme, 'System & Accessibility', key: _systemKey),
                          _buildSwitchRow(
                            theme: theme,
                            title: 'UI Animations',
                            subtitle: 'Enable fluid transitions and motion graphics.',
                            value: prefs.animationsEnabled,
                            onChanged: (val) => ref.read(uxPreferencesProvider.notifier).toggleAnimations(val),
                          ),
                          const SizedBox(height: 16),
                          _buildSwitchRow(
                            theme: theme,
                            title: 'Toast Notifications',
                            subtitle: 'Show floating alerts for system events.',
                            value: prefs.notificationsEnabled,
                            onChanged: (val) => ref.read(uxPreferencesProvider.notifier).toggleNotifications(val),
                          ),
                          const SizedBox(height: 16),
                          _buildSwitchRow(
                            theme: theme,
                            title: 'High Contrast Mode',
                            subtitle: 'Increase visual distinction for text and borders.',
                            value: prefs.highContrast,
                            onChanged: (val) => ref.read(uxPreferencesProvider.notifier).toggleHighContrast(val),
                          ),
                          const SizedBox(height: 16),
                          _buildSwitchRow(
                            theme: theme,
                            title: 'Keyboard Shortcuts',
                            subtitle: 'Enable quick actions via keyboard combinations.',
                            value: prefs.enableShortcuts,
                            onChanged: (val) => ref.read(uxPreferencesProvider.notifier).toggleShortcuts(val),
                          ),
                          const SizedBox(height: 64),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildActionBar(context, theme, ref),
        ],
      ),
    );
  }

  Widget _buildNavTile(ThemeData theme, String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return Container(
      color: isSelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, {Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: 24.0, top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildThemeSelector(ThemeData theme, WidgetRef ref, UxPreferencesModel prefs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Theme Mode', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildThemeOption(theme, 'Light', LucideIcons.sun, ThemePreference.light, prefs.theme, ref),
            const SizedBox(width: 16),
            _buildThemeOption(theme, 'Dark', LucideIcons.moon, ThemePreference.dark, prefs.theme, ref),
            const SizedBox(width: 16),
            _buildThemeOption(theme, 'System', LucideIcons.laptop, ThemePreference.system, prefs.theme, ref),
          ],
        )
      ],
    );
  }

  Widget _buildThemeOption(ThemeData theme, String label, IconData icon, ThemePreference value, ThemePreference groupValue, WidgetRef ref) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => ref.read(uxPreferencesProvider.notifier).updateTheme(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5) : theme.colorScheme.surface,
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownRow<T>({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Container(
          width: 250,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(8),
            color: theme.colorScheme.surface,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchRow({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildActionBar(BuildContext context, ThemeData theme, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () {
              ref.read(uxPreferencesProvider.notifier).resetToDefaults();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preferences reset to default')));
            },
            child: const Text('Reset to Defaults'),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preferences saved successfully')));
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}
