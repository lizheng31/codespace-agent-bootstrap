#!/usr/bin/env bash
set -euo pipefail

if ! command -v codex >/dev/null 2>&1; then
  echo "codex not installed"
  exit 1
fi

echo "== Codex auth =="
echo "If browser/device auth is supported, complete the login flow below."

auth_cmd=''
if codex --help 2>/dev/null | grep -q 'auth'; then
  auth_cmd='codex auth login'
elif command -v openai >/dev/null 2>&1 && openai --help 2>/dev/null | grep -q 'auth'; then
  auth_cmd='openai auth login'
fi

if [ -z "$auth_cmd" ]; then
  echo "No auth subcommand detected automatically. Run 'codex --help' and check login/auth commands."
  exit 1
fi

echo "Running: $auth_cmd"
exec bash -lc "$auth_cmd"
