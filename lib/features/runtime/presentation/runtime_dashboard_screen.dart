import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/runtime_providers.dart';

class RuntimeDashboardScreen extends ConsumerWidget {
  const RuntimeDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navAsync = ref.watch(runtimeNavigationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workspace Dashboard'),
      ),
      body: navAsync.when(
        data: (modules) {
          if (modules.isEmpty) {
            return const Center(child: Text('No active modules in this workspace.'));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              itemCount: modules.length,
              itemBuilder: (context, index) {
                final module = modules[index];
                return Card(
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                      // Navigate would go here
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(module.icon, size: 48, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 16),
                        Text(module.displayName, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        const Text('Active', style: TextStyle(color: Colors.green)),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
