# Codespace Agent Bootstrap

用 GitHub Codespaces 在几分钟内拉起 Codex CLI（auth 登录优先）+ Claude Code（可选 API key）工作环境。

## 目标

打开 Codespace 后，执行一条命令即可完成：
- 基础依赖安装
- Claude Code CLI 安装/检查
- Codex CLI 安装/检查
- 常用工具安装（git, gh, jq, ripgrep 等）
- auth-first 登录流程与环境变量模板生成

## 最快使用方式

### 方式 1：在 Codespace 里一条命令

```bash
curl -fsSL https://raw.githubusercontent.com/<YOUR_GITHUB>/<YOUR_REPO>/main/scripts/install.sh | bash
```

### 方式 2：Codespaces 自动执行

本仓库自带 `.devcontainer/devcontainer.json`，创建 Codespace 后会自动跑：

```bash
bash /workspaces/<repo>/scripts/install.sh
```

## 支持内容

- Claude Code
- Codex CLI
- GitHub CLI
- 常用 shell 工具
- `.env.example`
- `bootstrap-check.sh` 自检

## 认证建议

### Codex CLI（推荐）
优先使用网页登录 / device auth：

```bash
bash scripts/auth-codex.sh
```

### Claude Code（可选）
如果你有 `ANTHROPIC_API_KEY`，再使用 Claude 路径。

### 可选 Secrets
- `ANTHROPIC_API_KEY`
- `OPENAI_API_KEY`
- `GITHUB_TOKEN`

## 下一步

1. 把这个目录推到 GitHub
2. 替换 README 里的 `<YOUR_GITHUB>/<YOUR_REPO>`
3. 创建 Codespace
4. 执行一条 curl


## 快速验证

```bash
bash scripts/doctor.sh
bash scripts/auth-codex.sh
bash scripts/start-codex.sh
```

## 推荐仓库 Secrets

在 GitHub 仓库 / Codespaces Secrets 中设置：

- `ANTHROPIC_API_KEY`
- `OPENAI_API_KEY`
- `GITHUB_TOKEN`（可选）

## 启动后你能直接干什么

- 用 Claude Code 跑一次性任务
- 用 Codex CLI 跑一次性任务
- 在 Codespace 里直接开发/调试/提交
