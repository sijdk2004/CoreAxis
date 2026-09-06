import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:coreaxis/features/customer_solution/application/customer_solution_providers.dart';
import 'package:coreaxis/features/customer_solution/domain/models/customer_solution_lifecycle.dart';

class CustomerSolutionDetailScreen extends ConsumerWidget {
  final String id;
  const CustomerSolutionDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final solutionAsync = ref.watch(customerSolutionProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Solution Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/customer-solutions'),
        ),
      ),
      body: solutionAsync.when(
        data: (solution) {
          if (solution == null) {
            return const Center(child: Text('Customer Solution not found.'));
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Identity'),
                _buildInfoRow('Customer Solution ID', solution.id),
                _buildInfoRow('Tenant ID', solution.tenantId),
                _buildInfoRow('Lifecycle', solution.lifecycleState.name),
                _buildInfoRow('Created', solution.createdAt.toIso8601String()),
                _buildInfoRow('Updated', solution.updatedAt.toIso8601String()),
                const SizedBox(height: 24),
                
                _buildSectionHeader('Source'),
                _buildInfoRow('Business Solution ID', solution.sourceSolutionDefinitionId),
                _buildInfoRow('Exact Solution Version', solution.exactSolutionDefinitionVersion),
                const SizedBox(height: 24),
                
                _buildSectionHeader('Module Traceability'),
                if (solution.moduleConfigurations.isEmpty)
                  const Text('No modules included.')
                else
                  ...solution.moduleConfigurations.map((m) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        title: Text('Module: ${m.reference.marketplaceModuleId}'),
                        subtitle: Text('Code: ${m.reference.moduleCode}\nExact Version: ${m.reference.exactPublishedVersion}'),
                        isThreeLine: true,
                      ),
                    );
                  }),
                  
                const SizedBox(height: 32),
                _buildActionsSection(context, ref, solution.lifecycleState, solution.id),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context, WidgetRef ref, CustomerSolutionLifecycle state, String solutionId) {
    if (state == CustomerSolutionLifecycle.provisioning) {
      return const Text('Provisioning is running. Actions disabled.');
    }
    
    return Row(
      children: [
        if (state == CustomerSolutionLifecycle.active)
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(customerSolutionListProvider.notifier).suspendCustomerSolution(solutionId);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer Solution suspended.')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Suspend'),
          ),
        
        if (state == CustomerSolutionLifecycle.suspended)
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(customerSolutionListProvider.notifier).reactivateCustomerSolution(solutionId);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer Solution reactivated.')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Reactivate'),
          ),
      ],
    );
  }
}
