<?php
// Run once from a trusted terminal: php scripts/create-manager.php
require dirname(__DIR__) . '/app/bootstrap.php';
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
function ask(string $label): string { fwrite(STDOUT, $label); return trim((string)fgets(STDIN)); }
try {
    $pdo=db();
    $existing=(int)$pdo->query("SELECT COUNT(*) FROM users WHERE role='FLEET_MANAGER'")->fetchColumn();
    if($existing>0) { fwrite(STDERR,"A fleet manager already exists. Use the application to manage access.\n"); exit(1); }
    $org=ask('Organization name: '); $name=ask('Manager full name: '); $email=strtolower(ask('Manager email: '));
    fwrite(STDOUT,'Password (12+ characters): ');
    if (function_exists('shell_exec')) @shell_exec('stty -echo');
    $password=trim((string)fgets(STDIN));
    if (function_exists('shell_exec')) @shell_exec('stty echo');
    fwrite(STDOUT,"\n");
    if(!$org||!$name||!filter_var($email,FILTER_VALIDATE_EMAIL)||strlen($password)<12) throw new RuntimeException('Provide an organization, name, valid email, and a password of at least 12 characters.');
    $pdo->beginTransaction(); $orgId=uid(); $pdo->prepare('INSERT INTO organizations (id,name) VALUES (?,?)')->execute([$orgId,$org]);
    $pdo->prepare('INSERT INTO users (id,org_id,name,email,password_hash,role) VALUES (?,?,?,?,?,?)')->execute([uid(),$orgId,$name,$email,password_hash($password,PASSWORD_DEFAULT),'FLEET_MANAGER']);
    $pdo->commit(); fwrite(STDOUT,"Manager account created. You can sign in at the application URL.\n");
} catch(Throwable $e) { if(isset($pdo)&&$pdo->inTransaction())$pdo->rollBack(); fwrite(STDERR,'Setup failed: '.$e->getMessage()."\n"); exit(1); }
