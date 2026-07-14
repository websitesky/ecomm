# SolarPro Photo Benefits Overlay Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Створити окрему версію hero, де три переваги показані на темно-синій скляній картці поверх фотографії.

**Architecture:** `index.html` залишається поточним варіантом. Нова `photo-benefits.html` використовує ті самі `styles.css` та фотографію, але має body-клас `photo-benefits-variant`; стилі накладки ізольовані цим класом.

**Tech Stack:** HTML5, CSS3, PowerShell contract tests, локальна браузерна перевірка.

## Global Constraints

- `index.html` не змінюється.
- Нова сторінка: `photo-benefits.html`.
- Накладка: `rgba(16, 27, 92, 0.82)`, `blur(12px)`, рамка `rgba(255, 255, 255, 0.18)`, радіус `12px`.
- Відступ накладки: `24px` на десктопі й планшеті, `12px` на смартфоні.
- Три погоджені переваги залишаються семантичним `<ul>`.
- Ken Burns, `prefers-reduced-motion`, CTA та навігація не змінюються.
- Перевірка: `1440px`, `1024px`, `768px`, `375px`, `320px`.
- Активні Git-метадані відсутні, тому коміт не створюється.

---

### Task 1: Контракт окремої сторінки

**Files:**
- Create: `tests/photo-benefits.contract.ps1`
- Test: `tests/photo-benefits.contract.ps1`

**Interfaces:**
- Consumes: `photo-benefits.html`, `styles.css`, `assets/hero-solar-home.jpg`.
- Produces: автоматичну перевірку ізоляції, структури накладки й погоджених стилів.

- [ ] **Step 1: Створити тест**

```powershell
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$variantPath = Join-Path $root 'photo-benefits.html'
$indexPath = Join-Path $root 'index.html'
$cssPath = Join-Path $root 'styles.css'
$imagePath = Join-Path $root 'assets/hero-solar-home.jpg'

if (-not (Test-Path -LiteralPath $variantPath)) {
  throw 'Photo benefits variant is missing'
}

$variant = Get-Content -Raw -Encoding utf8 -LiteralPath $variantPath
$index = Get-Content -Raw -Encoding utf8 -LiteralPath $indexPath
$css = Get-Content -Raw -Encoding utf8 -LiteralPath $cssPath
$figure = [regex]::Match($variant, '(?s)<figure class="hero-media">(?<content>.*?)</figure>')
$benefitCount = [regex]::Matches($variant, 'class="hero-benefits"').Count

function Decode-Utf8([string]$base64) {
  return [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($base64))
}

$benefits = @(
  (Decode-Utf8 '0JbQuNCy0LvQtdC90L3RjyDQv9GW0LQg0YfQsNGBINCy0ZbQtNC60LvRjtGH0LXQvdGM'),
  (Decode-Utf8 '0JXQutC+0L3QvtC80L3RltGI0LUg0YHQv9C+0LbQuNCy0LDQvdC90Y8g0LXQvdC10YDQs9GW0Zc='),
  (Decode-Utf8 '0KHQuNGB0YLQtdC80LAsINGJ0L4g0LfRgNC+0YHRgtCw0ZQg0YDQsNC30L7QvCDRltC3INCy0LDRiNC40LzQuCDQv9C+0YLRgNC10LHQsNC80Lg=')
)

$checks = [ordered]@{
  'original remains standard' = $index.Contains('<ul class="hero-benefits"') -and -not $index.Contains('photo-benefits-variant')
  'variant body class' = $variant.Contains('class="photo-benefits-variant"')
  'single benefits list' = $benefitCount -eq 1
  'benefits inside photo' = $figure.Success -and $figure.Groups['content'].Value.Contains('class="hero-benefits"')
  'all benefits present' = @($benefits | Where-Object { -not $variant.Contains($_) }).Count -eq 0
  'local image' = (Test-Path -LiteralPath $imagePath) -and $variant.Contains('src="assets/hero-solar-home.jpg"')
  'isolated overlay styles' = $css.Contains('.photo-benefits-variant .hero-media .hero-benefits')
  'overlay background' = $css.Contains('background: rgba(16, 27, 92, 0.82);')
  'overlay blur' = $css.Contains('backdrop-filter: blur(12px);')
  'mobile inset' = $css.Contains('inset: auto 12px 12px;')
}

$failed = @($checks.GetEnumerator() | Where-Object { -not $_.Value } | ForEach-Object Key)
if ($failed.Count -gt 0) {
  throw ('Photo benefits contract failures: ' + ($failed -join ', '))
}

Write-Output ('PASS: {0}/{0} photo benefits checks' -f $checks.Count)
```

