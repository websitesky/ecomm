# SolarPro Brand Marquee Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a premium, responsive social-proof section with a seamless full-color brand-logo marquee directly below the approved SolarPro first screen.

**Architecture:** Keep the feature self-contained inside `approved-hero.html`: semantic list markup for two identical logo groups and scoped CSS for layout, animation, pause states, edge fading, mobile behavior, and reduced motion. Store the eight logo assets locally under `assets/brands/` so GitHub Pages does not depend on external image hosts. Add one PowerShell contract test that verifies the section, assets, copy, accessibility, animation, and responsive contract.

**Tech Stack:** Static HTML5, scoped CSS3, SVG brand assets, PowerShell contract tests, GitHub Pages.

## Global Constraints

- Do not change the current video hero, header, title, promise, benefits, buttons, or their responsive behavior.
- The section title is exactly `Обладнання провідних світових брендів`.
- The brands are exactly Deye, Huawei, Jinko Solar, Growatt, Solis, Victron Energy, JA Solar, and LONGi Solar.
- Logos remain in their real full-color brand treatment at rest and on hover.
- The section background is `#FFFFFF`; logos have no cards, frames, or colored containers.
- The desktop animation cycle is `30s`; the mobile cycle is `24s`.
- CSS provides the animation; do not add JavaScript.
- The marquee pauses on hover and keyboard focus.
- `prefers-reduced-motion: reduce` disables movement and displays one wrapped static set.
- No other HTML variant is modified.

---

### Task 1: Add the failing brand-marquee contract

**Files:**
- Create: `tests/brand-marquee.contract.ps1`
- Test: `tests/brand-marquee.contract.ps1`

**Interfaces:**
- Consumes: `approved-hero.html` and the expected files under `assets/brands/`.
- Produces: a single contract that fails until the section, eight assets, and all required CSS behaviors exist.

- [ ] **Step 1: Create the contract test**

Create `tests/brand-marquee.contract.ps1` with this complete content:

```powershell
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$pagePath = Join-Path $root 'approved-hero.html'
$page = Get-Content -Raw -Encoding utf8 -LiteralPath $pagePath

function Decode-Utf8([string]$base64) {
  return [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($base64))
}

$heading = Decode-Utf8 '0J7QsdC70LDQtNC90LDQvdC90Y8g0L/RgNC+0LLRltC00L3QuNGFINGB0LLRltGC0L7QstC40YUg0LHRgNC10L3QtNGW0LI='
$brands = [ordered]@{
  'Deye' = 'assets/brands/deye.svg'
  'Huawei' = 'assets/brands/huawei.svg'
  'Jinko Solar' = 'assets/brands/jinko-solar.svg'
  'Growatt' = 'assets/brands/growatt.svg'
  'Solis' = 'assets/brands/solis.svg'
  'Victron Energy' = 'assets/brands/victron-energy.svg'
  'JA Solar' = 'assets/brands/ja-solar.svg'
  'LONGi Solar' = 'assets/brands/longi-solar.svg'
}

$assetChecks = foreach ($entry in $brands.GetEnumerator()) {
  $assetPath = Join-Path $root $entry.Value
  $asset = if (Test-Path -LiteralPath $assetPath) {
    Get-Content -Raw -Encoding utf8 -LiteralPath $assetPath
  } else { '' }
  (Test-Path -LiteralPath $assetPath) -and
    $asset.Contains('<svg') -and
    $asset.Contains('viewBox=') -and
    -not $asset.Contains('<script') -and
    $page.Contains(('src="{0}"' -f $entry.Value)) -and
    $page.Contains(('alt="{0}"' -f $entry.Key))
}

$checks = [ordered]@{
  'social proof section' = $page.Contains('class="brand-proof"') -and $page.Contains('aria-labelledby="brand-proof-title"')
  'exact heading' = $page.Contains(('id="brand-proof-title">{0}</h2>' -f $heading))
  'eight valid local brand assets' = @($assetChecks | Where-Object { $_ }).Count -eq 8
  'two seamless groups' = ([regex]::Matches($page, 'class="brand-group"')).Count -eq 2
  'duplicate group hidden from assistive tech' = $page.Contains('class="brand-group" aria-hidden="true"')
  'focusable marquee' = $page.Contains('class="brand-marquee" tabindex="0"')
  'white edge fade' = $page.Contains('mask-image: linear-gradient') -and $page.Contains('-webkit-mask-image: linear-gradient')
  'desktop animation' = $page.Contains('@keyframes brand-marquee') -and $page.Contains('animation: brand-marquee 30s linear infinite;')
  'hover and focus pause' = $page.Contains('.brand-marquee:hover .brand-track') -and $page.Contains('.brand-marquee:focus-within .brand-track') -and $page.Contains('animation-play-state: paused;')
  'mobile animation' = $page.Contains('@media (max-width: 720px)') -and $page.Contains('animation-duration: 24s;')
  'reduced motion static set' = $page.Contains('@media (prefers-reduced-motion: reduce)') -and $page.Contains('.brand-group[aria-hidden="true"]') -and $page.Contains('animation: none;')
  'no javascript marquee' = -not $page.Contains('brand-marquee.js')
}

$failed = @($checks.GetEnumerator() | Where-Object { -not $_.Value } | ForEach-Object Key)
if ($failed.Count -gt 0) { throw ('Brand marquee failures: ' + ($failed -join ', ')) }
Write-Output ('PASS: {0}/{0} brand marquee checks' -f $checks.Count)
```

