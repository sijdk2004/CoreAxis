import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── STATE MODEL ────────────────────────────────────────────────────────
class ApprovalDashboardState {
  final bool isLoading;
  final bool hasError;
  final String errorMessage;

  // Filter State
  final String selectedPeriod;
  final String selectedDepartment;
  final String selectedWorkflow;
  final String selectedPriority;

  // KPIs
  final int pendingApprovals;
  final int approvedToday;
  final int rejectedToday;
  final int escalatedRequests;
  final String avgApprovalTime;
  final double slaCompliance; // Percentage
  final int delegatedApprovals;
  final int approvalBacklog;

  // Charts
  final List<double> approvalTrend; // 7 days of trend data
  final Map<String, double> statusDistribution; // Approved, Rejected, Pending, Escalated
  final Map<String, int> departmentVolume;
  final List<double> slaComplianceTrend; // 7 days of SLA %

  // Widgets
  final List<Map<String, dynamic>> pendingMyApprovals;
  final List<Map<String, dynamic>> recentDecisions;
  final List<Map<String, dynamic>> escalatedRequestsList;
  final List<Map<String, dynamic>> topApprovalWorkflows;
  final double approvalHealthScore; // 0.0 to 100.0

  ApprovalDashboardState({
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage = '',
    this.selectedPeriod = 'Today',
    this.selectedDepartment = 'All Departments',
    this.selectedWorkflow = 'All Workflows',
    this.selectedPriority = 'All Priorities',
    this.pendingApprovals = 0,
    this.approvedToday = 0,
    this.rejectedToday = 0,
    this.escalatedRequests = 0,
    this.avgApprovalTime = '0h',
    this.slaCompliance = 0.0,
    this.delegatedApprovals = 0,
    this.approvalBacklog = 0,
    this.approvalTrend = const [],
    this.statusDistribution = const {},
    this.departmentVolume = const {},
    this.slaComplianceTrend = const [],
    this.pendingMyApprovals = const [],
    this.recentDecisions = const [],
    this.escalatedRequestsList = const [],
    this.topApprovalWorkflows = const [],
    this.approvalHealthScore = 0.0,
  });

  ApprovalDashboardState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    String? selectedPeriod,
    String? selectedDepartment,
    String? selectedWorkflow,
    String? selectedPriority,
    int? pendingApprovals,
    int? approvedToday,
    int? rejectedToday,
    int? escalatedRequests,
    String? avgApprovalTime,
    double? slaCompliance,
    int? delegatedApprovals,
    int? approvalBacklog,
    List<double>? approvalTrend,
    Map<String, double>? statusDistribution,
    Map<String, int>? departmentVolume,
    List<double>? slaComplianceTrend,
    List<Map<String, dynamic>>? pendingMyApprovals,
    List<Map<String, dynamic>>? recentDecisions,
    List<Map<String, dynamic>>? escalatedRequestsList,
    List<Map<String, dynamic>>? topApprovalWorkflows,
    double? approvalHealthScore,
  }) {
    return ApprovalDashboardState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      selectedDepartment: selectedDepartment ?? this.selectedDepartment,
      selectedWorkflow: selectedWorkflow ?? this.selectedWorkflow,
      selectedPriority: selectedPriority ?? this.selectedPriority,
      pendingApprovals: pendingApprovals ?? this.pendingApprovals,
      approvedToday: approvedToday ?? this.approvedToday,
      rejectedToday: rejectedToday ?? this.rejectedToday,
      escalatedRequests: escalatedRequests ?? this.escalatedRequests,
      avgApprovalTime: avgApprovalTime ?? this.avgApprovalTime,
      slaCompliance: slaCompliance ?? this.slaCompliance,
      delegatedApprovals: delegatedApprovals ?? this.delegatedApprovals,
      approvalBacklog: approvalBacklog ?? this.approvalBacklog,
      approvalTrend: approvalTrend ?? this.approvalTrend,
      statusDistribution: statusDistribution ?? this.statusDistribution,
      departmentVolume: departmentVolume ?? this.departmentVolume,
      slaComplianceTrend: slaComplianceTrend ?? this.slaComplianceTrend,
      pendingMyApprovals: pendingMyApprovals ?? this.pendingMyApprovals,
      recentDecisions: recentDecisions ?? this.recentDecisions,
      escalatedRequestsList: escalatedRequestsList ?? this.escalatedRequestsList,
      topApprovalWorkflows: topApprovalWorkflows ?? this.topApprovalWorkflows,
      approvalHealthScore: approvalHealthScore ?? this.approvalHealthScore,
    );
  }
}

