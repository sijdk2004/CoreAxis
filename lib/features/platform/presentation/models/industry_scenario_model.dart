import 'package:flutter/material.dart';

class IndustryScenarioModel {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final List<String> features;

  const IndustryScenarioModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.features,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IndustryScenarioModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
