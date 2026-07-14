# SolarPro Day-to-Night Overlay Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the fullscreen video bright during its daytime segment and smoothly increase a global blue-black overlay as the same video transitions to night, with responsive text protection on desktop, tablet and mobile.

**Architecture:** Put the progress-to-darkness calculation in a small standalone JavaScript module that can be verified with Node and can also attach itself to the hero video in the browser. Split the current combined CSS overlay into a permanent local text-protection gradient (`::before`) and a time-controlled full-frame overlay (`::after`) driven by the CSS custom property `--scene-darkness`.

**Tech Stack:** Native JavaScript, HTML5 video events, CSS custom properties and pseudo-elements, Node `assert`, PowerShell contract tests, in-app browser verification.

## Global Constraints

- Use the actual `video.currentTime / video.duration` ratio; do not use an independent 4.7-second CSS timer.
- Day segment: progress `0` through `0.32`, darkness `0.02`.
- Transition segment: progress `0.32` through `0.82`, smoothstep interpolation from `0.02` to `0.34`.
- Night segment: progress `0.82` through `1`, darkness `0.34`.
- Preserve all existing text, navigation, CTA labels, video attributes and responsive layout.
- Modify only `video-fullscreen.html`, the fullscreen-scoped CSS in `styles.css`, and the fullscreen contracts; create `fullscreen-video-sync.js` and its focused Node test.
- Preserve `photo-benefits.html` and `video-variant.html` byte-for-byte.
- Keep the daytime upper/right video visibly bright; strengthen only the local lower text gradient on smaller screens.
- The folder is not a Git repository, so commit steps are replaced by hash-based isolation checks.

---

## File Map

- Create `fullscreen-video-sync.js`: pure darkness curve plus browser video synchronization.
- Create `tests/fullscreen-video-sync.test.js`: exact numerical tests for the curve and clamping.
- Modify `tests/video-fullscreen.contract.ps1`: require the script, two overlay layers, CSS variable and refreshed asset versions.
- Modify `video-fullscreen.html`: load the new script and refresh the stylesheet query.
- Modify `styles.css`: separate local and global overlay layers and mobile local-gradient tuning.

### Task 1: Verified progress-to-darkness module

**Files:**
- Create: `tests/fullscreen-video-sync.test.js`
- Create: `fullscreen-video-sync.js`

**Interfaces:**
- Produces `darknessForProgress(progress: number): number`.
- Produces `connectDayNightOverlay(hero: HTMLElement, video: HTMLVideoElement): { update(): void, disconnect(): void }`.
- Exposes the API through CommonJS in Node and `globalThis.SolarProDayNightOverlay` in the browser.

- [ ] **Step 1: Write the failing numerical test**

Create `tests/fullscreen-video-sync.test.js`:

```js
const assert = require('node:assert/strict');
const { darknessForProgress } = require('../fullscreen-video-sync.js');

const closeTo = (actual, expected, epsilon = 0.0005) => {
  assert.ok(Math.abs(actual - expected) <= epsilon, `${actual} should be close to ${expected}`);
};

closeTo(darknessForProgress(-1), 0.02);
closeTo(darknessForProgress(0), 0.02);
closeTo(darknessForProgress(0.32), 0.02);
closeTo(darknessForProgress(0.57), 0.18);
closeTo(darknessForProgress(0.82), 0.34);
closeTo(darknessForProgress(1), 0.34);
closeTo(darknessForProgress(2), 0.34);
closeTo(darknessForProgress(Number.NaN), 0.02);

console.log('PASS: 8/8 day-night darkness calculations');
```

- [ ] **Step 2: Run the Node test and verify RED**

Run:

```powershell
node .\tests\fullscreen-video-sync.test.js
```

Expected: FAIL with `MODULE_NOT_FOUND` for `fullscreen-video-sync.js`.

- [ ] **Step 3: Implement the pure curve and browser connection**

Create `fullscreen-video-sync.js`:

