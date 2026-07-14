# SolarPro Video Hero Variant Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create an independently viewable hero variant that replaces the approved photo with unchanged `1.mp4` while leaving `photo-benefits.html` untouched.

**Architecture:** `video-variant.html` reuses the approved page structure and the existing `photo-benefits-variant` styles, adding only a `video-variant` body class and one `.hero-video` CSS selector. The decorative video autoplays muted, loops inline and uses the approved solar-house image as its loading/failure poster.

**Tech Stack:** HTML5 video, CSS3, PowerShell contract tests, in-app browser responsive verification.

## Global Constraints

- Do not edit `photo-benefits.html`.
- Use `1.mp4` unchanged, including its current visible mark.
- Create `video-variant.html` as a separate comparison page.
- Keep the approved header, copy, benefits, CTA buttons and white photo statement.
- Use `autoplay muted loop playsinline preload="metadata"` with no controls.
- Use `assets/hero-solar-home.jpg` as the poster.
- Add no JavaScript and no new dependencies.
- Git commits are not applicable because the folder is not an active Git repository.

---

### Task 1: Video Variant Contract

**Files:**
- Create: `tests/video-variant.contract.ps1`
- Read: `photo-benefits.html`
- Read: `styles.css`
- Read: `1.mp4`

**Interfaces:**
- Consumes: approved photo page, MP4 source and shared CSS.
- Produces: a 15-check contract for variant isolation, video attributes, overlay copy, source availability and video styling.

- [ ] **Step 1: Write the failing contract**

```powershell
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
$statement = 'Менше залежності від мережі — більше спокою та контролю'

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
```

- [ ] **Step 2: Run the contract and confirm the expected RED state**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\video-variant.contract.ps1
```

Expected: FAIL because `video-variant.html` and `.hero-video` do not exist yet.

---

### Task 2: Separate Video Hero Page

**Files:**
- Create: `video-variant.html`
- Test: `tests/video-variant.contract.ps1`

**Interfaces:**
- Consumes: complete markup from `photo-benefits.html`, `styles.css`, `1.mp4`, `assets/hero-solar-home.jpg`.
- Produces: a standalone local URL at `/video-variant.html`.

- [ ] **Step 1: Create the page from the approved photo variant**

Duplicate the complete `photo-benefits.html` markup into `video-variant.html`, then make exactly these two substitutions:

```html
<body class="photo-benefits-variant video-variant">
```

```html
<figure class="hero-media">
  <video
    class="hero-video"
    autoplay
    muted
    loop
    playsinline
    preload="metadata"
    poster="assets/hero-solar-home.jpg"
    aria-hidden="true"
  >
    <source src="1.mp4" type="video/mp4" />
  </video>
  <p class="photo-statement">Менше залежності від мережі — більше спокою та контролю</p>
</figure>
```

All header, copy, benefits and CTA markup remains byte-for-byte equivalent to the approved page.

- [ ] **Step 2: Run the new contract**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\video-variant.contract.ps1
```

Expected: FAIL only for `video cover styles`.

---

### Task 3: Video Media Styling

**Files:**
- Modify: `styles.css` after the `.hero-image` rule
- Test: `tests/video-variant.contract.ps1`

**Interfaces:**
- Consumes: `.hero-media` card dimensions and overlay layers.
- Produces: `.hero-video`, a full-card decorative media layer below the existing gradients and statement.

- [ ] **Step 1: Add the focused video selector**

```css
.hero-video {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: center 42%;
  background: #111827;
}
```

Do not add the Ken Burns animation to video and do not change `.hero-image`.

- [ ] **Step 2: Run all contracts**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\hero.contract.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\photo-benefits.contract.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\interaction-styles.contract.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\video-variant.contract.ps1
```

Expected: `PASS: 19/19`, `PASS: 13/13`, `PASS: 12/12`, `PASS: 15/15`.

- [ ] **Step 3: Verify balanced CSS braces**

```powershell
$css = Get-Content -Raw -Encoding utf8 styles.css
$opens = ($css.ToCharArray() | Where-Object { $_ -eq '{' }).Count
$closes = ($css.ToCharArray() | Where-Object { $_ -eq '}' }).Count
if ($opens -ne $closes) { throw "CSS brace mismatch: $opens/$closes" }
```

Expected: exit code 0.

---

### Task 4: Browser and Responsive Verification

**Files:**
- Verify: `video-variant.html`
- Verify unchanged: `photo-benefits.html`

**Interfaces:**
- Consumes: local server at `http://127.0.0.1:8765/`.
- Produces: evidence that the video plays, loops silently and preserves responsive layout.

- [ ] **Step 1: Open the separate video URL**

Open `http://127.0.0.1:8765/video-variant.html` and verify the source reports:

```text
paused=false
muted=true
loop=true
videoWidth=1280
videoHeight=720
```

- [ ] **Step 2: Verify desktop, tablet and mobile layouts**

Check `1440×900`, `768×1024`, `375×812` and `320×700`.

Expected at each size:

```text
document.documentElement.scrollWidth <= window.innerWidth
video rectangle equals hero-media rectangle
photo statement is visible and contained by hero-media
CTA buttons remain visible and readable
```

- [ ] **Step 3: Verify the saved photo page**

Open `http://127.0.0.1:8765/photo-benefits.html`.

Expected: the original animated photo is still present, no `<video>` exists, and the page has the same headline, bullets and CTA buttons.

- [ ] **Step 4: Check browser console**

Expected: no warnings or errors on either comparison page.
