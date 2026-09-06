# COREAXIS CLEAN FOUNDATION FREEZE

## 1. Purpose

This document establishes the formal, stable baseline for the CoreAxis platform architecture. This freeze follows the successful completion of the codebase audit, formal approval of the cleanup matrix, the physical removal of legacy/demo/optional features, and the final comprehensive M1–M9 regression verification. This document acts as the definitive contract for the platform's state before beginning any external ERP integration.

## 2. Platform Mission

CoreAxis is a common multi-product, multi-customer ERP platform. It is designed solely to orchestrate, provision, and manage independent industry-specific Business Solutions. CoreAxis itself is **not** a Furniture ERP, Die Casting ERP, or any other vertical product.

## 3. Frozen Architecture

The following operational sequence is frozen:

Platform Core
→ Marketplace
→ Blueprint
→ Composer
→ Solution Management
→ SolutionDefinition
→ Customer Provisioning
→ CustomerSolution
→ Tenant Runtime

## 4. Frozen Capabilities

The following constitute the mandatory and frozen CoreAxis capabilities:

- **Tenant**: Tenant management and hard isolation.
- **Organization**: Organization management and tenant-scoped isolation.
- **Identity**: Authentication and Platform user management.
- **RBAC**: Roles, Permissions, Permission Groups, Permission Matrix, User Role Assignment, and Runtime enforcement.
- **Marketplace**: Business Module metadata, catalog, module lifecycle, dependencies, version compatibility, and publishing.
- **Blueprint**: Solution Blueprint generation, exact module version referencing (MarketplaceModuleReference), configuration composition, and dependency handling.
- **Solution Composition**: Blueprint mapping to SolutionModuleConfiguration.
- **Solution Management**: Management and lifecycle of the immutable `SolutionDefinition`.
- **Customer Solution**: Tenant-associated `CustomerSolution`, snapshot configuration, and traceability.
- **Customer Provisioning**: Orchestration of tenant/org creation, solution assignment, entitlement validation, configuration resolution, and activation (idempotent with compensation).
- **Runtime**: Tenant Runtime, isolated RuntimeContext, authorized module consumption.
- **Effective Configuration**: Recursive deep immutability, `CustomerSolutionConfigurationResolver`, and pure consumption by the Tenant Runtime.

## 5. Tenant / Organization Model

- **Tenant**: The absolute top-level hard isolation boundary for a customer.
- **Organization**: The logical/business sub-structure operating strictly within a single Tenant.
- **CustomerSolution**: A localized, tenant-specific deployed instance of an overarching Business Solution / product.

## 6. Effective Configuration

The authoritative configuration pipeline is strictly one-way:

Blueprint Defaults
→ CustomerSolution Configuration
→ EffectiveRuntimeConfigurationSnapshot
→ Runtime

**Ownership Model:**
- **M7 (CustomerSolution)**: Resolves and builds the snapshot.
- **M8 (Provisioning)**: Orchestrates the resolution.
- **M9 (Runtime)**: Strictly consumes the snapshot.

## 7. Database Boundary

The platform database boundary is strictly delineated:
- **CoreAxis** → `coreaxis`
- **Furniture ERP** → `furniflow`

CoreAxis code does not and must not directly depend on or interface with `furniflow` tables. They remain entirely separate.

## 8. Removed Scope

To achieve this clean foundation, the following non-mandatory, legacy, duplicate, or mock areas were deliberately removed and will not be restored:
- Workspace Manager
- Duplicate Platform Module Catalog
- Mock Platform Dashboard
- Platform Settings mock
- Permission Simulator
- Access Policies
- Product Roadmap, What's New, Release Showcase, System Status placeholders
- Legacy Furniture ERP and Industry Pack implementations
- Obsolete ERP navigation shells and duplicate role/user mockups

## 9. Frozen Navigation Principle

The UI navigation architecture strictly separates platform governance from business operations:
- **Platform Administration**: Contains exclusively the functionality required to govern, provision, and maintain the CoreAxis platform (e.g., Tenants, Organizations, Identity, RBAC, Marketplace, Blueprints).
- **Tenant Runtime**: Contains exclusively the operational Business ERP navigation (e.g., Sales, Inventory, Production). Furniture modules do not belong in Platform Administration.

## 10. Regression

The final post-cleanup validation is complete.

- **STATUS**: M1–M9 FINAL REGRESSION PASSED
- **FULL TEST SUITE**: PASS WITH PRE-EXISTING UNRELATED FAILURE (Known networking mock isolation issue in `api_client_test.dart`).

## 11. Integration Boundary

The Furniture ERP remains a separate, fully functioning legacy product with its own frontend, backend, REST API, and PostgreSQL database. Its internal business logic has not been moved into CoreAxis. Integration of the Furniture ERP into the CoreAxis ecosystem is the explicit focus of the next architectural phase.

## 12. Next Phase

STEP 6 — FURNITURE ERP INTEGRATION ARCHITECTURE
