opt = vim.opt -- global option
g = vim.g -- global variable
api = vim.api
fn = vim.fn
cmd = vim.cmd
bo = vim.bo -- buffer-scoped options
b = vim.b -- buffer-scoped variables
wo = vim.wo -- window-scoped variables
augroup = vim.api.nvim_create_augroup
autocmd = vim.api.nvim_create_autocmd
telescope = require("telescope.builtin") -- requires loading extensions first
keymap = vim.keymap.set
home = fn.expand("~") ---@diagnostic disable-line: missing-parameter

-- :setlocal does not have a direct access via the vim-module, it seems https://neovim.io/doc/user/lua.html#lua-vim-setlocal
function localOpt(option, value)
	vim.api.nvim_set_option_value(option, value, {scope = "local"})
end


-- `:I` inspects the passed lua object
function inspectFn(obj)
	vim.pretty_print(fn.luaeval(obj))
end
cmd[[:command! -nargs=1 I lua inspectFn(<f-args>)]]

-- Border Style
borderStyle = "rounded"

function isGui()
	return g.neovide or g.goneovim
end
