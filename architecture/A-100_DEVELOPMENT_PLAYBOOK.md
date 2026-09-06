# A-100_DEVELOPMENT_PLAYBOOK.md

Version: 1.0

Status: Active

Classification: Engineering Playbook

---

# 1. Purpose

This document defines the engineering standards and day-to-day development practices for the CoreAxis ERP Platform.

It translates the architectural decisions defined in A-000 through A-005 into practical implementation guidelines.

This playbook applies to all contributors, including:

* Frontend Developers
* Backend Developers (Future)
* UI/UX Engineers
* QA Engineers
* AI Coding Assistants

---

# 2. Scope

This document governs:

* Project structure
* Development workflow
* Coding standards
* UI implementation
* Module implementation
* Mock data strategy
* Naming conventions
* Code reviews
* Quality standards

It does not redefine architecture.

---

# 3. Current Development Phase

Current Phase:

✅ UI-First Development

Current priorities:

* Flutter UI
* Mock repositories
* Mock data
* Responsive layouts
* UX validation
* Design consistency

Not in scope:

* Backend
* PostgreSQL
* REST APIs
* Authentication integration
* Business persistence

---

# 4. Development Principles

Every implementation should follow these principles:

* Reuse before creating
* Configuration before customization
* Composition before duplication
* Simplicity before complexity
* Consistency before creativity
* Architecture before implementation

---

# 5. Repository Structure

The project shall maintain a consistent folder structure.

Example:

```
lib/

core/
shared/
routing/
theme/
widgets/
services/

features/

platform/
business_modules/
business_solutions/

mock/

assets/

main.dart
```

Business Modules should never bypass the shared platform structure.

---

# 6. Feature Structure

Each feature should follow a consistent layout.

Example:

```
feature_name/

presentation/
widgets/
models/
mock/
controllers/
routes/
```

When backend development begins, additional folders such as repositories and data sources may be introduced without disrupting the UI layer.

---

# 7. UI Development Rules

Every new screen shall:

* Reuse existing layouts
* Reuse existing widgets
* Reuse typography
* Reuse spacing
* Reuse colors
* Reuse icons
* Reuse animations
* Support responsiveness

Avoid introducing one-off components when a reusable alternative exists.

---

# 8. Widget Reuse Policy

Before creating a new widget, verify:

* Does a similar widget already exist?
* Can the existing widget be extended?
* Can it be made configurable?
* Will another module benefit from it?

Only create new widgets when reuse is not practical.

---

# 9. Navigation Standards

All navigation shall use the centralized routing system.

Business Modules register routes through the platform.

Avoid hardcoded navigation paths within modules.

---

# 10. Mock Data Standards

Every Business Module shall include representative mock data.

Mock data should:

* Reflect realistic business scenarios
* Match future API contracts
* Cover common use cases
* Support UI demonstrations

Avoid placeholder values that do not resemble production data.

---

# 11. Screen Development Order

Develop screens in the following sequence where applicable:

1. Dashboard
2. List
3. Create
4. Edit
5. View
6. Search
7. Filters
8. Reports
9. Dialogs
10. Quick Actions

This promotes consistent user flows.

---

# 12. Naming Conventions

Use business terminology.

Examples:

Correct:

* Sales Order
* Purchase Order
* Production Order
* Quality Inspection

Avoid technical names for business concepts.

Examples:

Incorrect:

* SalesService
* InventoryDB
* PurchaseAPI

---

# 13. State Management

Until backend implementation:

* Use local state where appropriate.
* Keep state predictable.
* Separate UI state from mock data.
* Avoid coupling screens directly to future APIs.

State management should remain replaceable when backend integration begins.

---

# 14. AI-Assisted Development Rules

When using AI to generate code:

Always provide:

* Relevant architecture document(s)
* Module context
* Existing folder structure
* Existing design language
* Coding constraints

Never allow AI to:

* Invent architecture
* Redesign the UI
* Duplicate components
* Ignore naming conventions
* Introduce unrelated libraries without approval

---

# 15. Module Development Checklist

Before starting a module:

* Confirm Business Capability
* Confirm Business Module ownership
* Check for existing reusable components
* Review routing requirements
* Review navigation placement
* Define mock data
* Identify shared widgets
* Identify required platform services

---

# 16. Definition of Done (DoD)

A feature is considered complete when:

* UI is complete
* Responsive behavior is verified
* Mock data is implemented
* Navigation is integrated
* Existing design system is followed
* Code passes review
* No unnecessary duplication exists
* Documentation is updated if required

---

# 17. Code Review Checklist

Reviewers should verify:

* Architectural alignment
* Widget reuse
* Naming consistency
* Readability
* Modularity
* Responsive behavior
* Mock data quality
* No unnecessary complexity

---

# 18. Git Workflow

Recommended branch strategy:

* main
* develop
* feature/<module-name>
* bugfix/<issue-name>

Merge only after review and successful validation.

---

# 19. Quality Principles

Every implementation should strive for:

* Maintainability
* Readability
* Reusability
* Simplicity
* Consistency
* Predictability

Technical debt should be minimized rather than deferred.

---

# 20. Future Backend Readiness

Frontend development should anticipate backend integration by:

* Keeping UI independent of persistence
* Using mock repositories with API-like contracts
* Avoiding backend-specific assumptions
* Preserving clear separation of concerns

This minimizes rework during Phase 6.

---

# 21. Relationship to Architecture Documents

This playbook implements the standards established in:

* A-000_COREAXIS_META_ARCHITECTURE
* A-001_MASTER_CONTEXT
* A-002_PLATFORM_CORE_ARCHITECTURE
* A-003_BUSINESS_CAPABILITY_ARCHITECTURE
* A-004_BUSINESS_MODULE_ARCHITECTURE
* A-005_BUSINESS_SOLUTION_ARCHITECTURE

This document defines *how* the team builds CoreAxis, while the A-000 to A-005 documents define *what* CoreAxis is.

---

# End of Document
