import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:intl/intl.dart';

import 'models/demo_profile_model.dart';
import 'providers/demo_mode_provider.dart';

class DemoModeManagerScreen extends ConsumerWidget {
  const DemoModeManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(demoModeProvider);
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final isMobile = ResponsiveBreakpoints.of(context).equals(MOBILE);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Demo Mode Manager'),
        centerTitle: false,
        actions: [
          FilledButton.icon(
            onPressed: () => _showScenarioComparison(context, profiles),
            icon: const Icon(LucideIcons.gitCompare),
            label: const Text('Compare Scenarios'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select a demo profile to instantly reconfigure the platform.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            sliver: isDesktop || !isMobile
                ? SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop ? 3 : 2,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _DemoProfileCard(profile: profiles[index]);
                      },
                      childCount: profiles.length,
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _DemoProfileCard(profile: profiles[index]),
                        );
                      },
                      childCount: profiles.length,
                    ),
                  ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 48)),
        ],
      ),
    );
  }

  void _showScenarioComparison(BuildContext context, List<DemoProfileModel> profiles) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Scenario Comparison'),
          content: SizedBox(
            width: 800,
            height: 500,
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.surfaceContainerHighest),
                columns: const [
                  DataColumn(label: Text('Scenario')),
                  DataColumn(label: Text('Industry')),
                  DataColumn(label: Text('Data Size')),
                  DataColumn(label: Text('Status')),
                ],
                rows: profiles.map((p) {
                  return DataRow(
                    cells: [
                      DataCell(Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(p.industry)),
                      DataCell(Text(p.size)),
                      DataCell(
                        p.isActive
                            ? const Chip(
                                label: Text('Active'),
                                backgroundColor: Colors.green,
                                labelStyle: TextStyle(color: Colors.white, fontSize: 12),
                              )
                            : const Text('Inactive'),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            )
          ],
        );
      },
    );
  }
}

class _DemoProfileCard extends ConsumerWidget {
  final DemoProfileModel profile;

  const _DemoProfileCard({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: profile.isActive ? 8 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: profile.isActive ? theme.colorScheme.primary : theme.dividerColor,
          width: profile.isActive ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: profile.isActive
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    profile.icon,
                    color: profile.isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.industry,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (profile.isActive)
                  const Icon(LucideIcons.checkCircle2, color: Colors.green),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Text(
                profile.description,
                style: theme.textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(profile.size),
                  labelStyle: const TextStyle(fontSize: 12),
                  visualDensity: VisualDensity.compact,
                ),
                Chip(
                  label: Text('Last used: ${DateFormat.yMd().format(profile.lastActivated)}'),
                  labelStyle: const TextStyle(fontSize: 12),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!profile.isActive)
                  FilledButton(
                    onPressed: () {
                      ref.read(demoModeProvider.notifier).activateProfile(profile.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${profile.name} Activated')),
                      );
                    },
                    child: const Text('Activate'),
                  )
                else
                  const OutlinedButton(
                    onPressed: null,
                    child: Text('Active Scenario'),
                  ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.copy, size: 20),
                      tooltip: 'Duplicate',
                      onPressed: () {
                        ref.read(demoModeProvider.notifier).duplicateProfile(profile.id);
                      },
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.rotateCcw, size: 20),
                      tooltip: 'Reset to Default',
                      onPressed: () {
                        ref.read(demoModeProvider.notifier).resetProfile(profile.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${profile.name} data reset')),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.eye, size: 20),
                      tooltip: 'Preview Details',
                      onPressed: () => _showPreview(context, profile),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPreview(BuildContext context, DemoProfileModel profile) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(profile.icon),
              const SizedBox(width: 12),
              Text(profile.name),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Industry: ${profile.industry}'),
              Text('Data Volume: ${profile.size}'),
              const SizedBox(height: 16),
              Text(profile.description),
              const SizedBox(height: 16),
              const Text('This profile includes mocked:'),
              const Text('• Dashboard Widgets\n• Organizations & Users\n• Financial Reports\n• Supply Chain Workflows\n• AI Prompts & Responses'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            )
          ],
        );
      },
    );
  }
}
