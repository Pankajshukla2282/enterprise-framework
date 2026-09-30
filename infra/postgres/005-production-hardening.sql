CREATE TABLE IF NOT EXISTS platform_idempotency (
  tenant_id uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  key text NOT NULL,
  request_hash text NOT NULL,
  status text NOT NULL CHECK (status IN ('processing','completed')),
  status_code integer,
  response_body jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  completed_at timestamptz,
  PRIMARY KEY (tenant_id,key)
);
CREATE INDEX IF NOT EXISTS idx_idempotency_created ON platform_idempotency(created_at);

CREATE TABLE IF NOT EXISTS platform_outbox (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  topic text NOT NULL,
  event_type text NOT NULL,
  aggregate_id text,
  payload jsonb NOT NULL,
  headers jsonb NOT NULL DEFAULT '{}',
  attempts integer NOT NULL DEFAULT 0,
  next_attempt_at timestamptz,
  last_error text,
  created_at timestamptz NOT NULL DEFAULT now(),
  published_at timestamptz
);
CREATE INDEX IF NOT EXISTS idx_outbox_pending ON platform_outbox(published_at,next_attempt_at,created_at) WHERE published_at IS NULL;
ALTER TABLE platform_outbox ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS tenant_isolation ON platform_outbox;
CREATE POLICY tenant_isolation ON platform_outbox USING (tenant_id=current_setting('app.tenant_id',true)::uuid) WITH CHECK (tenant_id=current_setting('app.tenant_id',true)::uuid);
ALTER TABLE platform_idempotency ENABLE ROW LEVEL SECURITY;
ALTER TABLE platform_idempotency FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS tenant_isolation ON platform_idempotency;
CREATE POLICY tenant_isolation ON platform_idempotency USING (tenant_id=current_setting('app.tenant_id',true)::uuid) WITH CHECK (tenant_id=current_setting('app.tenant_id',true)::uuid);

CREATE TABLE IF NOT EXISTS platform_backup_runs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), started_at timestamptz NOT NULL DEFAULT now(), completed_at timestamptz,
  artifact text, checksum text, status text NOT NULL DEFAULT 'running', error text
);
