-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

if vim.g.vscode then
  -- running as VSCode extension
  local wrap = function(func, ...)
    local args = {...}
    return function()
      func(unpack(args))
    end
  end

  local vscode = require('vscode-neovim')

  -- getting vscodes whichkey plugin to work
  vim.keymap.set({"n", "x"}, "<Space>", wrap(vscode.action, 'whichkey.show'), { silent = true })
else
  -- normal nvim mode
end