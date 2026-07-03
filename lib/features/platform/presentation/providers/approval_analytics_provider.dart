import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/approval_analytics_data.dart';
import 'dart:math';

class ApprovalAnalyticsState {
  final ApprovalAnalyticsData? data;
  final String dateRange;

  ApprovalAnalyticsState({
    this.data,
    this.dateRange = 'Last 30 Days',
  });

  ApprovalAnalyticsState copyWith({
    ApprovalAnalyticsData? data,
    String? dateRange,
  }) {
    return ApprovalAnalyticsState(
      data: data ?? this.data,
      dateRange: dateRange ?? this.dateRange,
    );
  }
}

class ApprovalAnalyticsNotifier extends Notifier<ApprovalAnalyticsState> {
  @override
  ApprovalAnalyticsState build() {
    return ApprovalAnalyticsState(data: _generateMockData('Last 30 Days'));
  }

  void setDateRange(String range) {
    // Generate new mock data based on the range to simulate loading
    state = state.copyWith(
      dateRange: range,
      data: _generateMockData(range),
    );
  }

  ApprovalAnalyticsData _generateMockData(String range) {
    final rand = Random();
    
    // Simulate varying data based on range
    double multiplier = 1.0;
    if (range == 'Last 7 Days') multiplier = 0.25;
    if (range == 'Last 90 Days') multiplier = 3.0;

    return ApprovalAnalyticsData(
      kpis: {
        'Approval Volume': '${(1245 * multiplier).toInt()}',
        'Average SLA': '${(4.2 * (0.8 + rand.nextDouble() * 0.4)).toStringAsFixed(1)} hrs',
        'Escalation Rate': '${(8.5 * (0.8 + rand.nextDouble() * 0.4)).toStringAsFixed(1)}%',
        'Approval Duration': '${(1.8 * (0.8 + rand.nextDouble() * 0.4)).toStringAsFixed(1)} days',
        'Rejection Rate': '${(12.4 * (0.8 + rand.nextDouble() * 0.4)).toStringAsFixed(1)}%',
        'Delegation Rate': '${(5.2 * (0.8 + rand.nextDouble() * 0.4)).toStringAsFixed(1)}%',
      },
      trendData: List.generate(7, (index) {
        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return ChartDataPoint(days[index], 50 + rand.nextDouble() * 100 * multiplier);
      }),
      departmentData: [
        CategoryDataPoint('Finance', 450 * multiplier),
        CategoryDataPoint('HR', 320 * multiplier),
        CategoryDataPoint('IT', 210 * multiplier),
        CategoryDataPoint('Legal', 150 * multiplier),
        CategoryDataPoint('Operations', 280 * multiplier),
      ],
      slaCompliance: [
        CategoryDataPoint('Within SLA', 85, '#4CAF50'), // Green
        CategoryDataPoint('Breached SLA', 15, '#F44336'), // Red
      ],
      approverPerformance: [
        PerformanceDataPoint('John Doe', 120 * multiplier, 2.4),
        PerformanceDataPoint('Jane Smith', 85 * multiplier, 1.2),
        PerformanceDataPoint('Mike Johnson', 45 * multiplier, 8.5), // Bottleneck
        PerformanceDataPoint('Sarah Williams', 210 * multiplier, 0.8), // Fast
        PerformanceDataPoint('Robert Chen', 65 * multiplier, 4.2),
      ],
      activityHeatmap: List.generate(30, (index) {
        // Generating random scattered points for a mock heatmap
        return HeatmapDataPoint(rand.nextInt(7), 8 + rand.nextInt(10), rand.nextInt(100));
      }),
      topBottlenecks: [
        'IT Hardware Requests (Avg 5 days)',
        'Legal Contract Review (Avg 4.2 days)',
        'Mike Johnson (Avg 8.5 hours/req)'
      ],
      slowestApprovers: ['Mike Johnson', 'Robert Chen'],
      fastestApprovers: ['Sarah Williams', 'Jane Smith'],
      pendingTrends: 'Pending volume increased by 15% this week, primarily driven by Q3 Budget Approvals.',
      aiRecommendations: [
        'Finance approvals exceed SLA by 12%. Consider adding a secondary approver for POs under \$5,000.',
        'Purchase approvals under \$500 can be fully automated, potentially saving 45 hours/week.',
        'Mike Johnson has a backlog of 45 requests. Recommend temporary delegation to Jane Smith.',
      ],
    );
  }
}

final approvalAnalyticsProvider = NotifierProvider<ApprovalAnalyticsNotifier, ApprovalAnalyticsState>(() {
  return ApprovalAnalyticsNotifier();
});
