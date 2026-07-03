class UserActivityAuditModel {
  final int mostActiveUsers;
  final int inactiveUsers;
  final int loginCount;
  final int workflowActions;
  final int approvals;
  final int documentAccess;

  final List<ChartDataPoint> activityTrend;
  final List<CategoryDataPoint> departmentComparison;
  final List<CategoryDataPoint> moduleUsage;
  final List<HeatmapDataPoint> loginActivityHeatmap;

  final List<UserActivityRow> tableRows;

  const UserActivityAuditModel({
    required this.mostActiveUsers,
    required this.inactiveUsers,
    required this.loginCount,
    required this.workflowActions,
    required this.approvals,
    required this.documentAccess,
    required this.activityTrend,
    required this.departmentComparison,
    required this.moduleUsage,
    required this.loginActivityHeatmap,
    required this.tableRows,
  });
}

class UserActivityRow {
  final String userId;
  final String user;
  final String department;
  final String role;
  final String lastActivity;
  final int activitiesCount;
  final String lastLogin;
  final int riskScore;

  const UserActivityRow({
    required this.userId,
    required this.user,
    required this.department,
    required this.role,
    required this.lastActivity,
    required this.activitiesCount,
    required this.lastLogin,
    required this.riskScore,
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

class HeatmapDataPoint {
  final String dayOfWeek;
  final int hourOfDay;
  final int intensity;

  const HeatmapDataPoint(this.dayOfWeek, this.hourOfDay, this.intensity);
}
