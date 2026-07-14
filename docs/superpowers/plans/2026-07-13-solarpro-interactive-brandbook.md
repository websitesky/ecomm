# SolarPro Interactive Brandbook Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Побудувати інтерактивний український брендбук, який перемикає три задані палітри на реальних елементах інтернет-магазину SolarPro.

**Architecture:** Один самодостатній HTML-фрагмент містить семантичну розмітку, локальні стилі та невеликий масив даних палітр. Функція `applyPalette(id)` синхронно оновлює CSS-змінні, підписи, HEX-коди, стани кнопок і рекомендацію без мережевих запитів.

**Tech Stack:** HTML, CSS, vanilla JavaScript, CSS custom properties, нативні кнопки, доступний у середовищі набір Lucide.

## Global Constraints

- Файл візуалізації: `C:/Users/slm08/.codex/visualizations/2026/07/13/019f5beb-d5c9-7323-aa55-41a294b10122/solarpro-brandbook.html`.
- Кореневий елемент має унікальний ID `solarpro-brandbook`.
- Файл є HTML-фрагментом без `doctype`, `html`, `head` і `body`.
- Точні кольори: `#1A237E` / `#2979FF` / `#FFFFFF`; `#37474F` / `#4CAF50` / `#ECEFF1`; `#212121` / `#FF9100` / `#FFFFFF`.
- Початковий вибір: `technology` — «Технологічний лідер».
- Радіус демонстраційних кнопок і картки товару: `8px`.
- Основний шрифт: Inter; Montserrat показується як альтернатива для заголовка.
- Підтримка ширини від `320px` без горизонтального прокручування.
- Жодних мережевих запитів, фотографій або змін до `index.html` і `styles.css`.

---

### Task 1: Interactive brandbook fragment

**Files:**
- Create: `C:/Users/slm08/.codex/visualizations/2026/07/13/019f5beb-d5c9-7323-aa55-41a294b10122/solarpro-brandbook.html`

**Interfaces:**
- Consumes: три палітри та композицію з дизайн-специфікації.
- Produces: `const palettes`, `applyPalette(id: string): void`, три кнопки `[data-palette]`, динамічні вузли `[data-bind]` і CSS-змінні `--brand-main`, `--brand-accent`, `--brand-support`, `--brand-soft`, `--brand-on-main`, `--brand-on-accent`.

- [ ] **Step 1: Зафіксувати перевірювані DOM-контракти**

Перевірка після створення фрагмента має використовувати такі точні умови:

```javascript
const root = document.getElementById('solarpro-brandbook');
const buttons = [...root.querySelectorAll('[data-palette]')];
if (buttons.length !== 3) throw new Error('Expected 3 palette buttons');
if (!buttons.every((button) => button.tagName === 'BUTTON')) throw new Error('Palette controls must be buttons');
if (root.querySelectorAll('[data-role="swatch"]').length !== 3) throw new Error('Expected 3 live swatches');
if (!root.querySelector('[data-role="ratio"]')) throw new Error('Missing 60-30-10 ratio');
if (!root.querySelector('[data-role="product"]')) throw new Error('Missing product example');
```

- [ ] **Step 2: Створити початкову розмітку й переконатися, що перевірка взаємодії ще не проходить**

Початкова розмітка містить три кнопки, hero, три зразки кольору, смугу 60–30–10, типографіку, товар і рекомендацію, але без обробника кліків. Очікуваний результат ручної перевірки: натискання «Еко-інновації» не змінює `aria-pressed` і HEX-коди.

- [ ] **Step 3: Реалізувати дані палітр і `applyPalette`**

Функція має відповідати такому контракту:

```javascript
function applyPalette(id) {
  const palette = palettes[id];
  if (!palette) return;
  root.dataset.activePalette = id;
  root.style.setProperty('--brand-main', palette.main);
  root.style.setProperty('--brand-accent', palette.accent);
  root.style.setProperty('--brand-support', palette.support);
  root.style.setProperty('--brand-soft', palette.soft);
  root.style.setProperty('--brand-on-main', palette.onMain);
  root.style.setProperty('--brand-on-accent', palette.onAccent);
  buttons.forEach((button) => {
    button.setAttribute('aria-pressed', String(button.dataset.palette === id));
  });
  root.querySelectorAll('[data-bind]').forEach((node) => {
    node.textContent = palette[node.dataset.bind];
  });
}
```

Дані мають містити ключі `name`, `tagline`, `main`, `accent`, `support`, `soft`, `onMain`, `onAccent`, `mainLabel`, `accentLabel`, `supportLabel`, `mood`, `useCase` для кожного з ID `technology`, `eco`, `energy`.

- [ ] **Step 4: Додати адаптивні стилі й доступні стани**

Використати `display: grid`, `minmax(0, 1fr)`, перенесення кнопок і медіа-запит `@media (max-width: 560px)`. Демонстраційні фони та кнопки використовують лише CSS-змінні `--brand-*`, а нейтральний інтерфейс — змінні теми середовища. Активний перемикач дублює вибір через `aria-pressed="true"` і текст «Обрано».

- [ ] **Step 5: Запустити DOM-перевірку та перевірку трьох станів**

Для кожного ID виконати:

```javascript
applyPalette('technology');
if (root.style.getPropertyValue('--brand-main') !== '#1A237E') throw new Error('Technology main mismatch');
applyPalette('eco');
if (root.style.getPropertyValue('--brand-accent') !== '#4CAF50') throw new Error('Eco accent mismatch');
applyPalette('energy');
if (root.style.getPropertyValue('--brand-accent') !== '#FF9100') throw new Error('Energy accent mismatch');
applyPalette('technology');
```

Очікувано: помилок немає, наприкінці активна синя палітра.

### Task 2: Visual and responsive verification

**Files:**
- Verify: `C:/Users/slm08/.codex/visualizations/2026/07/13/019f5beb-d5c9-7323-aa55-41a294b10122/solarpro-brandbook.html`

**Interfaces:**
- Consumes: готовий фрагмент із `applyPalette(id)`.
- Produces: перевірений макет без переповнення й з робочими трьома станами.

- [ ] **Step 1: Перевірити структуру файлу**

Підтвердити відсутність заборонених оболонок і мережевих викликів:

```powershell
rg -n '<!doctype|<html|<head|<body|fetch\(|XMLHttpRequest|WebSocket' 'C:\Users\slm08\.codex\visualizations\2026\07\13\019f5beb-d5c9-7323-aa55-41a294b10122\solarpro-brandbook.html'
```

Очікувано: збігів немає.

- [ ] **Step 2: Відкрити фрагмент у браузерній перевірці**

Відрендерити фрагмент засобом перегляду середовища та перевірити ширини 736 px і 320 px. Очікувано: немає горизонтального прокручування, кнопки не обрізані, hero і товарна частина стають вертикальними на вузькому екрані.

- [ ] **Step 3: Перевірити взаємодію мишею та клавіатурою**

Натиснути послідовно «Еко-інновації», «Сучасна енергія», «Технологічний лідер». Очікувано: змінюються hero, кнопки, товар, зразки, HEX-коди, правило 60–30–10 і рекомендація; лише одна кнопка має `aria-pressed="true"`.

- [ ] **Step 4: Фінальна перевірка тексту**

Підтвердити, що всі українські написи читаються коректно, а палітри містять точні HEX-коди. Очікувано: символів на кшталт `Ð` або `Ñ` у видимому тексті немає.

- [ ] **Step 5: Commit**

Коміт пропускається: робоча папка не є Git-репозиторієм. Файл плану та візуалізація залишаються у визначених writable roots.
