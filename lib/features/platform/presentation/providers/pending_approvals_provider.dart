import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/approval_request.dart';

class PendingApprovalsState {
  final bool isLoading;
  final List<ApprovalRequest> requests;
  final Set<String> selectedIds;
  final String searchQuery;
  final String activeQuickFilter;
  final ApprovalRequest? selectedRequest; // For drawer

  // Stats
  final int pendingCount;
  final int highPriorityCount;
  final int overdueCount;
  final int delegatedCount;
  final int escalatedCount;

  PendingApprovalsState({
    this.isLoading = false,
    this.requests = const [],
    this.selectedIds = const {},
    this.searchQuery = '',
    this.activeQuickFilter = 'All',
    this.selectedRequest,
    this.pendingCount = 0,
    this.highPriorityCount = 0,
    this.overdueCount = 0,
    this.delegatedCount = 0,
    this.escalatedCount = 0,
  });

  PendingApprovalsState copyWith({
    bool? isLoading,
    List<ApprovalRequest>? requests,
    Set<String>? selectedIds,
    String? searchQuery,
    String? activeQuickFilter,
    ApprovalRequest? selectedRequest,
    bool clearSelectedRequest = false,
    int? pendingCount,
    int? highPriorityCount,
    int? overdueCount,
    int? delegatedCount,
    int? escalatedCount,
  }) {
    return PendingApprovalsState(
      isLoading: isLoading ?? this.isLoading,
      requests: requests ?? this.requests,
      selectedIds: selectedIds ?? this.selectedIds,
      searchQuery: searchQuery ?? this.searchQuery,
      activeQuickFilter: activeQuickFilter ?? this.activeQuickFilter,
      selectedRequest: clearSelectedRequest ? null : (selectedRequest ?? this.selectedRequest),
      pendingCount: pendingCount ?? this.pendingCount,
      highPriorityCount: highPriorityCount ?? this.highPriorityCount,
      overdueCount: overdueCount ?? this.overdueCount,
      delegatedCount: delegatedCount ?? this.delegatedCount,
      escalatedCount: escalatedCount ?? this.escalatedCount,
    );
  }

  List<ApprovalRequest> get filteredRequests {
    return requests.where((r) {
      // 1. Search
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        if (!r.id.toLowerCase().contains(q) &&
            !r.requestType.toLowerCase().contains(q) &&
            !r.requestedBy.toLowerCase().contains(q) &&
            !r.workflow.toLowerCase().contains(q)) {
          return false;
        }
      }

      // 2. Quick Filter
      switch (activeQuickFilter) {
        case 'My Approvals':
          if (r.assignedTo != 'Me') return false;
          break;
        case 'Delegated':
          if (r.status != 'Delegated') return false;
          break;
        case 'High Priority':
          if (r.priority != 'High') return false;
          break;
        case 'Escalated':
          if (r.status != 'Escalated') return false;
          break;
        case 'Overdue':
          if (!r.dueDate.isBefore(DateTime.now())) return false;
          break;
        case 'Awaiting Review':
          if (r.status != 'Pending') return false;
          break;
        case 'All':
        default:
          break;
      }
      return true;
    }).toList();
  }
}

class PendingApprovalsNotifier extends Notifier<PendingApprovalsState> {
  @override
  PendingApprovalsState build() {
    _loadMockData();
    return PendingApprovalsState(isLoading: true);
  }

