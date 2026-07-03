class AuditKpiMetrics {
  final int auditVolume;
  final int criticalEvents;
  final int securityIncidents;
  final int dataChanges;
  final double loginSuccessRate;
  final int workflowActivities;

  const AuditKpiMetrics({
    required this.auditVolume,
    required this.criticalEvents,
    required this.securityIncidents,
    required this.dataChanges,
    required this.loginSuccessRate,
    required this.workflowActivities,
  });
}

class ChartDataPoint {
  final String label;
  final double value;

  const ChartDataPoint(this.label, this.value);
}

class TopUser {
  final String name;
  final String avatarUrl;
  final int eventCount;
  final String role;

  const TopUser({
    required this.name,
    required this.avatarUrl,
    required this.eventCount,
    required this.role,
  });
}

class ChangedRecord {
  final String entityName;
  final String entityType;
  final int changeCount;

  const ChangedRecord({
    required this.entityName,
    required this.entityType,
    required this.changeCount,
  });
}

class CriticalAlert {
  final String id;
  final String message;
  final DateTime time;
  final String severity; // e.g., 'high', 'critical'

  const CriticalAlert({
    required this.id,
    required this.message,
    required this.time,
    required this.severity,
  });
}

class AiRecommendation {
  final String id;
  final String title;
  final String description;

  const AiRecommendation({
    required this.id,
    required this.title,
    required this.description,
  });
}

class AuditAnalyticsModel {
  final AuditKpiMetrics kpis;
  final List<ChartDataPoint> eventsTrend;
  final List<ChartDataPoint> moduleComparison;
  final List<ChartDataPoint> userComparison;
  final List<ChartDataPoint> departmentActivity;
  final List<TopUser> topUsers;
  final List<ChangedRecord> mostChangedRecords;
  final List<CriticalAlert> criticalAlerts;
  final List<AiRecommendation> aiRecommendations;
  final Map<int, Map<int, double>> peakActivityHeatmap; // dayOfWeek -> (hourOfDay -> value)
  final Map<int, Map<int, double>> securityEventsHeatmap;

  const AuditAnalyticsModel({
    required this.kpis,
    required this.eventsTrend,
    required this.moduleComparison,
    required this.userComparison,
    required this.departmentActivity,
    required this.topUsers,
    required this.mostChangedRecords,
    required this.criticalAlerts,
    required this.aiRecommendations,
    required this.peakActivityHeatmap,
    required this.securityEventsHeatmap,
  });
}