- [ ] **Step 2: Запустити тест і побачити очікувану помилку**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\photo-benefits.contract.ps1
```

Expected: `Photo benefits variant is missing`.

---

### Task 2: Окрема HTML-сторінка з перевагами у фотоблоці

**Files:**
- Create: `photo-benefits.html`
- Test: `tests/photo-benefits.contract.ps1`

**Interfaces:**
- Consumes: наявні класи hero та `styles.css`.
- Produces: body-клас `.photo-benefits-variant` і один `.hero-benefits` усередині `.hero-media`.

- [ ] **Step 1: Створити сторінку з тією самою структурою hero**

Використати поточний вміст `index.html`, внести лише ці дві структурні відмінності:

```html
<body class="photo-benefits-variant">
```

Видалити `<ul class="hero-benefits">…</ul>` із `.hero-copy` та вставити той самий список після `<img>` усередині `<figure class="hero-media">`:

```html
<figure class="hero-media">
  <img
    class="hero-image"
    src="assets/hero-solar-home.jpg"
    width="736"
    height="736"
    alt="Сучасний будинок із сонячними панелями, інвертором і зарядною станцією"
    fetchpriority="high"
    decoding="async"
  />
  <ul class="hero-benefits" aria-label="Переваги енергетичної системи">
    <li><span class="benefit-icon" aria-hidden="true">✓</span><span>Живлення під час відключень</span></li>
    <li><span class="benefit-icon" aria-hidden="true">✓</span><span>Економніше споживання енергії</span></li>
    <li><span class="benefit-icon" aria-hidden="true">✓</span><span>Система, що зростає разом із вашими потребами</span></li>
  </ul>
</figure>
```

- [ ] **Step 2: Запустити тест**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\photo-benefits.contract.ps1
```

Expected: FAIL лише для `isolated overlay styles`, `overlay background`, `overlay blur`, `mobile inset`.

---

### Task 3: Ізольовані стилі скляної накладки

**Files:**
- Modify: `styles.css`
- Test: `tests/photo-benefits.contract.ps1`

**Interfaces:**
- Consumes: `.photo-benefits-variant .hero-media .hero-benefits` із Task 2.
- Produces: стабільну темну накладку над рухомою фотографією.

- [ ] **Step 1: Додати базові стилі варіанта перед медіазапитами**

```css
.photo-benefits-variant .hero-media .hero-benefits {
  position: absolute;
  z-index: 4;
  inset: auto 24px 24px;
  display: grid;
  grid-template-columns: minmax(0, 1fr);
  gap: 10px;
  max-width: none;
  margin: 0;
  padding: 18px 20px;
  border: 1px solid rgba(255, 255, 255, 0.18);
  border-radius: 12px;
  background: rgba(16, 27, 92, 0.82);
  box-shadow: 0 18px 42px rgba(8, 16, 64, 0.3);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
}

.photo-benefits-variant .hero-media .hero-benefits li {
  color: var(--paper);
  font-size: 14px;
  font-weight: 650;
  line-height: 1.35;
}

.photo-benefits-variant .hero-media .benefit-icon {
  color: var(--paper);
  background: rgba(41, 121, 255, 0.72);
}
```

- [ ] **Step 2: Додати мобільне перевизначення в `@media (max-width: 640px)`**

```css
.photo-benefits-variant .hero-media .hero-benefits {
  inset: auto 12px 12px;
  gap: 8px;
  padding: 14px;
}

.photo-benefits-variant .hero-media .hero-benefits li {
  font-size: 14px;
}
```

- [ ] **Step 3: Запустити обидва контракти**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\hero.contract.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\photo-benefits.contract.ps1
```

Expected: `PASS: 19/19 hero contract checks` і `PASS: 10/10 photo benefits checks`.

- [ ] **Step 4: Перевірити баланс CSS-дужок**

Run:

```powershell
$css = Get-Content -Raw -Encoding utf8 styles.css
$open = ($css.ToCharArray() | Where-Object { $_ -eq '{' }).Count
$close = ($css.ToCharArray() | Where-Object { $_ -eq '}' }).Count
if ($open -ne $close) { throw "Unbalanced CSS braces: $open/$close" }
"PASS: CSS braces balanced ($open/$close)"
```

Expected: `PASS: CSS braces balanced`.

---

### Task 4: Візуальне порівняння

**Files:**
- Verify: `index.html`
- Verify: `photo-benefits.html`

**Interfaces:**
- Consumes: дві локальні сторінки.
- Produces: готовий варіант для вибору користувачем.

- [ ] **Step 1: Перевірити `photo-benefits.html` на `1440px`, `1024px`, `768px`**

Expected: накладка має відступ `24px`, три вертикальні рядки, не перекриває панелі та інвертор, немає горизонтального прокручування.

- [ ] **Step 2: Перевірити `375px` і `320px`**

Expected: накладка має відступ `12px`, повністю вміщується у фото, текст не обрізаний, горизонтального прокручування немає.

- [ ] **Step 3: Перевірити ізоляцію та консоль**

Expected: `index.html` і далі показує переваги під кнопками; `photo-benefits.html` показує їх лише на фото; обидві сторінки не мають console errors/warnings.
