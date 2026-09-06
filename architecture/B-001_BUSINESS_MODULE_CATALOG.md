# B-001_BUSINESS_MODULE_CATALOG.md

Version: 1.0

Status: Active

Classification: Master Implementation Catalog

---

# 1. Purpose

The Business Module Catalog is the master inventory of all functional modules within the CoreAxis platform.

It serves as the primary implementation planning document for:

* Product Management
* UI Development
* Backend Development (Future)
* QA
* AI-Assisted Development

Every Business Module implemented in CoreAxis must exist in this catalog.

---

# 2. Objectives

The catalog provides:

* Complete module inventory
* Business Capability mapping
* Business Solution mapping
* Development status
* UI implementation scope
* Dependency tracking
* Implementation priority

This document is the single implementation roadmap for the platform.

---

# 3. Module Classification

Modules are classified into three categories.

| Classification  | Description                                              |
| --------------- | -------------------------------------------------------- |
| Platform Core   | Shared platform services used by every solution          |
| Business Module | Reusable business functionality shared across industries |
| Industry Module | Industry-specific functionality                          |

---

# 4. Development Lifecycle

Each module progresses through the following stages.

| Status              | Description                   |
| ------------------- | ----------------------------- |
| Planned             | Module identified             |
| Analysis            | Business analysis in progress |
| UI Design           | UX/UI planning                |
| UI Development      | Screen implementation         |
| UI Review           | Functional review             |
| UI Complete         | Frontend complete             |
| Backend Pending     | Waiting for Phase 6           |
| Backend Development | API implementation            |
| Testing             | Functional validation         |
| Released            | Production ready              |

---

# 5. Priority Levels

| Priority | Meaning                  |
| -------- | ------------------------ |
| Critical | Required for MVP         |
| High     | Required soon after MVP  |
| Medium   | Important but can follow |
| Low      | Future enhancement       |

---

# 6. Module Catalog

## 6.1 Platform Core

| Module                  | Classification | Capability | Furniture | Die Casting | Construction | Priority | Current Status |
| ----------------------- | -------------- | ---------- | --------- | ----------- | ------------ | -------- | -------------- |
| Tenant Management       | Platform Core  | Platform   | ✔         | ✔           | ✔            | Critical | UI Complete    |
| Organization Management | Platform Core  | Platform   | ✔         | ✔           | ✔            | Critical | UI Complete    |
| User Management         | Platform Core  | Platform   | ✔         | ✔           | ✔            | Critical | UI Complete    |
| RBAC                    | Platform Core  | Platform   | ✔         | ✔           | ✔            | Critical | UI Complete    |
| Workflow Engine         | Platform Core  | Platform   | ✔         | ✔           | ✔            | Critical | UI Complete    |
| Approval Engine         | Platform Core  | Platform   | ✔         | ✔           | ✔            | Critical | UI Complete    |
| Notification Engine     | Platform Core  | Platform   | ✔         | ✔           | ✔            | High     | UI Complete    |
| Document Engine         | Platform Core  | Platform   | ✔         | ✔           | ✔            | High     | UI Complete    |
| Reporting               | Platform Core  | Platform   | ✔         | ✔           | ✔            | High     | UI Complete    |
| AI Assistant            | Platform Core  | Platform   | ✔         | ✔           | ✔            | High     | UI Complete    |
| Pack Configuration      | Platform Core  | Platform   | ✔         | ✔           | ✔            | High     | UI Complete    |

---

## 6.2 Business Capabilities

> [!NOTE]
> All industry-specific modules (CRM, Sales, Procurement, Manufacturing, Finance, HR) have been removed from this CoreAxis Platform catalog. They now exist in their respective separate Business Solution codebases (e.g., FurniFlow ERP) and are dynamically published via the M1 Marketplace.
