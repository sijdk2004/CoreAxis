import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/audit_dashboard_model.dart';

final auditDashboardProvider = AsyncNotifierProvider<AuditDashboardNotifier, AuditDashboardModel>(() {
  return AuditDashboardNotifier();
});

class AuditDashboardNotifier extends AsyncNotifier<AuditDashboardModel> {
  @override
  FutureOr<AuditDashboardModel> build() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));
    return generateMockAuditDashboard();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(milliseconds: 800));
      return generateMockAuditDashboard();
    });
  }
}
