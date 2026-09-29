#!/usr/bin/env bash
# ==============================================================================
# pack.sh — Pack rules into a single Markdown bundle and extract it
#
# Usage:
#   ./pack.sh pack              — build pack/rules-bundle.md
#   ./pack.sh unpack [target]   — extract to target directory (.agents/, scripts/)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUNDLE="$SCRIPT_DIR/pack/rules-bundle.md"

if [ -d "$SCRIPT_DIR/rules" ]; then
    RULES_DIR="$SCRIPT_DIR/rules"
elif [ -d "$SCRIPT_DIR/draft" ]; then
    RULES_DIR="$SCRIPT_DIR/draft"
else
    RULES_DIR="$SCRIPT_DIR"
fi

HOOKS_DIR="$SCRIPT_DIR/hooks"

pack() {
    mkdir -p "$SCRIPT_DIR/pack"
    : > "$BUNDLE"

    echo "# Rules Bundle" >> "$BUNDLE"
    echo "" >> "$BUNDLE"

    # 1. Rules (.agents/rules/)
    for f in "$RULES_DIR"/0*.md "$RULES_DIR"/[0-9]*.md; do
        [ -f "$f" ] || continue
        echo "## .agents/rules/$(basename "$f")" >> "$BUNDLE"
        echo '````markdown' >> "$BUNDLE"
        cat "$f" >> "$BUNDLE"
        echo "" >> "$BUNDLE"
        echo '````' >> "$BUNDLE"
        echo "" >> "$BUNDLE"
    done

    # 2. Hooks (.agents/hooks.json directly under .agents/)
    if [ -f "$HOOKS_DIR/hooks.json" ]; then
        echo "## .agents/hooks.json" >> "$BUNDLE"
        echo '````json' >> "$BUNDLE"
        cat "$HOOKS_DIR/hooks.json" >> "$BUNDLE"
        echo "" >> "$BUNDLE"
        echo '````' >> "$BUNDLE"
        echo "" >> "$BUNDLE"
    fi

    # 3. Router script (scripts/graph-router.sh)
    if [ -f "$HOOKS_DIR/graph-router.sh" ]; then
        echo "## scripts/graph-router.sh" >> "$BUNDLE"
        echo '````bash' >> "$BUNDLE"
        cat "$HOOKS_DIR/graph-router.sh" >> "$BUNDLE"
        echo "" >> "$BUNDLE"
        echo '````' >> "$BUNDLE"
        echo "" >> "$BUNDLE"
    fi

    echo "✅ Built: $BUNDLE ($(wc -c < "$BUNDLE" | tr -d ' ') bytes)"
}

unpack() {
    [ -f "$BUNDLE" ] || { echo "❌ File $BUNDLE not found. Run: $0 pack first"; exit 1; }

    TARGET="${1:-.}"
    mkdir -p "$TARGET"
    ABS_TARGET="$(cd "$TARGET" && pwd)"

    python3 - "$BUNDLE" "$ABS_TARGET" << 'EOF' || python - "$BUNDLE" "$ABS_TARGET" << 'EOF'
import sys
import os
import re

bundle_path = sys.argv[1]
target_dir = sys.argv[2]

with open(bundle_path, "r", encoding="utf-8") as f:
    text = f.read()

pattern = r'(?ms)^##\s+((?:\.agents/|scripts/)[^\r\n]+)\r?\n(?:````|```)[a-z]*\r?\n(.*?)\r?\n(?:````|```)'
file_blocks = re.findall(pattern, text)

created = 0
skipped = 0

for rel_path, file_content in file_blocks:
    rel_path = rel_path.strip()
    dest_path = os.path.join(target_dir, os.path.normpath(rel_path))
    
    if os.path.exists(dest_path):
        print(f"SKIP: {rel_path}")
        skipped += 1
    else:
        os.makedirs(os.path.dirname(dest_path), exist_ok=True)
        with open(dest_path, "w", encoding="utf-8", newline="\n") as out:
            out.write(file_content.strip() + "\n")
        if dest_path.endswith(".sh"):
            try:
                os.chmod(dest_path, 0o755)
            except Exception:
                pass
        print(f"CREATE: {rel_path}")
        created += 1

print(f"\nCreated: {created}")
print(f"Skipped: {skipped}")
EOF
}

case "${1:-}" in
    pack)   pack ;;
    unpack) unpack "${2:-.}" ;;
    *)      echo "Usage: $0 {pack|unpack [target_dir]}" ;;
esac
