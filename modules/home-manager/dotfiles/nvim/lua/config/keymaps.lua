-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

if vim.g.vscode then
  -- running as VSCode extension
  -- local vscode = require('vscode-neovim')
  -- vim.keymap.set({"n", "x"}, "<Space>", vscode.notify('whichkey.show'), { silent = true })
else
end