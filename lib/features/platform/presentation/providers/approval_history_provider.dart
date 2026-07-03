import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/approval_history_record.dart';

enum ApprovalHistoryViewMode { table, card, timeline }

class ApprovalHistoryState {
  final List<ApprovalHistoryRecord> records;
  final String searchQuery;
  final ApprovalHistoryViewMode viewMode;
  
  // Filters
  final String? selectedWorkflow;
  final String? selectedDecision;
  final String? selectedDepartment;
  final String? selectedPriority;

  ApprovalHistoryState({
    required this.records,
    this.searchQuery = '',
    this.viewMode = ApprovalHistoryViewMode.table,
    this.selectedWorkflow,
    this.selectedDecision,
    this.selectedDepartment,
    this.selectedPriority,
  });

  ApprovalHistoryState copyWith({
    List<ApprovalHistoryRecord>? records,
    String? searchQuery,
    ApprovalHistoryViewMode? viewMode,
    String? selectedWorkflow,
    String? selectedDecision,
    String? selectedDepartment,
    String? selectedPriority,
  }) {
    return ApprovalHistoryState(
      records: records ?? this.records,
      searchQuery: searchQuery ?? this.searchQuery,
      viewMode: viewMode ?? this.viewMode,
      selectedWorkflow: selectedWorkflow ?? this.selectedWorkflow,
      selectedDecision: selectedDecision ?? this.selectedDecision,
      selectedDepartment: selectedDepartment ?? this.selectedDepartment,
      selectedPriority: selectedPriority ?? this.selectedPriority,
    );
  }
}

class ApprovalHistoryNotifier extends Notifier<ApprovalHistoryState> {
  @override
  ApprovalHistoryState build() {
    return ApprovalHistoryState(records: _mockRecords);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setViewMode(ApprovalHistoryViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }
  
  void setFilters({
    String? workflow,
    String? decision,
    String? department,
    String? priority,
  }) {
    state = state.copyWith(
      selectedWorkflow: workflow,
      selectedDecision: decision,
      selectedDepartment: department,
      selectedPriority: priority,
    );
  }

  List<ApprovalHistoryRecord> get filteredRecords {
    return state.records.where((record) {
      final matchesSearch = state.searchQuery.isEmpty ||
          record.id.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
          record.workflow.toLowerCase().contains(state.searchQuery.toLowerCase());
          
      final matchesWorkflow = state.selectedWorkflow == null || state.selectedWorkflow == 'All' || record.workflow == state.selectedWorkflow;
      final matchesDecision = state.selectedDecision == null || state.selectedDecision == 'All' || record.decision == state.selectedDecision;
      final matchesDepartment = state.selectedDepartment == null || state.selectedDepartment == 'All' || record.department == state.selectedDepartment;
      final matchesPriority = state.selectedPriority == null || state.selectedPriority == 'All' || record.priority == state.selectedPriority;

      return matchesSearch && matchesWorkflow && matchesDecision && matchesDepartment && matchesPriority;
    }).toList();
  }

  Map<String, String> get statistics {
    int approved = 0;
    int rejected = 0;
    int cancelled = 0;
    int expired = 0;
    
    for (var r in state.records) {
      switch (r.decision) {
        case 'Approved': approved++; break;
        case 'Rejected': rejected++; break;
        case 'Cancelled': cancelled++; break;
        case 'Expired': expired++; break;
      }
    }
    
    return {
      'Approved': approved.toString(),
      'Rejected': rejected.toString(),
      'Cancelled': cancelled.toString(),
      'Expired': expired.toString(),
      'Average Approval Time': '2h 15m',
    };
  }

  static final List<ApprovalHistoryRecord> _mockRecords = [
    ApprovalHistoryRecord(
      id: 'APP-1001',
      workflow: 'Purchase Order Approval',
      requestType: 'PO-2023-001',
      approvedBy: 'John Doe',
      decision: 'Approved',
      decisionDate: DateTime.now().subtract(const Duration(days: 1)),
      duration: '4h 30m',
      comments: 'Looks good, budget approved.',
      department: 'Finance',
      priority: 'High',
    ),
    ApprovalHistoryRecord(
      id: 'APP-1002',
      workflow: 'Leave Request Approval',
      requestType: 'LR-2023-045',
      approvedBy: 'Jane Smith',
      decision: 'Rejected',
      decisionDate: DateTime.now().subtract(const Duration(days: 2)),
      duration: '1h 15m',
      comments: 'Project deadline next week, cannot approve right now.',
      department: 'Engineering',
      priority: 'Normal',
    ),
    ApprovalHistoryRecord(
      id: 'APP-1003',
      workflow: 'Expense Reimbursement',
      requestType: 'EXP-2023-012',
      approvedBy: 'Mike Johnson',
      decision: 'Approved',
      decisionDate: DateTime.now().subtract(const Duration(days: 3)),
      duration: '2d 4h',
      comments: 'Receipts verified.',
      department: 'Sales',
      priority: 'Normal',
    ),
    ApprovalHistoryRecord(
      id: 'APP-1004',
      workflow: 'Vendor Onboarding',
      requestType: 'VEN-2023-008',
      approvedBy: 'System',
      decision: 'Expired',
      decisionDate: DateTime.now().subtract(const Duration(days: 5)),
      duration: '7d 0h',
      comments: 'SLA missed by Legal department.',
      department: 'Legal',
      priority: 'Low',
    ),
    ApprovalHistoryRecord(
      id: 'APP-1005',
      workflow: 'Contract Approval',
      requestType: 'CON-2023-002',
      approvedBy: 'Sarah Williams',
      decision: 'Cancelled',
      decisionDate: DateTime.now().subtract(const Duration(days: 6)),
      duration: '0h 45m',
      comments: 'Requestor withdrew the contract.',
      department: 'Operations',
      priority: 'High',
    ),
    ApprovalHistoryRecord(
      id: 'APP-1006',
      workflow: 'Purchase Order Approval',
      requestType: 'PO-2023-002',
      approvedBy: 'John Doe',
      decision: 'Approved',
      decisionDate: DateTime.now().subtract(const Duration(days: 7)),
      duration: '2h 10m',
      comments: 'Approved.',
      department: 'Finance',
      priority: 'High',
    ),
  ];
}

final approvalHistoryProvider = NotifierProvider<ApprovalHistoryNotifier, ApprovalHistoryState>(() {
  return ApprovalHistoryNotifier();
});
