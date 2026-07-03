import 'package:flutter/material.dart';

enum ApprovalNodeType {
  start,
  managerApproval,
  roleApproval,
  userApproval,
  financeApproval,
  decision,
  parallelApproval,
  sequentialApproval,
  timeout,
  escalation,
  notification,
  end,
}

class ApprovalChainNode {
  final String id;
  final ApprovalNodeType type;
  final String label;
  final String? description;
  final IconData icon;
  final Color color;
  final Map<String, dynamic> config;
  final List<String> nextNodeIds;

  ApprovalChainNode({
    required this.id,
    required this.type,
    required this.label,
    this.description,
    required this.icon,
    required this.color,
    this.config = const {},
    this.nextNodeIds = const [],
  });

  ApprovalChainNode copyWith({
    String? id,
    ApprovalNodeType? type,
    String? label,
    String? description,
    IconData? icon,
    Color? color,
    Map<String, dynamic>? config,
    List<String>? nextNodeIds,
  }) {
    return ApprovalChainNode(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      config: config ?? this.config,
      nextNodeIds: nextNodeIds ?? this.nextNodeIds,
    );
  }
}
