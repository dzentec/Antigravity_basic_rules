#!/usr/bin/env bash
# ==============================================================================
# graph-router.sh: PreToolUse router for MCP Knowledge Graph & Grep gating
# Enforces graph-first code exploration with per-session marker and fail-open
# ==============================================================================

# Ensure fail-open safety: on any unexpected error, default to allow and exit 0
fallback_allow() {
  cat <<'EOF'
{"decision": "allow"}
EOF
  exit 0
}

trap fallback_allow ERR

# Read stdin
INPUT_PAYLOAD=$(cat 2>/dev/null || echo "{}")

if [ -z "$INPUT_PAYLOAD" ] || [ "$INPUT_PAYLOAD" = "{}" ]; then
  fallback_allow
fi

# Determine tmp directory cross-platform
TMP_DIR="${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"

# Parse toolName, conversationId, and Query using python or jq
PARSED_VALUES=$(python -c "
import sys, json
try:
    data = json.loads('''$INPUT_PAYLOAD''')
    tool_name = data.get('toolCall', {}).get('name', '')
    args = data.get('toolCall', {}).get('args', {})
    query = args.get('Query', '') or args.get('query', '')
    conv_id = data.get('conversationId', '') or 'default'
    print(f'{tool_name}\t{conv_id}\t{query}')
except Exception:
    sys.exit(1)
" 2>/dev/null || jq -r '[.toolCall.name // "", .conversationId // "default", .toolCall.args.Query // .toolCall.args.query // ""] | @tsv' <<< "$INPUT_PAYLOAD" 2>/dev/null || echo "")

if [ -z "$PARSED_VALUES" ]; then
  fallback_allow
fi

IFS=$'\t' read -r TOOL_NAME CONV_ID QUERY <<< "$PARSED_VALUES"

MARKER_FILE="${TMP_DIR}/antigravity_graph_${CONV_ID}.marker"

# 1. Handle Knowledge Graph tools: touch session marker and allow
case "$TOOL_NAME" in
  search_graph|trace_path|get_code_snippet|query_graph|get_architecture)
    touch "$MARKER_FILE" 2>/dev/null || true
    cat <<'EOF'
{"decision": "allow"}
EOF
    exit 0
    ;;
esac

# 2. Handle grep_search
if [ "$TOOL_NAME" = "grep_search" ]; then
  # If graph was already queried in this conversation, unlock grep
  if [ -f "$MARKER_FILE" ]; then
    cat <<'EOF'
{"decision": "allow"}
EOF
    exit 0
  fi

  # Check if Query resembles a code symbol identifier (e.g. UserService, handle_login, models.User)
  # String literals, regexes, spaces, quotes, operators, and common text markers are allowed through
  IS_SYMBOL=$(python -c "
import sys, re
q = sys.argv[1] if len(sys.argv) > 1 else ''
if not q or len(q) < 3:
    print('0')
    sys.exit(0)

# If contains spaces, quotes, slashes, hyphens, colons, stars, or comments -> text/literal search
if any(c in q for c in [' ', '\"', '\'', '/', '\\\\', '-', ':', ';', '=', '#', '(', ')', '[', ']', '{', '}', '*', '?', '+', '<', '>', '~', '^', '$', '!', '|', '&', '@', '%']):
    print('0')
    sys.exit(0)

# Check identifier or dotted identifier (e.g. OrderHandler or user.service)
if re.match(r'^[A-Za-z_][A-Za-z0-9_]*(\.[A-Za-z_][A-Za-z0-9_]*)*$', q):
    print('1')
else:
    print('0')
" "$QUERY" 2>/dev/null || echo "0")

  if [ "$IS_SYMBOL" = "1" ]; then
    # Sanitize query for JSON reason output
    SAFE_QUERY=$(echo "$QUERY" | tr -d '"\\')
    cat <<EOF
{"decision": "deny", "reason": "KNOWLEDGE GRAPH ROUTER: Symbol-level query ('$SAFE_QUERY') detected. Use MCP Knowledge Graph tools (search_graph, trace_path, get_code_snippet) first per 00-research-protocol.md. Knowledge graph discovery unlocks grep for the remainder of this session."}
EOF
    exit 0
  fi
fi

# Default fallback
fallback_allow
