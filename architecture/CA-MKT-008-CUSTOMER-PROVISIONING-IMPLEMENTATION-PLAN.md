# CA-MKT-008 — Customer Provisioning Implementation Plan

## 1. Document Control
* **Milestone:** CA-MKT-008 (Customer Provisioning Foundation)
* **Purpose:** Translate the frozen A-008 SSOT into an implementation-ready frontend and mock-data plan.
* **Source SSOT:** `architecture/A-008_CUSTOMER_PROVISIONING_ARCHITECTURE.md`
* **Implementation Status:** NOT STARTED
* **Planning Status:** READY FOR CHATGPT REVIEW

---

## 2. Scope
**Included:**
* Mocking a complete Customer Provisioning orchestration flow (UI + Mock Data).
* Support for New-Tenant and Existing-Tenant provisioning modes.
* Implementation of the Provisioning Orchestration Contract / Boundary.
* Simulated generation of Tenant, Organization, Administrator, and CustomerSolution records through abstract boundaries.
* Provisioning state management, including failure, retry, idempotency, and compensation scenarios.
* Idempotency via `provisioningRequestId`.
* Tenant isolation enforcement in the mock data layer.

**Excluded:**
* Real backend APIs or database persistence.
* Modifying existing frozen milestones (CA-MKT-001 through CA-MKT-007).
* Runtime shell / session establishment (beyond marking a solution as ACTIVE).
* Billing, payment, and detailed commercial licensing engines.
* Real infrastructure or Kubernetes deployment code.
* Runtime configuration management.

---

## 3. Architecture Compliance
* **A-000 Compliance:** Strict adherence to dependency direction. Platform Core (Provisioning) will not directly depend on concrete higher-layer implementations.
* **A-008 Compliance:** Provisioning acts as an orchestrator, utilizing the defined boundaries.
* **M1-M7 Protection:** Frozen M1-M7 business/domain implementations must remain unchanged. No behavioral modification to M1-M7. No lifecycle changes. No model ownership changes. No dependency-engine duplication. No new business logic inside frozen milestones. If dependency registration is technically necessary, the existing composition root (e.g. `lib/core/providers.dart` or `lib/main.dart` if applicable) may be minimally extended.

---

## 4. Existing Implementation Discovery

* **Tenant:** 
  - `Tenant` model in `lib/features/platform/domain/models/tenant.dart`.
  - `MockTenantRepository` in `lib/features/platform/data/mock_tenant_repository.dart` handles tenant persistence.
  - Generates IDs internally; lacks deterministic idempotency creation currently.
* **Organization:** 
  - `Organization` model in `lib/features/platform/domain/models/organization.dart`.
  - Currently mocked dynamically within `OrganizationListNotifier`.
* **User Management:** 
  - `MockPlatformUserRepository` exists in `lib/features/platform/data/mock_platform_user_repository.dart`.
* **RBAC:** 
  - No concrete RBAC simulation exists currently; will mock implicitly via user roles in user management.
* **Licensing:** 
  - No concrete licensing engine exists; will create a minimal boundary adapter simulating entitlement.
* **Marketplace / M2:** 
  - `MockMarketplaceRepository` in `lib/features/marketplace/mock/mock_marketplace_repository.dart`. Contains module metadata and dependency relationships.
* **Solution Management:** 
  - `SolutionDefinition` model in `lib/features/solution_management/domain/models/solution_definition.dart`.
  - `MockSolutionDefinitionRepository` handles published solutions.
* **CustomerSolution:** 
  - `MockCustomerSolutionRepository` exists with `createSolution`, `updateLifecycle`, and `getSolutionsForTenant` methods.

---

## 5. Ownership Map
* **Platform Core / Provisioning:** Owns orchestration requests and process state.
* **Tenant Management:** Owns `Tenant` data/lifecycle.
* **Organization Management:** Owns `Organization` data/lifecycle.
* **Solution Management:** Owns `SolutionDefinition`.
* **Marketplace:** Owns `MarketplaceModule` and dependencies (M2 remains sole authority).
* **Customer Solution:** Owns `CustomerSolution` model and lifecycle (M7).
* **User Management:** Owns initial `Administrator` records.
* **RBAC:** Owns roles/permissions.
* **Licensing:** Owns entitlement checks.

---

## 6. Dependency Boundary Implementation Plan
To prevent Platform Core from depending on the concrete higher-layer domain logic, we will define a **Provisioning Boundary Contract** consisting of abstract interfaces.