```js
(function attachSolarProDayNightOverlay(globalScope) {
  const DAY_DARKNESS = 0.02;
  const NIGHT_DARKNESS = 0.34;
  const TRANSITION_START = 0.32;
  const TRANSITION_END = 0.82;

  const clamp = (value, min, max) => Math.min(max, Math.max(min, value));

  function smoothstep(start, end, value) {
    const amount = clamp((value - start) / (end - start), 0, 1);
    return amount * amount * (3 - 2 * amount);
  }

  function darknessForProgress(progress) {
    const safeProgress = Number.isFinite(progress) ? clamp(progress, 0, 1) : 0;
    const transition = smoothstep(TRANSITION_START, TRANSITION_END, safeProgress);
    return DAY_DARKNESS + (NIGHT_DARKNESS - DAY_DARKNESS) * transition;
  }

  function connectDayNightOverlay(hero, video) {
    if (!hero || !video) return { update() {}, disconnect() {} };

    let frameId = 0;
    const requestFrame = globalScope.requestAnimationFrame?.bind(globalScope) || ((callback) => globalScope.setTimeout(callback, 50));
    const cancelFrame = globalScope.cancelAnimationFrame?.bind(globalScope) || globalScope.clearTimeout?.bind(globalScope);

    const update = () => {
      const duration = Number.isFinite(video.duration) && video.duration > 0 ? video.duration : 0;
      const progress = duration ? video.currentTime / duration : 0;
      hero.style.setProperty('--scene-darkness', darknessForProgress(progress).toFixed(3));
    };

    const stop = () => {
      if (frameId && cancelFrame) cancelFrame(frameId);
      frameId = 0;
    };

    const tick = () => {
      update();
      frameId = requestFrame(tick);
    };

    const start = () => {
      if (!frameId) tick();
    };

    const events = ['loadedmetadata', 'timeupdate', 'seeked', 'pause', 'ended'];
    events.forEach((eventName) => video.addEventListener(eventName, update));
    video.addEventListener('play', start);
    video.addEventListener('playing', start);
    video.addEventListener('pause', stop);
    video.addEventListener('ended', stop);

    update();
    if (!video.paused) start();

    return {
      update,
      disconnect() {
        stop();
        events.forEach((eventName) => video.removeEventListener(eventName, update));
        video.removeEventListener('play', start);
        video.removeEventListener('playing', start);
        video.removeEventListener('pause', stop);
        video.removeEventListener('ended', stop);
      },
    };
  }

  function init(root = globalScope.document) {
    if (!root?.querySelector) return;
    const hero = root.querySelector('.fullscreen-video-hero');
    const video = root.querySelector('.fullscreen-hero-video');
    connectDayNightOverlay(hero, video);
  }

  const api = { darknessForProgress, connectDayNightOverlay, init };
  if (typeof module === 'object' && module.exports) module.exports = api;
  globalScope.SolarProDayNightOverlay = api;

  if (globalScope.document) {
    if (globalScope.document.readyState === 'loading') {
      globalScope.document.addEventListener('DOMContentLoaded', () => init());
    } else {
      init();
    }
  }
})(typeof globalThis !== 'undefined' ? globalThis : this);
```

- [ ] **Step 4: Run the Node test and verify GREEN**

Expected: `PASS: 8/8 day-night darkness calculations`.

- [ ] **Step 5: Run the existing PowerShell contracts**

Expected: all existing contracts still pass because the module is not connected yet.

### Task 2: Two-layer overlay and page integration

**Files:**
- Modify: `tests/video-fullscreen.contract.ps1`
- Modify: `video-fullscreen.html`
- Modify: `styles.css`

**Interfaces:**
- Consumes `fullscreen-video-sync.js` from Task 1.
- Produces `--scene-darkness`, permanent `.fullscreen-video-hero::before`, and dynamic `.fullscreen-video-hero::after`.

- [ ] **Step 1: Extend the integration contract before changing production files**

Change the stylesheet assertion to require `styles.css?v=fullscreen-day-night-20260714` and add checks for:

