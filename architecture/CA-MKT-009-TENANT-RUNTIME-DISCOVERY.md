# CA-MKT-009 — Tenant Runtime Discovery & Architecture Plan

## 1. Executive Summary
This document defines the architecture discovery and implementation plan for the Tenant Runtime Foundation (CA-MKT-009). The Tenant Runtime represents the secure execution environment where users interact with their provisioned Customer Solutions. The primary goal of this phase is to establish the composition boundary and routing mechanism that dynamically adapts to a given `CustomerSolution` without rewriting legacy module implementations. We will utilize the Strangler Pattern to bypass the legacy `AppShell` and introduce a flexible `RuntimeShell`.

## 2. Shell Analysis
### Legacy AppShell
- **Analysis:** `AppShell` (`lib/features/shell/presentation/app_shell.dart`) is heavily hardcoded with specific industry assumptions (e.g., "FurniFlow"). It relies on a `MenuProvider` that hardcodes legacy routing groups (`Dashboards`, `Sales`, `Manufacturing`).
- **Verdict:** It is a rigid legacy shell. It must be bypassed for generic runtime usage.
### PlatformShell
- **Analysis:** `PlatformShell` (`lib/features/platform_shell/presentation/platform_shell.dart`) contains a static `_menuHierarchy` dedicated to Platform Administration (Tenants, Organizations, Business Modules, etc.).
- **Verdict:** It is exclusively for Platform Core administration. It cannot be used for Customer Runtime execution.

## 3. Router Analysis
- **Structure:** `app_router.dart` is a monolithic `GoRouter` configuration (>900 lines).
- **Coupling:** It maps specific URL paths directly to legacy Flutter screens (`/customers` -> `CustomersScreen`).
- **Verdict:** The monolithic router will be retained as an immutable baseline. Runtime behavior will be injected via a route guard rather than a dynamic router generation strategy.

## 4. Existing Platform Runtime Capabilities
Currently, Platform Administration features are well-defined within `PlatformShell` and explicitly guarded by the Platform Administration RBAC rules (`PLATFORM_ADMIN`).

## 5. Existing CustomerSolution Capabilities
The `CustomerSolution` model encapsulates the runtime boundary definition.
- **Fields:** `id`, `tenantId`, `sourceSolutionDefinitionId`, `exactSolutionDefinitionVersion`, `moduleConfigurations`, `lifecycleState`.
- **Role:** It dictates exactly which modules are active and holds the effective configuration. It does NOT hold organization or user details directly.

## 6. Existing Business Module Analysis
- **Modules Examined:** `Customers`, `Quotations`, `SalesOrders`.
- **Finding:** Legacy business modules do not expose explicit "module descriptors". They are purely Flutter screen widgets wired to Riverpod providers calling backend endpoints (e.g., `/v1/system/customers`).
- **Navigation:** Navigation metadata is currently implicitly hardcoded in `MenuProvider` rather than being provided by the module itself.

## 7. Tenant Context
- The Tenant Context is the highest isolation boundary.
- A user belongs to a specific Tenant. The Tenant ID is globally available in `RuntimeContext` and must strictly isolate all data requests and access.

## 8. Organization Context
- `Organization` (`lib/features/platform/domain/models/organization.dart`) includes `tenantId`.
- **Resolution:** A Tenant may have multiple Organizations. 
- **Scope:** Runtime operations typically occur within a specific Organization context. Organization switching is out of scope for the MVP unless explicitly required by existing legacy modules. The runtime context will lock onto a single primary Organization.

## 9. User Context
- User identity and profile information.
- Provides the inputs for RBAC (Role-Based Access Control) but does not store the CustomerSolution itself.

## 10. Multiple CustomerSolutions
- **Architecture:** `Tenant` -> `CustomerSolution A`, `CustomerSolution B`.
- **Support:** A Tenant may own multiple active CustomerSolutions.
- **Runtime Rules:** The runtime executes exactly **one** `CustomerSolution` at a time. The entry point must select the active solution before proceeding to the runtime shell.

