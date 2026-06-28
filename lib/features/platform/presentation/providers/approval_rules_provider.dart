import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/approval_rule.dart';

class ApprovalRulesState {
  final bool isLoading;
  final List<ApprovalRule> rules;
  final String searchQuery;
  final String activeCategoryFilter;

  ApprovalRulesState({
    this.isLoading = false,
    this.rules = const [],
    this.searchQuery = '',
    this.activeCategoryFilter = 'All',
  });

  ApprovalRulesState copyWith({
    bool? isLoading,
    List<ApprovalRule>? rules,
    String? searchQuery,
    String? activeCategoryFilter,
  }) {
    return ApprovalRulesState(
      isLoading: isLoading ?? this.isLoading,
      rules: rules ?? this.rules,
      searchQuery: searchQuery ?? this.searchQuery,
      activeCategoryFilter: activeCategoryFilter ?? this.activeCategoryFilter,
    );
  }

  List<ApprovalRule> get filteredRules {
    return rules.where((r) {
      if (activeCategoryFilter != 'All' && r.category != activeCategoryFilter) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        if (!r.name.toLowerCase().contains(q) && !r.category.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }
}

class ApprovalRulesNotifier extends Notifier<ApprovalRulesState> {
  @override
  ApprovalRulesState build() {
    _loadMockData();
    return ApprovalRulesState(isLoading: true);
  }

  void _loadMockData() {
    Future.delayed(const Duration(milliseconds: 600), () {
      final mockData = [
        ApprovalRule(
          id: 'RUL-001',
          name: 'Large Purchase Orders',
          category: 'Purchase',
          conditions: 'Amount > 100,000',
          approvers: ['Finance Manager', 'Director', 'CEO'],
          escalation: 'Auto-Reject (48h)',
          sla: '24h per step',
        ),
        ApprovalRule(
          id: 'RUL-002',
          name: 'Standard Expenses',
          category: 'Finance',
          conditions: 'Amount <= 5,000',
          approvers: ['Direct Manager'],
          escalation: 'Notify Manager (72h)',
          sla: '48h',
        ),
        ApprovalRule(
          id: 'RUL-003',
          name: 'Executive Leave',
          category: 'HR',
          conditions: 'Role == "Executive"',
          approvers: ['HR Director', 'CEO'],
          escalation: 'Reassign to Admin',
          sla: '12h per step',
          isActive: false,
        ),
        ApprovalRule(
          id: 'RUL-004',
          name: 'International Sales Contract',
          category: 'Sales Order',
          conditions: 'Region != "Domestic"',
          approvers: ['Legal Review', 'VP of Sales'],
          escalation: 'Auto-Escalate to CEO',
          sla: '24h',
        ),
      ];

      state = state.copyWith(isLoading: false, rules: mockData);
    });
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategoryFilter(String filter) {
    state = state.copyWith(activeCategoryFilter: filter);
  }

  void toggleRuleStatus(String id) {
    final updated = state.rules.map((r) {
      if (r.id == id) {
        return r.copyWith(isActive: !r.isActive);
      }
      return r;
    }).toList();
    state = state.copyWith(rules: updated);
  }

  void deleteRule(String id) {
    final updated = state.rules.where((r) => r.id != id).toList();
    state = state.copyWith(rules: updated);
  }

  Future<void> mockSaveRule(ApprovalRule rule) async {
    // Simulate network
    await Future.delayed(const Duration(milliseconds: 800));
    final existingIndex = state.rules.indexWhere((r) => r.id == rule.id);
    final updatedRules = List<ApprovalRule>.from(state.rules);
    if (existingIndex >= 0) {
      updatedRules[existingIndex] = rule;
    } else {
      updatedRules.insert(0, rule);
    }
    state = state.copyWith(rules: updatedRules);
  }
}

final approvalRulesProvider = NotifierProvider<ApprovalRulesNotifier, ApprovalRulesState>(() {
  return ApprovalRulesNotifier();
});
