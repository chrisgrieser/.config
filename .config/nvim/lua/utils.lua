require("lua-utils") -- does not work with symlink, therefore hardlink
--------------------------------------------------------------------------------

opt = vim.opt -- global options
g = vim.g -- global variables
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
error = vim.log.levels.ERROR
warn = vim.log.levels.WARN

--------------------------------------------------------------------------------

---equivalent to `:setlocal option=value`
---@param option string
---@param value any
function setlocal(option, value)
	-- :setlocal does not have a direct access via the vim-module, it seems https://neovim.io/doc/user/lua.html#lua-vim-setlocal
	vim.api.nvim_set_option_value(option, value, {scope = "local"})
end

---equivalent to `:setlocal option?`
---@param option string
---@return any
function getlocalopt(option)
	return vim.api.nvim_get_option_value(option, {scope = "local"})
end

-- `:I` inspects the passed lua object
cmd [[:command! -nargs=1 I lua inspectFn(<f-args>)]]
function inspectFn(obj)
	vim.pretty_print(fn.luaeval(obj))
end

---whether nvim runs in a GUI
---@return boolean
function isGui()
	return g.neovide or g.goneovim
end

--------------------------------------------------------------------------------

commonFiletypes = {
	"lua",
	"markdown",
	"javascript",
	"typescript",
	"applescript",
	"json",
	"yaml",
	"toml",
	"zsh",
	"bash",
	"bibtex",
	"gitcommit",
	"conf",
}

specialFiletypes = {
	"help",
	"startuptime",
	"qf",
	"DressingSelect",
	"lspinfo",
	"AppleScriptRunOutput",
	"netrw",
	"packer",
	"undotree",
}
