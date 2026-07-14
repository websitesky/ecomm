# SolarPro Sticky Header and Gradient Buttons Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Додати липку шапку, градієнтне hover-підсвічування меню та преміальні анімовані градієнти CTA-кнопок.

**Architecture:** Уся поведінка реалізується в `styles.css` без JavaScript і автоматично застосовується до `index.html` та `photo-benefits.html`. Новий PowerShell-контракт перевіряє наявність sticky-позиціонування, градієнтів, відблиску та reduced-motion правил.

**Tech Stack:** CSS3, PowerShell contract tests, браузерна перевірка hover/scroll/responsive.

## Global Constraints

- `.header`: `position: sticky`, `top: 12px`, `z-index: 30`.
- `.hero`: `overflow: clip`.
- Основний градієнт: `#1A237E → #2979FF → #61A0FF`, `120deg`.
- Додатковий градієнт: `#FFFFFF → #EDF4FF`.
- Відблиск запускається лише на hover/focus-visible.
- `prefers-reduced-motion` вимикає переміщення.
- JavaScript не додається.
- Активні Git-метадані відсутні, тому коміт не створюється.

---

### Task 1: Контракт інтерактивних стилів

**Files:**
- Create: `tests/interaction-styles.contract.ps1`

**Interfaces:**
- Consumes: `styles.css`.
- Produces: 12 перевірок sticky-шапки, меню, двох кнопок, відблиску та reduced motion.

- [ ] **Step 1: Створити тест**

```powershell
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$css = Get-Content -Raw -Encoding utf8 -LiteralPath (Join-Path $root 'styles.css')

$checks = [ordered]@{
  'hero clip overflow' = $css.Contains('overflow: clip;')
  'sticky header' = $css.Contains('position: sticky;')
  'sticky top' = $css.Contains('top: 12px;')
  'sticky layer' = $css.Contains('z-index: 30;')
  'nav gradient underline' = $css.Contains('linear-gradient(90deg, #75a7ff 0%, var(--blue) 52%, var(--blue-deep) 100%)')
  'nav hover lift' = $css.Contains('transform: translateY(-1px);')
  'button shine' = $css.Contains('.btn::before') -and $css.Contains('skewX(-18deg)')
  'button shine hover' = $css.Contains('.btn:hover::before') -and $css.Contains('.btn:focus-visible::before')
  'primary gradient' = $css.Contains('linear-gradient(120deg, var(--blue-deep) 0%, var(--blue) 55%, #61a0ff 100%)')
  'moving gradient' = $css.Contains('background-size: 200% 100%;') -and $css.Contains('background-position: 100% 50%;')
  'secondary gradient' = $css.Contains('linear-gradient(135deg, var(--paper) 0%, #edf4ff 100%)')
  'shine reduced motion' = $css.Contains('.btn::before,') -and $css.Contains('.btn:hover::before,')
}

$failed = @($checks.GetEnumerator() | Where-Object { -not $_.Value } | ForEach-Object Key)
if ($failed.Count -gt 0) { throw ('Interaction style failures: ' + ($failed -join ', ')) }
Write-Output ('PASS: {0}/{0} interaction style checks' -f $checks.Count)
```

- [ ] **Step 2: Запустити тест і підтвердити очікувану помилку**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\interaction-styles.contract.ps1
```

Expected: FAIL для sticky, нових градієнтів і відблиску.

---

### Task 2: Липка шапка й hover меню

**Files:**
- Modify: `styles.css`
- Test: `tests/interaction-styles.contract.ps1`

**Interfaces:**
- Consumes: `.hero`, `.header`, `.nav a`, `.nav a::after`.
- Produces: sticky-шапку та анімовану градієнтну лінію меню.

- [ ] **Step 1: Оновити hero й header**

```css
.hero {
  overflow: clip;
}

