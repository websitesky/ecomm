# SolarPro Native Video Without Overlay Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove every fullscreen video-darkening layer so `1.mp4` renders with its original day-to-night color while existing text and controls remain over it.

**Architecture:** Turn the fullscreen PowerShell contract into a regression guard that forbids pseudo-element overlays, the darkness CSS variable and the synchronization script. Then delete the unused synchronization artifacts, remove only the page-scoped overlay CSS, and refresh the stylesheet query to invalidate the browser cache.

**Tech Stack:** HTML5, CSS3, PowerShell contract tests, local Python HTTP server.

## Global Constraints

- Keep the video file, video attributes, text, menu, benefits and CTA buttons unchanged.
- Remove `.fullscreen-video-hero::before`, `.fullscreen-video-hero::after`, `--scene-darkness` and the fullscreen sync script reference.
- Do not add `filter`, `opacity`, masks, gradients or translucent cards over the video.
- Preserve `object-fit: cover`, all responsive layout rules and the text-only `text-shadow`.
- Delete the now-unused `fullscreen-video-sync.js` and `tests/fullscreen-video-sync.test.js`.
- Preserve `photo-benefits.html` and `video-variant.html` byte-for-byte.
- This folder has no Git repository, so isolation is verified with SHA-256 hashes.

---

### Task 1: Regression contract for natural video color

**Files:**
- Modify: `tests/video-fullscreen.contract.ps1`
- Modify: `video-fullscreen.html`
- Modify: `styles.css`
- Delete: `fullscreen-video-sync.js`
- Delete: `tests/fullscreen-video-sync.test.js`

**Interfaces:**
- Consumes the existing `.fullscreen-video-hero`, `.fullscreen-hero-video` and `.fullscreen-hero-content` structure.
- Produces a fullscreen page with no visual layer between the video and the text/interface elements.

- [ ] **Step 1: Change the contract before production files**

Replace the day/night requirements with these exact checks:

```powershell
'versioned stylesheet' = $page.Contains('href="styles.css?v=fullscreen-native-video-20260714"')
'no sync script' = -not $page.Contains('fullscreen-video-sync.js')
'no darkness variable' = -not $css.Contains('--scene-darkness')
'no local video overlay' = -not $css.Contains('.fullscreen-video-hero::before')
'no global video overlay' = -not $css.Contains('.fullscreen-video-hero::after')
'native video appearance' = $css.Contains('.fullscreen-hero-video') -and $css.Contains('object-fit: cover;') -and -not $css.Contains('filter: brightness')
```

Remove `$syncPath` and the previous checks named `sync script`, `day-night CSS variable`, `local text overlay`, `dynamic night overlay` and `mobile local protection`.

- [ ] **Step 2: Run the fullscreen contract and verify RED**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\video-fullscreen.contract.ps1
```

Expected: FAIL for the new stylesheet version, sync script, darkness variable and both overlay selectors.

- [ ] **Step 3: Remove the script and refresh the stylesheet in HTML**

The head of `video-fullscreen.html` must contain:

```html
<link rel="stylesheet" href="styles.css?v=fullscreen-native-video-20260714" />
```

It must not contain a `fullscreen-video-sync.js` script tag.

- [ ] **Step 4: Remove only fullscreen overlay CSS**

From `.fullscreen-video-hero`, delete:

```css
--scene-darkness: 0.12;
```

Delete the complete `.fullscreen-video-hero::before`, `.fullscreen-video-hero::after`, combined pseudo-element block, and the mobile `.fullscreen-video-hero::before` override. Keep `.fullscreen-hero-content` and its existing `text-shadow` unchanged.

- [ ] **Step 5: Delete unused synchronization artifacts**

Delete `fullscreen-video-sync.js` and `tests/fullscreen-video-sync.test.js` because the selected design has no time-driven overlay.

- [ ] **Step 6: Run the focused contract and verify GREEN**

Expected: the fullscreen contract prints an updated PASS count with the no-overlay checks.

### Task 2: Full regression and delivery verification

**Files:**
- Verify: `video-fullscreen.html`
- Verify: `styles.css`
- Verify: `tests/video-fullscreen.contract.ps1`

**Interfaces:**
- Consumes the local page at `http://127.0.0.1:8765/video-fullscreen.html`.
- Produces a cache-refreshed no-overlay page for the in-app browser.

- [ ] **Step 1: Run every PowerShell contract**

Expected: all five `tests/*.contract.ps1` files pass.

- [ ] **Step 2: Verify preserved page hashes**

Expected SHA-256 values:

```text
photo-benefits.html D4CD087FBB96407CB6C17D97E9AA31CE76A893E762FFAB2DD29A2CA341B070FB
video-variant.html  A5B23C27051483222E8DEC2FF6EED94CC028A43337AA6EEC6C6EF9CCDB0FCEA3
```

- [ ] **Step 3: Verify served assets**

Request the HTML and `styles.css?v=fullscreen-native-video-20260714`. Both must return HTTP 200; HTML must not reference the sync script and CSS must not contain fullscreen pseudo-element overlays.

- [ ] **Step 4: Leave the no-overlay page available**

Keep the local server running and provide `http://127.0.0.1:8765/video-fullscreen.html`. If browser automation cannot refresh the local page because of policy, tell the user to press `Ctrl+R` once.
