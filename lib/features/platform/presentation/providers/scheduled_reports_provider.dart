import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

import '../../domain/scheduled_report_model.dart';

class ScheduledReportsState {
  final List<ScheduledReportModel> schedules;
  final String searchQuery;
  final String filter; // 'all', 'active', 'paused', 'failed'

  ScheduledReportsState({
    required this.schedules,
    this.searchQuery = '',
    this.filter = 'all',
  });

  ScheduledReportsState copyWith({
    List<ScheduledReportModel>? schedules,
    String? searchQuery,
    String? filter,
  }) {
    return ScheduledReportsState(
      schedules: schedules ?? this.schedules,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
    );
  }

  List<ScheduledReportModel> get filteredSchedules {
    var filtered = schedules;

    // Apply filter
    if (filter == 'active') {
      filtered = filtered.where((s) => s.status == ScheduleStatus.active).toList();
    } else if (filter == 'paused') {
      filtered = filtered.where((s) => s.status == ScheduleStatus.paused).toList();
    } else if (filter == 'failed') {
      filtered = filtered.where((s) => s.status == ScheduleStatus.failed).toList();
    }

    // Apply search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((s) => 
        s.name.toLowerCase().contains(query) || 
        s.reportName.toLowerCase().contains(query)
      ).toList();
    }

    return filtered;
  }
}

final scheduledReportsProvider = NotifierProvider<ScheduledReportsNotifier, ScheduledReportsState>(() {
  return ScheduledReportsNotifier();
});

class ScheduledReportsNotifier extends Notifier<ScheduledReportsState> {
  final _random = Random();
  
  String _generateId() => 'sch_${DateTime.now().millisecondsSinceEpoch}${_random.nextInt(1000)}';

  @override
  ScheduledReportsState build() {
    return ScheduledReportsState(
      schedules: [
        ScheduledReportModel(
          id: 'sch_1',
          name: 'Weekly Sales Summary',
          reportName: 'Global Sales Dashboard',
          frequency: ScheduleFrequency.weekly,
          recipients: ['exec-team@example.com'],
          deliveryMethods: [DeliveryMethod.email],
          exportFormat: ExportFormat.pdf,
          lastRun: DateTime.now().subtract(const Duration(days: 2)),
          nextRun: DateTime.now().add(const Duration(days: 5)),
          status: ScheduleStatus.active,
        ),
        ScheduledReportModel(
          id: 'sch_2',
          name: 'Daily Inventory Alerts',
          reportName: 'Stock Level Report',
          frequency: ScheduleFrequency.daily,
          recipients: ['inventory-managers@example.com', 'warehouse@example.com'],
          deliveryMethods: [DeliveryMethod.email, DeliveryMethod.sms],
          exportFormat: ExportFormat.csv,
          lastRun: DateTime.now().subtract(const Duration(hours: 14)),
          nextRun: DateTime.now().add(const Duration(hours: 10)),
          status: ScheduleStatus.active,
        ),
        ScheduledReportModel(
          id: 'sch_3',
          name: 'Monthly Financial Packet',
          reportName: 'Q3 Financial Summary',
          frequency: ScheduleFrequency.monthly,
          recipients: ['finance@example.com', 'board@example.com'],
          deliveryMethods: [DeliveryMethod.email, DeliveryMethod.inApp],
          exportFormat: ExportFormat.excel,
          lastRun: null,
          nextRun: DateTime.now().add(const Duration(days: 12)),
          status: ScheduleStatus.paused,
        ),
        ScheduledReportModel(
          id: 'sch_4',
          name: 'Annual Performance Review',
          reportName: 'Employee Performance Metrics',
          frequency: ScheduleFrequency.yearly,
          recipients: ['hr@example.com'],
          deliveryMethods: [DeliveryMethod.email],
          exportFormat: ExportFormat.pdf,
          lastRun: DateTime.now().subtract(const Duration(days: 180)),
          nextRun: DateTime.now().add(const Duration(days: 185)),
          status: ScheduleStatus.failed,
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

  void addSchedule(ScheduledReportModel schedule) {
    state = state.copyWith(schedules: [...state.schedules, schedule]);
  }

  void toggleScheduleStatus(String id) {
    final updatedSchedules = state.schedules.map((s) {
      if (s.id == id) {
        final newStatus = s.status == ScheduleStatus.active 
            ? ScheduleStatus.paused 
            : ScheduleStatus.active;
        return s.copyWith(status: newStatus);
      }
      return s;
    }).toList();
    state = state.copyWith(schedules: updatedSchedules);
  }

  void deleteSchedule(String id) {
    state = state.copyWith(
      schedules: state.schedules.where((s) => s.id != id).toList(),
    );
  }

  ScheduledReportModel createNewSchedule({
    required String name,
    required String reportName,
    required ScheduleFrequency frequency,
    required List<String> recipients,
    required List<DeliveryMethod> deliveryMethods,
    required ExportFormat exportFormat,
  }) {
    final now = DateTime.now();
    DateTime nextRun;
    switch (frequency) {
      case ScheduleFrequency.daily:
        nextRun = now.add(const Duration(days: 1));
        break;
      case ScheduleFrequency.weekly:
        nextRun = now.add(const Duration(days: 7));
        break;
      case ScheduleFrequency.monthly:
        nextRun = now.add(const Duration(days: 30));
        break;
      case ScheduleFrequency.yearly:
        nextRun = now.add(const Duration(days: 365));
        break;
    }

    final newSchedule = ScheduledReportModel(
      id: _generateId(),
      name: name,
      reportName: reportName,
      frequency: frequency,
      recipients: recipients,
      deliveryMethods: deliveryMethods,
      exportFormat: exportFormat,
      nextRun: nextRun,
      status: ScheduleStatus.active,
    );

    addSchedule(newSchedule);
    return newSchedule;
  }
}