1. **Tenant Management:**
   * **Existing Contract:** CREATE (`ITenantProvisioningAdapter` or reuse repo directly since it's Core).
   * **Concrete Implementation:** `MockTenantRepository`.
   * **Owner:** Platform Core.
2. **Organization Management:**
   * **Existing Contract:** CREATE (`IOrganizationProvisioningAdapter` or reuse repo directly).
   * **Concrete Implementation:** Needs new `MockOrganizationRepository` (to move state out of Notifier).
   * **Owner:** Platform Core.
3. **Solution Management / Business Solution assignment:**
   * **Existing Contract:** CREATE (`ISolutionDefinitionProviderAdapter`).
   * **Concrete Implementation:** Wrapper around `MockSolutionDefinitionRepository`.
   * **Owner:** Solution Management (M5).
4. **Marketplace / Module Dependency validation:**
   * **Existing Contract:** CREATE (`IMarketplaceDependencyValidatorAdapter`).
   * **Concrete Implementation:** Adapter calling `MockMarketplaceRepository` methods to use authoritative M2 logic.
   * **Owner:** Marketplace (M2).
5. **Licensing / Entitlement:**
   * **Existing Contract:** CREATE (`IEntitlementValidatorAdapter`).
   * **Concrete Implementation:** New mock adapter `MockEntitlementAdapter`.
   * **Owner:** Future Licensing layer.
6. **User Management / Administrator creation:**
   * **Existing Contract:** CREATE (`IUserProvisioningAdapter`).
   * **Concrete Implementation:** Wrapper around `MockPlatformUserRepository`.
   * **Owner:** Platform Core / User Management.
7. **CustomerSolution:**
   * **Existing Contract:** CREATE (`ICustomerSolutionProvisioningAdapter`).
   * **Concrete Implementation:** Adapter wrapping `MockCustomerSolutionRepository`.
   * **Owner:** Customer Solution (M7).

---

## 7. Domain / Boundary Models
* `ProvisioningRequest`: Represents the intent, containing a `provisioningRequestId`. Owned by Provisioning.
* `ProvisioningProcessState`: Enum tracking milestones (`pending`, `tenant_created`, `solution_assigned`, `modules_activated`, `admin_created`, `completed`, `failed`). Owned by Provisioning.
* `ProvisioningOperation`: The execution log and current status. Owned by Provisioning.

---

## 8. Repository Strategy
* **New Repository:** `MockProvisioningRepository` to store long-lived `ProvisioningOperation` states.
* **Organization Repository:** Create `MockOrganizationRepository` to persist Organizations (moving logic out of `OrganizationListNotifier`).
* **Authoritative State:** Provisioning process records are owned by `MockProvisioningRepository`. Created domain entities remain owned by their respective repositories.

---

## 9. Riverpod Strategy
* **Persistence:** `MockProvisioningRepository` is a long-lived authoritative repository.
* **Orchestration:** `ProvisioningController` (a `NotifierProvider`) manages the orchestration steps. It reads other repositories (via boundary adapter providers) to execute the saga.
* Downstream UI providers observe the `ProvisioningController` state without recreating repositories on invalidation.

---

## 10. Provisioning State Model
* **Provisioning Process State (`ProvisioningProcessState`):** Tracks business orchestration milestones (e.g., `tenant_created`, `admin_created`).
* **Provisioning Operation State:** Mock execution state (e.g., `idle`, `running`, `error`, `success`).
* **CustomerSolution Lifecycle (`CustomerSolutionLifecycle`):** Domain state (`provisioning`, `active`, `suspended`) owned exclusively by M7.

---

## 11. New Tenant Flow
1. User enters data (Tenant info, Org info, Admin details, selects `SolutionDefinition`).
2. Generates unique `provisioningRequestId`. `ProvisioningOperation` created (`pending`).
3. **Tenant Creation:** Invokes Tenant boundary with `provisioningRequestId` for idempotency.
4. **Org Creation:** Invokes Org boundary.
5. **Solution Assignment:** Invokes CustomerSolution boundary to create record (`sourceSolutionDefinitionId`, exact version). State: `provisioning`.
6. **Module Activation:** Invokes M2 dependency authority via boundary.
7. **Config/Data:** Simulated setup steps.
8. **Admin Creation:** Invokes User boundary.
9. **Completion:** M7 lifecycle transitions to `active`.

---

## 12. Existing Tenant Flow
1. User selects existing Tenant.
2. Selects existing Organization OR creates new Organization under selected Tenant. Tenant is never recreated.
3. Selects `SolutionDefinition`.
4. `ProvisioningOperation` created with unique `provisioningRequestId`.
5. Steps for Tenant creation are skipped.
6. If failure occurs, the existing Tenant and Organization are NEVER deleted or rolled back.

---

## 13. Module Activation Strategy
M8 must NOT implement another dependency engine. 
* CA-MKT-002 -> Authoritative module dependency/compatibility logic.
* M8 Provisioning Boundary -> `IMarketplaceDependencyValidatorAdapter`.
* Customer Provisioning -> Calls the boundary to validate selected modules.

---

## 14. Licensing / Entitlement Strategy
Since no explicit licensing engine exists, provisioning will orchestrate via an `IEntitlementValidatorAdapter`. The concrete implementation will merely return a simulated success boolean, preserving the boundary for future real licensing engines.

---

## 15. Configuration Strategy
A-008 configuration chain is preserved.
* Inherited configuration (Marketplace -> Blueprint -> SolutionDefinition) is passed down.
* Provisioning orchestrates deep-copying these defaults into the `CustomerSolution` snapshot.
* Provisioning does NOT own future runtime configuration. It merely provides the initial provisioning defaults.

---

## 16. Initial Data Strategy
Initial data setup is an explicit orchestration step in the saga (`ProvisioningProcessState.initial_data_setup`). The mock orchestrator will yield this state to the UI to represent progress ("running" -> "success"), but no fake business-domain repositories will be created to simulate actual data insertion.

---

## 17. Administrator Strategy
Provisioning orchestrates a call to `IUserProvisioningAdapter` to create a mock administrator user tied to the Tenant. The concrete adapter delegates to `MockPlatformUserRepository`.

---

## 18. Failure / Retry / Idempotency / Compensation
* **Idempotency Request ID:** Every request has a `provisioningRequestId`. 
  * Same request ID -> same provisioning operation -> resume/retry existing operation.
  * Different request ID -> different operation.
* **Duplication Prevention:** Repositories or the orchestrator will check if an entity tied to the `provisioningRequestId` already exists. (e.g., Tenant, CustomerSolution, Admin).
* **Existing Tenant:** Existing tenant remains unchanged. Failed provisioning never deletes a Tenant.

---

## 19. CustomerSolution Integration
M8 invokes creation and activation through `ICustomerSolutionProvisioningAdapter`. `CustomerSolution` and `MockCustomerSolutionRepository` remain fully owned by CA-MKT-007. M8 must not move CustomerSolution into Platform Core.

---

## 20. Runtime Availability Boundary
M8 establishes that when Provisioning is completed, `CustomerSolution` becomes `ACTIVE`.
The M8 UI may show: "Customer Solution is active and ready for runtime."
No fake runtime destination or shell will be created.

---

## 21. Tenant Isolation Strategy
Mock repositories enforce `tenantId` filtering. The Existing-Tenant flow prevents cross-tenant Organization access.

---

## 22. UI / UX Plan
* **Provisioning Dashboard:** Shows past/active provisioning operations.
* **Provisioning Wizard:** A stepper UI.
* **Progress Screen:** Real-time visual ticks for each orchestration step.
* **Error/Retry Dialogs:** Consistent Material 3 alerts.

---

## 23. Routing Plan
* `/provisioning`: Dashboard of provisioning tasks.
* `/provisioning/new`: Provisioning Wizard.
* `/provisioning/:id/progress`: Live progress view.

---

## 24. Mock Data Plan
* Inject 2-3 pre-existing completed provisioning operations.
* Inject 1 failed operation to demonstrate retry capabilities.

---

## 25. Error Handling
The orchestration controller yields specific error states mapping to UI error messages without leaking technical exceptions.

---

## 26. Test Strategy
* **Idempotency:** Verify same request ID resumes operation without duplicating Tenant, Organization, CustomerSolution, Administrator, or module activation.
* **Existing Tenant:** Verify existing Tenant remains unchanged and failed provisioning never deletes Tenant.
* **Organization:** Verify new Organization created under selected Tenant. Cross-tenant Organization access rejected.
* **Dependency:** Verify M2 remains authoritative; required dependency failures halt provisioning.
* **Runtime boundary:** Verify CustomerSolution becomes ACTIVE. No runtime shell is created.
* **Frozen milestone protection:** Verify M1-M7 regression tests pass unmodified.

---

## 27. Exact Future File Changes

| Area | File Path | Action | Owner | Reason | Frozen Boundary? |
|---|---|---|---|---|---|
| Contracts | `lib/features/platform/domain/contracts/provisioning_boundaries.dart` | CREATE | Platform Core | Establish abstract boundary interfaces to avoid upward dependencies. | No |
| Models | `lib/features/platform/domain/models/provisioning_operation.dart` | CREATE | Platform Core | Process state model. | No |
| Models | `lib/features/platform/domain/models/provisioning_request.dart` | CREATE | Platform Core | Captures intent and `provisioningRequestId`. | No |
| Repo | `lib/features/platform/data/mock_provisioning_repository.dart` | CREATE | Platform Core | Persistence for operations. | No |
| Repo | `lib/features/platform/data/mock_organization_repository.dart` | CREATE | Platform Core | Extract Org state from Provider for idempotency. | No |
| Adapter | `lib/features/customer_solution/application/customer_solution_provisioning_adapter.dart` | CREATE | Customer Solution (M7) | Implements `ICustomerSolutionProvisioningAdapter` using M7 repo. | Yes (Adapter Only) |
| Adapter | `lib/features/solution_management/application/solution_definition_adapter.dart` | CREATE | Solution Mgt (M5) | Implements `ISolutionDefinitionProviderAdapter`. | Yes (Adapter Only) |
| Adapter | `lib/features/marketplace/application/marketplace_dependency_adapter.dart` | CREATE | Marketplace (M2) | Implements `IMarketplaceDependencyValidatorAdapter` delegating to M2. | Yes (Adapter Only) |
| Adapter | `lib/features/platform/application/tenant_provisioning_adapter.dart` | CREATE | Platform Core | Implements `ITenantProvisioningAdapter`. | No |
| Adapter | `lib/features/platform/application/organization_provisioning_adapter.dart` | CREATE | Platform Core | Implements `IOrganizationProvisioningAdapter`. | No |
| Adapter | `lib/features/platform/application/user_provisioning_adapter.dart` | CREATE | Platform Core | Implements `IUserProvisioningAdapter`. | No |
| Adapter | `lib/features/platform/application/mock_entitlement_adapter.dart` | CREATE | Platform Core | Implements `IEntitlementValidatorAdapter`. | No |
| Controller | `lib/features/platform/application/provisioning_controller.dart` | CREATE | Platform Core | Orchestration saga using boundaries. | No |
| UI | `lib/features/platform/presentation/provisioning_dashboard_screen.dart` | CREATE | Platform Core | Dashboard UI. | No |
| UI | `lib/features/platform/presentation/provisioning_wizard_screen.dart` | CREATE | Platform Core | Wizard UI. | No |
| UI | `lib/features/platform/presentation/provisioning_progress_screen.dart` | CREATE | Platform Core | Live progress UI. | No |
| Router | `lib/core/routing/app_router.dart` | MODIFY | Core | Add `/provisioning` routes. | No |
| Router | `lib/core/providers.dart` (or composition root) | MODIFY | Core | Register boundary adapters if necessary for DI. | No |
| Tests | `test/features/platform/provisioning_test.dart` | CREATE | Platform Core | Unit and orchestration tests. | No |
| M1-M7 | All existing frozen domain files | DO NOT TOUCH | Respective | Must not change behavior, logic, or ownership. | Yes |

---

## 28. Implementation Sequence
1. Existing implementation discovery confirmation (Verified).
2. Boundary contracts creation.
3. Boundary adapters creation (calling existing repos).
4. Provisioning models & request identity creation.
5. `MockProvisioningRepository` & `MockOrganizationRepository` creation.
6. Orchestration controller (`ProvisioningController`) logic.
7. Providers wiring.
8. Wizard UI creation.
9. Progress/details UI creation.
10. Minimal routing/composition-root wiring.
11. Mock data seeding.
12. Unit/orchestration tests.
13. Tenant-isolation tests.
14. Idempotency/retry tests.
15. M1-M7 regression validation.
16. Final implementation acceptance.

---

## 29. Risks / Open Questions
None currently unresolved. The architecture perfectly supports the boundaries required for mock implementation.

---

## 30. Architecture Compliance Checklist
* [x] **A-000:** Platform Core isolates provisioning via boundaries.
* [x] **A-008:** Orchestrates without usurping domain ownership.
* [x] **M1-M7 Protection:** Frozen implementations remain untouched. Adapters provide read/write access.

---

## 31. Final Implementation Readiness
READY FOR CHATGPT REVIEW
