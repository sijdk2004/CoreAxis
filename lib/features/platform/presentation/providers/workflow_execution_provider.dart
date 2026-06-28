import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/workflow_execution.dart';
import '../../data/mock_workflow_execution_repository.dart';

class WorkflowExecutionState {
  final bool isLoading;
  final List<WorkflowExecution> executions;
  final String selectedWorkflow;
  final String selectedStatus;
  final String selectedDate;
  final String selectedUser;
  final bool autoRefresh;

  WorkflowExecutionState({
    this.isLoading = true,
    this.executions = const <WorkflowExecution>[],
    this.selectedWorkflow = 'All Workflows',
    this.selectedStatus = 'All Statuses',
    this.selectedDate = 'Any Time',
    this.selectedUser = 'All Users',
    this.autoRefresh = false,
  });

  WorkflowExecutionState copyWith({
    bool? isLoading,
    List<WorkflowExecution>? executions,
    String? selectedWorkflow,
    String? selectedStatus,
    String? selectedDate,
    String? selectedUser,
    bool? autoRefresh,
  }) {
    return WorkflowExecutionState(
      isLoading: isLoading ?? this.isLoading,
      executions: executions ?? this.executions,
      selectedWorkflow: selectedWorkflow ?? this.selectedWorkflow,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedUser: selectedUser ?? this.selectedUser,
      autoRefresh: autoRefresh ?? this.autoRefresh,
    );
  }

  List<WorkflowExecution> get filteredExecutions {
    return executions.where((e) {
      final matchesWorkflow = selectedWorkflow == 'All Workflows' || e.workflowName == selectedWorkflow;
      final matchesStatus = selectedStatus == 'All Statuses' || e.status == selectedStatus;
      final matchesUser = selectedUser == 'All Users' || e.startedBy == selectedUser || e.assignedUser == selectedUser;
      
      // Date filtering logic (simplified for mock)
      bool matchesDate = true;
      if (selectedDate == 'Last 24 Hours') {
        matchesDate = e.startedAt.isAfter(DateTime.now().subtract(const Duration(hours: 24)));
      } else if (selectedDate == 'Last 7 Days') {
        matchesDate = e.startedAt.isAfter(DateTime.now().subtract(const Duration(days: 7)));
      }

      return matchesWorkflow && matchesStatus && matchesUser && matchesDate;
    }).toList();
  }

  // Statistics
  int get totalRunning => executions.where((e) => e.status == 'Running').length;
  int get totalCompleted => executions.where((e) => e.status == 'Completed').length;
  int get totalFailed => executions.where((e) => e.status == 'Failed').length;
  int get totalCancelled => executions.where((e) => e.status == 'Cancelled').length;
  
  String get averageDuration {
    final completed = executions.where((e) => e.status == 'Completed');
    if (completed.isEmpty) return '0h 0m';
    int totalMinutes = 0;
    for (var e in completed) {
      totalMinutes += e.duration.inMinutes;
    }
    final avg = totalMinutes ~/ completed.length;
    return '${avg ~/ 60}h ${avg % 60}m';
  }
}

class WorkflowExecutionNotifier extends Notifier<WorkflowExecutionState> {
  Timer? _refreshTimer;

  @override
  WorkflowExecutionState build() {
    ref.onDispose(() {
      _refreshTimer?.cancel();
    });
    _loadExecutions();
    return WorkflowExecutionState();
  }

  Future<void> _loadExecutions() async {
    final repository = MockWorkflowExecutionRepository();
    final data = await repository.getExecutions();
    state = state.copyWith(isLoading: false, executions: data);
  }

  void setFilter({
    String? workflow,
    String? status,
    String? date,
    String? user,
  }) {
    state = state.copyWith(
      selectedWorkflow: workflow,
      selectedStatus: status,
      selectedDate: date,
      selectedUser: user,
    );
  }

  void toggleAutoRefresh() {
    final newValue = !state.autoRefresh;
    state = state.copyWith(autoRefresh: newValue);

    if (newValue) {
      _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        _simulateLiveUpdate();
      });
    } else {
      _refreshTimer?.cancel();
      _refreshTimer = null;
    }
  }

  void _simulateLiveUpdate() {
    // Increment duration for running executions
    final updated = state.executions.map<WorkflowExecution>((e) {
      if (e.status == 'Running') {
        return e.copyWith(duration: e.duration + const Duration(minutes: 1));
      }
      return e;
    }).toList();
    state = state.copyWith(executions: updated);
  }
}

final workflowExecutionProvider = NotifierProvider<WorkflowExecutionNotifier, WorkflowExecutionState>(() {
  return WorkflowExecutionNotifier();
});
