# SolarPro Smoke Copy Panel Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a subtle graphite panel only behind the hero copy, increase mobile vertical spacing, and keep the CTA buttons and the rest of the video outside the panel.

**Architecture:** Wrap the eyebrow, headline, subheadline and benefit list in one semantic-neutral `.fullscreen-copy-panel` while leaving `.fullscreen-actions` as its sibling. Add scoped desktop/tablet/mobile styles with an understated neutral translucent background, then guard structure and exact mobile spacing through the existing PowerShell contract.

**Tech Stack:** Semantic HTML5, CSS3, PowerShell contract tests, local Python HTTP server, in-app responsive inspection.

## Global Constraints

- Do not add a fullscreen video overlay, video filter, mask or opacity adjustment.
- Keep the original `1.mp4`, menu, text, benefit copy and CTA labels unchanged.
- Put only eyebrow, `h1`, subheadline and benefits inside `.fullscreen-copy-panel`.
- Keep `.fullscreen-actions` outside the panel.
- Desktop spacing: 20 px / 18 px / 20 px; panel-to-CTA 25 px.
- Mobile spacing: 20 px / 18 px / 20 px; panel-to-CTA 24 px; benefit row gap 9 px.
- Mobile panel padding: `14px 14px 16px`.
- Preserve `photo-benefits.html` and `video-variant.html` byte-for-byte.
- The folder is not a Git repository, so isolation is verified with SHA-256 hashes.

---

### Task 1: Contract for panel structure and spacing

**Files:**
- Modify: `tests/video-fullscreen.contract.ps1`

**Interfaces:**
- Produces a regression contract for `.fullscreen-copy-panel` content, CTA separation, neutral panel styling and exact mobile spacing.

- [ ] **Step 1: Add structure extraction and checks before implementation**

After loading `$page` and `$css`, add:

```powershell
$copyPanel = [regex]::Match($page, '(?s)<div class="fullscreen-copy-panel">(?<content>.*?)</div>\s*<div class="hero-actions fullscreen-actions"')
```

Add these contract entries and update the stylesheet version requirement:

```powershell
'versioned stylesheet' = $page.Contains('href="styles.css?v=fullscreen-smoke-panel-20260714"')
'copy panel structure' = $copyPanel.Success
'required copy inside panel' = $copyPanel.Success -and $copyPanel.Groups['content'].Value.Contains('class="eyebrow"') -and $copyPanel.Groups['content'].Value.Contains('<h1') -and $copyPanel.Groups['content'].Value.Contains('class="fullscreen-subheadline"') -and $copyPanel.Groups['content'].Value.Contains('class="fullscreen-benefits"')
'actions outside panel' = $copyPanel.Success -and -not $copyPanel.Groups['content'].Value.Contains('fullscreen-actions')
'smoke panel style' = $css.Contains('.fullscreen-copy-panel') -and $css.Contains('rgba(5, 8, 15, 0.52)') -and $css.Contains('backdrop-filter: blur(4px);')
'desktop copy spacing' = $css.Contains('.fullscreen-copy-panel h1') -and $css.Contains('margin-top: 20px;') -and $css.Contains('margin-top: 18px;')
'mobile panel padding' = $css.Contains('padding: 14px 14px 16px;')
'mobile benefit spacing' = $css.Contains('gap: 9px;')
'mobile panel to actions spacing' = $css.Contains('margin-top: 24px;')
```

- [ ] **Step 2: Run the focused contract and verify RED**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\video-fullscreen.contract.ps1
```

Expected: FAIL for the new stylesheet version, missing copy panel, missing panel styles and new mobile spacing.

### Task 2: Copy wrapper and responsive smoke panel

**Files:**
- Modify: `video-fullscreen.html`
- Modify: `styles.css`
- Test: `tests/video-fullscreen.contract.ps1`

**Interfaces:**
- Consumes `.fullscreen-hero-content`, `.eyebrow`, `h1`, `.fullscreen-subheadline`, `.fullscreen-benefits` and `.fullscreen-actions`.
- Produces `.fullscreen-copy-panel` as the only locally darkened area.

- [ ] **Step 1: Add the wrapper and cache-busting stylesheet version**

Change the stylesheet URL to:

```html
<link rel="stylesheet" href="styles.css?v=fullscreen-smoke-panel-20260714" />
```

Inside `.fullscreen-hero-content`, wrap eyebrow through benefit list:

```html
<div class="fullscreen-copy-panel">
  <p class="eyebrow">Енергія під вашим контролем</p>
  <h1 id="hero-title">Інвертори та сонячні панелі для вашого дому та бізнесу</h1>
  <p class="fullscreen-subheadline">Менше залежності від мережі — більше спокою та контролю</p>
  <ul class="fullscreen-benefits" aria-label="Переваги енергетичної системи">
    <li><span class="benefit-icon" aria-hidden="true">✓</span><span>Живлення під час відключень</span></li>
    <li><span class="benefit-icon" aria-hidden="true">✓</span><span>Економніше споживання енергії</span></li>
    <li><span class="benefit-icon" aria-hidden="true">✓</span><span>Система, що зростає разом із вашими потребами</span></li>
  </ul>
