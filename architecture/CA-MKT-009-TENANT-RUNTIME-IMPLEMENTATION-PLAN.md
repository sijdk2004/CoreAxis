# CA-MKT-009 — TENANT RUNTIME FOUNDATION IMPLEMENTATION PLAN

## 1. Executive Summary
This document outlines the detailed implementation plan for the Tenant Runtime Foundation (CA-MKT-009) in CoreAxis ERP. The runtime acts as the secure, composition boundary where users interact with their active Customer Solutions. Following the Strangler Pattern, this plan introduces a new generic `RuntimeShell` and dynamic routing enforcement, adapting the legacy monolithic `app_router.dart` and `AppShell` without rewriting existing legacy business modules.

## 2. Architecture Baseline
This implementation plan strictly adheres to:
- `A-000_COREAXIS_META_ARCHITECTURE.md`
- `A-008_CUSTOMER_PROVISIONING_ARCHITECTURE.md`
- `CA-MKT-009-TENANT-RUNTIME-DISCOVERY.md`
- M1-M8 milestone definitions remain completely frozen and are consumed as immutable baselines.

## 3. Existing Code Findings
- **Legacy Shell (`AppShell`)**: Tightly coupled to "FurniFlow" industry assumptions and hardcoded static menus.
- **Platform Shell (`PlatformShell`)**: Platform administration oriented, not suitable for customer runtime.
- **Routing (`app_router.dart`)**: Over 900 lines of hardcoded static routes linking to legacy business module screens.
- **Business Modules (e.g. Sales, Customers)**: Provide screens and providers, but do not emit explicit runtime capability descriptors or metadata.
- **RBAC (`rbac_provider.dart`)**: A functional capability providing role-based permission evaluation via `hasPermission(String requiredPermission)`.

## 4. Runtime Context Design
`RuntimeContext` is the core execution boundary.
- **Nature**: It holds a *Deep Immutable Snapshot* of the selected `CustomerSolution` at runtime initialization. It does not retain a mutable reference to the underlying repository.
- **Fields Preserved**:
  - `tenantId`
  - `id` (CustomerSolutionId)
  - `exactSolutionDefinitionVersion`
  - `moduleConfigurations`
  - `lifecycleState`
  - Computed runtime configuration snapshot
- **Boundary**: `RuntimeContext` is NOT a second RBAC engine. It only dictates Module Enablement, which is entirely separate from User Authorization.

## 5. Runtime Module Descriptor
To connect legacy Business Modules to the generic Tenant Runtime without rewriting them, we introduce the `ModuleRuntimeDescriptor`.
- **Definition**: Runtime integration/compatibility metadata used by the Strangler migration.
- **Purpose**: Maps generic module codes to static legacy routes and navigation hierarchy.
- **Fields**:
  - `moduleCode`: Matches Marketplace/Blueprint definitions.
  - `displayName`: Rendered in navigation.
  - `requiredPermission`: The actual permission code expected by the existing RBAC system (e.g. `SALES_VIEW`), allowing the Strangler pattern to map module navigation to existing RBAC definitions.
  - `routes`: Base routes claimed by the module.
  - `iconName`: For UI menus.
- **Not**: It is NOT a Business Module definition, MarketplaceModule, dependency definition, lifecycle definition, licensing definition, RBAC definition, or permanent replacement for module metadata.

## 6. Descriptor Registry
Since existing modules cannot provide these descriptors natively, we will use **Option C: Adapter registry specifically for legacy modules**.
- **Implementation**: A static `LegacyModuleRuntimeRegistry` acting as a lookup mechanism containing complete `ModuleRuntimeDescriptor` objects (not merely a `moduleCode -> route` mapping).
- **Clarification**:
  - `MarketplaceModule` = module identity/version/publication/dependency authority
  - `Business Module` = business functionality
  - `ModuleRuntimeDescriptor` = runtime integration metadata
  - `LegacyModuleRuntimeRegistry` = temporary Strangler compatibility registry
  - `Tenant Runtime` = runtime composition/consumption