## 11. Runtime Context Model
**Rule:** `RuntimeContext` is NOT a second RBAC engine.
- **Consumption:** It consumes the `CustomerSolution` (specifically `moduleConfigurations`).
- **Distinction:** Module Enablement (from CustomerSolution) ≠ User Authorized (from RBAC).
- **Snapshotting:** `CustomerSolution Repository` -> `Deep Immutable Snapshot` -> `RuntimeContext`. `RuntimeContext` must capture a deep immutable snapshot of the selected CustomerSolution at runtime initialization. It must NOT retain a mutable repository-owned reference that could observe later mutations. It preserves: `tenantId`, `id` (CustomerSolutionId), `exactSolutionDefinitionVersion`, `moduleConfigurations`, `lifecycleState` (lifecycle-relevant runtime information), and required runtime configuration snapshot.

## 12. Module Runtime Model
- **Challenge:** Existing modules do not provide explicit descriptors.
- **Solution:** A minimal reusable runtime contract (adapter) is needed. The `ModuleRuntimeDescriptor` is defined as: "Runtime integration/compatibility metadata for connecting existing Business Modules to Tenant Runtime."
- **Clarification:** It is NOT the authoritative Business Module definition, MarketplaceModule definition, a dependency authority, a lifecycle authority, or a second module registry.
- **Separation:**
  - `MarketplaceModule` = module identity/version/publication/dependency authority
  - `Business Module` = business functionality
  - `ModuleRuntimeDescriptor` = runtime integration metadata
  - `Tenant Runtime` = runtime composition and consumption
- The descriptor exists primarily because legacy modules do not yet expose a unified runtime contract. It is part of the Strangler Pattern.

## 13. Navigation Composition
- **Strangler Pattern Adapter:** Instead of hardcoding capability-to-route maps, we will use a `ModuleRuntimeDescriptor`.
- **Flow:** `CustomerSolution` -> `Enabled Module` -> `Module Runtime Descriptor` -> `Navigation Metadata` -> `RBAC Filtering` -> `Runtime UI`.
- **Nature:** This is clearly identified as Strangler Pattern compatibility infrastructure.

## 14. Routing
- **Architecture Selected:** Option A (Static routes with runtime guards).
- **Reasoning:** Since `app_router.dart` already contains the static routes, we will keep them but apply a `RuntimeContextGuard`.
- **Evaluation Chain:** 
  1. Requested Route
  2. Map to Runtime Feature / Module
  3. Is module enabled for CustomerSolution? (Check `RuntimeContext`)
  4. Is module/runtime feature available? 
  5. Is current user authorized? (Check `RbacProvider`)
  6. Allow / Deny

## 15. RBAC Integration
- **Mechanism:** Runtime must consume existing Platform Core RBAC (`RbacProvider`).
- **Equation:** `CustomerSolution enabled module + Current user's permissions = Effective Runtime Access`.
- Do not create a separate Runtime RBAC engine.

## 16. Configuration Resolution
- **Resolution Chain:** Marketplace defaults -> Blueprint defaults -> Business Solution configuration -> Customer Provisioning defaults -> Customer-specific configuration -> Runtime effective configuration.
- **Implementation:** `CustomerSolution.moduleConfigurations` contains `blueprintConfiguration` (defaults) and `configuration` (customer overrides).
- **Runtime action:** A configuration provider will deep-merge these maps to produce the effective configuration for any given module.

## 17. Runtime States
- **ACTIVE:** Normal runtime.
- **SUSPENDED:** User sees a "Solution Suspended" informational screen. No business operations allowed.
- **NO ACTIVE SOLUTION:** User sees a prompt indicating no solutions are available for this tenant.
- **INVALID CONFIGURATION:** Fallback error boundary screen.
- **MODULE UNAVAILABLE:** Route guard redirects to a standard "Capability Not Provisioned" view.

## 18. RuntimeShell
- **Scope:** Customer Business Application boundary.
- **Contents:** Dynamic branding, solution name, navigation (filtered by RBAC and Module Descriptor), user context, responsive layout.
- **Exclusion:** Does not duplicate Platform Administration tools.

## 19. Dashboard Composition
- **Approach:** Capability-driven dashboard restricted to a lightweight mock composition.
- **Mechanics:** `Enabled + Authorized Module` -> `Eligible Mock Dashboard Section`.
- **Constraint:** Do NOT introduce a generalized dashboard-widget platform. A generalized dashboard composition framework may be considered in a later milestone.

