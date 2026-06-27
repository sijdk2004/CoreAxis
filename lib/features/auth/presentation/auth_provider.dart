import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/local_storage/secure_storage_service.dart';
import '../../../core/network/providers/network_providers.dart';
import '../data/auth_repository.dart';
import 'rbac_provider.dart';

enum AuthStateStatus { initial, authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStateStatus status;
  final String? errorMessage;
  AuthState({required this.status, this.errorMessage});
}

class AuthNotifier extends Notifier<AuthState> {
  late SecureStorageService _secureStorage;
  late AuthRepository _authRepository;

  @override
  AuthState build() {
    _secureStorage = ref.watch(secureStorageServiceProvider);
    _authRepository = ref.watch(authRepositoryProvider);
    _checkInitialState();
    return AuthState(status: AuthStateStatus.initial);
  }

  Future<void> _checkInitialState() async {
    final token = await _secureStorage.getAccessToken();
    // Fetch cached permissions to persist menus across refresh
    final permissions = await _secureStorage.getPermissions();
    if (permissions.isNotEmpty) {
      ref.read(rbacProvider.notifier).setPermissions(permissions);
    }
    
    if (token != null && token.isNotEmpty) {
      state = AuthState(status: AuthStateStatus.authenticated);
    } else {
      state = AuthState(status: AuthStateStatus.unauthenticated);
    }
  }

  Future<void> login(String username, String password, String tenantId) async {
    state = AuthState(status: AuthStateStatus.loading);
    try {
      // Mock login to skip backend request
      await Future.delayed(const Duration(milliseconds: 800));
      
      final mockPermissions = [
        'view_dashboard', 
        'manage_users', 
        'manage_roles', 
        'view_reports', 
        'manage_workflows',
        'manage_sales_orders',
        'manage_production_orders',
      ];
      
      // Save tokens
      await _secureStorage.saveTokens(
        accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token',
      );
      await _secureStorage.saveTenantAndOrg(tenantId: tenantId, orgId: 'default');
      
      // Update RBAC state and save to storage
      ref.read(rbacProvider.notifier).setPermissions(mockPermissions);
      await _secureStorage.savePermissions(mockPermissions);
      
      state = AuthState(status: AuthStateStatus.authenticated);
    } catch (e) {
      state = AuthState(status: AuthStateStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> logout() async {
    await _secureStorage.clearAll();
    ref.read(rbacProvider.notifier).clear();
    state = AuthState(status: AuthStateStatus.unauthenticated);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