- **Constraint**: This registry must NOT become a second Business Module registry, a second Marketplace registry, a dependency registry, an RBAC registry, or a licensing registry. It is purely runtime integration/compatibility infrastructure.

## 7. Runtime Providers
Before creating new context providers, we will inspect existing authoritative context providers in Platform Core (such as `tenantProvider`, `organizationProvider`, `authProvider`). If they exist and are authoritative, Runtime will adapt/consume them rather than creating duplicate authoritative state (`Existing Platform Core context -> Runtime adapter/consumer`).
The following runtime-specific derived state providers are proposed where Runtime genuinely needs a distinct state boundary:
- `runtimeContextProvider`: (Session scope) Holds the immutable `RuntimeContext` snapshot.
- `enabledRuntimeModulesProvider`: Derived from `runtimeContextProvider` and `LegacyModuleRuntimeRegistry`.
- `runtimeNavigationProvider`: Derived from enabled modules and `rbacProvider` to build the sidebar.
- `effectiveConfigurationProvider`: Derived from the snapshot inside `RuntimeContext`.

## 8. Runtime Initialization
Mock frontend-only initialization flow:
1. **Mock Login**: Simulates user authentication.
2. **Resolve Tenant / Organization / User** (via existing authoritative providers).
3. **Resolve ACTIVE CustomerSolution**: From `customerSolutionRepositoryProvider`.
4. **Deep Snapshot**: Freezes the solution data.
5. **RuntimeContext**: Created and placed in `runtimeContextProvider`.
6. **RuntimeShell**: Pushed via GoRouter, automatically composing the UI.

## 9. Multiple CustomerSolutions
- **Architecture**: A single Tenant may own multiple active `CustomerSolution`s.
- **Execution**: The runtime context executes exactly *one* CustomerSolution at a time.
- **Implementation**: The mock login entry point will explicitly inject a specific `CustomerSolution` ID to initialize the runtime. Switching solutions is architecturally supported but out of scope for the MVP UI.

## 10. Organization Context
- **Scope**: The runtime operates under one primary Organization.
- **Isolation**: Mocks will validate that the chosen Organization strictly belongs to the current Tenant. Organization switching is out of scope for CA-MKT-009.

## 11. Module Enablement
- **Source**: Derived strictly from `CustomerSolution.moduleConfigurations`.
- **Mapping**: `CustomerSolution` -> `moduleCode` -> matches `LegacyModuleRuntimeRegistry` -> `ModuleRuntimeDescriptor`.
- **Rule**: M2 Marketplace remains the sole dependency authority. Runtime must not revalidate or recreate the dependency engine. Runtime consumes the already-provisioned/validated module composition.

## 12. Navigation Composition
- **Flow**: `CustomerSolution module enabled` -> `runtime descriptor exists / module is runtime-available` -> `existing RBAC authorization passes` -> `navigation entry is visible`.
- **Implementation**: A navigation builder evaluates each enabled descriptor. It retrieves the descriptor's mapped `requiredPermission` and passes it directly to the existing `RbacProvider.hasPermission()`. If authorized, the entry is added to the sidebar.

## 13. RBAC Integration
- **Rule**: Consume existing Platform Core RBAC authority (`RbacProvider`). Use the actual existing API exactly as implemented.
- **Constraint**: Do NOT assume a BusinessCapability code is a permission code. Do not invent `hasPermission(descriptor.capabilityCode)`. Use the explicit authorization mapping metadata in the `ModuleRuntimeDescriptor` to bridge the legacy gap.
- **Constraint**: Do NOT create a RuntimeRBAC, RuntimePermissionEngine, new permission identifiers, or a second authorization mapping system.
- **Evaluation Chain**: `Module Enabled` + `Module Runtime Feature Available` + `Existing Platform Core RBAC Authorization` = `Effective Runtime Access`.

