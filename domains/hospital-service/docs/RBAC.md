# Hospital RBAC

Roles are tenant-scoped memberships. Authorization is evaluated from the database membership, never from client-supplied roles.

- superadmin: unrestricted tenant administration and domain access
- admin: tenant/users and operational hospital administration
- doctor: clinical read/write, patients, appointments
- nurse: patient/clinical read-write and appointment read
- accountant: billing and patient read
- receptionist: patient registration and appointment management
- patient: own/self-service resources only (self-service endpoints must enforce ownership)

All resource queries require the authenticated tenant context. PostgreSQL RLS is a second isolation boundary.

## v1.1 hospital permission matrix

- superadmin: all permissions
- admin: tenant/users, patients, departments, staff, beds, admissions, clinical, prescriptions, lab, radiology, billing, insurance, discharge
- doctor: patients, clinical, appointments, prescriptions, lab, radiology, admissions, discharge, limited billing/insurance read
- nurse: patients, clinical, appointments read, admissions, beds, prescriptions read, lab/radiology read
- accountant: patients read, billing, insurance
- receptionist: patients, appointments, departments read, admissions, beds read
- patient: own patient profile, own appointments/clinical/prescriptions/lab/radiology/billing via self-scoped endpoints
