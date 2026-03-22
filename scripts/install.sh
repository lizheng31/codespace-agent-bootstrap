#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '\n[%s] %s\n' "bootstrap" "$1"
}

has() {
  command -v "$1" >/dev/null 2>&1
}

need_sudo() {
  if command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    "$@"
  fi
}

install_apt_base() {
  if ! has apt-get; then
    log "apt-get not found; cannot continue on this image"
    exit 1
  fi

  need_sudo apt-get update -y
  need_sudo apt-get install -y \
    ca-certificates \
    curl \
    git \
    jq \
    unzip \
    ripgrep \
    fd-find \
    build-essential \
    pkg-config \
    python3 \
    python3-pip \
    xz-utils
}

install_node() {
  if has node && has npm; then
    log "node already installed: $(node -v), npm: $(npm -v)"
    return
  fi

  log "installing nodejs + npm via NodeSource"
  curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
  need_sudo apt-get install -y nodejs

  if ! has node || ! has npm; then
    log "node/npm install failed"
    exit 1
  fi

  log "node installed: $(node -v), npm: $(npm -v)"
}

install_claude() {
  if has claude; then
    log "claude already installed: $(claude --version 2>/dev/null || true)"
    return
  fi

  log "installing Claude Code CLI"
  npm install -g @anthropic-ai/claude-code

  if has claude; then
    log "claude installed"
  else
    log "Claude install failed"
  fi
}

install_codex() {
  if has codex; then
    log "codex already installed: $(codex --version 2>/dev/null || true)"
    return
  fi

  log "installing Codex CLI"
  npm install -g @openai/codex

  if ! has codex; then
    log "Codex install failed"
    exit 1
  fi

  log "codex installed: $(codex --version 2>/dev/null || true)"
}

write_env_example() {
  cat > .env.example <<'EOF2'
# Optional for Claude Code
ANTHROPIC_API_KEY=

# Optional for Codex CLI if you prefer API key over auth login
OPENAI_API_KEY=

# Optional
GITHUB_TOKEN=
EOF2
}

write_helper() {
  cat > scripts/bootstrap-check.sh <<'EOF2'
#!/usr/bin/env bash
set -euo pipefail

echo "== agent bootstrap check =="
for bin in git node npm python3 pip3 gh jq rg curl; do
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
EOF2
  chmod +x scripts/bootstrap-check.sh
}

main() {
  log "starting install"
  install_apt_base
  install_node
  install_claude
  install_codex
  write_env_example
  write_helper
  chmod +x scripts/install.sh
  log "done"
  bash scripts/bootstrap-check.sh
}

main "$@"