## 14. Routing Integration
- **Architecture**: Static routes + runtime guards (Option A).
- **Implementation**: We will introduce `RuntimeContextGuard` as a GoRouter `redirect`.
- **Behavior**: 
  - The guard resolves the requested route to its owning module deterministically (using normalized route templates or exact route patterns, avoiding unsafe loose prefix matching).
  - Flow: `Requested Route` -> `Runtime Route/Descriptor Lookup` -> `Owning ModuleRuntimeDescriptor` -> `Module Enabled?` -> `Module Available?` -> `User Authorized?` -> `Allow / Deny`.
  - If unauthorized, it redirects to a generic error route. We will not modify the 900+ lines of static legacy routes.

## 15. Legacy Route Adapters
- **Infrastructure**: `LegacyModuleRuntimeRegistry` maps `moduleCode` to a full `ModuleRuntimeDescriptor`.
- **Nature**: Strangler compatibility infrastructure to avoid rewriting legacy screens. Future native modules would supply descriptors directly.

## 16. Configuration Resolution
- **Chain**: The historical ownership chain is Marketplace defaults -> Blueprint defaults -> Business Solution configuration -> Customer Provisioning defaults -> Customer-specific configuration -> effective CustomerSolution runtime configuration.
- **Implementation**: Provisioning produces the effective configuration snapshot consumed by Runtime. `CustomerSolution` -> `Effective Customer Configuration Snapshot` -> `Runtime`.
- **Constraint**: Runtime must consume the effective snapshot. Do not reconstruct the historical configuration chain at runtime. Runtime owns consumption/resolution only where necessary for runtime access; it does not recreate the upstream ownership chain or mutate the source snapshot.

## 17. RuntimeShell
- **Implementation**: A new generic widget `RuntimeShell`.
- **Features**: dynamic tenant/solution branding, dynamic navigation sidebar, breadcrumbs, user context.
- **Strategy**: Provides the UX frame for Customer Business Application routes.

## 18. Dashboard
- **Scope**: Keep the dashboard lightweight and mock-only.
- **Constraint**: No generalized dashboard framework, no new analytics engine, no generalized widget platform.
- **Mechanics**: Checks `enabledRuntimeModulesProvider` and renders a simple mock section per authorized module.

## 19. Runtime States
- `ACTIVE`: Normal operation.
- `SUSPENDED`: Intercepted by guard, routes to a full-screen "Solution Suspended" notice.
- `NO_ACTIVE_SOLUTION`: Displayed after login if no valid solution is resolved.
- `UNAUTHORIZED` / `MODULE_UNAVAILABLE`: Redirects from guard to an "Access Denied" view.

## 20. Tenant Isolation
- **Frontend Phase**: Logical tenant-scoped runtime context and state isolation. Provide explicit tenant context propagation and no cross-tenant state leakage in UI. We do not describe frontend tenant isolation as a security boundary.
- **Future Backend Phase**: Authoritative security/isolation boundary.

## 21. Strangler Strategy
- `AppShell`: ISOLATE (Legacy wrapper, to be bypassed for Tenants).
- `PlatformShell`: SAFE TO REUSE (For platform admins).
- `app_router.dart`: ADAPT (Separate the tree into `PlatformShell` vs `RuntimeShell`).
- `Business Modules`: SAFE TO REUSE (Mounted via Legacy Adapters).

## 22. Exact File Matrix
**NEW FILES (runtime-specific only):**
- `lib/features/runtime/domain/models/runtime_context.dart`: Holds the immutable snapshot.
- `lib/features/runtime/domain/models/module_runtime_descriptor.dart`: The adapter contract.
- `lib/features/runtime/data/legacy_module_registry.dart`: The static Strangler mapping.
- `lib/features/runtime/application/runtime_providers.dart`: Riverpod providers.
- `lib/features/runtime/routing/runtime_guard.dart`: The GoRouter redirect logic.
- `lib/features/runtime/presentation/runtime_shell.dart`: The dynamic generic shell.
- `lib/features/runtime/presentation/runtime_dashboard_screen.dart`: The lightweight mock dashboard.
- `lib/features/runtime/presentation/runtime_state_screen.dart`: For Suspended/Unauthorized states.

