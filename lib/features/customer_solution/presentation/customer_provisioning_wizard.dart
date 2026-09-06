import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:coreaxis/features/customer_solution/application/customer_solution_providers.dart';
import 'package:coreaxis/features/customer_solution/domain/models/customer_solution.dart';
import 'package:coreaxis/features/customer_solution/domain/models/customer_solution_lifecycle.dart';
import 'package:coreaxis/features/solution_management/application/solution_management_providers.dart';
import 'package:coreaxis/features/solution_management/domain/models/solution_definition.dart';
import 'package:coreaxis/features/platform/presentation/providers/tenant_provider.dart';

class CustomerProvisioningWizard extends ConsumerStatefulWidget {
  final String definitionId;
  const CustomerProvisioningWizard({super.key, required this.definitionId});

  @override
  ConsumerState<CustomerProvisioningWizard> createState() => _CustomerProvisioningWizardState();
}

class _CustomerProvisioningWizardState extends ConsumerState<CustomerProvisioningWizard> {
  int _currentStep = 0;
  String? _selectedTenantId;

  @override
  Widget build(BuildContext context) {
    final definitionAsync = ref.watch(solutionDefinitionProvider(widget.definitionId));
    final tenantState = ref.watch(tenantListProvider);
    final opState = ref.watch(provisioningOperationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Provision Customer Solution'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: definitionAsync.when(
        data: (definition) {
          if (definition == null) {
            return const Center(child: Text('Source Business Solution not found.'));
          }

          if (definition.state != SolutionDefinitionState.published) {
            return const Center(child: Text('Error: Only published solutions can be provisioned.'));
          }

          if (opState == ProvisioningOperationState.success) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 64),
                  const SizedBox(height: 16),
                  const Text('Customer Solution Provisioned Successfully!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(provisioningOperationProvider.notifier).reset();
                      context.go('/customer-solutions');
                    },
                    child: const Text('Go to Customer Solutions'),
                  )
                ],
              ),
            );
          }

          if (opState == ProvisioningOperationState.provisioning || opState == ProvisioningOperationState.validating) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Provisioning in progress...'),
                ],
              ),
            );
          }

          return Stepper(
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep == 0) {
                if (_selectedTenantId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a tenant.')));
                  return;
                }
                setState(() => _currentStep++);
              } else if (_currentStep == 1) {
                setState(() => _currentStep++);
              } else if (_currentStep == 2) {
                _provision(definition);
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep--);
              } else {
                context.pop();
              }
            },
            steps: [
              Step(
                title: const Text('Select Tenant'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select the tenant that will receive this Customer Solution.'),
                    const SizedBox(height: 16),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedTenantId,
                      hint: const Text('Select a Mock Tenant'),
                      items: tenantState.allTenants.map((t) {
                        return DropdownMenuItem(
                          value: t.id,
                          child: Text(t.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedTenantId = val;
                        });
                      },
                    ),
                  ],
                ),
                isActive: _currentStep >= 0,
              ),
              Step(
                title: const Text('Review Business Solution'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Business Solution ID: ${definition.id}'),
                    Text('Exact Version: 1.0.0 (Simulated version for M7 mock)'),
                    const SizedBox(height: 16),
                    const Text('Included Modules:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...definition.moduleConfigurations.map((m) => Text('- ${m.reference.moduleCode} (v${m.reference.exactPublishedVersion})')),
                  ],
                ),
                isActive: _currentStep >= 1,
              ),
              Step(
                title: const Text('Confirm & Provision'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('This Customer Solution will be created from:'),
                    const SizedBox(height: 8),
                    Text('Business Solution: ${definition.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Text('SolutionDefinition Version: 1.0.0', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Tenant: $_selectedTenantId', style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (ref.read(provisioningOperationProvider.notifier).error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text('Error: ${ref.read(provisioningOperationProvider.notifier).error}', style: const TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
                isActive: _currentStep >= 2,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Future<void> _provision(SolutionDefinition definition) async {
    final tenantId = _selectedTenantId;
    if (tenantId == null) return;

    await ref.read(provisioningOperationProvider.notifier).runProvisioning(() async {
      // Create Customer Solution Snapshot
      final newId = const Uuid().v4();
      final now = DateTime.now();

      final customerSolution = CustomerSolution(
        id: newId,
        tenantId: tenantId,
        sourceSolutionDefinitionId: definition.id,
        exactSolutionDefinitionVersion: '1.0.0', // Standardized mock version for M7 requirement
        moduleConfigurations: CustomerSolution.deepCopyModules(definition.moduleConfigurations),
        lifecycleState: CustomerSolutionLifecycle.provisioning,
        createdAt: now,
        updatedAt: now,
      );

      final controller = ref.read(customerSolutionListProvider.notifier);
      final created = await controller.provisionCustomerSolution(customerSolution);
      
      // Simulate mock completion transition to active
      await Future.delayed(const Duration(milliseconds: 500));
      await controller.activateCustomerSolution(created.id);
    });
  }
}
