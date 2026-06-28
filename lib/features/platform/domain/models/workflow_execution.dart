class WorkflowExecution {
  final String id;
  final String workflowName;
  final String startedBy;
  final DateTime startedAt;
  final String currentStep;
  final String assignedUser;
  final String status; // 'Running', 'Completed', 'Failed', 'Cancelled'
  final Duration duration;

  const WorkflowExecution({
    required this.id,
    required this.workflowName,
    required this.startedBy,
    required this.startedAt,
    required this.currentStep,
    required this.assignedUser,
    required this.status,
    required this.duration,
  });

  WorkflowExecution copyWith({
    String? id,
    String? workflowName,
    String? startedBy,
    DateTime? startedAt,
    String? currentStep,
    String? assignedUser,
    String? status,
    Duration? duration,
  }) {
    return WorkflowExecution(
      id: id ?? this.id,
      workflowName: workflowName ?? this.workflowName,
      startedBy: startedBy ?? this.startedBy,
      startedAt: startedAt ?? this.startedAt,
      currentStep: currentStep ?? this.currentStep,
      assignedUser: assignedUser ?? this.assignedUser,
      status: status ?? this.status,
      duration: duration ?? this.duration,
    );
  }
}

class ExecutionDetail {
  final String id;
  final List<ExecutionEvent> timeline;
  final String currentNode;
  final List<String> previousNodes;
  final List<String> logs;
  final Map<String, String> variables;
  final List<String> errors;

  const ExecutionDetail({
    required this.id,
    required this.timeline,
    required this.currentNode,
    required this.previousNodes,
    required this.logs,
    required this.variables,
    required this.errors,
  });
}

class ExecutionEvent {
  final DateTime timestamp;
  final String node;
  final String action;
  final String user;
  final String status;

  const ExecutionEvent({
    required this.timestamp,
    required this.node,
    required this.action,
    required this.user,
    required this.status,
  });
}
