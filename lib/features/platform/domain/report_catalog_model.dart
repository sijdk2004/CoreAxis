import 'package:flutter/material.dart';

enum ReportCategory {
  sales('Sales', Icons.point_of_sale, Colors.blue),
  inventory('Inventory', Icons.inventory, Colors.orange),
  production('Production', Icons.factory, Colors.brown),
  finance('Finance', Icons.attach_money, Colors.green),
  hr('HR', Icons.people, Colors.purple),
  workflow('Workflow', Icons.account_tree, Colors.indigo),
  approval('Approval', Icons.check_circle, Colors.teal),
  audit('Audit', Icons.security, Colors.red),
  platform('Platform', Icons.settings, Colors.grey);

  final String label;
  final IconData icon;
  final Color color;
  const ReportCategory(this.label, this.icon, this.color);
}

enum ReportStatus {
  active('Active', Colors.green),
  draft('Draft', Colors.orange),
  archived('Archived', Colors.grey);

  final String label;
  final Color color;
  const ReportStatus(this.label, this.color);
}

class ReportCatalogItem {
  final String id;
  final String name;
  final String description;
  final ReportCategory category;
  final String owner;
  final String organization;
  final DateTime lastRun;
  final int views;
  final int favorites;
  final ReportStatus status;
  final bool isFavorite;

  const ReportCatalogItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.owner,
    required this.organization,
    required this.lastRun,
    required this.views,
    required this.favorites,
    required this.status,
    this.isFavorite = false,
  });

  ReportCatalogItem copyWith({
    String? id,
    String? name,
    String? description,
    ReportCategory? category,
    String? owner,
    String? organization,
    DateTime? lastRun,
    int? views,
    int? favorites,
    ReportStatus? status,
    bool? isFavorite,
  }) {
    return ReportCatalogItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      owner: owner ?? this.owner,
      organization: organization ?? this.organization,
      lastRun: lastRun ?? this.lastRun,
      views: views ?? this.views,
      favorites: favorites ?? this.favorites,
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class ReportCatalogState {
  final List<ReportCatalogItem> items;
  final String viewMode; // 'Grid', 'List', 'Table'
  final String searchQuery;
  final String selectedCategory; // 'All' or category label
  final bool showOnlyFavorites;

  const ReportCatalogState({
    required this.items,
    this.viewMode = 'Grid',
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.showOnlyFavorites = false,
  });

  ReportCatalogState copyWith({
    List<ReportCatalogItem>? items,
    String? viewMode,
    String? searchQuery,
    String? selectedCategory,
    bool? showOnlyFavorites,
  }) {
    return ReportCatalogState(
      items: items ?? this.items,
      viewMode: viewMode ?? this.viewMode,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      showOnlyFavorites: showOnlyFavorites ?? this.showOnlyFavorites,
    );
  }
}
