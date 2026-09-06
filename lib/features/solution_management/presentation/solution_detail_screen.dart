import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:coreaxis/features/solution_management/application/solution_management_providers.dart';
import 'package:coreaxis/features/solution_management/domain/models/solution_definition.dart';

class SolutionDetailScreen extends ConsumerWidget {
  final String solutionId;

  const SolutionDetailScreen({super.key, required this.solutionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final solutionsAsync = ref.watch(solutionDefinitionListProvider);
    final mgmtState = ref.watch(solutionManagementControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solution Definition Details'),
        actions: [
          solutionsAsync.maybeWhen(
            data: (solutions) {
              final definition = solutions.cast<SolutionDefinition?>().firstWhere(
                    (s) => s?.id == solutionId,
                    orElse: () => null,
                  );

              if (definition == null) return const SizedBox.shrink();

              final isPublished = definition.state == SolutionDefinitionState.published;
              
              return Tooltip(
                message: isPublished
                    ? 'Published Solution Definitions are locked. Create a new version to make future changes.'
                    : 'Edit in Composer',
                child: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: isPublished
                      ? null
                      : () {
                          context.go('/solutions/${definition.id}/edit');
                        },
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: solutionsAsync.when(
        data: (solutions) {
          final definition = solutions.cast<SolutionDefinition?>().firstWhere(
                (s) => s?.id == solutionId,
                orElse: () => null,
              );

          if (definition == null) {
            return const Center(child: Text('Solution Definition not found.'));
          }

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIdentitySection(context, definition),
                    const SizedBox(height: 24),
                    _buildOriginSection(context, definition),
                    const SizedBox(height: 24),
                    _buildModuleCompositionSection(context, definition),
                    const SizedBox(height: 32),
                    _buildLifecycleActions(context, ref, definition),
                  ],
                ),
              ),
              if (mgmtState.isLoading)
                Container(
                  color: Colors.black12,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildIdentitySection(BuildContext context, SolutionDefinition definition) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Identity', style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            ListTile(
              title: const Text('Name'),
              subtitle: Text(definition.name),
            ),
            ListTile(
              title: const Text('ID / Code'),
              subtitle: Text(definition.id),
            ),
            ListTile(
              title: const Text('Description'),
              subtitle: Text(definition.description.isEmpty ? 'N/A' : definition.description),
            ),
            ListTile(
              title: const Text('State'),
              subtitle: Text(
                definition.state.name.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: definition.state == SolutionDefinitionState.published ? Colors.green : Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOriginSection(BuildContext context, SolutionDefinition definition) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Origin', style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            ListTile(
              title: const Text('Source Blueprint ID'),
              subtitle: Text(definition.sourceBlueprintId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCompositionSection(BuildContext context, SolutionDefinition definition) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Module Composition', style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            if (definition.moduleConfigurations.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No modules configured.'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: definition.moduleConfigurations.length,
                itemBuilder: (context, index) {
                  final config = definition.moduleConfigurations[index];
                  return ListTile(
                    leading: const Icon(Icons.extension),
                    title: Text(config.reference.moduleCode),
                    subtitle: Text('Exact Version: ${config.reference.exactPublishedVersion}'),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLifecycleActions(BuildContext context, WidgetRef ref, SolutionDefinition definition) {
    final controller = ref.read(solutionManagementControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lifecycle Actions', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            if (definition.state == SolutionDefinitionState.draft)
              ElevatedButton(
                onPressed: () => _handleTransition(context, () => controller.transitionToDesign(definition)),
                child: const Text('Transition to Design'),
              ),
            if (definition.state == SolutionDefinitionState.draft || definition.state == SolutionDefinitionState.design)
              ElevatedButton(
                onPressed: () => _handleTransition(context, () => controller.transitionToConfiguration(definition)),
                child: const Text('Transition to Configuration'),
              ),
            if (definition.state == SolutionDefinitionState.configuration)
              ElevatedButton(
                onPressed: () => _handleTransition(context, () => controller.transitionToValidation(definition)),
                child: const Text('Transition to Validation'),
              ),
            if (definition.state == SolutionDefinitionState.validation)
              ElevatedButton(
                onPressed: () => _handleTransition(context, () => controller.transitionToPreview(definition)),
                child: const Text('Transition to Preview'),
              ),
            if (definition.state == SolutionDefinitionState.preview || definition.state == SolutionDefinitionState.validation)
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                onPressed: () => _handleTransition(context, () => controller.publish(definition)),
                child: const Text('Publish Solution'),
              ),
            if (definition.state == SolutionDefinitionState.published)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'This Solution Definition is PUBLISHED and LOCKED. '
                      'It is available for future Business Solution instantiation.',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.go('/customer-solutions/provision/${definition.id}');
                    },
                    icon: const Icon(Icons.rocket_launch),
                    label: const Text('Provision to Customer'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleTransition(BuildContext context, Future<void> Function() action) async {
    try {
      await action();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('State transition successful.')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }
}
