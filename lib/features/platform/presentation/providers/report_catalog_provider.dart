import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/report_catalog_model.dart';
import 'dart:math';

final reportCatalogProvider = NotifierProvider<ReportCatalogNotifier, ReportCatalogState>(() {
  return ReportCatalogNotifier();
});

class ReportCatalogNotifier extends Notifier<ReportCatalogState> {
  @override
  ReportCatalogState build() {
    return ReportCatalogState(items: _generateMockReports());
  }

  void setViewMode(String mode) {
    state = state.copyWith(viewMode: mode);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSelectedCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void toggleShowOnlyFavorites() {
    state = state.copyWith(showOnlyFavorites: !state.showOnlyFavorites);
  }

  void toggleFavorite(String reportId) {
    final newItems = state.items.map((item) {
      if (item.id == reportId) {
        return item.copyWith(isFavorite: !item.isFavorite);
      }
      return item;
    }).toList();
    state = state.copyWith(items: newItems);
  }

  void duplicateReport(String reportId) {
    final item = state.items.firstWhere((element) => element.id == reportId);
    final newItem = item.copyWith(
      id: 'REP-${Random().nextInt(9000) + 1000}',
      name: '${item.name} (Copy)',
      status: ReportStatus.draft,
      views: 0,
      favorites: 0,
      isFavorite: false,
    );
    state = state.copyWith(items: [newItem, ...state.items]);
  }

  void archiveReport(String reportId) {
    final newItems = state.items.map((item) {
      if (item.id == reportId) {
        return item.copyWith(status: ReportStatus.archived);
      }
      return item;
    }).toList();
    state = state.copyWith(items: newItems);
  }

  List<ReportCatalogItem> get filteredItems {
    return state.items.where((item) {
      final matchesSearch = state.searchQuery.isEmpty || item.name.toLowerCase().contains(state.searchQuery.toLowerCase()) || item.description.toLowerCase().contains(state.searchQuery.toLowerCase());
      final matchesCategory = state.selectedCategory == 'All' || item.category.label == state.selectedCategory;
      final matchesFavorite = !state.showOnlyFavorites || item.isFavorite;
      
      return matchesSearch && matchesCategory && matchesFavorite;
    }).toList();
  }

  List<ReportCatalogItem> _generateMockReports() {
    final random = Random(42);
    final owners = ['Alice Smith', 'Bob Jones', 'Charlie Brown', 'Diana Prince', 'Eve Adams', 'System'];
    final orgs = ['Acme Corp', 'Stark Ind', 'Wayne Ent', 'Umbrella Corp'];

    return List.generate(24, (index) {
      final category = ReportCategory.values[random.nextInt(ReportCategory.values.length)];
      final status = ReportStatus.values[random.nextInt(ReportStatus.values.length)];
      return ReportCatalogItem(
        id: 'REP-${1000 + index}',
        name: '${category.label} Overview $index',
        description: 'Comprehensive analysis of ${category.label.toLowerCase()} metrics and KPIs for the current fiscal quarter.',
        category: category,
        owner: owners[random.nextInt(owners.length)],
        organization: orgs[random.nextInt(orgs.length)],
        lastRun: DateTime.now().subtract(Duration(days: random.nextInt(30), hours: random.nextInt(24))),
        views: random.nextInt(5000) + 100,
        favorites: random.nextInt(500),
        status: status,
        isFavorite: random.nextDouble() > 0.8,
      );
    });
  }
}
