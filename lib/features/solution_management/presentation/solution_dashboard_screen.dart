import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:coreaxis/features/solution_management/application/solution_management_providers.dart';
import 'package:coreaxis/features/solution_management/domain/models/solution_definition.dart';

class SolutionDashboardScreen extends ConsumerWidget {
  const SolutionDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final solutionsAsync = ref.watch(solutionDefinitionListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solution Management Dashboard'),
      ),
      body: solutionsAsync.when(
        data: (solutions) {
          final total = solutions.length;
          final drafts = solutions.where((s) => s.state == SolutionDefinitionState.draft).length;
          final inProgress = solutions.where((s) => s.state != SolutionDefinitionState.draft && s.state != SolutionDefinitionState.published && s.state != SolutionDefinitionState.archived).length;
          final published = solutions.where((s) => s.state == SolutionDefinitionState.published).length;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Overview', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _KpiCard(title: 'Total Solutions', value: total.toString())),
                    const SizedBox(width: 16),
                    Expanded(child: _KpiCard(title: 'Draft', value: drafts.toString())),
                    const SizedBox(width: 16),
                    Expanded(child: _KpiCard(title: 'In Progress', value: inProgress.toString())),
                    const SizedBox(width: 16),
                    Expanded(child: _KpiCard(title: 'Published', value: published.toString())),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    context.go('/solutions/list');
                  },
                  icon: const Icon(Icons.list),
                  label: const Text('View Solution Catalog'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/blueprints');
        },
        label: const Text('New Solution from Blueprint'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;

  const _KpiCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}
