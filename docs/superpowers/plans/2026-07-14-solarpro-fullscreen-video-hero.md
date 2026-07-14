# SolarPro Fullscreen Video Hero Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a separate third SolarPro hero variant with `1.mp4` covering the full first screen and all sales content aligned at the lower left.

**Architecture:** Add one isolated HTML page and one page-scoped CSS section that reuses the approved header, logo, navigation and button primitives. Protect the existing photo and split-video variants with contract assertions, then verify the new page structurally and in the in-app browser at desktop, tablet and mobile sizes.

**Tech Stack:** Semantic HTML5, CSS3, native `<video>`, PowerShell contract tests, local Python HTTP server, in-app browser verification.

## Global Constraints

- Preserve `photo-benefits.html` and `video-variant.html` unchanged.
- Use `1.mp4` unchanged with `assets/hero-solar-home.jpg` as poster.
- Create the new page at `video-fullscreen.html`.
- Keep autoplay, muted, loop, playsinline, metadata preload and no controls.
- Place all marketing content at the lower left over a soft left-and-bottom dark gradient.
- Keep the sticky header and the existing two CTA labels.
- Support desktop, tablet and mobile without horizontal scrolling.
- Scope every new CSS rule under `.fullscreen-video-variant` or a new `fullscreen-*` class.
- The folder is not a Git repository, so commit steps are replaced by explicit file-isolation checks.

---

## File Map

- Create `video-fullscreen.html`: complete third-variant markup and video source.
- Create `tests/video-fullscreen.contract.ps1`: structural, content, isolation and CSS contract.
- Modify `styles.css`: append only the scoped full-screen variant and responsive rules.
- Preserve `photo-benefits.html`: approved photo variant.
- Preserve `video-variant.html`: approved split video variant.

### Task 1: Full-screen hero contract and markup

**Files:**
- Create: `tests/video-fullscreen.contract.ps1`
- Create: `video-fullscreen.html`
- Read: `photo-benefits.html`
- Read: `video-variant.html`

**Interfaces:**
- Consumes: `1.mp4`, `assets/hero-solar-home.jpg`, and existing shared classes `.header`, `.logo`, `.nav`, `.phone`, `.eyebrow`, `.benefit-icon`, `.hero-actions`, `.btn`, `.btn-primary`, `.btn-secondary`.
- Produces: `.fullscreen-video-variant`, `.fullscreen-video-hero`, `.fullscreen-hero-video`, `.fullscreen-hero-content`, `.fullscreen-subheadline`, `.fullscreen-benefits`, and `.fullscreen-actions` for Task 2.

- [ ] **Step 1: Write the failing contract test**

Create `tests/video-fullscreen.contract.ps1` with checks for the new file, unchanged older pages, required copy, video behavior and CSS hooks:

