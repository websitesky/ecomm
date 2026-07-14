# SolarPro Photo Statement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Замінити синю картку на фотографії білим УТП на нейтральному градієнті, а три переваги перенести під основний заголовок.

**Architecture:** Змінюється лише порівняльна сторінка `photo-benefits.html` і її ізольовані стилі в `styles.css`; `index.html` залишається без змін. Контракт `tests/photo-benefits.contract.ps1` спочатку фіксує нову структуру, потім HTML і CSS доводяться до проходження тесту.

**Tech Stack:** HTML5, CSS3, PowerShell contract tests, локальна браузерна перевірка.

## Global Constraints

- `index.html` не змінюється.
- УТП на фото: «Менше залежності від мережі — більше спокою та контролю».
- Градієнт: `rgba(5, 9, 18, 0.76)` без синьої картки.
- Переваги розміщуються між `h1` і `.hero-actions`.
- Розмір УТП: до `38px` на десктопі, `25px` на смартфоні.
- Відступ УТП: `32px` на десктопі, `20px` на смартфоні.
- Ken Burns, `prefers-reduced-motion`, CTA та навігація не змінюються.
- Активні Git-метадані відсутні, тому коміт не створюється.

---

### Task 1: Оновити контракт нової структури

**Files:**
- Modify: `tests/photo-benefits.contract.ps1`

**Interfaces:**
- Consumes: `photo-benefits.html`, `styles.css`, `index.html`.
- Produces: перевірки `.photo-statement`, розміщення переваг у `.hero-copy`, нейтрального градієнта та відсутності старої картки.

- [ ] **Step 1: Замінити перевірки фотоблоку та стилів**

Додати після `$figure`:

```powershell
$copy = [regex]::Match($variant, '(?s)<div class="hero-copy">(?<content>.*?)</div>')
$statement = Decode-Utf8 '0JzQtdC90YjQtSDQt9Cw0LvQtdC20L3QvtGB0YLRliDQstGW0LQg0LzQtdGA0LXQttGWIOKAlCDQsdGW0LvRjNGI0LUg0YHQv9C+0LrQvtGOINGC0LAg0LrQvtC90YLRgNC+0LvRjg=='
```

Замінити `$checks` на:

```powershell
$checks = [ordered]@{
  'original remains standard' = $index.Contains('<ul class="hero-benefits"') -and -not $index.Contains('photo-benefits-variant')
  'variant body class' = $variant.Contains('class="photo-benefits-variant"')
  'single benefits list' = $benefitCount -eq 1
  'benefits inside copy' = $copy.Success -and $copy.Groups['content'].Value.Contains('class="hero-benefits"')
  'benefits before actions' = $copy.Groups['content'].Value.IndexOf('class="hero-benefits"') -lt $copy.Groups['content'].Value.IndexOf('class="hero-actions"')
  'all benefits present' = @($benefits | Where-Object { -not $variant.Contains($_) }).Count -eq 0
  'statement inside photo' = $figure.Success -and $figure.Groups['content'].Value.Contains('class="photo-statement"') -and $variant.Contains($statement)
  'old lead removed' = -not $copy.Groups['content'].Value.Contains('class="lead"')
  'neutral gradient style' = $css.Contains('.photo-benefits-variant .hero-media::after') -and $css.Contains('rgba(5, 9, 18, 0.76)')
  'statement styles' = $css.Contains('.photo-statement') -and $css.Contains('color: var(--paper);')
  'old blue card removed' = -not $css.Contains('background: rgba(16, 27, 92, 0.82);')
  'mobile statement size' = $css.Contains('font-size: 25px;')
  'local image' = (Test-Path -LiteralPath $imagePath) -and $variant.Contains('src="assets/hero-solar-home.jpg"')
}
```

