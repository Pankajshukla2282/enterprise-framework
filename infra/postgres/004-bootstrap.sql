-- Optional local bootstrap. Production identity provisioning should use tenant-service.
INSERT INTO tenants(code,name,status) VALUES ('demo-hospital','Demo Hospital','active') ON CONFLICT(code) DO NOTHING;
INSERT INTO users(email,display_name,status) VALUES ('superadmin@example.local','Platform Super Admin','active') ON CONFLICT(email) DO NOTHING;
INSERT INTO tenant_memberships(tenant_id,user_id,roles)
SELECT t.id,u.id,ARRAY['superadmin'] FROM tenants t,users u WHERE t.code='demo-hospital' AND u.email='superadmin@example.local'
ON CONFLICT(tenant_id,user_id) DO UPDATE SET roles=excluded.roles,status='active';