```powershell
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

$checks = [ordered]@{
  'fullscreen page exists' = Test-Path -LiteralPath $pagePath
  'photo page remains image based' = $photo.Contains('class="hero-image"') -and -not $photo.Contains('fullscreen-video-variant')
  'split video page remains separate' = $splitVideo.Contains('class="photo-benefits-variant video-variant"') -and -not $splitVideo.Contains('fullscreen-video-variant')
  'variant body class' = $page.Contains('class="fullscreen-video-variant"')
  'fullscreen hero' = $page.Contains('class="fullscreen-video-hero"')
  'video element' = $page.Contains('<video') -and $page.Contains('class="fullscreen-hero-video"')
  'autoplay muted loop inline' = $page.Contains('autoplay') -and $page.Contains('muted') -and $page.Contains('loop') -and $page.Contains('playsinline')
  'metadata preload' = $page.Contains('preload="metadata"')
  'video source exists' = (Test-Path -LiteralPath $videoPath) -and $page.Contains('src="1.mp4"') -and $page.Contains('type="video/mp4"')
  'poster exists' = (Test-Path -LiteralPath $posterPath) -and $page.Contains('poster="assets/hero-solar-home.jpg"')
  'decorative video has no controls' = $page.Contains('aria-hidden="true"') -and -not $page.Contains(' controls')
  'content hook' = $page.Contains('class="fullscreen-hero-content"')
  'headline' = $page.Contains('Інвертори та сонячні панелі для вашого дому та бізнесу')
  'subheadline' = $page.Contains('Менше залежності від мережі — більше спокою та контролю')
  'three benefits' = ([regex]::Matches($page, '<li>')).Count -eq 3
  'two calls to action' = $page.Contains('Перейти до каталогу') -and $page.Contains('Допомога у підборі')
  'scoped CSS root' = $css.Contains('.fullscreen-video-variant')
  'desktop fullscreen height' = $css.Contains('min-height: 100svh;')
  'video cover' = $css.Contains('.fullscreen-hero-video') -and $css.Contains('object-fit: cover;')
  'lower-left content' = $css.Contains('.fullscreen-hero-content') -and $css.Contains('margin-top: auto;')
  'responsive rules' = $css.Contains('@media (max-width: 1024px)') -and $css.Contains('@media (max-width: 640px)')
}

$failed = @($checks.GetEnumerator() | Where-Object { -not $_.Value } | ForEach-Object Key)
if ($failed.Count -gt 0) { throw ('Fullscreen video failures: ' + ($failed -join ', ')) }
Write-Output ('PASS: {0}/{0} fullscreen video checks' -f $checks.Count)
```

- [ ] **Step 2: Run the contract and verify the expected failure**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\video-fullscreen.contract.ps1
```

Expected: FAIL listing at least `fullscreen page exists`, `variant body class`, `fullscreen hero`, and `scoped CSS root` because the third variant does not exist yet.

- [ ] **Step 3: Create the minimal semantic HTML**

Create `video-fullscreen.html` using the approved Ukrainian copy and this exact structure:

```html
<!doctype html>
<html lang="uk">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="Інвертори, сонячні панелі та рішення для енергонезалежності дому й бізнесу." />
    <title>Інвертори та сонячні панелі | SolarPro</title>
    <link rel="stylesheet" href="styles.css" />
  </head>
  <body class="fullscreen-video-variant">
    <main class="fullscreen-video-page">
      <section class="fullscreen-video-hero" aria-labelledby="hero-title">
        <video class="fullscreen-hero-video" autoplay muted loop playsinline preload="metadata" poster="assets/hero-solar-home.jpg" aria-hidden="true">
          <source src="1.mp4" type="video/mp4" />
        </video>

        <header class="header">
          <a class="logo" href="#" aria-label="SolarPro — на головну">
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
          <a class="phone" href="tel:+380671234567" aria-label="Зателефонувати нам">+38 (067) 123-45-67</a>
        </header>

        <div class="fullscreen-hero-content">
          <p class="eyebrow">Енергія під вашим контролем</p>
          <h1 id="hero-title">Інвертори та сонячні панелі для вашого дому та бізнесу</h1>
          <p class="fullscreen-subheadline">Менше залежності від мережі — більше спокою та контролю</p>
          <ul class="fullscreen-benefits" aria-label="Переваги енергетичної системи">
            <li><span class="benefit-icon" aria-hidden="true">✓</span><span>Живлення під час відключень</span></li>
            <li><span class="benefit-icon" aria-hidden="true">✓</span><span>Економніше споживання енергії</span></li>
            <li><span class="benefit-icon" aria-hidden="true">✓</span><span>Система, що зростає разом із вашими потребами</span></li>
          </ul>
          <div class="hero-actions fullscreen-actions" aria-label="Основні дії">
            <a class="btn btn-primary" href="#catalog"><span>Перейти до каталогу</span><span class="btn-arrow" aria-hidden="true">→</span></a>
            <a class="btn btn-secondary" href="#selection-help"><span>Допомога у підборі</span></a>
          </div>
        </div>
      </section>
    </main>
  </body>
