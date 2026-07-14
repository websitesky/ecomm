$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$pagePath = Join-Path $root 'video-fullscreen.html'
$photoPath = Join-Path $root 'photo-benefits.html'
$splitVideoPath = Join-Path $root 'video-variant.html'
$cssPath = Join-Path $root 'styles.css'
$videoPath = Join-Path $root '1.mp4'
$posterPath = Join-Path $root 'assets/hero-solar-home.jpg'

$page = if (Test-Path -LiteralPath $pagePath) {
  Get-Content -Raw -Encoding utf8 -LiteralPath $pagePath
} else { '' }
$photo = Get-Content -Raw -Encoding utf8 -LiteralPath $photoPath
$splitVideo = Get-Content -Raw -Encoding utf8 -LiteralPath $splitVideoPath
$css = Get-Content -Raw -Encoding utf8 -LiteralPath $cssPath
$copyPanel = [regex]::Match($page, '(?s)<div class="fullscreen-copy-panel">(?<content>.*?)</div>\s*<div class="hero-actions fullscreen-actions"')

function Decode-Utf8([string]$base64) {
  return [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($base64))
}

$headline = Decode-Utf8 '0IbQvdCy0LXRgNGC0L7RgNC4INGC0LAg0YHQvtC90Y/Rh9C90ZYg0L/QsNC90LXQu9GWINC00LvRjyDQstCw0YjQvtCz0L4g0LTQvtC80YMg0YLQsCDQsdGW0LfQvdC10YHRgw=='
$subheadline = Decode-Utf8 '0JzQtdC90YjQtSDQt9Cw0LvQtdC20L3QvtGB0YLRliDQstGW0LQg0LzQtdGA0LXQttGWIOKAlCDQsdGW0LvRjNGI0LUg0YHQv9C+0LrQvtGOINGC0LAg0LrQvtC90YLRgNC+0LvRjg=='
$catalogCta = Decode-Utf8 '0J/QtdGA0LXQudGC0Lgg0LTQviDQutCw0YLQsNC70L7Qs9GD'
$selectionCta = Decode-Utf8 '0JTQvtC/0L7QvNC+0LPQsCDRgyDQv9GW0LTQsdC+0YDRlg=='

$checks = [ordered]@{
  'fullscreen page exists' = Test-Path -LiteralPath $pagePath
  'photo page remains image based' = $photo.Contains('class="hero-image"') -and -not $photo.Contains('fullscreen-video-variant')
  'split video page remains separate' = $splitVideo.Contains('class="photo-benefits-variant video-variant"') -and -not $splitVideo.Contains('fullscreen-video-variant')
  'variant body class' = $page.Contains('class="fullscreen-video-variant"')
  'versioned stylesheet' = $page.Contains('href="styles.css?v=fullscreen-smoke-panel-20260714"')
  'no sync script' = -not $page.Contains('fullscreen-video-sync.js')
  'fullscreen hero' = $page.Contains('class="fullscreen-video-hero"')
  'video element' = $page.Contains('<video') -and $page.Contains('class="fullscreen-hero-video"')
  'autoplay muted loop inline' = $page.Contains('autoplay') -and $page.Contains('muted') -and $page.Contains('loop') -and $page.Contains('playsinline')
  'metadata preload' = $page.Contains('preload="metadata"')
  'video source exists' = (Test-Path -LiteralPath $videoPath) -and $page.Contains('src="1.mp4"') -and $page.Contains('type="video/mp4"')
  'poster exists' = (Test-Path -LiteralPath $posterPath) -and $page.Contains('poster="assets/hero-solar-home.jpg"')
  'decorative video has no controls' = $page.Contains('aria-hidden="true"') -and -not $page.Contains(' controls')
  'content hook' = $page.Contains('class="fullscreen-hero-content"')
  'headline' = $page.Contains($headline)
  'subheadline' = $page.Contains($subheadline)
  'three benefits' = ([regex]::Matches($page, '<li>')).Count -eq 3
  'two calls to action' = $page.Contains($catalogCta) -and $page.Contains($selectionCta)
  'scoped CSS root' = $css.Contains('.fullscreen-video-variant')
  'desktop fullscreen height' = $css.Contains('min-height: 100svh;')
  'video cover' = $css.Contains('.fullscreen-hero-video') -and $css.Contains('object-fit: cover;')
  'lower-left content' = $css.Contains('.fullscreen-hero-content') -and $css.Contains('margin-top: auto;')
  'copy panel structure' = $copyPanel.Success
  'required copy inside panel' = $copyPanel.Success -and $copyPanel.Groups['content'].Value.Contains('class="eyebrow"') -and $copyPanel.Groups['content'].Value.Contains('<h1') -and $copyPanel.Groups['content'].Value.Contains('class="fullscreen-subheadline"') -and $copyPanel.Groups['content'].Value.Contains('class="fullscreen-benefits"')
  'actions outside panel' = $copyPanel.Success -and -not $copyPanel.Groups['content'].Value.Contains('fullscreen-actions')
  'smoke panel style' = $css.Contains('.fullscreen-copy-panel') -and $css.Contains('rgba(5, 8, 15, 0.52)') -and $css.Contains('backdrop-filter: blur(4px);')
  'desktop copy spacing' = $css.Contains('.fullscreen-copy-panel h1') -and $css.Contains('margin-top: 20px;') -and $css.Contains('margin-top: 18px;')
  'mobile panel padding' = $css.Contains('padding: 14px 14px 16px;')
  'mobile benefit spacing' = $css.Contains('gap: 9px;')
  'mobile panel to actions spacing' = $css.Contains('margin-top: 24px;')
  'no darkness variable' = -not $css.Contains('--scene-darkness')
  'no local video overlay' = -not $css.Contains('.fullscreen-video-hero::before')
  'no global video overlay' = -not $css.Contains('.fullscreen-video-hero::after')
  'native video appearance' = $css.Contains('.fullscreen-hero-video') -and $css.Contains('object-fit: cover;') -and -not $css.Contains('filter: brightness')
  'responsive rules' = $css.Contains('@media (max-width: 1024px)') -and $css.Contains('@media (max-width: 640px)')
}

$failed = @($checks.GetEnumerator() | Where-Object { -not $_.Value } | ForEach-Object Key)
if ($failed.Count -gt 0) { throw ('Fullscreen video failures: ' + ($failed -join ', ')) }
Write-Output ('PASS: {0}/{0} fullscreen video checks' -f $checks.Count)
