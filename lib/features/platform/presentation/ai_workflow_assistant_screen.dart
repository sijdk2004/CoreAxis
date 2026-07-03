import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'providers/ai_workflow_assistant_provider.dart';
import '../domain/ai_workflow_assistant_model.dart';

class AiWorkflowAssistantScreen extends ConsumerWidget {
  const AiWorkflowAssistantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aiWorkflowAssistantProvider);
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerOrEqualTo(DESKTOP);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(LucideIcons.bot, color: Colors.blue),
            const SizedBox(width: 12),
            const Text('AI Workflow Assistant'),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: state.nodes.isEmpty ? null : () {},
            icon: const Icon(LucideIcons.download),
            label: const Text('Export'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: state.nodes.isEmpty ? null : () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Workflow published successfully!')),
              );
            },
            icon: const Icon(LucideIcons.uploadCloud, size: 18),
            label: const Text('Publish'),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: Flex(
        direction: isDesktop ? Axis.horizontal : Axis.vertical,
        children: [
          // Left: Description Input
          Expanded(
            flex: isDesktop ? 1 : 0,
            child: _buildInputPanel(context, ref, state),
          ),
          if (isDesktop) const VerticalDivider(width: 1),
          // Center: AI Generated Visual
          Expanded(
            flex: isDesktop ? 2 : 1,
            child: _buildVisualPanel(context, ref, state),
          ),
          if (isDesktop) const VerticalDivider(width: 1),
          // Right: Details/Preview
          if (isDesktop)
            Expanded(
              flex: 1,
              child: _buildPreviewPanel(context, state),
            ),
        ],
      ),
    );
  }

  Widget _buildInputPanel(BuildContext context, WidgetRef ref, AiWorkflowAssistantState state) {
    final theme = Theme.of(context);
    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Workflow Description', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Describe the workflow you want to create in plain English.', style: theme.textTheme.bodySmall),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: 'e.g., Create a quotation approval workflow...',
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) {
                ref.read(aiWorkflowAssistantProvider.notifier).updatePrompt(val);
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: state.isGenerating || state.currentPrompt.trim().isEmpty
                  ? null
                  : () => ref.read(aiWorkflowAssistantProvider.notifier).generateWorkflow(),
              icon: state.isGenerating 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(LucideIcons.sparkles, size: 18),
              label: Text(state.isGenerating ? 'Generating...' : 'Generate Workflow'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualPanel(BuildContext context, WidgetRef ref, AiWorkflowAssistantState state) {
    final theme = Theme.of(context);
    
    if (state.isGenerating) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('AI is designing your workflow...'),
          ],
        ),
      );
    }
    
    if (state.nodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.workflow, size: 64, color: theme.dividerColor),
            const SizedBox(height: 16),
            Text('No workflow generated yet.', style: theme.textTheme.titleMedium),
            Text('Enter a description and click Generate.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color)),
          ],
        ),
      );
    }

    return Container(
      color: theme.colorScheme.surface,
      child: Stack(
        children: [
          // Grid background pattern (mock)
          CustomPaint(
            painter: GridPainter(color: theme.dividerColor.withValues(alpha: 0.1)),
            child: Container(),
          ),
          // Workflow Nodes
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  for (var i = 0; i < state.nodes.length; i++)
                    _buildNodeWidget(context, state.nodes[i], i < state.nodes.length - 1).animate().fade(delay: Duration(milliseconds: 100 * i)).scaleXY(begin: 0.8),
                ],
              ),
            ),
          ),
          // Floating Action Buttons
          Positioned(
            bottom: 24,
            right: 24,
            child: Row(
              children: [
                FloatingActionButton.extended(
                  heroTag: 'simplify',
                  onPressed: () => ref.read(aiWorkflowAssistantProvider.notifier).simplifyWorkflow(),
                  icon: const Icon(LucideIcons.minimize2, size: 18),
                  label: const Text('Simplify'),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  foregroundColor: theme.colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 12),
                FloatingActionButton.extended(
                  heroTag: 'improve',
                  onPressed: () => ref.read(aiWorkflowAssistantProvider.notifier).improveWorkflow(),
                  icon: const Icon(LucideIcons.sparkles, size: 18),
                  label: const Text('Improve'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNodeWidget(BuildContext context, WorkflowNode node, bool hasNext) {
    final theme = Theme.of(context);
    
    IconData icon;
    Color color;
    
    switch (node.type) {
      case 'start':
        icon = LucideIcons.playCircle;
        color = Colors.green;
        break;
      case 'end':
        icon = LucideIcons.stopCircle;
        color = Colors.red;
        break;
      case 'approval':
        icon = LucideIcons.checkSquare;
        color = Colors.orange;
        break;
      case 'notification':
        icon = LucideIcons.bell;
        color = Colors.blue;
        break;
      case 'automated':
        icon = LucideIcons.bot;
        color = Colors.purple;
        break;
      default:
        icon = LucideIcons.square;
        color = Colors.grey;
    }

    return Column(
      children: [
        Container(
          width: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(node.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    if (node.role.isNotEmpty)
                      Text(node.role, style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (hasNext)
          Container(
            height: 40,
            width: 2,
            color: theme.dividerColor,
            child: const Align(
              alignment: Alignment.bottomCenter,
              child: Icon(LucideIcons.arrowDown, size: 16, color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget _buildPreviewPanel(BuildContext context, AiWorkflowAssistantState state) {
    final theme = Theme.of(context);
    
    if (state.nodes.isEmpty) {
      return Container(color: theme.scaffoldBackgroundColor);
    }
    
    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Workflow Preview', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (state.generatedDescription != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.info, size: 20, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(child: Text(state.generatedDescription!, style: const TextStyle(height: 1.5))),
                ],
              ),
            ).animate().fade(),
          const SizedBox(height: 24),
          Text('Execution Summary', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          _buildSummaryItem(context, 'Total Steps', '${state.nodes.length}'),
          _buildSummaryItem(context, 'Approvers', '${state.nodes.where((n) => n.type == 'approval').length}'),
          _buildSummaryItem(context, 'Estimated Time', '2-3 Days'),
          const Divider(height: 32),
          Text('Roles Involved', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.nodes
                .map((n) => n.role)
                .where((r) => r.isNotEmpty && r != 'System')
                .toSet()
                .map((r) => Chip(label: Text(r, style: const TextStyle(fontSize: 12))))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    
    const step = 40.0;
    
    for (var i = 0.0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    
    for (var i = 0.0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
