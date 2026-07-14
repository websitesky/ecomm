# SolarPro Hero Benefits Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Зменшити заголовок, перетворити підзаголовок на виразне УТП та додати три адаптивні переваги під CTA-кнопками.

**Architecture:** Зберегти наявний статичний HTML/CSS hero без JavaScript. Додати семантичний список переваг у `index.html`, окремий акцент усередині УТП та адаптивні правила в `styles.css`; розширити поточний PowerShell-контракт для нового контенту й класів.

**Tech Stack:** HTML5, CSS3, PowerShell contract tests, локальна перевірка у браузері.

## Global Constraints

- Заголовок: «Інвертори та сонячні панелі для вашого дому та бізнесу».
- УТП: «Менше залежності від мережі — більше спокою та контролю.»
- Переваги: «Живлення під час відключень», «Економніше споживання енергії», «Система, що зростає разом із вашими потребами».
- Кольори `#1A237E`, `#2979FF`, `#FFFFFF` і `#F5F7FF` не змінюються.
- Ken Burns, `prefers-reduced-motion`, focus/hover-стани та поточна фотографія зберігаються.
- Розміри перевірки: `1440px`, `1024px`, `768px`, `375px`, `320px`.
- Активні Git-метадані в робочій папці відсутні, тому план не передбачає створення коміту.

---

### Task 1: Контракт для акцентного УТП та трьох переваг

**Files:**
- Modify: `tests/hero.contract.ps1`

**Interfaces:**
- Consumes: статичний вміст `index.html` і `styles.css`.
- Produces: перевірки класів `.lead-accent`, `.hero-benefits`, трьох погоджених вигод і адаптивної сітки.

- [ ] **Step 1: Оновити тест новими очікуваннями**

Замінити перевірку суцільного `$subheadline` на перевірку двох текстових частин і додати масив переваг:

```powershell
$subheadlineAccent = 'Менше залежності від мережі'
$subheadlineRest = 'більше спокою та контролю.'
$benefits = @(
  'Живлення під час відключень',
  'Економніше споживання енергії',
  'Система, що зростає разом із вашими потребами'
)

$checks = [ordered]@{
  'local hero image' = Test-Path -LiteralPath $imagePath
  'exact headline' = $html.Contains($headline)
  'highlighted subheadline' = $html.Contains('class="lead-accent"') -and $html.Contains($subheadlineAccent) -and $html.Contains($subheadlineRest)
  'all benefits' = @($benefits | Where-Object { -not $html.Contains($_) }).Count -eq 0
  'benefits semantics' = $html.Contains('class="hero-benefits"') -and $html.Contains('<ul') -and $html.Contains('<li')
  'benefits styles' = $css.Contains('.hero-benefits') -and $css.Contains('.benefit-icon')
  'catalog CTA' = $html.Contains($catalogCta)
  'selection CTA' = $html.Contains($selectionCta)
}
```

Зберегти всі наявні перевірки фотографії, палітри, анімації, брейкпоінтів, reduced motion та focus-станів.

- [ ] **Step 2: Запустити тест і підтвердити очікувану помилку**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\hero.contract.ps1
```

Expected: `Hero contract failures` для нового УТП, переваг і стилів.

---

### Task 2: Семантична розмітка УТП та переваг

**Files:**
- Modify: `index.html`
- Test: `tests/hero.contract.ps1`

**Interfaces:**
- Consumes: погоджений український текст і наявні `.lead`, `.hero-actions`.
- Produces: `.lead-accent`, `.hero-benefits`, `.benefit-icon` для стилізації в Task 3.

- [ ] **Step 1: Додати акцент у підзаголовок**

Замінити поточний `p.lead` на:

```html
<p class="lead">
  <span class="lead-accent">Менше залежності від мережі</span>
  <span> — більше спокою та контролю.</span>
</p>
```

- [ ] **Step 2: Додати список після `.hero-actions`**

```html
<ul class="hero-benefits" aria-label="Переваги енергетичної системи">
  <li><span class="benefit-icon" aria-hidden="true">✓</span><span>Живлення під час відключень</span></li>
  <li><span class="benefit-icon" aria-hidden="true">✓</span><span>Економніше споживання енергії</span></li>
  <li><span class="benefit-icon" aria-hidden="true">✓</span><span>Система, що зростає разом із вашими потребами</span></li>
</ul>
```

- [ ] **Step 3: Запустити контракт**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\hero.contract.ps1
```

