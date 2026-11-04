-- =====================================================================
--  FleetOps Platform  |  DEVELOPMENT SEED DATA  v1.0
--  Run AFTER database/schema.sql.  FAKE DATA - never load into production.
--
--  Demo logins (password for all: Password@123)
--    nimal@example.com   -> INDIVIDUAL account, owns 2 vehicles
--    kamal@example.com   -> BUSINESS account owner (Silva Logistics)
--    dilini@example.com  -> BUSINESS fleet manager
--    sunil@example.com   -> BUSINESS driver
-- =====================================================================

SET NAMES utf8mb4;
SET @pw := '$2b$10$35DtN2DN.xzYlFT3vib1f./KLgAKIbPgZlS6/UW7iVWf7DJxVBW9O';

SET @r_owner   := (SELECT id FROM roles WHERE code='OWNER'         AND account_id IS NULL);
SET @r_manager := (SELECT id FROM roles WHERE code='FLEET_MANAGER' AND account_id IS NULL);
SET @r_driver  := (SELECT id FROM roles WHERE code='DRIVER'        AND account_id IS NULL);

-- ---------------------------------------------------------------------
-- System inspection template (available to every account)
-- ---------------------------------------------------------------------
INSERT INTO inspection_templates (account_id, name, vehicle_type, description)
VALUES (NULL, 'Daily Pre-Trip Check', NULL, 'Basic walk-around check before driving');
SET @tpl := LAST_INSERT_ID();
INSERT INTO inspection_template_items (template_id, sequence_no, category, label, response_type, is_critical) VALUES
 (@tpl,1,'Tyres','Tyre condition and pressure','PASS_FAIL',1),
 (@tpl,2,'Brakes','Brake pedal feel / handbrake','PASS_FAIL',1),
 (@tpl,3,'Lights','Head, brake and indicator lights','PASS_FAIL',1),
 (@tpl,4,'Fluids','Engine oil and coolant level','PASS_FAIL',0),
 (@tpl,5,'Safety','Seat belts, horn, wipers','PASS_FAIL',0),
 (@tpl,6,'Documents','Revenue licence and insurance in vehicle','YES_NO',0);

-- =====================================================================
-- A) INDIVIDUAL OWNER: Nimal Perera  (2 vehicles)
-- =====================================================================
INSERT INTO users (public_id,email,phone,password_hash,first_name,last_name,status,email_verified_at)
VALUES (UUID(),'nimal@example.com','+94771234567',@pw,'Nimal','Perera','ACTIVE',NOW());
SET @u_nimal := LAST_INSERT_ID();

INSERT INTO accounts (public_id,account_type,name,city,country_code,owner_user_id)
VALUES (UUID(),'INDIVIDUAL','Nimal''s Garage','Colombo','LK',@u_nimal);
SET @a1 := LAST_INSERT_ID();
UPDATE users SET default_account_id=@a1 WHERE id=@u_nimal;

INSERT INTO account_members (account_id,user_id,role_id,job_title) VALUES (@a1,@u_nimal,@r_owner,'Owner');
INSERT INTO subscriptions (account_id,plan_id,status,starts_at)
VALUES (@a1,(SELECT id FROM plans WHERE code='INDIVIDUAL_FREE'),'ACTIVE',NOW());

INSERT INTO drivers (public_id,account_id,user_id,first_name,last_name,phone,license_no,license_class,license_expiry_date,is_account_owner)
VALUES (UUID(),@a1,@u_nimal,'Nimal','Perera','+94771234567','B1234567','B,A1','2028-03-31',1);
SET @d_nimal := LAST_INSERT_ID();

INSERT INTO vehicles (public_id,account_id,registration_no,nickname,make_id,model_id,custom_model,year_manufactured,color,
                      vehicle_type,ownership_type,usage_type,fuel_type,transmission,engine_cc,seating_capacity,tank_capacity_l,
                      purchase_date,purchase_price,purchase_odometer,primary_driver_id)
VALUES (UUID(),@a1,'CAB-1234','Family Car',(SELECT id FROM vehicle_makes WHERE name='Toyota'),NULL,'Axio',2016,'White',
        'CAR','OWNED','PERSONAL','HYBRID','CVT',1500,5,36,'2021-06-10',6800000,42000,@d_nimal);
SET @v_car := LAST_INSERT_ID();
INSERT INTO vehicles (public_id,account_id,registration_no,nickname,make_id,custom_model,year_manufactured,color,
                      vehicle_type,ownership_type,usage_type,fuel_type,engine_cc,seating_capacity,tank_capacity_l,
                      purchase_date,purchase_price,purchase_odometer,primary_driver_id)
