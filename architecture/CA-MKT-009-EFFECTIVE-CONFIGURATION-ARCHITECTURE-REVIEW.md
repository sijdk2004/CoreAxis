# CA-MKT-009 — EFFECTIVE CONFIGURATION ARCHITECTURE REVIEW

## 1. Executive Summary
During the CA-MKT-009 Tenant Runtime Foundation implementation, a blocking architectural gap was identified regarding the ownership and provision of the Effective Runtime Configuration. Tenant Runtime requires a fully resolved, flattened configuration snapshot to initialize `RuntimeContext` without violating dependency constraints. However, the current frozen M7 (CustomerSolution) and M8 (Customer Provisioning) implementations do not produce or persist a pre-resolved effective configuration snapshot. This document investigates the architectural landscape, evaluates potential owners, and recommends a targeted architecture amendment to bridge this gap without invalidating the frozen milestones.

## 2. Current Configuration Architecture
The intended configuration inheritance chain is:
1. Marketplace Module Defaults
2. Blueprint Defaults
3. Business Solution Configuration
4. Customer Provisioning Defaults
5. Customer-specific Configuration
6. Runtime Effective Configuration

Currently, `CustomerSolution` stores the configuration deltas and references to Blueprint defaults but does not flatten them. The Tenant Runtime `RuntimeContext` was originally attempting to reconstruct this hierarchy, which violated the architectural boundary. This has been removed, leaving a gap where no effective snapshot is available to the runtime.

## 3. M7 CustomerSolution Findings
Inspection of `CustomerSolution` and `SolutionModuleConfiguration` reveals:
- **Persisted Data:** Stores `moduleConfigurations`, which contain `configuration` (the customer overrides) and a `MarketplaceModuleReference` (containing `blueprintConfiguration` defaults).
- **Defaults & Overrides:** Maintained separately within the nested objects. Blueprint defaults and customer overrides are isolated.
- **Deep Copying:** `deepCopyModules` exists to ensure immutability of the nested maps.
- **Flattening:** No flattened effective configuration is computed or stored.
- **Runtime Consumption Representation:** There is currently no pre-resolved representation that Runtime can safely consume without performing the merge logic itself.

## 4. M8 Customer Provisioning Findings
Inspection of `ProvisioningController` reveals:
- **Resolution:** M8 does not currently resolve configuration.
- **Copying:** M8 orchestrates the creation of the `CustomerSolution` but does not manipulate the configuration maps directly.
- **Snapshot Production:** M8 does not produce an effective configuration snapshot.
- **Lifecycle Availability:** The provisioning saga explicitly defines Step 6: `configuration_applied` (currently a placeholder with a `Future.delayed`). This is the exact logical lifecycle boundary where an effective snapshot should become available.
- **Ownership:** Exposing the snapshot here does not change M8's ownership; M8 remains the orchestrator that coordinates the computation and persists the result.

## 5. Existing Platform Core Configuration Capabilities
A search and review of `A-002_PLATFORM_CORE_ARCHITECTURE.md` confirms that Platform Core includes a **Configuration Platform** capability (handling Settings, Business Rules, Number Series, Localization). However, this platform capability cannot *compute* the effective configuration because Platform Core resides at the bottom of the architectural dependency chain (A-000) and cannot have upward dependencies on Marketplace, Blueprint, or Business Solutions. It can only provide foundational storage or rules engines.

## 6. Configuration Ownership Analysis
Configuration involves three distinct concepts:
- **Configuration Source:** M1, M4, M5, M7.
- **Configuration Composition/Resolution:** The act of merging the hierarchy. This logic requires visibility across the entire chain.
- **Effective Configuration Storage:** The final resting place of the snapshot.

The composition logic cannot reside in Platform Core (violates downward dependency rule) nor Tenant Runtime (violates scope and duplication rules). It logically belongs to the domain that represents the final deployed entity: **M7 Customer Solution**. 

## 7. Effective Configuration Resolution Responsibility
The responsibility for resolving the configuration hierarchy into a flat snapshot should belong to a dedicated Domain Service within M7 (e.g., `CustomerSolutionConfigurationResolver`). M7 is the only domain that fully encapsulates the CustomerSolution aggregate and has legitimate reason to process its own internal configurations. M8 (Customer Provisioning) is responsible for *orchestrating* this resolution during the provisioning lifecycle.

## 8. Lifecycle Resolution Point
The effective configuration must be resolved at two distinct lifecycle points:
1. **Customer Provisioning (M8):** Specifically at Step 6 (`configuration_applied`), before initial data setup and before Runtime activation.
2. **Solution Management (M6):** Whenever a customer or administrator updates their specific configuration overrides after provisioning.