</html>
```

- [ ] **Step 4: Run the contract and confirm the remaining failures are only CSS requirements**

Run the same contract. Expected: FAIL only for CSS-related checks such as `scoped CSS root`, `video cover` or `lower-left content`.

- [ ] **Step 5: Verify file isolation**

Run:

```powershell
Select-String -LiteralPath .\photo-benefits.html, .\video-variant.html -Pattern 'fullscreen-video-variant'
```

Expected: no matches.

### Task 2: Scoped cinematic layout and responsive behavior

**Files:**
- Modify: `styles.css`
- Test: `tests/video-fullscreen.contract.ps1`

**Interfaces:**
- Consumes: the classes produced by Task 1 and shared header/button primitives already in `styles.css`.
- Produces: a full-screen stacking context with video at layer 0, gradient at layer 1, header/content above it, plus tablet and mobile adaptations.

- [ ] **Step 1: Confirm the contract is red for missing CSS**

Run `tests/video-fullscreen.contract.ps1` and confirm the failures name the CSS requirements rather than missing markup.

- [ ] **Step 2: Append the scoped full-screen styles**

Append this page-specific CSS to `styles.css`:

```css
.fullscreen-video-variant {
  min-width: 320px;
  color: var(--paper);
  background: #070c1d;
}

.fullscreen-video-page,
.fullscreen-video-hero {
  min-height: 100svh;
}

.fullscreen-video-hero {
  position: relative;
  isolation: isolate;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  padding: 20px clamp(18px, 4vw, 56px) clamp(34px, 6vh, 72px);
}

.fullscreen-video-hero::before {
  content: "";
  position: absolute;
  z-index: 1;
  inset: 0;
  background:
    linear-gradient(90deg, rgba(4, 8, 24, 0.9) 0%, rgba(7, 14, 38, 0.68) 42%, rgba(7, 14, 38, 0.12) 76%, transparent 100%),
    linear-gradient(0deg, rgba(3, 7, 20, 0.94) 0%, rgba(6, 12, 32, 0.56) 44%, transparent 78%);
  pointer-events: none;
}

.fullscreen-hero-video {
  position: absolute;
  z-index: 0;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: center 42%;
  background: #070c1d;
}

.fullscreen-video-hero > .header {
  z-index: 4;
  flex: 0 0 auto;
  width: 100%;
}

.fullscreen-hero-content {
  position: relative;
  z-index: 3;
  width: min(960px, 78vw);
  margin-top: auto;
  padding-top: clamp(170px, 28vh, 300px);
  text-shadow: 0 3px 24px rgba(0, 0, 0, 0.36);
}

.fullscreen-video-variant .eyebrow {
  color: #dce9ff;
  border-color: rgba(125, 173, 255, 0.48);
  background: rgba(16, 40, 92, 0.46);
  box-shadow: inset 0 0 0 1px rgba(255, 255, 255, 0.07);
  backdrop-filter: blur(10px);
}

.fullscreen-video-variant h1 {
  max-width: 900px;
  margin: 22px 0 0;
  color: var(--paper);
  font-size: clamp(40px, 4.3vw, 66px);
  line-height: 0.99;
  text-wrap: balance;
  letter-spacing: -0.045em;
}

.fullscreen-subheadline {
  max-width: 760px;
  margin: 18px 0 0;
  padding-left: 16px;
  border-left: 4px solid var(--blue);
  color: #f2f6ff;
  font-size: clamp(20px, 2vw, 29px);
  font-weight: 780;
  line-height: 1.18;
  text-wrap: balance;
}

.fullscreen-benefits {
  display: flex;
  flex-wrap: wrap;
  gap: 10px 22px;
  margin: 22px 0 0;
  padding: 0;
  list-style: none;
}

.fullscreen-benefits li {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  color: #edf3ff;
  font-size: 15px;
  font-weight: 680;
  line-height: 1.35;
}

.fullscreen-video-variant .benefit-icon {
  flex: 0 0 18px;
  color: var(--paper);
  background: var(--blue);
  box-shadow: 0 5px 16px rgba(41, 121, 255, 0.32);
}

.fullscreen-actions {
  margin-top: 25px;
}

.fullscreen-video-variant .btn-secondary {
  border-color: rgba(255, 255, 255, 0.64);
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.98), rgba(225, 235, 255, 0.94));
  box-shadow: 0 16px 36px rgba(0, 0, 0, 0.2);
}

