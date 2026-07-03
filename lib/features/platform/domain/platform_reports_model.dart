import 'package:flutter/material.dart';

class ReportKpiMetrics {
  final int totalReports;
  final int dashboards;
  final int scheduledReports;
  final int executionsToday;
  final int sharedReports;
  final int exportCount;
  final int dataSources;
  final int activeUsers;

  const ReportKpiMetrics({
    required this.totalReports,
    required this.dashboards,
    required this.scheduledReports,
    required this.executionsToday,
    required this.sharedReports,
    required this.exportCount,
    required this.dataSources,
    required this.activeUsers,
  });
}

class ChartDataPoint {
  final String label;
  final double value;

  const ChartDataPoint(this.label, this.value);
}

class ReportItem {
  final String id;
  final String title;
  final String category;
  final String views;
  final IconData icon;
  final Color color;
  final DateTime? lastRun;

  const ReportItem({
    required this.id,
    required this.title,
    required this.category,
    required this.views,
    required this.icon,
    required this.color,
    this.lastRun,
  });
}

class ScheduledJob {
  final String id;
  final String reportName;
  final String schedule; // e.g., "Daily at 8:00 AM"
  final String status; // 'Active', 'Paused', 'Failed'
  final DateTime nextRun;

  const ScheduledJob({
    required this.id,
    required this.reportName,
    required this.schedule,
    required this.status,
    required this.nextRun,
  });
}

class TopDashboardItem {
  final String id;
  final String name;
  final String department;
  final int userCount;

  const TopDashboardItem({
    required this.id,
    required this.name,
    required this.department,
    required this.userCount,
  });
}

class PlatformReportsModel {
  final ReportKpiMetrics kpis;
  final List<ChartDataPoint> usageTrend;
  final List<ChartDataPoint> mostViewedReports;
  final List<ChartDataPoint> departmentUsage;
  final List<ChartDataPoint> executionTrend;
  final List<ReportItem> recentReports;
  final List<ReportItem> favoriteReports;
  final List<ScheduledJob> scheduledJobs;
  final List<TopDashboardItem> topDashboards;
  final List<ReportItem> recentlyShared;
  
  // Filters
  final String filterTimeRange;
  final String filterDepartment;
  final String filterOrganization;

  const PlatformReportsModel({
    required this.kpis,
    required this.usageTrend,
    required this.mostViewedReports,
    required this.departmentUsage,
    required this.executionTrend,
    required this.recentReports,
    required this.favoriteReports,
    required this.scheduledJobs,
    required this.topDashboards,
    required this.recentlyShared,
    this.filterTimeRange = 'This Week',
    this.filterDepartment = 'All Departments',
    this.filterOrganization = 'All Organizations',
  });

  PlatformReportsModel copyWith({
    ReportKpiMetrics? kpis,
    List<ChartDataPoint>? usageTrend,
    List<ChartDataPoint>? mostViewedReports,
    List<ChartDataPoint>? departmentUsage,
    List<ChartDataPoint>? executionTrend,
    List<ReportItem>? recentReports,
    List<ReportItem>? favoriteReports,
    List<ScheduledJob>? scheduledJobs,
    List<TopDashboardItem>? topDashboards,
    List<ReportItem>? recentlyShared,
    String? filterTimeRange,
    String? filterDepartment,
    String? filterOrganization,
  }) {
    return PlatformReportsModel(
      kpis: kpis ?? this.kpis,
      usageTrend: usageTrend ?? this.usageTrend,
      mostViewedReports: mostViewedReports ?? this.mostViewedReports,
      departmentUsage: departmentUsage ?? this.departmentUsage,
      executionTrend: executionTrend ?? this.executionTrend,
      recentReports: recentReports ?? this.recentReports,
      favoriteReports: favoriteReports ?? this.favoriteReports,
      scheduledJobs: scheduledJobs ?? this.scheduledJobs,
      topDashboards: topDashboards ?? this.topDashboards,
      recentlyShared: recentlyShared ?? this.recentlyShared,
      filterTimeRange: filterTimeRange ?? this.filterTimeRange,
      filterDepartment: filterDepartment ?? this.filterDepartment,
      filterOrganization: filterOrganization ?? this.filterOrganization,
    );
  }
}
