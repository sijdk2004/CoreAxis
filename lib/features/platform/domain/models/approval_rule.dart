class ApprovalRule {
  final String id;
  final String name;
  final String category;
  final String conditions;
  final List<String> approvers;
  final String escalation;
  final String sla;
  final bool isActive;

  ApprovalRule({
    required this.id,
    required this.name,
    required this.category,
    required this.conditions,
    required this.approvers,
    required this.escalation,
    required this.sla,
    this.isActive = true,
  });

  ApprovalRule copyWith({
    String? id,
    String? name,
    String? category,
    String? conditions,
    List<String>? approvers,
    String? escalation,
    String? sla,
    bool? isActive,
  }) {
    return ApprovalRule(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      conditions: conditions ?? this.conditions,
      approvers: approvers ?? this.approvers,
      escalation: escalation ?? this.escalation,
      sla: sla ?? this.sla,
      isActive: isActive ?? this.isActive,
    );
  }
}
