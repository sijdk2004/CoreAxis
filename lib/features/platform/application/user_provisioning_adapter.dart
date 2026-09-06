import 'package:coreaxis/features/platform/domain/contracts/provisioning_boundaries.dart';
import 'package:coreaxis/features/platform/data/mock_platform_user_repository.dart';
import 'package:coreaxis/features/platform/domain/models/platform_user.dart';

class UserProvisioningAdapter implements IUserProvisioningAdapter {
  final MockPlatformUserRepository _repository;

  UserProvisioningAdapter(this._repository);

  @override
  Future<dynamic> createInitialAdministrator({
    required String tenantId,
    required String organizationId,
    required String name,
    required String email,
    required String provisioningRequestId,
  }) async {
    final hash = provisioningRequestId.hashCode.abs();
    final newId = 'USR-NEW-$hash';
    
    // Idempotency check
    final users = await _repository.getUsers();
    try {
      return users.firstWhere((u) => u.id == newId);
    } catch (_) {
      final newAdmin = PlatformUser(
        id: newId,
        email: email,
        firstName: name.split(' ').first,
        lastName: name.split(' ').length > 1 ? name.split(' ').last : '',
        role: PlatformUserRole.tenantAdmin,
        status: PlatformUserStatus.active,
        employeeId: 'EMP-$newId',
        tenantId: tenantId,
        organizationId: organizationId,
        lastLogin: null,
        avatarUrl: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random',
      );
      
      // We assume MockPlatformUserRepository can add or just returns it
      // Since it's a mock without create, we will just return it.
      return newAdmin;
    }
  }
}
