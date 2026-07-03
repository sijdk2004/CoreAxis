import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/ai_dashboard_model.dart';
import 'dart:math';

final aiDashboardProvider = NotifierProvider<AiDashboardNotifier, AiDashboardState>(() {
  return AiDashboardNotifier();
});

class AiDashboardNotifier extends Notifier<AiDashboardState> {
  @override
  AiDashboardState build() {
    Future.microtask(() => _loadData());
    return AiDashboardState(isLoading: true);
  }

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 800));

    state = state.copyWith(
      isLoading: false,
      kpis: AiKpis(
        requestsToday: 15420,
        activeUsers: 3450,
        automationHoursSaved: 850,
        recommendations: 1240,
        reportsGenerated: 310,
        workflowsTriggered: 890,
        predictionsGenerated: 4500,
        successRate: 99.8,
      ),
      usageTrends: [
        AiUsageTrend(date: 'Mon', requests: 12000),
        AiUsageTrend(date: 'Tue', requests: 14500),
        AiUsageTrend(date: 'Wed', requests: 13000),
        AiUsageTrend(date: 'Thu', requests: 15500),
        AiUsageTrend(date: 'Fri', requests: 16000),
        AiUsageTrend(date: 'Sat', requests: 8000),
        AiUsageTrend(date: 'Sun', requests: 7500),
      ],
      departmentUsage: [
        DepartmentUsage(department: 'Finance', usageCount: 4500),
        DepartmentUsage(department: 'HR', usageCount: 3200),
        DepartmentUsage(department: 'Operations', usageCount: 5100),
        DepartmentUsage(department: 'IT', usageCount: 2620),
      ],
      requestTypes: [
        RequestTypeDistribution(type: 'Data Analysis', count: 5400),
        RequestTypeDistribution(type: 'Text Generation', count: 3200),
        RequestTypeDistribution(type: 'Workflow Automation', count: 4100),
        RequestTypeDistribution(type: 'Prediction', count: 2720),
      ],
      automationTrends: [
        AutomationTrend(date: 'Mon', hoursSaved: 120),
        AutomationTrend(date: 'Tue', hoursSaved: 140),
        AutomationTrend(date: 'Wed', hoursSaved: 110),
        AutomationTrend(date: 'Thu', hoursSaved: 160),
        AutomationTrend(date: 'Fri', hoursSaved: 180),
        AutomationTrend(date: 'Sat', hoursSaved: 60),
        AutomationTrend(date: 'Sun', hoursSaved: 80),
      ],
      recentConversations: [
        RecentConversation(id: 'C-1', topic: 'Q3 Budget Variance', user: 'Alice Smith', time: '10m ago'),
        RecentConversation(id: 'C-2', topic: 'Onboarding Workflow', user: 'Bob Johnson', time: '45m ago'),
        RecentConversation(id: 'C-3', topic: 'Inventory Prediction', user: 'Charlie Brown', time: '2h ago'),
        RecentConversation(id: 'C-4', topic: 'Sales Report Gen', user: 'Diana Prince', time: '3h ago'),
      ],
      pendingSuggestions: [
        PendingSuggestion(id: 'S-1', description: 'Automate PO Approvals under \$500', impact: 'Save 15h/week'),
        PendingSuggestion(id: 'S-2', description: 'Archive obsolete documents from 2023', impact: 'Free up 45GB storage'),
        PendingSuggestion(id: 'S-3', description: 'Re-route support tickets to IT', impact: 'Reduce resolution time by 30%'),
      ],
      topFeatures: [
        'Natural Language Query',
        'Smart Form Autofill',
        'Anomaly Detection',
        'Document Summarization',
      ],
      popularPrompts: [
        '"Generate monthly sales report"',
        '"Summarize candidate resumes"',
        '"Why did Q2 expenses increase?"',
        '"Create an onboarding workflow"',
      ],
      healthStatus: [
        AiHealthStatus(service: 'LLM Inference', status: 'Operational', uptime: 100),
        AiHealthStatus(service: 'Embeddings Engine', status: 'Operational', uptime: 100),
        AiHealthStatus(service: 'Vector Database', status: 'Operational', uptime: 99),
        AiHealthStatus(service: 'Workflow Agents', status: 'Degraded', uptime: 95),
      ],
    );
  }

  void updateFilters({String? time, String? org, String? dept}) {
    state = state.copyWith(
      timeFilter: time ?? state.timeFilter,
      organizationFilter: org ?? state.organizationFilter,
      departmentFilter: dept ?? state.departmentFilter,
      isLoading: true,
    );
    _loadData();
  }
}
