# CA-MKT-009 — EFFECTIVE CONFIGURATION FINAL ARCHITECTURE GATE

## 1. Final Decision Summary
After deep architectural inspection of the frozen M1-M8 implementation, two significant configuration layer gaps have been identified: Marketplace Module Defaults and Customer Provisioning Defaults do not exist in the actual data models. Furthermore, Business Solution Configuration and Customer-Specific Configuration share the same physical storage field at runtime. The configuration resolution algorithm strictly belongs to M7 (Customer Solution) and can be executed deterministically without violating A-000 dependency rules because all necessary input data is already copied into the `CustomerSolution` aggregate during provisioning. The architecture is ready for implementation, provided the inheritance expectations are formally adjusted to match the actual implemented reality.

## 2. Five-Layer Configuration Source Matrix

| Layer | Actual Source | Owner | Available At Resolution? | How Resolver Accesses It |
|---|---|---|---|---|
| 1. Marketplace Module Defaults | **ABSENT** (`MarketplaceModuleRelease` has no config) | N/A | No | N/A (Does not exist) |
| 2. Blueprint Defaults | `MarketplaceModuleReference.blueprintConfiguration` | M4 Blueprint | Yes | Read directly from `CustomerSolution`'s nested reference |
| 3. Business Solution Configuration | `SolutionModuleConfiguration.configuration` | M6 Solution Mgmt | Yes | Initial state of `CustomerSolution`'s config map |
| 4. Customer Provisioning Defaults | **ABSENT** (`ProvisioningRequest` has no config) | N/A | No | N/A (Does not exist) |
| 5. Customer-specific Configuration | `SolutionModuleConfiguration.configuration` | M7 Customer Sol | Yes | Mutated state of `CustomerSolution`'s config map |

## 3. Configuration Ownership
- **M7 Customer Solution:** Owns the effective configuration snapshot and the customer-specific configuration overrides (which are initialized from the Business Solution Configuration).
- **M8 Customer Provisioning:** Owns orchestration. It retrieves the `CustomerSolution` and invokes the resolver during Step 6 of provisioning.
- **M9 Tenant Runtime:** Strictly consumes the snapshot.

## 4. Algorithm Ownership
M7 `CustomerSolution` exclusively owns the configuration resolution algorithm. The resolver is a pure domain service in M7 that knows how to merge `blueprintConfiguration` with the active `configuration` map for each module.

## 5. Input Ownership
M7 `CustomerSolution` owns all inputs at the time of resolution. Because M8 copies the `blueprintConfiguration` (from M4) and the Business Solution `configuration` (from M6) into the `CustomerSolution` entity during initialization, M7 does not need to reach outside its own aggregate to resolve the final state.

## 6. Resolution Contract
The contract is a pure, self-contained domain function:
```dart
EffectiveRuntimeConfigurationSnapshot resolve(
    CustomerSolution solution
)
```
This guarantees no hidden repository dependencies or I/O side effects.

## 7. Customer Provisioning Defaults Analysis
**CUSTOMER PROVISIONING DEFAULT SOURCE GAP**
Inspection of M8 `ProvisioningRequest` and `ProvisioningController` reveals that provisioning defaults do not exist. Provisioning orchestrates the creation of the tenant, organization, and solution, but does not inject arbitrary configuration defaults into the modules. This layer is currently a phantom concept in A-008 and must be dropped or marked as a future capability.

## 8. Business Solution Configuration Analysis
In the current architecture, Business Solution Configuration is defined in M6 `SolutionDefinition.moduleConfigurations[i].configuration`. During M8 Provisioning, this exact configuration list is copied by value into M7 `CustomerSolution`. Therefore, "Business Solution Configuration" serves as the **initial state** of the M7 `configuration` map, which is subsequently mutated to become the "Customer-specific Configuration". They are not distinct layers at resolution time; they are the same physical map at different points in the lifecycle.