Expected: тест усе ще FAIL лише на `benefits styles`, доки Task 3 не додасть CSS.

---

### Task 3: Типографічна ієрархія та адаптивний блок переваг

**Files:**
- Modify: `styles.css`
- Test: `tests/hero.contract.ps1`

**Interfaces:**
- Consumes: `.lead-accent`, `.hero-benefits`, `.benefit-icon` з Task 2.
- Produces: триколонкову десктопну сітку та вертикальний список до `1099px`.

- [ ] **Step 1: Зменшити заголовок і підсилити УТП**

Оновити базові правила:

```css
h1 {
  font-size: clamp(42px, 4.4vw, 64px);
}

.lead {
  max-width: 590px;
  margin: 24px 0 0;
  color: var(--blue-deep);
  font-size: clamp(19px, 1.45vw, 22px);
  font-weight: 600;
  line-height: 1.45;
}

.lead-accent {
  color: var(--blue);
  font-weight: 800;
}

.hero-actions {
  margin-top: 30px;
}
```

- [ ] **Step 2: Додати стилі переваг**

```css
.hero-benefits {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 14px;
  margin: 26px 0 0;
  padding: 20px 0 0;
  border-top: 1px solid var(--line);
  list-style: none;
}

.hero-benefits li {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  color: var(--muted);
  font-size: 14px;
  font-weight: 650;
  line-height: 1.35;
}

.benefit-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 18px;
  height: 18px;
  flex: 0 0 18px;
  border-radius: 50%;
  color: var(--blue);
  background: rgba(41, 121, 255, 0.1);
  font-size: 12px;
  font-weight: 900;
}
```

- [ ] **Step 3: Додати адаптивні правила**

```css
@media (max-width: 1099px) {
  .hero-benefits {
    grid-template-columns: minmax(0, 1fr);
    gap: 10px;
    max-width: 420px;
    margin-top: 22px;
    padding-top: 18px;
  }
}

@media (max-width: 1024px) {
  h1 { font-size: clamp(38px, 5.2vw, 52px); }
  .lead { font-size: 18px; }
}

@media (max-width: 640px) {
  h1 { font-size: clamp(34px, 9.5vw, 42px); }
  .lead { margin-top: 18px; font-size: 18px; }
  .hero-actions { margin-top: 26px; }
  .hero-benefits { max-width: none; }
  .hero-benefits li { font-size: 15px; }
}

@media (max-width: 360px) {
  h1 { font-size: 34px; }
}
```

Замінити наявні конфліктні значення `h1`, `.lead` і `.hero-actions` у відповідних медіазапитах, а не дублювати їх нижче.

- [ ] **Step 4: Запустити контракт і перевірити синтаксис CSS**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\hero.contract.ps1
```

Expected: `PASS` для всіх contract checks.

Run:

```powershell
$css = Get-Content -Raw -Encoding utf8 styles.css; if (($css.ToCharArray() | Where-Object { $_ -eq '{' }).Count -ne ($css.ToCharArray() | Where-Object { $_ -eq '}' }).Count) { throw 'Unbalanced CSS braces' } else { 'PASS: CSS braces balanced' }
```

Expected: `PASS: CSS braces balanced`.

---

### Task 4: Візуальна перевірка адаптивності

**Files:**
- Verify: `index.html`
- Verify: `styles.css`

**Interfaces:**
- Consumes: готовий статичний hero.
- Produces: підтвердження композиції на п’яти погоджених ширинах.

- [ ] **Step 1: Перевірити десктоп `1440px`**

Expected: заголовок не перевищує `64px`; УТП помітне; переваги стоять у три колонки; CTA залишаються основною точкою уваги; фото не перекрито.

- [ ] **Step 2: Перевірити `1024px` і `768px`**

Expected: переваги утворюють вертикальний список; немає накладань і горизонтального прокручування; фотографія не деформована.

- [ ] **Step 3: Перевірити `375px` і `320px`**

Expected: порядок «заголовок → УТП → кнопки → переваги → фото»; шрифт заголовка не менший за `34px`; обидві кнопки на всю ширину; текст переваг не обрізаний.

- [ ] **Step 4: Перевірити доступність і рух**

Expected: клавіатурний фокус кнопок видимий; `prefers-reduced-motion: reduce` вимикає Ken Burns; іконки не озвучуються скрінрідером; контраст тексту достатній.
