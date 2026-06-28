import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/department.dart';

class DepartmentListState {
  final List<Department> departments;
  final String searchQuery;
  final String sortColumn;
  final bool sortAscending;
  final Set<String> selectedIds;

  DepartmentListState({
    required this.departments,
    this.searchQuery = '',
    this.sortColumn = 'name',
    this.sortAscending = true,
    this.selectedIds = const {},
  });

  List<Department> get filteredDepartments {
    var filtered = departments.where((d) {
      if (searchQuery.isEmpty) return true;
      final query = searchQuery.toLowerCase();
      return d.name.toLowerCase().contains(query) ||
             d.code.toLowerCase().contains(query) ||
             d.manager.toLowerCase().contains(query);
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

  DepartmentListState copyWith({
    List<Department>? departments,
    String? searchQuery,
    String? sortColumn,
    bool? sortAscending,
    Set<String>? selectedIds,
  }) {
    return DepartmentListState(
      departments: departments ?? this.departments,
      searchQuery: searchQuery ?? this.searchQuery,
      sortColumn: sortColumn ?? this.sortColumn,
      sortAscending: sortAscending ?? this.sortAscending,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}

class DepartmentListNotifier extends Notifier<DepartmentListState> {
  @override
  DepartmentListState build() {
    return DepartmentListState(departments: _generateMockData('org_1000'));
  }

  List<Department> _generateMockData(String orgId) {
    // Generate a corporate hierarchy
    // Corporate
    // ├── Sales
    // ├── Production
    // │   ├── Cutting
    // │   ├── Assembly
    // │   ├── Painting
    // │   └── QC
    // ├── Purchase
    // ├── Inventory
    // ├── Finance
    // └── HR

    final now = DateTime.now();
    final List<Department> list = [];

    // Level 1: Corporate
    final corp = Department(
      id: 'DEP001',
      orgId: orgId,
      branchId: 'BR1000',
      parentId: null,
      name: 'Corporate',
      code: 'CORP',
      manager: 'John Doe',
      description: 'Corporate Headquarters',
      status: 'Active',
      employees: 50,
      createdAt: now.subtract(const Duration(days: 100)),
    );
    list.add(corp);

    // Level 2: Top Level Departments under Corporate
    final level2 = [
      {'id': 'DEP002', 'name': 'Sales', 'code': 'SALES', 'manager': 'Alice Smith', 'emp': 120},
      {'id': 'DEP003', 'name': 'Production', 'code': 'PROD', 'manager': 'Bob Jones', 'emp': 300},
      {'id': 'DEP004', 'name': 'Purchase', 'code': 'PURC', 'manager': 'Charlie Brown', 'emp': 40},
      {'id': 'DEP005', 'name': 'Inventory', 'code': 'INV', 'manager': 'David White', 'emp': 80},
      {'id': 'DEP006', 'name': 'Finance', 'code': 'FIN', 'manager': 'Eve Black', 'emp': 35},
      {'id': 'DEP007', 'name': 'HR', 'code': 'HR', 'manager': 'Fiona Green', 'emp': 25},
    ];

    for (var d in level2) {
      list.add(Department(
        id: d['id'] as String,
        orgId: orgId,
        branchId: 'BR1000',
        parentId: corp.id,
        name: d['name'] as String,
        code: d['code'] as String,
        manager: d['manager'] as String,
        description: '${d['name']} Department',
        status: 'Active',
        employees: d['emp'] as int,
        createdAt: now.subtract(const Duration(days: 90)),
      ));
    }

    // Level 3: Sub-departments under Production
    final prodId = 'DEP003';
    final level3 = [
      {'id': 'DEP008', 'name': 'Cutting', 'code': 'PROD-CUT', 'manager': 'George King', 'emp': 80},
      {'id': 'DEP009', 'name': 'Assembly', 'code': 'PROD-ASM', 'manager': 'Helen Queen', 'emp': 120},
      {'id': 'DEP010', 'name': 'Painting', 'code': 'PROD-PNT', 'manager': 'Ian Jack', 'emp': 50},
      {'id': 'DEP011', 'name': 'QC', 'code': 'PROD-QC', 'manager': 'Jane Ace', 'emp': 50},
    ];

    for (var d in level3) {
      list.add(Department(
        id: d['id'] as String,
        orgId: orgId,
        branchId: 'BR1001', // Different branch maybe
        parentId: prodId,
        name: d['name'] as String,
        code: d['code'] as String,
        manager: d['manager'] as String,
        description: '${d['name']} Department',
        status: 'Active',
        employees: d['emp'] as int,
        createdAt: now.subtract(const Duration(days: 80)),
      ));
    }

    return list;
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
      state = state.copyWith(selectedIds: state.filteredDepartments.map((d) => d.id).toSet());
    } else {
      state = state.copyWith(selectedIds: {});
    }
  }

  void addDepartment(Department department) {
    state = state.copyWith(departments: [...state.departments, department]);
  }

  void updateDepartment(Department updatedDepartment) {
    final newDepartments = state.departments.map((d) => d.id == updatedDepartment.id ? updatedDepartment : d).toList();
    state = state.copyWith(departments: newDepartments);
  }

  void deleteDepartment(String id) {
    final newDepartments = state.departments.where((d) => d.id != id).toList();
    final newSelection = Set<String>.from(state.selectedIds)..remove(id);
    state = state.copyWith(departments: newDepartments, selectedIds: newSelection);
  }
}

final departmentListProvider = NotifierProvider<DepartmentListNotifier, DepartmentListState>(DepartmentListNotifier.new);
