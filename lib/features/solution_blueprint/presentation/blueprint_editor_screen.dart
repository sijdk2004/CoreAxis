import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coreaxis/features/solution_blueprint/application/blueprint_providers.dart';
import 'package:coreaxis/features/solution_blueprint/domain/models/marketplace_module_reference.dart';
import 'package:coreaxis/features/solution_blueprint/domain/models/solution_blueprint.dart';
import 'package:go_router/go_router.dart';

class BlueprintEditorScreen extends ConsumerStatefulWidget {
  final String blueprintId;

  const BlueprintEditorScreen({super.key, required this.blueprintId});

  @override
  ConsumerState<BlueprintEditorScreen> createState() => _BlueprintEditorScreenState();
}

class _BlueprintEditorScreenState extends ConsumerState<BlueprintEditorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(blueprintEditorControllerProvider.notifier).loadBlueprint(widget.blueprintId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(blueprintEditorControllerProvider);

    if (state.isLoading && state.blueprint == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.error != null && state.blueprint == null) {
      return Scaffold(body: Center(child: Text('Error: ${state.error}')));
    }

    final blueprint = state.blueprint;
    if (blueprint == null) {
      return const Scaffold(body: Center(child: Text('Blueprint not found')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit: ${blueprint.name}'),
        actions: [
          if (blueprint.state == BlueprintState.published)
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Compose Solution'),
              onPressed: () {
                context.go('/blueprints/${blueprint.id}/compose');
              },
            ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Blueprint',
            onPressed: () {
              ref.read(blueprintEditorControllerProvider.notifier).saveBlueprint();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Blueprint saved')));
            },
          )
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: Blueprint details and validation
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Industry: ${blueprint.industry}', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(blueprint.description),
                  const SizedBox(height: 24),
                  const Text('Validation Status', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildValidationPanel(blueprint.validationResult),
                ],
              ),
            ),
          ),
          
          const VerticalDivider(width: 1),
          
          // Right side: Module References
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Composed Modules (${blueprint.moduleReferences.length})', 
                        style: Theme.of(context).textTheme.titleLarge),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Module'),
                        onPressed: () async {
                          // Navigate to Marketplace Explorer in selection mode
                            final result = await context.push<Map<String, String>>('/marketplace/explorer?mode=selection');
                            if (result != null && result.containsKey('moduleId') && result.containsKey('version') && result.containsKey('moduleCode')) {
                              ref.read(blueprintEditorControllerProvider.notifier)
                                 .addModuleReference(result['moduleId']!, result['moduleCode']!, result['version']!);
                            }
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: blueprint.moduleReferences.isEmpty
                      ? const Center(child: Text('No modules selected. Add a module to begin composition.'))
                      : ListView.builder(
                          itemCount: blueprint.moduleReferences.length,
                          itemBuilder: (context, index) {
                            final refModel = blueprint.moduleReferences[index];
                            return _ModuleReferenceTile(
                              moduleRef: refModel,
                              onRemove: () {
                                ref.read(blueprintEditorControllerProvider.notifier)
                                   .removeModuleReference(refModel.marketplaceModuleId);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildValidationPanel(validationResult) {
    if (validationResult == null) {
      return const Text('Pending validation...');
    }

    if (validationResult.isValid && validationResult.warnings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        color: Colors.green.withValues(alpha: 0.1),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Blueprint is valid and composition is sound.', style: TextStyle(color: Colors.green)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!validationResult.isValid)
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.red.withValues(alpha: 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Validation Errors', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                ...validationResult.errors.map((e) => Text('• $e', style: const TextStyle(color: Colors.red))),
              ],
            ),
          ),
        
        if (validationResult.warnings.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.orange.withValues(alpha: 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Warnings', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                ...validationResult.warnings.map((w) => Text('• $w', style: const TextStyle(color: Colors.orange))),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ModuleReferenceTile extends StatelessWidget {
  final MarketplaceModuleReference moduleRef;
  final VoidCallback onRemove;

  const _ModuleReferenceTile({required this.moduleRef, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.view_module),
        title: Text(moduleRef.moduleCode),
        subtitle: Row(
          children: [
            Text('Pinned: v${moduleRef.exactPublishedVersion}'),
            if (moduleRef.hasUpdateAvailable) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.blue),
                ),
                child: const Text('Update Available', style: TextStyle(color: Colors.blue, fontSize: 10)),
              )
            ]
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onRemove,
        ),
      ),
    );
  }
}
