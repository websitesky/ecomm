$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$pagePath = Join-Path $root 'approved-hero.html'
$videoPath = Join-Path $root '1.mp4'
$posterPath = Join-Path $root 'assets/hero-solar-home.jpg'

$page = if (Test-Path -LiteralPath $pagePath) {
  Get-Content -Raw -Encoding utf8 -LiteralPath $pagePath
} else { '' }

function Decode-Utf8([string]$base64) {
  return [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($base64))
}

$headline = Decode-Utf8 '0IbQvdCy0LXRgNGC0L7RgNC4INGC0LAg0YHQvtC90Y/Rh9C90ZYg0L/QsNC90LXQu9GWINC00LvRjyDQstCw0YjQvtCz0L4g0LTQvtC80YMg0YLQsCDQsdGW0LfQvdC10YHRgw=='
$promise = Decode-Utf8 '0JzQtdC90YjQtSDQt9Cw0LvQtdC20L3QvtGB0YLRliDQstGW0LQg0LzQtdGA0LXQttGWIOKAlCDQsdGW0LvRjNGI0LUg0YHQv9C+0LrQvtGOINGC0LAg0LrQvtC90YLRgNC+0LvRjg=='
$catalogCta = Decode-Utf8 '0J/QtdGA0LXQudGC0Lgg0LTQviDQutCw0YLQsNC70L7Qs9GD'
$selectionCta = Decode-Utf8 '0JTQvtC/0L7QvNC+0LPQsCDRgyDQv9GW0LTQsdC+0YDRlg=='
$menuLabel = Decode-Utf8 '0JLRltC00LrRgNC40YLQuCDQvNC10L3Rjg=='

$checks = [ordered]@{
  'approved page exists' = Test-Path -LiteralPath $pagePath
  'ukrainian responsive document' = $page.Contains('lang="uk"') -and $page.Contains('name="viewport"')
  'approved variant marker' = $page.Contains('class="approved-hybrid-variant"')
  'video source and poster exist' = (Test-Path -LiteralPath $videoPath) -and (Test-Path -LiteralPath $posterPath) -and $page.Contains('src="1.mp4"') -and $page.Contains('poster="assets/hero-solar-home.jpg"')
  'video playback attributes' = $page.Contains('autoplay') -and $page.Contains('muted') -and $page.Contains('loop') -and $page.Contains('playsinline')
  'approved headline' = $page.Contains($headline)
  'approved promise' = $page.Contains($promise)
  'three benefits' = ([regex]::Matches($page, '<li>')).Count -eq 3 -and ([regex]::Matches($page, 'class="approved-check"')).Count -eq 3
  'two calls to action' = $page.Contains($catalogCta) -and $page.Contains($selectionCta) -and ([regex]::Matches($page, 'class="approved-button')).Count -eq 2
  'desktop navigation and phone' = $page.Contains('class="approved-nav"') -and $page.Contains('+38 (067) 123-45-67')
  'mobile menu control' = $page.Contains('class="approved-menu"') -and $page.Contains(('aria-label="{0}"' -f $menuLabel))
  'desktop lower composition' = $page.Contains('grid-template-columns: minmax(310px, 1.2fr) minmax(300px, 1fr) 240px;')
  'single mobile breakpoint' = $page.Contains('@media (max-width: 720px)') -and $page.Contains('.approved-nav,') -and $page.Contains('display: none;')
  'mobile stacked composition' = $page.Contains('grid-template-columns: 1fr;') -and $page.Contains('height: 325px;')
  'edge crop hides video corner mark' = $page.Contains('transform: scale(1.035);')
  'animated buttons' = $page.Contains('@keyframes approved-button-shine') -and $page.Contains('animation: approved-button-shine') -and $page.Contains(':hover')
  'reduced motion support' = $page.Contains('@media (prefers-reduced-motion: reduce)')
  'no artificial video dark overlay' = -not $page.Contains('.approved-video-area::before') -and -not $page.Contains('.approved-video-area::after')
}

$failed = @($checks.GetEnumerator() | Where-Object { -not $_.Value } | ForEach-Object Key)
if ($failed.Count -gt 0) { throw ('Approved hero failures: ' + ($failed -join ', ')) }
Write-Output ('PASS: {0}/{0} approved hero checks' -f $checks.Count)
