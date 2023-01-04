g = vim.g -- global variables
api = vim.api
fn = vim.fn
cmd = vim.cmd
bo = vim.bo -- buffer-scoped options
b = vim.b -- buffer-scoped variables
wo = vim.wo -- window-scoped variables
opt = vim.opt -- global options obj
o = vim.o -- global options variables

augroup = vim.api.nvim_create_augroup
autocmd = vim.api.nvim_create_autocmd
getCursor = vim.api.nvim_win_get_cursor
setCursor = vim.api.nvim_win_set_cursor
keymap = vim.keymap.set
expand = vim.fn.expand

logWarn = vim.log.levels.WARN
logError = vim.log.levels.ERROR
logTrace = vim.log.levels.TRACE

---runs :normal natively with bang
---@param cmdStr any
function normal(cmdStr) vim.cmd.normal { cmdStr, bang = true } end

---whether nvim runs in a GUI
---@return boolean
function isGui() return g.neovide or g.goneovim end

---equivalent to `:setlocal option&`
---@param option string
---@return any
function getlocalopt(option) return vim.api.nvim_get_option_value(option, { scope = "local" }) end

---equivalent to `:setlocal option=value`
---@param option string
---@param value any
function setlocal(option, value)
	-- :setlocal does not have a direct access via the vim-module, it seems https://neovim.io/doc/user/lua.html#lua-vim-setlocal
	vim.api.nvim_set_option_value(option, value, { scope = "local" })
end

