# U-001_UI_SCREEN_CATALOG.md

Version: 1.0

Status: Active

Classification: UI Master Index

---

# 1. Purpose

The UI Screen Catalog is the master inventory of every user interface screen within the CoreAxis platform.

It is the authoritative index for all UI implementation work.

Every screen in CoreAxis shall:

* Have a unique Screen ID.
* Belong to exactly one Business Module.
* Belong to one primary Business Capability.
* Reference an individual Screen Specification document.
* Be traceable to future routes, permissions, APIs, database entities, and test cases.

This document intentionally contains only the catalog and summary information.

Detailed implementation is maintained in individual Screen Specification documents.

---

# 2. Screen ID Standard

Every screen receives a permanent identifier.

Format:

SCR-<AREA>-<NUMBER>

Examples:

SCR-PLT-001

SCR-CRM-014

SCR-SAL-027

SCR-PRC-018

SCR-INV-041

SCR-MFG-063

SCR-FIN-012

SCR-HRM-009

SCR-PRJ-005

SCR-FUR-011

SCR-DIE-008

SCR-CON-022

Screen IDs never change once assigned.

---

# 3. Screen Categories

Each screen belongs to one category.

| Category      | Description                 |
| ------------- | --------------------------- |
| Dashboard     | Overview and KPIs           |
| List          | Searchable data listing     |
| Create        | New record entry            |
| Edit          | Modify existing record      |
| View          | Read-only details           |
| Wizard        | Multi-step process          |
| Approval      | Approval actions            |
| Report        | Printable/reporting screens |
| Analytics     | Charts and trends           |
| Configuration | Module settings             |
| Popup         | Modal dialog                |
| Drawer        | Side panel                  |

---

# 4. Screen Status

| Status         | Description                    |
| -------------- | ------------------------------ |
| Planned        | Not started                    |
| UX Design      | Under design                   |
| UI Development | Being implemented              |
| UI Review      | Functional review              |
| UI Complete    | Ready for frontend freeze      |
| Frozen         | Locked for backend integration |

---

# 5. Master Screen Catalog

## Platform Core

| Screen ID   | Screen Name      | Module            | Type      | Status   |
| ----------- | ---------------- | ----------------- | --------- | -------- |
| SCR-PLT-001 | Tenant Dashboard | Tenant Management | Dashboard | Complete |
| SCR-PLT-002 | Tenant List      | Tenant Management | List      | Complete |
| SCR-PLT-003 | Create Tenant    | Tenant Management | Create    | Complete |
| SCR-PLT-004 | Edit Tenant      | Tenant Management | Edit      | Complete |
| SCR-PLT-005 | Tenant Details   | Tenant Management | View      | Complete |

---

## CRM

| Screen ID   | Screen Name    | Module          | Type      | Status  |
| ----------- | -------------- | --------------- | --------- | ------- |
| SCR-CRM-001 | Lead Dashboard | Lead Management | Dashboard | Planned |
| SCR-CRM-002 | Lead List      | Lead Management | List      | Planned |
| SCR-CRM-003 | Create Lead    | Lead Management | Create    | Planned |
| SCR-CRM-004 | Lead Details   | Lead Management | View      | Planned |

---

## Sales

| Screen ID   | Screen Name      | Module      | Type      | Status  |
| ----------- | ---------------- | ----------- | --------- | ------- |
| SCR-SAL-001 | Sales Dashboard  | Sales       | Dashboard | Planned |
| SCR-SAL-002 | Quotation List   | Quotation   | List      | Planned |
| SCR-SAL-003 | Create Quotation | Quotation   | Create    | Planned |
| SCR-SAL-004 | Sales Order List | Sales Order | List      | Planned |

---

## Procurement

| Screen ID   | Screen Name           | Module            | Type | Status  |
| ----------- | --------------------- | ----------------- | ---- | ------- |
| SCR-PRC-001 | Vendor List           | Vendor Management | List | Planned |
| SCR-PRC-002 | Purchase Request List | Purchase Request  | List | Planned |
| SCR-PRC-003 | Purchase Order List   | Purchase Order    | List | Planned |

---

## Inventory

| Screen ID   | Screen Name    | Module      | Type      | Status  |
| ----------- | -------------- | ----------- | --------- | ------- |
| SCR-INV-001 | Item Dashboard | Item Master | Dashboard | Planned |
| SCR-INV-002 | Item List      | Item Master | List      | Planned |
| SCR-INV-003 | Warehouse List | Warehouse   | List      | Planned |

---

## Manufacturing

| Screen ID   | Screen Name                | Module             | Type      | Status  |
| ----------- | -------------------------- | ------------------ | --------- | ------- |
| SCR-MFG-001 | Product Dashboard          | Product Management | Dashboard | Planned |
| SCR-MFG-002 | BOM List                   | Bill of Materials  | List      | Planned |
| SCR-MFG-003 | Production Order Dashboard | Production Order   | Dashboard | Planned |

---

## Furniture Manufacturing

| Screen ID   | Screen Name       | Module            | Type      | Status  |
| ----------- | ----------------- | ----------------- | --------- | ------- |
| SCR-FUR-001 | Furniture Catalog | Furniture Catalog | List      | Planned |
| SCR-FUR-002 | Cutting Plan      | Cutting Plan      | Dashboard | Planned |

---

## Die Casting

| Screen ID   | Screen Name   | Module         | Type      | Status  |
| ----------- | ------------- | -------------- | --------- | ------- |
| SCR-DIE-001 | Die Dashboard | Die Management | Dashboard | Planned |
| SCR-DIE-002 | Die Register  | Die Management | List      | Planned |

---

## Construction

| Screen ID   | Screen Name       | Module             | Type      | Status  |
| ----------- | ----------------- | ------------------ | --------- | ------- |
| SCR-CON-001 | Project Dashboard | Project Management | Dashboard | Planned |
| SCR-CON-002 | BOQ List          | BOQ Management     | List      | Planned |

---

# 6. Individual Screen Specifications

Every screen listed in this catalog shall have its own specification.

Naming convention:

U-101_SCR-PLT-001_TENANT_DASHBOARD.md

U-102_SCR-PLT-002_TENANT_LIST.md

U-103_SCR-PLT-003_CREATE_TENANT.md

...

Each specification becomes the implementation contract for one screen.

---

# 7. Traceability

Every Screen Specification shall reference:

* Business Capability
* Business Module
* Navigation Node
* Route
* Required Permissions
* Reusable Widgets
* Mock Data Source
* Future APIs
* Future Database Entities
* Test Cases

This provides complete traceability from architecture through implementation.

---

# 8. Relationship to Other Documents

This document is the parent index for:

* U-101+ Screen Specifications
* U-200 Navigation Registry
* U-300 Route Registry
* U-400 Widget Catalog
* D-001 Development Roadmap
* T-001 Test Catalog

No UI implementation should begin without a corresponding Screen Specification.

---

# End of Document
