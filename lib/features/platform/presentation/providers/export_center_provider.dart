import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/export_center_model.dart';

final exportCenterProvider = NotifierProvider<ExportCenterNotifier, ExportCenterState>(() {
  return ExportCenterNotifier();
});

class ExportCenterNotifier extends Notifier<ExportCenterState> {
  @override
  ExportCenterState build() {
    return ExportCenterState(
      statistics: ExportStatistics(
        exportsToday: 124,
        averageTimeMs: 1450.5,
        failures: 2,
      ),
      tasks: [
        ExportTask(
          id: 'EXP-1001',
          reportName: 'Q3 Financial Overview',
          requestedBy: 'Alice Smith',
          format: 'PDF',
          status: 'Completed',
          size: '2.4 MB',
          requestedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        ExportTask(
          id: 'EXP-1002',
          reportName: 'Employee Attendance',
          requestedBy: 'Bob Johnson',
          format: 'Excel',
          status: 'Processing',
          size: '--',
          requestedAt: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
        ExportTask(
          id: 'EXP-1003',
          reportName: 'Inventory Status',
          requestedBy: 'Charlie Brown',
          format: 'CSV',
          status: 'Failed',
          size: '0 KB',
          requestedAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        ExportTask(
          id: 'EXP-1004',
          reportName: 'Marketing Campaign ROI',
          requestedBy: 'Diana Prince',
          format: 'PowerPoint',
          status: 'Scheduled',
          size: '--',
          requestedAt: DateTime.now().add(const Duration(hours: 2)),
        ),
        ExportTask(
          id: 'EXP-1005',
          reportName: 'System Audit Logs',
          requestedBy: 'Eve Adams',
          format: 'JSON',
          status: 'Completed',
          size: '15.2 MB',
          requestedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        ExportTask(
          id: 'EXP-1006',
          reportName: 'Monthly Sales Report',
          requestedBy: 'Frank Castle',
          format: 'PDF',
          status: 'Completed',
          size: '1.1 MB',
          requestedAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
        ),
      ],
    );
  }

  void deleteTask(String id) {
    state = ExportCenterState(
      statistics: state.statistics,
      tasks: state.tasks.where((t) => t.id != id).toList(),
    );
  }

  void retryTask(String id) {
    final updatedTasks = state.tasks.map((t) {
      if (t.id == id) {
        return ExportTask(
          id: t.id,
          reportName: t.reportName,
          requestedBy: t.requestedBy,
          format: t.format,
          status: 'Processing',
          size: '--',
          requestedAt: DateTime.now(),
        );
      }
      return t;
    }).toList();

    state = ExportCenterState(
      statistics: state.statistics,
      tasks: updatedTasks,
    );
  }
}
