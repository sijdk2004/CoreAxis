class ReportAnalyticsKpis {
  final int totalViews;
  final int totalExports;
  final int totalShares;
  final int totalFavorites;
  final double avgExecutionTimeMs;

  ReportAnalyticsKpis({
    required this.totalViews,
    required this.totalExports,
    required this.totalShares,
    required this.totalFavorites,
    required this.avgExecutionTimeMs,
  });
}

class ReportUsageTrend {
  final String date;
  final int views;

  ReportUsageTrend({required this.date, required this.views});
}

class DepartmentUsage {
  final String department;
  final double percentage;

  DepartmentUsage({required this.department, required this.percentage});
}

class ReportStats {
  final String id;
  final String name;
  final int views;
  final String trend;
  final String status;

  ReportStats({
    required this.id,
    required this.name,
    required this.views,
    required this.trend,
    required this.status,
  });
}

class AiRecommendation {
  final String message;
  final String type;

  AiRecommendation({required this.message, required this.type});
}

class ReportAnalyticsState {
  final ReportAnalyticsKpis kpis;
  final List<ReportUsageTrend> usageTrends;
  final List<DepartmentUsage> departmentUsage;
  final List<ReportStats> topReports;
  final List<ReportStats> inactiveReports;
  final List<AiRecommendation> recommendations;

  ReportAnalyticsState({
    required this.kpis,
    required this.usageTrends,
    required this.departmentUsage,
    required this.topReports,
    required this.inactiveReports,
    required this.recommendations,
  });
}
