#!/usr/bin/env bash
set -euo pipefail

echo '== doctor =='
for v in ANTHROPIC_API_KEY OPENAI_API_KEY GITHUB_TOKEN; do
  if [ -n "${!v:-}" ]; then
    echo "[ok] $v is set"
  else
    echo "[info] $v is not set"
  fi
done

echo
bash scripts/bootstrap-check.sh || true

echo
if command -v codex >/dev/null 2>&1; then
  echo "[hint] use: bash scripts/auth-codex.sh"
fi
