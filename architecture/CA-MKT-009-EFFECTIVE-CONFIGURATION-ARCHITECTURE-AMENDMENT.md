# CA-MKT-009 — EFFECTIVE CONFIGURATION ARCHITECTURE AMENDMENT

## 1. Amendment Summary
This document formally amends the CoreAxis architecture to resolve a blocking gap identified during the CA-MKT-009 Tenant Runtime Foundation implementation. It establishes M7 (Customer Solution) as the definitive owner of the resolved effective configuration snapshot and the configuration-resolution domain service. It designates M8 (Customer Provisioning) as the orchestrator that invokes this resolution during provisioning, and M9 (Tenant Runtime) as the strict consumer of the pre-resolved snapshot.

## 2. Problem Being Resolved
Tenant Runtime (M9) requires a fully resolved, flattened configuration snapshot to initialize `RuntimeContext` safely without performing complex hierarchy resolution. The frozen M7 and M8 implementations stored configuration inputs and deltas but lacked the architectural capability to produce a unified effective snapshot, creating a blocking gap that would force Runtime to violate architectural dependency and responsibility constraints.

## 3. Existing Architecture
The existing architecture defines the configuration inheritance chain:
1. Marketplace Module Defaults
2. Blueprint Defaults
3. Business Solution Configuration
4. Customer Provisioning Defaults
5. Customer-specific Overrides

Currently, M7 `CustomerSolution` stores these inputs (specifically `blueprintConfiguration` and customer `configuration`) in isolated nested maps inside `SolutionModuleConfiguration`, but never flattens them into an effective representation.

## 4. Confirmed Configuration Ownership
The previous investigation incorrectly assumed M6 (Solution Management) manages customer-specific overrides. This amendment corrects and formally defines the ownership:
- **M7 Customer Solution:** Owns the customer-specific configuration data, the effective configuration snapshot, the configuration resolution algorithm, and the deterministic merge rules. M7 is the correct aggregate boundary for a specific customer's deployed solution.
- **M8 Customer Provisioning:** Owns provisioning orchestration, including invoking the M7 resolution algorithm at the appropriate provisioning step.
- **M9 Tenant Runtime:** Owns runtime consumption only. M9 must never merge or resolve configuration.

## 5. Configuration Resolution Responsibility
The authoritative resolution algorithm is defined as:
**`CustomerSolutionConfigurationResolver`**
- An M7-owned, pure, domain-level service.
- Highly deterministic and side-effect free.
- Fully independent of UI, GoRouter, Riverpod, and backend implementations.
- Reusable by M8 (during provisioning) and M7 (during future customer configuration updates).
- Guarantees exactly ONE configuration-resolution engine exists in the platform.

## 6. Effective Runtime Configuration Snapshot
The output of the resolver is defined as:
**`EffectiveRuntimeConfigurationSnapshot`**
- A separate Value Object owned by M7 `CustomerSolution` (not just a raw Map field).
- Immutable, deep-copied, and tenant/customer-solution scoped.
- Directly consumable by M9 Runtime in O(1) time.
- Traceable, containing metadata (e.g., exact source SolutionDefinition version and resolution timestamp) to ensure it corresponds precisely to the context from which it was generated.

## 7. Resolution Lifecycle
The primary resolution point occurs during M8 Customer Provisioning:
1. Step 6: `configuration_applied`
2. M8 retrieves the `CustomerSolution` (M7).
3. M8 invokes the `CustomerSolutionConfigurationResolver`.
4. M8 persists the resulting `EffectiveRuntimeConfigurationSnapshot` onto the `CustomerSolution`.
5. Step 7: `initial_data_setup`
6. ...
7. CustomerSolution becomes ACTIVE.
8. Tenant Runtime consumes the snapshot upon initialization.

## 8. Configuration Precedence
Resolution utilizes deep merging with the following precedence (later overrides earlier):
1. Marketplace Module Defaults
2. Blueprint Defaults
3. Business Solution Configuration
4. Customer Provisioning Defaults
5. Customer-specific Configuration

**Granularity & Semantics:**
- Configuration is strictly **module-specific**. The snapshot must isolate configurations by module identity (e.g., keyed by `moduleCode` or `moduleId`).
- One module cannot override another module's configuration.
- Explicit `null` values in an override layer logically remove the corresponding key inherited from an earlier layer.
- Missing values simply inherit from the previous layer.

## 9. M7 Responsibility Amendment
M7 is amended to include:
- The `EffectiveRuntimeConfigurationSnapshot` value object.
- A field on `CustomerSolution` to hold this snapshot.
- The `CustomerSolutionConfigurationResolver` domain service to compute the snapshot based on the `SolutionModuleConfiguration` list.

## 10. M8 Responsibility Amendment
M8 is amended to clarify that:
- Step 6 (`configuration_applied`) is the explicit lifecycle boundary for effective configuration resolution.
- Provisioning invokes the M7-owned resolver.
- M8 persists the resulting snapshot by updating the `CustomerSolution` entity.
- M8 does NOT own the configuration model or the resolution logic.

