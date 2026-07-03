import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DemoResetCenterScreen extends ConsumerStatefulWidget {
  const DemoResetCenterScreen({super.key});

  @override
  ConsumerState<DemoResetCenterScreen> createState() => _DemoResetCenterScreenState();
}

class _DemoResetCenterScreenState extends ConsumerState<DemoResetCenterScreen> {
  final List<_ResetOption> _options = [
    _ResetOption(title: 'Reset Users', description: 'Removes all created users and restores default admins.', icon: LucideIcons.users, color: Colors.blue),
    _ResetOption(title: 'Reset Reports', description: 'Deletes all custom reports and scheduled tasks.', icon: LucideIcons.barChart2, color: Colors.green),
    _ResetOption(title: 'Reset Workflows', description: 'Clears all execution history and custom workflows.', icon: LucideIcons.workflow, color: Colors.orange),
    _ResetOption(title: 'Reset Notifications', description: 'Purges all notification history and custom templates.', icon: LucideIcons.bell, color: Colors.amber),
    _ResetOption(title: 'Reset Documents', description: 'Deletes all uploaded mock files and folder structures.', icon: LucideIcons.fileText, color: Colors.indigo),
    _ResetOption(title: 'Reset AI History', description: 'Clears all AI chat logs, prompt history, and cached insights.', icon: LucideIcons.bot, color: Colors.purple),
  ];

  Future<void> _handleReset(String title, {bool isEverything = false}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.alertTriangle, color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 8),
            const Text('Confirm Reset'),
          ],
        ),
        content: Text(
          isEverything
              ? 'Are you absolutely sure you want to reset EVERYTHING to the factory demo state? This action cannot be undone.'
              : 'Are you sure you want to $title? This will wipe associated mock data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes, Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Show mock progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 24),
              Text('Resetting in progress...'),
            ],
          ),
        ),
      );

      // Simulate network/db delay
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.of(context).pop(); // Close progress dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(LucideIcons.checkCircle2, color: Colors.white),
                const SizedBox(width: 12),
                Text('$title completed successfully.'),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Demo Reset Center'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWarningHeader(theme),
            const SizedBox(height: 48),
            Text(
              'Individual Resets',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildOptionsGrid(theme, isDesktop),
            const SizedBox(height: 48),
            _buildResetEverythingSection(theme),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.error),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.alertOctagon, color: theme.colorScheme.error, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Caution: Destructive Actions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The tools below are designed to purge mock data and restore the platform to a pristine demonstration state. These actions are immediate and irreversible.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildOptionsGrid(ThemeData theme, bool isDesktop) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 1,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: isDesktop ? 1.5 : 2.0,
      ),
      itemCount: _options.length,
      itemBuilder: (context, index) {
        final option = _options[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: option.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(option.icon, color: option.color, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        option.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Text(
                    option.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () => _handleReset(option.title),
                    child: const Text('Reset'),
                  ),
                ),
              ],
            ),
          ),
        ).animate(delay: (100 * index).ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildResetEverythingSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.power, color: theme.colorScheme.error, size: 40),
          ),
          const SizedBox(height: 24),
          Text(
            'Reset Everything',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Purge all generated data across all modules and restore the factory demo state.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            ),
            onPressed: () => _handleReset('Reset Everything', isEverything: true),
            icon: const Icon(LucideIcons.refreshCw),
            label: const Text('RESET EVERYTHING NOW'),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }
}

class _ResetOption {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  _ResetOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
