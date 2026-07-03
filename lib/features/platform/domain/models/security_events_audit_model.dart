class SecurityEventsAuditModel {
  final int successfulLogins;
  final int failedLogins;
  final int lockedAccounts;
  final int passwordChanges;
  final int mfaEvents;
  final int activeSessions;

  final List<ChartDataPoint> loginTrend;
  final List<ChartDataPoint> failedLoginTrend;
  final List<CategoryDataPoint> riskDistribution;

  final List<SuspiciousActivity> suspiciousActivities;
  final List<RecentSession> recentSessions;
  final List<SecurityAlert> securityAlerts;

  final List<SecurityEventRow> tableRows;

  const SecurityEventsAuditModel({
    required this.successfulLogins,
    required this.failedLogins,
    required this.lockedAccounts,
    required this.passwordChanges,
    required this.mfaEvents,
    required this.activeSessions,
    required this.loginTrend,
    required this.failedLoginTrend,
    required this.riskDistribution,
    required this.suspiciousActivities,
    required this.recentSessions,
    required this.securityAlerts,
    required this.tableRows,
  });
}

class ChartDataPoint {
  final String label;
  final double value;

  const ChartDataPoint(this.label, this.value);
}

class CategoryDataPoint {
  final String category;
  final double value;
  final String colorHex;

  const CategoryDataPoint(this.category, this.value, this.colorHex);
}

class SuspiciousActivity {
  final String title;
  final String description;
  final String timeAgo;
  final String severity; // Low, Medium, High, Critical

  const SuspiciousActivity({
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.severity,
  });
}

class RecentSession {
  final String user;
  final String ipAddress;
  final String duration;
  final bool isActive;

  const RecentSession({
    required this.user,
    required this.ipAddress,
    required this.duration,
    required this.isActive,
  });
}

class SecurityAlert {
  final String message;
  final String type; // Info, Warning, Error

  const SecurityAlert({
    required this.message,
    required this.type,
  });
}

class SecurityEventRow {
  final String timestamp;
  final String userId;
  final String user;
  final String ipAddress;
  final String browser;
  final String os;
  final String location;
  final String device;
  final String eventType;
  final String result; // Success, Failure, Blocked
  final String riskLevel; // Low, Medium, High, Critical

  const SecurityEventRow({
    required this.timestamp,
    required this.userId,
    required this.user,
    required this.ipAddress,
    required this.browser,
    required this.os,
    required this.location,
    required this.device,
    required this.eventType,
    required this.result,
    required this.riskLevel,
  });
}
