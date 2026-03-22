#!/usr/bin/env bash
set -euo pipefail

bash scripts/install.sh
bash scripts/doctor.sh

echo
echo "Next:"
echo "  bash scripts/auth-codex.sh"
echo "  bash scripts/start-codex.sh"
