#!/usr/bin/env bash
set -euo pipefail

echo '== doctor =='
for v in ANTHROPIC_API_KEY OPENAI_API_KEY GITHUB_TOKEN; do
  if [ -n "${!v:-}" ]; then
    echo "[ok] $v is set"
  else
    echo "[warn] $v is missing"
  fi
done

echo
bash scripts/bootstrap-check.sh || true
