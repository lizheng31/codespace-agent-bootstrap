#!/usr/bin/env bash
set -euo pipefail

if ! command -v claude >/dev/null 2>&1; then
  echo "claude not installed"
  exit 1
fi

if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  echo "ANTHROPIC_API_KEY is missing"
  exit 1
fi

exec claude --permission-mode bypassPermissions --print "${*:-Say hello and confirm Claude Code is ready in this Codespace.}"
