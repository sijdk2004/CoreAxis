import '../domain/models/workflow_execution.dart';

class MockWorkflowExecutionRepository {
  Future<List<WorkflowExecution>> getExecutions() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    return [
      WorkflowExecution(
        id: 'EXE-2024-001',
        workflowName: 'Standard PO Approval',
        startedBy: 'John Doe',
        startedAt: now.subtract(const Duration(hours: 2)),
        currentStep: 'Manager Review',
        assignedUser: 'Jane Smith',
        status: 'Running',
        duration: const Duration(hours: 2),
      ),
      WorkflowExecution(
        id: 'EXE-2024-002',
        workflowName: 'Employee Onboarding',
        startedBy: 'System',
        startedAt: now.subtract(const Duration(days: 1)),
        currentStep: 'IT Setup',
        assignedUser: 'IT Support Team',
        status: 'Running',
        duration: const Duration(days: 1, hours: 4),
      ),
      WorkflowExecution(
        id: 'EXE-2024-003',
        workflowName: 'Expense Reimbursement',
        startedBy: 'Alice Wong',
        startedAt: now.subtract(const Duration(days: 2)),
        currentStep: 'Completed',
        assignedUser: '-',
        status: 'Completed',
        duration: const Duration(hours: 12),
      ),
      WorkflowExecution(
        id: 'EXE-2024-004',
        workflowName: 'High Value PO Approval',
        startedBy: 'Bob Builder',
        startedAt: now.subtract(const Duration(minutes: 45)),
        currentStep: 'Finance Approval',
        assignedUser: 'CFO',
        status: 'Failed',
        duration: const Duration(minutes: 45),
      ),
      WorkflowExecution(
        id: 'EXE-2024-005',
        workflowName: 'Leave Request',
        startedBy: 'Charlie Brown',
        startedAt: now.subtract(const Duration(days: 5)),
        currentStep: 'Cancelled',
        assignedUser: '-',
        status: 'Cancelled',
        duration: const Duration(hours: 1),
      ),
    ];
  }

  Future<ExecutionDetail> getExecutionDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();

    return ExecutionDetail(
      id: id,
      timeline: [
        ExecutionEvent(timestamp: now.subtract(const Duration(hours: 2)), node: 'Start Node', action: 'Initiated', user: 'System', status: 'Success'),
        ExecutionEvent(timestamp: now.subtract(const Duration(hours: 1, minutes: 55)), node: 'Check Budget', action: 'Evaluated Condition', user: 'System', status: 'Success'),
        ExecutionEvent(timestamp: now.subtract(const Duration(hours: 1)), node: 'Manager Review', action: 'Pending Action', user: 'Jane Smith', status: 'Pending'),
      ],
      currentNode: 'Manager Review',
      previousNodes: ['Start Node', 'Check Budget'],
      logs: [
        '${now.subtract(const Duration(hours: 2)).toIso8601String()}: Workflow execution started.',
        '${now.subtract(const Duration(hours: 1, minutes: 55)).toIso8601String()}: Budget check passed. Available budget: \$50,000.',
        '${now.subtract(const Duration(hours: 1)).toIso8601String()}: Task assigned to Jane Smith.',
      ],
      variables: {
        'poAmount': '15000',
        'department': 'Marketing',
        'isHighValue': 'true',
      },
      errors: id == 'EXE-2024-004' ? ['Insufficient approval authority for amount > \$10,000.'] : [],
    );
  }
}
