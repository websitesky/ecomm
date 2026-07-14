# SolarPro Video Hero Variant Design

## Goal

Create a separate first-screen variant that replaces the current solar-house photo with `1.mp4`, while preserving the approved photo version unchanged for direct comparison.

## Approaches Considered

1. **Separate comparison page (selected).** Create `video-variant.html` from the approved `photo-benefits.html`. This is safest because the current version remains available and the two designs can be compared independently.
2. **Replace the photo on the current page.** Faster, but it would overwrite the approved reference and make comparison harder.
3. **Add a photo/video switch to one page.** Flexible, but adds interface controls and JavaScript that are unnecessary for this design comparison.

## Selected Visual Design

- Keep the current header, headline, three benefit bullets, CTA buttons, color palette, spacing, sticky navigation and responsive rules.
- Replace only the image inside the right-hand media card with `1.mp4`.
- Keep the white statement “Менше залежності від мережі — більше спокою та контролю” over the lower part of the video.
- Keep the current dark lower gradient so the statement remains readable throughout the video loop.
- Preserve the rounded card, border and shadow used by the photo version.
- Use the existing photo as a poster/fallback while the video loads or when playback is unavailable.

## Video Behaviour

- Source: `1.mp4`, unchanged, including its current visible mark.
- Playback: automatic, muted, looped and inline on mobile.
- Controls: hidden, because the video is a decorative hero visual rather than user-controlled content.
- Sizing: `object-fit: cover` inside the existing media card, with a centered focal area.
- Loading: preload metadata and show `assets/hero-solar-home.jpg` as the poster until the first frame is available.
- The video has no functional dependency on the CTA buttons or navigation.

## Accessibility and Fallbacks

- The video is decorative and marked accordingly so it does not duplicate the visible marketing statement for screen readers.
- If video playback is blocked, the poster image remains visible and the page still communicates the complete offer.
- The existing focus styles, reduced-motion button behaviour and responsive typography remain unchanged.
- A later clean video can replace `1.mp4` without changing the HTML structure or page layout.

## Files and Isolation

- Preserve without edits: `photo-benefits.html`.
- Create: `video-variant.html`.
- Modify: `styles.css` only with video-specific selectors that do not change the photo variant.
- Test: add a focused contract for the video page and rerun all existing contracts.
- Git commit is not applicable because this folder is not an active Git repository.

## Verification

- Confirm the approved photo page still renders the original `<img>` and not a video.
- Confirm the video page contains `autoplay`, `muted`, `loop`, `playsinline`, poster and MP4 source attributes.
- Confirm the video fills the card without distortion at desktop, tablet and mobile widths.
- Confirm the white statement stays readable and no horizontal scrolling appears.
- Confirm the video begins playing automatically in the local browser and loops without audio.
- Confirm the browser console contains no warnings or errors.
