import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

import '../../domain/report_template_model.dart';

class ReportTemplatesState {
  final List<ReportTemplateModel> templates;
  final String searchQuery;
  final TemplateCategory? selectedCategory;
  final bool showOnlyFavorites;

  ReportTemplatesState({
    required this.templates,
    this.searchQuery = '',
    this.selectedCategory,
    this.showOnlyFavorites = false,
  });

  ReportTemplatesState copyWith({
    List<ReportTemplateModel>? templates,
    String? searchQuery,
    TemplateCategory? selectedCategory,
    bool? showOnlyFavorites,
  }) {
    return ReportTemplatesState(
      templates: templates ?? this.templates,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory, // Allow null
      showOnlyFavorites: showOnlyFavorites ?? this.showOnlyFavorites,
    );
  }

  List<ReportTemplateModel> get filteredTemplates {
    var filtered = templates;

    if (showOnlyFavorites) {
      filtered = filtered.where((t) => t.isFavorite).toList();
    }

    if (selectedCategory != null) {
      filtered = filtered.where((t) => t.category == selectedCategory).toList();
    }

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((t) => 
        t.name.toLowerCase().contains(query) || 
        t.description.toLowerCase().contains(query)
      ).toList();
    }

    return filtered;
  }
}

final reportTemplatesProvider = NotifierProvider<ReportTemplatesNotifier, ReportTemplatesState>(() {
  return ReportTemplatesNotifier();
});

class ReportTemplatesNotifier extends Notifier<ReportTemplatesState> {
  final _random = Random();
  
  String _generateId() => 'tpl_${DateTime.now().millisecondsSinceEpoch}${_random.nextInt(1000)}';

  @override
  ReportTemplatesState build() {
    return ReportTemplatesState(
      templates: [
        ReportTemplateModel(
          id: 'tpl_1',
          name: 'Executive Dashboard',
          description: 'High-level overview of company performance, including KPIs for sales, revenue, and growth.',
          category: TemplateCategory.executive,
          complexity: ComplexityLevel.high,
          widgetCount: 12,
          estimatedTime: '5 mins',
          isFavorite: true,
          previewImage: 'assets/images/templates/executive.png',
        ),
        ReportTemplateModel(
          id: 'tpl_2',
          name: 'Quarterly Financials',
          description: 'Detailed financial breakdown, P&L statement, balance sheet, and cash flow analysis.',
          category: TemplateCategory.finance,
          complexity: ComplexityLevel.high,
          widgetCount: 8,
          estimatedTime: '10 mins',
          isFavorite: true,
          previewImage: 'assets/images/templates/finance.png',
        ),
        ReportTemplateModel(
          id: 'tpl_3',
          name: 'Sales Pipeline',
          description: 'Tracks lead conversions, sales velocity, and rep performance across all regions.',
          category: TemplateCategory.sales,
          complexity: ComplexityLevel.medium,
          widgetCount: 6,
          estimatedTime: '2 mins',
          isFavorite: false,
          previewImage: 'assets/images/templates/sales.png',
        ),
        ReportTemplateModel(
          id: 'tpl_4',
          name: 'Inventory Levels',
          description: 'Real-time stock monitoring, reorder alerts, and warehouse utilization metrics.',
          category: TemplateCategory.inventory,
          complexity: ComplexityLevel.low,
          widgetCount: 4,
          estimatedTime: '1 min',
          isFavorite: false,
          previewImage: 'assets/images/templates/inventory.png',
        ),
        ReportTemplateModel(
          id: 'tpl_5',
          name: 'HR Headcount & Retention',
          description: 'Employee turnover rates, hiring pipeline, and department headcount tracking.',
          category: TemplateCategory.hr,
          complexity: ComplexityLevel.medium,
          widgetCount: 5,
          estimatedTime: '3 mins',
          isFavorite: false,
          previewImage: 'assets/images/templates/hr.png',
        ),
        ReportTemplateModel(
          id: 'tpl_6',
          name: 'Production Output',
          description: 'Manufacturing KPIs, machine downtime, and quality control metrics.',
          category: TemplateCategory.production,
          complexity: ComplexityLevel.high,
          widgetCount: 9,
          estimatedTime: '8 mins',
          isFavorite: false,
          previewImage: 'assets/images/templates/production.png',
        ),
        ReportTemplateModel(
          id: 'tpl_7',
          name: 'Compliance Audit',
          description: 'Tracks regulatory compliance, policy acknowledgments, and risk assessments.',
          category: TemplateCategory.audit,
          complexity: ComplexityLevel.medium,
          widgetCount: 7,
          estimatedTime: '5 mins',
          isFavorite: false,
          previewImage: 'assets/images/templates/audit.png',
        ),
        ReportTemplateModel(
          id: 'tpl_8',
          name: 'Workflow Bottlenecks',
          description: 'Analyzes process inefficiencies, task completion times, and team throughput.',
          category: TemplateCategory.workflow,
          complexity: ComplexityLevel.high,
          widgetCount: 10,
          estimatedTime: '12 mins',
          isFavorite: true,
          previewImage: 'assets/images/templates/workflow.png',
        ),
      ],
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query, selectedCategory: state.selectedCategory);
  }

  void setCategory(TemplateCategory? category) {
    state = state.copyWith(selectedCategory: category);
  }

  void toggleShowFavorites() {
    state = state.copyWith(showOnlyFavorites: !state.showOnlyFavorites, selectedCategory: state.selectedCategory);
  }

  void toggleFavorite(String id) {
    final updatedTemplates = state.templates.map((t) {
      if (t.id == id) {
        return t.copyWith(isFavorite: !t.isFavorite);
      }
      return t;
    }).toList();
    state = state.copyWith(templates: updatedTemplates, selectedCategory: state.selectedCategory);
  }

  void cloneTemplate(String id) {
    final template = state.templates.firstWhere((t) => t.id == id);
    final newTemplate = template.copyWith(
      id: _generateId(),
      name: '${template.name} (Clone)',
      isFavorite: false,
    );
    state = state.copyWith(templates: [...state.templates, newTemplate], selectedCategory: state.selectedCategory);
  }
}
