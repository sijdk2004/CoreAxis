import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../domain/models/approval_chain_node.dart';

class ApprovalChainDesignerState {
  final List<ApprovalChainNode> nodes;
  final String? selectedNodeId;

  ApprovalChainDesignerState({
    required this.nodes,
    this.selectedNodeId,
  });

  ApprovalChainDesignerState copyWith({
    List<ApprovalChainNode>? nodes,
    String? selectedNodeId,
  }) {
    return ApprovalChainDesignerState(
      nodes: nodes ?? this.nodes,
      selectedNodeId: selectedNodeId ?? this.selectedNodeId,
    );
  }
}

class ApprovalChainDesignerNotifier extends Notifier<ApprovalChainDesignerState> {
  @override
  ApprovalChainDesignerState build() {
    return ApprovalChainDesignerState(nodes: _initialNodes);
  }

  static final List<ApprovalChainNode> _initialNodes = [
    ApprovalChainNode(
      id: 'start',
      type: ApprovalNodeType.start,
      label: 'Start',
      icon: LucideIcons.play,
      color: Colors.green,
    ),
    ApprovalChainNode(
      id: 'n1',
      type: ApprovalNodeType.managerApproval,
      label: 'Sales Manager',
      description: 'First level approval',
      icon: LucideIcons.userCheck,
      color: Colors.blue,
      config: {'role': 'Sales Manager', 'timeoutHours': 24},
    ),
    ApprovalChainNode(
      id: 'n2',
      type: ApprovalNodeType.managerApproval,
      label: 'Finance Manager',
      description: 'Budget verification',
      icon: LucideIcons.calculator,
      color: Colors.purple,
      config: {'role': 'Finance Manager', 'timeoutHours': 48},
    ),
    ApprovalChainNode(
      id: 'n3',
      type: ApprovalNodeType.roleApproval,
      label: 'Managing Director',
      description: 'Final sign-off',
      icon: LucideIcons.shieldCheck,
      color: Colors.deepOrange,
      config: {'role': 'Managing Director'},
    ),
    ApprovalChainNode(
      id: 'end',
      type: ApprovalNodeType.end,
      label: 'Completed',
      icon: LucideIcons.checkCircle,
      color: Colors.teal,
    ),
  ];

  void selectNode(String id) {
    state = state.copyWith(selectedNodeId: id);
  }
  
  void deselectNode() {
    state = state.copyWith(selectedNodeId: null);
  }

  void updateNodeConfig(String id, Map<String, dynamic> newConfig) {
    final updatedNodes = state.nodes.map((n) {
      if (n.id == id) {
        return n.copyWith(config: {...n.config, ...newConfig});
      }
      return n;
    }).toList();
    state = state.copyWith(nodes: updatedNodes);
  }
  
  void updateNodeLabel(String id, String newLabel) {
    final updatedNodes = state.nodes.map((n) {
      if (n.id == id) {
        return n.copyWith(label: newLabel);
      }
      return n;
    }).toList();
    state = state.copyWith(nodes: updatedNodes);
  }

  void addNode(ApprovalChainNode node, int index) {
    final newNodes = List<ApprovalChainNode>.from(state.nodes);
    newNodes.insert(index, node);
    state = state.copyWith(nodes: newNodes);
  }

  void removeNode(String id) {
    if (id == 'start' || id == 'end') return; // Cannot remove start/end for this mock
    final newNodes = state.nodes.where((n) => n.id != id).toList();
    final newSelectedId = state.selectedNodeId == id ? null : state.selectedNodeId;
    state = state.copyWith(nodes: newNodes, selectedNodeId: newSelectedId);
  }

  void reorderNodes(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= state.nodes.length || newIndex < 0 || newIndex > state.nodes.length) return;
    
    // Prevent moving start/end
    if (state.nodes[oldIndex].type == ApprovalNodeType.start || 
        state.nodes[oldIndex].type == ApprovalNodeType.end) return;

    if (newIndex == 0) newIndex = 1; // Don't move before start
    if (newIndex >= state.nodes.length) newIndex = state.nodes.length - 1; // Don't move after end

    final newNodes = List<ApprovalChainNode>.from(state.nodes);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final node = newNodes.removeAt(oldIndex);
    newNodes.insert(newIndex, node);
    state = state.copyWith(nodes: newNodes);
  }
}

final approvalChainDesignerProvider = NotifierProvider<ApprovalChainDesignerNotifier, ApprovalChainDesignerState>(() {
  return ApprovalChainDesignerNotifier();
});
