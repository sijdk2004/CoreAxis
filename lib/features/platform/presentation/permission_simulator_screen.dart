import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import 'providers/permission_simulator_provider.dart';

class PermissionSimulatorScreen extends ConsumerWidget {
  const PermissionSimulatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(permissionSimulatorProvider);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(theme),
                Expanded(
                  child: isDesktop
                      ? Row(
                          children: [
                            // Left Pane: Target Selection
                            SizedBox(width: 320, child: _buildLeftPane(theme, state, ref)),
                            const VerticalDivider(width: 1),
                            // Center Pane: Simulation Grid
                            Expanded(flex: 5, child: _buildCenterPane(theme, state, ref)),
                            const VerticalDivider(width: 1),
                            // Right Pane: Explanations
                            SizedBox(width: 380, child: _buildRightPane(theme, state)),
                          ],
                        )
                      : Column(
                          children: [
                            Expanded(flex: 3, child: _buildLeftPane(theme, state, ref)),
                            const Divider(height: 1),
                            Expanded(flex: 5, child: _buildCenterPane(theme, state, ref)),
                          ],
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.flaskConical, color: theme.colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Permission Simulator', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Live simulation of effective permissions across modules', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPane(ThemeData theme, PermissionSimulatorState state, WidgetRef ref) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tabs
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'user', label: Text('Users'), icon: Icon(LucideIcons.user)),
                ButtonSegment(value: 'role', label: Text('Roles'), icon: Icon(LucideIcons.shieldCheck)),
              ],
              selected: {state.simulationTargetType},
              onSelectionChanged: (set) {
                ref.read(permissionSimulatorProvider.notifier).setSimulationType(set.first);
              },
            ),
          ),
          const Divider(height: 1),
          // List
          Expanded(
            child: ListView.separated(
              itemCount: state.simulationTargetType == 'user' ? state.users.length : state.roles.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (state.simulationTargetType == 'user') {
                  final user = state.users[index];
                  final isSelected = state.selectedTargetId == user.id;
                  return ListTile(
                    selected: isSelected,
                    selectedTileColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text('${user.firstName[0]}${user.lastName[0]}', style: TextStyle(color: theme.colorScheme.primary, fontSize: 12)),
                    ),
                    title: Text('${user.firstName} ${user.lastName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text(user.departmentName ?? '', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                    onTap: () => ref.read(permissionSimulatorProvider.notifier).selectTarget(user.id),
                  );
                } else {
                  final role = state.roles[index];
                  final isSelected = state.selectedTargetId == role.id;
                  return ListTile(
                    selected: isSelected,
                    selectedTileColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, shape: BoxShape.circle),
                      child: const Icon(LucideIcons.shield, size: 16),
                    ),
                    title: Text(role.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text(role.scope, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                    onTap: () => ref.read(permissionSimulatorProvider.notifier).selectTarget(role.id),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterPane(ThemeData theme, PermissionSimulatorState state, WidgetRef ref) {
    if (state.selectedTargetId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.mousePointerClick, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text('Select a User or Role on the left to begin simulation.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 16)),
          ],
        ),
      );
    }

    if (state.simulatedModules.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5))),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.activity, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                const Text('Live Simulation Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Select a module to view effective permission breakdown', 
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.4,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
              ),
              itemCount: state.simulatedModules.length,
              itemBuilder: (context, index) {
                final module = state.simulatedModules[index];
                final isSelected = state.selectedModuleId == module.moduleId;

                return InkWell(
                  onTap: () => ref.read(permissionSimulatorProvider.notifier).selectModule(module.moduleId),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? theme.colorScheme.primaryContainer.withOpacity(0.1) : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        if (!isSelected)
                          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Module Header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5))),
                          ),
                          child: Row(
                            children: [
                              _getIcon(module.iconName, color: theme.colorScheme.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(module.moduleName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ),
                              if (module.isFullyAccessible)
                                Icon(LucideIcons.shieldCheck, size: 16, color: Colors.green)
                              else
                                Icon(LucideIcons.shieldAlert, size: 16, color: Colors.orange),
                            ],
                          ),
                        ),
                        // Actions List
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: module.actions.length,
                            itemBuilder: (context, actionIndex) {
                              final act = module.actions[actionIndex];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      act.isAllowed ? LucideIcons.check : LucideIcons.x, 
                                      color: act.isAllowed ? Colors.green : Colors.red, 
                                      size: 16
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      act.actionName, 
                                      style: TextStyle(
                                        fontSize: 13, 
                                        color: act.isAllowed ? theme.colorScheme.onSurface : Colors.grey,
                                        decoration: act.isAllowed ? TextDecoration.none : TextDecoration.lineThrough,
                                      )
                                    ),
                                    const Spacer(),
                                    if (act.hasConflict)
                                      const Icon(LucideIcons.alertTriangle, size: 14, color: Colors.orange),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPane(ThemeData theme, PermissionSimulatorState state) {
    if (state.selectedModuleId == null || state.simulatedModules.isEmpty) {
      return Container(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.fileSearch, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.2)),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text('Select a module from the center grid to view detailed permission explanations and conflicts.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 14)),
              ),
            ],
          ),
        ),
      );
    }

    final module = state.simulatedModules.firstWhere((m) => m.moduleId == state.selectedModuleId);

    return Container(
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Permission Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Effective access for ${module.moduleName}', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: module.actions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 24),
              itemBuilder: (context, index) {
                final act = module.actions[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(act.isAllowed ? LucideIcons.checkCircle2 : LucideIcons.xCircle, color: act.isAllowed ? Colors.green : Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Text(act.actionName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: act.isAllowed ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(act.isAllowed ? 'GRANTED' : 'DENIED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: act.isAllowed ? Colors.green : Colors.red)),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (act.hasConflict)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(LucideIcons.alertTriangle, color: Colors.orange, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(act.primaryReason, style: const TextStyle(fontSize: 12, color: Colors.orange))),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(act.primaryReason, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
                      ),
                    
                    const Text('Contributing Factors:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: act.contributingRoles.map((r) => Chip(
                        label: Text(r, style: const TextStyle(fontSize: 11)),
                        backgroundColor: theme.colorScheme.surface,
                        side: BorderSide(color: theme.dividerColor),
                        visualDensity: VisualDensity.compact,
                      )).toList(),
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _getIcon(String name, {Color? color}) {
    switch (name) {
      case 'layout-dashboard': return Icon(LucideIcons.layoutDashboard, size: 16, color: color);
      case 'users': return Icon(LucideIcons.users, size: 16, color: color);
      case 'bar-chart-3': return Icon(LucideIcons.barChart3, size: 16, color: color);
      case 'git-merge': return Icon(LucideIcons.gitMerge, size: 16, color: color);
      case 'sparkles': return Icon(LucideIcons.sparkles, size: 16, color: color);
      case 'package': return Icon(LucideIcons.package, size: 16, color: color);
      case 'trending-up': return Icon(LucideIcons.trendingUp, size: 16, color: color);
      case 'shield-alert': return Icon(LucideIcons.shieldAlert, size: 16, color: color);
      default: return Icon(LucideIcons.box, size: 16, color: color);
    }
  }
}
