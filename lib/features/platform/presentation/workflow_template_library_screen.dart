import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'providers/workflow_template_provider.dart';
import '../domain/models/workflow_template.dart';

class WorkflowTemplateLibraryScreen extends ConsumerStatefulWidget {
  const WorkflowTemplateLibraryScreen({super.key});

  @override
  ConsumerState<WorkflowTemplateLibraryScreen> createState() => _WorkflowTemplateLibraryScreenState();
}

class _WorkflowTemplateLibraryScreenState extends ConsumerState<WorkflowTemplateLibraryScreen> {
  final List<String> _categories = [
    'All Categories',
    'Sales',
    'Purchase',
    'Inventory',
    'Manufacturing',
    'Finance',
    'HR',
    'Quality',
    'Compliance'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(workflowTemplateProvider);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Workflow Template Library'),
        backgroundColor: theme.colorScheme.surface,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.dividerColor.withOpacity(0.5),
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildToolbar(context, theme, state, isDesktop),
          const Divider(height: 1),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.filteredTemplates.isEmpty
                    ? _buildEmptyState(theme)
                    : _buildContent(theme, state, isDesktop),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, ThemeData theme, WorkflowTemplateLibraryState state, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Provide reusable workflow templates.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: isDesktop ? 2 : 1,
                child: TextField(
                  onChanged: (val) => ref.read(workflowTemplateProvider.notifier).setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search templates...',
                    prefixIcon: const Icon(LucideIcons.search, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: state.selectedCategory,
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(workflowTemplateProvider.notifier).setCategoryFilter(val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, icon: Icon(LucideIcons.layoutGrid), label: Text('Grid')),
                  ButtonSegment(value: false, icon: Icon(LucideIcons.list), label: Text('List')),
                ],
                selected: {state.isGridView},
                onSelectionChanged: (set) {
                  if (set.isNotEmpty) {
                    ref.read(workflowTemplateProvider.notifier).toggleViewMode(set.first);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.packageOpen, size: 64, color: theme.dividerColor),
          const SizedBox(height: 16),
          Text('No templates found', style: theme.textTheme.titleLarge),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme, WorkflowTemplateLibraryState state, bool isDesktop) {
    if (state.isGridView) {
      return GridView.builder(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 4 : ResponsiveBreakpoints.of(context).largerThan(MOBILE) ? 2 : 1,
          childAspectRatio: 0.85,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
        ),
        itemCount: state.filteredTemplates.length,
        itemBuilder: (context, index) {
          return _buildGridCard(context, theme, state.filteredTemplates[index]);
        },
      );
    } else {
      return ListView.separated(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        itemCount: state.filteredTemplates.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildListCard(context, theme, state.filteredTemplates[index]);
        },
      );
    }
  }

  Widget _buildGridCard(BuildContext context, ThemeData theme, WorkflowTemplate template) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(LucideIcons.fileCode2, color: theme.colorScheme.primary),
                  ),
                  IconButton(
                    icon: Icon(
                      template.isFavorite ? LucideIcons.star : LucideIcons.star,
                      color: template.isFavorite ? Colors.amber : theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      ref.read(workflowTemplateProvider.notifier).toggleFavorite(template.id);
                    },
                  ),
                ],
              ),
              const Spacer(),
              Text(
                template.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(template.category, style: const TextStyle(fontSize: 12)),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIconText(theme, LucideIcons.gitCommitHorizontal, '${template.steps} Steps'),
                  _buildComplexityBadge(theme, template.complexity),
                ],
              ),
              const SizedBox(height: 8),
              _buildIconText(theme, LucideIcons.clock, template.estimatedSetupTime),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Using template: ${template.name}')));
                      },
                      child: const Text('Use Template'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(LucideIcons.moreVertical, size: 20),
                    onSelected: (action) {
                      if (action == 'preview') {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Previewing: ${template.name}')));
                      } else if (action == 'clone') {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cloned: ${template.name}')));
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'preview', child: Row(children: [Icon(LucideIcons.eye, size: 16), SizedBox(width: 8), Text('Preview')])),
                      const PopupMenuItem(value: 'clone', child: Row(children: [Icon(LucideIcons.copy, size: 16), SizedBox(width: 8), Text('Clone')])),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListCard(BuildContext context, ThemeData theme, WorkflowTemplate template) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(LucideIcons.fileCode2, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(template.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(template.category, style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _buildIconText(theme, LucideIcons.gitCommitHorizontal, '${template.steps} Steps'),
              ),
              Expanded(
                child: _buildComplexityBadge(theme, template.complexity),
              ),
              Expanded(
                child: _buildIconText(theme, LucideIcons.clock, template.estimatedSetupTime),
              ),
              IconButton(
                icon: Icon(
                  template.isFavorite ? LucideIcons.star : LucideIcons.star,
                  color: template.isFavorite ? Colors.amber : theme.colorScheme.onSurfaceVariant,
                ),
                onPressed: () {
                  ref.read(workflowTemplateProvider.notifier).toggleFavorite(template.id);
                },
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Using template: ${template.name}')));
                },
                child: const Text('Use Template'),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(LucideIcons.moreVertical, size: 20),
                onSelected: (action) {
                  if (action == 'preview') {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Previewing: ${template.name}')));
                  } else if (action == 'clone') {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cloned: ${template.name}')));
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'preview', child: Row(children: [Icon(LucideIcons.eye, size: 16), SizedBox(width: 8), Text('Preview')])),
                  const PopupMenuItem(value: 'clone', child: Row(children: [Icon(LucideIcons.copy, size: 16), SizedBox(width: 8), Text('Clone')])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconText(ThemeData theme, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
      ],
    );
  }

  Widget _buildComplexityBadge(ThemeData theme, String complexity) {
    Color color;
    if (complexity == 'Simple') color = Colors.green;
    else if (complexity == 'Medium') color = Colors.orange;
    else color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(complexity, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
