import 'package:flutter/material.dart';

class DemoProfileModel {
  final String id;
  final String name;
  final String industry;
  final String size;
  final String description;
  final IconData icon;
  final bool isActive;
  final DateTime lastActivated;

  const DemoProfileModel({
    required this.id,
    required this.name,
    required this.industry,
    required this.size,
    required this.description,
    required this.icon,
    this.isActive = false,
    required this.lastActivated,
  });

  DemoProfileModel copyWith({
    String? id,
    String? name,
    String? industry,
    String? size,
    String? description,
    IconData? icon,
    bool? isActive,
    DateTime? lastActivated,
  }) {
    return DemoProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      industry: industry ?? this.industry,
      size: size ?? this.size,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      lastActivated: lastActivated ?? this.lastActivated,
    );
  }
}
