<?php
// scrape_hma.php — demo scraper with 15-minute cache
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *'); // demo only

$url = "https://hmacanada.org/halal-check/";
$categoryFilter = isset($_GET['category']) ? trim($_GET['category']) : null;
$query = isset($_GET['q']) ? trim($_GET['q']) : null;

// --- simple cache ---
$cacheDir = __DIR__ . '/cache';
if (!is_dir($cacheDir)) { @mkdir($cacheDir, 0775, true); }
$cacheFile = $cacheDir . '/hma.json';
$ttl = 900; // 15 minutes

if (file_exists($cacheFile) && (time() - filemtime($cacheFile) < $ttl)) {
  echo file_get_contents($cacheFile);
  exit;
}

function fetch_html($url) {
  $ch = curl_init($url);
  curl_setopt_array($ch, [
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_FOLLOWLOCATION => true,
    CURLOPT_USERAGENT      => 'HalalSure-Demo/1.0'
  ]);
  $html = curl_exec($ch);
  curl_close($ch);
  return $html;
}

$html = fetch_html($url);
if (!$html) { echo json_encode(["error"=>"fetch_failed"]); exit; }

libxml_use_internal_errors(true);
$dom = new DOMDocument();
$dom->loadHTML($html);
$xpath = new DOMXPath($dom);

$rows = $xpath->query("//table//tr");
$out = [];

foreach ($rows as $tr) {
  $cells = $tr->getElementsByTagName('td');
  if ($cells->length < 3) continue;

  $name  = trim($cells->item(0)->textContent ?? '');
  $brand = trim($cells->item(1)->textContent ?? '');
  $cat   = trim($cells->item(2)->textContent ?? '');
  $stat  = trim($cells->item(3)->textContent ?? '');
  $date  = $cells->length > 4 ? trim($cells->item(4)->textContent ?? '') : null;
  $upc   = $cells->length > 5 ? trim($cells->item(5)->textContent ?? '') : null;

  if (!$name) continue;
  if ($categoryFilter && stripos($cat, $categoryFilter) === false) continue;
  if ($query) {
    $needle = strtolower($query);
    $hay = strtolower("$name $brand $cat $stat $upc");
    if (strpos($hay, $needle) === false) continue;
  }

  $out[] = [
    "id"          => $upc ?: md5($name.$brand.$cat.$stat),
    "name"        => $name,
    "brand"       => $brand ?: null,
    "category"    => $cat ?: null,
    "status"      => $stat ?: null,
    "lastChecked" => $date,
    "upc"         => $upc,
    "source"      => $url
  ];
}

$json = json_encode(array_values($out), JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
file_put_contents($cacheFile, $json);
echo $json;
