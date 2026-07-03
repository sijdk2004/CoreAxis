import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/report_analytics_model.dart';

final reportAnalyticsProvider = Provider<ReportAnalyticsState>((ref) {
  return ReportAnalyticsState(
    kpis: ReportAnalyticsKpis(
      totalViews: 12450,
      totalExports: 3420,
      totalShares: 890,
      totalFavorites: 450,
      avgExecutionTimeMs: 450.5,
    ),
    usageTrends: [
      ReportUsageTrend(date: 'Mon', views: 400),
      ReportUsageTrend(date: 'Tue', views: 550),
      ReportUsageTrend(date: 'Wed', views: 300),
      ReportUsageTrend(date: 'Thu', views: 650),
      ReportUsageTrend(date: 'Fri', views: 800),
      ReportUsageTrend(date: 'Sat', views: 250),
      ReportUsageTrend(date: 'Sun', views: 150),
    ],
    departmentUsage: [
      DepartmentUsage(department: 'Sales', percentage: 35),
      DepartmentUsage(department: 'Finance', percentage: 25),
      DepartmentUsage(department: 'HR', percentage: 15),
      DepartmentUsage(department: 'Operations', percentage: 20),
      DepartmentUsage(department: 'Other', percentage: 5),
    ],
    topReports: [
      ReportStats(id: 'RPT-001', name: 'Sales Dashboard', views: 420, trend: '+15%', status: 'Active'),
      ReportStats(id: 'RPT-002', name: 'Quarterly Revenue', views: 380, trend: '+8%', status: 'Active'),
      ReportStats(id: 'RPT-003', name: 'Employee Attrition', views: 210, trend: '-2%', status: 'Active'),
      ReportStats(id: 'RPT-004', name: 'Inventory Status', views: 195, trend: '+5%', status: 'Active'),
      ReportStats(id: 'RPT-005', name: 'Marketing ROI', views: 150, trend: '+12%', status: 'Active'),
    ],
    inactiveReports: [
      ReportStats(id: 'RPT-101', name: 'Old Audit 2024', views: 2, trend: '-90%', status: 'Inactive'),
      ReportStats(id: 'RPT-102', name: 'Legacy Payroll', views: 0, trend: '-100%', status: 'Archived'),
      ReportStats(id: 'RPT-103', name: 'Test Dashboard', views: 0, trend: '0%', status: 'Draft'),
    ],
    recommendations: [
      AiRecommendation(message: 'Sales Dashboard viewed 420 times this week. Consider optimizing its database queries.', type: 'Performance'),
      AiRecommendation(message: 'Audit Report usage increased 35%. You might want to schedule it for automated delivery.', type: 'Usage'),
      AiRecommendation(message: '3 inactive reports found. Consider archiving them to clean up the workspace.', type: 'Cleanup'),
    ],
  );
});
