# A-008 Customer Provisioning Architecture

## 1. Document Control
* **Document ID:** A-008
* **Title:** Customer Provisioning Architecture
* **Status:** Draft / Architecture Review
* **Scope:** Defines Customer Provisioning as a Platform Core orchestration capability responsible for establishing the logical operational boundary required for a Customer Solution.
* **Dependencies:** A-000 CoreAxis Meta Architecture, A-002 Platform Core Architecture, A-005 Business Solution Architecture, B-002 Solution Management, CA-MKT-007 Customer Solution Foundation.
* **Related Documents:** A-001, A-003, A-004, A-100, B-001.

---

## 2. Document Purpose
This document defines Customer Provisioning as a Platform Core orchestration capability responsible for establishing the logical operational boundary required for a Customer Solution. It defines architectural ownership, process boundaries, lifecycle relationships, dependencies, isolation, failure semantics, and runtime/deployment boundaries. This document is the formal SSOT (Single Source of Truth) and does not serve as an implementation specification.

---

## 3. Required Terminology
This document uses existing CoreAxis terminology consistently:
* **Tenant:** The absolute data isolation boundary.
* **Organization:** A logical/business/legal structure within a Tenant.
* **Business Solution:** The reusable Platform-owned solution offering represented by a `SolutionDefinition`.
* **SolutionDefinition:** The formal definition of a Business Solution.
* **Customer Solution:** The tenant-specific instantiated/deployed solution, represented by the `CustomerSolution` entity.
* **Business Module:** An atomic, reusable business capability.
* **Marketplace:** Owns the repository and distribution of Business Modules.
* **Solution Blueprint:** The logical composition graph of selected Marketplace Modules.
* **Solution Composer:** The interactive authoring session transforming a Blueprint into a SolutionDefinition.
* **Solution Management:** The management of SolutionDefinitions.
* **Customer Provisioning:** The orchestration process between Business Solution and Customer Solution.
* **Customer Runtime:** The operational environment where users interact with the active Customer Solution.
* **Platform Core:** Foundational platform capabilities (e.g., Tenant Management, User Management).

---

## 4. Formal Provisioning Definition
```text
Business Solution / SolutionDefinition
        ↓
Customer Provisioning
        ↓
CustomerSolution
        ↓
Customer Runtime
```
- **Nature:** Provisioning is an orchestration capability. It is not itself a persistent business domain entity.
- **Coordination:** It coordinates domain entities owned by their respective modules.
- **Process vs Dependency Direction:** The flow shown above is the **business orchestration direction**. It does NOT imply a code-level architectural dependency from Platform Core to the Business Solution or Customer Solution domains.
- **Scope Limit:** It does not replace Tenant Management, Organization Management, User Management, RBAC, Licensing, Configuration, Marketplace, Solution Management, or Runtime.

---

## 5. Provisioning Modes
Tenant creation is conditional. Customer Provisioning may establish a new Tenant or operate against an existing Tenant depending on the provisioning scenario. A Tenant may exist without a CustomerSolution.

### New-Tenant Provisioning
```text
Customer / Registration
        ↓
Create Tenant
        ↓
Initialize Organization
        ↓
Assign Business Solution
        ↓
Create Customer Solution
        ↓
Enable Modules
        ↓
Initialize Configuration / Data
        ↓
Create Initial Administrator
        ↓
Customer Solution Active
```

### Existing-Tenant Solution Provisioning
```text
Existing Tenant
        ↓
Validate Tenant
        ↓
Initialize / Validate Organization
        ↓
Assign Business Solution
        ↓
Create Customer Solution
        ↓
Enable Modules
        ↓
Initialize Configuration / Data
        ↓
Create Administrator if required
        ↓
Customer Solution Active
```

---

## 6. Platform Core Provisioning Dependency Boundary
To comply with A-000 dependency direction (Platform Core must not depend directly on higher-layer domains), Customer Provisioning utilizes an explicit **Provisioning Orchestration Contract / Boundary**.

```text
                Business / Customer Layers
                         │
                         │ Provisioning Contract (API / Interfaces)
                         ▼
                 ┌─────────────────────┐
                 │ Customer Provisioning│
                 │     Boundary        │
                 └─────────────────────┘
                         │
                         ▼
                   Platform Core
```

**Boundary Rules:**
1. Customer Provisioning is owned by Platform Core.
2. Provisioning orchestrates customer onboarding but does not own Business Solution or Customer Solution domain models.
3. Platform Core must not directly depend on higher-layer domain implementations (e.g., it must not import `CustomerSolution` or `SolutionDefinition` concrete models directly).
4. Interaction with higher-layer concerns occurs through an explicitly defined provisioning contract/boundary (e.g., port/adapter interfaces or platform-neutral orchestration commands).
5. Higher layers may invoke provisioning through the approved contract.
6. The contract must not redefine ownership of Business Solution, CustomerSolution, Marketplace, or Business Modules.
7. Customer Provisioning must not duplicate domain logic owned by those layers.
8. Process orchestration direction must not be confused with package/module dependency direction.
9. No circular dependency is permitted.
10. Any genuine reverse dependency that cannot be resolved through the approved boundary requires an Architecture Decision Record (ADR) before implementation.

