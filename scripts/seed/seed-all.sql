-- EMTAF deterministic, repeatable demo data.
-- Safe to execute multiple times. No generated IDs are relied on for idempotency;
-- business keys (tenant code, user email, MRN/admission number, room/property codes, etc.) are.
BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ---------------------------------------------------------------------------
-- Platform tenants and demo users
-- ---------------------------------------------------------------------------
INSERT INTO tenants(code,name,domain,status) VALUES
 ('demo-hospital','Demo City Hospital','hospital','active'),
 ('demo-school','Demo Public School','school','active'),
 ('demo-college','Demo Institute of Technology','college','active'),
 ('demo-hotel','Demo Grand Hotel','hotel','active'),
 ('demo-realestate','Demo Realty Group','realestate','active')
ON CONFLICT(code) DO UPDATE SET name=EXCLUDED.name, domain=EXCLUDED.domain, status='active';

INSERT INTO users(email,display_name,status) VALUES
 ('hospital.admin@demo.local','Hospital Admin','active'),
 ('hospital.doctor@demo.local','Dr. Ananya Sharma','active'),
 ('hospital.nurse@demo.local','Nurse Priya Singh','active'),
 ('hospital.accountant@demo.local','Hospital Accountant','active'),
 ('hospital.reception@demo.local','Hospital Receptionist','active'),
 ('hospital.patient@demo.local','Hospital Patient','active'),
 ('school.admin@demo.local','School Admin','active'),
 ('school.teacher@demo.local','School Teacher','active'),
 ('school.parent@demo.local','School Parent','active'),
 ('college.admin@demo.local','College Admin','active'),
 ('college.faculty@demo.local','College Faculty','active'),
 ('college.student@demo.local','College Student','active'),
 ('hotel.admin@demo.local','Hotel Admin','active'),
 ('hotel.frontdesk@demo.local','Hotel Front Desk','active'),
 ('hotel.guest@demo.local','Hotel Guest','active'),
 ('realestate.admin@demo.local','Real Estate Admin','active'),
 ('realestate.agent@demo.local','Real Estate Agent','active'),
 ('realestate.buyer@demo.local','Real Estate Buyer','active'),
 ('platform.superadmin@demo.local','Platform Super Admin','active')
ON CONFLICT(email) DO UPDATE SET display_name=EXCLUDED.display_name,status='active';

INSERT INTO tenant_memberships(tenant_id,user_id,roles)
SELECT t.id,u.id,x.roles
FROM (VALUES
 ('demo-hospital','hospital.admin@demo.local',ARRAY['admin']),
 ('demo-hospital','hospital.doctor@demo.local',ARRAY['doctor']),
 ('demo-hospital','hospital.nurse@demo.local',ARRAY['nurse']),
 ('demo-hospital','hospital.accountant@demo.local',ARRAY['accountant']),
 ('demo-hospital','hospital.reception@demo.local',ARRAY['receptionist']),
 ('demo-hospital','hospital.patient@demo.local',ARRAY['patient']),
 ('demo-hospital','platform.superadmin@demo.local',ARRAY['superadmin']),
 ('demo-school','school.admin@demo.local',ARRAY['admin']),
 ('demo-school','school.teacher@demo.local',ARRAY['teacher']),
 ('demo-school','school.parent@demo.local',ARRAY['parent']),
 ('demo-school','platform.superadmin@demo.local',ARRAY['superadmin']),
 ('demo-college','college.admin@demo.local',ARRAY['admin']),
 ('demo-college','college.faculty@demo.local',ARRAY['faculty']),
 ('demo-college','college.student@demo.local',ARRAY['student']),
 ('demo-college','platform.superadmin@demo.local',ARRAY['superadmin']),
 ('demo-hotel','hotel.admin@demo.local',ARRAY['admin']),
 ('demo-hotel','hotel.frontdesk@demo.local',ARRAY['frontdesk']),
 ('demo-hotel','hotel.guest@demo.local',ARRAY['guest']),
 ('demo-hotel','platform.superadmin@demo.local',ARRAY['superadmin']),
 ('demo-realestate','realestate.admin@demo.local',ARRAY['realestateadmin']),
 ('demo-realestate','realestate.agent@demo.local',ARRAY['agent']),
 ('demo-realestate','realestate.buyer@demo.local',ARRAY['buyer']),
 ('demo-realestate','platform.superadmin@demo.local',ARRAY['superadmin'])
) AS x(tenant_code,email,roles)
JOIN tenants t ON t.code=x.tenant_code
JOIN users u ON u.email=x.email
ON CONFLICT(tenant_id,user_id) DO UPDATE SET roles=EXCLUDED.roles,status='active';

