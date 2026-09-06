import 'package:coreaxis/features/platform/domain/models/tenant.dart';
import 'package:coreaxis/features/platform/domain/models/organization.dart';

abstract class ITenantProvisioningAdapter {
  Future<Tenant> createTenant({
    required String name,
    required String provisioningRequestId,
  });
  Future<Tenant?> getTenant(String tenantId);
}

abstract class IOrganizationProvisioningAdapter {
  Future<Organization> createOrganization({
    required String tenantId,
    required String tenantName,
    required String name,
    required String industry,
    required String country,
    required String provisioningRequestId,
  });
}

abstract class ISolutionDefinitionProviderAdapter {
  Future<dynamic> getSolutionDefinition(String id);
  // We return dynamic or an abstract wrapper here to avoid tight coupling if preferred,
  // but since SolutionDefinition is a DTO, importing the model would be technically fine. 
  // To be safe, we'll return dynamic and cast locally, or create a DTO.
}

abstract class IMarketplaceDependencyValidatorAdapter {
  Future<bool> validateDependencies(List<String> moduleIds);
}

abstract class IEntitlementValidatorAdapter {
  Future<bool> checkEntitlement(String tenantId, String solutionId);
}

abstract class IUserProvisioningAdapter {
  Future<dynamic> createInitialAdministrator({
    required String tenantId,
    required String organizationId,
    required String name,
    required String email,
    required String provisioningRequestId,
  });
}

abstract class ICustomerSolutionProvisioningAdapter {
  Future<dynamic> createCustomerSolution({
    required String tenantId,
    required String sourceSolutionDefinitionId,
    required String exactSolutionDefinitionVersion,
    required String provisioningRequestId,
  });
  
  Future<void> activateCustomerSolution(String customerSolutionId);
  
  Future<void> resolveEffectiveConfiguration(String customerSolutionId);
}
