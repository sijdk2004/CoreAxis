import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coreaxis/features/solution_blueprint/application/blueprint_providers.dart';
import 'package:coreaxis/features/solution_blueprint/domain/models/solution_blueprint.dart';
import 'package:go_router/go_router.dart';

class BlueprintDashboardScreen extends ConsumerWidget {
  const BlueprintDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blueprintsAsync = ref.watch(blueprintListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solution Blueprints'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create Blueprint',
            onPressed: () async {
              final result = await showDialog<Map<String, String>>(
                context: context,
                builder: (context) => const _CreateBlueprintDialog(),
              );
              if (result != null && context.mounted) {
                final repo = ref.read(mockBlueprintRepositoryProvider);
                final newBp = await repo.createBlueprint(result['name']!, result['industry']!, result['description']!);
                ref.invalidate(blueprintListProvider);
                if (context.mounted) {
                  context.go('/blueprints/${newBp.id}');
                }
              }
            },
          ),
        ],
      ),
      body: blueprintsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (blueprints) {
          if (blueprints.isEmpty) {
            return const Center(child: Text('No Blueprints found.'));
          }
          return ListView.builder(
            itemCount: blueprints.length,
            itemBuilder: (context, index) {
              final blueprint = blueprints[index];
              return _BlueprintCard(blueprint: blueprint);
            },
          );
        },
      ),
    );
  }
}

class _BlueprintCard extends StatelessWidget {
  final SolutionBlueprint blueprint;

  const _BlueprintCard({required this.blueprint});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(blueprint.name, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(blueprint.industry),
            Text(
              blueprint.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: _buildStateChip(blueprint.state),
        onTap: () {
          context.go('/blueprints/${blueprint.id}');
        },
      ),
    );
  }

  Widget _buildStateChip(BlueprintState state) {
    Color color;
    switch (state) {
      case BlueprintState.draft:
        color = Colors.grey;
        break;
      case BlueprintState.validated:
        color = Colors.blue;
        break;
      case BlueprintState.published:
        color = Colors.green;
        break;
      case BlueprintState.deprecated:
        color = Colors.orange;
        break;
      case BlueprintState.retired:
        color = Colors.red;
        break;
    }
    return Chip(
      label: Text(state.name.toUpperCase(), style: const TextStyle(fontSize: 10)),
      backgroundColor: color.withValues(alpha: 0.2),
      side: BorderSide(color: color),
    );
  }
}

class _CreateBlueprintDialog extends StatefulWidget {
  const _CreateBlueprintDialog();

  @override
  State<_CreateBlueprintDialog> createState() => _CreateBlueprintDialogState();
}

class _CreateBlueprintDialogState extends State<_CreateBlueprintDialog> {
  final _nameController = TextEditingController();
  final _industryController = TextEditingController();
  final _descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Solution Blueprint'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: _industryController, decoration: const InputDecoration(labelText: 'Industry')),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Description')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              Navigator.pop(context, {
                'name': _nameController.text,
                'industry': _industryController.text,
                'description': _descController.text,
              });
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
