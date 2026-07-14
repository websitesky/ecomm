# SolarPro Split Hero Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Перебудувати перший екран SolarPro у преміальний адаптивний hero з синьою палітрою, двома CTA та делікатною анімацією фотографії Ken Burns.

**Architecture:** Семантична розмітка в `index.html` створює двоколонковий hero з окремою текстовою та медіачастиною. `styles.css` керує палітрою, сіткою, трьома адаптивними режимами, станами кнопок і CSS-анімацією без JavaScript; надане фото копіюється локально в `assets/`.

**Tech Stack:** HTML5, CSS custom properties, CSS Grid/Flexbox, CSS keyframes, PowerShell contract test, Playwright browser verification.

## Global Constraints

- Заголовок: «Інвертори та сонячні панелі для вашого дому та бізнесу».
- Підзаголовок: «Менше залежності від мережі — більше спокою та контролю.»
- CTA: «Перейти до каталогу» та «Допомога у підборі».
- Кольори: `#1A237E`, `#2979FF`, `#FFFFFF`, `#F5F7FF`, `#4A5575`.
- Джерело фото: `C:/Users/slm08/Downloads/65dbfc2062c07012ab05674fb1370693 1.jpg`.
- Робочий asset: `assets/hero-solar-home.jpg`.
- Ken Burns: `scale(1)` до `scale(1.04)`, зміщення до `1%`, `20s ease-in-out infinite alternate`.
- При `prefers-reduced-motion: reduce` анімація фотографії та геометричний рух кнопок вимикаються.
- Адаптивні режими: десктоп `>1024px`, планшет `641–1024px`, смартфон `<=640px`.
- На смартфоні текст іде перед фото, CTA займають повну ширину, nav приховується, логотип і телефон залишаються.
- JavaScript у production-файлах не додається.

---

### Task 1: Contract test and local image asset

**Files:**
- Create: `tests/hero.contract.ps1`
- Create: `assets/hero-solar-home.jpg`

**Interfaces:**
- Consumes: погоджену дизайн-специфікацію та вихідний JPG.
- Produces: повторювану перевірку `tests/hero.contract.ps1` і локальний asset `assets/hero-solar-home.jpg`.

- [ ] **Step 1: Write the failing contract test**

Створити `tests/hero.contract.ps1` із такими перевірками:

```powershell
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$htmlPath = Join-Path $root 'index.html'
$cssPath = Join-Path $root 'styles.css'
$imagePath = Join-Path $root 'assets/hero-solar-home.jpg'
$html = Get-Content -Raw -Encoding utf8 -LiteralPath $htmlPath
$css = Get-Content -Raw -Encoding utf8 -LiteralPath $cssPath

$checks = [ordered]@{
  'local hero image' = Test-Path -LiteralPath $imagePath
  'exact headline' = $html.Contains('Інвертори та сонячні панелі для вашого дому та бізнесу')
  'exact subheadline' = $html.Contains('Менше залежності від мережі — більше спокою та контролю.')
  'catalog CTA' = $html.Contains('Перейти до каталогу')
  'selection CTA' = $html.Contains('Допомога у підборі')
  'media figure' = $html.Contains('class="hero-media"')
  'semantic image' = $html.Contains('src="assets/hero-solar-home.jpg"') -and $html.Contains('class="hero-image"')
  'blue palette' = $css.Contains('--blue-deep: #1a237e;') -and $css.Contains('--blue: #2979ff;')
  'ken burns keyframes' = $css.Contains('@keyframes hero-ken-burns')
  'ken burns timing' = $css.Contains('20s ease-in-out infinite alternate')
  'tablet breakpoint' = $css.Contains('@media (max-width: 1024px)')
  'mobile breakpoint' = $css.Contains('@media (max-width: 640px)')
  'reduced motion' = $css.Contains('@media (prefers-reduced-motion: reduce)')
  'focus styles' = $css.Contains(':focus-visible')
}

$failed = @($checks.GetEnumerator() | Where-Object { -not $_.Value } | ForEach-Object Key)
if ($failed.Count -gt 0) { throw ('Hero contract failures: ' + ($failed -join ', ')) }
Write-Output ('PASS: {0}/{0} hero contract checks' -f $checks.Count)
```

