class ExportTask {
  final String id;
  final String reportName;
  final String requestedBy;
  final String format; // PDF, Excel, CSV, JSON, PowerPoint
  final String status; // Completed, Failed, Scheduled, Processing
  final String size;
  final DateTime requestedAt;

  ExportTask({
    required this.id,
    required this.reportName,
    required this.requestedBy,
    required this.format,
    required this.status,
    required this.size,
    required this.requestedAt,
  });
}

class ExportStatistics {
  final int exportsToday;
  final double averageTimeMs;
  final int failures;

  ExportStatistics({
    required this.exportsToday,
    required this.averageTimeMs,
    required this.failures,
  });
}

class ExportCenterState {
  final List<ExportTask> tasks;
  final ExportStatistics statistics;

  ExportCenterState({
    required this.tasks,
    required this.statistics,
  });
}
