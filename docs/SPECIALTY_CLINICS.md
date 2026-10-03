# EMTAF Hospital Specialty Clinics

EMTAF hospital-service now includes three tenant-scoped specialty workflows sharing the hospital patient registry:

- **Skin & Cosmetics** — consultations and treatment plans/session tracking.
- **Cardiac EECP** — programs and treatment sessions with pre/post observations.
- **Physiotherapy** — functional assessments and therapy sessions.

Each specialty has its own independent web application:

| Site | Local port | Backend |
|---|---:|---|
| Skin & Cosmetic Clinic | 3006 | hospital-service |
| Cardiac EECP Therapy | 3007 | hospital-service |
| Physiotherapy Clinic | 3008 | hospital-service |

The specialty sites use the same JWT/tenant context and `clinical:read` / `clinical:write` permissions as the hospital clinical workflows. The backend remains the enforcement point for authorization and tenant isolation.

> Clinical content is workflow/data-management support; treatment decisions remain with qualified clinicians.