VALUES (UUID(),@a1,'BHC-5678','Daily Bike',(SELECT id FROM vehicle_makes WHERE name='Honda'),'CB Hornet',2020,'Red',
        'MOTORCYCLE','FINANCED','PERSONAL','PETROL',160,2,12,'2020-09-01',640000,0,@d_nimal);
SET @v_bike := LAST_INSERT_ID();

INSERT INTO odometer_readings (account_id,vehicle_id,reading,read_at,source,recorded_by) VALUES
 (@a1,@v_car,58200,'2026-08-01 08:00:00','MANUAL',@u_nimal),
 (@a1,@v_car,60150,'2026-10-15 08:00:00','FUEL',@u_nimal),
 (@a1,@v_bike,21400,'2026-10-20 18:00:00','MANUAL',@u_nimal);

INSERT INTO fuel_logs (account_id,vehicle_id,driver_id,filled_at,energy_type,quantity,quantity_unit,unit_price,total_cost,odometer,is_full_tank,station_name) VALUES
 (@a1,@v_car,@d_nimal,'2026-09-05 09:10:00','PETROL',30.000,'L',350.000,10500.00,58900,1,'Ceypetco Nugegoda'),
 (@a1,@v_car,@d_nimal,'2026-09-28 18:30:00','PETROL',29.500,'L',355.000,10472.50,59600,1,'IOC Maharagama'),
 (@a1,@v_car,@d_nimal,'2026-10-15 08:15:00','PETROL',31.000,'L',358.000,11098.00,60150,1,'Ceypetco Nugegoda');

INSERT INTO vehicle_documents (account_id,vehicle_id,doc_type,doc_number,issuer,issue_date,expiry_date,cost) VALUES
 (@a1,@v_car,'REVENUE_LICENSE','WP-RL-889900','Dept. of Motor Traffic','2026-01-05','2026-12-31',12500),
 (@a1,@v_car,'EMISSION_TEST','EM-55421','Authorised Test Centre','2026-02-10','2026-11-30',1500),
 (@a1,@v_bike,'REVENUE_LICENSE','WP-RL-445566','Dept. of Motor Traffic','2026-01-05','2026-12-31',3000);

INSERT INTO insurance_policies (account_id,vehicle_id,provider_name,policy_no,coverage_type,premium_amount,premium_frequency,sum_insured,start_date,end_date)
VALUES (@a1,@v_car,'Demo Insurance PLC','POL-100245','COMPREHENSIVE',85000,'YEARLY',6000000,'2026-03-01','2027-02-28');

INSERT INTO maintenance_schedules (account_id,vehicle_id,service_type_id,title,interval_km,interval_days,last_done_odometer,last_done_date,next_due_odometer,next_due_date)
VALUES (@a1,@v_car,(SELECT id FROM service_types WHERE code='OIL_CHANGE'),'Engine oil change',5000,180,56000,'2026-06-20',61000,'2026-12-17');

INSERT INTO expenses (account_id,vehicle_id,driver_id,category_id,expense_date,description,amount,vendor_name,created_by)
VALUES (@a1,@v_car,@d_nimal,(SELECT id FROM expense_categories WHERE code='PARKING'),'2026-10-12','City parking',400,'Colombo Municipal Council',@u_nimal);

-- =====================================================================
-- B) BUSINESS OWNER: Silva Logistics (Pvt) Ltd  (4 vehicles, 3 drivers)
-- =====================================================================
INSERT INTO users (public_id,email,phone,password_hash,first_name,last_name,status,email_verified_at) VALUES
 (UUID(),'kamal@example.com', '+94712223333',@pw,'Kamal', 'Silva',   'ACTIVE',NOW()),
 (UUID(),'dilini@example.com','+94714445555',@pw,'Dilini','Fernando','ACTIVE',NOW()),
 (UUID(),'sunil@example.com', '+94716667777',@pw,'Sunil', 'Jayasuriya','ACTIVE',NOW());
SET @u_kamal  := (SELECT id FROM users WHERE email='kamal@example.com');
SET @u_dilini := (SELECT id FROM users WHERE email='dilini@example.com');
SET @u_sunil  := (SELECT id FROM users WHERE email='sunil@example.com');