  void _loadMockData() {
    Future.delayed(const Duration(milliseconds: 600), () {
      final now = DateTime.now();
      final mockData = [
        ApprovalRequest(
          id: 'REQ-1042',
          requestType: 'Budget Approval',
          workflow: 'Q3 Marketing Budget',
          requestedBy: 'Alice Smith',
          currentStep: 'VP Review',
          assignedTo: 'Me',
          priority: 'High',
          submittedDate: now.subtract(const Duration(days: 2)),
          dueDate: now.subtract(const Duration(hours: 2)),
          status: 'Pending',
          summary: 'Requesting \$50,000 for Q3 digital marketing campaign expansion across APAC region.',
          timeline: [
            TimelineEvent(title: 'Submitted', subtitle: 'Alice Smith', time: now.subtract(const Duration(days: 2)), isCompleted: true),
            TimelineEvent(title: 'Manager Review', subtitle: 'Approved by Bob', time: now.subtract(const Duration(days: 1)), isCompleted: true),
            TimelineEvent(title: 'VP Review', subtitle: 'Pending your approval', time: now, isCurrent: true),
          ],
          comments: [
            Comment(user: 'Bob', text: 'Looks good to me, passing to VP.', time: now.subtract(const Duration(days: 1))),
          ],
          attachments: [
            Attachment(fileName: 'Q3_Budget_Breakdown.xlsx', fileSize: '2.4 MB', fileType: 'excel'),
          ],
          history: [
            HistoryEvent(action: 'Status changed to Pending VP Review', user: 'System', time: now.subtract(const Duration(days: 1))),
          ],
        ),
        ApprovalRequest(
          id: 'REQ-1045',
          requestType: 'IT Provisioning',
          workflow: 'New Server Provisioning',
          requestedBy: 'IT Ops',
          currentStep: 'Security Clearance',
          assignedTo: 'Me',
          priority: 'Medium',
          submittedDate: now.subtract(const Duration(hours: 12)),
          dueDate: now.add(const Duration(days: 1)),
          status: 'Pending',
          summary: 'Requesting 3 new AWS EC2 instances for the upcoming production release.',
          timeline: [
            TimelineEvent(title: 'Submitted', subtitle: 'IT Ops', time: now.subtract(const Duration(hours: 12)), isCompleted: true),
            TimelineEvent(title: 'Security Clearance', subtitle: 'Pending your approval', time: now, isCurrent: true),
          ],
          comments: [],
          attachments: [],
          history: [
            HistoryEvent(action: 'Request created', user: 'IT Ops', time: now.subtract(const Duration(hours: 12))),
          ],
        ),
        ApprovalRequest(
          id: 'REQ-1049',
          requestType: 'Contract',
          workflow: 'Vendor Contract (Acme Corp)',
          requestedBy: 'Bob Jones',
          currentStep: 'Legal Review',
          assignedTo: 'Me',
          priority: 'High',
          submittedDate: now.subtract(const Duration(days: 5)),
          dueDate: now.subtract(const Duration(days: 1)),
          status: 'Escalated',
          summary: 'Annual renewal contract for Acme Corp SaaS services.',
          timeline: [
            TimelineEvent(title: 'Submitted', subtitle: 'Bob Jones', time: now.subtract(const Duration(days: 5)), isCompleted: true),
            TimelineEvent(title: 'Legal Review', subtitle: 'Escalated due to SLA breach', time: now, isCurrent: true),
          ],
          comments: [
            Comment(user: 'System', text: 'Auto-escalated due to 72h SLA breach.', time: now.subtract(const Duration(days: 1))),
          ],
          attachments: [
            Attachment(fileName: 'Acme_Renewal_2026.pdf', fileSize: '4.1 MB', fileType: 'pdf'),
          ],
          history: [
            HistoryEvent(action: 'Escalated', user: 'System', time: now.subtract(const Duration(days: 1))),
          ],
        ),
        ApprovalRequest(
          id: 'REQ-1055',
          requestType: 'Leave',
          workflow: 'Annual Leave Request',
          requestedBy: 'Charlie Davis',
          currentStep: 'Manager Approval',
          assignedTo: 'Me',
          priority: 'Low',
          submittedDate: now.subtract(const Duration(hours: 4)),
          dueDate: now.add(const Duration(days: 5)),
          status: 'Pending',
          summary: 'Requesting 2 weeks of annual leave in August.',
          timeline: [
            TimelineEvent(title: 'Submitted', subtitle: 'Charlie Davis', time: now.subtract(const Duration(hours: 4)), isCompleted: true),
            TimelineEvent(title: 'Manager Approval', subtitle: 'Pending your approval', time: now, isCurrent: true),
          ],
          comments: [],
          attachments: [],
          history: [
            HistoryEvent(action: 'Request created', user: 'Charlie Davis', time: now.subtract(const Duration(hours: 4))),
          ],
        ),
      ];

      state = state.copyWith(
        isLoading: false,
        requests: mockData,
        pendingCount: mockData.length,
        highPriorityCount: mockData.where((r) => r.priority == 'High').length,
        overdueCount: mockData.where((r) => r.dueDate.isBefore(DateTime.now())).length,
        delegatedCount: mockData.where((r) => r.status == 'Delegated').length,
        escalatedCount: mockData.where((r) => r.status == 'Escalated').length,
      );
    });
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setQuickFilter(String filter) {
    state = state.copyWith(activeQuickFilter: filter);
  }

  void toggleSelection(String id) {
    final newSelection = Set<String>.from(state.selectedIds);
    if (newSelection.contains(id)) {
      newSelection.remove(id);
    } else {
      newSelection.add(id);
    }
    state = state.copyWith(selectedIds: newSelection);
  }

  void toggleAll(bool selectAll) {
    if (selectAll) {
      state = state.copyWith(selectedIds: state.filteredRequests.map((r) => r.id).toSet());
    } else {
      state = state.copyWith(selectedIds: {});
    }
  }

  void selectRequest(ApprovalRequest? request) {
    if (request == null) {
      state = state.copyWith(clearSelectedRequest: true);
    } else {
      state = state.copyWith(selectedRequest: request);
    }
  }

  void refresh() {
    state = state.copyWith(isLoading: true, selectedIds: {});
    _loadMockData();
  }

  // Mock Actions
  void approveSelected() {
    _removeSelected();
  }

  void rejectSelected() {
    _removeSelected();
  }

  void delegateSelected() {
    _removeSelected();
  }

  void actionSingle(String id, String action) {
    final newRequests = state.requests.where((r) => r.id != id).toList();
    state = state.copyWith(
      requests: newRequests,
      selectedIds: state.selectedIds.where((selectedId) => selectedId != id).toSet(),
      clearSelectedRequest: state.selectedRequest?.id == id,
    );
    _recalcStats(newRequests);
  }

  void _removeSelected() {
    final newRequests = state.requests.where((r) => !state.selectedIds.contains(r.id)).toList();
    state = state.copyWith(
      requests: newRequests,
      selectedIds: {},
      clearSelectedRequest: state.selectedRequest != null && state.selectedIds.contains(state.selectedRequest!.id),
    );
    _recalcStats(newRequests);
  }

  void _recalcStats(List<ApprovalRequest> data) {
    state = state.copyWith(
      pendingCount: data.length,
      highPriorityCount: data.where((r) => r.priority == 'High').length,
      overdueCount: data.where((r) => r.dueDate.isBefore(DateTime.now())).length,
      delegatedCount: data.where((r) => r.status == 'Delegated').length,
      escalatedCount: data.where((r) => r.status == 'Escalated').length,
    );
  }
}

final pendingApprovalsProvider = NotifierProvider<PendingApprovalsNotifier, PendingApprovalsState>(() {
  return PendingApprovalsNotifier();
});
