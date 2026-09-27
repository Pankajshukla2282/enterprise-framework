DO $$ DECLARE r record; BEGIN
FOR r IN SELECT unnest(ARRAY['hospital_patients','hospital_staff','hospital_appointments','hospital_encounters','hospital_admissions','hospital_billing','hospital_departments','hospital_wards','hospital_beds','hospital_prescriptions','hospital_lab_orders','hospital_radiology_orders','hospital_insurance_policies','hospital_invoice_items','hospital_payments','hospital_discharge_summaries','school_students','school_teachers','school_classes','school_enrollments','school_attendance','college_students','hotel_guests']) table_name LOOP
  EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', r.table_name);
  EXECUTE format('DROP POLICY IF EXISTS tenant_isolation ON %I', r.table_name);
  EXECUTE format('CREATE POLICY tenant_isolation ON %I USING (tenant_id = current_setting(''app.tenant_id'', true)::uuid) WITH CHECK (tenant_id = current_setting(''app.tenant_id'', true)::uuid)', r.table_name);
END LOOP; END $$;
ALTER TABLE platform_audit ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS tenant_isolation ON platform_audit;
CREATE POLICY tenant_isolation ON platform_audit USING (tenant_id=current_setting('app.tenant_id',true)::uuid) WITH CHECK (tenant_id=current_setting('app.tenant_id',true)::uuid);