INSERT INTO accounts (public_id,account_type,name,legal_name,registration_no,industry,email,phone,city,country_code,owner_user_id)
VALUES (UUID(),'BUSINESS','Silva Logistics','Silva Logistics (Pvt) Ltd','PV 00112233','Transport & Logistics',
        'info@silvalogistics.example','+94112345678','Colombo','LK',@u_kamal);
SET @a2 := LAST_INSERT_ID();
UPDATE users SET default_account_id=@a2 WHERE id IN (@u_kamal,@u_dilini,@u_sunil);

INSERT INTO subscriptions (account_id,plan_id,status,starts_at)
VALUES (@a2,(SELECT id FROM plans WHERE code='BUSINESS_STARTER'),'ACTIVE',NOW());

INSERT INTO locations (account_id,name,location_type,city,latitude,longitude) VALUES
 (@a2,'Head Office - Colombo','HEAD_OFFICE','Colombo',6.9271000,79.8612000),
 (@a2,'Kandy Depot','DEPOT','Kandy',7.2906000,80.6337000);
SET @l_hq   := (SELECT id FROM locations WHERE account_id=@a2 AND name='Head Office - Colombo');
SET @l_kdy  := (SELECT id FROM locations WHERE account_id=@a2 AND name='Kandy Depot');

INSERT INTO departments (account_id,name,code,cost_center_code) VALUES
 (@a2,'Operations','OPS','CC-100'),(@a2,'Sales','SAL','CC-200');
SET @dp_ops := (SELECT id FROM departments WHERE account_id=@a2 AND code='OPS');

INSERT INTO account_members (account_id,user_id,role_id,department_id,location_id,job_title) VALUES
 (@a2,@u_kamal, @r_owner,  NULL,   @l_hq,'Managing Director'),
 (@a2,@u_dilini,@r_manager,@dp_ops,@l_hq,'Fleet Manager'),
 (@a2,@u_sunil, @r_driver, @dp_ops,@l_hq,'Driver');
SET @m_dilini := (SELECT id FROM account_members WHERE account_id=@a2 AND user_id=@u_dilini);

INSERT INTO drivers (public_id,account_id,user_id,department_id,employee_no,first_name,last_name,phone,license_no,license_class,license_expiry_date,hire_date) VALUES
 (UUID(),@a2,@u_sunil,@dp_ops,'EMP-001','Sunil','Jayasuriya','+94716667777','B7654321','B,C1','2027-05-20','2022-02-01'),
 (UUID(),@a2,NULL,    @dp_ops,'EMP-002','Ruwan','Bandara',   '+94718889999','B1122334','B,C',   '2026-12-15','2023-07-10'),
 (UUID(),@a2,NULL,    @dp_ops,'EMP-003','Asela','Wickrama',  '+94719990000','B9988776','B',     '2029-01-31','2024-03-01');
SET @d_sunil := (SELECT id FROM drivers WHERE account_id=@a2 AND employee_no='EMP-001');
SET @d_ruwan := (SELECT id FROM drivers WHERE account_id=@a2 AND employee_no='EMP-002');
SET @d_asela := (SELECT id FROM drivers WHERE account_id=@a2 AND employee_no='EMP-003');

INSERT INTO vehicles (public_id,account_id,registration_no,nickname,make_id,custom_model,year_manufactured,vehicle_type,ownership_type,usage_type,
                      fuel_type,transmission,seating_capacity,payload_kg,tank_capacity_l,purchase_date,purchase_price,purchase_odometer,location_id,department_id,primary_driver_id) VALUES
 (UUID(),@a2,'LA-1001','Van 01',  (SELECT id FROM vehicle_makes WHERE name='Toyota'),    'HiAce',2018,'VAN',   'OWNED',   'BUSINESS','DIESEL','MANUAL',  14,1200,70,'2019-01-15',9500000, 10000,@l_hq, @dp_ops,@d_sunil),
 (UUID(),@a2,'LB-2002','Lorry 01',(SELECT id FROM vehicle_makes WHERE name='Isuzu'),     'Elf',  2017,'LORRY', 'FINANCED','BUSINESS','DIESEL','MANUAL',   3,3500,100,'2018-05-20',8200000,20000,@l_hq, @dp_ops,@d_ruwan),
 (UUID(),@a2,'PE-3003','Pickup 01',(SELECT id FROM vehicle_makes WHERE name='Mahindra'),'Bolero',2020,'PICKUP','LEASED',  'BUSINESS','DIESEL','MANUAL',   5,1000,60,'2020-08-01',5600000, 0,    @l_kdy,@dp_ops,@d_asela),
 (UUID(),@a2,'CBA-4004','Manager Car',(SELECT id FROM vehicle_makes WHERE name='Honda'),'Vezel',2019,'SUV',   'OWNED',   'MIXED',   'HYBRID','CVT',      5,NULL,40,'2019-11-11',7400000,15000,@l_hq, NULL,   NULL);
