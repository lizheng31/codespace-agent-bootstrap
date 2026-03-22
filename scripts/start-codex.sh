#!/usr/bin/env bash
set -euo pipefail

if ! command -v codex >/dev/null 2>&1; then
  echo "codex not installed"
  exit 1
fi

if [ ! -d .git ]; then
  git init >/dev/null 2>&1 || true
fi

exec codex exec "${*:-Say hello and confirm Codex CLI is ready in this Codespace.}"
