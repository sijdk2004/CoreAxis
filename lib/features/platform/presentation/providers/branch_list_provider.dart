import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/branch.dart';

class BranchListState {
  final List<Branch> branches;
  final String searchQuery;
  final String sortColumn;
  final bool sortAscending;
  final Set<String> selectedIds;

  BranchListState({
    required this.branches,
    this.searchQuery = '',
    this.sortColumn = 'name',
    this.sortAscending = true,
    this.selectedIds = const {},
  });

  List<Branch> get filteredBranches {
    var filtered = branches.where((b) {
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        return b.name.toLowerCase().contains(query) ||
            b.code.toLowerCase().contains(query) ||
            b.city.toLowerCase().contains(query) ||
            b.country.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    filtered.sort((a, b) {
      int comparison = 0;
      switch (sortColumn) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'code':
          comparison = a.code.compareTo(b.code);
          break;
        case 'manager':
          comparison = a.manager.compareTo(b.manager);
          break;
        case 'city':
          comparison = a.city.compareTo(b.city);
          break;
        case 'country':
          comparison = a.country.compareTo(b.country);
          break;
        case 'departments':
          comparison = a.departments.compareTo(b.departments);
          break;
        case 'employees':
          comparison = a.employees.compareTo(b.employees);
          break;
        case 'status':
          comparison = a.status.compareTo(b.status);
          break;
      }
      return sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  BranchListState copyWith({
    List<Branch>? branches,
    String? searchQuery,
    String? sortColumn,
    bool? sortAscending,
    Set<String>? selectedIds,
  }) {
    return BranchListState(
      branches: branches ?? this.branches,
      searchQuery: searchQuery ?? this.searchQuery,
      sortColumn: sortColumn ?? this.sortColumn,
      sortAscending: sortAscending ?? this.sortAscending,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}

class BranchListNotifier extends Notifier<BranchListState> {
  @override
  BranchListState build() {
    return BranchListState(branches: _generateMockData('org_1000'));
  }

  List<Branch> _generateMockData(String orgId) {
    return List.generate(12, (index) {
      final isOffice = index % 3 != 0;
      return Branch(
        id: 'BR${1000 + index}',
        orgId: orgId,
        name: isOffice ? 'Corporate Office ${index + 1}' : 'Distribution Center ${index + 1}',
        code: 'BRC-00${index + 1}',
        manager: 'Manager ${index + 1}',
        email: 'manager${index + 1}@example.com',
        phone: '+1 555-010${index % 9}',
        address: '${100 + index} Main St',
        city: index % 2 == 0 ? 'New York' : 'London',
        state: index % 2 == 0 ? 'NY' : 'ENG',
        country: index % 2 == 0 ? 'USA' : 'UK',
        postalCode: '1000$index',
        type: isOffice ? 'Office' : 'Warehouse',
        status: index % 4 == 0 ? 'Inactive' : 'Active',
        departments: isOffice ? 5 + (index % 3) : 2,
        employees: isOffice ? 150 + (index * 10) : 45 + (index * 5),
        createdAt: DateTime.now().subtract(Duration(days: index * 10)),
      );
    });
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSort(String column, bool ascending) {
    state = state.copyWith(sortColumn: column, sortAscending: ascending);
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

  void selectAll(bool select) {
    if (select) {
      state = state.copyWith(selectedIds: state.filteredBranches.map((b) => b.id).toSet());
    } else {
      state = state.copyWith(selectedIds: {});
    }
  }

  void addBranch(Branch branch) {
    state = state.copyWith(branches: [...state.branches, branch]);
  }

  void updateBranch(Branch updatedBranch) {
    final newBranches = state.branches.map((b) => b.id == updatedBranch.id ? updatedBranch : b).toList();
    state = state.copyWith(branches: newBranches);
  }

  void deleteBranch(String id) {
    final newBranches = state.branches.where((b) => b.id != id).toList();
    final newSelection = Set<String>.from(state.selectedIds)..remove(id);
    state = state.copyWith(branches: newBranches, selectedIds: newSelection);
  }
}

final branchListProvider = NotifierProvider<BranchListNotifier, BranchListState>(BranchListNotifier.new);
