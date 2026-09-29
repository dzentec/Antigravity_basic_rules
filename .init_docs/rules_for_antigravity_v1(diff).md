

## A. Обновлённая структура staging

Добавь в раздел 2 (`ЦЕЛЕВАЯ СТРУКТУРА STAGING`) ещё две папки:

```
scratch/rules-staging/
├── README.md
├── sources/                       # склонированные репозитории
├── draft/                         # черновики правил (9 файлов)
├── hooks/                         # черновик хуков
├── diff/                          # ← НОВОЕ
│   ├── install.patch              # unified diff для применения в новом проекте
│   ├── uninstall.patch            # обратный diff для удаления
│   ├── sources-report.md          # что взято из какого репо
│   └── changelog.md               # что нового/изменено vs предыдущая версия
└── validation/
    ├── check-size.sh
    ├── check-frontmatter.sh
    ├── check-diff.sh              # ← НОВОЕ
    └── report.md
```

---

## B. Новый раздел 6.5: Генерация диффов

Вставь **после** раздела 6 (`ЧЕРНОВИК ХУКОВ`) и **перед** разделом 7 (`ВАЛИДАЦИЯ`):

---

### 6.5. Диффы пакета (`diff/`)

Пакет правил должен быть применим к любому проекту **без ручного копирования файлов**. Для этого генерируются unified diffs.

#### 6.5.1. `diff/install.patch`

Unified diff, который добавляет правила в целевой проект. Формат — совместим с `git apply` и `patch -p1`.

**Как генерировать:**
```bash
cd scratch/rules-staging
mkdir -p diff/tmp-target/.agents/rules diff/tmp-target/.agents/hooks
cp draft/*.md diff/tmp-target/.agents/rules/
cp hooks/hooks.json diff/tmp-target/.agents/hooks/ 2>/dev/null
cp hooks/graph-router.sh diff/tmp-target/scripts/ 2>/dev/null

# Генерируем diff от пустого состояния
diff -ruN /dev/null diff/tmp-target > diff/install.patch

# Очищаем
rm -rf diff/tmp-target
```

**Заголовок патча:**
```
# Rules Package v1.0
# Применение: git apply install.patch
# Или:        patch -p1 < install.patch
# Удаление:   patch -p1 -R < install.patch
```

Патч должен создавать файлы **не перезаписывая** существующие. Если `.agents/rules/00-research-protocol.md` уже есть в проекте — `git apply` **откажет** (это правильное поведение, конфликт надо разрешать вручную).

#### 6.5.2. `diff/uninstall.patch`

Обратный патч для удаления. Генерируется как `diff -ruN diff/tmp-target /dev/null` (обратный порядок аргументов).

**Проверка:** `patch -p1 -R < install.patch` должен давать то же, что `patch -p1 < uninstall.patch`.

#### 6.5.3. `diff/sources-report.md`

Таблица: какой файл правил из каких источников собран.

```markdown
# Источники правил

## 03-python.md
- База: собственный свод, раздел 5.5
- Взято из `lifedever/claude-rules/python.md`:
  - ruff-специфичные правила
  - Protocol в типизации
- Взято из `Lay4U/awesome-ai-rules/.../python/GEMINI.md`:
  - структура frontmatter
- Написано с нуля:
  - правила констант (`Final`, единицы в имени)

## 06-css.md
- Источников нет — написан с нуля
- Принципы: BEM-подобные имена, утилитарные классы, лимит вложенности 3
```

#### 6.5.4. `diff/changelog.md`

Версия пакета + изменения относительно предыдущей.

```markdown
# Changelog

## v1.0 (2026-09-29)
- Первый релиз
- 9 файлов правил
- 3 always_on: 00, 01, 02
- 5 glob: 03, 04, 05, 06, 07
- 1 model_decision: 08
- Хуки: hooks.json + graph-router.sh

## v1.1 (TBD)
- ...
```

**Формат версии:** MAJOR.MINOR.PATCH
- MAJOR — несовместимое изменение (новый trigger, удаление файла)
- MINOR — новое правило или файл
- PATCH — правки формулировок

#### 6.5.5. Разделение патчей (опционально)

Если хочешь применять только часть правил (например, только Python), генерируй **подпатчи**:

```
diff/install.patch              # всё
diff/install-python.patch       # только 03-python.md
diff/install-frontend.patch     # 04, 05, 06
diff/install-always-on.patch    # 00, 01, 02
diff/install-hooks.patch        # только хуки
```

Каждый — самодостаточный unified diff.

---

## C. Обновлённый раздел 10: Перенос в проект (через патч)

Замени старый раздел 10 на этот:

---

## 10. ПЕРЕНОС В ПРОЕКТ

**Два метода. Выбор — за пользователем.**

### Метод A: Через патч (рекомендуется)

```bash
cd /path/to/new-project

# Посмотреть, что будет применено (без изменений)
git apply --check /path/to/rules-package/diff/install.patch

# Посмотреть сам дифф
cat /path/to/rules-package/diff/install.patch

# Применить
git apply /path/to/rules-package/diff/install.patch

# Если git apply не работает (не git-репо) — patch:
patch -p1 < /path/to/rules-package/diff/install.patch
```

**Откат:**
```bash
git apply -R /path/to/rules-package/diff/install.patch
# или
patch -p1 -R < /path/to/rules-package/diff/install.patch
```

### Метод B: Прямое копирование

