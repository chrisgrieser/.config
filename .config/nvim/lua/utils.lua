---@diagnostic disable: lowercase-global

-- shorthands
opt = vim.opt
g = vim.g
api = vim.api
fn = vim.fn
cmd = vim.cmd
augroup = vim.api.nvim_create_augroup
autocmd = vim.api.nvim_create_autocmd
telescope = require("telescope.builtin") -- requires loading extensions first
keymap = vim.keymap.set


