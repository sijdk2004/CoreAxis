import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExecutiveDashboardState {
  final double annualRevenue;
  final double mrr;
  final double growthPercentage;
  final int activeUsers;
  final int workflowCompletions;
  final int aiInsightsGenerated;
  final int reportsViewed;
  final int notificationsSent;
  final double systemUptime;
  final double storageUsedTb;
  final double storageTotalTb;
  
  final List<double> revenueHistory; // 12 months
  final List<double> userGrowthHistory; // 12 months
  
  final List<String> recentAiInsights;

  const ExecutiveDashboardState({
    required this.annualRevenue,
    required this.mrr,
    required this.growthPercentage,
    required this.activeUsers,
    required this.workflowCompletions,
    required this.aiInsightsGenerated,
    required this.reportsViewed,
    required this.notificationsSent,
    required this.systemUptime,
    required this.storageUsedTb,
    required this.storageTotalTb,
    required this.revenueHistory,
    required this.userGrowthHistory,
    required this.recentAiInsights,
  });
}

class ExecutiveDashboardNotifier extends Notifier<ExecutiveDashboardState> {
  @override
  ExecutiveDashboardState build() {
    // Generate realistic looking mock data for an enterprise ERP
    return const ExecutiveDashboardState(
      annualRevenue: 12450000.0,
      mrr: 1150000.0,
      growthPercentage: 24.5,
      activeUsers: 8432,
      workflowCompletions: 145020,
      aiInsightsGenerated: 3405,
      reportsViewed: 12054,
      notificationsSent: 890430,
      systemUptime: 99.99,
      storageUsedTb: 42.5,
      storageTotalTb: 100.0,
      revenueHistory: [
        8.5, 8.7, 9.2, 9.1, 9.5, 10.2, 10.0, 10.5, 11.1, 11.4, 11.8, 12.45
      ],
      userGrowthHistory: [
        5000, 5200, 5600, 5800, 6100, 6400, 6700, 7000, 7300, 7800, 8100, 8432
      ],
      recentAiInsights: [
        'Predicted supply chain delay in Q4 due to logistics capacity.',
        'Identified 15% cost reduction opportunity in cloud compute usage.',
        'High churn risk detected in mid-market segment (Accounts 100-500 employees).',
      ],
    );
  }
}

final executiveDashboardProvider = NotifierProvider<ExecutiveDashboardNotifier, ExecutiveDashboardState>(
  ExecutiveDashboardNotifier.new,
);
