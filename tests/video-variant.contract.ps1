$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$videoPagePath = Join-Path $root 'video-variant.html'
$photoPagePath = Join-Path $root 'photo-benefits.html'
$cssPath = Join-Path $root 'styles.css'
$videoPath = Join-Path $root '1.mp4'
$posterPath = Join-Path $root 'assets/hero-solar-home.jpg'

$videoPage = if (Test-Path -LiteralPath $videoPagePath) {
  Get-Content -Raw -Encoding utf8 -LiteralPath $videoPagePath
} else { '' }
$photoPage = Get-Content -Raw -Encoding utf8 -LiteralPath $photoPagePath
$css = Get-Content -Raw -Encoding utf8 -LiteralPath $cssPath

function Decode-Utf8([string]$base64) {
  return [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($base64))
}

$statement = Decode-Utf8 '0JzQtdC90YjQtSDQt9Cw0LvQtdC20L3QvtGB0YLRliDQstGW0LQg0LzQtdGA0LXQttGWIOKAlCDQsdGW0LvRjNGI0LUg0YHQv9C+0LrQvtGOINGC0LAg0LrQvtC90YLRgNC+0LvRjg=='

$checks = [ordered]@{
  'video page exists' = Test-Path -LiteralPath $videoPagePath
  'photo page preserved as image' = $photoPage.Contains('class="hero-image"') -and -not $photoPage.Contains('<video')
  'video body classes' = $videoPage.Contains('class="photo-benefits-variant video-variant"')
  'video element' = $videoPage.Contains('<video') -and $videoPage.Contains('class="hero-video"')
  'autoplay' = $videoPage.Contains('autoplay')
  'muted' = $videoPage.Contains('muted')
  'loop' = $videoPage.Contains('loop')
  'plays inline' = $videoPage.Contains('playsinline')
  'metadata preload' = $videoPage.Contains('preload="metadata"')
  'poster' = (Test-Path -LiteralPath $posterPath) -and $videoPage.Contains('poster="assets/hero-solar-home.jpg"')
  'mp4 source' = (Test-Path -LiteralPath $videoPath) -and $videoPage.Contains('src="1.mp4"')
  'mp4 type' = $videoPage.Contains('type="video/mp4"')
  'decorative video' = $videoPage.Contains('aria-hidden="true"') -and -not $videoPage.Contains('controls')
  'statement preserved' = $videoPage.Contains('class="photo-statement"') -and $videoPage.Contains($statement)
  'video cover styles' = $css.Contains('.hero-video') -and $css.Contains('object-fit: cover;') -and $css.Contains('object-position: center 42%;')
}

$failed = @($checks.GetEnumerator() | Where-Object { -not $_.Value } | ForEach-Object Key)
if ($failed.Count -gt 0) { throw ('Video variant failures: ' + ($failed -join ', ')) }
Write-Output ('PASS: {0}/{0} video variant checks' -f $checks.Count)
