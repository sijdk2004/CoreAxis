import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:coreaxis/features/platform/application/provisioning_controller.dart';
import 'package:coreaxis/features/platform/application/provisioning_providers.dart';
import 'package:coreaxis/features/platform/domain/models/provisioning_operation.dart';

class ProvisioningProgressScreen extends ConsumerStatefulWidget {
  final String provisioningRequestId;

  const ProvisioningProgressScreen({super.key, required this.provisioningRequestId});

  @override
  ConsumerState<ProvisioningProgressScreen> createState() => _ProvisioningProgressScreenState();
}

class _ProvisioningProgressScreenState extends ConsumerState<ProvisioningProgressScreen> {
  @override
  void initState() {
    super.initState();
    _loadInitial();
  }
  
  void _loadInitial() async {
     final op = await ref.read(mockProvisioningRepositoryProvider).getOperationByRequestId(widget.provisioningRequestId);
     if (op != null) {
       ref.read(provisioningControllerProvider.notifier).startOrResumeProvisioning(op.request);
     }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(provisioningControllerProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Provisioning Progress')),
      body: state.when(
        data: (operation) {
          if (operation == null || operation.request.provisioningRequestId != widget.provisioningRequestId) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final steps = [
            'Pending',
            'Tenant Creation',
            'Organization Creation',
            'Solution Assignment',
            'Module Validation',
            'Licensing/Entitlements',
            'Configuration Applied',
            'Initial Data Setup',
            'Administrator Creation',
            'Completed'
          ];
          
          final currentIndex = operation.processState.index;
          final isError = operation.operationState == ProvisioningOperationState.error;
          final isSuccess = operation.operationState == ProvisioningOperationState.success;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: steps.length,
                    itemBuilder: (context, index) {
                      final isPast = index <= currentIndex;
                      final isCurrent = index == currentIndex && !isSuccess;
                      
                      Color iconColor = Colors.grey;
                      IconData iconData = Icons.radio_button_unchecked;
                      
                      if (isPast && !isCurrent) {
                        iconColor = Colors.green;
                        iconData = Icons.check_circle;
                      } else if (isCurrent) {
                        if (isError) {
                          iconColor = Colors.red;
                          iconData = Icons.error;
                        } else {
                          iconColor = Colors.blue;
                          iconData = Icons.sync;
                        }
                      }
                      
                      if (isSuccess && index == steps.length - 1) {
                         iconColor = Colors.green;
                         iconData = Icons.check_circle;
                      }
                      
                      return ListTile(
                        leading: Icon(iconData, color: iconColor),
                        title: Text(steps[index], style: TextStyle(fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
                      );
                    },
                  ),
                ),
                if (isError) ...[
                  Text(operation.errorMessage ?? 'Unknown error occurred.', style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.read(provisioningControllerProvider.notifier).startOrResumeProvisioning(operation.request),
                    child: const Text('Retry'),
                  ),
                ],
                if (isSuccess) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.green.withOpacity(0.1),
                    child: const Text(
                      'Provisioning Complete\nCustomer Solution is active and ready for runtime.',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/provisioning'),
                    child: const Text('Return to Dashboard'),
                  ),
                ]
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(e.toString())),
      ),
    );
  }
}