- [ ] **Step 2: Запустити тест і підтвердити очікувану помилку**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\photo-benefits.contract.ps1
```

Expected: FAIL для нової структури, градієнта та `.photo-statement`.

---

### Task 2: Перебудувати контент `photo-benefits.html`

**Files:**
- Modify: `photo-benefits.html`
- Test: `tests/photo-benefits.contract.ps1`

**Interfaces:**
- Consumes: наявні `.hero-copy`, `.hero-media`, `.hero-benefits`.
- Produces: переваги в лівій колонці й `.photo-statement` у фотоблоці.

- [ ] **Step 1: Прибрати `p.lead` і вставити список після `h1`**

Після `h1` вставити:

```html
<ul class="hero-benefits" aria-label="Переваги енергетичної системи">
  <li><span class="benefit-icon" aria-hidden="true">✓</span><span>Живлення під час відключень</span></li>
  <li><span class="benefit-icon" aria-hidden="true">✓</span><span>Економніше споживання енергії</span></li>
  <li><span class="benefit-icon" aria-hidden="true">✓</span><span>Система, що зростає разом із вашими потребами</span></li>
</ul>
```

- [ ] **Step 2: Замінити список усередині `figure.hero-media` на УТП**

```html
<p class="photo-statement">Менше залежності від мережі — більше спокою та контролю</p>
```

- [ ] **Step 3: Запустити контракт**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\photo-benefits.contract.ps1
```

Expected: FAIL лише для нових CSS-перевірок.

---

### Task 3: Замінити синю картку на нейтральний градієнт і білий текст

**Files:**
- Modify: `styles.css`
- Test: `tests/photo-benefits.contract.ps1`

**Interfaces:**
- Consumes: `.photo-benefits-variant .hero-copy .hero-benefits` і `.photo-statement`.
- Produces: чисту ліву колонку та стабільно читабельне УТП на фото.

- [ ] **Step 1: Замінити старі стилі `.photo-benefits-variant .hero-media .hero-benefits`**

```css
.photo-benefits-variant .hero-copy .hero-benefits {
  grid-template-columns: minmax(0, 1fr);
  gap: 10px;
  max-width: 560px;
  margin: 24px 0 0;
  padding: 0;
  border: 0;
}

.photo-benefits-variant .hero-copy .hero-benefits li {
  color: var(--muted);
  font-size: 16px;
  font-weight: 650;
  line-height: 1.4;
}

.photo-benefits-variant .hero-copy .hero-actions {
  margin-top: 30px;
}

.photo-benefits-variant .hero-media::after {
  z-index: 2;
  inset: 38% 0 0;
  width: 100%;
  background: linear-gradient(180deg, transparent 0%, rgba(5, 9, 18, 0.76) 100%);
}

.photo-statement {
  position: absolute;
  z-index: 4;
  right: 32px;
  bottom: 32px;
  left: 32px;
  max-width: 520px;
  margin: 0;
  color: var(--paper);
  font-size: clamp(28px, 2.5vw, 38px);
  font-weight: 800;
  line-height: 1.12;
  letter-spacing: -0.03em;
  text-shadow: 0 3px 18px rgba(0, 0, 0, 0.42);
  text-wrap: balance;
}
```

- [ ] **Step 2: Замінити мобільні стилі старої картки**

```css
.photo-benefits-variant .hero-copy .hero-benefits {
  margin-top: 22px;
}

.photo-benefits-variant .hero-copy .hero-benefits li {
  font-size: 15px;
}

.photo-statement {
  right: 20px;
  bottom: 20px;
  left: 20px;
  font-size: 25px;
}
```

- [ ] **Step 3: Запустити обидва контракти й перевірити CSS**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\hero.contract.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\photo-benefits.contract.ps1
```

Expected: `PASS: 19/19 hero contract checks` і `PASS: 13/13 photo benefits checks`.

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

### Task 4: Адаптивна візуальна перевірка

**Files:**
- Verify: `index.html`
- Verify: `photo-benefits.html`

**Interfaces:**
- Consumes: дві локальні сторінки.
- Produces: третій варіант для остаточного порівняння.

- [ ] **Step 1: Перевірити `1440px`, `1024px`, `768px`**

Expected: три переваги під `h1`; кнопки після них; біле УТП внизу фото; панелі й інвертор видимі; немає горизонтального прокручування.

- [ ] **Step 2: Перевірити `375px` і `320px`**

Expected: порядок «заголовок → переваги → кнопки → фото»; УТП повністю всередині фотографії; текст не обрізаний.

- [ ] **Step 3: Перевірити ізоляцію й консоль**

Expected: `index.html` не змінився; на обох сторінках немає console errors/warnings.