- [ ] **Step 2: Run the test and confirm the intended failure**

Run:

```powershell
& '.\tests\hero.contract.ps1'
```

Expected: FAIL with missing local hero image, exact subheadline, `hero-media`, Ken Burns, responsive breakpoints, reduced motion, and focus styles.

- [ ] **Step 3: Copy the source image non-destructively**

Run:

```powershell
Copy-Item -LiteralPath 'C:\Users\slm08\Downloads\65dbfc2062c07012ab05674fb1370693 1.jpg' -Destination '.\assets\hero-solar-home.jpg'
```

Expected: `assets/hero-solar-home.jpg` exists and the source file remains unchanged.

- [ ] **Step 4: Verify the image asset**

Run:

```powershell
Get-FileHash -Algorithm SHA256 -LiteralPath 'C:\Users\slm08\Downloads\65dbfc2062c07012ab05674fb1370693 1.jpg','.\assets\hero-solar-home.jpg'
```

Expected: both rows report the same SHA256 hash.

### Task 2: Semantic split-hero markup and responsive styling

**Files:**
- Modify: `index.html`
- Modify: `styles.css`
- Test: `tests/hero.contract.ps1`

**Interfaces:**
- Consumes: `assets/hero-solar-home.jpg` from Task 1.
- Produces: `.hero-layout`, `.hero-copy`, `.hero-media`, `.hero-image`, `.hero-actions`, `.btn-primary`, `.btn-secondary` and the responsive CSS contracts checked by Task 1.

- [ ] **Step 1: Replace the hero content in `index.html`**

Основна структура має бути такою:

```html
<section class="hero" aria-labelledby="hero-title">
  <header class="header">
    <a class="logo" href="#" aria-label="На головну">
      <span class="logo-mark" aria-hidden="true"></span>
      <span>SolarPro</span>
    </a>
    <nav class="nav" aria-label="Головне меню">
      <a href="#catalog">Каталог</a>
      <a href="#offers">Акції</a>
      <a href="#delivery">Доставка</a>
      <a href="#warranty">Гарантія</a>
      <a href="#contacts">Контакти</a>
    </nav>
    <a class="phone" href="tel:+380671234567">+38 (067) 123-45-67</a>
  </header>
  <div class="hero-layout">
    <div class="hero-copy">
      <p class="eyebrow">Енергія під вашим контролем</p>
      <h1 id="hero-title">Інвертори та сонячні панелі для вашого дому та бізнесу</h1>
      <p class="lead">Менше залежності від мережі — більше спокою та контролю.</p>
      <div class="hero-actions" aria-label="Основні дії">
        <a class="btn btn-primary" href="#catalog">Перейти до каталогу</a>
        <a class="btn btn-secondary" href="#selection-help">Допомога у підборі</a>
      </div>
    </div>
    <figure class="hero-media">
      <img class="hero-image" src="assets/hero-solar-home.jpg" alt="Сучасний будинок із сонячними панелями, інвертором і зарядною станцією" />
    </figure>
  </div>
</section>
```

Header retains the current links «Каталог», «Акції», «Доставка», «Гарантія», «Контакти» and the current phone number.

- [ ] **Step 2: Replace `styles.css` with the approved design system**

The stylesheet must define:

```css
:root {
  --blue-deep: #1a237e;
  --blue: #2979ff;
  --paper: #ffffff;
  --wash: #f5f7ff;
  --muted: #4a5575;
  --radius: 8px;
}

.hero-layout {
  display: grid;
  grid-template-columns: minmax(0, 1.08fr) minmax(0, 1fr);
}

.hero-media { overflow: hidden; border-radius: var(--radius); }
.hero-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: center 42%;
  animation: hero-ken-burns 20s ease-in-out infinite alternate;
}

@keyframes hero-ken-burns {
  from { transform: scale(1) translateX(0); }
  to { transform: scale(1.04) translateX(-1%); }
}

@media (max-width: 1024px) {
  .hero-layout { grid-template-columns: minmax(0, 1.18fr) minmax(0, 1fr); }
  .nav a:nth-child(2), .nav a:nth-child(5) { display: none; }
}

@media (max-width: 640px) {
  .hero-layout { grid-template-columns: minmax(0, 1fr); }
  .hero-media { height: clamp(280px, 42svh, 420px); }
  .hero-image { object-position: center 38%; }
  .nav { display: none; }
  .hero-actions { display: grid; }
  .btn { width: 100%; }
}

@media (prefers-reduced-motion: reduce) {
  .hero-image { animation: none; transform: none; }
  .btn { transition-duration: 0.01ms; }
  .btn:hover { transform: none; }
}
```

