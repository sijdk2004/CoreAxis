import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../domain/models/approval_chain_node.dart';
import 'providers/approval_chain_designer_provider.dart';

class ApprovalChainDesignerScreen extends ConsumerWidget {
  const ApprovalChainDesignerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(approvalChainDesignerProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: _buildAppBar(context, theme),
      body: Row(
        children: [
          // Left: Component Library
          SizedBox(
            width: 250,
            child: _buildComponentLibrary(context, theme),
          ),
          VerticalDivider(width: 1, thickness: 1, color: theme.colorScheme.outlineVariant),
          
          // Center: Visual Canvas
          Expanded(
            child: _buildCanvas(context, ref, state, theme),
          ),
          VerticalDivider(width: 1, thickness: 1, color: theme.colorScheme.outlineVariant),
          
          // Right: Property Editor
          SizedBox(
            width: 300,
            child: _buildPropertyEditor(context, ref, state, theme),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Purchase Requisition Chain', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text('Approval Chain Designer', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.undo2, size: 20),
          tooltip: 'Undo',
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(LucideIcons.redo2, size: 20),
          tooltip: 'Redo',
          onPressed: () {},
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(LucideIcons.zoomIn, size: 20),
          tooltip: 'Zoom In',
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(LucideIcons.zoomOut, size: 20),
          tooltip: 'Zoom Out',
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(LucideIcons.layoutGrid, size: 20),
          tooltip: 'Auto Layout',
          onPressed: () {},
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          icon: const Icon(LucideIcons.play, size: 16),
          label: const Text('Preview'),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          icon: const Icon(LucideIcons.checkCircle2, size: 16),
          label: const Text('Validate'),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          icon: const Icon(LucideIcons.uploadCloud, size: 16),
          label: const Text('Publish'),
          onPressed: () {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Approval Chain published successfully')),
            );
          },
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(LucideIcons.history, size: 20),
          tooltip: 'Version History',
          onPressed: () {},
        ),
        const SizedBox(width: 16),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: theme.colorScheme.outlineVariant,
          height: 1.0,
        ),
      ),
    );
  }

  Widget _buildComponentLibrary(BuildContext context, ThemeData theme) {
    final components = [
      {'type': ApprovalNodeType.managerApproval, 'label': 'Manager Approval', 'icon': LucideIcons.userCheck, 'color': Colors.blue},
      {'type': ApprovalNodeType.roleApproval, 'label': 'Role Approval', 'icon': LucideIcons.shieldCheck, 'color': Colors.indigo},
      {'type': ApprovalNodeType.userApproval, 'label': 'User Approval', 'icon': LucideIcons.user, 'color': Colors.cyan},
      {'type': ApprovalNodeType.financeApproval, 'label': 'Finance Approval', 'icon': LucideIcons.calculator, 'color': Colors.purple},
      {'type': ApprovalNodeType.decision, 'label': 'Decision', 'icon': LucideIcons.split, 'color': Colors.orange},
      {'type': ApprovalNodeType.parallelApproval, 'label': 'Parallel Approval', 'icon': LucideIcons.gitBranch, 'color': Colors.pink},
      {'type': ApprovalNodeType.sequentialApproval, 'label': 'Sequential Approval', 'icon': LucideIcons.listOrdered, 'color': Colors.blueGrey},
      {'type': ApprovalNodeType.timeout, 'label': 'Timeout', 'icon': LucideIcons.timer, 'color': Colors.red},
      {'type': ApprovalNodeType.escalation, 'label': 'Escalation', 'icon': LucideIcons.trendingUp, 'color': Colors.deepOrange},
      {'type': ApprovalNodeType.notification, 'label': 'Notification', 'icon': LucideIcons.bell, 'color': Colors.amber},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Components', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: components.length,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemBuilder: (context, index) {
              final comp = components[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Draggable<Map<String, dynamic>>(
                  data: comp,
                  feedback: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: _buildComponentCard(comp, theme, isDragging: true),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.5,
                    child: _buildComponentCard(comp, theme),
                  ),
                  child: _buildComponentCard(comp, theme),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildComponentCard(Map<String, dynamic> comp, ThemeData theme, {bool isDragging = false}) {
    return Container(
      width: isDragging ? 220 : null,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(comp['icon'] as IconData, color: comp['color'] as Color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              comp['label'] as String,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Icon(LucideIcons.gripVertical, size: 16, color: theme.colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildCanvas(BuildContext context, WidgetRef ref, ApprovalChainDesignerState state, ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      child: Stack(
        children: [
          // Background Grid
          CustomPaint(
            painter: _GridPainter(theme.colorScheme.outlineVariant.withOpacity(0.5)),
            size: Size.infinite,
          ),
          
          // Nodes
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: DragTarget<Map<String, dynamic>>(
                onAcceptWithDetails: (details) {
                  final comp = details.data;
                  final newNode = ApprovalChainNode(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    type: comp['type'] as ApprovalNodeType,
                    label: comp['label'] as String,
                    icon: comp['icon'] as IconData,
                    color: comp['color'] as Color,
                  );
                  // Insert before the end node if possible
                  final insertIndex = state.nodes.length > 1 ? state.nodes.length - 1 : state.nodes.length;
                  ref.read(approvalChainDesignerProvider.notifier).addNode(newNode, insertIndex);
                },
                builder: (context, candidateData, rejectedData) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < state.nodes.length; i++)
                        _buildCanvasNode(context, ref, state.nodes[i], state.selectedNodeId == state.nodes[i].id, i < state.nodes.length - 1, theme),
                      
                      // Drop Zone Indicator
                      if (candidateData.isNotEmpty)
                        Container(
                          width: 250,
                          height: 60,
                          margin: const EdgeInsets.only(top: 16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                            border: Border.all(color: theme.colorScheme.primary, style: BorderStyle.solid, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text('Drop component here', style: TextStyle(color: theme.colorScheme.primary)),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvasNode(BuildContext context, WidgetRef ref, ApprovalChainNode node, bool isSelected, bool hasNext, ThemeData theme) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => ref.read(approvalChainDesignerProvider.notifier).selectNode(node.id),
          child: Container(
            width: 250,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: node.color.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                  ),
                  child: Row(
                    children: [
                      Icon(node.icon, color: node.color, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          node.label,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (node.type != ApprovalNodeType.start && node.type != ApprovalNodeType.end)
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(LucideIcons.x, size: 16, color: theme.colorScheme.onSurfaceVariant),
                          onPressed: () {
                            ref.read(approvalChainDesignerProvider.notifier).removeNode(node.id);
                          },
                        ),
                    ],
                  ),
                ),
                // Body
                if (node.description != null || node.config.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (node.description != null)
                          Text(
                            node.description!,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        if (node.config.containsKey('role'))
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(LucideIcons.users, size: 12, color: theme.colorScheme.primary),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    node.config['role'].toString(),
                                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        // Connector Arrow
        if (hasNext)
          Container(
            height: 40,
            width: 2,
            color: theme.colorScheme.outline,
            alignment: Alignment.bottomCenter,
            child: Icon(LucideIcons.arrowDown, size: 16, color: theme.colorScheme.outline),
          ),
      ],
    );
  }

  Widget _buildPropertyEditor(BuildContext context, WidgetRef ref, ApprovalChainDesignerState state, ThemeData theme) {
    if (state.selectedNodeId == null) {
      return Center(
        child: Text('Select a node to edit properties', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      );
    }

    final node = state.nodes.firstWhere((n) => n.id == state.selectedNodeId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Text('Properties', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: const Icon(LucideIcons.x, size: 20),
                onPressed: () => ref.read(approvalChainDesignerProvider.notifier).deselectNode(),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                initialValue: node.label,
                decoration: const InputDecoration(
                  labelText: 'Node Label',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) {
                   ref.read(approvalChainDesignerProvider.notifier).updateNodeLabel(node.id, val);
                },
              ),
              const SizedBox(height: 16),
              if (node.type == ApprovalNodeType.managerApproval || node.type == ApprovalNodeType.roleApproval) ...[
                DropdownButtonFormField<String>(
                  value: node.config['role'] as String?,
                  decoration: const InputDecoration(
                    labelText: 'Target Role',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Sales Manager', 'Finance Manager', 'Managing Director', 'HR Manager', 'Line Manager']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(approvalChainDesignerProvider.notifier).updateNodeConfig(node.id, {'role': val});
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: (node.config['timeoutHours'] ?? 24).toString(),
                  decoration: const InputDecoration(
                    labelText: 'Timeout (Hours)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    final hours = int.tryParse(val);
                    if (hours != null) {
                      ref.read(approvalChainDesignerProvider.notifier).updateNodeConfig(node.id, {'timeoutHours': hours});
                    }
                  },
                ),
              ],
              
              if (node.type == ApprovalNodeType.decision) ...[
                 DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Condition',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Amount > \$10,000', 'Department == IT', 'Risk Level == High']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) {},
                ),
              ],
              
              const SizedBox(height: 24),
              // Advanced Settings Mock
              ExpansionTile(
                title: const Text('Advanced Settings'),
                tilePadding: EdgeInsets.zero,
                children: [
                   SwitchListTile(
                    title: const Text('Allow Delegation'),
                    value: node.config['allowDelegation'] ?? true,
                    onChanged: (val) {
                       ref.read(approvalChainDesignerProvider.notifier).updateNodeConfig(node.id, {'allowDelegation': val});
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                   SwitchListTile(
                    title: const Text('Require Signature'),
                    value: node.config['requireSignature'] ?? false,
                    onChanged: (val) {
                       ref.read(approvalChainDesignerProvider.notifier).updateNodeConfig(node.id, {'requireSignature': val});
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;

  _GridPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const double spacing = 20.0;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
