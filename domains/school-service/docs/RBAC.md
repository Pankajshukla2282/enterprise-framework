# School RBAC

Tenant-scoped roles: superadmin, admin, teacher, accountant, receptionist, student, parent. Authorization is evaluated against tenant_memberships and domain permissions. All domain rows carry tenant_id and are protected by PostgreSQL RLS.
