import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coreaxis/features/platform/data/mock_provisioning_repository.dart';
import 'package:coreaxis/features/platform/data/mock_organization_repository.dart';
import 'package:coreaxis/features/platform/application/tenant_provisioning_adapter.dart';
import 'package:coreaxis/features/platform/application/organization_provisioning_adapter.dart';
import 'package:coreaxis/features/platform/application/user_provisioning_adapter.dart';
import 'package:coreaxis/features/platform/application/mock_entitlement_adapter.dart';
import 'package:coreaxis/features/marketplace/application/marketplace_dependency_adapter.dart';
import 'package:coreaxis/features/solution_management/application/solution_definition_adapter.dart';
import 'package:coreaxis/features/customer_solution/application/customer_solution_provisioning_adapter.dart';

import 'package:coreaxis/features/platform/presentation/providers/tenant_provider.dart';
import 'package:coreaxis/features/marketplace/application/marketplace_providers.dart';
import 'package:coreaxis/features/solution_management/application/solution_management_providers.dart';
import 'package:coreaxis/features/customer_solution/application/customer_solution_providers.dart';
import 'package:coreaxis/features/platform/presentation/providers/platform_user_list_provider.dart';

final mockProvisioningRepositoryProvider = Provider((ref) => MockProvisioningRepository());
final mockOrganizationRepositoryProvider = Provider((ref) => MockOrganizationRepository());

final tenantProvisioningAdapterProvider = Provider((ref) => TenantProvisioningAdapter(ref.read(tenantRepositoryProvider)));
final organizationProvisioningAdapterProvider = Provider((ref) => OrganizationProvisioningAdapter(ref.read(mockOrganizationRepositoryProvider)));
final userProvisioningAdapterProvider = Provider((ref) => UserProvisioningAdapter(ref.read(platformUserRepositoryProvider)));
final mockEntitlementAdapterProvider = Provider((ref) => MockEntitlementAdapter());
final marketplaceDependencyAdapterProvider = Provider((ref) => MarketplaceDependencyAdapter(ref.read(marketplaceRepositoryProvider)));
final solutionDefinitionAdapterProvider = Provider((ref) => SolutionDefinitionAdapter(ref.read(mockSolutionDefinitionRepositoryProvider)));
final customerSolutionProvisioningAdapterProvider = Provider((ref) => CustomerSolutionProvisioningAdapter(ref.read(mockCustomerSolutionRepositoryProvider)));
