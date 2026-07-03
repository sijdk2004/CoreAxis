import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/delegation_record.dart';

class DelegationState {
  final List<DelegationRecord> records;
  final String searchQuery;
  final String? statusFilter;

  DelegationState({
    required this.records,
    this.searchQuery = '',
    this.statusFilter,
  });

  DelegationState copyWith({
    List<DelegationRecord>? records,
    String? searchQuery,
    String? statusFilter,
  }) {
    return DelegationState(
      records: records ?? this.records,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

class DelegationNotifier extends Notifier<DelegationState> {
  @override
  DelegationState build() {
    return DelegationState(records: _mockRecords);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setStatusFilter(String? status) {
    state = state.copyWith(statusFilter: status);
  }

  void addDelegation(DelegationRecord record) {
    state = state.copyWith(records: [...state.records, record]);
  }

  void revokeDelegation(String id) {
    state = state.copyWith(
      records: state.records.map((r) {
        if (r.id == id) {
          return r.copyWith(status: 'Revoked');
        }
        return r;
      }).toList(),
    );
  }

  List<DelegationRecord> get filteredRecords {
    return state.records.where((record) {
      final matchesSearch = state.searchQuery.isEmpty ||
          record.delegator.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
          record.delegate.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
          record.reason.toLowerCase().contains(state.searchQuery.toLowerCase());
          
      final matchesStatus = state.statusFilter == null || state.statusFilter == 'All' || record.status == state.statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  bool checkConflict(String delegator, DateTime from, DateTime to) {
    // Check if the delegator already has an active delegation overlapping with these dates
    for (var r in state.records) {
      if (r.delegator == delegator && r.status == 'Active') {
        if ((from.isBefore(r.toDate) && to.isAfter(r.fromDate)) || 
            from.isAtSameMomentAs(r.fromDate) || to.isAtSameMomentAs(r.toDate)) {
          return true; // Conflict found
        }
      }
    }
    return false;
  }

  static final List<DelegationRecord> _mockRecords = [
    DelegationRecord(
      id: 'DEL-101',
      delegator: 'John Doe',
      delegate: 'Jane Smith',
      fromDate: DateTime.now().subtract(const Duration(days: 2)),
      toDate: DateTime.now().add(const Duration(days: 5)),
      reason: 'Annual Leave',
      status: 'Active',
      approvalTypes: ['Purchase Orders', 'Leave Requests'],
    ),
    DelegationRecord(
      id: 'DEL-102',
      delegator: 'Sarah Williams',
      delegate: 'Mike Johnson',
      fromDate: DateTime.now().add(const Duration(days: 10)),
      toDate: DateTime.now().add(const Duration(days: 14)),
      reason: 'Business Trip',
      status: 'Scheduled',
      approvalTypes: ['Expense Reports'],
    ),
    DelegationRecord(
      id: 'DEL-103',
      delegator: 'Robert Chen',
      delegate: 'John Doe',
      fromDate: DateTime.now().subtract(const Duration(days: 30)),
      toDate: DateTime.now().subtract(const Duration(days: 20)),
      reason: 'Sick Leave',
      status: 'Expired',
      approvalTypes: ['All Approvals'],
    ),
  ];
}

final delegationProvider = NotifierProvider<DelegationNotifier, DelegationState>(() {
  return DelegationNotifier();
});
