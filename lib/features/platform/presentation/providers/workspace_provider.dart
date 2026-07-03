import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/workspace_model.dart';

class WorkspaceState {
  final List<WorkspaceModel> workspaces;
  final String activeWorkspaceId;
  final bool isLoading;
  final String searchQuery;

  const WorkspaceState({
    this.workspaces = const [],
    this.activeWorkspaceId = '',
    this.isLoading = false,
    this.searchQuery = '',
  });

  WorkspaceState copyWith({
    List<WorkspaceModel>? workspaces,
    String? activeWorkspaceId,
    bool? isLoading,
    String? searchQuery,
  }) {
    return WorkspaceState(
      workspaces: workspaces ?? this.workspaces,
      activeWorkspaceId: activeWorkspaceId ?? this.activeWorkspaceId,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  WorkspaceModel? get activeWorkspace {
    if (activeWorkspaceId.isEmpty) return null;
    try {
      return workspaces.firstWhere((w) => w.id == activeWorkspaceId);
    } catch (_) {
      return null;
    }
  }

  List<WorkspaceModel> get filteredWorkspaces {
    if (searchQuery.isEmpty) return workspaces;
    final lower = searchQuery.toLowerCase();
    return workspaces.where((w) => 
      w.name.toLowerCase().contains(lower) || 
      w.description.toLowerCase().contains(lower)
    ).toList();
  }
  
  List<WorkspaceModel> get personalWorkspaces => filteredWorkspaces.where((w) => w.isPersonal).toList();
  List<WorkspaceModel> get templateWorkspaces => filteredWorkspaces.where((w) => !w.isPersonal).toList();
}

class WorkspaceNotifier extends Notifier<WorkspaceState> {
  @override
  WorkspaceState build() {
    return const WorkspaceState(
      activeWorkspaceId: 'ws_1',
      workspaces: [
        WorkspaceModel(
          id: 'ws_1',
          name: 'My Default Workspace',
          description: 'Personalized default view for daily operations.',
          icon: LucideIcons.layoutDashboard,
          isPersonal: true,
          isActive: true,
          favoriteModules: ['Sales Orders', 'Inventory', 'Production'],
          pinnedDashboards: ['Operations Overview', 'Financial Health'],
          personalWidgets: ['Task List', 'Recent Activity'],
          savedFilters: ['High Priority Orders', 'Low Stock Items'],
        ),
        WorkspaceModel(
          id: 'ws_2',
          name: 'End-of-Month Financials',
          description: 'Specialized workspace for closing out the month.',
          icon: LucideIcons.calculator,
          isPersonal: true,
          favoriteModules: ['Invoices', 'Reports', 'Audit'],
          pinnedDashboards: ['Revenue Analysis', 'Expense Tracking'],
          personalWidgets: ['Approval Queue'],
          savedFilters: ['Unpaid Invoices', 'Pending Approvals'],
        ),
        WorkspaceModel(
          id: 'tpl_1',
          name: 'Standard Executive View',
          description: 'Curated template for C-level metrics.',
          icon: LucideIcons.briefcase,
          isPersonal: false,
          favoriteModules: ['Reports', 'Dashboard', 'AI Insights'],
          pinnedDashboards: ['Executive Summary'],
          personalWidgets: ['KPI Tracker', 'AI Predictions'],
          savedFilters: [],
        ),
        WorkspaceModel(
          id: 'tpl_2',
          name: 'Floor Manager Layout',
          description: 'Optimized for shop floor operations and tracking.',
          icon: LucideIcons.factory,
          isPersonal: false,
          favoriteModules: ['Production', 'Job Orders', 'Inventory'],
          pinnedDashboards: ['Manufacturing Dashboard'],
          personalWidgets: ['Machine Status', 'Active Jobs'],
          savedFilters: ['Delayed Jobs'],
        ),
      ],
    );
  }

  void setActiveWorkspace(String id) {
    state = state.copyWith(
      activeWorkspaceId: id,
      workspaces: state.workspaces.map((w) {
        return w.copyWith(isActive: w.id == id);
      }).toList(),
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void saveWorkspace(WorkspaceModel workspace) {
    final exists = state.workspaces.any((w) => w.id == workspace.id);
    if (exists) {
      state = state.copyWith(
        workspaces: state.workspaces.map((w) => w.id == workspace.id ? workspace : w).toList(),
      );
    } else {
      state = state.copyWith(
        workspaces: [...state.workspaces, workspace],
      );
    }
  }
}

final workspaceProvider = NotifierProvider<WorkspaceNotifier, WorkspaceState>(() {
  return WorkspaceNotifier();
});
