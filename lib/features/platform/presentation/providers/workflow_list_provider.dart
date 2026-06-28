import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkflowDefinition {
  final String id;
  final String name;
  final String code;
  final String category;
  final String version;
  final int steps;
  final String status; // Active, Inactive, Draft, Published, Archived
  final String createdBy;
  final DateTime lastModified;

  const WorkflowDefinition({
    required this.id,
    required this.name,
    required this.code,
    required this.category,
    required this.version,
    required this.steps,
    required this.status,
    required this.createdBy,
    required this.lastModified,
  });

  WorkflowDefinition copyWith({
    String? name,
    String? code,
    String? category,
    String? version,
    int? steps,
    String? status,
    String? createdBy,
    DateTime? lastModified,
  }) {
    return WorkflowDefinition(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
      category: category ?? this.category,
      version: version ?? this.version,
      steps: steps ?? this.steps,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}

class WorkflowListState {
  final List<WorkflowDefinition> workflows;
  final List<WorkflowDefinition> filteredWorkflows;
  final Set<String> selectedIds;
  final Set<String> visibleColumns;
  final String searchQuery;
  final String? filterStatus;
  final String? filterCategory;
  final bool isLoading;

  final int totalCount;
  final int publishedCount;
  final int draftCount;
  final int runningCount;
  final int archivedCount;

  const WorkflowListState({
    this.workflows = const [],
    this.filteredWorkflows = const [],
    this.selectedIds = const {},
    this.visibleColumns = const {
      'Workflow Name', 'Workflow Code', 'Category', 'Version', 'Steps', 'Status', 'Last Modified'
    },
    this.searchQuery = '',
    this.filterStatus,
    this.filterCategory,
    this.isLoading = true,
    this.totalCount = 0,
    this.publishedCount = 0,
    this.draftCount = 0,
    this.runningCount = 0,
    this.archivedCount = 0,
  });

  WorkflowListState copyWith({
    List<WorkflowDefinition>? workflows,
    List<WorkflowDefinition>? filteredWorkflows,
    Set<String>? selectedIds,
    Set<String>? visibleColumns,
    String? searchQuery,
    String? filterStatus,
    String? filterCategory,
    bool? isLoading,
    int? totalCount,
    int? publishedCount,
    int? draftCount,
    int? runningCount,
    int? archivedCount,
  }) {
    return WorkflowListState(
      workflows: workflows ?? this.workflows,
      filteredWorkflows: filteredWorkflows ?? this.filteredWorkflows,
      selectedIds: selectedIds ?? this.selectedIds,
      visibleColumns: visibleColumns ?? this.visibleColumns,
      searchQuery: searchQuery ?? this.searchQuery,
      filterStatus: filterStatus, // Allowing null
      filterCategory: filterCategory, // Allowing null
      isLoading: isLoading ?? this.isLoading,
      totalCount: totalCount ?? this.totalCount,
      publishedCount: publishedCount ?? this.publishedCount,
      draftCount: draftCount ?? this.draftCount,
      runningCount: runningCount ?? this.runningCount,
      archivedCount: archivedCount ?? this.archivedCount,
    );
  }

  // Helper to correctly handle nulls for optional filters
  WorkflowListState copyWithFilters({
    String? searchQuery,
    String? filterStatus,
    String? filterCategory,
    bool clearStatus = false,
    bool clearCategory = false,
  }) {
    return WorkflowListState(
      workflows: workflows,
      filteredWorkflows: filteredWorkflows,
      selectedIds: selectedIds,
      visibleColumns: visibleColumns,
      searchQuery: searchQuery ?? this.searchQuery,
      filterStatus: clearStatus ? null : (filterStatus ?? this.filterStatus),
      filterCategory: clearCategory ? null : (filterCategory ?? this.filterCategory),
      isLoading: isLoading,
      totalCount: totalCount,
      publishedCount: publishedCount,
      draftCount: draftCount,
      runningCount: runningCount,
      archivedCount: archivedCount,
    );
  }
}

class WorkflowListNotifier extends Notifier<WorkflowListState> {
  bool _initialized = false;

  @override
  WorkflowListState build() {
    if (!_initialized) {
      _initialized = true;
      Future.microtask(() => loadWorkflows());
    }
    return const WorkflowListState();
  }

  Future<void> loadWorkflows() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 600));

    final data = _generateMockWorkflows();
    _applyState(data, state.searchQuery, state.filterStatus, state.filterCategory);
  }

  void search(String query) {
    _applyState(state.workflows, query, state.filterStatus, state.filterCategory);
  }

  void setFilterStatus(String? status) {
    final newState = state.copyWithFilters(filterStatus: status, clearStatus: status == null);
    _applyState(newState.workflows, newState.searchQuery, newState.filterStatus, newState.filterCategory);
  }

  void setFilterCategory(String? category) {
    final newState = state.copyWithFilters(filterCategory: category, clearCategory: category == null);
    _applyState(newState.workflows, newState.searchQuery, newState.filterStatus, newState.filterCategory);
  }

  void _applyState(List<WorkflowDefinition> all, String query, String? status, String? category) {
    var filtered = all.toList();

    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      filtered = filtered.where((w) => 
        w.name.toLowerCase().contains(q) || 
        w.code.toLowerCase().contains(q)
      ).toList();
    }

    if (status != null && status != 'All') {
      filtered = filtered.where((w) => w.status == status).toList();
    }

    if (category != null && category != 'All Categories') {
      filtered = filtered.where((w) => w.category == category).toList();
    }

    final published = all.where((w) => w.status == 'Published').length;
    final draft = all.where((w) => w.status == 'Draft').length;
    final running = all.where((w) => w.status == 'Active').length;
    final archived = all.where((w) => w.status == 'Archived').length;

    state = WorkflowListState(
      workflows: all,
      filteredWorkflows: filtered,
      selectedIds: state.selectedIds,
      visibleColumns: state.visibleColumns,
      searchQuery: query,
      filterStatus: status,
      filterCategory: category,
      isLoading: false,
      totalCount: all.length,
      publishedCount: published,
      draftCount: draft,
      runningCount: running,
      archivedCount: archived,
    );
  }

  void toggleSelection(String id) {
    final newSelected = Set<String>.from(state.selectedIds);
    if (newSelected.contains(id)) {
      newSelected.remove(id);
    } else {
      newSelected.add(id);
    }
    state = state.copyWith(selectedIds: newSelected);
  }

  void selectAll(bool select) {
    if (select) {
      state = state.copyWith(selectedIds: state.filteredWorkflows.map((w) => w.id).toSet());
    } else {
      state = state.copyWith(selectedIds: {});
    }
  }

  void toggleColumn(String column) {
    final newCols = Set<String>.from(state.visibleColumns);
    if (newCols.contains(column)) {
      newCols.remove(column);
    } else {
      newCols.add(column);
    }
    state = state.copyWith(visibleColumns: newCols);
  }

  // Mock Actions
  void cloneWorkflow(String id) {
    final workflow = state.workflows.firstWhere((w) => w.id == id);
    final cloned = workflow.copyWith(
      name: '${workflow.name} (Copy)',
      code: '${workflow.code}_COPY',
      status: 'Draft',
      version: 'v1.0.0',
    );
    final all = [...state.workflows, cloned];
    _applyState(all, state.searchQuery, state.filterStatus, state.filterCategory);
  }

  void publishWorkflow(String id) {
    final all = state.workflows.map((w) {
      if (w.id == id) return w.copyWith(status: 'Published');
      return w;
    }).toList();
    _applyState(all, state.searchQuery, state.filterStatus, state.filterCategory);
  }

  void archiveWorkflow(String id) {
    final all = state.workflows.map((w) {
      if (w.id == id) return w.copyWith(status: 'Archived');
      return w;
    }).toList();
    _applyState(all, state.searchQuery, state.filterStatus, state.filterCategory);
  }

  void deleteWorkflow(String id) {
    final all = state.workflows.where((w) => w.id != id).toList();
    final newSelected = Set<String>.from(state.selectedIds)..remove(id);
    state = state.copyWith(selectedIds: newSelected);
    _applyState(all, state.searchQuery, state.filterStatus, state.filterCategory);
  }

  void bulkDelete() {
    final all = state.workflows.where((w) => !state.selectedIds.contains(w.id)).toList();
    state = state.copyWith(selectedIds: {});
    _applyState(all, state.searchQuery, state.filterStatus, state.filterCategory);
  }

  List<WorkflowDefinition> _generateMockWorkflows() {
    return [
      WorkflowDefinition(id: 'w1', name: 'Standard PO Approval', code: 'WF-PUR-001', category: 'Purchase', version: 'v2.1.0', steps: 4, status: 'Published', createdBy: 'Admin User', lastModified: DateTime.now().subtract(const Duration(days: 2))),
      WorkflowDefinition(id: 'w2', name: 'High Value PO Approval', code: 'WF-PUR-002', category: 'Purchase', version: 'v1.0.0', steps: 6, status: 'Active', createdBy: 'Finance Lead', lastModified: DateTime.now().subtract(const Duration(days: 5))),
      WorkflowDefinition(id: 'w3', name: 'Employee Onboarding', code: 'WF-HR-012', category: 'HR', version: 'v3.0.1', steps: 12, status: 'Published', createdBy: 'HR Manager', lastModified: DateTime.now().subtract(const Duration(days: 12))),
      WorkflowDefinition(id: 'w4', name: 'Q1 Performance Review', code: 'WF-HR-045', category: 'HR', version: 'v1.0.0', steps: 3, status: 'Draft', createdBy: 'HR Admin', lastModified: DateTime.now().subtract(const Duration(hours: 4))),
      WorkflowDefinition(id: 'w5', name: 'Inventory Restock Check', code: 'WF-INV-001', category: 'Inventory', version: 'v1.2.0', steps: 5, status: 'Active', createdBy: 'Warehouse Manager', lastModified: DateTime.now().subtract(const Duration(days: 1))),
      WorkflowDefinition(id: 'w6', name: 'Sales Order Processing', code: 'WF-SAL-004', category: 'Sales', version: 'v4.0.0', steps: 8, status: 'Published', createdBy: 'Sales Director', lastModified: DateTime.now().subtract(const Duration(days: 20))),
      WorkflowDefinition(id: 'w7', name: 'Expense Claim Approval', code: 'WF-FIN-021', category: 'Finance', version: 'v2.0.0', steps: 4, status: 'Active', createdBy: 'Finance System', lastModified: DateTime.now().subtract(const Duration(hours: 12))),
      WorkflowDefinition(id: 'w8', name: 'Manufacturing QA Check', code: 'WF-MFG-008', category: 'Quality', version: 'v1.1.0', steps: 9, status: 'Draft', createdBy: 'QA Lead', lastModified: DateTime.now().subtract(const Duration(days: 3))),
      WorkflowDefinition(id: 'w9', name: 'Vendor Registration', code: 'WF-PUR-010', category: 'Purchase', version: 'v1.0.0', steps: 5, status: 'Archived', createdBy: 'Admin User', lastModified: DateTime.now().subtract(const Duration(days: 60))),
      WorkflowDefinition(id: 'w10', name: 'Leave Request Approval', code: 'WF-HR-015', category: 'HR', version: 'v2.2.0', steps: 3, status: 'Published', createdBy: 'HR System', lastModified: DateTime.now().subtract(const Duration(days: 15))),
    ];
  }
}

final workflowListProvider = NotifierProvider<WorkflowListNotifier, WorkflowListState>(
  WorkflowListNotifier.new,
);
