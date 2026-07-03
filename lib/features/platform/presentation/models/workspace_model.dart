import 'package:flutter/material.dart';

class WorkspaceModel {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final bool isPersonal;
  final bool isActive;
  final List<String> favoriteModules;
  final List<String> pinnedDashboards;
  final List<String> personalWidgets;
  final List<String> savedFilters;

  const WorkspaceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.isPersonal = false,
    this.isActive = false,
    this.favoriteModules = const [],
    this.pinnedDashboards = const [],
    this.personalWidgets = const [],
    this.savedFilters = const [],
  });

  WorkspaceModel copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    bool? isPersonal,
    bool? isActive,
    List<String>? favoriteModules,
    List<String>? pinnedDashboards,
    List<String>? personalWidgets,
    List<String>? savedFilters,
  }) {
    return WorkspaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isPersonal: isPersonal ?? this.isPersonal,
      isActive: isActive ?? this.isActive,
      favoriteModules: favoriteModules ?? this.favoriteModules,
      pinnedDashboards: pinnedDashboards ?? this.pinnedDashboards,
      personalWidgets: personalWidgets ?? this.personalWidgets,
      savedFilters: savedFilters ?? this.savedFilters,
    );
  }
}