The complete CSS also includes the approved floating header, typography, exact button colors, hover/active/focus-visible states, spacing, shadows, and overflow protection. It must not add JavaScript dependencies.

- [ ] **Step 3: Run the contract test and confirm green**

Run:

```powershell
& '.\tests\hero.contract.ps1'
```

Expected: `PASS: 14/14 hero contract checks`.

- [ ] **Step 4: Confirm production files contain no JavaScript**

Run:

```powershell
rg -n '<script|javascript:' 'index.html' 'styles.css'
```

Expected: no matches.

- [ ] **Step 5: Commit**

Commit is skipped because the workspace is not a Git repository. Preserve all previous generated preview files and unrelated assets.

### Task 3: Browser verification at desktop, tablet, and mobile widths

**Files:**
- Create: `tests/hero.browser-check.cjs`
- Verify: `index.html`
- Verify: `styles.css`

**Interfaces:**
- Consumes: the completed hero implementation from Task 2.
- Produces: measured evidence for `1440x1000`, `768x1024`, and `375x812`, plus screenshots `hero-final-desktop.png`, `hero-final-tablet.png`, `hero-final-mobile.png`.

- [ ] **Step 1: Create `tests/hero.browser-check.cjs`**

Use Playwright to open the local `index.html`, then for each viewport assert:

```javascript
const viewports = [
  { name: 'desktop', width: 1440, height: 1000 },
  { name: 'tablet', width: 768, height: 1024 },
  { name: 'mobile', width: 375, height: 812 }
];

const metrics = await page.evaluate(() => ({
  clientWidth: document.documentElement.clientWidth,
  scrollWidth: document.documentElement.scrollWidth,
  title: document.getElementById('hero-title')?.textContent.trim(),
  mediaVisible: Boolean(document.querySelector('.hero-media')?.getBoundingClientRect().height),
  primaryVisible: Boolean(document.querySelector('.btn-primary')?.getBoundingClientRect().height),
  secondaryVisible: Boolean(document.querySelector('.btn-secondary')?.getBoundingClientRect().height)
}));

if (metrics.scrollWidth > metrics.clientWidth) throw new Error(`${viewport.name}: horizontal overflow`);
if (!metrics.mediaVisible || !metrics.primaryVisible || !metrics.secondaryVisible) throw new Error(`${viewport.name}: missing hero content`);
```

The script also verifies the computed animation name is `hero-ken-burns` in normal mode and `none` with `reducedMotion: 'reduce'`. It writes one screenshot per viewport to the project root.

- [ ] **Step 2: Run browser verification**

Run the bundled Node runtime with the bundled Playwright package path and `tests/hero.browser-check.cjs`.

Expected: three viewport results with `scrollWidth === clientWidth`, all required content visible, normal animation `hero-ken-burns`, and reduced-motion animation `none`.

- [ ] **Step 3: Inspect all three screenshots**

Check that:

- desktop uses the approved `52% / 48%` split and keeps the photo fully legible;
- tablet keeps text and photo side-by-side without clipped nav or CTAs;
- mobile stacks text before the image, keeps the logo and phone visible, hides nav, and makes both buttons full width;
- no text overlaps the photo, no control is clipped, and the image remains undistorted.

- [ ] **Step 4: Re-run the full verification suite**

Run `tests/hero.contract.ps1` and `tests/hero.browser-check.cjs` again after any visual adjustments.

Expected: all contract checks and all three viewport checks pass with no errors.