---

## 7. Ownership Architecture
Provisioning orchestrates; the respective domain/module owns its data and behavior. Platform Core does NOT own the CustomerSolution domain model.

**Explicit Ownership Rules:**
* The Customer Solution domain/module owns the `CustomerSolution` domain model; Customer Provisioning orchestrates its creation through the approved provisioning boundary.
* Solution Management owns `SolutionDefinition`.
* Marketplace owns Marketplace Module definitions.
* Marketplace/Module Definition remains authoritative for dependency metadata.
* Tenant Management owns Tenant.
* Organization Management owns Organization.
* User Management owns Administrator.
* RBAC owns RBAC behavior.
* Licensing owns entitlements.
* Configuration ownership remains with the appropriate configuration/domain owner.

| Concern             | Owner                                     | Provisioning Responsibility (Via Contract Boundary) |
| ------------------- | ----------------------------------------- | --------------------------------------------------- |
| Tenant              | Tenant Management                         | Establish/validate natively                         |
| Organization        | Organization Management                   | Establish/validate natively                         |
| CustomerSolution    | Customer Solution domain/module           | Orchestrate creation via Boundary                   |
| SolutionDefinition  | Solution Management                       | Consume via abstract Boundary                       |
| Module Definition   | Marketplace                               | Consume via abstract Boundary                       |
| Module Dependencies | Marketplace / Module Definition           | Validate/consume via abstract Boundary              |
| Licensing           | Licensing Platform                        | Consume/validate entitlement natively               |
| Configuration       | Configuration Platform / respective owner | Orchestrate initial setup via Boundary              |
| Initial Module Data | Business Modules                          | Invoke/orchestrate via Boundary                     |
| Administrator       | User Management                           | Orchestrate natively                                |
| RBAC                | RBAC                                      | Consume natively                                    |
| Runtime             | Customer Runtime                          | Boundary only                                       |
| Infrastructure      | Infrastructure/DevOps                     | Out of scope                                        |
| Billing             | Commercial/Billing                        | Out of scope                                        |

---

## 8. Tenant and Organization Architecture
```text
Tenant
 ├── Organization(s)
 ├── CustomerSolution(s)
 ├── User(s)
 ├── Role(s)
 └── Platform-scoped data
```
- Tenant is the absolute isolation boundary.
- Organization is a logical/business/legal structure within Tenant.
- `tenantId` and `organizationId` are distinct.
- CustomerSolution belongs to Tenant.
- Organization does not own CustomerSolution.
- One Tenant may contain multiple Organizations.

---

## 9. Business Solution Assignment
```text
Business Solution / SolutionDefinition
        ↓
Immutable source
        ↓
Customer Provisioning
        ↓
CustomerSolution
```
- The source `SolutionDefinition` must be published.
- The exact version must be locked.
- `sourceSolutionDefinitionId` must remain traceable.
- Subsequent SolutionDefinition changes must not mutate existing CustomerSolutions.
- **Architectural Boundary:** Provisioning receives the identifier or an abstract representation of the selected published `SolutionDefinition` through the provisioning contract, ensuring Platform Core does not depend on the internal Business Solution implementation.

---

## 10. Module Enablement
- `SolutionDefinition` contains selected modules.
- Customer Provisioning establishes customer-specific enabled modules.
- Licensing may restrict enablement.
- Dependency validation may be performed during activation.
- **Critical rule:** A-008 does not own module dependency definitions and does not create a second dependency engine. CA-MKT-002 remains authoritative. Provisioning obtains the required module/dependency information purely through the approved architectural boundary.

---

## 11. Licensing
Licensing is defined as **Capability/module entitlement**.
```text
Licensing
    ↓
Entitlement
    ↓
Provisioning validates entitlement
    ↓
Module activation permitted/rejected
```
- **Excluded:** billing, payment, subscription invoicing, commercial pricing, revenue sharing. Detailed licensing implementation remains future architecture. Provisioning only orchestrates/validates against the licensing contract.

---

## 12. Configuration Inheritance
```text
Blueprint Defaults
        ↓
Current CustomerSolution Configuration
        ↓
Runtime Effective Configuration Snapshot
```
- **Marketplace Module Defaults** and **Customer Provisioning Defaults** are not currently implemented as separate configuration layers in the architecture.
- The **Current CustomerSolution Configuration** is initialized from the Business Solution Configuration during provisioning and mutated thereafter.
- A-008 orchestrates the initial configuration resolution at Step 6 (`configuration_applied`).
- M8 (Provisioning) invokes the resolution algorithm but does not become the permanent configuration owner.
- M7 (Customer Solution) strictly owns the configuration-resolution algorithm and the resulting immutable snapshot.
- M9 (Tenant Runtime) strictly consumes the snapshot and does not reconstruct configuration.

---

## 13. Initial Data Setup
Provisioning orchestrates initialization; the respective owner defines the initialization contract and owns the resulting data. Provisioning does not become the owner of module/domain data.
- **Platform initialization:** timezone, currency, number series, platform defaults.
- **Tenant initialization:** tenant defaults, initial organization, administrator context.
- **Business Module initialization:** module reference/master data, module defaults.

