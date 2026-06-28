import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/platform_user.dart';
import 'dart:math';

class MockPlatformUserRepository {
  List<PlatformUser> _generateMockUsers() {
    final random = Random(42);
    final users = <PlatformUser>[];
    
    final firstNames = ['James', 'Mary', 'John', 'Patricia', 'Robert', 'Jennifer', 'Michael', 'Linda', 'William', 'Elizabeth', 'David', 'Barbara', 'Richard', 'Susan', 'Joseph', 'Jessica', 'Thomas', 'Sarah', 'Charles', 'Karen'];
    final lastNames = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin'];
    final roles = PlatformUserRole.values;
    final statuses = PlatformUserStatus.values;
    
    final tenants = ['TN-100', 'TN-101', 'TN-102', 'TN-103'];
    final orgs = ['ORG-100', 'ORG-200', 'ORG-300'];
    final depts = ['Engineering', 'Sales', 'HR', 'Finance', 'Operations', 'Marketing'];

    for (int i = 0; i < 100; i++) {
      final fName = firstNames[random.nextInt(firstNames.length)];
      final lName = lastNames[random.nextInt(lastNames.length)];
      
      // Bias towards active status
      final statusRoll = random.nextDouble();
      PlatformUserStatus status = PlatformUserStatus.active;
      if (statusRoll > 0.8) status = PlatformUserStatus.inactive;
      if (statusRoll > 0.9) status = PlatformUserStatus.pending;
      if (statusRoll > 0.95) status = PlatformUserStatus.locked;

      users.add(PlatformUser(
        id: 'USR-${1000 + i}',
        firstName: fName,
        lastName: lName,
        email: '${fName.toLowerCase()}.${lName.toLowerCase()}@example.com',
        employeeId: 'EMP${20000 + i}',
        mobile: '+1 555-${100 + random.nextInt(899)}-${1000 + random.nextInt(8999)}',
        avatarUrl: 'https://i.pravatar.cc/150?u=USR${1000 + i}',
        tenantId: tenants[random.nextInt(tenants.length)],
        tenantName: 'Acme Corp ${random.nextInt(10)}',
        organizationId: orgs[random.nextInt(orgs.length)],
        organizationName: 'Org Unit ${random.nextInt(10)}',
        departmentId: 'DPT-${random.nextInt(100)}',
        departmentName: depts[random.nextInt(depts.length)],
        role: roles[random.nextInt(roles.length)],
        status: status,
        lastLogin: status == PlatformUserStatus.active || status == PlatformUserStatus.locked
            ? DateTime.now().subtract(Duration(hours: random.nextInt(100), minutes: random.nextInt(60)))
            : null,
        isMfaEnabled: random.nextDouble() > 0.3, // 70% MFA enabled
        isOnline: status == PlatformUserStatus.active && random.nextDouble() > 0.7,
      ));
    }
    
    return users;
  }

  late List<PlatformUser> _users = _generateMockUsers();

  Future<List<PlatformUser>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.unmodifiable(_users);
  }

  Future<void> updateUserStatus(String id, PlatformUserStatus newStatus) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _users.indexWhere((u) => u.id == id);
    if (index != -1) {
      _users[index] = _users[index].copyWith(status: newStatus);
    }
  }

  Future<void> bulkUpdateStatus(List<String> ids, PlatformUserStatus newStatus) async {
    await Future.delayed(const Duration(milliseconds: 500));
    for (final id in ids) {
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) {
        _users[index] = _users[index].copyWith(status: newStatus);
      }
    }
  }

  Future<void> deleteUsers(List<String> ids) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _users.removeWhere((u) => ids.contains(u.id));
  }
}
