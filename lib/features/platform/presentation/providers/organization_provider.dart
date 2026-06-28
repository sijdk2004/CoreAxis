import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/organization.dart';

class OrganizationListState {
  final List<Organization> allOrganizations;
  final String filterStatus;
  final String searchQuery;
  final Set<String> selectedOrgIds;
  final bool isLoading;
  final String sortColumn;
  final bool sortAscending;

  OrganizationListState({
    required this.allOrganizations,
    this.filterStatus = 'All',
    this.searchQuery = '',
    this.selectedOrgIds = const {},
    this.isLoading = false,
    this.sortColumn = 'name',
    this.sortAscending = true,
  });

  List<Organization> get filteredOrganizations {
    var filtered = allOrganizations;
    
    // Quick filter
    if (filterStatus != 'All') {
      if (filterStatus == 'Active' || filterStatus == 'Inactive') {
        filtered = filtered.where((org) => org.status == filterStatus).toList();
      } else if (filterStatus == 'Multi-Branch') {
        filtered = filtered.where((org) => org.branchCount > 1).toList();
      } else {
        filtered = filtered.where((org) => org.industry == filterStatus).toList();
      }
    }

    // Search query
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      filtered = filtered.where((org) => 
        org.name.toLowerCase().contains(q) ||
        org.code.toLowerCase().contains(q) ||
        org.tenantName.toLowerCase().contains(q)
      ).toList();
    }

    // Sort
    filtered.sort((a, b) {
      int result = 0;
      switch (sortColumn) {
        case 'name':
          result = a.name.compareTo(b.name);
          break;
        case 'code':
          result = a.code.compareTo(b.code);
          break;
        case 'tenant':
          result = a.tenantName.compareTo(b.tenantName);
          break;
        case 'industry':
          result = a.industry.compareTo(b.industry);
          break;
        case 'branches':
          result = a.branchCount.compareTo(b.branchCount);
          break;
        case 'employees':
          result = a.employeeCount.compareTo(b.employeeCount);
          break;
        case 'country':
          result = a.country.compareTo(b.country);
          break;
        case 'status':
          result = a.status.compareTo(b.status);
          break;
        case 'created':
          result = b.createdAt.compareTo(a.createdAt); // Default descending for dates
          if (!sortAscending) result = -result; // Inverse because the generic logic below handles it
          break;
      }
      return sortAscending ? result : -result;
    });

    return filtered;
  }

  OrganizationListState copyWith({
    List<Organization>? allOrganizations,
    String? filterStatus,
    String? searchQuery,
    Set<String>? selectedOrgIds,
    bool? isLoading,
    String? sortColumn,
    bool? sortAscending,
  }) {
    return OrganizationListState(
      allOrganizations: allOrganizations ?? this.allOrganizations,
      filterStatus: filterStatus ?? this.filterStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedOrgIds: selectedOrgIds ?? this.selectedOrgIds,
      isLoading: isLoading ?? this.isLoading,
      sortColumn: sortColumn ?? this.sortColumn,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

class OrganizationListNotifier extends Notifier<OrganizationListState> {
  @override
  OrganizationListState build() {
    _loadOrganizations();
    return OrganizationListState(allOrganizations: [], isLoading: true);
  }

  Future<void> _loadOrganizations() async {
    await Future.delayed(const Duration(milliseconds: 600));
    final mockData = _generateMockOrganizations(50);
    state = state.copyWith(
      allOrganizations: mockData,
      isLoading: false,
    );
  }

  void loadOrganizations() => _loadOrganizations();

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query, selectedOrgIds: {});
  }

  void setFilterStatus(String status) {
    state = state.copyWith(filterStatus: status, selectedOrgIds: {});
  }

  void setSort(String column, bool ascending) {
    state = state.copyWith(sortColumn: column, sortAscending: ascending);
  }

  void toggleSelection(String id) {
    final newSelection = Set<String>.from(state.selectedOrgIds);
    if (newSelection.contains(id)) {
      newSelection.remove(id);
    } else {
      newSelection.add(id);
    }
    state = state.copyWith(selectedOrgIds: newSelection);
  }

  void selectAll(bool selected) {
    if (selected) {
      state = state.copyWith(selectedOrgIds: state.filteredOrganizations.map((o) => o.id).toSet());
    } else {
      state = state.copyWith(selectedOrgIds: {});
    }
  }

  void bulkUpdateStatus(String status) {
    final updatedList = state.allOrganizations.map((org) {
      if (state.selectedOrgIds.contains(org.id)) {
        return org.copyWith(status: status);
      }
      return org;
    }).toList();
    state = state.copyWith(allOrganizations: updatedList, selectedOrgIds: {});
  }

  void bulkDelete() {
    final updatedList = state.allOrganizations.where((org) => !state.selectedOrgIds.contains(org.id)).toList();
    state = state.copyWith(allOrganizations: updatedList, selectedOrgIds: {});
  }

  void deleteOrganization(String id) {
    final updatedList = state.allOrganizations.where((org) => org.id != id).toList();
    state = state.copyWith(allOrganizations: updatedList);
  }

  void updateOrganizationStatus(String id, String status) {
    final updatedList = state.allOrganizations.map((org) {
      if (org.id == id) {
        return org.copyWith(status: status);
      }
      return org;
    }).toList();
    state = state.copyWith(allOrganizations: updatedList);
  }

  List<Organization> _generateMockOrganizations(int count) {
    final random = Random();
    final industries = ['Manufacturing', 'Trading', 'Service', 'Technology', 'Healthcare'];
    final countries = ['United States', 'United Kingdom', 'Canada', 'India', 'Germany', 'Japan', 'Australia'];
    final statuses = ['Active', 'Active', 'Active', 'Inactive'];
    final tenants = ['Stellar Tech', 'Global Logistics', 'Acme Corp', 'Wayne Enterprises', 'Stark Industries'];

    final orgs = <Organization>[];
    for (int i = 0; i < count; i++) {
      final name = 'Organization ${i + 1}';
      final isService = random.nextBool();
      orgs.add(Organization(
        id: 'org_${1000 + i}',
        name: name,
        code: 'ORG${1000 + i}',
        tenantId: 'tenant_${random.nextInt(5) + 1}',
        tenantName: tenants[random.nextInt(tenants.length)],
        industry: industries[random.nextInt(industries.length)],
        branchCount: isService ? 1 : random.nextInt(20) + 1,
        employeeCount: random.nextInt(5000) + 10,
        country: countries[random.nextInt(countries.length)],
        status: statuses[random.nextInt(statuses.length)],
        logoUrl: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random',
        createdAt: DateTime.now().subtract(Duration(days: random.nextInt(365 * 3))),
      ));
    }
    return orgs;
  }
}

final organizationListProvider = NotifierProvider<OrganizationListNotifier, OrganizationListState>(OrganizationListNotifier.new);
