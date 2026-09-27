# College RBAC

Tenant-scoped roles: superadmin, admin, faculty, accountant, receptionist, student. Authorization is evaluated against tenant_memberships and domain permissions. All domain rows carry tenant_id and are protected by PostgreSQL RLS.
