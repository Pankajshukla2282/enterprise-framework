-- EMTAF Hospital Specialty Clinics
CREATE TABLE IF NOT EXISTS hospital_skin_consultations(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), tenant_id uuid NOT NULL REFERENCES tenants(id),
 patient_id uuid NOT NULL REFERENCES hospital_patients(id), provider_user_id uuid REFERENCES users(id),
 skin_type text, concerns text, assessment text, diagnosis text, allergies text, treatment_plan text,
 status text NOT NULL DEFAULT 'open', created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS hospital_skin_treatments(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), tenant_id uuid NOT NULL REFERENCES tenants(id),
 patient_id uuid NOT NULL REFERENCES hospital_patients(id), consultation_id uuid REFERENCES hospital_skin_consultations(id),
 treatment_name text NOT NULL, treatment_area text, product_or_device text, sessions_planned int NOT NULL DEFAULT 1,
 sessions_completed int NOT NULL DEFAULT 0, notes text, status text NOT NULL DEFAULT 'planned',
 started_at timestamptz, completed_at timestamptz, created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS hospital_eecp_programs(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), tenant_id uuid NOT NULL REFERENCES tenants(id),
 patient_id uuid NOT NULL REFERENCES hospital_patients(id), cardiologist_user_id uuid REFERENCES users(id),
 indication text, baseline_assessment text, planned_sessions int NOT NULL DEFAULT 35, sessions_completed int NOT NULL DEFAULT 0,
 treatment_notes text, status text NOT NULL DEFAULT 'planned', start_date date, end_date date,
 created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS hospital_eecp_sessions(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), tenant_id uuid NOT NULL REFERENCES tenants(id),
 program_id uuid NOT NULL REFERENCES hospital_eecp_programs(id), patient_id uuid NOT NULL REFERENCES hospital_patients(id),
 session_no int NOT NULL, therapist_user_id uuid REFERENCES users(id), duration_minutes int,
 pre_systolic_bp text, pre_diastolic_bp text, pre_hr int, post_systolic_bp text, post_diastolic_bp text, post_hr int,
 tolerance text, notes text, status text NOT NULL DEFAULT 'scheduled', session_date timestamptz,
 created_at timestamptz NOT NULL DEFAULT now(), UNIQUE(tenant_id,program_id,session_no)
);
CREATE TABLE IF NOT EXISTS hospital_physio_assessments(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), tenant_id uuid NOT NULL REFERENCES tenants(id),
 patient_id uuid NOT NULL REFERENCES hospital_patients(id), therapist_user_id uuid REFERENCES users(id),
 diagnosis text, pain_score numeric(4,1), mobility_findings text, strength_findings text, functional_goals text,
 precautions text, plan text, status text NOT NULL DEFAULT 'active', created_at timestamptz NOT NULL DEFAULT now(),
 updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS hospital_physio_sessions(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), tenant_id uuid NOT NULL REFERENCES tenants(id),
 patient_id uuid NOT NULL REFERENCES hospital_patients(id), assessment_id uuid REFERENCES hospital_physio_assessments(id),
 therapist_user_id uuid REFERENCES users(id), session_date timestamptz, session_type text, exercises text, modalities text,
 pain_before numeric(4,1), pain_after numeric(4,1), response text, home_program text,
 status text NOT NULL DEFAULT 'scheduled', notes text, created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_hospital_skin_tenant_patient ON hospital_skin_consultations(tenant_id,patient_id);
CREATE INDEX IF NOT EXISTS idx_hospital_skin_treatment_tenant_patient ON hospital_skin_treatments(tenant_id,patient_id);
CREATE INDEX IF NOT EXISTS idx_hospital_eecp_program_tenant_patient ON hospital_eecp_programs(tenant_id,patient_id);
CREATE INDEX IF NOT EXISTS idx_hospital_eecp_session_tenant_patient ON hospital_eecp_sessions(tenant_id,patient_id);
CREATE INDEX IF NOT EXISTS idx_hospital_physio_assessment_tenant_patient ON hospital_physio_assessments(tenant_id,patient_id);
CREATE INDEX IF NOT EXISTS idx_hospital_physio_session_tenant_patient ON hospital_physio_sessions(tenant_id,patient_id);
