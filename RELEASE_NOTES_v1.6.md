# EMTAF SaaS v1.6

Completed all remaining original domains and added Real Estate.

- College expanded from student CRUD to faculty, departments, courses, enrollments, attendance, fees, exams and results.
- Hotel expanded from guest CRUD to room types, rooms, bookings, check-in/out, payments and housekeeping.
- Real Estate added as a fifth independently deployable domain.
- PostgreSQL migrations and RLS expanded for all new tables.
- Kubernetes base/overlays and Helm configuration expanded for Real Estate.
- All domains consume the shared EMTAF core for authentication, tenant context, RBAC, audit and events.
