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
home = vim.fn.expand("~")

--------------------------------------------------------------------------------

-- General Lua Utility
-- https://www.lua.org/manual/5.4/manual.html#pdf-string.gmatch

---@param str string
---@param separator string uses Lua Pattern, so requires escaping
---@return table
function split(str, separator)
	str = str .. separator
	local output = {}
	for i in str:gmatch("(.-)" .. separator) do
		table.insert(output, i)
	end
	return output
end

blubb = "bla.bli.blu"
test = split(blubb, "b")[2]
print(test)

--------------------------------------------------------------------------------

-- :setlocal does not have a direct access via the vim-module, it seems https://neovim.io/doc/user/lua.html#lua-vim-setlocal
function setlocal(option, value)
	vim.api.nvim_set_option_value(option, value, {scope = "local"})
end

function trim(str)
	return (str:gsub("^%s*(.-)%s*$", "%1"))
end

-- `:I` inspects the passed lua object
function inspectFn(obj)
	vim.pretty_print(fn.luaeval(obj))
end

cmd [[:command! -nargs=1 I lua inspectFn(<f-args>)]]

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
}

specialFiletypes = {
	"help",
	"startuptime",
	"qf",
	"lspinfo",
	"AppleScriptRunOutput",
	"netrw",
	"packer",
	"undotree",
}
