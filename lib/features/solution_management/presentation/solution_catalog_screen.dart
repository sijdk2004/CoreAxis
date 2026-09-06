import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:coreaxis/features/solution_management/application/solution_management_providers.dart';
import 'package:coreaxis/features/solution_management/domain/models/solution_definition.dart';

class SolutionCatalogScreen extends ConsumerStatefulWidget {
  const SolutionCatalogScreen({super.key});

  @override
  ConsumerState<SolutionCatalogScreen> createState() => _SolutionCatalogScreenState();
}

class _SolutionCatalogScreenState extends ConsumerState<SolutionCatalogScreen> {
  String _searchQuery = '';
  SolutionDefinitionState? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final solutionsAsync = ref.watch(solutionDefinitionListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solution Catalog'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search (Name, Code, Description)',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: DropdownButton<SolutionDefinitionState?>(
                    isExpanded: true,
                    value: _statusFilter,
                    hint: const Text('Filter by Status'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All States')),
                      ...SolutionDefinitionState.values.map(
                        (state) => DropdownMenuItem(
                          value: state,
                          child: Text(state.name),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _statusFilter = val;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: solutionsAsync.when(
              data: (solutions) {
                final filtered = solutions.where((s) {
                  final matchesSearch = s.name.toLowerCase().contains(_searchQuery) ||
                      s.description.toLowerCase().contains(_searchQuery) ||
                      s.id.toLowerCase().contains(_searchQuery);
                  final matchesStatus = _statusFilter == null || s.state == _statusFilter;
                  return matchesSearch && matchesStatus;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No Solutions Found.'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final definition = filtered[index];
                    return ListTile(
                      title: Text(definition.name),
                      subtitle: Text('Status: ${definition.state.name}\n${definition.description}'),
                      isThreeLine: true,
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        context.go('/solutions/${definition.id}');
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
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
