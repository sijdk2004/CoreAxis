import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:coreaxis/features/platform/application/provisioning_providers.dart';
import 'package:coreaxis/features/platform/domain/models/provisioning_operation.dart';

class ProvisioningDashboardScreen extends ConsumerStatefulWidget {
  const ProvisioningDashboardScreen({super.key});

  @override
  ConsumerState<ProvisioningDashboardScreen> createState() => _ProvisioningDashboardScreenState();
}

class _ProvisioningDashboardScreenState extends ConsumerState<ProvisioningDashboardScreen> {
  List<ProvisioningOperation> _operations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOperations();
  }

  Future<void> _loadOperations() async {
    final repo = ref.read(mockProvisioningRepositoryProvider);
    final ops = await repo.getAllOperations();
    if (mounted) {
      setState(() {
        _operations = ops;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Provisioning'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadOperations();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _operations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No provisioning operations found.'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.go('/provisioning/new'),
                        child: const Text('Provision New Customer'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _operations.length,
                  itemBuilder: (context, index) {
                    final op = _operations[index];
                    final isComplete = op.processState == ProvisioningProcessState.completed;
                    final isError = op.operationState == ProvisioningOperationState.error;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isComplete ? Colors.green : (isError ? Colors.red : Colors.orange),
                        child: Icon(
                          isComplete ? Icons.check : (isError ? Icons.error : Icons.sync),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(op.request.isNewTenant ? 'New Tenant Provisioning' : 'Existing Tenant Provisioning'),
                      subtitle: Text('Status: ${op.processState.name.replaceAll('_', ' ')}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.go('/provisioning/${op.request.provisioningRequestId}/progress');
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/provisioning/new'),
        icon: const Icon(Icons.add),
        label: const Text('New Provisioning'),
      ),
    );
  }
}
