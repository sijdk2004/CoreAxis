import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../../domain/audit_analytics_model.dart';

final auditAnalyticsProvider = NotifierProvider<AuditAnalyticsNotifier, AsyncValue<AuditAnalyticsModel>>(() {
  return AuditAnalyticsNotifier();
});

class AuditAnalyticsNotifier extends Notifier<AsyncValue<AuditAnalyticsModel>> {
  @override
  AsyncValue<AuditAnalyticsModel> build() {
    _loadMockData();
    return const AsyncValue.loading();
  }

  Future<void> _loadMockData() async {
    await Future.delayed(const Duration(milliseconds: 600));

    final random = Random(42); // Seeded for consistency

    // Generate Heatmap Data
    Map<int, Map<int, double>> generateHeatmap(double base, double variance) {
      final map = <int, Map<int, double>>{};
      for (int day = 0; day < 7; day++) {
        map[day] = {};
        for (int hour = 0; hour < 24; hour++) {
          // Higher activity during business hours (9-17) and weekdays (1-5)
          double multiplier = 1.0;
          if (day > 0 && day < 6) multiplier *= 1.5;
          if (hour >= 9 && hour <= 17) multiplier *= 2.0;
          
          map[day]![hour] = (base * multiplier) + (random.nextDouble() * variance);
        }
      }
      return map;
    }

    final peakActivity = generateHeatmap(10, 20);
    final securityEvents = generateHeatmap(1, 5);

    // Force some anomalies
    securityEvents[3]![14] = 45.0; // Wednesday 2PM anomaly
    peakActivity[1]![3] = 80.0; // Monday 3AM anomaly

    final mockModel = AuditAnalyticsModel(
      kpis: const AuditKpiMetrics(
        auditVolume: 124592,
        criticalEvents: 43,
        securityIncidents: 12,
        dataChanges: 8432,
        loginSuccessRate: 98.4,
        workflowActivities: 1543,
      ),
      eventsTrend: [
        const ChartDataPoint('Mon', 12000),
        const ChartDataPoint('Tue', 15000),
        const ChartDataPoint('Wed', 22000),
        const ChartDataPoint('Thu', 18000),
        const ChartDataPoint('Fri', 16000),
        const ChartDataPoint('Sat', 5000),
        const ChartDataPoint('Sun', 4000),
      ],
      moduleComparison: [
        const ChartDataPoint('RBAC', 35),
        const ChartDataPoint('Documents', 25),
        const ChartDataPoint('Workflows', 20),
        const ChartDataPoint('Auth', 15),
        const ChartDataPoint('Settings', 5),
      ],
      userComparison: [
        const ChartDataPoint('Internal', 65),
        const ChartDataPoint('Partners', 20),
        const ChartDataPoint('API', 15),
      ],
      departmentActivity: [
        const ChartDataPoint('IT', 4500),
        const ChartDataPoint('HR', 2100),
        const ChartDataPoint('Finance', 3200),
        const ChartDataPoint('Sales', 1800),
      ],
      topUsers: const [
        TopUser(name: 'System Admin', avatarUrl: 'https://i.pravatar.cc/150?u=admin', eventCount: 5432, role: 'Super Admin'),
        TopUser(name: 'API Service', avatarUrl: 'https://i.pravatar.cc/150?u=api', eventCount: 4120, role: 'System'),
        TopUser(name: 'John Doe', avatarUrl: 'https://i.pravatar.cc/150?u=john', eventCount: 890, role: 'IT Manager'),
      ],
      mostChangedRecords: const [
        ChangedRecord(entityName: 'Invoice Approval', entityType: 'Workflow', changeCount: 142),
        ChangedRecord(entityName: 'Q3 Financials', entityType: 'Document', changeCount: 85),
        ChangedRecord(entityName: 'Partner Access Role', entityType: 'RBAC Policy', changeCount: 34),
      ],
      criticalAlerts: [
        CriticalAlert(id: 'ALT-1', message: 'Multiple failed logins detected from unfamiliar IP.', time: DateTime.now().subtract(const Duration(minutes: 15)), severity: 'critical'),
        CriticalAlert(id: 'ALT-2', message: 'Mass document deletion initiated by Finance User.', time: DateTime.now().subtract(const Duration(hours: 2)), severity: 'high'),
      ],
      aiRecommendations: const [
        AiRecommendation(id: 'AI-1', title: 'RBAC Changes Increased', description: 'RBAC role assignments increased by 40% this week. Consider reviewing recent privilege escalations.'),
        AiRecommendation(id: 'AI-2', title: 'Document Access Anomalies', description: 'Unusual access patterns detected on confidential HR documents outside business hours.'),
        AiRecommendation(id: 'AI-3', title: 'Workflow Overrides', description: 'Manual workflow overrides spiked yesterday. Review approval chains for bottlenecks.'),
      ],
      peakActivityHeatmap: peakActivity,
      securityEventsHeatmap: securityEvents,
    );

    state = AsyncValue.data(mockModel);
  }
}
