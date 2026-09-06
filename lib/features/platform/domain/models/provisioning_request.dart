class ProvisioningRequest {
  final String provisioningRequestId;
  final bool isNewTenant;
  final String? existingTenantId;
  final String? existingOrganizationId;
  
  final String? newTenantName;
  final String? newOrganizationName;
  final String? newOrganizationIndustry;
  final String? newOrganizationCountry;

  final String sourceSolutionDefinitionId;

  final String adminName;
  final String adminEmail;

  ProvisioningRequest({
    required this.provisioningRequestId,
    required this.isNewTenant,
    this.existingTenantId,
    this.existingOrganizationId,
    this.newTenantName,
    this.newOrganizationName,
    this.newOrganizationIndustry,
    this.newOrganizationCountry,
    required this.sourceSolutionDefinitionId,
    required this.adminName,
    required this.adminEmail,
  });
}
