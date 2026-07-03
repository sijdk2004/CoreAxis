import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../domain/platform_reports_model.dart';

final platformReportsProvider = NotifierProvider<PlatformReportsNotifier, AsyncValue<PlatformReportsModel>>(() {
  return PlatformReportsNotifier();
});

class PlatformReportsNotifier extends Notifier<AsyncValue<PlatformReportsModel>> {
  @override
  AsyncValue<PlatformReportsModel> build() {
    _loadMockData();
    return const AsyncValue.loading();
  }

  Future<void> _loadMockData() async {
    await Future.delayed(const Duration(milliseconds: 600));

    final mockModel = PlatformReportsModel(
      kpis: const ReportKpiMetrics(
        totalReports: 142,
        dashboards: 18,
        scheduledReports: 56,
        executionsToday: 894,
        sharedReports: 34,
        exportCount: 1205,
        dataSources: 12,
        activeUsers: 843,
      ),
      usageTrend: [
        const ChartDataPoint('Mon', 450),
        const ChartDataPoint('Tue', 520),
        const ChartDataPoint('Wed', 850),
        const ChartDataPoint('Thu', 740),
        const ChartDataPoint('Fri', 610),
        const ChartDataPoint('Sat', 230),
        const ChartDataPoint('Sun', 190),
      ],
      mostViewedReports: [
        const ChartDataPoint('Q3 Financials', 1240),
        const ChartDataPoint('User Activity', 980),
        const ChartDataPoint('Sales Pipeline', 850),
        const ChartDataPoint('HR Headcount', 620),
        const ChartDataPoint('Inventory Level', 450),
      ],
      departmentUsage: [
        const ChartDataPoint('Finance', 35),
        const ChartDataPoint('Sales', 25),
        const ChartDataPoint('HR', 20),
        const ChartDataPoint('IT', 15),
        const ChartDataPoint('Ops', 5),
      ],
      executionTrend: [
        const ChartDataPoint('W1', 4200),
        const ChartDataPoint('W2', 4800),
        const ChartDataPoint('W3', 5100),
        const ChartDataPoint('W4', 6500),
      ],
      recentReports: [
        ReportItem(
          id: 'RPT-1',
          title: 'Monthly Revenue',
          category: 'Finance',
          views: '1.2k',
          icon: LucideIcons.dollarSign,
          color: Colors.green,
          lastRun: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        ReportItem(
          id: 'RPT-2',
          title: 'Active Users List',
          category: 'IT Security',
          views: '840',
          icon: LucideIcons.users,
          color: Colors.blue,
          lastRun: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        ReportItem(
          id: 'RPT-3',
          title: 'Q3 Sales Targets',
          category: 'Sales',
          views: '2.4k',
          icon: LucideIcons.target,
          color: Colors.orange,
          lastRun: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
      favoriteReports: [
        const ReportItem(id: 'RPT-1', title: 'Monthly Revenue', category: 'Finance', views: '1.2k', icon: LucideIcons.dollarSign, color: Colors.green),
        const ReportItem(id: 'RPT-4', title: 'System Uptime', category: 'IT', views: '500', icon: LucideIcons.activity, color: Colors.purple),
      ],
      scheduledJobs: [
        ScheduledJob(id: 'JOB-1', reportName: 'Daily Sales Digest', schedule: 'Daily at 8:00 AM', status: 'Active', nextRun: DateTime.now().add(const Duration(hours: 12))),
        ScheduledJob(id: 'JOB-2', reportName: 'Weekly Backup Log', schedule: 'Sunday at 12:00 AM', status: 'Active', nextRun: DateTime.now().add(const Duration(days: 4))),
        ScheduledJob(id: 'JOB-3', reportName: 'Monthly Compliance', schedule: '1st of Month at 9:00 AM', status: 'Paused', nextRun: DateTime.now().add(const Duration(days: 15))),
      ],
      topDashboards: const [
        TopDashboardItem(id: 'DB-1', name: 'Executive Overview', department: 'Management', userCount: 45),
        TopDashboardItem(id: 'DB-2', name: 'Sales Pipeline', department: 'Sales', userCount: 120),
        TopDashboardItem(id: 'DB-3', name: 'System Health', department: 'IT', userCount: 35),
      ],
      recentlyShared: [
        const ReportItem(id: 'RPT-5', title: 'Q2 Audit Findings', category: 'Compliance', views: '320', icon: LucideIcons.fileCheck, color: Colors.red),
        const ReportItem(id: 'RPT-6', title: 'Marketing Spend', category: 'Marketing', views: '890', icon: LucideIcons.pieChart, color: Colors.pink),
      ],
    );

    state = AsyncValue.data(mockModel);
  }

  void updateFilters({String? timeRange, String? department, String? organization}) {
    if (state.value != null) {
      state = AsyncValue.data(state.value!.copyWith(
        filterTimeRange: timeRange,
        filterDepartment: department,
        filterOrganization: organization,
      ));
    }
  }
}
