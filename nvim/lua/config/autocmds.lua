-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
-- 起動時にNeo-treeを自動で表示する
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimStarted", -- 全プラグインが読み込まれた後に実行
  callback = function()
    vim.cmd("Neotree show")
  end,
})
