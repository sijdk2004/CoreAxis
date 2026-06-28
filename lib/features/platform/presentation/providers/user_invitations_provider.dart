import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_invitation.dart';

class UserInvitationsState {
  final List<UserInvitation> allInvitations;
  final List<UserInvitation> filteredInvitations;
  final bool isLoading;
  final String searchQuery;
  final String selectedFilter; // 'All', 'Pending', 'Accepted', 'Expired', 'Cancelled'
  
  const UserInvitationsState({
    this.allInvitations = const [],
    this.filteredInvitations = const [],
    this.isLoading = false,
    this.searchQuery = '',
    this.selectedFilter = 'All',
  });

  UserInvitationsState copyWith({
    List<UserInvitation>? allInvitations,
    List<UserInvitation>? filteredInvitations,
    bool? isLoading,
    String? searchQuery,
    String? selectedFilter,
  }) {
    return UserInvitationsState(
      allInvitations: allInvitations ?? this.allInvitations,
      filteredInvitations: filteredInvitations ?? this.filteredInvitations,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

class UserInvitationsNotifier extends Notifier<UserInvitationsState> {
  bool _initialized = false;

  @override
  UserInvitationsState build() {
    if (!_initialized) {
      _initialized = true;
      Future.microtask(() => init());
    }
    return const UserInvitationsState(isLoading: true);
  }

  void init() async {
    state = const UserInvitationsState(isLoading: true);
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final mockInvitations = _generateMockInvitations();
    
    state = state.copyWith(
      allInvitations: mockInvitations,
      isLoading: false,
    );
    _applyFilters();
  }

  List<UserInvitation> _generateMockInvitations() {
    final random = Random(42);
    final roles = ['Org Admin', 'Sales Rep', 'Operations Manager', 'Finance Lead', 'Viewer'];
    final organizations = ['Stellar Inc', 'Acme Corp', 'Global Tech', 'Nexus Industries'];
    final names = ['Alice Smith', 'Bob Jones', 'Charlie Brown', 'Diana Prince'];
    final statuses = ['Pending', 'Accepted', 'Expired', 'Cancelled'];

    return List.generate(20, (index) {
      final now = DateTime.now();
      final daysAgo = random.nextInt(30);
      final invitationDate = now.subtract(Duration(days: daysAgo));
      final expiryDate = invitationDate.add(const Duration(days: 7));
      
      String status;
      if (now.isAfter(expiryDate) && random.nextBool()) {
        status = 'Expired';
      } else if (index < 5) {
        status = 'Pending';
      } else {
        status = statuses[random.nextInt(statuses.length)];
      }

      return UserInvitation(
        id: 'inv_\${index}_\${random.nextInt(10000)}',
        email: 'user\${index}@example.com',
        role: roles[random.nextInt(roles.length)],
        organization: organizations[random.nextInt(organizations.length)],
        invitedBy: names[random.nextInt(names.length)],
        invitationDate: invitationDate,
        expiryDate: expiryDate,
        status: status,
      );
    });
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = List<UserInvitation>.from(state.allInvitations);

    // Apply Filter Tab
    if (state.selectedFilter != 'All') {
      filtered = filtered.where((i) => i.status == state.selectedFilter).toList();
    }

    // Apply Search
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((i) =>
        i.email.toLowerCase().contains(query) ||
        i.organization.toLowerCase().contains(query) ||
        i.role.toLowerCase().contains(query)
      ).toList();
    }

    // Sort by invitation date descending
    filtered.sort((a, b) => b.invitationDate.compareTo(a.invitationDate));

    state = state.copyWith(filteredInvitations: filtered);
  }

  void cancelInvitation(String id) {
    final updated = state.allInvitations.map((i) {
      if (i.id == id) return i.copyWith(status: 'Cancelled');
      return i;
    }).toList();
    state = state.copyWith(allInvitations: updated);
    _applyFilters();
  }

  void resendInvitation(String id) {
    // Just update the invitation date to now as a mock action
    final updated = state.allInvitations.map((i) {
      if (i.id == id) {
        return i.copyWith(
          invitationDate: DateTime.now(),
          expiryDate: DateTime.now().add(const Duration(days: 7)),
          status: 'Pending',
        );
      }
      return i;
    }).toList();
    state = state.copyWith(allInvitations: updated);
    _applyFilters();
  }

  Future<void> createInvitation({
    required String email,
    required String role,
    required String organization,
    required int expiryDays,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    final newInv = UserInvitation(
      id: 'inv_new_\${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      role: role,
      organization: organization,
      invitedBy: 'Current User', // Mocked
      invitationDate: DateTime.now(),
      expiryDate: DateTime.now().add(Duration(days: expiryDays)),
      status: 'Pending',
    );

    final updated = [newInv, ...state.allInvitations];
    state = state.copyWith(allInvitations: updated);
    _applyFilters();
  }
}

final userInvitationsProvider = NotifierProvider<UserInvitationsNotifier, UserInvitationsState>(
  UserInvitationsNotifier.new,
);
