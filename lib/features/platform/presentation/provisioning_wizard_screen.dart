import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:coreaxis/features/platform/application/provisioning_controller.dart';
import 'package:coreaxis/features/platform/domain/models/provisioning_request.dart';
import 'package:coreaxis/features/platform/presentation/providers/tenant_provider.dart';
import 'package:coreaxis/features/solution_management/application/solution_management_providers.dart';
import 'package:uuid/uuid.dart';

class ProvisioningWizardScreen extends ConsumerStatefulWidget {
  const ProvisioningWizardScreen({super.key});

  @override
  ConsumerState<ProvisioningWizardScreen> createState() => _ProvisioningWizardScreenState();
}

class _ProvisioningWizardScreenState extends ConsumerState<ProvisioningWizardScreen> {
  int _currentStep = 0;
  bool _isNewTenant = true;
  
  // Controllers
  final _tenantNameCtrl = TextEditingController();
  final _orgNameCtrl = TextEditingController();
  final _adminNameCtrl = TextEditingController();
  final _adminEmailCtrl = TextEditingController();

  String? _selectedTenantId;
  String? _selectedSolutionId;

  @override
  Widget build(BuildContext context) {
    final tenants = ref.watch(tenantRepositoryProvider).getTenants(); // Synchronous for mock or need async
    // Since MockTenantRepository getTenants is async in standard flow, we might need a FutureBuilder.
    // For simplicity, we just assume we can fetch them. Let's use FutureBuilder.
    
    return Scaffold(
      appBar: AppBar(title: const Text('Provision New Customer')),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 3) {
            setState(() => _currentStep += 1);
          } else {
            _submit();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          } else {
            context.pop();
          }
        },
        steps: [
          Step(
            title: const Text('Tenant'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: const Text('Create New Tenant'),
                  value: _isNewTenant,
                  onChanged: (val) {
                    setState(() {
                      _isNewTenant = val;
                      _selectedTenantId = null;
                    });
                  },
                ),
                if (_isNewTenant)
                  TextFormField(
                    controller: _tenantNameCtrl,
                    decoration: const InputDecoration(labelText: 'New Tenant Name'),
                  )
                else
                  FutureBuilder(
                    future: ref.read(tenantRepositoryProvider).getTenants(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const CircularProgressIndicator();
                      final list = snapshot.data as List;
                      return DropdownButtonFormField<String>(
                        value: _selectedTenantId,
                        items: list.map((t) => DropdownMenuItem(value: t.id as String, child: Text(t.name))).toList(),
                        onChanged: (val) => setState(() => _selectedTenantId = val),
                        decoration: const InputDecoration(labelText: 'Select Existing Tenant'),
                      );
                    }
                  )
              ],
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Organization'),
            content: TextFormField(
              controller: _orgNameCtrl,
              decoration: const InputDecoration(labelText: 'Organization Name'),
            ),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Solution'),
            content: FutureBuilder(
              future: ref.read(mockSolutionDefinitionRepositoryProvider).getDefinitions(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final list = snapshot.data as List;
                return DropdownButtonFormField<String>(
                  value: _selectedSolutionId,
                  items: list.map((s) => DropdownMenuItem(value: s.id as String, child: Text(s.name))).toList(),
                  onChanged: (val) => setState(() => _selectedSolutionId = val),
                  decoration: const InputDecoration(labelText: 'Select Solution Blueprint'),
                );
              }
            ),
            isActive: _currentStep >= 2,
          ),
          Step(
            title: const Text('Admin'),
            content: Column(
              children: [
                TextFormField(
                  controller: _adminNameCtrl,
                  decoration: const InputDecoration(labelText: 'Admin Full Name'),
                ),
                TextFormField(
                  controller: _adminEmailCtrl,
                  decoration: const InputDecoration(labelText: 'Admin Email'),
                ),
              ],
            ),
            isActive: _currentStep >= 3,
          ),
        ],
      ),
    );
  }

  void _submit() {
    final reqId = const Uuid().v4();
    final req = ProvisioningRequest(
      provisioningRequestId: reqId,
      isNewTenant: _isNewTenant,
      existingTenantId: _selectedTenantId,
      newTenantName: _tenantNameCtrl.text,
      newOrganizationName: _orgNameCtrl.text,
      sourceSolutionDefinitionId: _selectedSolutionId ?? 'sd-1',
      adminName: _adminNameCtrl.text,
      adminEmail: _adminEmailCtrl.text,
    );

    ref.read(provisioningControllerProvider.notifier).startOrResumeProvisioning(req);
    context.go('/provisioning/$reqId/progress');
  }
}
