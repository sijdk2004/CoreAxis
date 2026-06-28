import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/workflow_template.dart';
import '../../data/mock_workflow_template_repository.dart';

class WorkflowTemplateLibraryState {
  final bool isLoading;
  final List<WorkflowTemplate> templates;
  final String searchQuery;
  final String selectedCategory;
  final bool isGridView;

  WorkflowTemplateLibraryState({
    this.isLoading = true,
    this.templates = const [],
    this.searchQuery = '',
    this.selectedCategory = 'All Categories',
    this.isGridView = true,
  });

  WorkflowTemplateLibraryState copyWith({
    bool? isLoading,
    List<WorkflowTemplate>? templates,
    String? searchQuery,
    String? selectedCategory,
    bool? isGridView,
  }) {
    return WorkflowTemplateLibraryState(
      isLoading: isLoading ?? this.isLoading,
      templates: templates ?? this.templates,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isGridView: isGridView ?? this.isGridView,
    );
  }

  List<WorkflowTemplate> get filteredTemplates {
    return templates.where((t) {
      final matchesSearch = t.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          t.category.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = selectedCategory == 'All Categories' || t.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }
}

class WorkflowTemplateLibraryNotifier extends Notifier<WorkflowTemplateLibraryState> {
  @override
  WorkflowTemplateLibraryState build() {
    _loadTemplates();
    return WorkflowTemplateLibraryState();
  }

  Future<void> _loadTemplates() async {
    final repository = MockWorkflowTemplateRepository();
    final templates = await repository.getTemplates();
    state = state.copyWith(isLoading: false, templates: templates);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategoryFilter(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void toggleViewMode(bool isGridView) {
    state = state.copyWith(isGridView: isGridView);
  }

  void toggleFavorite(String id) {
    final updated = state.templates.map((t) {
      if (t.id == id) {
        return t.copyWith(isFavorite: !t.isFavorite);
      }
      return t;
    }).toList();
    state = state.copyWith(templates: updated);
  }
}

final workflowTemplateProvider = NotifierProvider<WorkflowTemplateLibraryNotifier, WorkflowTemplateLibraryState>(() {
  return WorkflowTemplateLibraryNotifier();
});
