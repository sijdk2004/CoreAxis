import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkflowKpis {
  final int totalWorkflows;
  final int activeWorkflows;
  final int runningExecutions;
  final int completedToday;
  final int failedExecutions;
  final String avgProcessingTime;
  final int pendingApprovals;
  final double automationRate;

  const WorkflowKpis({
    required this.totalWorkflows,
    required this.activeWorkflows,
    required this.runningExecutions,
    required this.completedToday,
    required this.failedExecutions,
    required this.avgProcessingTime,
    required this.pendingApprovals,
    required this.automationRate,
  });
}

class WorkflowExecution {
  final String id;
  final String name;
  final String category;
  final String status; // 'running', 'completed', 'failed'
  final DateTime startTime;
  final String duration;
  final String initiator;

  const WorkflowExecution({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.startTime,
    required this.duration,
    required this.initiator,
  });
}

class WorkflowTask {
  final String id;
  final String title;
  final String workflowName;
  final String assignedTo;
  final DateTime dueDate;
  final String priority;

  const WorkflowTask({
    required this.id,
    required this.title,
    required this.workflowName,
    required this.assignedTo,
    required this.dueDate,
    required this.priority,
  });
}

class WorkflowDashboardState {
  final bool isLoading;
  final String filterRange; // 'Today', 'This Week', 'This Month', 'Custom'
  final WorkflowKpis? kpis;
  final List<WorkflowExecution> recentExecutions;
  final List<WorkflowTask> pendingTasks;
  final Map<String, double> categoryDistribution;
  final List<double> executionTrend; // Mock points for sparkline

  const WorkflowDashboardState({
    this.isLoading = true,
    this.filterRange = 'This Week',
    this.kpis,
    this.recentExecutions = const [],
    this.pendingTasks = const [],
    this.categoryDistribution = const {},
    this.executionTrend = const [],
  });

  WorkflowDashboardState copyWith({
    bool? isLoading,
    String? filterRange,
    WorkflowKpis? kpis,
    List<WorkflowExecution>? recentExecutions,
    List<WorkflowTask>? pendingTasks,
    Map<String, double>? categoryDistribution,
    List<double>? executionTrend,
  }) {
    return WorkflowDashboardState(
      isLoading: isLoading ?? this.isLoading,
      filterRange: filterRange ?? this.filterRange,
      kpis: kpis ?? this.kpis,
      recentExecutions: recentExecutions ?? this.recentExecutions,
      pendingTasks: pendingTasks ?? this.pendingTasks,
      categoryDistribution: categoryDistribution ?? this.categoryDistribution,
      executionTrend: executionTrend ?? this.executionTrend,
    );
  }
}

class WorkflowDashboardNotifier extends Notifier<WorkflowDashboardState> {
  bool _initialized = false;

  @override
  WorkflowDashboardState build() {
    if (!_initialized) {
      _initialized = true;
      Future.microtask(() => loadData(state.filterRange));
    }
    return const WorkflowDashboardState();
  }

  Future<void> loadData(String range) async {
    state = state.copyWith(isLoading: true, filterRange: range);
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Generate mock data based on range to make it feel interactive
    double multiplier = 1.0;
    if (range == 'Today') multiplier = 0.2;
    if (range == 'This Month') multiplier = 4.0;

    final kpis = WorkflowKpis(
      totalWorkflows: 142,
      activeWorkflows: 108,
      runningExecutions: (24 * multiplier).round(),
      completedToday: (856 * multiplier).round(),
      failedExecutions: (12 * multiplier).round(),
      avgProcessingTime: '1m 24s',
      pendingApprovals: 45,
      automationRate: 0.88,
    );

    final recentExecutions = [
      WorkflowExecution(id: 'exec_1', name: 'Vendor Onboarding', category: 'Procurement', status: 'running', startTime: DateTime.now().subtract(const Duration(minutes: 5)), duration: '-', initiator: 'System'),
      WorkflowExecution(id: 'exec_2', name: 'Quarterly Expense Approval', category: 'Finance', status: 'completed', startTime: DateTime.now().subtract(const Duration(minutes: 45)), duration: '2m 14s', initiator: 'John Doe'),
      WorkflowExecution(id: 'exec_3', name: 'Employee Termination', category: 'HR', status: 'failed', startTime: DateTime.now().subtract(const Duration(hours: 2)), duration: '45s', initiator: 'HR System'),
      WorkflowExecution(id: 'exec_4', name: 'Inventory Restock', category: 'Operations', status: 'completed', startTime: DateTime.now().subtract(const Duration(hours: 3)), duration: '1m 02s', initiator: 'System'),
      WorkflowExecution(id: 'exec_5', name: 'Invoice Generation', category: 'Finance', status: 'completed', startTime: DateTime.now().subtract(const Duration(hours: 4)), duration: '12s', initiator: 'Billing Bot'),
    ];

    final pendingTasks = [
      WorkflowTask(id: 'task_1', title: 'Approve Expense Report EX-2034', workflowName: 'Expense Approval', assignedTo: 'Finance Team', dueDate: DateTime.now().add(const Duration(hours: 24)), priority: 'High'),
      WorkflowTask(id: 'task_2', title: 'Review Vendor Security Questionnaire', workflowName: 'Vendor Onboarding', assignedTo: 'IT Security', dueDate: DateTime.now().add(const Duration(days: 2)), priority: 'Medium'),
      WorkflowTask(id: 'task_3', title: 'Sign Lease Agreement', workflowName: 'Facility Management', assignedTo: 'Legal Dept', dueDate: DateTime.now().add(const Duration(days: 5)), priority: 'High'),
    ];

    state = state.copyWith(
      isLoading: false,
      kpis: kpis,
      recentExecutions: recentExecutions,
      pendingTasks: pendingTasks,
      categoryDistribution: {'Finance': 0.35, 'HR': 0.25, 'Operations': 0.20, 'Procurement': 0.15, 'Other': 0.05},
      executionTrend: [12, 18, 15, 25, 22, 30, 28, 35, 45, 40, 50, 48],
    );
  }

  void setFilterRange(String range) {
    if (state.filterRange == range) return;
    loadData(range);
  }
}

final workflowDashboardProvider = NotifierProvider<WorkflowDashboardNotifier, WorkflowDashboardState>(
  WorkflowDashboardNotifier.new,
);
