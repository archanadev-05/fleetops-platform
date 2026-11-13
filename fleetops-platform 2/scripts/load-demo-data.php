<?php
// Adds a separate classroom organization and sample records without changing existing rows.
require dirname(__DIR__) . '/app/bootstrap.php';
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }

$demoPassword = 'FleetOpsDemo2026!';
$accounts = [
    ['Demo Fleet Manager', 'demo.manager@fleetops.local', 'FLEET_MANAGER'],
    ['Demo Mechanic', 'demo.mechanic@fleetops.local', 'MECHANIC'],
    ['Demo Driver', 'demo.driver@fleetops.local', 'DRIVER'],
    ['Demo Driver Two', 'demo.driver2@fleetops.local', 'DRIVER'],
];

try {
    $pdo = db();
    $emailCheck = $pdo->prepare('SELECT COUNT(*) FROM users WHERE email=?');
    foreach ($accounts as $account) {
        $emailCheck->execute([$account[1]]);
        if ($emailCheck->fetchColumn()) {
            fwrite(STDERR, "Demo account already exists: {$account[1]}. No data was added.\n");
            exit(1);
        }
    }

    fwrite(STDOUT, "This adds a separate FleetOps Classroom Demo organization and records to the selected database. Existing rows are not edited or deleted.\nType ADD DEMO DATA to continue: ");
    if (trim((string)fgets(STDIN)) !== 'ADD DEMO DATA') {
        fwrite(STDOUT, "Cancelled.\n");
        exit(0);
    }

    $orgId = uid();
    $userIds = array_map(static fn() => uid(), $accounts);
    $vehicleIds = [uid(), uid(), uid()];
    $ruleIds = [uid(), uid(), uid()];
    $jobIds = [uid(), uid()];
    $pdo->beginTransaction();

    $pdo->prepare('INSERT INTO organizations (id,name) VALUES (?,?)')->execute([$orgId, 'FleetOps Classroom Demo']);
    $insertUser = $pdo->prepare('INSERT INTO users (id,org_id,name,email,password_hash,role) VALUES (?,?,?,?,?,?)');
    foreach ($accounts as $i => [$name, $email, $role]) {
        $insertUser->execute([$userIds[$i], $orgId, $name, $email, password_hash($demoPassword, PASSWORD_DEFAULT), $role]);
    }

    $vehicles = [
        ['CAB-1234','Toyota Hiace 2.8',2022,'DIESEL','ACTIVE',48200,180,90],
        ['WP-5678','Isuzu ELF NKR',2020,'DIESEL','IN_MAINTENANCE',76150,120,45],
        ['CP-9012','Suzuki Carry 1.5',2023,'PETROL','ACTIVE',21300,210,150],
    ];
    $insertVehicle = $pdo->prepare('INSERT INTO vehicles (id,org_id,plate_number,model,year,fuel_type,status,current_odometer,insurance_expiry,revenue_lic_expiry) VALUES (?,?,?,?,?,?,?,?,?,?)');
    foreach ($vehicles as $i => $v) $insertVehicle->execute([$vehicleIds[$i],$orgId,$v[0],$v[1],$v[2],$v[3],$v[4],$v[5],date('Y-m-d',strtotime('+' . $v[6] . ' days')),date('Y-m-d',strtotime('+' . $v[7] . ' days'))]);

    $insertRule = $pdo->prepare('INSERT INTO service_rules (id,vehicle_id,name,interval_km,last_service_odometer) VALUES (?,?,?,?,?)');
    $insertRule->execute([$ruleIds[0],$vehicleIds[0],'Engine oil and filter',10000,45000]);
    $insertRule->execute([$ruleIds[1],$vehicleIds[1],'Scheduled service',10000,66000]);
    $insertRule->execute([$ruleIds[2],$vehicleIds[2],'Engine oil and filter',7500,18000]);

    $insertJob = $pdo->prepare('INSERT INTO job_cards (id,vehicle_id,mechanic_id,service_rule_id,title,description,status,labor_cost,odometer_at_service,opened_at,completed_at) VALUES (?,?,?,?,?,?,?,?,?,?,?)');
    $insertJob->execute([$jobIds[0],$vehicleIds[1],$userIds[1],$ruleIds[1],'10,000 km scheduled service','Replace engine oil and filters; inspect brakes and tires.','OPEN',0,null,date('Y-m-d H:i:s'),null]);
    $insertJob->execute([$jobIds[1],$vehicleIds[0],$userIds[1],$ruleIds[0],'Engine oil and filter change','Routine oil and filter replacement.','COMPLETED',5000,45000,date('Y-m-d H:i:s',strtotime('-30 days')),date('Y-m-d H:i:s',strtotime('-30 days'))]);
    $insertPart = $pdo->prepare('INSERT INTO job_parts (id,job_card_id,name,quantity,unit_cost) VALUES (?,?,?,?,?)');
    $insertPart->execute([uid(),$jobIds[0],'Engine oil filter',1,2400]);
    $insertPart->execute([uid(),$jobIds[0],'Diesel engine oil (litre)',8,1850]);

    $start = date('Y-m-d', strtotime('+1 day')) . ' 08:00:00';
    $end = date('Y-m-d', strtotime('+1 day')) . ' 17:00:00';
    $insertAssignment = $pdo->prepare('INSERT INTO assignments (id,vehicle_id,driver_id,shift_start,shift_end) VALUES (?,?,?,?,?)');
    $insertAssignment->execute([uid(),$vehicleIds[0],$userIds[2],$start,$end]);
    $insertAssignment->execute([uid(),$vehicleIds[2],$userIds[3],date('Y-m-d', strtotime('+2 days')) . ' 08:00:00',date('Y-m-d', strtotime('+2 days')) . ' 17:00:00']);

    $insertFuel = $pdo->prepare('INSERT INTO fuel_logs (id,vehicle_id,driver_id,odometer,liters,total_cost,full_tank,logged_at) VALUES (?,?,?,?,?,?,?,?)');
    $insertFuel->execute([uid(),$vehicleIds[0],$userIds[2],48120,48.50,16500,1,date('Y-m-d H:i:s',strtotime('-2 days'))]);
    $insertFuel->execute([uid(),$vehicleIds[0],$userIds[2],48200,51.20,17600,1,date('Y-m-d H:i:s',strtotime('-1 day'))]);
    $insertFuel->execute([uid(),$vehicleIds[1],$userIds[3],76150,35.00,11900,0,date('Y-m-d H:i:s',strtotime('-1 day'))]);

    $insertAlert = $pdo->prepare('INSERT INTO alerts (id,org_id,vehicle_id,service_rule_id,type,message,resolved) VALUES (?,?,?,?,?,?,FALSE)');
    $insertAlert->execute([uid(),$orgId,$vehicleIds[1],$ruleIds[1],'SERVICE_DUE','Isuzu ELF is due for its 76,000 km service interval.']);
    $insertAlert->execute([uid(),$orgId,$vehicleIds[1],null,'LICENSE_EXPIRY','Revenue license expires in 45 days.']);

    $pdo->commit();
    fwrite(STDOUT, "Demo data added. Sign in with demo.manager@fleetops.local and password {$demoPassword}\nMechanic and driver accounts use the same demo password.\n");
} catch (Throwable $error) {
    if (isset($pdo) && $pdo->inTransaction()) $pdo->rollBack();
    fwrite(STDERR, 'Demo setup failed: ' . $error->getMessage() . "\n");
    exit(1);
}
