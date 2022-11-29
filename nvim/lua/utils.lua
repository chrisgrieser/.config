-- NVIM UTILS
opt = vim.opt -- global options obj
g = vim.g -- global variables
api = vim.api
fn = vim.fn
cmd = vim.cmd
bo = vim.bo -- buffer-scoped options
b = vim.b -- buffer-scoped variables
wo = vim.wo -- window-scoped variables

augroup = vim.api.nvim_create_augroup
autocmd = vim.api.nvim_create_autocmd
keymap = vim.keymap.set
unmap = vim.keymap.del
logWarn = vim.log.levels.WARN
logError = vim.log.levels.ERROR
logTrace = vim.log.levels.TRACE

qol = require("quality-of-life")
telescope = require("telescope.builtin")

---equivalent to `:setlocal option=value`
---@param option string
---@param value any
function setlocal(option, value)
	-- :setlocal does not have a direct access via the vim-module, it seems https://neovim.io/doc/user/lua.html#lua-vim-setlocal
	vim.api.nvim_set_option_value(option, value, {scope = "local"})
end

---equivalent to `:setlocal option&`
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

-- GENERAL LUA UTILS
---home directory
home = os.getenv("HOME")

---returns current date in ISO 8601 format
---@return string|osdate
function isodate()
	return os.date("!%Y-%m-%d")
end

---appends t2 to t1 in-place
---@param t1 table
---@param t2 table
function concatTables(t1, t2)
	for _, v in ipairs(t2) do
		table.insert(t1, v)
	end
end

---@param str string
---@param separator string uses Lua Pattern, so requires escaping
---@return table
function split(str, separator)
	str = str .. separator
	local output = {}
	-- https://www.lua.org/manual/5.4/manual.html#pdf-string.gmatch
	for i in str:gmatch("(.-)" .. separator) do
		table.insert(output, i)
	end
	return output
end

---trims whitespace from string
---@param str string
---@return string
function trim(str)
	if not (str) then return "" end
	return (str:gsub("^%s*(.-)%s*$", "%1"))
end

--------------------------------------------------------------------------------

-- CONFIGS SHARED SCROSS MULTIPLE FILES
dotfilesFolder = home .. "/.config"
signIcons = {
	Error = "",
	Warn = "▲",
	Info = "",
	Hint = "",
}

commonFiletypes = {
	"lua",
	"markdown",
	"javascript",
	"typescript",
	"applescript",
	"json",
	"python",
	"yaml",
	"toml",
	"zsh",
	"bash",
	"sh",
	"bibtex",
	"gitcommit",
	"conf",
}

-- filetypes to be ignored by most plugins
specialFiletypes = {
	"help",
	"startuptime",
	"DiffviewFileHistory",
	"qf",
	"man",
	"DressingSelect",
	"DressingInput",
	"lspinfo",
	"AppleScriptRunOutput",
	"netrw",
	"packer",
	"undotree",
	"Mundo",
	"MundoDiff",
	"prompt",
	"TelescopePrompt",
	"noice",
	"mason",
	"ssr",
	"cybu",
	"",

	"dap-repl",
	"dui_console",
	"dui_scopes",
	"dui_breakpoints",
	"dui_stacks",
	"dui_watches",
}