Runtime initialization is expressly the *wrong* point for resolution, as it would require Runtime to hold historical hierarchy awareness.

## 9. Proposed Effective Configuration Contract
**`EffectiveRuntimeConfigurationSnapshot`**
- Conceptually a `Map<String, dynamic>` (or a wrapped value object).
- Stored as a direct, immutable field on the `CustomerSolution` entity: `Map<String, dynamic> effectiveConfigurationSnapshot`.
- It is tenant and customer-solution scoped.
- Safe for Tenant Runtime to consume blindly (O(1) lookup).
- Traceable and deterministic based on the underlying `SolutionModuleConfiguration` hierarchy.

## 10. Dependency Direction Validation
This proposal strictly adheres to A-000 and A-008:
- **Runtime:** Depends on `CustomerSolution` (downward dependency) to read the snapshot. No upward or cross-domain dependencies added.
- **M8 Provisioning:** Depends on M7 (downward dependency) to orchestrate resolution.
- **Platform Core:** Remains independent of Business Solutions.
- No reverse dependencies are introduced.

## 11. M7/M8 Freeze Impact
Because M7 and M8 are frozen, modifying the `CustomerSolution` model to include `effectiveConfigurationSnapshot` and updating `ProvisioningController` to invoke the resolver constitutes a modification of frozen architecture. 
This requires a narrowly-scoped architecture amendment.
The amendment does not invalidate the *concepts* of M7/M8; it merely completes the configuration capability that was identified as a placeholder (Step 6) in the original M8 design.

## 12. CA-MKT-009 Runtime Consumption Model
The current CA-MKT-009 implementation has correctly removed all merge logic from `RuntimeContext`. It currently injects an empty map `{}` as the `effectiveConfigurationSnapshot` due to the upstream gap. Once M7 provides the snapshot, `runtime_providers.dart` will simply map `customerSolution.effectiveConfigurationSnapshot` directly into the `RuntimeContext`.

## 13. Alternatives Considered
- **Marketplace (M1):** Unaware of customer context. Rejected.
- **Blueprint (M4) / Business Solution (M5):** Unaware of tenant/customer overrides. Rejected.
- **Customer Provisioning (M8):** Good orchestrator, but should not hold persistent state (A-008: "does not become the permanent configuration owner"). Rejected as the storage owner.
- **Platform Core Configuration:** Violates dependency direction if it performs the merge. Could act as a generic key-value store, but splitting the configuration from the `CustomerSolution` lifecycle adds unnecessary complexity. Rejected.
- **Tenant Runtime (M9):** Violates architectural separation of concerns and forces historical hierarchy awareness onto the runtime. Rejected.

## 14. Recommended Architecture
- **Storage:** Add `effectiveConfigurationSnapshot: Map<String, dynamic>` to `CustomerSolution` (M7).
- **Resolution:** Add `CustomerSolutionConfigurationResolver` (domain service) to M7.
- **Orchestration:** Update M8 `ProvisioningController` Step 6 to invoke the resolver and persist the updated `CustomerSolution`.

## 15. Required Architectural Changes
To proceed, the following minimum exact changes are required:
1. **M7:** Add `final Map<String, dynamic> effectiveConfigurationSnapshot;` to `CustomerSolution` and its `copyWith`/constructors.
2. **M7:** Create `CustomerSolutionConfigurationResolver` to perform the deep merge of `blueprintConfiguration` and `configuration`.
3. **M8:** Update `ProvisioningController` Step 6 (`configuration_applied`) to retrieve the `CustomerSolution`, invoke the resolver, and save the updated snapshot.
4. **M7/M8 Tests:** Update associated unit tests to reflect the new field.

## 16. Implementation Impact
- **M7 (Customer Solution):** Minor model extension and addition of one pure domain service.
- **M8 (Customer Provisioning):** Minor update to Step 6 of the existing saga.
- **M9 (Tenant Runtime):** Trivial update to map `solution.effectiveConfigurationSnapshot` in `runtime_providers.dart` (replacing the current empty map `{}`).

## 17. Blocking Issues
The inability of Tenant Runtime to consume an effective configuration snapshot without reconstructing it violates the architecture. The required fix alters frozen M7/M8 files.

## 18. Final Recommendation
The architecture must be amended to allow M7 to store and M8 to orchestrate the effective configuration snapshot.

---
ARCHITECTURE INVESTIGATION COMPLETE

STATUS: ARCHITECTURE AMENDMENT REQUIRED — BLOCKING