```bash
mkdir -p .agents/rules .agents/hooks scripts
cp /path/to/rules-package/rules/*.md .agents/rules/
cp /path/to/rules-package/hooks/hooks.json .agents/hooks/ 2>/dev/null
cp /path/to/rules-package/hooks/graph-router.sh scripts/ 2>/dev/null
chmod +x scripts/graph-router.sh 2>/dev/null
```

**Когда какой:**
- **Патч** — если проект под git. Даёт историю, откат, обзор изменений.
- **Копирование** — если надо быстро, без git, или надо перезаписать существующее.

### После переноса — проверить

1. `/memory show` в Antigravity — правила в контексте?
2. `ls -la .agents/rules/` — 9 файлов?
3. Размер каждого файла ≤ 12 000 символов?
4. Frontmatter с `trigger` присутствует?

---

## D. Новый скрипт валидации `validation/check-diff.sh`

Добавь в `validation/`:

```bash
#!/usr/bin/env bash
# Проверяет, что install.patch применим к пустому проекту и откатывается

set -e

TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

# 1. Пустой git-репо
cd "$TMP"
git init -q
git config user.email "test@test"
git config user.name "test"
git commit --allow-empty -q -m "init"

# 2. Применяем install.patch
if git apply /path/to/rules-staging/diff/install.patch; then
  echo "✅ install.patch применяется"
else
  echo "❌ install.patch НЕ применяется"
  exit 1
fi

# 3. Проверяем, что 9 файлов на месте
count=$(ls .agents/rules/*.md 2>/dev/null | wc -l)
if [ "$count" -eq 9 ]; then
  echo "✅ 9 файлов правил созданы"
else
  echo "❌ Ожидалось 9, найдено $count"
  exit 1
fi

# 4. Откат через uninstall.patch
if git apply /path/to/rules-staging/diff/uninstall.patch; then
  echo "✅ uninstall.patch применяется"
else
  echo "❌ uninstall.patch НЕ применяется"
  exit 1
fi

# 5. Проверяем, что файлов нет
if [ -z "$(ls .agents/rules/*.md 2>/dev/null)" ]; then
  echo "✅ Откат чистый"
else
  echo "❌ Откат неполный"
  exit 1
fi
```

---

## E. Обновлённый `install.sh` (в корне пакета)

```bash
#!/usr/bin/env bash
# install.sh — установка пакета правил в целевой проект
# Использование:
#   ./install.sh /path/to/project          — применить install.patch
#   ./install.sh /path/to/project --copy   — скопировать файлы
#   ./install.sh /path/to/project --dry    — показать diff без применения
#   ./install.sh /path/to/project --revert — откатить

set -e

TARGET="${1:-.}"
MODE="${2:-patch}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

case "$MODE" in
  --dry)
    echo "=== DIFF ==="
    cat "$SCRIPT_DIR/diff/install.patch"
    echo
    echo "=== CHECK ==="
    cd "$TARGET" && git apply --check "$SCRIPT_DIR/diff/install.patch" && echo "✅ Применим"
    ;;

  --revert)
    cd "$TARGET"
    git apply -R "$SCRIPT_DIR/diff/install.patch"
    echo "✅ Откат применён"
    ;;

  --copy)
    mkdir -p "$TARGET/.agents/rules" "$TARGET/.agents/hooks" "$TARGET/scripts"
    cp "$SCRIPT_DIR/rules/"*.md "$TARGET/.agents/rules/"
    cp "$SCRIPT_DIR/hooks/hooks.json" "$TARGET/.agents/hooks/" 2>/dev/null || true
    cp "$SCRIPT_DIR/hooks/graph-router.sh" "$TARGET/scripts/" 2>/dev/null || true
    chmod +x "$TARGET/scripts/graph-router.sh" 2>/dev/null || true
    echo "✅ Скопировано в $TARGET"
    ;;

  *)
    cd "$TARGET"
    git apply "$SCRIPT_DIR/diff/install.patch"
    echo "✅ Патч применён в $TARGET"
    ;;
esac
```

---

## F. Обновлённый критерий готовности staging

Добавь в раздел 11:

- [ ] `diff/install.patch` сгенерирован
- [ ] `diff/uninstall.patch` сгенерирован
- [ ] `diff/sources-report.md` заполнен
- [ ] `diff/changelog.md` создан с версией
- [ ] `check-diff.sh` прогнан, install/uninstall применяются чисто
- [ ] `install.sh` в корне пакета работает в режиме `--dry`

---

## G. Обновлённая итоговая структура пакета

Пакет, который агент сдаёт, теперь выглядит так:

```
rules-package/                  # пакет после сборки
├── README.md                   # как импортировать (3 метода)
├── install.sh                  # скрипт установки
├── rules/                      # 9 файлов правил
│   ├── 00-research-protocol.md
│   ├── 01-architecture.md
│   ├── 02-no-crutches.md
│   ├── 03-python.md
│   ├── 04-javascript.md
│   ├── 05-html.md
│   ├── 06-css.md
│   ├── 07-tests.md
│   └── 08-commits.md
├── hooks/
│   ├── hooks.json
│   └── graph-router.sh
└── diff/
    ├── install.patch
    ├── uninstall.patch
    ├── sources-report.md
    └── changelog.md
```

Этот пакет — самодостаточный. Кладёшь его в git, клонируешь в любой проект, применяешь патч.

---