// ─── NOTIFIER ──────────────────────────────────────────────────────────
class ApprovalDashboardNotifier extends Notifier<ApprovalDashboardState> {
  @override
  ApprovalDashboardState build() {
    // Initial fetch
    _fetchMockData();
    return ApprovalDashboardState(isLoading: true);
  }

  void setFilter({
    String? period,
    String? department,
    String? workflow,
    String? priority,
  }) {
    state = state.copyWith(
      selectedPeriod: period,
      selectedDepartment: department,
      selectedWorkflow: workflow,
      selectedPriority: priority,
      isLoading: true,
    );
    _fetchMockData();
  }

  void refresh() {
    state = state.copyWith(isLoading: true, hasError: false);
    _fetchMockData();
  }

  Future<void> _fetchMockData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 800)); // Simulating network
      
      // Update state with robust mock data
      state = state.copyWith(
        isLoading: false,
        pendingApprovals: 42,
        approvedToday: 128,
        rejectedToday: 14,
        escalatedRequests: 5,
        avgApprovalTime: '2h 15m',
        slaCompliance: 96.5,
        delegatedApprovals: 8,
        approvalBacklog: 15,
        
        // Trends
        approvalTrend: [110, 135, 120, 150, 140, 95, 128], // Last 7 days
        statusDistribution: {
          'Approved': 75.0,
          'Rejected': 10.0,
          'Pending': 12.0,
          'Escalated': 3.0,
        },
        departmentVolume: {
          'Finance': 450,
          'HR': 210,
          'IT': 320,
          'Legal': 95,
        },
        slaComplianceTrend: [92.0, 94.5, 96.0, 95.5, 97.0, 98.2, 96.5],

        // Widget Lists
        pendingMyApprovals: [
          {'id': 'REQ-1042', 'title': 'Q3 Marketing Budget', 'requester': 'Alice Smith', 'due': '2 hours'},
          {'id': 'REQ-1045', 'title': 'New Server Provisioning', 'requester': 'IT Ops', 'due': 'Tomorrow'},
          {'id': 'REQ-1049', 'title': 'Vendor Contract (Acme Corp)', 'requester': 'Bob Jones', 'due': '4 hours'},
        ],
        recentDecisions: [
          {'id': 'REQ-1030', 'title': 'Leave Request', 'decision': 'Approved', 'time': '10 mins ago'},
          {'id': 'REQ-1031', 'title': 'Expense Report', 'decision': 'Rejected', 'time': '1 hour ago'},
          {'id': 'REQ-1032', 'title': 'Software License', 'decision': 'Approved', 'time': '2 hours ago'},
        ],
        escalatedRequestsList: [
          {'id': 'REQ-0995', 'title': 'Emergency Server Patch', 'reason': 'SLA Breach (24h)', 'priority': 'High'},
          {'id': 'REQ-0980', 'title': 'Executive Travel Approval', 'reason': 'Approver on leave', 'priority': 'Medium'},
        ],
        topApprovalWorkflows: [
          {'name': 'Expense Reimbursement', 'volume': '1,205', 'avgTime': '1h 30m'},
          {'name': 'Purchase Order Approval', 'volume': '840', 'avgTime': '4h 15m'},
          {'name': 'Leave Request', 'volume': '650', 'avgTime': '12h 0m'},
        ],
        approvalHealthScore: 92.5,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, hasError: true, errorMessage: 'Failed to load dashboard data.');
    }
  }
}

final approvalDashboardProvider = NotifierProvider<ApprovalDashboardNotifier, ApprovalDashboardState>(() {
  return ApprovalDashboardNotifier();
});
