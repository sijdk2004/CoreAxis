import 'package:flutter/foundation.dart';

@immutable
class AutomationNode {
  final String id;
  final String title;
  final String type; // 'trigger', 'ai_analysis', 'decision', 'workflow', 'notification', 'completion'
  final String icon;
  final String description;
  final Map<String, dynamic> config;

  const AutomationNode({
    required this.id,
    required this.title,
    required this.type,
    required this.icon,
    this.description = '',
    this.config = const {},
  });

  AutomationNode copyWith({
    String? id,
    String? title,
    String? type,
    String? icon,
    String? description,
    Map<String, dynamic>? config,
  }) {
    return AutomationNode(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      config: config ?? this.config,
    );
  }
}

@immutable
class AiBlock {
  final String id;
  final String title;
  final String icon;
  final String description;

  const AiBlock({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
  });
}
