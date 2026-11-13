<?php
declare(strict_types=1);

// Small environment loader. Production hosts should set these values directly.
$envFile = dirname(__DIR__) . '/.env';
if (is_file($envFile)) {
    foreach (file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        if (str_starts_with(trim($line), '#') || !str_contains($line, '=')) continue;
        [$key, $value] = explode('=', $line, 2);
        if (getenv(trim($key)) === false) putenv(trim($key) . '=' . trim(trim($value), " \t\n\r\0\x0B\"'"));
    }
}
$https = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') || (($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '') === 'https');
session_set_cookie_params(['httponly' => true, 'secure' => $https, 'samesite' => 'Lax', 'path' => '/']);
session_start();

function db(): PDO {
    static $pdo;
    if ($pdo instanceof PDO) return $pdo;
    $host = getenv('DB_HOST'); $name = getenv('DB_NAME') ?: 'fleetdb';
    if (!$host || !getenv('DB_USER')) throw new RuntimeException('Database connection is not configured. Add the database settings to .env.');
    $dsn = 'mysql:host=' . $host . ';port=' . (getenv('DB_PORT') ?: '3306') . ';dbname=' . $name . ';charset=utf8mb4';
    $opts = [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC, PDO::ATTR_EMULATE_PREPARES => false];
    $sslCa = getenv('DB_SSL_CA');
    if ($sslCa) {
        // Resolve relative CA paths from the repository root so CLI and web SAPIs agree.
        if (!str_starts_with($sslCa, DIRECTORY_SEPARATOR)) $sslCa = dirname(__DIR__) . '/' . $sslCa;
        // Some local PHP servers cannot read a CA stored outside the project. Use the
        // checked-in Aiven CA only when the configured path is unavailable.
        if (!is_file($sslCa) || !is_readable($sslCa)) {
            $projectCa = dirname(__DIR__) . '/certs/ca.pem';
            if (is_file($projectCa) && is_readable($projectCa)) $sslCa = $projectCa;
            else throw new RuntimeException('The configured database CA certificate is not readable. Set DB_SSL_CA to a readable CA file.');
        }
        $opts[PDO::MYSQL_ATTR_SSL_CA] = $sslCa;
    }
    return $pdo = new PDO($dsn, getenv('DB_USER'), getenv('DB_PASSWORD') ?: '', $opts);
}
function e(mixed $v): string { return htmlspecialchars((string)$v, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8'); }
function uid(): string { return sprintf('%04x%04x-%04x-4%03x-%04x-%04x%08x', random_int(0,65535),random_int(0,65535),random_int(0,65535),random_int(0,4095),random_int(0,16383)|0x8000,random_int(0,65535),random_int(0,65535)); }
function user(): ?array { return $_SESSION['user'] ?? null; }
function require_login(): array { if (!user()) { header('Location: ?page=login'); exit; } return user(); }
function can(string ...$roles): bool { return user() && in_array(user()['role'], $roles, true); }
function require_role(string ...$roles): void { require_login(); if (!can(...$roles)) { http_response_code(403); exit('Access denied'); } }
function csrf(): string { return $_SESSION['csrf'] ??= bin2hex(random_bytes(32)); }
function verify_csrf(): void { if (!hash_equals(csrf(), $_POST['csrf'] ?? '')) { http_response_code(419); exit('Form expired. Go back and try again.'); } }
function notice(string $text, string $kind='success'): void { $_SESSION['notice'] = [$text,$kind]; }
function redirect(string $page): never { header('Location: ?page=' . urlencode($page)); exit; }
function friendly_db_error(PDOException $error): string {
    $driverCode = (int)($error->errorInfo[1] ?? 0);
    error_log('FleetOps database error [' . $driverCode . ']: ' . $error->getMessage());
    return match ($driverCode) {
        1045 => 'The database rejected the username or password. Check DB_USER and DB_PASSWORD in .env.',
        1049 => 'The database name was not found. Check DB_NAME in .env.',
        1146 => 'The FleetOps tables are missing. Import database/schema.sql into this database, then try again.',
        2002, 2003, 2005 => 'FleetOps could not reach the database host. Check DB_HOST, DB_PORT, and your network connection.',
        default => 'The database request failed. Check your .env settings and confirm the FleetOps schema is installed.',
    };
}
function scoped_vehicle(string $id): array { $s=db()->prepare('SELECT * FROM vehicles WHERE id=? AND org_id=? AND deleted_at IS NULL'); $s->execute([$id,user()['org_id']]); $v=$s->fetch(); if(!$v) throw new RuntimeException('Vehicle not found.'); return $v; }
