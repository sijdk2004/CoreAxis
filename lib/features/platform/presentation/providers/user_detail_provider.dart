import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/platform_user.dart';
import 'platform_user_list_provider.dart';

class UserDetailState {
  final PlatformUser user;
  
  // Mock data for widgets
  final String lastLoginTime;
  final String lastLoginLocation;
  final String deviceSummary;
  final int securityScore;
  final bool isMfaEnabled;
  final double storageUsedGb;
  final double storageTotalGb;
  
  // Mock data for charts
  final List<double> loginTrend; // logins per day for the last 7 days
  final Map<String, double> departmentParticipation;
  final List<double> activityTimeline; // activities per hour

  UserDetailState({
    required this.user,
    required this.lastLoginTime,
    required this.lastLoginLocation,
    required this.deviceSummary,
    required this.securityScore,
    required this.isMfaEnabled,
    required this.storageUsedGb,
    required this.storageTotalGb,
    required this.loginTrend,
    required this.departmentParticipation,
    required this.activityTimeline,
  });
}

final userDetailProvider = FutureProvider.family<UserDetailState, String>((ref, id) async {
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 800));

  final repo = ref.read(platformUserRepositoryProvider);
  final users = await repo.getUsers();
  
  final user = users.firstWhere(
    (u) => u.id == id,
    orElse: () => throw Exception('User not found'),
  );

  return UserDetailState(
    user: user,
    lastLoginTime: '2 hours ago',
    lastLoginLocation: 'San Francisco, CA (192.168.1.1)',
    deviceSummary: 'MacBook Pro (macOS), iPhone 13 (iOS)',
    securityScore: 85,
    isMfaEnabled: user.isMfaEnabled,
    storageUsedGb: 2.4,
    storageTotalGb: 10.0,
    loginTrend: [2, 1, 3, 0, 4, 1, 2],
    departmentParticipation: {
      'Engineering': 60,
      'Product': 25,
      'Design': 15,
    },
    activityTimeline: [5, 12, 8, 20, 15, 30, 22, 10, 2, 0, 0, 1],
  );
});
