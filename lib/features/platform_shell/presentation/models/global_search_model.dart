import 'package:flutter/material.dart';

enum CommandGroup {
  recent,
  favorites,
  navigation,
  actions,
}

class CommandItem {
  final String id;
  final String title;
  final String? subtitle;
  final IconData icon;
  final CommandGroup group;
  final String? route;
  final String? actionType;

  const CommandItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.group,
    this.route,
    this.actionType,
  });

  String get groupLabel {
    switch (group) {
      case CommandGroup.recent: return 'Recent Commands';
      case CommandGroup.favorites: return 'Favorites';
      case CommandGroup.navigation: return 'Navigation';
      case CommandGroup.actions: return 'Actions';
    }
  }
}