@media (max-width: 1024px) {
  .fullscreen-video-hero {
    padding: 18px 22px 38px;
  }

  .fullscreen-hero-content {
    width: min(820px, 88vw);
    padding-top: clamp(160px, 24vh, 240px);
  }

  .fullscreen-video-variant h1 {
    font-size: clamp(38px, 6vw, 58px);
  }
}

@media (max-width: 640px) {
  .fullscreen-video-hero {
    min-height: 100svh;
    padding: 12px 14px 24px;
  }

  .fullscreen-video-hero::before {
    background:
      linear-gradient(90deg, rgba(4, 8, 24, 0.84) 0%, rgba(7, 14, 38, 0.45) 72%, transparent 100%),
      linear-gradient(0deg, rgba(3, 7, 20, 0.98) 0%, rgba(6, 12, 32, 0.78) 58%, rgba(6, 12, 32, 0.08) 92%);
  }

  .fullscreen-hero-video {
    object-position: 58% 42%;
  }

  .fullscreen-hero-content {
    width: 100%;
    padding: 132px 4px 0;
  }

  .fullscreen-video-variant .eyebrow {
    padding: 7px 10px;
    font-size: 12px;
  }

  .fullscreen-video-variant h1 {
    margin-top: 15px;
    font-size: clamp(32px, 9.5vw, 42px);
    line-height: 1.02;
  }

  .fullscreen-subheadline {
    margin-top: 13px;
    padding-left: 12px;
    border-left-width: 3px;
    font-size: clamp(18px, 5.2vw, 22px);
  }

  .fullscreen-benefits {
    display: grid;
    gap: 7px;
    margin-top: 15px;
  }

  .fullscreen-benefits li {
    font-size: 13px;
  }

  .fullscreen-actions {
    display: grid;
    gap: 10px;
    margin-top: 18px;
  }

  .fullscreen-video-variant .btn {
    width: 100%;
    min-height: 50px;
  }
}

@media (max-width: 380px) {
  .fullscreen-video-variant h1 {
    font-size: 30px;
  }

  .fullscreen-subheadline {
    font-size: 17px;
  }
}
```

- [ ] **Step 3: Run the focused contract**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\video-fullscreen.contract.ps1
```

Expected: `PASS: 21/21 fullscreen video checks`.

- [ ] **Step 4: Run all contract tests**

Run each `tests/*.contract.ps1` file and fail if any script exits non-zero. Expected: every contract prints `PASS` and the process exits 0.

- [ ] **Step 5: Verify isolation without Git**

Confirm the only new production page is `video-fullscreen.html`, the new rules are scoped, and both preserved pages still pass their original tests.

### Task 3: Browser verification and delivery

**Files:**
- Verify: `video-fullscreen.html`
- Verify: `styles.css`

**Interfaces:**
- Consumes: the local page served at `http://127.0.0.1:8765/video-fullscreen.html`.
- Produces: a browser-visible third variant ready for visual comparison.

- [ ] **Step 1: Confirm the local page returns HTTP 200**

Run `Invoke-WebRequest` against the page. Expected: status 200 and content containing `fullscreen-video-variant`.

- [ ] **Step 2: Verify desktop at 1440 × 900**

Check: full-viewport video, sticky readable header, lower-left content, two visible CTA buttons, no horizontal overflow, and playing muted video.

- [ ] **Step 3: Verify tablet at 820 × 1180**

Check: compact title, left-aligned content, preserved video focal area, readable benefits and both CTA buttons without overlap or horizontal overflow.

- [ ] **Step 4: Verify mobile at 390 × 844**

Check: compact menu, lower-left content, stacked full-width buttons, denser gradient, no clipped content and no horizontal overflow.

- [ ] **Step 5: Inspect browser logs**

Expected: no page-generated warnings or errors.

- [ ] **Step 6: Return to desktop and leave the page open**

Set the browser to a desktop viewport, keep `video-fullscreen.html` selected, and provide its clickable local link to the user.