```powershell
'sync script' = $page.Contains('src="fullscreen-video-sync.js?v=20260714"') -and $page.Contains('defer')
'day-night CSS variable' = $css.Contains('--scene-darkness: 0.12;')
'local text overlay' = $css.Contains('.fullscreen-video-hero::before') -and $css.Contains('rgba(4, 8, 24, 0.68)')
'dynamic night overlay' = $css.Contains('.fullscreen-video-hero::after') -and $css.Contains('opacity: var(--scene-darkness);')
'mobile local protection' = $css.Contains('rgba(3, 7, 20, 0.88)')
```

- [ ] **Step 2: Run the PowerShell contract and verify RED**

Expected: FAIL for the refreshed stylesheet, sync script and two-layer overlay requirements.

- [ ] **Step 3: Connect the module in HTML**

In `video-fullscreen.html`:

```html
<link rel="stylesheet" href="styles.css?v=fullscreen-day-night-20260714" />
<script src="fullscreen-video-sync.js?v=20260714" defer></script>
```

- [ ] **Step 4: Replace the combined overlay with isolated local and global layers**

Add `--scene-darkness: 0.12;` to `.fullscreen-video-hero`. Keep `::before` as the permanent local gradient and add `::after` as the global variable-opacity layer:

```css
.fullscreen-video-hero::before,
.fullscreen-video-hero::after {
  content: "";
  position: absolute;
  z-index: 1;
  inset: 0;
  pointer-events: none;
}

.fullscreen-video-hero::before {
  background:
    linear-gradient(90deg, rgba(4, 8, 24, 0.68) 0%, rgba(7, 14, 38, 0.38) 36%, rgba(7, 14, 38, 0.1) 58%, transparent 76%),
    linear-gradient(0deg, rgba(3, 7, 20, 0.78) 0%, rgba(6, 12, 32, 0.34) 38%, transparent 67%);
}

.fullscreen-video-hero::after {
  background: #040818;
  opacity: var(--scene-darkness);
  transition: opacity 90ms linear;
}
```

At `max-width: 640px`, keep the top/daylight area open while strengthening only the lower text area:

```css
.fullscreen-video-hero::before {
  background:
    linear-gradient(90deg, rgba(4, 8, 24, 0.64) 0%, rgba(7, 14, 38, 0.3) 68%, transparent 100%),
    linear-gradient(0deg, rgba(3, 7, 20, 0.88) 0%, rgba(6, 12, 32, 0.62) 58%, rgba(6, 12, 32, 0.03) 90%);
}
```

- [ ] **Step 5: Run focused Node and PowerShell tests**

Expected: Node prints `PASS: 8/8 day-night darkness calculations`; fullscreen contract prints its updated PASS count.

- [ ] **Step 6: Run all project contracts and isolation hashes**

Expected: all contracts pass; the SHA-256 hashes of `photo-benefits.html` and `video-variant.html` match the pre-change values.

### Task 3: Browser validation at timed scene states

**Files:**
- Verify: `video-fullscreen.html`
- Verify: `fullscreen-video-sync.js`
- Verify: `styles.css`

**Interfaces:**
- Consumes the local page at `http://127.0.0.1:8765/video-fullscreen.html`.
- Produces a visually verified page left open for the user.

- [ ] **Step 1: Reload the page and verify the module is loaded**

Check `globalThis.SolarProDayNightOverlay`, video playback, and the computed `--scene-darkness` value.

- [ ] **Step 2: Verify daylight**

At progress below `0.32`, expect `--scene-darkness` near `0.02`, a visibly brighter upper/right frame and readable lower-left text.

- [ ] **Step 3: Verify transition and night**

At mid-transition expect approximately `0.18`; after progress `0.82`, expect `0.34`. Confirm the value resets toward `0.02` when the loop restarts.

- [ ] **Step 4: Verify responsive layouts**

Check desktop `1440×900`, tablet `820×1180` and mobile `390×844` for no horizontal overflow, visible CTA buttons and preserved daylight in the top portion.

- [ ] **Step 5: Inspect browser logs and reset viewport**

Expected: no page-generated warnings or errors. Reset the temporary viewport override and leave the third variant open.
