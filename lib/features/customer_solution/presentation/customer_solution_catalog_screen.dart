import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:coreaxis/features/customer_solution/application/customer_solution_providers.dart';
import 'package:coreaxis/features/customer_solution/domain/models/customer_solution_lifecycle.dart';
import 'package:coreaxis/features/platform/presentation/providers/tenant_provider.dart';

class CustomerSolutionCatalogScreen extends ConsumerWidget {
  const CustomerSolutionCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerSolutionListProvider);
    final currentTenantId = ref.watch(currentTenantIdProvider);
    final tenantState = ref.watch(tenantListProvider);

    // Get current tenant name for display
    String tenantName = 'Unknown Tenant';
    if (currentTenantId != null && tenantState.allTenants.isNotEmpty) {
      try {
        tenantName = tenantState.allTenants.firstWhere((t) => t.id == currentTenantId).name;
      } catch (_) {}
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Solutions'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<String?>(
              value: currentTenantId,
              hint: const Text('Select Tenant Context'),
              items: tenantState.allTenants.map((t) {
                return DropdownMenuItem(
                  value: t.id,
                  child: Text(t.name),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  ref.read(currentTenantIdProvider.notifier).setTenant(val);
                }
              },
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Viewing Solutions for Tenant: $tenantName',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (state.error != null) {
                  return Center(child: Text('Error: ${state.error}'));
                }
                
                if (currentTenantId == null) {
                   return const Center(child: Text('Please select a tenant context from the top right.'));
                }

                if (state.solutions.isEmpty) {
                  return const Center(child: Text('No Customer Solutions found for this tenant.'));
                }

                return ListView.builder(
                  itemCount: state.solutions.length,
                  itemBuilder: (context, index) {
                    final solution = state.solutions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: ListTile(
                        title: Text('Customer Solution: ${solution.id}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Source Business Solution: ${solution.sourceSolutionDefinitionId}'),
                            Text('Definition Version: ${solution.exactSolutionDefinitionVersion}'),
                            Text('Lifecycle: ${solution.lifecycleState.name}'),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          context.go('/customer-solutions/${solution.id}');
                        },
                      ),
                    );
                  },
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}
