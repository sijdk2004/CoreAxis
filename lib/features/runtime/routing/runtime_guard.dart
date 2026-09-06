import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/runtime_providers.dart';
import '../../customer_solution/domain/models/customer_solution_lifecycle.dart';
import '../data/legacy_module_registry.dart';
import '../../auth/presentation/auth_provider.dart';

/// Evaluates route requests against the Tenant Runtime boundary.
/// Ensures that business module routes are only accessible if the CustomerSolution
/// is active, the module is enabled, and the user has RBAC permissions.
String? runtimeGuard(BuildContext context, GoRouterState state, WidgetRef ref) {
  // If we are not authenticated, let the main router redirect handle it
  final authState = ref.read(authProvider);
  if (authState.status != AuthStateStatus.authenticated) return null;

  // We only guard business runtime routes, not platform administration routes
  // The classification is handled by the ShellRoute hierarchy in app_router.dart,
  // but just in case this guard is attached broadly, we only inspect known module routes.
  final requestedPath = state.matchedLocation;
  
  // Quick check if this path even belongs to a legacy business module
  bool isBusinessModuleRoute = false;
  for (final descriptor in LegacyModuleRegistry.allDescriptors) {
    if (descriptor.ownsRoute(requestedPath)) {
      isBusinessModuleRoute = true;
      break;
    }
  }

  // If it's not a business module route, let it pass (e.g. platform routes)
  if (!isBusinessModuleRoute) return null;

  final runtimeContextAsync = ref.read(runtimeContextProvider);

  return runtimeContextAsync.when(
    data: (runtimeContext) {
      // STATE 1: NO ACTIVE SOLUTION
      if (runtimeContext == null) {
        return '/runtime/no-solution';
      }

      // STATE 2: SUSPENDED
      if (runtimeContext.lifecycleState == CustomerSolutionLifecycle.suspended) {
        return '/runtime/suspended';
      }

      // If solution is not active or provisioning, it shouldn't be accessible
      if (runtimeContext.lifecycleState != CustomerSolutionLifecycle.active && 
          runtimeContext.lifecycleState != CustomerSolutionLifecycle.provisioning) {
        return '/runtime/suspended';
      }

      // STATE 3: RBAC & ENABLEMENT CHECK
      final isAuthorized = ref.read(routeAuthorizationProvider(requestedPath));
      return isAuthorized.when(
        data: (authorized) {
          if (!authorized) {
            // STATE 4: UNAUTHORIZED or MODULE_UNAVAILABLE
            return '/runtime/unauthorized';
          }
          // STATE 5: ACTIVE - allow the route
          return null; 
        },
        loading: () => null, // Wait for resolution
        error: (_, __) => '/runtime/error',
      );
    },
    loading: () => null, // Let the router wait while loading context
    error: (err, stack) => '/runtime/error',
  );
}
