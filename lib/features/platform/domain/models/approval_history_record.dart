class ApprovalHistoryRecord {
  final String id;
  final String workflow;
  final String requestType;
  final String approvedBy;
  final String decision;
  final DateTime decisionDate;
  final String duration;
  final String comments;
  final String department;
  final String priority;

  ApprovalHistoryRecord({
    required this.id,
    required this.workflow,
    required this.requestType,
    required this.approvedBy,
    required this.decision,
    required this.decisionDate,
    required this.duration,
    required this.comments,
    required this.department,
    required this.priority,
  });
}
