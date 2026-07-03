import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'providers/ai_automation_provider.dart';
import 'models/ai_automation_model.dart';

class AiAutomationStudioScreen extends ConsumerWidget {
  const AiAutomationStudioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(aiAutomationProvider);
    final notifier = ref.read(aiAutomationProvider.notifier);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          _buildToolbar(context, theme, state, notifier),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDesktop && !state.isPreviewing) _buildSidebar(context, theme, state, notifier),
                if (isDesktop && !state.isPreviewing) const VerticalDivider(width: 1),
                Expanded(
                  child: _buildCanvas(context, theme, state, notifier),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, ThemeData theme, AIAutomationState state, AIAutomationNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(LucideIcons.workflow, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'AI Automation Studio',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Combine AI with workflow automation',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: notifier.loadTemplate,
            icon: const Icon(LucideIcons.layoutTemplate, size: 18),
            label: const Text('Templates'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: notifier.togglePreview,
            icon: Icon(state.isPreviewing ? LucideIcons.eyeOff : LucideIcons.eye, size: 18),
            label: Text(state.isPreviewing ? 'Exit Preview' : 'Preview'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: state.isSaving ? null : notifier.saveFlow,
            icon: state.isSaving 
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(LucideIcons.save, size: 18),
            label: Text(state.isSaving ? 'Saving...' : 'Publish'),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, ThemeData theme, AIAutomationState state, AIAutomationNotifier notifier) {
    return SizedBox(
      width: 280,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'AI BLOCKS',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...state.availableBlocks.map((block) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
              ),
              child: ListTile(
                leading: Icon(_getIcon(block.icon), color: theme.colorScheme.primary, size: 20),
                title: Text(block.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  block.description, 
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                onTap: () {},
                trailing: const Icon(LucideIcons.gripVertical, size: 16),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCanvas(BuildContext context, ThemeData theme, AIAutomationState state, AIAutomationNotifier notifier) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.1),
      child: ReorderableListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        buildDefaultDragHandles: !state.isPreviewing,
        proxyDecorator: (child, index, animation) {
          return Material(
            elevation: 8,
            color: Colors.transparent,
            shadowColor: Colors.black26,
            child: child,
          );
        },
        itemCount: state.nodes.length,
        onReorder: (oldIndex, newIndex) {
          notifier.reorderNodes(oldIndex, newIndex);
        },
        itemBuilder: (context, index) {
          final node = state.nodes[index];
          final isLast = index == state.nodes.length - 1;
          
          return Column(
            key: ValueKey(node.id),
            children: [
              _buildCanvasNode(context, theme, node, state.isPreviewing, () => notifier.removeNode(node.id)),
              if (!isLast)
                Container(
                  height: 32,
                  width: 2,
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                ),
              if (!isLast)
                Icon(LucideIcons.arrowDown, size: 16, color: theme.colorScheme.primary.withOpacity(0.5)),
              if (!isLast)
                const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCanvasNode(BuildContext context, ThemeData theme, AutomationNode node, bool isPreviewing, VoidCallback onRemove) {
    final Color nodeColor = _getNodeColor(node.type, theme);
    
    return Center(
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: nodeColor.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: nodeColor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: nodeColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(11),
                  topRight: Radius.circular(11),
                ),
              ),
              child: Row(
                children: [
                  Icon(_getIcon(node.icon), color: nodeColor, size: 18),
                  const SizedBox(width: 12),
                  Text(
                    node.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: nodeColor.withOpacity(0.8).withAlpha(255), // ensure visibility
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      node.type.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 9,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  if (!isPreviewing) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onRemove,
                      child: Icon(LucideIcons.x, size: 16, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ]
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                node.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getNodeColor(String type, ThemeData theme) {
    switch (type) {
      case 'trigger': return Colors.green;
      case 'ai_analysis': return Colors.deepPurple;
      case 'decision': return Colors.orange;
      case 'workflow': return Colors.blue;
      case 'notification': return Colors.pink;
      case 'completion': return Colors.teal;
      default: return theme.colorScheme.primary;
    }
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'file-text': return LucideIcons.fileText;
      case 'tag': return LucideIcons.tag;
      case 'globe': return LucideIcons.globe;
      case 'trending-up': return LucideIcons.trendingUp;
      case 'scissors': return LucideIcons.scissors;
      case 'pen-tool': return LucideIcons.penTool;
      case 'git-compare': return LucideIcons.gitCompare;
      case 'thumbs-up': return LucideIcons.thumbsUp;
      case 'mail': return LucideIcons.mail;
      case 'git-branch': return LucideIcons.gitBranch;
      case 'check-square': return LucideIcons.checkSquare;
      case 'bell': return LucideIcons.bell;
      case 'flag': return LucideIcons.flag;
      default: return LucideIcons.box;
    }
  }
}