.header {
  position: sticky;
  top: 12px;
  z-index: 30;
  background: rgba(255, 255, 255, 0.9);
}
```

Зберегти всі інші поточні властивості цих селекторів.

- [ ] **Step 2: Оновити hover меню**

```css
.nav a {
  transition: color 180ms ease, transform 180ms ease;
}

.nav a::after {
  background: linear-gradient(90deg, #75a7ff 0%, var(--blue) 52%, var(--blue-deep) 100%);
  box-shadow: 0 3px 12px rgba(41, 121, 255, 0.42);
}

.nav a:hover {
  color: var(--blue);
  transform: translateY(-1px);
}
```

- [ ] **Step 3: Запустити тест**

Expected: FAIL лише для кнопок і reduced motion.

---

### Task 3: Градієнтні кнопки й рухомий відблиск

**Files:**
- Modify: `styles.css`
- Test: `tests/interaction-styles.contract.ps1`

**Interfaces:**
- Consumes: `.btn`, `.btn-primary`, `.btn-secondary`.
- Produces: два градієнти, hover-світіння та `.btn::before`.

- [ ] **Step 1: Підготувати кнопку й відблиск**

```css
.btn {
  position: relative;
  isolation: isolate;
  overflow: hidden;
}

.btn::before {
  content: "";
  position: absolute;
  z-index: 0;
  top: -45%;
  bottom: -45%;
  left: -36%;
  width: 24%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.55), transparent);
  transform: translateX(-160%) skewX(-18deg);
  transition: transform 550ms ease;
  pointer-events: none;
}

.btn > span {
  position: relative;
  z-index: 1;
}

.btn:hover::before,
.btn:focus-visible::before {
  transform: translateX(620%) skewX(-18deg);
}
```

- [ ] **Step 2: Оновити основну кнопку**

```css
.btn-primary {
  background: linear-gradient(120deg, var(--blue-deep) 0%, var(--blue) 55%, #61a0ff 100%);
  background-size: 200% 100%;
  background-position: 0% 50%;
}

.btn-primary:hover {
  background-position: 100% 50%;
  box-shadow: 0 20px 46px rgba(41, 121, 255, 0.42);
}
```

- [ ] **Step 3: Оновити додаткову кнопку**

```css
.btn-secondary {
  background: linear-gradient(135deg, var(--paper) 0%, #edf4ff 100%);
}

.btn-secondary:hover {
  border-color: var(--blue);
  color: var(--blue-deep);
  background: linear-gradient(135deg, #f7fbff 0%, #dceaff 100%);
  box-shadow: 0 18px 40px rgba(41, 121, 255, 0.22);
}
```

- [ ] **Step 4: Додати reduced-motion перевизначення**

```css
.btn::before,
.nav a {
  transition-duration: 0.01ms;
}

.btn:hover::before,
.btn:focus-visible::before,
.nav a:hover {
  transform: none;
}

.btn-primary:hover {
  background-position: 0% 50%;
}
```

Розмістити ці правила всередині наявного `@media (prefers-reduced-motion: reduce)`.

- [ ] **Step 5: Запустити всі контракти**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\hero.contract.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\photo-benefits.contract.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\interaction-styles.contract.ps1
```

Expected: `PASS: 19/19`, `PASS: 13/13`, `PASS: 12/12`.

---

### Task 4: Браузерна перевірка

**Files:**
- Verify: `index.html`
- Verify: `photo-benefits.html`

- [ ] **Step 1: Перевірити hover/focus кнопок і меню**

Expected: градієнти й світіння змінюються без стрибків геометрії; текст не перекривається відблиском.

- [ ] **Step 2: Перевірити sticky на мобільній сторінці**

Expected: після прокручування `.header` залишається біля `top: 12px`, горизонтального прокручування немає.

- [ ] **Step 3: Перевірити `1440px`, `768px`, `375px`, `320px` і консоль**

Expected: немає накладань, console errors/warnings або поламаних CTA.
