-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- On macOS, Neovim uses /bin/sh internally and doesn't inherit the full fish
-- PATH. Prepend Homebrew so tools like fd, ripgrep, and mise shims are found.
vim.env.PATH = "/opt/homebrew/bin:/opt/homebrew/sbin:" .. vim.env.PATH

vim.opt.wrap = true
