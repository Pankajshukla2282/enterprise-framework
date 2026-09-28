# EMTAF Real Estate Service v1.6

Tenant-scoped property management domain with independently deployable Kubernetes/Helm artifacts.

## Modules
- Properties and units
- Listings
- Leads and agents
- Viewings
- Offers
- Leases
- Lease payments
- Dashboard/reporting

## Roles
- realestateadmin
- agent
- property_manager
- realestate_accountant
- buyer
- tenant

All persistence uses tenant_id and PostgreSQL RLS. Events publish to `realestate.domain.v1`.