---

## 14. Administrator Provisioning
- The initial Administrator belongs to User Management.
- Administrator is Tenant-scoped and associated with the initial Organization.
- Provisioning associates the Administrator with the platform-defined administrative role.
- Authentication integration is out of scope.
- RBAC internals are not defined by provisioning.

---

## 15. Provisioning Process State
Provisioning process state is ephemeral orchestration state, distinct from domain lifecycles.
Suggested process states:
`pending`, `tenant_created`, `solution_assigned`, `modules_activated`, `admin_created`, `completed`, `failed`.

Explicitly distinguish:
- Provisioning Process State
- CustomerSolutionLifecycle (long-lived domain state)
- Tenant Lifecycle (long-lived domain state)

---

## 16. Failure, Retry, Idempotency, Compensation
```text
Provisioning Failure
        ↓
Identify artifacts created by THIS provisioning operation
        ↓
Retry failed step if safely possible
        OR
Execute compensating action
        ↓
Preserve pre-existing valid entities
```
- Existing Tenants must never be deleted because an associated provisioning operation failed.
- The orchestration must use Saga/compensation-compatible orchestration patterns.
- Backend transaction technology is not mandated here.

---

## 17. Multiple CustomerSolutions
```text
Tenant
 ├── CustomerSolution A
 ├── CustomerSolution B
 └── CustomerSolution C
```
Each CustomerSolution independently retains:
- source SolutionDefinition
- exact version
- module configuration
- lifecycle
- customer-specific state
Login-time CustomerSolution selection is deferred to Runtime/Session architecture.

---

## 18. Tenant Isolation
```text
Tenant
   ↓
Organization(s)
   ↓
CustomerSolution(s)
   ↓
Enabled Modules
```
- Tenant = absolute isolation boundary
- Organization = business/legal/logical structure
- CustomerSolution = application/product boundary
- Module enablement = feature boundary
- Provisioning must never cross tenant boundaries.

---

## 19. Runtime Boundary
```text
Provisioning
        ↓
Tenant established
        ↓
Organization established
        ↓
CustomerSolution established
        ↓
Required configuration/entitlements established
        ↓
Administrator established
        ↓
CustomerSolution = ACTIVE
        ↓
Customer Runtime becomes available
        ↓
User Login / Runtime Session
```
**Critical rule:** Runtime becomes available when CustomerSolution is operationally ready. First login does not define the beginning of Runtime. A-008 does not design the Runtime Shell.

---

## 20. Deployment Boundary
A-008 concerns logical provisioning only.
**Explicitly excluded:** cloud infrastructure, Kubernetes, containers, physical database provisioning, database sharding, CI/CD, infrastructure scaling, physical deployment.

---

## 21. Frozen Milestone Protection
A-008 consumes and does not redefine frozen milestones: CA-MKT-001, CA-MKT-002, CA-MKT-003, CA-MKT-004, CA-MKT-005, CA-MKT-006, CA-MKT-007. They all remain frozen.

---

## 22. End-to-End Conceptual Architecture

### Business Process Flow
This represents the lifecycle orchestration direction (not the code-level architectural dependency):
```text
Business Solution / SolutionDefinition
        │
        │ published + exact version
        ▼
Customer Provisioning
        │
        ├── Establish / validate Tenant
        │
        ├── Establish initial Organization
        │
        ├── Assign exact SolutionDefinition version
        │
        ├── Validate licensing/entitlements
        │
        ├── Determine customer module enablement
        │
        ├── Initialize configuration
        │
        ├── Initialize required data
        │
        ├── Create initial Administrator
        │
        └── Create/activate CustomerSolution
                    │
                    ▼
             CustomerSolution ACTIVE
                    │
                    ▼
             Customer Runtime
```

### Architectural Dependency Direction
Customer Provisioning / Platform Core must not have direct upward dependencies on concrete higher-layer Business Solution, Customer Solution, Business Module, or Business Capability implementations. Platform Core may continue to depend on other Platform Core capabilities according to A-000/A-002. Customer Provisioning uses explicit boundaries (e.g. interfaces, commands) to orchestrate these higher layers.
```text
Marketplace / Business Solutions / Customer Solutions
        │
        │ Invoke Provisioning Contract
        ▼
Platform Core (Customer Provisioning Orchestrator)
```

---

## 23. Future Extension Points
Detailed architecture for the following remains outside A-008:
- Customer Runtime, Runtime Shell, Session management
- Dynamic navigation
- Runtime RBAC enforcement
- Organization-specific runtime behavior
- CustomerSolution upgrades
- Deployment infrastructure
- Detailed licensing, billing
- Authentication, full user provisioning
- Module-specific initialization contracts
- Production saga implementation
- Infrastructure deployment

---

## 24. Architecture Principles
This document aligns with CoreAxis principles:
- Single Source of Truth
- Separation of Responsibilities
- Reusability
- Multi-Tenant Isolation
- Explicit Ownership
- Version Traceability
- No duplication of domain ownership
- Platform/Core vs Business Module separation
- Technology-independent architecture
- Future extensibility