**MODIFIED FILES:**
- `lib/core/routing/app_router.dart`: 
  - *Reason*: To separate Platform Administration routes from Customer Business Runtime routes.
  - *Change*: We will classify the router tree into:
    - Platform Administration routes -> `PlatformShell`
    - Customer/Tenant Runtime routes -> `RuntimeShell`
    - Shared/public routes -> outside both.
  - *Action*: We will specify the smallest possible router adaptation. We will NOT blindly replace a global ShellRoute, NOT rewrite the 900+ line router, NOT globally replace `PlatformShell`, and NOT disturb Platform Administration routing. We will merely ensure the Customer/Tenant routes are placed under the new `RuntimeShell` and its `RuntimeContextGuard`.

## 23. Implementation Sequence
1. Domain: `runtime_context.dart`, `module_runtime_descriptor.dart`.
2. Data: `legacy_module_registry.dart` (adapter descriptors).
3. Application: `runtime_providers.dart` (context, configuration resolver, navigation composition).
4. Presentation: `runtime_shell.dart`, `runtime_state_screen.dart`, `runtime_dashboard_screen.dart`.
5. Routing: `runtime_guard.dart`.
6. Integration: Wire into `app_router.dart` precisely.
7. Mock Initialization: Setup fake login resolving to an active CustomerSolution.
8. Testing and Validation.

## 24. Test Matrix
- **Runtime Context**: Unit tests verifying deep immutable snapshots and proper tenant/solution scoping.
- **Module Composition**: Unit tests verifying that enabled modules merge correctly with `legacy_module_registry`.
- **Configuration**: Unit tests validating effective configuration snapshot availability.
- **Navigation/Routing**: Unit tests for the `RuntimeGuard` (disabled modules rejected, RBAC unauthorized rejected).
- **Tenant Isolation**: Verify `runtimeContextProvider` matches Tenant/Org IDs logically.
- **Regression**: Execute existing M1-M8 test suites.

## 25. Manual Verification
- **Scenario A (Active)**: Mock login -> resolves CustomerSolution -> `RuntimeShell` mounts -> Sidebar displays only enabled, available, and user-authorized modules -> Clicking a module routes correctly.
- **Scenario B (Suspended)**: Mutate mock CustomerSolution to `SUSPENDED` -> verify login traps user in suspended state screen.
- **Scenario C (RBAC)**: Mutate `RbacProvider` to drop a required permission -> verify the mapped module disappears from sidebar and direct navigation redirects to Unauthorized.

## 26. Risk Register
- **app_router coupling**: High likelihood, low impact. Careful tree classification isolates the risk.
- **Mutable snapshots**: Medium likelihood, high impact. Handled by strictly defining deep-copy methods in `RuntimeContext`.
- **Accidental M1-M8 Modification**: Low likelihood. Strict code-review rule to ignore all legacy business logic.

## 27. Scope / Out of Scope
- **In Scope**: Minimal usable Tenant Runtime Foundation (Frontend/Mock), RuntimeShell, context snapshots, routing guards.
- **Out of Scope**: Backend, Database, real Authentication, real Licensing, Organization/Solution switching UI, rewriting legacy modules, rewriting AppShell.

## 28. M1–M8 Protection
- No M1-M8 architecture or domain files will be modified. No behavioral/domain changes.
- M2 Marketplace dependency models remain untouched. 

## 29. Final Acceptance Criteria
- [ ] Descriptor registry contains complete descriptors: PASS requirement
- [ ] Route -> module resolution is deterministic: PASS requirement
- [ ] RBAC uses existing Platform Core authorization API: PASS requirement
- [ ] Runtime contains no licensing logic: PASS requirement
- [ ] PlatformShell routes remain PlatformShell: PASS requirement
- [ ] Runtime routes are explicitly separated: PASS requirement
- [ ] Runtime consumes CustomerSolution configuration snapshot: PASS requirement
- [ ] Existing authoritative context providers are reused: PASS requirement
- [ ] Runtime boundary is explicit (Deep Immutable Snapshot).
- [ ] Tenant isolation boundary is explicitly logical frontend-only.
- [ ] M2 remains dependency authority.
- [ ] M1-M8 code and documentation remains fully protected.
- [ ] A-000 and A-008 remain fully protected.
