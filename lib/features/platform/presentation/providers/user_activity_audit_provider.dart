import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_activity_audit_model.dart';

final userActivityAuditProvider = AsyncNotifierProvider<UserActivityAuditNotifier, UserActivityAuditModel>(() {
  return UserActivityAuditNotifier();
});

class UserActivityAuditNotifier extends AsyncNotifier<UserActivityAuditModel> {
  @override
  FutureOr<UserActivityAuditModel> build() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));
    return _generateMockData();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(milliseconds: 800));
      return _generateMockData();
    });
  }

  UserActivityAuditModel _generateMockData() {
    return UserActivityAuditModel(
      mostActiveUsers: 145,
      inactiveUsers: 32,
      loginCount: 1248,
      workflowActions: 456,
      approvals: 213,
      documentAccess: 890,
      activityTrend: const [
        ChartDataPoint('08:00', 120),
        ChartDataPoint('10:00', 350),
        ChartDataPoint('12:00', 200),
        ChartDataPoint('14:00', 480),
        ChartDataPoint('16:00', 600),
        ChartDataPoint('18:00', 150),
      ],
      departmentComparison: const [
        CategoryDataPoint('Finance', 450, '#3b82f6'), // blue
        CategoryDataPoint('HR', 300, '#10b981'), // green
        CategoryDataPoint('Operations', 600, '#f59e0b'), // amber
        CategoryDataPoint('IT', 250, '#8b5cf6'), // purple
      ],
      moduleUsage: const [
        CategoryDataPoint('Documents', 40, '#3b82f6'),
        CategoryDataPoint('Workflows', 30, '#10b981'),
        CategoryDataPoint('Approvals', 20, '#f59e0b'),
        CategoryDataPoint('Settings', 10, '#8b5cf6'),
      ],
      loginActivityHeatmap: const [
        // Day 0 = Mon, 1 = Tue, etc. Hour = 0-23. Intensity = 0-10
        HeatmapDataPoint('Mon', 9, 8), HeatmapDataPoint('Mon', 10, 9), HeatmapDataPoint('Mon', 14, 5),
        HeatmapDataPoint('Tue', 9, 7), HeatmapDataPoint('Tue', 10, 8), HeatmapDataPoint('Tue', 15, 6),
        HeatmapDataPoint('Wed', 8, 5), HeatmapDataPoint('Wed', 11, 9), HeatmapDataPoint('Wed', 16, 7),
        HeatmapDataPoint('Thu', 9, 8), HeatmapDataPoint('Thu', 13, 6), HeatmapDataPoint('Thu', 17, 4),
        HeatmapDataPoint('Fri', 10, 5), HeatmapDataPoint('Fri', 11, 4), HeatmapDataPoint('Fri', 14, 3),
      ],
      tableRows: const [
        UserActivityRow(
          userId: 'USR-101',
          user: 'john.doe',
          department: 'Finance',
          role: 'Manager',
          lastActivity: 'Approved Invoice #4512',
          activitiesCount: 345,
          lastLogin: '2023-10-27 09:15',
          riskScore: 12,
        ),
        UserActivityRow(
          userId: 'USR-102',
          user: 'jane.smith',
          department: 'HR',
          role: 'Admin',
          lastActivity: 'Created Onboarding Workflow',
          activitiesCount: 890,
          lastLogin: '2023-10-27 08:30',
          riskScore: 5,
        ),
        UserActivityRow(
          userId: 'USR-103',
          user: 'system.admin',
          department: 'IT',
          role: 'Super Admin',
          lastActivity: 'Changed Role Permissions',
          activitiesCount: 1250,
          lastLogin: '2023-10-27 10:05',
          riskScore: 45,
        ),
        UserActivityRow(
          userId: 'USR-104',
          user: 'sarah.c',
          department: 'Operations',
          role: 'Coordinator',
          lastActivity: 'Uploaded Q3 Report',
          activitiesCount: 120,
          lastLogin: '2023-10-26 16:45',
          riskScore: 8,
        ),
        UserActivityRow(
          userId: 'USR-105',
          user: 'mike.t',
          department: 'Sales',
          role: 'Executive',
          lastActivity: 'Viewed Sales Dashboard',
          activitiesCount: 45,
          lastLogin: '2023-10-25 14:20',
          riskScore: 2,
        ),
        UserActivityRow(
          userId: 'USR-106',
          user: 'admin.sys',
          department: 'IT',
          role: 'Auditor',
          lastActivity: 'Exported Audit Logs',
          activitiesCount: 78,
          lastLogin: '2023-10-27 11:30',
          riskScore: 15,
        ),
      ],
    );
  }
}
