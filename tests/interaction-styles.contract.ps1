$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$css = Get-Content -Raw -Encoding utf8 -LiteralPath (Join-Path $root 'styles.css')

$checks = [ordered]@{
  'hero clip overflow' = $css.Contains('overflow: clip;')
  'sticky header' = $css.Contains('position: sticky;')
  'sticky top' = $css.Contains('top: 12px;')
  'sticky layer' = $css.Contains('z-index: 30;')
  'nav gradient underline' = $css.Contains('linear-gradient(90deg, #75a7ff 0%, var(--blue) 52%, var(--blue-deep) 100%)')
  'nav hover lift' = $css.Contains('transform: translateY(-1px);')
  'button shine' = $css.Contains('.btn::before') -and $css.Contains('skewX(-18deg)')
  'button shine hover' = $css.Contains('.btn:hover::before') -and $css.Contains('.btn:focus-visible::before')
  'primary gradient' = $css.Contains('linear-gradient(120deg, var(--blue-deep) 0%, var(--blue) 55%, #61a0ff 100%)')
  'moving gradient' = $css.Contains('background-size: 200% 100%;') -and $css.Contains('background-position: 100% 50%;')
  'secondary gradient' = $css.Contains('linear-gradient(135deg, var(--paper) 0%, #edf4ff 100%)')
  'shine reduced motion' = $css.Contains('.btn::before,') -and $css.Contains('.btn:hover::before,')
}

$failed = @($checks.GetEnumerator() | Where-Object { -not $_.Value } | ForEach-Object Key)
if ($failed.Count -gt 0) { throw ('Interaction style failures: ' + ($failed -join ', ')) }
Write-Output ('PASS: {0}/{0} interaction style checks' -f $checks.Count)