-- ---------------------------------------------------------------------------
-- Hospital
SELECT set_config('app.tenant_id',(SELECT id::text FROM tenants WHERE code='demo-hospital'),true);
-- ---------------------------------------------------------------------------
WITH t AS (SELECT id FROM tenants WHERE code='demo-hospital'),
admin AS (SELECT id FROM users WHERE email='hospital.admin@demo.local'),
doc AS (SELECT id FROM users WHERE email='hospital.doctor@demo.local'),
patient_user AS (SELECT id FROM users WHERE email='hospital.patient@demo.local')
INSERT INTO hospital_departments(tenant_id,name,code,status)
SELECT t.id,v.name,v.code,'active' FROM t CROSS JOIN (VALUES ('Cardiology','CARD'),('General Medicine','MED'),('Emergency','ER')) v(name,code)
ON CONFLICT(tenant_id,code) DO UPDATE SET name=EXCLUDED.name,status='active';

WITH t AS (SELECT id FROM tenants WHERE code='demo-hospital')
INSERT INTO hospital_patients(tenant_id,mrn,first_name,last_name,dob,phone,email,user_id)
SELECT t.id,'MRN-1001','Rahul','Verma','1988-04-12','+91-9000001001','hospital.patient@demo.local',(SELECT id FROM users WHERE email='hospital.patient@demo.local') FROM t
ON CONFLICT(tenant_id,mrn) DO UPDATE SET first_name=EXCLUDED.first_name,last_name=EXCLUDED.last_name,phone=EXCLUDED.phone,email=EXCLUDED.email,user_id=EXCLUDED.user_id,status='active';

