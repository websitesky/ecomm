$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$htmlPath = Join-Path $root 'index.html'
$cssPath = Join-Path $root 'styles.css'
$imagePath = Join-Path $root 'assets/hero-solar-home.jpg'
$html = Get-Content -Raw -Encoding utf8 -LiteralPath $htmlPath
$css = Get-Content -Raw -Encoding utf8 -LiteralPath $cssPath

function Decode-Utf8([string]$base64) {
  return [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($base64))
}

$headline = Decode-Utf8 '0IbQvdCy0LXRgNGC0L7RgNC4INGC0LAg0YHQvtC90Y/Rh9C90ZYg0L/QsNC90LXQu9GWINC00LvRjyDQstCw0YjQvtCz0L4g0LTQvtC80YMg0YLQsCDQsdGW0LfQvdC10YHRgw=='
$subheadlineAccent = Decode-Utf8 '0JzQtdC90YjQtSDQt9Cw0LvQtdC20L3QvtGB0YLRliDQstGW0LQg0LzQtdGA0LXQttGW'
$subheadlineRest = Decode-Utf8 '0LHRltC70YzRiNC1INGB0L/QvtC60L7RjiDRgtCwINC60L7QvdGC0YDQvtC70Y4u'
$benefits = @(
  (Decode-Utf8 '0JbQuNCy0LvQtdC90L3RjyDQv9GW0LQg0YfQsNGBINCy0ZbQtNC60LvRjtGH0LXQvdGM'),
  (Decode-Utf8 '0JXQutC+0L3QvtC80L3RltGI0LUg0YHQv9C+0LbQuNCy0LDQvdC90Y8g0LXQvdC10YDQs9GW0Zc='),
  (Decode-Utf8 '0KHQuNGB0YLQtdC80LAsINGJ0L4g0LfRgNC+0YHRgtCw0ZQg0YDQsNC30L7QvCDRltC3INCy0LDRiNC40LzQuCDQv9C+0YLRgNC10LHQsNC80Lg=')
)
$catalogCta = Decode-Utf8 '0J/QtdGA0LXQudGC0Lgg0LTQviDQutCw0YLQsNC70L7Qs9GD'
$selectionCta = Decode-Utf8 '0JTQvtC/0L7QvNC+0LPQsCDRgyDQv9GW0LTQsdC+0YDRlg=='

$checks = [ordered]@{
  'local hero image' = Test-Path -LiteralPath $imagePath
  'exact headline' = $html.Contains($headline)
  'highlighted subheadline' = $html.Contains('class="lead-accent"') -and $html.Contains($subheadlineAccent) -and $html.Contains($subheadlineRest)
  'all benefits' = @($benefits | Where-Object { -not $html.Contains($_) }).Count -eq 0
  'benefits semantics' = $html.Contains('class="hero-benefits"') -and $html.Contains('<ul') -and $html.Contains('<li')
  'benefits styles' = $css.Contains('.hero-benefits') -and $css.Contains('.benefit-icon')
  'catalog CTA' = $html.Contains($catalogCta)
  'selection CTA' = $html.Contains($selectionCta)
  'media figure' = $html.Contains('class="hero-media"')
  'semantic image' = $html.Contains('src="assets/hero-solar-home.jpg"') -and $html.Contains('class="hero-image"')
  'blue palette' = $css.Contains('--blue-deep: #1a237e;') -and $css.Contains('--blue: #2979ff;')
  'ken burns keyframes' = $css.Contains('@keyframes hero-ken-burns')
  'ken burns timing' = $css.Contains('20s ease-in-out infinite alternate')
  'tablet breakpoint' = $css.Contains('@media (max-width: 1024px)')
  'tablet media sizing' = $css.Contains('min-height: clamp(460px, 58vw, 580px);')
  'compact tablet media sizing' = $css.Contains('min-height: 480px;')
  'mobile breakpoint' = $css.Contains('@media (max-width: 640px)')
  'reduced motion' = $css.Contains('@media (prefers-reduced-motion: reduce)')
  'focus styles' = $css.Contains(':focus-visible')
}

$failed = @($checks.GetEnumerator() | Where-Object { -not $_.Value } | ForEach-Object Key)

if ($failed.Count -gt 0) {
  throw ('Hero contract failures: ' + ($failed -join ', '))
}

Write-Output ('PASS: {0}/{0} hero contract checks' -f $checks.Count)