SET @v_van  := (SELECT id FROM vehicles WHERE account_id=@a2 AND registration_no='LA-1001');
SET @v_lor  := (SELECT id FROM vehicles WHERE account_id=@a2 AND registration_no='LB-2002');
SET @v_pick := (SELECT id FROM vehicles WHERE account_id=@a2 AND registration_no='PE-3003');
SET @v_mgr  := (SELECT id FROM vehicles WHERE account_id=@a2 AND registration_no='CBA-4004');

INSERT INTO vehicle_driver_assignments (account_id,vehicle_id,driver_id,assignment_type,starts_at) VALUES
 (@a2,@v_van,@d_sunil,'PRIMARY','2022-02-01 08:00:00'),
 (@a2,@v_lor,@d_ruwan,'PRIMARY','2023-07-10 08:00:00'),
 (@a2,@v_pick,@d_asela,'PRIMARY','2024-03-01 08:00:00');

INSERT INTO odometer_readings (account_id,vehicle_id,reading,read_at,source,recorded_by) VALUES
 (@a2,@v_van, 96500,'2026-10-31 18:00:00','TRIP',@u_dilini),
 (@a2,@v_lor,143200,'2026-10-31 18:00:00','TRIP',@u_dilini),
 (@a2,@v_pick,61800,'2026-10-30 17:30:00','MANUAL',@u_dilini),
 (@a2,@v_mgr, 58300,'2026-10-29 09:00:00','MANUAL',@u_dilini);

INSERT INTO vehicle_documents (account_id,vehicle_id,doc_type,doc_number,issuer,issue_date,expiry_date,cost) VALUES
 (@a2,@v_van, 'REVENUE_LICENSE','WP-RL-100100','Dept. of Motor Traffic','2026-01-03','2026-12-31',28000),
 (@a2,@v_lor, 'REVENUE_LICENSE','WP-RL-200200','Dept. of Motor Traffic','2026-01-03','2026-12-31',45000),
 (@a2,@v_lor, 'EMISSION_TEST',  'EM-90011','Authorised Test Centre',     '2026-05-10','2026-11-20',2500),
 (@a2,@v_pick,'REVENUE_LICENSE','CP-RL-300300','Dept. of Motor Traffic','2026-01-04','2026-12-31',22000);

INSERT INTO insurance_policies (account_id,vehicle_id,provider_name,policy_no,coverage_type,premium_amount,premium_frequency,sum_insured,start_date,end_date) VALUES
 (@a2,@v_van, 'Demo Insurance PLC','POL-200001','COMPREHENSIVE',180000,'YEARLY',8000000,'2026-02-01','2027-01-31'),
 (@a2,@v_lor, 'Demo Insurance PLC','POL-200002','COMPREHENSIVE',240000,'YEARLY',7500000,'2026-02-01','2026-12-05'),
 (@a2,@v_pick,'Demo Insurance PLC','POL-200003','THIRD_PARTY',   60000,'YEARLY',NULL,   '2026-04-01','2027-03-31');

INSERT INTO finance_contracts (account_id,vehicle_id,contract_type,lender_name,contract_no,total_amount,monthly_payment,interest_rate,start_date,end_date) VALUES
 (@a2,@v_lor, 'LOAN', 'Demo Bank PLC',   'LN-77881',6500000,145000,12.50,'2018-05-20','2026-11-20'),
 (@a2,@v_pick,'LEASE','Demo Leasing Ltd','LS-55120',5000000,118000,13.00,'2020-08-01','2027-08-01');

INSERT INTO service_providers (account_id,name,provider_type,contact_name,phone,city) VALUES
 (@a2,'AutoCare Service Centre','GARAGE','Mr. Perera','+94112223344','Colombo'),
 (@a2,'Ceypetco Fuel Station','FUEL_STATION',NULL,'+94112000111','Colombo');
SET @p_garage := (SELECT id FROM service_providers WHERE account_id=@a2 AND name='AutoCare Service Centre');

