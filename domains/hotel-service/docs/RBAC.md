# Hotel RBAC

Tenant-scoped roles: superadmin, admin, manager, receptionist, housekeeping, accountant, guest. Authorization is evaluated against tenant_memberships and domain permissions. All domain rows carry tenant_id and are protected by PostgreSQL RLS.
