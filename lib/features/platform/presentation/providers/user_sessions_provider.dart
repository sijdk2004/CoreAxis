import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_session.dart';

class UserSessionsState {
  final List<UserSession> allSessions;
  final List<UserSession> filteredSessions;
  final bool isLoading;
  final String searchQuery;
  final String selectedFilter; // 'All', 'Desktop', 'Mobile', 'Browser', 'Active', 'Expired'
  
  const UserSessionsState({
    this.allSessions = const [],
    this.filteredSessions = const [],
    this.isLoading = false,
    this.searchQuery = '',
    this.selectedFilter = 'All',
  });

  UserSessionsState copyWith({
    List<UserSession>? allSessions,
    List<UserSession>? filteredSessions,
    bool? isLoading,
    String? searchQuery,
    String? selectedFilter,
  }) {
    return UserSessionsState(
      allSessions: allSessions ?? this.allSessions,
      filteredSessions: filteredSessions ?? this.filteredSessions,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

class UserSessionsNotifier extends Notifier<UserSessionsState> {
  String? _userId;

  @override
  UserSessionsState build() {
    return const UserSessionsState(isLoading: true);
  }

  void init(String userId) async {
    if (_userId == userId) return;
    _userId = userId;

    state = const UserSessionsState(isLoading: true);
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final mockSessions = _generateMockSessions(userId);
    
    state = state.copyWith(
      allSessions: mockSessions,
      isLoading: false,
    );
    _applyFilters();
  }

  List<UserSession> _generateMockSessions(String userId) {
    final random = Random(userId.hashCode);
    final devices = ['MacBook Pro', 'iPhone 14', 'Windows PC', 'iPad Pro', 'Samsung Galaxy S23'];
    final browsers = ['Chrome', 'Safari', 'Native App', 'Edge', 'Firefox'];
    final osList = ['macOS Ventura', 'iOS 16', 'Windows 11', 'iPadOS 16', 'Android 13'];
    final locations = ['New York, US', 'London, UK', 'Tokyo, JP', 'Berlin, DE', 'Toronto, CA'];
    final statuses = ['Active', 'Expired'];

    return List.generate(15, (index) {
      final now = DateTime.now();
      final loginTime = now.subtract(Duration(days: random.nextInt(30), hours: random.nextInt(24)));
      final lastActivity = loginTime.add(Duration(hours: random.nextInt(10)));
      
      final isDesktop = index % 2 == 0;
      final status = (index == 0 || index == 2) ? 'Active' : statuses[random.nextInt(statuses.length)];

      return UserSession(
        id: 'sess_\${index}_\${random.nextInt(10000)}',
        userId: userId,
        device: devices[random.nextInt(devices.length)],
        browser: isDesktop ? browsers[random.nextInt(2) == 0 ? 0 : 3] : 'Native App',
        os: isDesktop ? osList[random.nextInt(2) == 0 ? 0 : 2] : osList[random.nextInt(2) == 0 ? 1 : 4],
        ipAddress: '\${random.nextInt(256)}.\${random.nextInt(256)}.\${random.nextInt(256)}.\${random.nextInt(256)}',
        location: locations[random.nextInt(locations.length)],
        loginTime: loginTime,
        lastActivity: lastActivity,
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

  void terminateSession(String sessionId) {
    final updatedSessions = state.allSessions.map((session) {
      if (session.id == sessionId) {
        return session.copyWith(status: 'Expired');
      }
      return session;
    }).toList();

    state = state.copyWith(allSessions: updatedSessions);
    _applyFilters();
  }

  void terminateAllSessions() {
    final updatedSessions = state.allSessions.map((session) {
      return session.copyWith(status: 'Expired');
    }).toList();

    state = state.copyWith(allSessions: updatedSessions);
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = List<UserSession>.from(state.allSessions);

    // Apply Filter Tab
    switch (state.selectedFilter) {
      case 'Desktop':
        filtered = filtered.where((s) => s.os.contains('macOS') || s.os.contains('Windows')).toList();
        break;
      case 'Mobile':
        filtered = filtered.where((s) => s.os.contains('iOS') || s.os.contains('Android') || s.os.contains('iPadOS')).toList();
        break;
      case 'Browser':
        filtered = filtered.where((s) => s.browser != 'Native App').toList();
        break;
      case 'Active':
        filtered = filtered.where((s) => s.status == 'Active').toList();
        break;
      case 'Expired':
        filtered = filtered.where((s) => s.status == 'Expired').toList();
        break;
    }

    // Apply Search
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((s) =>
        s.device.toLowerCase().contains(query) ||
        s.ipAddress.toLowerCase().contains(query) ||
        s.location.toLowerCase().contains(query)
      ).toList();
    }

    // Sort by last activity descending
    filtered.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));

    state = state.copyWith(filteredSessions: filtered);
  }
}

final userSessionsProvider = NotifierProvider<UserSessionsNotifier, UserSessionsState>(
  UserSessionsNotifier.new,
);