## 11. M9 Runtime Responsibility
M9 is amended to explicitly restrict its role:
- `RuntimeContext` solely consumes the `EffectiveRuntimeConfigurationSnapshot`.
- M9 never reconstructs historical configuration inheritance or resolves defaults.

## 12. Future Configuration Update Handling
When a customer or administrator updates configuration post-provisioning:
- The update is handled by an M7-owned capability (e.g., a Customer Solution Update Service).
- M7 modifies the `SolutionModuleConfiguration` overrides.
- M7 invokes the `CustomerSolutionConfigurationResolver` to regenerate the `EffectiveRuntimeConfigurationSnapshot`.
- The new snapshot replaces the old one on the `CustomerSolution`.
- Tenant Runtime (M9) receives the new snapshot upon its next initialization or via reactive provider invalidation.

## 13. Versioning and Immutability
To guarantee the snapshot aligns with its source, the `EffectiveRuntimeConfigurationSnapshot` value object will include:
- `resolvedAt`: Timestamp of resolution.
- `sourceSolutionDefinitionVersion`: The exact version of the Business Solution used during resolution.
This ensures immutability and traceability without inventing a parallel versioning system.

## 14. Dependency Direction Validation
This amendment strictly adheres to A-000 and A-008:
- **Platform Core:** Remains independent of Business Solutions and Customer Solutions.
- **M8 Provisioning:** Depends downward on M7 Customer Solution to orchestrate the resolution.
- **M9 Runtime:** Depends downward on M7 to consume the snapshot.
- No upward dependencies into Platform Core are introduced.
- No concrete Marketplace/Blueprint repositories are accessed by M9.

## 15. A-008 Boundary Validation
A-008 dictates that Provisioning orchestrates initial configuration but does not become the permanent configuration owner. This amendment perfectly aligns with A-008 by having M8 orchestrate the invocation of the M7 resolver, leaving M7 as the permanent owner of the resulting snapshot.

## 16. Frozen Milestone Impact
- M1-M6: Completely unaffected.
- M7: Requires adding a value object, a field on the aggregate, and a pure domain service. No existing logic is invalidated.
- M8: Requires replacing a `Future.delayed` placeholder in Step 6 with a call to the M7 resolver. No saga states are invalidated.

## 17. Alternatives Rejected
- **M6 Solution Management Ownership:** Rejected because M6 manages global Business Solutions, not customer-specific deployments and overrides.
- **M8 Resolution Ownership:** Rejected because M8 orchestrates but does not permanently own the configuration lifecycle, causing issues for post-provisioning updates.
- **Global Flattening:** Rejected because configuration is fundamentally module-specific; flattening globally risks key collisions across distinct modules.

## 18. Exact Architectural Changes Required
1. Define `EffectiveRuntimeConfigurationSnapshot` in M7.
2. Add `effectiveConfigurationSnapshot` field to M7 `CustomerSolution`.
3. Create `CustomerSolutionConfigurationResolver` in M7.
4. Update M8 `ProvisioningController` Step 6 to invoke the resolver and update the `CustomerSolution`.

## 19. Implementation Sequencing
1. Implement M7 model additions (`EffectiveRuntimeConfigurationSnapshot`).
2. Implement M7 `CustomerSolutionConfigurationResolver` and its unit tests.
3. Update M8 `ProvisioningController` to consume the resolver.
4. Update M9 `RuntimeContext` to map the populated snapshot.

## 20. Risks and Open Questions
- **Risk:** Deep merging complex JSON structures can be computationally expensive. **Mitigation:** The resolution only occurs during provisioning or explicit configuration updates, never on the hot path of Runtime initialization.
- **Open Question:** How are explicitly deleted keys represented in the delta overrides vs implicitly missing keys? **Decision:** Explicit `null` values represent deletions; missing keys represent inheritance.

## 21. Final Architecture Decision

### SSOT Updates Required
| DOCUMENT | CHANGE REQUIRED | REASON |
|---|---|---|
| A-000_COREAXIS_META_ARCHITECTURE.md | NO SSOT CHANGE REQUIRED | |
| A-005_BUSINESS_SOLUTION_ARCHITECTURE.md | NO SSOT CHANGE REQUIRED | |
| A-008_CUSTOMER_PROVISIONING_ARCHITECTURE.md | CHANGE REQUIRED | Must clarify that Provisioning Step 6 invokes the M7 configuration resolver and M7 owns the resulting snapshot. |
| B-002_SOLUTION_MANAGEMENT.md | NO SSOT CHANGE REQUIRED | |

ARCHITECTURE INVESTIGATION + AMENDMENT DESIGN COMPLETE

IMPLEMENTATION PERFORMED: NO

STATUS: READY FOR ARCHITECTURE AMENDMENT IMPLEMENTATION
