import 'package:coreaxis/features/platform/domain/contracts/provisioning_boundaries.dart';

class MockEntitlementAdapter implements IEntitlementValidatorAdapter {
  @override
  Future<bool> checkEntitlement(String tenantId, String solutionId) async {
    // In a real implementation, this would call a Licensing/Billing module.
    // For M8 mock purposes, we simulate an entitlement check passing.
    await Future.delayed(const Duration(milliseconds: 600));
    return true; // Simulating success
  }
}