## 20. Riverpod Architecture
- **Tenant Scope:** `currentTenantProvider`
- **Organization Scope:** `currentOrganizationProvider`
- **Session Scope:** `runtimeContextProvider` (holds `CustomerSolution`)
- **Derived Providers:** `enabledModulesProvider`, `effectiveConfigurationProvider`.

## 21. Tenant Isolation
- **Flow:** `Tenant Context` -> `Tenant-scoped Runtime State` -> `Tenant-aware Data Boundary` -> `Future Backend Tenant Isolation`.
- **Current frontend/mock phase:** Runtime must provide tenant-scoped runtime state, tenant-scoped mock repositories/services, explicit tenant context propagation, no cross-tenant state leakage, and tenant-aware data boundaries.
- **Future backend:** The backend must enforce the actual security/isolation boundary. We do not claim frontend-only runtime state is the ultimate security boundary.

## 22. Legacy Strangler Strategy
- **AppShell:** ISOLATE (Bypass for tenant runtime).
- **PlatformShell:** SAFE TO REUSE (For platform admins).
- **Business Modules (Screens):** ADAPT (Mount inside RuntimeShell using static routes + runtime guard).

## 23. Ownership Matrix

| Concept                   | Owner                   |
| ------------------------- | ----------------------- |
| Tenant                    | Tenant Management       |
| Organization              | Organization Management |
| User                      | User Management         |
| RBAC                      | Platform Core           |
| MarketplaceModule         | Marketplace             |
| Module Dependencies       | Marketplace / M2        |
| Business Capability       | Business Capability     |
| Business Module           | Business Module         |
| SolutionDefinition        | Solution Management     |
| CustomerSolution          | Customer Solution       |
| Provisioning              | Customer Provisioning   |
| Runtime Context           | Runtime Foundation      |
| Runtime Shell             | Runtime Foundation      |
| Runtime Navigation        | Runtime Foundation      |
| Runtime Routing           | Runtime Foundation      |
| Effective Configuration   | Runtime Foundation      |
| Runtime Module Descriptor | Runtime Foundation (Strangler) |
| Dashboard Composition     | Runtime Foundation      |

## 24. Dependency Direction
- **Rule:** Runtime may consume approved Platform Core capabilities and contracts, including Tenant, Organization, User, RBAC and other approved runtime services, but must not depend directly on Platform Core implementation internals.
- **Intended Direction:** `Tenant Runtime` -> `Approved Platform Core Contracts / Services`
- **NOT:** `Tenant Runtime` -> `Platform Core Concrete Implementation Internals`
- This preserves the A-000/A-008 dependency principles.

## 25. Architecture Gaps
- Legacy business modules lack a unified descriptor. A Strangler adapter (`ModuleRuntimeDescriptor`) is required to map module codes to static legacy routes.

## 26. Architecture Decisions Required
- How the initial user login securely determines the active `CustomerSolution` without backend support (to be handled via mock initialization).

## 27. Proposed CA-MKT-009 Scope
- `RuntimeContext` Providers
- `RuntimeShell` and dynamic navigation composition
- `RuntimeContextGuard` and Static Route mapping integration
- Configuration resolver
- Capability-driven Dashboard mock
- Ensure isolation and states (ACTIVE, SUSPENDED, UNAVAILABLE).

## 28. Proposed Follow-up Milestones
- Organization Switching support
- Deep UX customization (branding application)
- Backend implementation

## 29. Proposed Future File Structure
- `lib/features/runtime/domain/runtime_context.dart`
- `lib/features/runtime/presentation/runtime_shell.dart`
- `lib/features/runtime/routing/runtime_guard.dart`

## 30. Test Strategy
- Unit test Configuration deep-merge logic.
- Unit test Route Guard evaluation chain.
- Widget test `RuntimeShell` rendering specific enabled modules based on mock `CustomerSolution`.

## 31. M1–M8 Freeze Protection
- All `M1-M8` documents and code remain immutable.
- We will not alter existing legacy screens.
