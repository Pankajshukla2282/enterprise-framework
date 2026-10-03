-- EMTAF specialty-clinic demo data (skin / eecp / physio).
-- Safe to execute multiple times. Depends on scripts/seed/seed-all.sql
-- (tenants, users, tenant_memberships, hospital patient MRN-1001).
-- Business keys (specialty, package code, invoice number, reason/concerns
-- text) are used for idempotency; no generated IDs are relied on.
BEGIN;

-- ---------------------------------------------------------------------------
-- Clinic registry
-- ---------------------------------------------------------------------------
INSERT INTO hospital_specialty_clinics(tenant_id,specialty,name,status)
SELECT t.id,x.specialty,x.name,'active'
FROM (SELECT id FROM tenants WHERE code='demo-hospital') t
CROSS JOIN (VALUES
 ('skin','Skin & Cosmetic Clinic'),
 ('eecp','Cardiac EECP Therapy'),
 ('physio','Physiotherapy Clinic')
) AS x(specialty,name)
ON CONFLICT(tenant_id,specialty) DO UPDATE SET name=EXCLUDED.name,status='active';

-- ---------------------------------------------------------------------------
-- Billing packages
-- ---------------------------------------------------------------------------
INSERT INTO hospital_specialty_billing_packages(tenant_id,specialty,code,name,description,sessions,price)
SELECT t.id,x.specialty,x.code,x.name,x.description,x.sessions,x.price
FROM (SELECT id FROM tenants WHERE code='demo-hospital') t
CROSS JOIN (VALUES
 ('skin','SKIN-GLOW-05','Glow Signature Program','5-session signature facial program',5,12500),
 ('skin','SKIN-LASER-03','Laser Rejuvenation Course','3-session laser rejuvenation course',3,21000),
 ('eecp','EECP-35','EECP Standard 35-Session Course','Full 35-session cardiac EECP course',35,95000),
 ('eecp','EECP-15','EECP Evaluation 15-Session Pack','15-session cardiac evaluation pack',15,45000),
 ('physio','PHYSIO-10','Rehab 10-Session Pack','10-session musculoskeletal rehab pack',10,8000),
 ('physio','PHYSIO-POSTOP','Post-op Rehab Program','12-session post-operative rehab program',12,15000)
) AS x(specialty,code,name,description,sessions,price)
ON CONFLICT(tenant_id,specialty,code) DO UPDATE SET name=EXCLUDED.name,description=EXCLUDED.description,sessions=EXCLUDED.sessions,price=EXCLUDED.price,active=true;

