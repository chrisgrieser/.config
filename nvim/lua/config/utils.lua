g = vim.g -- global variables
api = vim.api
fn = vim.fn
cmd = vim.cmd
bo = vim.bo -- buffer-scoped options
b = vim.b -- buffer-scoped variables
wo = vim.wo -- window-scoped variables
opt = vim.opt -- global options obj
opt_local = vim.opt_local -- local options variables
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
logInfo = vim.log.levels.INFO

---runs :normal natively with bang
---@param cmdStr any
function normal(cmdStr) vim.cmd.normal { cmdStr, bang = true } end

---whether nvim runs in a GUI
---@return boolean
function IsGui() return g.neovide or g.goneovim end

---reads the full file
---@param filePath string
---@return string|nil file content or nil when not reading no successful
function ReadFile(filePath)
	local file, err = io.open(filePath, "r")
	if not file then 
		vim.notify("Could not read: " .. err, vim.log.levels.ERROR)
		return
	end
	local content = file:read("*a")
	file:close()
	return content
end

---@param str string
---@param filePath string line(s) to add
---@return boolean whether the writing was successful
function AppendToFile(str, filePath)
	local file, err = io.open(filePath, "a")
	if not file then
		vim.notify("Could not append: " .. err, vim.log.levels.ERROR)
		return false
	end
	file:write(str.. "\n")
	file:close()
	return true
end
