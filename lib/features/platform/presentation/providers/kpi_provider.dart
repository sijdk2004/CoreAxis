import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

import '../../domain/kpi_model.dart';

class KpiState {
  final List<KpiModel> kpis;
  final String searchQuery;
  final KpiCategory? selectedCategory;

  KpiState({
    required this.kpis,
    this.searchQuery = '',
    this.selectedCategory,
  });

  KpiState copyWith({
    List<KpiModel>? kpis,
    String? searchQuery,
    KpiCategory? selectedCategory,
  }) {
    return KpiState(
      kpis: kpis ?? this.kpis,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory, // allow null to clear filter
    );
  }

  List<KpiModel> get filteredKpis {
    var filtered = kpis;

    if (selectedCategory != null) {
      filtered = filtered.where((k) => k.category == selectedCategory).toList();
    }

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((k) => 
        k.name.toLowerCase().contains(query) || 
        k.description.toLowerCase().contains(query)
      ).toList();
    }

    return filtered;
  }
}

final kpiProvider = NotifierProvider<KpiNotifier, KpiState>(() {
  return KpiNotifier();
});

class KpiNotifier extends Notifier<KpiState> {
  final _random = Random();
  
  String _generateId() => 'kpi_${DateTime.now().millisecondsSinceEpoch}${_random.nextInt(1000)}';

  @override
  KpiState build() {
    return KpiState(
      kpis: [
        KpiModel(
          id: 'kpi_1',
          name: 'Monthly Revenue Growth',
          description: 'Measures the percentage increase in revenue compared to the previous month.',
          category: KpiCategory.finance,
          formula: '(CurrentMonthRev - LastMonthRev) / LastMonthRev * 100',
          target: 15.0,
          thresholds: [
            KpiThreshold(value: 5.0, color: '#F44336'), // Red
            KpiThreshold(value: 10.0, color: '#FF9800'), // Orange
            KpiThreshold(value: 15.0, color: '#4CAF50'), // Green
          ],
          widgetType: KpiWidgetType.trend,
          currentValue: 12.4, // Mock current value
        ),
        KpiModel(
          id: 'kpi_2',
          name: 'Employee Retention Rate',
          description: 'Percentage of employees that remain in the company over a given period.',
          category: KpiCategory.hr,
          formula: '((TotalEmployees - EmployeesLeft) / TotalEmployees) * 100',
          target: 95.0,
          thresholds: [
            KpiThreshold(value: 80.0, color: '#F44336'),
            KpiThreshold(value: 90.0, color: '#FF9800'),
            KpiThreshold(value: 95.0, color: '#4CAF50'),
          ],
          widgetType: KpiWidgetType.gauge,
          currentValue: 92.1,
        ),
        KpiModel(
          id: 'kpi_3',
          name: 'Production Uptime',
          description: 'Total time production lines are operational versus total available time.',
          category: KpiCategory.production,
          formula: '(OperatingTime / PlannedProductionTime) * 100',
          target: 99.0,
          thresholds: [
            KpiThreshold(value: 90.0, color: '#F44336'),
            KpiThreshold(value: 95.0, color: '#FF9800'),
            KpiThreshold(value: 99.0, color: '#4CAF50'),
          ],
          widgetType: KpiWidgetType.card,
          currentValue: 99.5,
        ),
      ],
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query, selectedCategory: state.selectedCategory);
  }

  void setCategory(KpiCategory? category) {
    state = state.copyWith(selectedCategory: category);
  }

  void createKpi(KpiModel newKpi) {
    final kpiWithId = newKpi.copyWith(
      id: _generateId(),
      currentValue: _random.nextDouble() * 100, // Assign random mock value
    );
    state = state.copyWith(
      kpis: [...state.kpis, kpiWithId],
      selectedCategory: state.selectedCategory,
    );
  }

  void deleteKpi(String id) {
    state = state.copyWith(
      kpis: state.kpis.where((k) => k.id != id).toList(),
      selectedCategory: state.selectedCategory,
    );
  }
}