-- ---------------------------------------------------------------------------
-- Specialty appointments (one upcoming demo appointment per clinic)
-- ---------------------------------------------------------------------------
WITH t AS (SELECT id FROM tenants WHERE code='demo-hospital'),
p AS (SELECT id FROM hospital_patients WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-hospital') AND mrn='MRN-1001'),
d AS (SELECT id FROM users WHERE email='hospital.doctor@demo.local')
INSERT INTO hospital_specialty_appointments(tenant_id,specialty,patient_id,provider_user_id,starts_at,ends_at,appointment_type,reason,status)
SELECT t.id,x.specialty,p.id,d.id,date_trunc('hour',now()+x.delta),date_trunc('hour',now()+x.delta)+interval '30 minutes',x.apptype,x.reason,'confirmed'
FROM t,p,d
CROSS JOIN (VALUES
 ('skin','1 day'::interval,'consultation','Demo skin consultation'),
 ('eecp','2 days'::interval,'evaluation','Demo cardiac evaluation'),
 ('physio','3 days'::interval,'assessment','Demo physio assessment')
) AS x(specialty,delta,apptype,reason)
WHERE NOT EXISTS (
 SELECT 1 FROM hospital_specialty_appointments a
 WHERE a.tenant_id=t.id AND a.patient_id=p.id AND a.specialty=x.specialty AND a.reason=x.reason
);

-- ---------------------------------------------------------------------------
-- Skin: consultation + treatment
-- ---------------------------------------------------------------------------
WITH t AS (SELECT id FROM tenants WHERE code='demo-hospital'),
p AS (SELECT id FROM hospital_patients WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-hospital') AND mrn='MRN-1001'),
d AS (SELECT id FROM users WHERE email='hospital.doctor@demo.local')
INSERT INTO hospital_skin_consultations(tenant_id,patient_id,provider_user_id,skin_type,concerns,assessment,diagnosis,treatment_plan,status)
SELECT t.id,p.id,d.id,'combination','Demo: uneven tone and early fine lines','Demo assessment recorded at seed time','Mild photoaging','Glow Signature Program (5 sessions)','open'
FROM t,p,d
WHERE NOT EXISTS (
 SELECT 1 FROM hospital_skin_consultations c
 WHERE c.tenant_id=t.id AND c.patient_id=p.id AND c.concerns='Demo: uneven tone and early fine lines'
);

WITH t AS (SELECT id FROM tenants WHERE code='demo-hospital'),
p AS (SELECT id FROM hospital_patients WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-hospital') AND mrn='MRN-1001'),
c AS (SELECT id FROM hospital_skin_consultations WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-hospital') AND patient_id=(SELECT id FROM hospital_patients WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-hospital') AND mrn='MRN-1001') AND concerns='Demo: uneven tone and early fine lines')
INSERT INTO hospital_skin_treatments(tenant_id,patient_id,consultation_id,treatment_name,treatment_area,product_or_device,sessions_planned,sessions_completed,status)
SELECT t.id,p.id,c.id,'Signature Glow Facial','face','Demo derma device',5,1,'in-progress'
FROM t,p,c
WHERE NOT EXISTS (
 SELECT 1 FROM hospital_skin_treatments tr
 WHERE tr.tenant_id=t.id AND tr.patient_id=p.id AND tr.treatment_name='Signature Glow Facial'
);

-- ---------------------------------------------------------------------------
-- EECP: program + sessions
-- ---------------------------------------------------------------------------
WITH t AS (SELECT id FROM tenants WHERE code='demo-hospital'),
p AS (SELECT id FROM hospital_patients WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-hospital') AND mrn='MRN-1001'),
d AS (SELECT id FROM users WHERE email='hospital.doctor@demo.local')
INSERT INTO hospital_eecp_programs(tenant_id,patient_id,cardiologist_user_id,indication,baseline_assessment,planned_sessions,sessions_completed,treatment_notes,status,start_date)
SELECT t.id,p.id,d.id,'Demo: stable angina, CCS class II','Demo baseline recorded at seed time',35,2,'Tolerating therapy well','active',CURRENT_DATE - interval '2 weeks'
FROM t,p,d
WHERE NOT EXISTS (
 SELECT 1 FROM hospital_eecp_programs g
 WHERE g.tenant_id=t.id AND g.patient_id=p.id AND g.indication='Demo: stable angina, CCS class II'
);

WITH t AS (SELECT id FROM tenants WHERE code='demo-hospital'),
g AS (SELECT id,patient_id FROM hospital_eecp_programs WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-hospital') AND indication='Demo: stable angina, CCS class II'),
d AS (SELECT id FROM users WHERE email='hospital.doctor@demo.local')
INSERT INTO hospital_eecp_sessions(tenant_id,program_id,patient_id,session_no,therapist_user_id,duration_minutes,pre_systolic_bp,pre_diastolic_bp,pre_hr,tolerance,status,session_date)
SELECT t.id,g.id,g.patient_id,x.n,d.id,60,'128','82',72,'good','completed',now()-(3-x.n)*interval '2 days'
FROM t,g,d
CROSS JOIN (VALUES (1),(2)) AS x(n)
ON CONFLICT(tenant_id,program_id,session_no) DO NOTHING;

-- ---------------------------------------------------------------------------
-- Physio: assessment + sessions
-- ---------------------------------------------------------------------------
WITH t AS (SELECT id FROM tenants WHERE code='demo-hospital'),
p AS (SELECT id FROM hospital_patients WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-hospital') AND mrn='MRN-1001'),
d AS (SELECT id FROM users WHERE email='hospital.doctor@demo.local')
INSERT INTO hospital_physio_assessments(tenant_id,patient_id,therapist_user_id,diagnosis,pain_score,functional_goals,plan,status)
SELECT t.id,p.id,d.id,'Demo: mechanical low back pain',6.5,'Sit-stand without pain for 30 minutes','Core stabilization, 10 sessions','active'
FROM t,p,d
WHERE NOT EXISTS (
 SELECT 1 FROM hospital_physio_assessments a
 WHERE a.tenant_id=t.id AND a.patient_id=p.id AND a.diagnosis='Demo: mechanical low back pain'
);

WITH t AS (SELECT id FROM tenants WHERE code='demo-hospital'),
a AS (SELECT id,patient_id FROM hospital_physio_assessments WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-hospital') AND diagnosis='Demo: mechanical low back pain'),
d AS (SELECT id FROM users WHERE email='hospital.doctor@demo.local')
INSERT INTO hospital_physio_sessions(tenant_id,patient_id,assessment_id,therapist_user_id,session_date,session_type,exercises,pain_before,pain_after,status)
SELECT t.id,a.patient_id,a.id,d.id,now()-interval '3 days','rehab','McKenzie extensions 3x10, core bracing 3x30s',6.5,4.0,'completed'
FROM t,a,d
WHERE NOT EXISTS (
 SELECT 1 FROM hospital_physio_sessions s
 WHERE s.tenant_id=t.id AND s.assessment_id=a.id AND s.session_type='rehab'
);

-- ---------------------------------------------------------------------------
-- Specialty invoices + patient portal profiles
-- ---------------------------------------------------------------------------
WITH t AS (SELECT id FROM tenants WHERE code='demo-hospital'),
p AS (SELECT id FROM hospital_patients WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-hospital') AND mrn='MRN-1001'),
k AS (SELECT id FROM hospital_specialty_billing_packages WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-hospital') AND specialty='eecp' AND code='EECP-35')
INSERT INTO hospital_specialty_invoices(tenant_id,specialty,patient_id,package_id,invoice_no,amount,status)
SELECT t.id,'eecp',p.id,k.id,'DEMO-EECP-0001',95000,'unpaid'
FROM t,p,k
WHERE NOT EXISTS (SELECT 1 FROM hospital_specialty_invoices i WHERE i.tenant_id=t.id AND i.invoice_no='DEMO-EECP-0001');

WITH t AS (SELECT id FROM tenants WHERE code='demo-hospital'),
p AS (SELECT id FROM hospital_patients WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-hospital') AND mrn='MRN-1001')
INSERT INTO hospital_specialty_portal_profiles(tenant_id,specialty,patient_id,preferences,consent_at)
SELECT t.id,x.specialty,p.id,'{}',now()
FROM t,p
CROSS JOIN (VALUES ('skin'),('eecp'),('physio')) AS x(specialty)
ON CONFLICT(tenant_id,specialty,patient_id) DO UPDATE SET consent_at=EXCLUDED.consent_at;

COMMIT;
