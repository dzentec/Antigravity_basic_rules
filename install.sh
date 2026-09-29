#!/usr/bin/env bash
# ==============================================================================
# install.sh — Universal installation script for the rules package
#
# Usage:
#   ./install.sh /path/to/project          — apply install.patch (default)
#   ./install.sh /path/to/project --dry    — check applicability without applying
#   ./install.sh /path/to/project --copy   — direct file copy mode
#   ./install.sh /path/to/project --revert — rollback changes (uninstall)
# ==============================================================================

set -euo pipefail

TARGET="${1:-.}"
MODE="${2:-patch}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ ! -d "$TARGET" ]; then
  echo "❌ Error: Target directory '$TARGET' does not exist."
  exit 1
fi

case "$MODE" in
  --dry)
    echo "=== PREVIEW (DIFF) ==="
    cat "$SCRIPT_DIR/diff/install.patch"
    echo
    echo "=== APPLICABILITY CHECK ==="
    cd "$TARGET"
    git apply --check "$SCRIPT_DIR/diff/install.patch"
    echo "✅ install.patch is cleanly applicable to target project."
    ;;

  --revert)
    echo "=== ROLLBACK RULES ==="
    cd "$TARGET"
    if [ -f "$SCRIPT_DIR/diff/uninstall.patch" ]; then
      git apply "$SCRIPT_DIR/diff/uninstall.patch"
    else
      git apply -R "$SCRIPT_DIR/diff/install.patch"
    fi
    echo "✅ Rules package successfully removed from $TARGET"
    ;;

  --copy)
    echo "=== DIRECT FILE COPY ==="
    mkdir -p "$TARGET/.agents/rules" "$TARGET/scripts"
    cp "$SCRIPT_DIR/rules/"*.md "$TARGET/.agents/rules/"
    cp "$SCRIPT_DIR/hooks/hooks.json" "$TARGET/.agents/hooks.json" 2>/dev/null || true
    cp "$SCRIPT_DIR/hooks/graph-router.sh" "$TARGET/scripts/" 2>/dev/null || true
    chmod +x "$TARGET/scripts/graph-router.sh" 2>/dev/null || true
    echo "✅ Rules files successfully copied to $TARGET"
    ;;

  *)
    echo "=== APPLYING PATCH ==="
    cd "$TARGET"
    git apply "$SCRIPT_DIR/diff/install.patch"
    echo "✅ install.patch successfully applied to $TARGET"
    ;;
esac
