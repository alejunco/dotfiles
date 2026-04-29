#!/bin/bash
input=$(cat)

# Current folder
folder=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
folder=$(basename "$folder")

# Model name
model=$(echo "$input" | jq -r '.model.display_name // ""')

# Git branch (skip optional locks to avoid contention)
git_branch=$(git -C "$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "."')" --no-optional-locks branch --show-current 2>/dev/null)

# Context window usage
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Session cost (total tokens as proxy; cost not directly available)
total_in=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_out=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')

# Build output
parts=()

# Folder
parts+=("$(printf '\033[0;34m\xf0\x9f\x93\x81 %s\033[0m' "$folder")")

# Model

# actual model is global.anthropic.claude-opus-4-6-v1 we need to trim the last part only
if [ -n "$model" ]; then
  # If model starts with global.anthropic., trim that prefix
  trimmed_model=$(echo "$model" | sed 's/^global\.anthropic\.//')
  parts+=("$(printf '\033[0;36m%s\033[0m' "$trimmed_model")")
fi

# Git branch
if [ -n "$git_branch" ]; then
  parts+=("$(printf '\033[0;33m\xef\xa0\x9c %s\033[0m' "$git_branch")")
fi

# Context usage
if [ -n "$used_pct" ]; then
  used_int=${used_pct%.*}
  if [ "$used_int" -ge 80 ] 2>/dev/null; then
    color='\033[0;31m'
  elif [ "$used_int" -ge 50 ] 2>/dev/null; then
    color='\033[0;33m'
  else
    color='\033[0;32m'
  fi
  parts+=("$(printf "${color}ctx: %s%%\033[0m" "$used_pct")")
fi

# Session cost estimate (input ~$3/MTok, output ~$15/MTok for Sonnet as reference)
if [ "$total_in" -gt 0 ] || [ "$total_out" -gt 0 ]; then
  # Use awk for floating point math
  cost=$(awk -v in_tok="$total_in" -v out_tok="$total_out" \
    'BEGIN { printf "%.4f", (in_tok / 1000000 * 3.00) + (out_tok / 1000000 * 15.00) }')
  parts+=("$(printf '\033[0;35m~$%s\033[0m' "$cost")")
fi

# Join with separator
printf '%s' "${parts[0]}"
for ((i=1; i<${#parts[@]}; i++)); do
  printf ' \033[0;90m|\033[0m %s' "${parts[$i]}"
done
printf '\n'