</div>
<div class="hero-actions fullscreen-actions" aria-label="Основні дії">
  <a class="btn btn-primary" href="#catalog"><span>Перейти до каталогу</span><span class="btn-arrow" aria-hidden="true">→</span></a>
  <a class="btn btn-secondary" href="#selection-help"><span>Допомога у підборі</span></a>
</div>
```

- [ ] **Step 2: Add the desktop/tablet panel styles**

Add after `.fullscreen-hero-content` and after the base typography rules where selector order is effective:

```css
.fullscreen-copy-panel {
  width: 100%;
  padding: 20px 24px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 18px;
  background: linear-gradient(110deg, rgba(5, 8, 15, 0.52) 0%, rgba(5, 8, 15, 0.34) 72%, rgba(5, 8, 15, 0.2) 100%);
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.05);
  backdrop-filter: blur(4px);
  -webkit-backdrop-filter: blur(4px);
}

.fullscreen-copy-panel .eyebrow {
  margin: 0;
}

.fullscreen-copy-panel h1 {
  margin-top: 20px;
}

.fullscreen-copy-panel .fullscreen-subheadline {
  margin-top: 18px;
}

.fullscreen-copy-panel .fullscreen-benefits {
  margin-top: 20px;
}
```

Keep `.fullscreen-actions { margin-top: 25px; }` at desktop/tablet sizes.

- [ ] **Step 3: Add exact mobile spacing**

Inside `@media (max-width: 640px)` add or override:

```css
.fullscreen-copy-panel {
  padding: 14px 14px 16px;
  border-radius: 16px;
  background: linear-gradient(135deg, rgba(5, 8, 15, 0.52) 0%, rgba(5, 8, 15, 0.38) 100%);
}

.fullscreen-copy-panel h1 {
  margin-top: 20px;
}

.fullscreen-copy-panel .fullscreen-subheadline {
  margin-top: 18px;
}

.fullscreen-copy-panel .fullscreen-benefits {
  gap: 9px;
  margin-top: 20px;
}

.fullscreen-actions {
  margin-top: 24px;
}
```

- [ ] **Step 4: Run the focused contract and verify GREEN**

Expected: the fullscreen contract prints an updated PASS count.

- [ ] **Step 5: Run all PowerShell contracts and verify preserved hashes**

Expected: all five contract files pass; SHA-256 values remain:

```text
photo-benefits.html D4CD087FBB96407CB6C17D97E9AA31CE76A893E762FFAB2DD29A2CA341B070FB
video-variant.html  A5B23C27051483222E8DEC2FF6EED94CC028A43337AA6EEC6C6EF9CCDB0FCEA3
```

### Task 3: Responsive and visual validation

**Files:**
- Verify: `video-fullscreen.html`
- Verify: `styles.css`

**Interfaces:**
- Consumes `http://127.0.0.1:8765/video-fullscreen.html`.
- Produces a browser-ready smoke-panel variant.

- [ ] **Step 1: Verify served HTML/CSS**

Both the page and `styles.css?v=fullscreen-smoke-panel-20260714` must return HTTP 200 and contain the new panel structure/styles.

- [ ] **Step 2: Check mobile at 390 × 844**

Confirm no horizontal overflow, two visible CTA buttons, the panel-to-actions gap is 24 px, and the actual gaps are at least 20/18/20 px.

- [ ] **Step 3: Check tablet and desktop**

At 820 × 1180 and 1440 × 900, confirm the panel stays local to the left/lower content area and does not cover the full video.

- [ ] **Step 4: Inspect day/night readability**

Confirm the neutral panel improves text legibility on both scene types without tinting the surrounding video blue.

- [ ] **Step 5: Reset temporary viewport and leave the page available**

If the in-app browser blocks automated reload, keep the local server running and ask the user to press `Ctrl+R` once.
