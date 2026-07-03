class DelegationRecord {
  final String id;
  final String delegator;
  final String delegate;
  final DateTime fromDate;
  final DateTime toDate;
  final String reason;
  final String status;
  final List<String> approvalTypes;
  final bool autoExpire;
  final bool notifyEmail;

  DelegationRecord({
    required this.id,
    required this.delegator,
    required this.delegate,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    required this.status,
    this.approvalTypes = const [],
    this.autoExpire = true,
    this.notifyEmail = true,
  });

  DelegationRecord copyWith({
    String? id,
    String? delegator,
    String? delegate,
    DateTime? fromDate,
    DateTime? toDate,
    String? reason,
    String? status,
    List<String>? approvalTypes,
    bool? autoExpire,
    bool? notifyEmail,
  }) {
    return DelegationRecord(
      id: id ?? this.id,
      delegator: delegator ?? this.delegator,
      delegate: delegate ?? this.delegate,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      approvalTypes: approvalTypes ?? this.approvalTypes,
      autoExpire: autoExpire ?? this.autoExpire,
      notifyEmail: notifyEmail ?? this.notifyEmail,
    );
  }
}
