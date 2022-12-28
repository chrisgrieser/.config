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
getCursor = vim.api.nvim_win_get_cursor
setCursor = vim.api.nvim_win_set_cursor
keymap = vim.keymap.set
expand = vim.fn.expand

logWarn = vim.log.levels.WARN
logError = vim.log.levels.ERROR
logTrace = vim.log.levels.TRACE

qol = require("config/quality-of-life")
telescope = require("telescope.builtin")

---equivalent to `:setlocal option=value`
---@param option string
---@param value any
function setlocal(option, value)
	-- :setlocal does not have a direct access via the vim-module, it seems https://neovim.io/doc/user/lua.html#lua-vim-setlocal
	vim.api.nvim_set_option_value(option, value, { scope = "local" })
end

---runs :normal natively with bang
---@param cmdStr any
function normal(cmdStr) vim.cmd.normal { cmdStr, bang = true } end

---equivalent to `:setlocal option&`
---@param option string
---@return any
function getlocalopt(option) return vim.api.nvim_get_option_value(option, { scope = "local" }) end

---whether nvim runs in a GUI
---@return boolean
function isGui() return g.neovide or g.goneovim end

--------------------------------------------------------------------------------
-- GENERAL LUA UTILS

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
	if not str then return "" end
	return (str:gsub("^%s*(.-)%s*$", "%1"))
end

--------------------------------------------------------------------------------

-- CONFIGS SHARED SCROSS MULTIPLE FILES
local home = os.getenv("HOME")
dotfilesFolder = home .. "/.config"
vaultFolder = home .. "/main-vault"
vimDataDir = home .. "/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/vim-data/"

signIcons = {
	Error = "",
	Warn = "▲",
	Info = "",
	Hint = "",
}
