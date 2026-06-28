import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:math';

enum NodeType {
  start,
  approval,
  task,
  notification,
  decision,
  condition,
  timer,
  integration,
  document,
  aiAction,
  end
}

class WorkflowNode {
  final String id;
  final NodeType type;
  final String title;
  final String? subtitle;
  final Offset position;
  final Map<String, dynamic> properties;

  const WorkflowNode({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    required this.position,
    this.properties = const {},
  });

  WorkflowNode copyWith({
    String? title,
    String? subtitle,
    Offset? position,
    Map<String, dynamic>? properties,
  }) {
    return WorkflowNode(
      id: id,
      type: type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      position: position ?? this.position,
      properties: properties ?? this.properties,
    );
  }

  IconData get icon {
    switch (type) {
      case NodeType.start: return LucideIcons.playCircle;
      case NodeType.approval: return LucideIcons.userCheck;
      case NodeType.task: return LucideIcons.checkSquare;
      case NodeType.notification: return LucideIcons.bellRing;
      case NodeType.decision: return LucideIcons.split;
      case NodeType.condition: return LucideIcons.helpCircle;
      case NodeType.timer: return LucideIcons.clock;
      case NodeType.integration: return LucideIcons.network;
      case NodeType.document: return LucideIcons.fileText;
      case NodeType.aiAction: return LucideIcons.bot;
      case NodeType.end: return LucideIcons.stopCircle;
    }
  }

  Color get color {
    switch (type) {
      case NodeType.start: return Colors.green;
      case NodeType.approval: return Colors.blue;
      case NodeType.task: return Colors.indigo;
      case NodeType.notification: return Colors.orange;
      case NodeType.decision: return Colors.purple;
      case NodeType.condition: return Colors.deepPurple;
      case NodeType.timer: return Colors.amber;
      case NodeType.integration: return Colors.cyan;
      case NodeType.document: return Colors.teal;
      case NodeType.aiAction: return Colors.pink;
      case NodeType.end: return Colors.red;
    }
  }
}

class WorkflowConnection {
  final String sourceNodeId;
  final String targetNodeId;

  const WorkflowConnection({
    required this.sourceNodeId,
    required this.targetNodeId,
  });
}

class WorkflowDesignerState {
  final List<WorkflowNode> nodes;
  final List<WorkflowConnection> connections;
  final String? selectedNodeId;
  final bool isPanning;

  const WorkflowDesignerState({
    this.nodes = const [],
    this.connections = const [],
    this.selectedNodeId,
    this.isPanning = false,
  });

  WorkflowDesignerState copyWith({
    List<WorkflowNode>? nodes,
    List<WorkflowConnection>? connections,
    String? selectedNodeId,
    bool clearSelection = false,
    bool? isPanning,
  }) {
    return WorkflowDesignerState(
      nodes: nodes ?? this.nodes,
      connections: connections ?? this.connections,
      selectedNodeId: clearSelection ? null : (selectedNodeId ?? this.selectedNodeId),
      isPanning: isPanning ?? this.isPanning,
    );
  }
}

class WorkflowDesignerNotifier extends Notifier<WorkflowDesignerState> {
  final _random = Random();
  bool _initialized = false;

  @override
  WorkflowDesignerState build() {
    if (!_initialized) {
      _initialized = true;
      Future.microtask(_seedExampleData);
    }
    return const WorkflowDesignerState();
  }

  String _generateId() => '${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(10000)}';

