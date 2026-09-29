#!/usr/bin/env bash
# ==============================================================================
# install.sh — Универсальный скрипт установки пакета правил в целевой проект
#
# Использование:
#   ./install.sh /path/to/project          — применить install.patch (по умолчанию)
#   ./install.sh /path/to/project --dry    — проверить применимость без изменений
#   ./install.sh /path/to/project --copy   — прямое копирование файлов
#   ./install.sh /path/to/project --revert — откатить изменения (uninstall)
# ==============================================================================

set -euo pipefail

TARGET="${1:-.}"
MODE="${2:-patch}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ ! -d "$TARGET" ]; then
  echo "❌ Ошибка: Целевой каталог '$TARGET' не существует."
  exit 1
fi

case "$MODE" in
  --dry)
    echo "=== ПРЕДВАРИТЕЛЬНЫЙ ПРОСМОТР (DIFF) ==="
    cat "$SCRIPT_DIR/diff/install.patch"
    echo
    echo "=== ПРОВЕРКА ПРИМЕНИМОСТИ ==="
    cd "$TARGET"
    git apply --check "$SCRIPT_DIR/diff/install.patch"
    echo "✅ install.patch успешно применим к проекту."
    ;;

  --revert)
    echo "=== ОТКАТ ПРАВИЛ ==="
    cd "$TARGET"
    if [ -f "$SCRIPT_DIR/diff/uninstall.patch" ]; then
      git apply "$SCRIPT_DIR/diff/uninstall.patch"
    else
      git apply -R "$SCRIPT_DIR/diff/install.patch"
    fi
    echo "✅ Пакет правил успешно удалён из $TARGET"
    ;;

  --copy)
    echo "=== ПРЯМОЕ КОПИРОВАНИЕ ==="
    mkdir -p "$TARGET/.agents/rules" "$TARGET/.agents/hooks" "$TARGET/scripts"
    cp "$SCRIPT_DIR/rules/"*.md "$TARGET/.agents/rules/"
    cp "$SCRIPT_DIR/hooks/hooks.json" "$TARGET/.agents/hooks/" 2>/dev/null || true
    cp "$SCRIPT_DIR/hooks/graph-router.sh" "$TARGET/scripts/" 2>/dev/null || true
    chmod +x "$TARGET/scripts/graph-router.sh" 2>/dev/null || true
    echo "✅ Файлы правил успешно скопированы в $TARGET"
    ;;

  *)
    echo "=== ПРИМЕНЕНИЕ PATCH ==="
    cd "$TARGET"
    git apply "$SCRIPT_DIR/diff/install.patch"
    echo "✅ install.patch успешно применён в $TARGET"
    ;;
esac
