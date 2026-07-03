import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'models/accessibility_settings_model.dart';
import 'providers/accessibility_provider.dart';

class AccessibilityCenterScreen extends ConsumerWidget {
  const AccessibilityCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final accessibilityState = ref.watch(accessibilityProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Accessibility Center'),
        centerTitle: false,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Settings Area
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, theme, accessibilityState),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 24),
                  _buildVisualSettings(context, theme, ref, accessibilityState),
                  const SizedBox(height: 32),
                  _buildNavigationSettings(context, theme, ref, accessibilityState),
                  const SizedBox(height: 32),
                  _buildColorBlindSettings(context, theme, ref, accessibilityState),
                ],
              ),
            ),
          ),
          
          // Preview & Checklist Sidebar
          if (isDesktop)
            Container(
              width: 380,
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: theme.dividerColor)),
                color: theme.colorScheme.surfaceContainerLowest,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Live Preview', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildPreviewCard(context, theme, accessibilityState),
                    const SizedBox(height: 48),
                    Text('WCAG 2.1 Checklist', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildWcagChecklist(theme, accessibilityState),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, AccessibilitySettingsModel state) {
    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: state.calculateScore / 100,
                strokeWidth: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                color: _getScoreColor(state.calculateScore),
              ),
            ),
            Column(
              children: [
                Text(
                  '${state.calculateScore}',
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '/ 100',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(width: 32),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Accessibility Score',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Enable features below to improve your platform experience. We aim for WCAG 2.1 AA compliance across all CoreAxis modules.',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVisualSettings(BuildContext context, ThemeData theme, WidgetRef ref, AccessibilitySettingsModel state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Visual Preferences', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildSwitchTile(
          title: 'High Contrast Mode',
          subtitle: 'Increases contrast between text and background colors.',
          icon: LucideIcons.contrast,
          value: state.highContrast,
          onChanged: (val) => ref.read(accessibilityProvider.notifier).toggleHighContrast(val),
        ),
        _buildSwitchTile(
          title: 'Large Fonts',
          subtitle: 'Scales up all typography by 125% globally.',
          icon: LucideIcons.type,
          value: state.largeFonts,
          onChanged: (val) => ref.read(accessibilityProvider.notifier).toggleLargeFonts(val),
        ),
        _buildSwitchTile(
          title: 'Reduced Motion',
          subtitle: 'Disables all non-essential UI animations and transitions.',
          icon: LucideIcons.playCircle,
          value: state.reducedMotion,
          onChanged: (val) => ref.read(accessibilityProvider.notifier).toggleReducedMotion(val),
        ),
      ],
    );
  }

  Widget _buildNavigationSettings(BuildContext context, ThemeData theme, WidgetRef ref, AccessibilitySettingsModel state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Navigation & Feedback', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildSwitchTile(
          title: 'Screen Reader Labels',
          subtitle: 'Forces explicit semantic labels on all interactive elements.',
          icon: LucideIcons.ear,
          value: state.screenReaderLabels,
          onChanged: (val) => ref.read(accessibilityProvider.notifier).toggleScreenReaderLabels(val),
        ),
        _buildSwitchTile(
          title: 'Keyboard Navigation Paths',
          subtitle: 'Optimizes tab-indexing for form-heavy modules.',
          icon: LucideIcons.keyboard,
          value: state.keyboardNavigation,
          onChanged: (val) => ref.read(accessibilityProvider.notifier).toggleKeyboardNavigation(val),
        ),
        _buildSwitchTile(
          title: 'Enhanced Focus Indicators',
          subtitle: 'Shows a thick, highly visible outline around focused elements.',
          icon: LucideIcons.focus,
          value: state.focusIndicators,
          onChanged: (val) => ref.read(accessibilityProvider.notifier).toggleFocusIndicators(val),
        ),
      ],
    );
  }

  Widget _buildColorBlindSettings(BuildContext context, ThemeData theme, WidgetRef ref, AccessibilitySettingsModel state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Color Vision Deficiency', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildRadioTile(
                title: 'None (Default)',
                value: ColorBlindMode.none,
                groupValue: state.colorBlindMode,
                onChanged: (val) => ref.read(accessibilityProvider.notifier).setColorBlindMode(val!),
              ),
              _buildRadioTile(
                title: 'Protanopia (Red-Blind)',
                value: ColorBlindMode.protanopia,
                groupValue: state.colorBlindMode,
                onChanged: (val) => ref.read(accessibilityProvider.notifier).setColorBlindMode(val!),
              ),
              _buildRadioTile(
                title: 'Deuteranopia (Green-Blind)',
                value: ColorBlindMode.deuteranopia,
                groupValue: state.colorBlindMode,
                onChanged: (val) => ref.read(accessibilityProvider.notifier).setColorBlindMode(val!),
              ),
              _buildRadioTile(
                title: 'Tritanopia (Blue-Blind)',
                value: ColorBlindMode.tritanopia,
                groupValue: state.colorBlindMode,
                onChanged: (val) => ref.read(accessibilityProvider.notifier).setColorBlindMode(val!),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        secondary: Icon(icon),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildRadioTile({
    required String title,
    required ColorBlindMode value,
    required ColorBlindMode groupValue,
    required ValueChanged<ColorBlindMode?> onChanged,
  }) {
    return RadioListTile<ColorBlindMode>(
      title: Text(title),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }

  Widget _buildPreviewCard(BuildContext context, ThemeData theme, AccessibilitySettingsModel state) {
    // Dynamic styles based on mock settings
    final bgColor = state.highContrast ? Colors.black : theme.colorScheme.surfaceContainerHighest;
    final textColor = state.highContrast ? Colors.white : theme.colorScheme.onSurface;
    final borderColor = state.focusIndicators ? Colors.blueAccent : Colors.transparent;
    final borderWidth = state.focusIndicators ? 3.0 : 0.0;
    
    // Simulate color blind mode shifts on a mock chart bar
    Color mockChartColor = Colors.green;
    if (state.colorBlindMode == ColorBlindMode.protanopia || state.colorBlindMode == ColorBlindMode.deuteranopia) {
      mockChartColor = Colors.orange; // Simulated shift
    } else if (state.colorBlindMode == ColorBlindMode.tritanopia) {
      mockChartColor = Colors.teal; // Simulated shift
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Q3 Revenue Forecast',
            style: TextStyle(
              fontSize: state.largeFonts ? 22 : 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(width: 40, height: 60, color: mockChartColor),
              const SizedBox(width: 8),
              Container(width: 40, height: 100, color: mockChartColor.withValues(alpha: 0.7)),
              const SizedBox(width: 8),
              Container(width: 40, height: 80, color: mockChartColor.withValues(alpha: 0.5)),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: state.highContrast ? Colors.white : theme.colorScheme.primary,
              foregroundColor: state.highContrast ? Colors.black : theme.colorScheme.onPrimary,
            ),
            child: Text(state.screenReaderLabels ? 'View detailed Q3 report (Button)' : 'View Report'),
          )
        ],
      ),
    );
  }

  Widget _buildWcagChecklist(ThemeData theme, AccessibilitySettingsModel state) {
    return Column(
      children: [
        _checklistRow(theme, '1.4.3 Contrast (Minimum)', state.highContrast),
        _checklistRow(theme, '1.4.4 Resize text', state.largeFonts),
        _checklistRow(theme, '2.3.3 Animation from Interactions', state.reducedMotion),
        _checklistRow(theme, '2.4.7 Focus Visible', state.focusIndicators),
        _checklistRow(theme, '2.1.1 Keyboard', state.keyboardNavigation),
        _checklistRow(theme, '3.3.2 Labels or Instructions', state.screenReaderLabels),
        _checklistRow(theme, '1.4.1 Use of Color', state.colorBlindMode != ColorBlindMode.none),
      ],
    );
  }

  Widget _checklistRow(ThemeData theme, String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isMet ? LucideIcons.checkCircle : LucideIcons.circle,
            color: isMet ? Colors.green : theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isMet ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
                decoration: isMet ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}
