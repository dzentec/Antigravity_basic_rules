#!/usr/bin/env bash
# ==============================================================================
# graph-router.sh: Hook script for routing search requests to MCP Graph Knowledge
# Protojson format: camelCase {"decision": "allow"}
# ==============================================================================

set -euo pipefail

LOG_DIR="validation"
if [ ! -d "$LOG_DIR" ]; then
  mkdir -p "$LOG_DIR" 2>/dev/null || true
fi
LOG_FILE="$LOG_DIR/graph-router.log"

# Read input payload from stdin if available
INPUT_PAYLOAD=$(cat || echo "{}")
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date)

# Log event for diagnostic tracking
echo "[$TIMESTAMP] PreToolUse triggered for grep/glob. Payload length: ${#INPUT_PAYLOAD}" >> "$LOG_FILE" 2>/dev/null || true

# Return protojson response in camelCase format required by Antigravity v2.18+
cat <<EOF
{"decision": "allow"}
EOF
