import 'package:flutter/foundation.dart';

@immutable
class AiAgent {
  final String id;
  final String name;
  final String description;
  final String status; // 'Active', 'Inactive', 'Learning'
  final List<String> capabilities;
  final DateTime? lastUsed;
  final String icon;

  const AiAgent({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.capabilities,
    this.lastUsed,
    required this.icon,
  });

  AiAgent copyWith({
    String? id,
    String? name,
    String? description,
    String? status,
    List<String>? capabilities,
    DateTime? lastUsed,
    String? icon,
  }) {
    return AiAgent(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      capabilities: capabilities ?? this.capabilities,
      lastUsed: lastUsed ?? this.lastUsed,
      icon: icon ?? this.icon,
    );
  }
}