- [ ] **Step 2: Run the new contract and verify RED**

Run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/brand-marquee.contract.ps1
```

Expected: FAIL listing `social proof section`, `eight valid local brand assets`, `desktop animation`, and the remaining missing marquee behaviors. This proves the test is exercising the absent feature rather than passing against existing markup.

- [ ] **Step 3: Commit the failing contract**

```powershell
git add tests/brand-marquee.contract.ps1
git commit -m "test: define SolarPro brand marquee contract"
```

---

### Task 2: Add verified full-color local logo assets

**Files:**
- Create: `assets/brands/deye.svg`
- Create: `assets/brands/huawei.svg`
- Create: `assets/brands/jinko-solar.svg`
- Create: `assets/brands/growatt.svg`
- Create: `assets/brands/solis.svg`
- Create: `assets/brands/victron-energy.svg`
- Create: `assets/brands/ja-solar.svg`
- Create: `assets/brands/longi-solar.svg`
- Test: `tests/brand-marquee.contract.ps1`

**Interfaces:**
- Consumes: the eight filenames fixed by the contract.
- Produces: self-contained, script-free SVG wordmarks with transparent backgrounds and preserved brand colors.

- [ ] **Step 1: Collect the horizontal full-color wordmark for each brand**

Use the corporate logo displayed by these official brand sites as the visual reference:

```text
Deye            https://www.deyeinverter.com/
Huawei Digital Power  https://solar.huawei.com/
Jinko Solar     https://www.jinkosolar.com/
Growatt         https://www.growatt.com/
Solis           https://www.solisinverters.com/
Victron Energy  https://www.victronenergy.com/
JA Solar        https://www.jasolar.com/
LONGi Solar     https://www.longi.com/
```

For each asset, retain the complete symbol and wordmark, preserve its original color fills, remove any opaque background rectangle, and save it under the exact filename listed above. Every SVG must have a `viewBox`, must not have fixed CSS positioning, must not embed raster data, and must not contain scripts, external stylesheets, or external image references.

- [ ] **Step 2: Validate the asset files**

Run:

```powershell
$files = Get-ChildItem assets/brands -Filter '*.svg'
if ($files.Count -ne 8) { throw "Expected 8 SVG logos, found $($files.Count)" }
$invalid = foreach ($file in $files) {
  $svg = Get-Content -Raw -Encoding utf8 -LiteralPath $file.FullName
  if (-not $svg.Contains('<svg') -or -not $svg.Contains('viewBox=') -or $svg.Contains('<script') -or $svg.Contains('data:image/')) { $file.Name }
}
if (@($invalid).Count -gt 0) { throw ('Invalid SVG assets: ' + ($invalid -join ', ')) }
'PASS: 8/8 SVG logo assets are local, vector, and script-free'
```

Expected: `PASS: 8/8 SVG logo assets are local, vector, and script-free`.

- [ ] **Step 3: Commit the brand assets**

```powershell
git add assets/brands
git commit -m "assets: add SolarPro partner brand logos"
```

---

### Task 3: Implement the semantic marquee and responsive CSS

**Files:**
- Modify: `approved-hero.html`
- Test: `tests/brand-marquee.contract.ps1`
- Test: `tests/approved-hero.contract.ps1`

**Interfaces:**
- Consumes: the eight SVG paths from Task 2 and the existing `.approved-hybrid-variant` first-screen container.
- Produces: `.brand-proof`, `.brand-marquee`, `.brand-track`, `.brand-group`, and `.brand-logo` as a self-contained second section.

- [ ] **Step 1: Add the marquee CSS before the existing responsive media rules**

Insert the following CSS after the `.approved-button.secondary:hover` rule and before `@keyframes approved-button-shine`:

```css
.brand-proof {
  overflow: hidden;
  padding: clamp(44px, 5vw, 72px) 0 clamp(48px, 5.5vw, 80px);
  border-top: 1px solid rgba(26, 35, 126, 0.08);
  background: #ffffff;
}

