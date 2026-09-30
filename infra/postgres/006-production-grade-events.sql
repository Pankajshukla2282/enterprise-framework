ALTER TABLE platform_idempotency ADD COLUMN IF NOT EXISTS processing_expires_at timestamptz;
ALTER TABLE platform_outbox ADD COLUMN IF NOT EXISTS locked_at timestamptz;
ALTER TABLE platform_outbox ADD COLUMN IF NOT EXISTS locked_by text;
CREATE INDEX IF NOT EXISTS idx_outbox_claim ON platform_outbox(published_at, next_attempt_at, locked_at, created_at) WHERE published_at IS NULL;

CREATE TABLE IF NOT EXISTS platform_consumed_events (
  consumer_group text NOT NULL,
  event_id uuid NOT NULL,
  tenant_id uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  consumed_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (consumer_group,event_id)
);
CREATE INDEX IF NOT EXISTS idx_consumed_events_tenant ON platform_consumed_events(tenant_id,consumed_at DESC);
ALTER TABLE platform_consumed_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE platform_consumed_events FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS tenant_isolation ON platform_consumed_events;
CREATE POLICY tenant_isolation ON platform_consumed_events USING (tenant_id=current_setting('app.tenant_id',true)::uuid) WITH CHECK (tenant_id=current_setting('app.tenant_id',true)::uuid);

CREATE OR REPLACE FUNCTION platform_domain_outbox_trigger() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE rid text; tid uuid;
BEGIN
  IF TG_OP='DELETE' THEN rid:=OLD.id::text; tid:=OLD.tenant_id;
  ELSE rid:=NEW.id::text; tid:=NEW.tenant_id;
  END IF;
  INSERT INTO platform_outbox(tenant_id,topic,event_type,aggregate_id,payload,headers)
  VALUES(
    tid,
    split_part(TG_TABLE_NAME,'_',1)||'.domain.v1',
    lower(TG_TABLE_NAME)||'.'||lower(TG_OP),
    rid,
    jsonb_build_object('id',rid,'table',TG_TABLE_NAME,'operation',TG_OP),
    jsonb_build_object('source','postgres-trigger','tenantId',tid::text)
  );
  RETURN COALESCE(NEW,OLD);
END $$;

DO $$ DECLARE t text; BEGIN
  FOREACH t IN ARRAY ARRAY[
    'hospital_patients','hospital_staff','hospital_appointments','hospital_encounters','hospital_admissions','hospital_billing','hospital_departments','hospital_wards','hospital_beds','hospital_prescriptions','hospital_lab_orders','hospital_radiology_orders','hospital_insurance_policies','hospital_invoice_items','hospital_payments','hospital_discharge_summaries',
    'school_students','school_teachers','school_classes','school_enrollments','school_attendance',
    'college_students','college_faculty','college_departments','college_courses','college_enrollments','college_attendance','college_fees','college_exams','college_exam_results',
    'hotel_guests','hotel_room_types','hotel_rooms','hotel_bookings','hotel_payments','hotel_housekeeping',
    'realestate_properties','realestate_units','realestate_listings','realestate_leads','realestate_viewings','realestate_offers','realestate_leases','realestate_payments'
  ] LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS trg_%s_outbox ON %I',t,t);
    EXECUTE format('CREATE TRIGGER trg_%s_outbox AFTER INSERT OR UPDATE OR DELETE ON %I FOR EACH ROW EXECUTE FUNCTION platform_domain_outbox_trigger()',t,t);
  END LOOP;
END $$;

-- Remove stale processing records only after their lease expires; application retries can safely reclaim them.
CREATE OR REPLACE FUNCTION platform_cleanup_idempotency() RETURNS integer LANGUAGE plpgsql AS $$
DECLARE n integer;
BEGIN
  DELETE FROM platform_idempotency WHERE status='processing' AND processing_expires_at < now() - interval '5 minutes';
  GET DIAGNOSTICS n=ROW_COUNT; RETURN n;
END $$;
