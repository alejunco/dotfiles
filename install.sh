#!/usr/bin/env bash
set -euo pipefail

# ─── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── 1. Homebrew ─────────────────────────────────────────────────────────────
install_homebrew() {
  if command -v brew &>/dev/null; then
    success "Homebrew already installed"
  else
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add brew to PATH for Apple Silicon
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  fi

  brew update --quiet
}

# ─── 2. Brew packages (via Brewfile) ─────────────────────────────────────────
install_brew_packages() {
  info "Installing Homebrew packages from Brewfile..."
  brew bundle --file="$REPO_DIR/Brewfile"
  success "Homebrew packages installed"
}

# ─── 3. gh-dash ──────────────────────────────────────────────────────────────
install_gh_dash() {
  if gh extension list 2>/dev/null | grep -q "dlvhdr/gh-dash"; then
    success "gh-dash already installed"
  else
    info "Installing gh-dash..."
    gh extension install dlvhdr/gh-dash
  fi
}

# ─── 4. TPM (Tmux Plugin Manager) ────────────────────────────────────────────
install_tpm() {
  local tpm_dir="$HOME/.tmux/plugins/tpm"
  if [[ -d "$tpm_dir" ]]; then
    success "tpm already installed"
  else
    info "Installing Tmux Plugin Manager (tpm)..."
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
    success "tpm installed — open tmux and press prefix+I to install plugins"
  fi
}

# ─── 4. mise ─────────────────────────────────────────────────────────────────
install_mise() {
  if command -v mise &>/dev/null || [[ -f "$HOME/.local/bin/mise" ]]; then
    success "mise already installed"
  else
    info "Installing mise..."
    curl -fsSL https://mise.run | sh
  fi

  export PATH="$HOME/.local/bin:$PATH"

  info "Installing runtimes via mise (node, python, go, terraform)..."
  mise install --quiet
  success "Runtimes ready"
}

# ─── 5. pi coding agent ──────────────────────────────────────────────────────
install_pi() {
  export PATH="$HOME/.local/bin:$PATH"

  if mise list npm:@mariozechner/pi-coding-agent 2>/dev/null | grep -q "pi-coding-agent"; then
    success "pi already installed"
  else
    info "Installing pi coding agent via mise npm backend..."
    # Use mise's npm backend so pi is stable across all directories regardless
    # of which Node version a project activates — avoids resolution mismatches.
    mise use --global npm:@mariozechner/pi-coding-agent
  fi
}

# ─── 7. Claude skills ────────────────────────────────────────────────────────
install_claude_skills() {
  info "Installing Claude skills..."

  # The skills CLI creates a relative symlink inside ~/.claude/skills/ that assumes
  # it's a real directory. Because our ~/.claude/skills is itself a symlink to
  # dotfiles/claude/skills/, the relative path breaks. The skill files are
  # committed directly to the repo instead and picked up via symlink.sh.
  #
  # This step just ensures the upstream ~/.agents/skills/tmux copy stays fresh
  # (used by other agents like Pi and Devin). It does NOT write into ~/.claude/skills.
  if [[ -d "$HOME/.agents/skills/tmux" ]]; then
    success "tmux skill (~/.agents/skills/tmux) already present"
  else
    info "Downloading tmux skill to ~/.agents/skills/tmux..."
    npx skills add steipete/clawdis@tmux -g -y
    # Remove the broken relative symlink the CLI just wrote into our dotfiles dir
    rm -f "$HOME/.claude/skills/tmux" 2>/dev/null || true
  fi
}

# ─── 8. Clean up legacy tools replaced by mise ───────────────────────────────
cleanup_legacy() {
  # jorgebucaran/nvm.fish was replaced by mise for Node version management.
  # If the nvm.fish fisher plugin is still installed, remove it so it doesn't
  # conflict with mise's PATH manipulation and nvm universal vars.
  if fish -c "functions --query nvm" 2>/dev/null; then
    warn "Removing legacy nvm.fish plugin (replaced by mise)..."
    fish -c "fisher remove jorgebucaran/nvm.fish" 2>/dev/null || true
    fish -c "set --erase --universal nvm_default_version" 2>/dev/null || true
  else
    success "nvm.fish already removed"
  fi
}

# ─── 9. Set fish as default shell ────────────────────────────────────────────
set_default_shell() {
  local fish_path
  fish_path="$(command -v fish 2>/dev/null || echo "")"

  if [[ -z "$fish_path" ]]; then
    warn "fish not found in PATH, skipping default shell setup"
    return
  fi

  if [[ "$SHELL" == "$fish_path" ]]; then
    success "fish is already the default shell"
    return
  fi

  if ! grep -qF "$fish_path" /etc/shells; then
    info "Adding fish to /etc/shells..."
    echo "$fish_path" | sudo tee -a /etc/shells
  fi

  info "Setting fish as default shell..."
  chsh -s "$fish_path"
}

# ─── 7. Symlinks ─────────────────────────────────────────────────────────────
run_symlinks() {
  info "Creating dotfile symlinks..."
  bash "$REPO_DIR/symlink.sh"
}

# ─── Main ─────────────────────────────────────────────────────────────────────
main() {
  info "Starting machine setup from: $REPO_DIR"
  echo ""

  install_homebrew
  echo ""

  install_brew_packages
  echo ""

  install_gh_dash
  echo ""

  install_tpm
  echo ""

  install_mise
  echo ""

  install_pi
  echo ""

  install_claude_skills
  echo ""

  cleanup_legacy
  echo ""

  set_default_shell
  echo ""

  run_symlinks
  echo ""

  success "Setup complete! Restart your terminal or run: exec fish"
  echo ""
  echo "Manual steps remaining:"
  echo "  1. Open tmux and press prefix + I (capital i) to install tmux plugins (resurrect, continuum)"
  echo "  2. Open Neovim — lazy.nvim will auto-install plugins on first launch"
  echo "  3. Run 'gh auth login' if not already authenticated"
  echo "  4. Create ~/.config/fish/conf.d/local.fish for machine-specific vars (e.g. DOCKER_HOST)"
  echo "  5. Create ~/.claude-bedrock-credentials.fish with your Bedrock keys"
}

main "$@"
