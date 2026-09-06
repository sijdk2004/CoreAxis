import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/runtime_providers.dart';
import '../../auth/presentation/auth_provider.dart';

class RuntimeShell extends ConsumerStatefulWidget {
  final Widget child;

  const RuntimeShell({Key? key, required this.child}) : super(key: key);

  @override
  ConsumerState<RuntimeShell> createState() => _RuntimeShellState();
}

class _RuntimeShellState extends ConsumerState<RuntimeShell> {
  bool _isSidebarExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navAsync = ref.watch(runtimeNavigationProvider);
    final contextAsync = ref.watch(runtimeContextProvider);

    return Scaffold(
      appBar: AppBar(
        title: contextAsync.when(
          data: (ctx) => Text(ctx != null 
              ? 'Tenant ${ctx.tenantId} - Workspace' 
              : 'CoreAxis Workspace'),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('CoreAxis Workspace'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _isSidebarExpanded ? 250 : 70,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
            ),
            child: Column(
              children: [
                // Toggle Button
                Align(
                  alignment: _isSidebarExpanded ? Alignment.centerRight : Alignment.center,
                  child: IconButton(
                    icon: Icon(_isSidebarExpanded ? Icons.chevron_left : Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        _isSidebarExpanded = !_isSidebarExpanded;
                      });
                    },
                  ),
                ),
                const Divider(),
                // Navigation Items
                Expanded(
                  child: navAsync.when(
                    data: (modules) {
                      if (modules.isEmpty) {
                        return const Center(child: Text('No modules available'));
                      }
                      return ListView.builder(
                        itemCount: modules.length,
                        itemBuilder: (context, index) {
                          final module = modules[index];
                          // Determine if this item is selected based on route
                          final isSelected = module.ownsRoute(GoRouterState.of(context).matchedLocation);
                          
                          return ListTile(
                            leading: Icon(module.icon, color: isSelected ? theme.colorScheme.primary : null),
                            title: _isSidebarExpanded 
                                ? Text(
                                    module.displayName,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? theme.colorScheme.primary : null,
                                    )
                                  ) 
                                : null,
                            selected: isSelected,
                            onTap: () {
                              context.go(module.primaryRoute);
                            },
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),
                ),
              ],
            ),
          ),
          
          // Main Content Area
          Expanded(
            child: Container(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
