if status is-interactive
    # Machine-specific overrides (not tracked in git): DOCKER_HOST, etc.
    # Place them in ~/.config/fish/conf.d/local.fish
    if test -f ~/.config/fish/conf.d/local.fish
        source ~/.config/fish/conf.d/local.fish
    end
end

# mise — replaces nvm for Node, Python, Go, Terraform version management
if command -q mise
    mise activate fish | source
end

# zoxide — smarter cd (replaces plain cd with frecency-based navigation)
if command -q zoxide
    zoxide init fish | source
end

# starship prompt
if command -q starship
    starship init fish | source
end

# Add ~/.local/bin to PATH (mise + other local tools)
fish_add_path ~/.local/bin

# Aliases
abbr -a q exit

# Claude Code with AWS Bedrock (credentials only apply to the claude command)
function claude
    if test -f ~/.claude-bedrock-credentials.fish
        source ~/.claude-bedrock-credentials.fish
        env CLAUDE_CODE_USE_BEDROCK=1 \
            AWS_REGION=us-east-1 \
            AWS_ACCESS_KEY_ID="$CLAUDE_AWS_ACCESS_KEY_ID" \
            AWS_SECRET_ACCESS_KEY="$CLAUDE_AWS_SECRET_ACCESS_KEY" \
            command claude $argv
    else
        echo "Missing ~/.claude-bedrock-credentials.fish — create it with CLAUDE_AWS_ACCESS_KEY_ID and CLAUDE_AWS_SECRET_ACCESS_KEY"
        return 1
    end
end

# pi coding agent with AWS Bedrock
# Uses PI_AWS_ACCESS_KEY_ID / PI_AWS_SECRET_ACCESS_KEY to avoid collision with
# any globally exported AWS_ACCESS_KEY_ID used by other tools (Terraform, etc.)
# Credentials are scoped to the pi process only, not exported globally.
function pi
    if test -f ~/.pi-bedrock-credentials.fish
        source ~/.pi-bedrock-credentials.fish
        env AWS_REGION=us-east-1 \
            AWS_ACCESS_KEY_ID="$PI_AWS_ACCESS_KEY_ID" \
            AWS_SECRET_ACCESS_KEY="$PI_AWS_SECRET_ACCESS_KEY" \
            command pi $argv
    else
        echo "Missing ~/.pi-bedrock-credentials.fish"
        echo "Create it with:"
        echo "  set -x PI_AWS_ACCESS_KEY_ID  \"AKIA...\""
        echo "  set -x PI_AWS_SECRET_ACCESS_KEY  \"...\""
        return 1
    end
end

# >>>> BEGIN MANAGED DEVIN BLOCK >>>>
# Add ~/.local/bin to PATH for devin
if not contains $HOME/.local/bin $PATH
    set -gx PATH $HOME/.local/bin $PATH
end
# <<<< END MANAGED DEVIN BLOCK <<<<
