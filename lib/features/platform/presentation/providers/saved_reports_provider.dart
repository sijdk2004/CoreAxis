import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

import '../../domain/saved_report_model.dart';

class SavedReportsState {
  final List<SavedReportModel> reports;
  final String searchQuery;
  final String filter; // 'all', 'favorites', 'recent', 'shared'

  SavedReportsState({
    required this.reports,
    this.searchQuery = '',
    this.filter = 'all',
  });

  SavedReportsState copyWith({
    List<SavedReportModel>? reports,
    String? searchQuery,
    String? filter,
  }) {
    return SavedReportsState(
      reports: reports ?? this.reports,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
    );
  }

  List<SavedReportModel> get filteredReports {
    var filtered = reports;

    // Apply main filter
    if (filter == 'favorites') {
      filtered = filtered.where((r) => r.isFavorite && r.status != ReportStatus.archived).toList();
    } else if (filter == 'shared') {
      filtered = filtered.where((r) => r.isShared && r.status != ReportStatus.archived).toList();
    } else if (filter == 'recent') {
      filtered = filtered.where((r) => r.status != ReportStatus.archived).toList();
      filtered.sort((a, b) => (b.lastRun ?? b.created).compareTo(a.lastRun ?? a.created));
    } else if (filter == 'archived') {
      filtered = filtered.where((r) => r.status == ReportStatus.archived).toList();
    } else {
      // 'all'
      filtered = filtered.where((r) => r.status != ReportStatus.archived).toList();
    }

    // Apply search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((r) => 
        r.name.toLowerCase().contains(query) || 
        r.owner.toLowerCase().contains(query)
      ).toList();
    }

    return filtered;
  }
}

final savedReportsProvider = NotifierProvider<SavedReportsNotifier, SavedReportsState>(() {
  return SavedReportsNotifier();
});

class SavedReportsNotifier extends Notifier<SavedReportsState> {
  final _random = Random();
  
  String _generateId() => 'rep_${DateTime.now().millisecondsSinceEpoch}${_random.nextInt(1000)}';

  @override
  SavedReportsState build() {
    return SavedReportsState(
      reports: [
        SavedReportModel(
          id: 'rep_1',
          name: 'Q3 Financial Summary',
          owner: 'Sarah Jenkins',
          created: DateTime.now().subtract(const Duration(days: 30)),
          lastRun: DateTime.now().subtract(const Duration(days: 2)),
          views: 142,
          status: ReportStatus.active,
          isFavorite: true,
          isShared: true,
        ),
        SavedReportModel(
          id: 'rep_2',
          name: 'Inventory Turnover Analysis',
          owner: 'Marcus Johnson',
          created: DateTime.now().subtract(const Duration(days: 45)),
          lastRun: DateTime.now().subtract(const Duration(days: 5)),
          views: 89,
          status: ReportStatus.active,
          isFavorite: false,
          isShared: true,
        ),
        SavedReportModel(
          id: 'rep_3',
          name: 'Employee Performance Metrics',
          owner: 'Amanda White',
          created: DateTime.now().subtract(const Duration(days: 15)),
          lastRun: DateTime.now().subtract(const Duration(hours: 12)),
          views: 45,
          status: ReportStatus.active,
          isFavorite: true,
          isShared: false,
        ),
        SavedReportModel(
          id: 'rep_4',
          name: 'Regional Sales Pipeline',
          owner: 'David Chen',
          created: DateTime.now().subtract(const Duration(days: 60)),
          lastRun: DateTime.now().subtract(const Duration(days: 10)),
          views: 210,
          status: ReportStatus.active,
          isFavorite: false,
          isShared: true,
        ),
        SavedReportModel(
          id: 'rep_5',
          name: 'Legacy Budget Plan 2024',
          owner: 'Sarah Jenkins',
          created: DateTime.now().subtract(const Duration(days: 365)),
          lastRun: DateTime.now().subtract(const Duration(days: 180)),
          views: 56,
          status: ReportStatus.archived,
          isFavorite: false,
          isShared: false,
        ),
      ],
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setFilter(String filter) {
    state = state.copyWith(filter: filter);
  }

  void toggleFavorite(String id) {
    final updatedReports = state.reports.map((r) {
      if (r.id == id) {
        return r.copyWith(isFavorite: !r.isFavorite);
      }
      return r;
    }).toList();
    state = state.copyWith(reports: updatedReports);
  }

  void duplicateReport(String id) {
    final report = state.reports.firstWhere((r) => r.id == id);
    final newReport = report.copyWith(
      id: _generateId(),
      name: '${report.name} (Copy)',
      created: DateTime.now(),
      lastRun: null,
      views: 0,
      isFavorite: false,
      isShared: false,
    );
    state = state.copyWith(reports: [...state.reports, newReport]);
  }

  void renameReport(String id, String newName) {
    final updatedReports = state.reports.map((r) {
      if (r.id == id) {
        return r.copyWith(name: newName);
      }
      return r;
    }).toList();
    state = state.copyWith(reports: updatedReports);
  }

  void archiveReport(String id) {
    final updatedReports = state.reports.map((r) {
      if (r.id == id) {
        return r.copyWith(status: ReportStatus.archived);
      }
      return r;
    }).toList();
    state = state.copyWith(reports: updatedReports);
  }

  void deleteReport(String id) {
    state = state.copyWith(
      reports: state.reports.where((r) => r.id != id).toList(),
    );
  }
}