  void _seedExampleData() {
    final startId = _generateId();
    final salesId = _generateId();
    final financeId = _generateId();
    final productionId = _generateId();
    final endId = _generateId();

    final nodes = [
      WorkflowNode(
        id: startId,
        type: NodeType.start,
        title: 'Start',
        position: const Offset(100, 300),
      ),
      WorkflowNode(
        id: salesId,
        type: NodeType.approval,
        title: 'Sales Manager Approval',
        subtitle: 'Requires Sales Manager',
        position: const Offset(400, 300),
        properties: {
          'description': 'Review sales order and verify discounts.',
          'assignedRole': 'Sales Manager',
          'approvalRequired': true,
          'slaHours': 24,
          'escalationRole': 'Sales Director',
          'timeoutAction': 'Escalate',
        }
      ),
      WorkflowNode(
        id: financeId,
        type: NodeType.approval,
        title: 'Finance Approval',
        subtitle: 'Requires Finance Admin',
        position: const Offset(700, 300),
        properties: {
          'description': 'Verify customer credit limit and payment terms.',
          'assignedRole': 'Finance Admin',
          'approvalRequired': true,
          'slaHours': 48,
          'escalationRole': 'CFO',
          'timeoutAction': 'Reject',
        }
      ),
      WorkflowNode(
        id: productionId,
        type: NodeType.approval,
        title: 'Production Manager Approval',
        subtitle: 'Requires Production Lead',
        position: const Offset(1000, 300),
        properties: {
          'description': 'Schedule manufacturing based on current capacity.',
          'assignedRole': 'Production Lead',
          'approvalRequired': true,
          'slaHours': 12,
          'escalationRole': 'Plant Manager',
          'timeoutAction': 'Escalate',
        }
      ),
      WorkflowNode(
        id: endId,
        type: NodeType.end,
        title: 'Completed',
        position: const Offset(1300, 300),
      ),
    ];

    final connections = [
      WorkflowConnection(sourceNodeId: startId, targetNodeId: salesId),
      WorkflowConnection(sourceNodeId: salesId, targetNodeId: financeId),
      WorkflowConnection(sourceNodeId: financeId, targetNodeId: productionId),
      WorkflowConnection(sourceNodeId: productionId, targetNodeId: endId),
    ];

    state = state.copyWith(nodes: nodes, connections: connections, selectedNodeId: salesId);
  }

  void selectNode(String? id) {
    state = state.copyWith(selectedNodeId: id, clearSelection: id == null);
  }

  void updateNodePosition(String id, Offset delta) {
    final nodes = state.nodes.map((n) {
      if (n.id == id) {
        return n.copyWith(position: n.position + delta);
      }
      return n;
    }).toList();
    state = state.copyWith(nodes: nodes);
  }

  void addNode(NodeType type, Offset position) {
    final newNode = WorkflowNode(
      id: _generateId(),
      type: type,
      title: 'New ${_typeToString(type)}',
      position: position,
    );
    state = state.copyWith(nodes: [...state.nodes, newNode]);
  }

  void updateNodeProperty(String id, String key, dynamic value) {
    final nodes = state.nodes.map((n) {
      if (n.id == id) {
        final props = Map<String, dynamic>.from(n.properties);
        props[key] = value;
        return n.copyWith(properties: props);
      }
      return n;
    }).toList();
    state = state.copyWith(nodes: nodes);
  }
  
  void updateNodeTitle(String id, String title) {
    final nodes = state.nodes.map((n) {
      if (n.id == id) {
        return n.copyWith(title: title);
      }
      return n;
    }).toList();
    state = state.copyWith(nodes: nodes);
  }
  
  void updateNodeSubtitle(String id, String subtitle) {
    final nodes = state.nodes.map((n) {
      if (n.id == id) {
        return n.copyWith(subtitle: subtitle);
      }
      return n;
    }).toList();
    state = state.copyWith(nodes: nodes);
  }

  void deleteNode(String id) {
    final nodes = state.nodes.where((n) => n.id != id).toList();
    final connections = state.connections.where((c) => c.sourceNodeId != id && c.targetNodeId != id).toList();
    state = state.copyWith(
      nodes: nodes,
      connections: connections,
      clearSelection: state.selectedNodeId == id,
    );
  }

  void addConnection(String sourceId, String targetId) {
    // Basic validation to prevent self connection or duplicates
    if (sourceId == targetId) return;
    if (state.connections.any((c) => c.sourceNodeId == sourceId && c.targetNodeId == targetId)) return;

    final newConn = WorkflowConnection(sourceNodeId: sourceId, targetNodeId: targetId);
    state = state.copyWith(connections: [...state.connections, newConn]);
  }

  void setPanning(bool panning) {
    state = state.copyWith(isPanning: panning);
  }

  String _typeToString(NodeType type) {
    switch (type) {
      case NodeType.start: return 'Start';
      case NodeType.approval: return 'Approval';
      case NodeType.task: return 'Task';
      case NodeType.notification: return 'Notification';
      case NodeType.decision: return 'Decision';
      case NodeType.condition: return 'Condition';
      case NodeType.timer: return 'Timer';
      case NodeType.integration: return 'Integration';
      case NodeType.document: return 'Document';
      case NodeType.aiAction: return 'AI Action';
      case NodeType.end: return 'End';
    }
  }
}

final workflowDesignerProvider = NotifierProvider<WorkflowDesignerNotifier, WorkflowDesignerState>(
  WorkflowDesignerNotifier.new,
);
