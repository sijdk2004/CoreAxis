import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'providers/workspace_provider.dart';
import 'models/workspace_model.dart';

class WorkspaceManagerScreen extends ConsumerWidget {
  const WorkspaceManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final state = ref.watch(workspaceProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, theme, ref),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildMainColumn(context, theme, state, ref),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 1,
                          child: _buildSidebarColumn(context, theme, state),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildMainColumn(context, theme, state, ref),
                        const SizedBox(height: 24),
                        _buildSidebarColumn(context, theme, state),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.layoutTemplate, color: theme.colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Workspace Manager', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                Text('Customize your ERP experience, save layouts, and switch between workspaces.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Create New Workspace action triggered')));
            },
            icon: const Icon(LucideIcons.plus),
            label: const Text('New Workspace'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainColumn(BuildContext context, ThemeData theme, WorkspaceState state, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Personal Workspaces', theme),
        const SizedBox(height: 16),
        if (state.personalWorkspaces.isEmpty)
          const Text('No personal workspaces found.')
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 350,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.3,
            ),
            itemCount: state.personalWorkspaces.length,
            itemBuilder: (context, index) {
              return _buildWorkspaceCard(context, theme, state.personalWorkspaces[index], ref);
            },
          ),
        const SizedBox(height: 32),
        _buildSectionTitle('Templates & Presets', theme),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 350,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.3,
          ),
          itemCount: state.templateWorkspaces.length,
          itemBuilder: (context, index) {
            return _buildWorkspaceCard(context, theme, state.templateWorkspaces[index], ref);
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildWorkspaceCard(BuildContext context, ThemeData theme, WorkspaceModel workspace, WidgetRef ref) {
    final isActive = workspace.isActive;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isActive ? theme.colorScheme.primary : theme.dividerColor.withOpacity(0.5),
          width: isActive ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (!isActive) {
            ref.read(workspaceProvider.notifier).setActiveWorkspace(workspace.id);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Switched to ${workspace.name}')));
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isActive ? theme.colorScheme.primary.withOpacity(0.1) : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(workspace.icon, color: isActive ? theme.colorScheme.primary : theme.iconTheme.color, size: 20),
                  ),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('ACTIVE', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                    )
                  else
                    IconButton(
                      icon: const Icon(LucideIcons.moreVertical, size: 18),
                      onPressed: () {},
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                workspace.name,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  workspace.description,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMetaTag(theme, LucideIcons.layoutDashboard, '${workspace.pinnedDashboards.length} Boards'),
                  _buildMetaTag(theme, LucideIcons.box, '${workspace.favoriteModules.length} Modules'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaTag(ThemeData theme, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(text, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 11)),
      ],
    );
  }

  Widget _buildSidebarColumn(BuildContext context, ThemeData theme, WorkspaceState state) {
    final active = state.activeWorkspace;
    if (active == null) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.info, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text('Active Configuration', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 24),
            _buildConfigList(theme, 'Favorite Modules', LucideIcons.star, active.favoriteModules),
            const SizedBox(height: 20),
            _buildConfigList(theme, 'Pinned Dashboards', LucideIcons.pin, active.pinnedDashboards),
            const SizedBox(height: 20),
            _buildConfigList(theme, 'Personal Widgets', LucideIcons.layoutGrid, active.personalWidgets),
            const SizedBox(height: 20),
            _buildConfigList(theme, 'Saved Filters', LucideIcons.filter, active.savedFilters),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.save),
                label: const Text('Save Current Layout'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigList(ThemeData theme, String title, IconData icon, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              title.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Text('None configured', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic))
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                ),
                child: Text(item, style: theme.textTheme.bodySmall),
              );
            }).toList(),
          ),
      ],
    );
  }
}