-- Trips
INSERT INTO trips (public_id,account_id,trip_no,vehicle_id,driver_id,requested_by,purpose,title,status,
                   actual_start_at,actual_end_at,origin_label,origin_lat,origin_lng,destination_label,destination_lat,destination_lng,
                   start_odometer,end_odometer,distance_km,cargo_description,cargo_weight_kg) VALUES
 (UUID(),@a2,'TRP-0001',@v_van,@d_sunil,@m_dilini,'DELIVERY','Colombo to Kandy delivery','COMPLETED',
  '2026-10-30 06:00:00','2026-10-30 11:30:00','Head Office - Colombo',6.9271,79.8612,'Kandy Depot',7.2906,80.6337,
  96100,96300,200,'Packaged goods',850),
 (UUID(),@a2,'TRP-0002',@v_lor,@d_ruwan,@m_dilini,'DELIVERY','Colombo to Galle delivery','COMPLETED',
  '2026-10-31 07:00:00','2026-10-31 13:00:00','Head Office - Colombo',6.9271,79.8612,'Galle',6.0535,80.2210,
  143000,143200,200,'Building materials',2800),
 (UUID(),@a2,'TRP-0003',@v_van,@d_sunil,@m_dilini,'DELIVERY','Kandy to Colombo return','SCHEDULED',
  NULL,NULL,'Kandy Depot',7.2906,80.6337,'Head Office - Colombo',6.9271,79.8612,NULL,NULL,NULL,'Returns',300);
SET @t1 := (SELECT id FROM trips WHERE account_id=@a2 AND trip_no='TRP-0001');
INSERT INTO trip_stops (trip_id,sequence_no,label,latitude,longitude) VALUES
 (@t1,1,'Kegalle rest stop',7.2513,80.3464),(@t1,2,'Kandy Depot',7.2906,80.6337);

INSERT INTO vehicle_bookings (account_id,vehicle_id,driver_id,requested_by,approved_by,starts_at,ends_at,purpose,status)
VALUES (@a2,@v_mgr,NULL,@m_dilini,@m_dilini,'2026-11-10 08:00:00','2026-11-10 17:00:00','Client visit in Negombo','APPROVED');

-- Fuel
INSERT INTO fuel_logs (account_id,vehicle_id,driver_id,trip_id,provider_id,filled_at,energy_type,quantity,quantity_unit,unit_price,total_cost,odometer,is_full_tank,station_name,payment_method) VALUES
 (@a2,@v_van,@d_sunil,NULL,NULL,'2026-10-20 07:00:00','DIESEL',55.000,'L',335.000,18425.00,95800,1,'Ceypetco Kandy','FUEL_CARD'),
 (@a2,@v_van,@d_sunil,@t1,NULL, '2026-10-30 05:30:00','DIESEL',48.500,'L',338.000,16393.00,96100,1,'Ceypetco Colombo','FUEL_CARD'),
 (@a2,@v_lor,@d_ruwan,NULL,NULL,'2026-10-18 06:45:00','DIESEL',80.000,'L',335.000,26800.00,142200,1,'IOC Kadawatha','FUEL_CARD'),
 (@a2,@v_lor,@d_ruwan,NULL,NULL,'2026-10-31 06:30:00','DIESEL',85.000,'L',338.000,28730.00,143000,1,'IOC Kadawatha','FUEL_CARD');

-- Maintenance
INSERT INTO maintenance_schedules (account_id,vehicle_id,service_type_id,title,interval_km,interval_days,last_done_odometer,last_done_date,next_due_odometer,next_due_date) VALUES
 (@a2,@v_van,(SELECT id FROM service_types WHERE code='OIL_CHANGE'),'Van engine oil',5000,120,92000,'2026-07-01',97000,'2026-10-29'),
 (@a2,@v_lor,(SELECT id FROM service_types WHERE code='BRAKE_SERVICE'),'Lorry brake service',20000,365,125000,'2026-01-15',145000,'2027-01-15');

INSERT INTO work_orders (public_id,account_id,wo_no,vehicle_id,provider_id,reported_by,work_type,priority,status,description,
                         odometer_at_service,opened_at,completed_at,downtime_hours,labor_cost,parts_cost,tax_amount,invoice_no,payment_status)
VALUES (UUID(),@a2,'WO-0001',@v_lor,@p_garage,@m_dilini,'CORRECTIVE','HIGH','COMPLETED','Replace worn front brake pads',
        142500,'2026-10-22 09:00:00','2026-10-22 16:00:00',7,8000,24000,0,'INV-5521','PAID');
