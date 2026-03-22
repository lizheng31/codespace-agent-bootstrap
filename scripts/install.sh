#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '\n[%s] %s\n' "bootstrap" "$1"
}

has() {
  command -v "$1" >/dev/null 2>&1
}

install_apt() {
  sudo apt-get update -y
  sudo apt-get install -y \
    curl \
    git \
    jq \
    unzip \
    ripgrep \
    fd-find \
    build-essential \
    pkg-config \
    python3-pip
}

install_claude() {
  if has claude; then
    log "claude already installed: $(claude --version 2>/dev/null || true)"
    return
  fi

  log "installing Claude Code CLI"
  npm install -g @anthropic-ai/claude-code || {
    log "Claude Code install failed; continuing"
    return
  }
}

install_codex() {
  if has codex; then
    log "codex already installed: $(codex --version 2>/dev/null || true)"
    return
  fi

  log "installing Codex CLI"
  npm install -g @openai/codex || {
    log "Codex install failed; continuing"
    return
  }
}

write_env_example() {
  cat > .env.example <<'EOF'
# Required for Claude Code
ANTHROPIC_API_KEY=

# Required for Codex CLI
OPENAI_API_KEY=

# Optional
GITHUB_TOKEN=
EOF
}

write_helper() {
  cat > scripts/bootstrap-check.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

echo "== agent bootstrap check =="
for bin in git node npm python3 pip3 gh jq rg; do
  if command -v "$bin" >/dev/null 2>&1; then
    echo "[ok] $bin -> $(command -v $bin)"
  else
    echo "[missing] $bin"
  fi
done

echo
if command -v claude >/dev/null 2>&1; then
  echo "[ok] claude -> $(claude --version 2>/dev/null || echo installed)"
else
  echo "[missing] claude"
fi

if command -v codex >/dev/null 2>&1; then
  echo "[ok] codex -> $(codex --version 2>/dev/null || echo installed)"
else
  echo "[missing] codex"
fi
EOF
  chmod +x scripts/bootstrap-check.sh
}

main() {
  log "starting install"
  install_apt
  install_claude
  install_codex
  write_env_example
  write_helper
  chmod +x scripts/install.sh
  log "done"
  bash scripts/bootstrap-check.sh || true
}

main "$@"
