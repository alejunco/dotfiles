#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$REPO_DIR/dotfiles"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok()   { echo -e "${GREEN}  linked${NC}  $2 → $1"; }
bak()  { echo -e "${YELLOW}  backup${NC}  $1 → $1.bak"; }

# Creates parent dirs, backs up existing non-symlink files, then symlinks.
backup_and_link() {
  local src="$1"
  local dest="$2"

  mkdir -p "$(dirname "$dest")"

  if [[ -e "$dest" && ! -L "$dest" ]]; then
    bak "$dest"
    mv "$dest" "$dest.bak"
  elif [[ -L "$dest" ]]; then
    rm "$dest"
  fi

  ln -sf "$src" "$dest"
  ok "$src" "$dest"
}

echo "Creating symlinks..."
echo ""

# Starship prompt
backup_and_link "$DOTFILES/starship/starship.toml"    "$HOME/.config/starship.toml"

# Fish
backup_and_link "$DOTFILES/fish/config.fish"          "$HOME/.config/fish/config.fish"

# Tmux
backup_and_link "$DOTFILES/tmux/tmux.conf"            "$HOME/.config/tmux/tmux.conf"

# Sesh
backup_and_link "$DOTFILES/sesh/sesh.toml"            "$HOME/.config/sesh/sesh.toml"

# gh-dash
backup_and_link "$DOTFILES/gh-dash/config.yml"        "$HOME/.config/gh-dash/config.yml"

# mise
backup_and_link "$DOTFILES/mise/config.toml"          "$HOME/.config/mise/config.toml"

# git
backup_and_link "$DOTFILES/git/.gitconfig"            "$HOME/.gitconfig"

# gh CLI
backup_and_link "$DOTFILES/gh/config.yml"             "$HOME/.config/gh/config.yml"

# AWS (config only — never credentials)
mkdir -p "$HOME/.aws"
backup_and_link "$DOTFILES/aws/config"                "$HOME/.aws/config"

# nvim (full directory symlink)
backup_and_link "$DOTFILES/nvim"                      "$HOME/.config/nvim"

# Claude
backup_and_link "$DOTFILES/claude/settings.json"           "$HOME/.claude/settings.json"
backup_and_link "$DOTFILES/claude/statusline-command.sh"   "$HOME/.claude/statusline-command.sh"
backup_and_link "$DOTFILES/claude/skills"                  "$HOME/.claude/skills"
backup_and_link "$DOTFILES/claude/commands"                "$HOME/.claude/commands"

# pi agent (link individual files/dirs, not the whole ~/.pi/agent/ dir,
# because it contains unmanaged runtime files like auth.json, sessions/)
mkdir -p "$HOME/.pi/agent"
backup_and_link "$DOTFILES/pi/settings.json"  "$HOME/.pi/agent/settings.json"
backup_and_link "$DOTFILES/pi/agents"         "$HOME/.pi/agent/agents"
backup_and_link "$DOTFILES/pi/prompts"        "$HOME/.pi/agent/prompts"
backup_and_link "$DOTFILES/pi/extensions"     "$HOME/.pi/agent/extensions"

# Cursor
# NOTE: DankMono Nerd Font is bundled in dotfiles/fonts/ and installed below.
CURSOR_USER="$HOME/Library/Application Support/Cursor/User"
backup_and_link "$DOTFILES/cursor/settings.json"    "$CURSOR_USER/settings.json"
backup_and_link "$DOTFILES/cursor/keybindings.json" "$CURSOR_USER/keybindings.json"

# Ghostty — prefer XDG path (~/.config/ghostty) over the macOS Library path.
# Both are valid; XDG is loaded first and is consistent with the rest of dotfiles.
backup_and_link "$DOTFILES/ghostty/config" "$HOME/.config/ghostty/config"

# Global fd/rg ignore overrides (makes .env files visible in Telescope etc.)
backup_and_link "$DOTFILES/ignore/.ignore" "$HOME/.ignore"

# Fonts — copy into ~/Library/Fonts (no symlink; macOS Font Book expects real files)
FONTS_DEST="$HOME/Library/Fonts"
mkdir -p "$FONTS_DEST"
for font in "$REPO_DIR/fonts/"*.{otf,ttf}; do
  [[ -e "$font" ]] || continue
  fname="$(basename "$font")"
  if [[ -f "$FONTS_DEST/$fname" ]]; then
    echo "  font already installed: $fname"
  else
    cp "$font" "$FONTS_DEST/$fname"
    echo "  installed font: $fname"
  fi
done

echo ""
echo "All symlinks created."
