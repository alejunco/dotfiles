# ajunco — dotfiles

Personal machine setup and configuration files. Run `install.sh` once on a fresh macOS machine and everything is wired up.

## What's included

| Tool | Config location in repo |
|---|---|
| Starship prompt | `dotfiles/starship/starship.toml` |
| fish shell | `dotfiles/fish/config.fish` |
| tmux | `dotfiles/tmux/tmux.conf` |
| sesh (tmux session manager) | `dotfiles/sesh/sesh.toml` |
| gh-dash (GitHub TUI) | `dotfiles/gh-dash/config.yml` |
| mise (version manager) | `dotfiles/mise/config.toml` |
| git | `dotfiles/git/.gitconfig` |
| gh CLI | `dotfiles/gh/config.yml` |
| AWS profiles | `dotfiles/aws/config` |
| neovim (LazyVim) | `dotfiles/nvim/` |
| Claude CLI | `dotfiles/claude/settings.json` + `statusline-command.sh` + `skills/` |
| pi agent | `dotfiles/pi/settings.json` + `agents/` + `prompts/` |
| Cursor / VSCode | `dotfiles/cursor/settings.json` + `keybindings.json` |
| Ghostty terminal | `dotfiles/ghostty/config` |

## Fresh machine setup

```bash
# 1. Clone this repo
git clone https://github.com/<your-username>/ajunco.git ~/study/ajunco
cd ~/study/ajunco

# 2. Run the installer (installs all tools + creates symlinks)
chmod +x install.sh symlink.sh
./install.sh
```

That's it. The script will:
- Install Homebrew (if missing)
- Install all tools via brew: `tmux`, `sesh`, `gh`, `zoxide`, `fzf`, `gum`, `starship`, `neovim`, `fish`
- Install `gh-dash` as a gh extension
- Install `mise` and provision `node@lts`, `python@latest`, `go@latest`, `terraform@latest`
- Install `pi` coding agent via npm
- Install the `steipete/clawdis@tmux` Claude skill (lets Claude remote-control tmux)
- Set fish as your default shell
- Symlink all configs from `dotfiles/` into the right places on disk

## Symlinks only (no reinstall)

If the tools are already installed and you just want to re-apply configs:

```bash
./symlink.sh
```

## Machine-specific config (not tracked)

Some settings are specific to one machine and should not be committed. Put them in:

```
~/.config/fish/conf.d/local.fish
```

Example — colima Docker socket:

```fish
set -gx DOCKER_HOST unix:///Users/<you>/.colima/default/docker.sock
```

## Fonts

**DankMono Nerd Font** is bundled in `fonts/` (repo root) and installed automatically by `symlink.sh` into `~/Library/Fonts`:

- `DankMono-Regular.otf`
- `DankMono-Italic.otf`
- `DankMonoNerdFont-Regular.otf` (Nerd Fonts patched, v3.1.1)

Free Nerd Fonts included in `Brewfile` as fallbacks: `font-meslo-lg-nerd-font`, `font-symbols-only-nerd-font`.

## Secrets (never committed)
- `~/.aws/credentials` — AWS access keys
- `~/.ssh/` — SSH keys
- `~/.claude-bedrock-credentials.fish` — Claude Bedrock API keys

## Keeping configs up to date

After changing a config file (they are all symlinked, so edits in `~/.config/...` automatically update the repo), just commit and push:

```bash
cd ~/study/ajunco
git add -A
git commit -m "update <tool> config"
git push
```

## Tools reference

| Tool | Docs |
|---|---|
| tmux | https://github.com/tmux/tmux/wiki |
| sesh | https://github.com/joshmedeski/sesh |
| gh-dash | https://www.gh-dash.dev |
| mise | https://mise.jdx.dev |
| pi | https://pi.dev |