SET @wo1 := LAST_INSERT_ID();
INSERT INTO work_order_items (work_order_id,item_type,description,part_no,quantity,unit_price) VALUES
 (@wo1,'PART','Front brake pad set','BP-ELF-01',1,24000),
 (@wo1,'LABOR','Brake pad replacement labour',NULL,1,8000);

-- Inspection (pre-trip)
INSERT INTO inspections (account_id,vehicle_id,template_id,driver_id,inspected_by,inspected_at,odometer,result,notes)
VALUES (@a2,@v_van,@tpl,@d_sunil,@u_sunil,'2026-10-30 05:45:00',96100,'PASSED_WITH_DEFECTS','Left indicator dim');
SET @ins1 := LAST_INSERT_ID();
INSERT INTO inspection_results (inspection_id,template_item_id,result,notes)
SELECT @ins1, i.id, IF(i.sequence_no=3,'FAIL','PASS'), IF(i.sequence_no=3,'Left indicator bulb weak',NULL)
FROM inspection_template_items i WHERE i.template_id=@tpl AND i.response_type='PASS_FAIL';

-- Fine and incident
INSERT INTO traffic_fines (account_id,vehicle_id,driver_id,fine_no,offence,offence_date,location,amount,due_date,status)
VALUES (@a2,@v_pick,@d_asela,'TF-99812','Parking in a no-parking zone','2026-10-05 14:20:00','Kandy',2000,'2026-11-20','UNPAID');

INSERT INTO incidents (account_id,incident_no,vehicle_id,driver_id,trip_id,incident_type,severity,occurred_at,location_label,description,estimated_damage,status)
VALUES (@a2,'INC-0001',@v_van,@d_sunil,@t1,'DAMAGE','MINOR','2026-10-30 09:40:00','Kegalle','Side mirror scratched in narrow road',15000,'REPORTED');

-- General business expense
INSERT INTO expenses (account_id,vehicle_id,driver_id,trip_id,category_id,expense_date,description,amount,vendor_name,created_by)
VALUES (@a2,@v_van,@d_sunil,@t1,(SELECT id FROM expense_categories WHERE code='TOLL'),'2026-10-30','Expressway toll',1300,'Southern Expressway',@u_dilini);

-- Telematics demo
INSERT INTO devices (account_id,vehicle_id,device_type,identifier,provider,status,last_seen_at)
VALUES (@a2,@v_van,'GPS_TRACKER','DEMO-IMEI-100000000001','DemoTrack','ACTIVE',NOW());
SET @dev1 := LAST_INSERT_ID();
INSERT INTO gps_positions (account_id,vehicle_id,device_id,recorded_at,latitude,longitude,speed_kph,heading,ignition_on) VALUES
 (@a2,@v_van,@dev1,'2026-10-30 06:05:00',6.9500000,79.9000000,45.0,60,1),
 (@a2,@v_van,@dev1,'2026-10-30 07:30:00',7.1500000,80.2000000,62.0,55,1),
 (@a2,@v_van,@dev1,'2026-10-30 09:10:00',7.2513000,80.3464000,38.0,70,1);
INSERT INTO geofences (account_id,name,shape,center_lat,center_lng,radius_m)
VALUES (@a2,'Head Office Yard','CIRCLE',6.9271000,79.8612000,300);

-- Alerts and notification
INSERT INTO alert_rules (account_id,vehicle_id,name,rule_type,config,channels)
VALUES (@a2,NULL,'Documents expiring in 30 days','DOCUMENT_EXPIRY','{"days_before":30}','["IN_APP","EMAIL"]');
SET @rule1 := LAST_INSERT_ID();
INSERT INTO alerts (account_id,rule_id,vehicle_id,alert_type,severity,title,message,entity_type,status)
VALUES (@a2,@rule1,@v_lor,'DOCUMENT_EXPIRY','WARNING','Emission test expiring soon','Lorry 01 (LB-2002) emission test expires on 2026-11-20.','vehicle_document','OPEN');
SET @al1 := LAST_INSERT_ID();
INSERT INTO notifications (account_id,user_id,alert_id,channel,title,body,status)
VALUES (@a2,@u_dilini,@al1,'IN_APP','Emission test expiring soon','Lorry 01 (LB-2002) emission test expires on 2026-11-20.','SENT');

-- Audit trail sample
INSERT INTO audit_logs (account_id,user_id,action,entity_type,entity_id,new_values)
VALUES (@a2,@u_dilini,'CREATE','work_order',@wo1,JSON_OBJECT('wo_no','WO-0001'));
