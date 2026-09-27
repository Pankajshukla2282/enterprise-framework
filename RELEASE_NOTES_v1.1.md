# EMTAF SaaS v1.1 — Hospital Reference Domain

This release extends the Kubernetes-only multi-tenant EMTAF platform with a substantially broader Hospital reference application.

## Hospital modules
- patient registration and tenant-scoped patient records
- patient self-profile linkage and self-service clinical result endpoints
- departments and hospital staff
- appointments and cancellation
- encounters and clinical closure
- wards and beds with assignment/release
- admissions and discharge
- discharge summaries
- prescriptions
- laboratory orders and results
- radiology orders and reports
- insurance policies
- invoices, invoice items and payments
- operational dashboard
- domain events and audit records

## Multi-tenancy
Every hospital record remains tenant-scoped. PostgreSQL RLS now covers the new hospital tables as well as the existing platform/domain tables.

## RBAC
Hospital permissions are mapped through the core tenant membership context. Roles include superadmin, admin, doctor, nurse, accountant, receptionist and patient. Patient self-service routes resolve the patient profile through the authenticated user's tenant membership and linked patient user_id.

## Kubernetes
No Docker Compose is included. Database migrations are executed by the Kubernetes migration Job and now run domain migrations before enabling RLS, ensuring the new tables exist when policies are created.