WITH t AS (SELECT id FROM tenants WHERE code='demo-hospital'), d AS (SELECT id FROM hospital_departments WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-hospital') AND code='CARD'), u AS (SELECT id FROM users WHERE email='hospital.doctor@demo.local')
INSERT INTO hospital_staff(tenant_id,user_id,role,department_id,status)
SELECT t.id,u.id,'doctor',d.id,'active' FROM t,d,u
ON CONFLICT(tenant_id,user_id,role) DO UPDATE SET department_id=EXCLUDED.department_id,status='active';

WITH t AS (SELECT id FROM tenants WHERE code='demo-hospital'), d AS (SELECT id FROM hospital_departments WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-hospital') AND code='CARD')
INSERT INTO hospital_wards(tenant_id,department_id,name,code,status)
SELECT t.id,d.id,'Cardiology Ward','CW-01','active' FROM t,d
ON CONFLICT(tenant_id,code) DO UPDATE SET name=EXCLUDED.name,status='active';

WITH t AS (SELECT id FROM tenants WHERE code='demo-hospital'), w AS (SELECT id FROM hospital_wards WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-hospital') AND code='CW-01')
INSERT INTO hospital_beds(tenant_id,ward_id,bed_no,status)
SELECT t.id,w.id,v.bed,'available' FROM t,w CROSS JOIN (VALUES ('CW-01'),('CW-02'),('CW-03')) v(bed)
ON CONFLICT(tenant_id,ward_id,bed_no) DO UPDATE SET status='available';

WITH t AS (SELECT id FROM tenants WHERE code='demo-hospital'), p AS (SELECT id FROM hospital_patients WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-hospital') AND mrn='MRN-1001'), d AS (SELECT id FROM users WHERE email='hospital.doctor@demo.local')
INSERT INTO hospital_appointments(tenant_id,patient_id,provider_user_id,starts_at,ends_at,reason,status)
SELECT t.id,p.id,d.id,date_trunc('day',now()) + interval '10 hours',date_trunc('day',now()) + interval '10 hours 30 minutes','Follow-up consultation','scheduled' FROM t,p,d
WHERE NOT EXISTS (SELECT 1 FROM hospital_appointments a WHERE a.tenant_id=t.id AND a.patient_id=p.id AND a.reason='Follow-up consultation' AND a.starts_at::date=current_date);

WITH t AS (SELECT id FROM tenants WHERE code='demo-hospital'), p AS (SELECT id FROM hospital_patients WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-hospital') AND mrn='MRN-1001'), d AS (SELECT id FROM users WHERE email='hospital.doctor@demo.local')
INSERT INTO hospital_encounters(tenant_id,patient_id,provider_user_id,chief_complaint,notes,status)
SELECT t.id,p.id,d.id,'Chest discomfort','Demo encounter for platform demonstration','open' FROM t,p,d
WHERE NOT EXISTS (SELECT 1 FROM hospital_encounters e WHERE e.tenant_id=t.id AND e.patient_id=p.id AND e.chief_complaint='Chest discomfort');

WITH t AS (SELECT id FROM tenants WHERE code='demo-hospital'), p AS (SELECT id FROM hospital_patients WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-hospital') AND mrn='MRN-1001'), e AS (SELECT id FROM hospital_encounters WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-hospital') AND patient_id=(SELECT id FROM hospital_patients WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-hospital') AND mrn='MRN-1001') AND chief_complaint='Chest discomfort'), d AS (SELECT id FROM users WHERE email='hospital.doctor@demo.local')
INSERT INTO hospital_prescriptions(tenant_id,patient_id,encounter_id,prescribed_by,medicine,dosage,duration,quantity,instructions,status)
SELECT t.id,p.id,e.id,d.id,'Paracetamol 500mg','1 tablet','3 days',6,'After food','active' FROM t,p,e,d
WHERE NOT EXISTS (SELECT 1 FROM hospital_prescriptions x WHERE x.tenant_id=t.id AND x.patient_id=p.id AND x.medicine='Paracetamol 500mg');

WITH t AS (SELECT id FROM tenants WHERE code='demo-hospital'), p AS (SELECT id FROM hospital_patients WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-hospital') AND mrn='MRN-1001'), e AS (SELECT id FROM hospital_encounters WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-hospital') AND patient_id=(SELECT id FROM hospital_patients WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-hospital') AND mrn='MRN-1001') AND chief_complaint='Chest discomfort'), d AS (SELECT id FROM users WHERE email='hospital.doctor@demo.local')
INSERT INTO hospital_lab_orders(tenant_id,patient_id,encounter_id,ordered_by,test_name,priority,status)
SELECT t.id,p.id,e.id,d.id,'CBC','routine','ordered' FROM t,p,e,d
WHERE NOT EXISTS (SELECT 1 FROM hospital_lab_orders x WHERE x.tenant_id=t.id AND x.patient_id=p.id AND x.test_name='CBC');

WITH t AS (SELECT id FROM tenants WHERE code='demo-hospital'), p AS (SELECT id FROM hospital_patients WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-hospital') AND mrn='MRN-1001')
INSERT INTO hospital_billing(tenant_id,patient_id,invoice_no,amount,status)
SELECT t.id,p.id,'INV-1001',2500,'unpaid' FROM t,p
ON CONFLICT(tenant_id,invoice_no) DO UPDATE SET amount=EXCLUDED.amount,status='unpaid';

-- ---------------------------------------------------------------------------
-- School
SELECT set_config('app.tenant_id',(SELECT id::text FROM tenants WHERE code='demo-school'),true);
-- ---------------------------------------------------------------------------
WITH t AS (SELECT id FROM tenants WHERE code='demo-school'), u AS (SELECT id FROM users WHERE email='school.teacher@demo.local')
INSERT INTO school_teachers(tenant_id,user_id,employee_no,name)
SELECT t.id,u.id,'T-001','Meera Kapoor' FROM t,u
ON CONFLICT(tenant_id,employee_no) DO UPDATE SET name=EXCLUDED.name,user_id=EXCLUDED.user_id,status='active';

WITH t AS (SELECT id FROM tenants WHERE code='demo-school')
INSERT INTO school_students(tenant_id,admission_no,first_name,last_name,phone,email)
SELECT t.id,'ADM-1001','Aarav','Sharma','+91-9000010001','aarav@demo.local' FROM t
ON CONFLICT(tenant_id,admission_no) DO UPDATE SET first_name=EXCLUDED.first_name,last_name=EXCLUDED.last_name,status='active';

WITH t AS (SELECT id FROM tenants WHERE code='demo-school'), teacher AS (SELECT id FROM school_teachers WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-school') AND employee_no='T-001')
INSERT INTO school_classes(tenant_id,name,section,academic_year,class_teacher_id)
SELECT t.id,'Grade 8','A','2026-27',teacher.id FROM t,teacher
ON CONFLICT(tenant_id,name,section,academic_year) DO UPDATE SET class_teacher_id=EXCLUDED.class_teacher_id,status='active';

WITH t AS (SELECT id FROM tenants WHERE code='demo-school'), s AS (SELECT id FROM school_students WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-school') AND admission_no='ADM-1001'), c AS (SELECT id FROM school_classes WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-school') AND name='Grade 8' AND section='A' AND academic_year='2026-27')
INSERT INTO school_enrollments(tenant_id,student_id,class_id)
SELECT t.id,s.id,c.id FROM t,s,c ON CONFLICT(tenant_id,student_id,class_id) DO UPDATE SET status='active';

WITH t AS (SELECT id FROM tenants WHERE code='demo-school'), s AS (SELECT id FROM school_students WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-school') AND admission_no='ADM-1001'), c AS (SELECT id FROM school_classes WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-school') AND name='Grade 8' AND section='A' AND academic_year='2026-27'), u AS (SELECT id FROM users WHERE email='school.teacher@demo.local')
INSERT INTO school_attendance(tenant_id,student_id,class_id,attendance_date,status,marked_by)
SELECT t.id,s.id,c.id,current_date,'present',u.id FROM t,s,c,u
ON CONFLICT(tenant_id,student_id,attendance_date) DO UPDATE SET status=EXCLUDED.status,marked_by=EXCLUDED.marked_by;

-- ---------------------------------------------------------------------------
-- College
SELECT set_config('app.tenant_id',(SELECT id::text FROM tenants WHERE code='demo-college'),true);
-- ---------------------------------------------------------------------------
WITH t AS (SELECT id FROM tenants WHERE code='demo-college')
INSERT INTO college_departments(tenant_id,name,code)
SELECT t.id,'Computer Science','CSE' FROM t ON CONFLICT(tenant_id,code) DO UPDATE SET name=EXCLUDED.name,status='active';

WITH t AS (SELECT id FROM tenants WHERE code='demo-college'), u AS (SELECT id FROM users WHERE email='college.faculty@demo.local')
INSERT INTO college_faculty(tenant_id,user_id,employee_no,name,department)
SELECT t.id,u.id,'F-001','Dr. Vikram Rao','Computer Science' FROM t,u ON CONFLICT(tenant_id,employee_no) DO UPDATE SET name=EXCLUDED.name,status='active';

WITH t AS (SELECT id FROM tenants WHERE code='demo-college'), d AS (SELECT id FROM college_departments WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-college') AND code='CSE')
INSERT INTO college_courses(tenant_id,department_id,code,name,credits)
SELECT t.id,d.id,'CSE101','Introduction to Computing',4 FROM t,d ON CONFLICT(tenant_id,code) DO UPDATE SET name=EXCLUDED.name,credits=EXCLUDED.credits,status='active';

WITH t AS (SELECT id FROM tenants WHERE code='demo-college'), u AS (SELECT id FROM users WHERE email='college.student@demo.local')
INSERT INTO college_students(tenant_id,enrollment_no,first_name,last_name,email,user_id)
SELECT t.id,'STU-1001','Ishita','Mehta','college.student@demo.local',u.id FROM t,u
ON CONFLICT(tenant_id,enrollment_no) DO UPDATE SET first_name=EXCLUDED.first_name,last_name=EXCLUDED.last_name,user_id=EXCLUDED.user_id,status='active';

WITH t AS (SELECT id FROM tenants WHERE code='demo-college'), s AS (SELECT id FROM college_students WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-college') AND enrollment_no='STU-1001'), c AS (SELECT id FROM college_courses WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-college') AND code='CSE101')
INSERT INTO college_enrollments(tenant_id,student_id,course_id,semester)
SELECT t.id,s.id,c.id,'2026-FALL' FROM t,s,c ON CONFLICT(tenant_id,student_id,course_id,semester) DO UPDATE SET status='active';

-- ---------------------------------------------------------------------------
-- Hotel
SELECT set_config('app.tenant_id',(SELECT id::text FROM tenants WHERE code='demo-hotel'),true);
-- ---------------------------------------------------------------------------
WITH t AS (SELECT id FROM tenants WHERE code='demo-hotel')
INSERT INTO hotel_room_types(tenant_id,name,capacity,base_rate)
SELECT t.id,v.name,v.capacity,v.rate FROM t CROSS JOIN (VALUES ('Deluxe',2,6500),('Suite',4,12000)) v(name,capacity,rate)
ON CONFLICT(tenant_id,name) DO UPDATE SET capacity=EXCLUDED.capacity,base_rate=EXCLUDED.base_rate,status='active';

WITH t AS (SELECT id FROM tenants WHERE code='demo-hotel'), rt AS (SELECT id FROM hotel_room_types WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-hotel') AND name='Deluxe')
INSERT INTO hotel_rooms(tenant_id,room_no,room_type_id,floor,status)
SELECT t.id,v.room,rt.id,'3','available' FROM t,rt CROSS JOIN (VALUES ('301'),('302'),('303')) v(room)
ON CONFLICT(tenant_id,room_no) DO UPDATE SET room_type_id=EXCLUDED.room_type_id,status='available';

WITH t AS (SELECT id FROM tenants WHERE code='demo-hotel')
INSERT INTO hotel_guests(tenant_id,guest_no,first_name,last_name,phone,email)
SELECT t.id,'G-1001','Rohan','Gupta','+91-9000020001','hotel.guest@demo.local' FROM t
ON CONFLICT(tenant_id,guest_no) DO UPDATE SET first_name=EXCLUDED.first_name,last_name=EXCLUDED.last_name,status='active';

WITH t AS (SELECT id FROM tenants WHERE code='demo-hotel'), g AS (SELECT id FROM hotel_guests WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-hotel') AND guest_no='G-1001'), r AS (SELECT id FROM hotel_rooms WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-hotel') AND room_no='301')
INSERT INTO hotel_bookings(tenant_id,booking_no,guest_id,room_id,check_in_date,check_out_date,adults,children,status,total_amount)
SELECT t.id,'BKG-1001',g.id,r.id,current_date+1,current_date+3,2,0,'booked',13000 FROM t,g,r
ON CONFLICT(tenant_id,booking_no) DO UPDATE SET room_id=EXCLUDED.room_id,status='booked',total_amount=EXCLUDED.total_amount;

-- ---------------------------------------------------------------------------
-- Real Estate
SELECT set_config('app.tenant_id',(SELECT id::text FROM tenants WHERE code='demo-realestate'),true);
-- ---------------------------------------------------------------------------
WITH t AS (SELECT id FROM tenants WHERE code='demo-realestate'), u AS (SELECT id FROM users WHERE email='realestate.agent@demo.local')
INSERT INTO realestate_properties(tenant_id,property_code,name,property_type,address_line1,city,state,country,postal_code,owner_user_id)
SELECT t.id,'PROP-1001','Lakeview Residency','residential','Ring Road','Nagpur','Maharashtra','India','440001',u.id FROM t,u
ON CONFLICT(tenant_id,property_code) DO UPDATE SET name=EXCLUDED.name,status='active',owner_user_id=EXCLUDED.owner_user_id;

WITH t AS (SELECT id FROM tenants WHERE code='demo-realestate'), p AS (SELECT id FROM realestate_properties WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-realestate') AND property_code='PROP-1001')
INSERT INTO realestate_units(tenant_id,property_id,unit_no,unit_type,area_sqft,bedrooms,bathrooms,status,asking_price)
SELECT t.id,p.id,'A-301','Apartment',1450,3,2,'available',8750000 FROM t,p
ON CONFLICT(tenant_id,property_id,unit_no) DO UPDATE SET asking_price=EXCLUDED.asking_price,status='available';

WITH t AS (SELECT id FROM tenants WHERE code='demo-realestate'), p AS (SELECT id FROM realestate_properties WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-realestate') AND property_code='PROP-1001'), u AS (SELECT id FROM realestate_units WHERE tenant_id=(SELECT id FROM tenants WHERE code='demo-realestate') AND unit_no='A-301'), a AS (SELECT id FROM users WHERE email='realestate.agent@demo.local')
INSERT INTO realestate_listings(tenant_id,property_id,unit_id,listing_type,title,description,price,agent_user_id)
SELECT t.id,p.id,u.id,'sale','3 BHK Lakeview Apartment','Demo listing for the EMTAF real estate showcase',8750000,a.id FROM t,p,u,a
WHERE NOT EXISTS (SELECT 1 FROM realestate_listings l WHERE l.tenant_id=t.id AND l.title='3 BHK Lakeview Apartment');

WITH t AS (SELECT id FROM tenants WHERE code='demo-realestate'), a AS (SELECT id FROM users WHERE email='realestate.agent@demo.local')
INSERT INTO realestate_leads(tenant_id,name,phone,email,source,status,assigned_agent_id)
SELECT t.id,'Neha Patil','+91-9000030001','neha@demo.local','website','new',a.id FROM t,a
WHERE NOT EXISTS (SELECT 1 FROM realestate_leads l WHERE l.tenant_id=t.id AND l.email='neha@demo.local');

COMMIT;
