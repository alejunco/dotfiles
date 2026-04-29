# AGENTS.md

Agent context for this repository. Read by Claude Code, Cursor, Pi, Codex, and any agent that follows the AGENTS.md convention.

## Overview

macOS dotfiles repo. Config files live in `dotfiles/` and are symlinked to their expected locations on disk via `symlink.sh`. Run `install.sh` once on a fresh machine to bootstrap everything.

## Setup

```bash
# Full bootstrap (installs tools + creates symlinks)
./install.sh

# Symlinks only (tools already installed)
./symlink.sh

# Homebrew packages only
brew bundle --file=Brewfile
```

## Symlink Map

| Repo path | Target on disk |
|---|---|
| `dotfiles/starship/starship.toml` | `~/.config/starship.toml` |
| `dotfiles/fish/config.fish` | `~/.config/fish/config.fish` |
| `dotfiles/tmux/tmux.conf` | `~/.config/tmux/tmux.conf` |
| `dotfiles/sesh/sesh.toml` | `~/.config/sesh/sesh.toml` |
| `dotfiles/gh-dash/config.yml` | `~/.config/gh-dash/config.yml` |
| `dotfiles/mise/config.toml` | `~/.config/mise/config.toml` |
| `dotfiles/git/.gitconfig` | `~/.gitconfig` |
| `dotfiles/gh/config.yml` | `~/.config/gh/config.yml` |
| `dotfiles/aws/config` | `~/.aws/config` |
| `dotfiles/nvim/` | `~/.config/nvim/` (full dir) |
| `dotfiles/claude/settings.json` | `~/.claude/settings.json` |
| `dotfiles/claude/statusline-command.sh` | `~/.claude/statusline-command.sh` |
| `dotfiles/claude/skills/` | `~/.claude/skills/` (full dir) |
| `dotfiles/claude/commands/` | `~/.claude/commands/` (full dir) |
| `dotfiles/pi/settings.json` | `~/.pi/agent/settings.json` |
| `dotfiles/pi/agents/` | `~/.pi/agent/agents/` (full dir) |
| `dotfiles/pi/prompts/` | `~/.pi/agent/prompts/` (full dir) |
| `dotfiles/cursor/settings.json` | `~/Library/Application Support/Cursor/User/settings.json` |
| `dotfiles/cursor/keybindings.json` | `~/Library/Application Support/Cursor/User/keybindings.json` |
| `dotfiles/ghostty/config` | `~/.config/ghostty/config` (XDG path, preferred) |
| `fonts/*.otf` | `~/Library/Fonts/` (copied, not symlinked — repo root, not dotfiles/) |

## Key Tool Notes

- **Shell**: fish + starship prompt + zoxide (smart cd) + mise (version manager)
- **Tmux prefix**: `Ctrl+A`. Session picker: `prefix + O` (sesh + fzf fuzzy picker)
- **Version manager**: mise manages node@lts, python@latest, go@latest, terraform@latest
- **pi**: installed via `mise use --global npm:@mariozechner/pi-coding-agent` — NOT `npm install -g`. Subagents workflow: run `/full-dev your request` to trigger the full 7-phase brainstorm → spec → plan → implement → review pipeline. Subagents live in `dotfiles/pi/agents/`.
- **Claude tmux skill**: `steipete/clawdis@tmux` installed via `npx skills add steipete/clawdis@tmux -g -y`. Lives at `~/.agents/skills/tmux`, symlinked into `~/.claude/skills/tmux`. Gives Claude the ability to send keystrokes to tmux panes, read pane output, and manage sessions.

## Secrets (never committed)

- `~/.aws/credentials` — AWS access keys
- `~/.ssh/` — SSH keys
- `~/.claude-bedrock-credentials.fish` — Claude Bedrock API keys

## Machine-specific config (not tracked)

Place machine-specific fish vars in `~/.config/fish/conf.d/local.fish` (not symlinked, not committed). Example:

```fish
set -gx DOCKER_HOST unix:///Users/you/.colima/default/docker.sock
```