## 9. Marketplace Defaults Analysis
**MARKETPLACE MODULE DEFAULTS GAP**
Inspection of M1 `MarketplaceModule` and `MarketplaceModuleRelease` confirms that Marketplace modules do not publish a default configuration map. The first layer of configuration defaults is explicitly authored in M4 `SolutionBlueprint`. Therefore, Blueprint Defaults act as the foundational configuration layer in the actual platform implementation.

## 10. Effective Snapshot Model
The `EffectiveRuntimeConfigurationSnapshot` is a value object containing:
- `Map<String, dynamic> resolvedConfiguration`
- `DateTime resolvedAt`
- `String sourceSolutionDefinitionVersion`

This is sufficient. It does not require CustomerSolution or Tenant identity because the snapshot is persisted directly on the `CustomerSolution` entity. It guarantees traceability back to the exact M6 Solution version without inventing a secondary versioning engine.

## 11. Module Isolation Model
The resolved map is strictly isolated by module code:
```
EffectiveRuntimeConfigurationSnapshot
    ├── MODULE_CODE_A
    │      └── { merged configuration }
    ├── MODULE_CODE_B
    │      └── { merged configuration }
```
A module cannot override another module's configuration. Explicit `null` values within a module's override map will delete the corresponding key inherited from the Blueprint layer.

## 12. M8 Provisioning Boundary
During M8 Step 6 (`configuration_applied`):
- M8 uses the `CustomerSolutionProvisioningAdapter` to fetch the `CustomerSolution`.
- M8 invokes the pure M7 domain service: `CustomerSolutionConfigurationResolver.resolve(solution)`.
- M8 updates the `CustomerSolution` with the returned snapshot via the adapter.
This is a standard process flow and perfectly respects A-008 and A-000 because M8 is permitted to depend downward on M7 domain logic and M7 adapters.

## 13. Dependency Direction Validation
- **M7 Resolver:** Has 0 external dependencies. It only depends on the M7 `CustomerSolution` entity.
- **M8 Provisioning:** Depends on M7 (downward) to execute the orchestration.
- **M9 Runtime:** Depends on M7 (downward) to read the snapshot.
- **Platform Core:** Untouched.
There are no upward dependencies, no circular dependencies, and no concrete repository leaks.

## 14. M7/M8 Freeze Impact
- **M7:** Must add `EffectiveRuntimeConfigurationSnapshot` value object, add it as a field on `CustomerSolution`, and implement the pure `CustomerSolutionConfigurationResolver`.
- **M8:** Must update `ProvisioningController` Step 6 to invoke the resolver and persist the snapshot.

## 15. SSOT Changes Required
| Document | Change? | Exact Section | Reason |
|---|---|---|---|
| A-000_COREAXIS_META_ARCHITECTURE.md | No | | |
| A-005_BUSINESS_SOLUTION_ARCHITECTURE.md | No | | |
| A-008_CUSTOMER_PROVISIONING_ARCHITECTURE.md | Yes | Section 12. Configuration Inheritance | Must remove or flag "Marketplace Module Defaults" and "Customer Provisioning Defaults" as they do not exist. Must clarify that the effective configuration is merged strictly from Blueprint Defaults and Customer Overrides within the `CustomerSolution` aggregate. |
| B-002_SOLUTION_MANAGEMENT.md | No | | |

## 16. Implementation Sequence
1. Update A-008.
2. Implement M7 snapshot value object and `CustomerSolution` field.
3. Implement M7 `CustomerSolutionConfigurationResolver`.
4. Update M8 `ProvisioningController` Step 6.
5. Update M9 `RuntimeContext` mapping in `runtime_providers.dart`.

## 17. Remaining Blocking Issues
None. The actual inputs have been verified as existing within the `CustomerSolution` boundary, making the resolution deterministic and architecturally safe.

## 18. Final Architecture Decision
ARCHITECTURE INVESTIGATION + AMENDMENT DESIGN COMPLETE

IMPLEMENTATION PERFORMED: NO

STATUS: READY FOR ARCHITECTURE AMENDMENT IMPLEMENTATION
