<?php
// /Applications/XAMPP/xamppfiles/htdocs/halalsure-api/proxy.php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json; charset=utf-8');

$url = filter_input(INPUT_GET, 'url', FILTER_VALIDATE_URL);
if (!$url) {
  http_response_code(400);
  echo json_encode(['error' => 'Missing or invalid ?url parameter']);
  exit;
}

$ch = curl_init($url);
curl_setopt_array($ch, [
  CURLOPT_RETURNTRANSFER => true,
  CURLOPT_FOLLOWLOCATION => true,
  CURLOPT_USERAGENT => 'HalalSureDevProxy/1.0 (+localhost)',
  CURLOPT_TIMEOUT => 15
]);
$body = curl_exec($ch);
$err  = curl_error($ch);
$code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($body === false) {
  http_response_code(502);
  echo json_encode(['error' => $err ?: 'Fetch failed']);
  exit;
}

// For demo we return the raw HTML. You can later parse this here and return clean JSON.
echo json_encode([
  'status' => $code,
  'url'    => $url,
  'html'   => $body
], JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);

