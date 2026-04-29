-- LazyVim's opts function (extras/editor/telescope.lua) runs after user opts
-- and overwrites pickers.find_files.find_command with rg (no --hidden).
-- The only reliable fix is to override the keymaps to inline the fd command
-- directly at call time, so no opts merging can interfere.
local fd_hidden = { "fd", "--type", "f", "--hidden", "--color", "never", "-E", ".git" }

local function find_files_hidden()
  vim.notify("find_files: fd --hidden", vim.log.levels.DEBUG)
  require("telescope.builtin").find_files({ find_command = fd_hidden })
end

return {
  "nvim-telescope/telescope.nvim",
  keys = {
    { "<leader>ff", find_files_hidden, desc = "Find Files (Root Dir)" },
    { "<leader><space>", find_files_hidden, desc = "Find Files (Root Dir)" },
    {
      "<leader>fF",
      function()
        require("telescope.builtin").find_files({
          find_command = fd_hidden,
          cwd = vim.fn.expand("%:p:h"),
        })
      end,
      desc = "Find Files (cwd)",
    },
  },
}
