import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── STATE MODEL ────────────────────────────────────────────────────────
class WorkflowAnalyticsState {
  final bool isLoading;
  
  // KPIs
  final double automationRate; // percentage
  final String avgCompletionTime;
  final double failureRate; // percentage
  final double approvalSLA; // percentage
  final int escalations;

  // Chart Data
  final List<double> executionTrend; // 7 data points
  final Map<String, int> approvalBottlenecks; // Department -> Count
  final Map<String, double> workflowDuration; // Workflow Name -> Hours
  final Map<String, double> departmentComparison; // Department -> %

  // Heatmap Data (Day x Hour) 7x24, value 0.0 to 1.0
  final List<List<double>> heatmapData;

  // Lists
  final List<Map<String, dynamic>> topSlowWorkflows;
  final List<Map<String, dynamic>> topAutomatedProcesses;
  final List<String> optimizationSuggestions;
  final List<String> aiRecommendations;

  WorkflowAnalyticsState({
    this.isLoading = false,
    this.automationRate = 0,
    this.avgCompletionTime = '',
    this.failureRate = 0,
    this.approvalSLA = 0,
    this.escalations = 0,
    this.executionTrend = const [],
    this.approvalBottlenecks = const {},
    this.workflowDuration = const {},
    this.departmentComparison = const {},
    this.heatmapData = const [],
    this.topSlowWorkflows = const [],
    this.topAutomatedProcesses = const [],
    this.optimizationSuggestions = const [],
    this.aiRecommendations = const [],
  });

  WorkflowAnalyticsState copyWith({
    bool? isLoading,
    double? automationRate,
    String? avgCompletionTime,
    double? failureRate,
    double? approvalSLA,
    int? escalations,
    List<double>? executionTrend,
    Map<String, int>? approvalBottlenecks,
    Map<String, double>? workflowDuration,
    Map<String, double>? departmentComparison,
    List<List<double>>? heatmapData,
    List<Map<String, dynamic>>? topSlowWorkflows,
    List<Map<String, dynamic>>? topAutomatedProcesses,
    List<String>? optimizationSuggestions,
    List<String>? aiRecommendations,
  }) {
    return WorkflowAnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      automationRate: automationRate ?? this.automationRate,
      avgCompletionTime: avgCompletionTime ?? this.avgCompletionTime,
      failureRate: failureRate ?? this.failureRate,
      approvalSLA: approvalSLA ?? this.approvalSLA,
      escalations: escalations ?? this.escalations,
      executionTrend: executionTrend ?? this.executionTrend,
      approvalBottlenecks: approvalBottlenecks ?? this.approvalBottlenecks,
      workflowDuration: workflowDuration ?? this.workflowDuration,
      departmentComparison: departmentComparison ?? this.departmentComparison,
      heatmapData: heatmapData ?? this.heatmapData,
      topSlowWorkflows: topSlowWorkflows ?? this.topSlowWorkflows,
      topAutomatedProcesses: topAutomatedProcesses ?? this.topAutomatedProcesses,
      optimizationSuggestions: optimizationSuggestions ?? this.optimizationSuggestions,
      aiRecommendations: aiRecommendations ?? this.aiRecommendations,
    );
  }
}

// ─── PROVIDER ──────────────────────────────────────────────────────────
class WorkflowAnalyticsNotifier extends Notifier<WorkflowAnalyticsState> {
  
  @override
  WorkflowAnalyticsState build() {
    _loadMockData();
    return WorkflowAnalyticsState(isLoading: true);
  }

  Future<void> _loadMockData() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Generate fake heatmap data (7 days, 24 hours)
    final heatmap = List.generate(7, (d) => List.generate(24, (h) {
      if (d > 4) return 0.1; // Weekend low activity
      if (h < 8 || h > 18) return 0.2; // Off-hours low activity
      if (h == 10 || h == 14) return 0.9; // Peak hours
      return 0.5; // Normal hours
    }));

    state = state.copyWith(
      isLoading: false,
      automationRate: 78.5,
      avgCompletionTime: '4h 15m',
      failureRate: 2.1,
      approvalSLA: 94.2,
      escalations: 12,
      executionTrend: [150, 180, 160, 210, 250, 230, 290],
      approvalBottlenecks: {
        'Finance': 45,
        'Legal': 32,
        'HR': 15,
        'IT Support': 8,
      },
      workflowDuration: {
        'Onboarding': 24.5,
        'PO Approval': 12.0,
        'Leave Request': 4.2,
        'Reimbursement': 8.5,
      },
      departmentComparison: {
        'Sales': 35.0,
        'Engineering': 25.0,
        'Marketing': 20.0,
        'Operations': 20.0,
      },
      heatmapData: heatmap,
      topSlowWorkflows: [
        {'name': 'Vendor Onboarding', 'duration': '72h', 'trend': '+12%'},
        {'name': 'Contract Approval', 'duration': '48h', 'trend': '+5%'},
        {'name': 'Annual Review', 'duration': '120h', 'trend': '-2%'},
      ],
      topAutomatedProcesses: [
        {'name': 'Password Reset', 'executions': '1,245', 'savings': '41h'},
        {'name': 'Access Request', 'executions': '890', 'savings': '29h'},
        {'name': 'Server Provisioning', 'executions': '420', 'savings': '56h'},
      ],
      optimizationSuggestions: [
        'Finance approvals take 45% longer than average. Consider adding a secondary approver.',
        'Vendor Onboarding drops off at the "Document Upload" step. Review UI clarity.',
      ],
      aiRecommendations: [
        'Auto-approve Expense Reports under \$50 based on historical 99% manual approval rate.',
        'Shift IT server provisioning batch jobs from 10 AM to 2 AM to reduce peak load by 15%.',
      ],
    );
  }

  void refresh() {
    state = state.copyWith(isLoading: true);
    _loadMockData();
  }
}

final workflowAnalyticsProvider = NotifierProvider<WorkflowAnalyticsNotifier, WorkflowAnalyticsState>(() {
  return WorkflowAnalyticsNotifier();
});
