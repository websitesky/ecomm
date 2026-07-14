$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$variantPath = Join-Path $root 'photo-benefits.html'
$indexPath = Join-Path $root 'index.html'
$cssPath = Join-Path $root 'styles.css'
$imagePath = Join-Path $root 'assets/hero-solar-home.jpg'

if (-not (Test-Path -LiteralPath $variantPath)) {
  throw 'Photo benefits variant is missing'
}

$variant = Get-Content -Raw -Encoding utf8 -LiteralPath $variantPath
$index = Get-Content -Raw -Encoding utf8 -LiteralPath $indexPath
$css = Get-Content -Raw -Encoding utf8 -LiteralPath $cssPath
$figure = [regex]::Match($variant, '(?s)<figure class="hero-media">(?<content>.*?)</figure>')
$copy = [regex]::Match($variant, '(?s)<div class="hero-copy">(?<content>.*?)</div>')
$benefitCount = [regex]::Matches($variant, 'class="hero-benefits"').Count

function Decode-Utf8([string]$base64) {
  return [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($base64))
}

$benefits = @(
  (Decode-Utf8 '0JbQuNCy0LvQtdC90L3RjyDQv9GW0LQg0YfQsNGBINCy0ZbQtNC60LvRjtGH0LXQvdGM'),
  (Decode-Utf8 '0JXQutC+0L3QvtC80L3RltGI0LUg0YHQv9C+0LbQuNCy0LDQvdC90Y8g0LXQvdC10YDQs9GW0Zc='),
  (Decode-Utf8 '0KHQuNGB0YLQtdC80LAsINGJ0L4g0LfRgNC+0YHRgtCw0ZQg0YDQsNC30L7QvCDRltC3INCy0LDRiNC40LzQuCDQv9C+0YLRgNC10LHQsNC80Lg=')
)
$statement = Decode-Utf8 '0JzQtdC90YjQtSDQt9Cw0LvQtdC20L3QvtGB0YLRliDQstGW0LQg0LzQtdGA0LXQttGWIOKAlCDQsdGW0LvRjNGI0LUg0YHQv9C+0LrQvtGOINGC0LAg0LrQvtC90YLRgNC+0LvRjg=='

$checks = [ordered]@{
  'original remains standard' = $index.Contains('<ul class="hero-benefits"') -and -not $index.Contains('photo-benefits-variant')
  'variant body class' = $variant.Contains('class="photo-benefits-variant"')
  'single benefits list' = $benefitCount -eq 1
  'benefits inside copy' = $copy.Success -and $copy.Groups['content'].Value.Contains('class="hero-benefits"')
  'benefits before actions' = $copy.Groups['content'].Value.IndexOf('class="hero-benefits"') -lt $copy.Groups['content'].Value.IndexOf('class="hero-actions"')
  'all benefits present' = @($benefits | Where-Object { -not $variant.Contains($_) }).Count -eq 0
  'statement inside photo' = $figure.Success -and $figure.Groups['content'].Value.Contains('class="photo-statement"') -and $variant.Contains($statement)
  'old lead removed' = -not $copy.Groups['content'].Value.Contains('class="lead"')
  'local image' = (Test-Path -LiteralPath $imagePath) -and $variant.Contains('src="assets/hero-solar-home.jpg"')
  'neutral gradient style' = $css.Contains('.photo-benefits-variant .hero-media::after') -and $css.Contains('rgba(5, 9, 18, 0.76)')
  'statement styles' = $css.Contains('.photo-statement') -and $css.Contains('color: var(--paper);')
  'old blue card removed' = -not $css.Contains('background: rgba(16, 27, 92, 0.82);')
  'mobile statement size' = $css.Contains('font-size: 25px;')
}

$failed = @($checks.GetEnumerator() | Where-Object { -not $_.Value } | ForEach-Object Key)
if ($failed.Count -gt 0) {
  throw ('Photo benefits contract failures: ' + ($failed -join ', '))
}

Write-Output ('PASS: {0}/{0} photo benefits checks' -f $checks.Count)
