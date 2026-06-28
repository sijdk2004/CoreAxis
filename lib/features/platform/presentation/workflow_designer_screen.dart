import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'providers/workflow_designer_provider.dart';

class WorkflowDesignerScreen extends ConsumerStatefulWidget {
  const WorkflowDesignerScreen({super.key});

  @override
  ConsumerState<WorkflowDesignerScreen> createState() => _WorkflowDesignerScreenState();
}

class _WorkflowDesignerScreenState extends ConsumerState<WorkflowDesignerScreen> {
  final TransformationController _transformationController = TransformationController();
  bool _isCanvasPanning = false;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(workflowDesignerProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          _buildToolbar(theme),
          const Divider(height: 1),
          Expanded(
            child: Row(
              children: [
                _buildToolbox(theme),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Stack(
                    children: [
                      // The Infinite Canvas background pattern
                      Positioned.fill(
                        child: CustomPaint(painter: _GridPainter(theme: theme)),
                      ),
                      // The actual interactive canvas
                      _buildInteractiveCanvas(theme, state),
                    ],
                  ),
                ),
                if (state.selectedNodeId != null) ...[
                  const VerticalDivider(width: 1),
                  _buildPropertiesPanel(theme, state),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildToolbar(ThemeData theme) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: theme.colorScheme.surface,
      child: Row(
        children: [
          IconButton(icon: const Icon(LucideIcons.undo, size: 20), onPressed: () {}, tooltip: 'Undo'),
          IconButton(icon: const Icon(LucideIcons.redo, size: 20), onPressed: () {}, tooltip: 'Redo'),
          const VerticalDivider(indent: 16, endIndent: 16),
          IconButton(
            icon: const Icon(LucideIcons.zoomIn, size: 20),
            onPressed: () {
              _transformationController.value = _transformationController.value.scaled(1.2);
            },
            tooltip: 'Zoom In'
          ),
          IconButton(
            icon: const Icon(LucideIcons.zoomOut, size: 20),
            onPressed: () {
              _transformationController.value = _transformationController.value.scaled(0.8);
            },
            tooltip: 'Zoom Out'
          ),
          IconButton(icon: const Icon(LucideIcons.layoutTemplate, size: 20), onPressed: () {}, tooltip: 'Auto Layout'),
          const Spacer(),
          TextButton.icon(icon: const Icon(LucideIcons.history, size: 16), label: const Text('Version History'), onPressed: () {}),
          const SizedBox(width: 8),
          OutlinedButton.icon(icon: const Icon(LucideIcons.eye, size: 16), label: const Text('Preview'), onPressed: () {}),
          const SizedBox(width: 8),
          FilledButton.icon(icon: const Icon(LucideIcons.save, size: 16), label: const Text('Save'), onPressed: () {}),
          const SizedBox(width: 8),
          FilledButton.icon(
            icon: const Icon(LucideIcons.uploadCloud, size: 16),
            label: const Text('Publish'),
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbox(ThemeData theme) {
    final tools = [
      {'type': NodeType.start, 'label': 'Start Event'},
      {'type': NodeType.approval, 'label': 'User Approval'},
      {'type': NodeType.task, 'label': 'System Task'},
      {'type': NodeType.notification, 'label': 'Notification'},
      {'type': NodeType.decision, 'label': 'Decision'},
      {'type': NodeType.condition, 'label': 'Condition'},
      {'type': NodeType.timer, 'label': 'Timer'},
      {'type': NodeType.integration, 'label': 'Integration'},
      {'type': NodeType.document, 'label': 'Document'},
      {'type': NodeType.aiAction, 'label': 'AI Action'},
      {'type': NodeType.end, 'label': 'End Event'},
    ];

    return Container(
      width: 260,
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Workflow Components', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: tools.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final type = tools[index]['type'] as NodeType;
                final label = tools[index]['label'] as String;
                final dummyNode = WorkflowNode(id: '', type: type, title: label, position: Offset.zero);
                
                return Draggable<NodeType>(
                  data: type,
                  feedback: SizedBox(
                    width: 260,
                    child: Material(
                      color: Colors.transparent,
                      child: Opacity(
                        opacity: 0.8,
                        child: _buildToolboxItem(theme, dummyNode, isDragging: true),
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.5,
                    child: _buildToolboxItem(theme, dummyNode),
                  ),
                  child: _buildToolboxItem(theme, dummyNode),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolboxItem(ThemeData theme, WorkflowNode node, {bool isDragging = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
        boxShadow: isDragging ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))] : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: node.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(node.icon, size: 18, color: node.color),
          ),
          const SizedBox(width: 12),
          Text(node.title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          const Spacer(),
          Icon(LucideIcons.gripVertical, size: 16, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
        ],
      ),
    );
  }

  Widget _buildInteractiveCanvas(ThemeData theme, WorkflowDesignerState state) {
    return GestureDetector(
      onTap: () => ref.read(workflowDesignerProvider.notifier).selectNode(null), // Deselect when clicking canvas
      child: DragTarget<NodeType>(
        onAcceptWithDetails: (details) {
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          final localOffset = renderBox.globalToLocal(details.offset);
          // Apply inverse matrix to get logical canvas coordinates
          final invertedMatrix = Matrix4.inverted(_transformationController.value);
          final logicalOffset = MatrixUtils.transformPoint(invertedMatrix, localOffset);
          
          ref.read(workflowDesignerProvider.notifier).addNode(details.data, logicalOffset - const Offset(260, 56));
        },
        builder: (context, candidateData, rejectedData) {
          return InteractiveViewer(
            transformationController: _transformationController,
            constrained: false,
            boundaryMargin: const EdgeInsets.all(4000),
            minScale: 0.1,
            maxScale: 2.0,
            onInteractionStart: (_) => _isCanvasPanning = true,
            onInteractionEnd: (_) => _isCanvasPanning = false,
            child: SizedBox(
              width: 8000,
              height: 8000,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Connections layer
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ConnectionPainter(
                        nodes: state.nodes,
                        connections: state.connections,
                        theme: theme,
                      ),
                    ),
                  ),
                  // Nodes layer
                  ...state.nodes.map((node) => Positioned(
                    left: node.position.dx,
                    top: node.position.dy,
                    child: _buildCanvasNode(theme, node, state.selectedNodeId == node.id),
                  )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCanvasNode(ThemeData theme, WorkflowNode node, bool isSelected) {
    final isCompact = node.type == NodeType.start || node.type == NodeType.end;

    return GestureDetector(
      onTap: () => ref.read(workflowDesignerProvider.notifier).selectNode(node.id),
      onPanUpdate: (details) {
        // Only drag node if we aren't panning the whole canvas
        if (!_isCanvasPanning) {
           // account for scale
           final scale = _transformationController.value.getMaxScaleOnAxis();
           ref.read(workflowDesignerProvider.notifier).updateNodePosition(node.id, details.delta / scale);
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.move,
        child: Container(
          width: isCompact ? 160 : 260,
          padding: EdgeInsets.all(isCompact ? 12 : 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isSelected ? theme.colorScheme.primary : Colors.black).withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: isCompact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: isCompact ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: node.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(node.icon, color: node.color, size: 20),
                  ),
                  if (!isCompact) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(node.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          if (node.subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(node.subtitle!, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                          ]
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.moreHorizontal, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {}, // Show menu (Delete, Duplicate)
                    )
                  ]
                ],
              ),
              if (isCompact) ...[
                const SizedBox(height: 8),
                Text(node.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertiesPanel(ThemeData theme, WorkflowDesignerState state) {
    final node = state.nodes.firstWhere((n) => n.id == state.selectedNodeId);
    
    return Container(
      width: 320,
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              children: [
                Expanded(child: Text('Properties', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant, fontSize: 14))),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => ref.read(workflowDesignerProvider.notifier).selectNode(null),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildPropertySection('General'),
                const SizedBox(height: 16),
                _buildTextField(theme, 'Node Name', node.title, (v) => ref.read(workflowDesignerProvider.notifier).updateNodeTitle(node.id, v)),
                const SizedBox(height: 16),
                _buildTextField(theme, 'Description', node.properties['description']?.toString() ?? '', (v) => ref.read(workflowDesignerProvider.notifier).updateNodeProperty(node.id, 'description', v), maxLines: 3),
                
                if (node.type == NodeType.approval || node.type == NodeType.task) ...[
                  const SizedBox(height: 32),
                  _buildPropertySection('Assignment'),
                  const SizedBox(height: 16),
                  _buildTextField(theme, 'Assigned Role', node.properties['assignedRole']?.toString() ?? '', (v) => ref.read(workflowDesignerProvider.notifier).updateNodeProperty(node.id, 'assignedRole', v)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(child: Text('Approval Required', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
                      Switch(
                        value: node.properties['approvalRequired'] as bool? ?? false,
                        onChanged: (v) => ref.read(workflowDesignerProvider.notifier).updateNodeProperty(node.id, 'approvalRequired', v),
                      )
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildPropertySection('SLA & Escalation'),
                  const SizedBox(height: 16),
                  _buildTextField(theme, 'SLA (Hours)', node.properties['slaHours']?.toString() ?? '', (v) => ref.read(workflowDesignerProvider.notifier).updateNodeProperty(node.id, 'slaHours', v)),
                  const SizedBox(height: 16),
                  _buildTextField(theme, 'Escalation Role', node.properties['escalationRole']?.toString() ?? '', (v) => ref.read(workflowDesignerProvider.notifier).updateNodeProperty(node.id, 'escalationRole', v)),
                ],

                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: () => ref.read(workflowDesignerProvider.notifier).deleteNode(node.id),
                  icon: const Icon(LucideIcons.trash2, size: 16),
                  label: const Text('Delete Node'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.withOpacity(0.5))
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPropertySection(String title) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5));
  }

  Widget _buildTextField(ThemeData theme, String label, String value, Function(String) onChanged, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          onChanged: onChanged,
        )
      ],
    );
  }
}

// Custom Painter to draw bezier curves between connected nodes
class _ConnectionPainter extends CustomPainter {
  final List<WorkflowNode> nodes;
  final List<WorkflowConnection> connections;
  final ThemeData theme;

  _ConnectionPainter({required this.nodes, required this.connections, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.dividerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final conn in connections) {
      try {
        final source = nodes.firstWhere((n) => n.id == conn.sourceNodeId);
        final target = nodes.firstWhere((n) => n.id == conn.targetNodeId);

        // Calculate center points (assuming generic widths for mock up)
        final sourceCenter = Offset(source.position.dx + (source.type == NodeType.start ? 80 : 260), source.position.dy + 40);
        final targetCenter = Offset(target.position.dx, target.position.dy + 40);

        final path = Path();
        path.moveTo(sourceCenter.dx, sourceCenter.dy);

        // Draw bezier curve for that smooth flow look
        final controlPointOffset = (targetCenter.dx - sourceCenter.dx).abs() * 0.5;
        path.cubicTo(
          sourceCenter.dx + controlPointOffset, sourceCenter.dy,
          targetCenter.dx - controlPointOffset, targetCenter.dy,
          targetCenter.dx, targetCenter.dy,
        );

        canvas.drawPath(path, paint);
        
        // Draw arrow head at target
        final arrowPaint = Paint()..color = theme.dividerColor..style = PaintingStyle.fill;
        final arrowPath = Path();
        arrowPath.moveTo(targetCenter.dx, targetCenter.dy);
        arrowPath.lineTo(targetCenter.dx - 10, targetCenter.dy - 6);
        arrowPath.lineTo(targetCenter.dx - 10, targetCenter.dy + 6);
        arrowPath.close();
        canvas.drawPath(arrowPath, arrowPaint);

      } catch (e) {
        // Node might not exist if deleted
        continue;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectionPainter oldDelegate) => true; // Simplification for mock
}

// Background grid pattern
class _GridPainter extends CustomPainter {
  final ThemeData theme;

  _GridPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.dividerColor.withOpacity(0.3)
      ..strokeWidth = 1;

    const double spacing = 40.0;
    
    // Draw dots
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
