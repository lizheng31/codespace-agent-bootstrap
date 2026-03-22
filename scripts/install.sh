#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '\n[%s] %s\n' "bootstrap" "$1"
}

has() {
  command -v "$1" >/dev/null 2>&1
}

as_root() {
  if command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    "$@"
  fi
}

detect_pkg_manager() {
  if has apt-get; then
    echo apt
    return
  fi
  if has apk; then
    echo apk
    return
  fi
  echo unknown
}

install_base_apt() {
  as_root apt-get update -y
  as_root apt-get install -y \
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
    xz-utils \
    bash
}

install_base_apk() {
  as_root apk update
  as_root apk add \
    bash \
    curl \
    git \
    jq \
    unzip \
    ripgrep \
    fd \
    build-base \
    pkgconf \
    python3 \
    py3-pip \
    xz \
    nodejs \
    npm
}

install_base() {
  pm=$(detect_pkg_manager)
  case "$pm" in
    apt)
      log "detected apt-get"
      install_base_apt
      ;;
    apk)
      log "detected apk"
      install_base_apk
      ;;
    *)
      log "no supported package manager found (need apt-get or apk)"
      exit 1
      ;;
  esac
}

install_node_apt() {
  if has node && has npm; then
    log "node already installed: $(node -v), npm: $(npm -v)"
    return
  fi

  log "installing nodejs + npm via NodeSource"
  curl -fsSL https://deb.nodesource.com/setup_22.x | as_root bash -
  as_root apt-get install -y nodejs
}

install_node() {
  pm=$(detect_pkg_manager)

  if has node && has npm; then
    log "node already installed: $(node -v), npm: $(npm -v)"
    return
  fi

  case "$pm" in
    apt)
      install_node_apt
      ;;
    apk)
      log "node installed via apk base packages"
      ;;
    *)
      log "cannot install node on unsupported package manager"
      exit 1
      ;;
  esac

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
  if npm install -g @anthropic-ai/claude-code; then
    log "claude install command completed"
  else
    log "Claude install failed; continuing"
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
for bin in git node npm python3 pip3 jq rg curl; do
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
  install_base
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
