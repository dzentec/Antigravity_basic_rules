# 📦 Universal Antigravity Rules Package (v1.0.0)

Переносимый, стек-агностичный свод правил для ИИ-ассистента Antigravity в проектах на Python, JavaScript, HTML5 и CSS3.

---

## 📁 Содержимое пакета

- `rules/` — 9 модульных файлов правил с YAML-триггерами (`always_on`, `glob`, `model_decision`).
- `hooks/` — конфигурация перехвата grep/glob и роутинга в MCP граф знаний (`codebase-memory-mcp`).
- `diff/` — unified diff патчи (`install.patch`, `uninstall.patch`, подпатчи) для безопасного наката через Git.
- `install.sh` / `install.ps1` — кроссплатформенные скрипты установки.

---

## 🚀 Способы установки в проект

### Метод 1: Через Git Patch (Рекомендуемый)
Сохраняет историю Git, предотвращает случайную перезапись файлов при конфликтах:

```bash
# Предпросмотр и проверка
./install.sh /path/to/project --dry

# Применение
./install.sh /path/to/project

# Откат при необходимости
./install.sh /path/to/project --revert
```

В PowerShell (Windows):
```powershell
.\install.ps1 -Target "D:\Projects\MyProject"
```

---

### Метод 2: Ручной Git Apply
```bash
cd /path/to/my-project
git apply /path/to/rules-package/diff/install.patch
```

---

### Метод 3: Прямое копирование файлов
Если проект не находится под управлением Git:

```bash
./install.sh /path/to/project --copy
```

---

## 🔍 Проверка после установки

1. В чате Antigravity выполните команду:
   ```text
   /memory show
   ```
2. Убедитесь, что правила отображаются в активном контексте.
3. Убедитесь в наличии 9 файлов в каталоге `.agents/rules/`.