.brand-proof h2 {
  max-width: 860px;
  margin: 0 auto clamp(30px, 3.5vw, 48px);
  padding: 0 20px;
  color: #1a237e;
  font-size: clamp(28px, 3vw, 42px);
  font-weight: 800;
  line-height: 1.12;
  letter-spacing: -0.03em;
  text-align: center;
}

.brand-marquee {
  --brand-gap: clamp(52px, 6vw, 92px);
  width: 100%;
  overflow: hidden;
  outline: none;
  -webkit-mask-image: linear-gradient(to right, transparent, #000 7%, #000 93%, transparent);
  mask-image: linear-gradient(to right, transparent, #000 7%, #000 93%, transparent);
}

.brand-marquee:focus-visible {
  box-shadow: inset 0 0 0 3px rgba(41, 121, 255, 0.18);
}

.brand-track {
  display: flex;
  width: max-content;
  gap: var(--brand-gap);
  animation: brand-marquee 30s linear infinite;
  will-change: transform;
}

.brand-group {
  flex: 0 0 auto;
  display: flex;
  gap: var(--brand-gap);
  align-items: center;
  margin: 0;
  padding: 0;
  list-style: none;
}

.brand-group li {
  flex: 0 0 auto;
  display: grid;
  place-items: center;
}

.brand-logo {
  display: block;
  width: auto;
  max-width: 180px;
  height: clamp(34px, 3vw, 44px);
  object-fit: contain;
}

.brand-marquee:hover .brand-track,
.brand-marquee:focus-within .brand-track {
  animation-play-state: paused;
}

@keyframes brand-marquee {
  to {
    transform: translateX(calc(-50% - (var(--brand-gap) / 2)));
  }
}
```

- [ ] **Step 2: Add the second section immediately after `.approved-lower`**

Insert this complete markup after the closing tag of the existing `.approved-lower` section and before `</main>`:

```html
<section class="brand-proof" aria-labelledby="brand-proof-title">
  <h2 id="brand-proof-title">Обладнання провідних світових брендів</h2>

  <div class="brand-marquee" tabindex="0" aria-label="Бренди обладнання">
    <div class="brand-track">
      <ul class="brand-group">
        <li><img class="brand-logo" src="assets/brands/deye.svg" alt="Deye"></li>
        <li><img class="brand-logo" src="assets/brands/huawei.svg" alt="Huawei"></li>
        <li><img class="brand-logo" src="assets/brands/jinko-solar.svg" alt="Jinko Solar"></li>
        <li><img class="brand-logo" src="assets/brands/growatt.svg" alt="Growatt"></li>
        <li><img class="brand-logo" src="assets/brands/solis.svg" alt="Solis"></li>
        <li><img class="brand-logo" src="assets/brands/victron-energy.svg" alt="Victron Energy"></li>
        <li><img class="brand-logo" src="assets/brands/ja-solar.svg" alt="JA Solar"></li>
        <li><img class="brand-logo" src="assets/brands/longi-solar.svg" alt="LONGi Solar"></li>
      </ul>

      <ul class="brand-group" aria-hidden="true">
        <li><img class="brand-logo" src="assets/brands/deye.svg" alt=""></li>
        <li><img class="brand-logo" src="assets/brands/huawei.svg" alt=""></li>
        <li><img class="brand-logo" src="assets/brands/jinko-solar.svg" alt=""></li>
        <li><img class="brand-logo" src="assets/brands/growatt.svg" alt=""></li>
        <li><img class="brand-logo" src="assets/brands/solis.svg" alt=""></li>
        <li><img class="brand-logo" src="assets/brands/victron-energy.svg" alt=""></li>
        <li><img class="brand-logo" src="assets/brands/ja-solar.svg" alt=""></li>
        <li><img class="brand-logo" src="assets/brands/longi-solar.svg" alt=""></li>
      </ul>
    </div>
  </div>
</section>
```

- [ ] **Step 3: Extend the `max-width: 720px` rules**

Add this CSS inside the existing `@media (max-width: 720px)` block after `.approved-button`:

```css
.brand-proof {
  padding: 38px 0 46px;
}

.brand-proof h2 {
  margin-bottom: 30px;
  padding: 0 20px;
  font-size: 28px;
}

.brand-marquee {
  --brand-gap: 46px;
  -webkit-mask-image: linear-gradient(to right, transparent, #000 12%, #000 88%, transparent);
  mask-image: linear-gradient(to right, transparent, #000 12%, #000 88%, transparent);
}

.brand-track {
  animation-duration: 24s;
}

.brand-logo {
  max-width: 150px;
  height: 34px;
}
```

- [ ] **Step 4: Extend reduced-motion behavior**

Add this CSS inside the existing `@media (prefers-reduced-motion: reduce)` block:

```css
.brand-marquee {
  overflow: visible;
  -webkit-mask-image: none;
  mask-image: none;
}

.brand-track {
  display: block;
  width: 100%;
  animation: none;
}

.brand-group:first-child {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  padding: 0 20px;
}

.brand-group[aria-hidden="true"] {
  display: none;
}
```

- [ ] **Step 5: Run the new test and existing hero regression test**

Run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/brand-marquee.contract.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/approved-hero.contract.ps1
```

Expected:

```text
PASS: 12/12 brand marquee checks
PASS: 18/18 approved hero checks
```

- [ ] **Step 6: Commit the implemented section**

```powershell
git add approved-hero.html tests/brand-marquee.contract.ps1
git commit -m "feat: add responsive brand social proof marquee"
```

---

### Task 4: Verify every variant, visual behavior, and GitHub Pages publication

**Files:**
- Verify: `approved-hero.html`
- Verify: `tests/*.ps1`

**Interfaces:**
- Consumes: the finished section and existing project test suite.
- Produces: evidence that every contract passes, the layout does not overflow, the first screen is unchanged, and GitHub Pages serves the new block.

- [ ] **Step 1: Run every contract test**

Run:

```powershell
$failed = 0
Get-ChildItem tests -Filter '*.ps1' | Sort-Object Name | ForEach-Object {
  & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $_.FullName
  if ($LASTEXITCODE -ne 0) { $failed++ }
}
if ($failed -ne 0) { throw "$failed contract test file(s) failed" }
```

Expected: all seven contract files report `PASS` and the command exits with code `0`.

- [ ] **Step 2: Verify desktop layout in the in-app browser**

Serve the project locally and inspect `approved-hero.html` at a desktop viewport at least 1440 px wide. Confirm all of the following:

```text
- the first screen matches the previously approved layout;
- the new section begins directly after the white benefits-and-buttons row;
- the heading is centered and dark blue;
- 5–6 full-color logos are visible at once;
- the track moves without a blank gap or jump;
- hovering or focusing the marquee pauses movement;
- the page has no horizontal overflow.
```

- [ ] **Step 3: Verify mobile layout in the in-app browser**

Inspect the same URL at a viewport between 390 and 433 px wide. Confirm all of the following:

```text
- the approved mobile first screen remains unchanged;
- the heading occupies no more than two lines;
- 2–3 logos are visible at once;
- logo colors and proportions remain intact;
- the page has no horizontal overflow;
- the animation completes one cycle in 24 seconds.
```

- [ ] **Step 4: Confirm the working tree and push the completed commits**

Run:

```powershell
git status --short --branch
git push origin main
```

Expected: the branch tracks `origin/main`, only intended files were committed, and the push reports `main -> main`.

- [ ] **Step 5: Verify the public page**

Open:

```text
https://websitesky.github.io/ecomm/approved-hero.html
```

Confirm the page title is `Інвертори та сонячні панелі | SolarPro`, the `Обладнання провідних світових брендів` heading is present, all eight local logo requests return successfully, and the desktop and mobile layouts match the local verification.
