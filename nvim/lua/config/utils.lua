bo = vim.bo
fn = vim.fn
cmd = vim.cmd
autocmd = vim.api.nvim_create_autocmd
GetCursor = vim.api.nvim_win_get_cursor
SetCursor = vim.api.nvim_win_set_cursor
keymap = vim.keymap.set
expand = vim.fn.expand
Iabbrev = vim.cmd.inoreabbrev

LogError = vim.log.levels.ERROR
LogWarn = vim.log.levels.WARN
LogTrace = vim.log.levels.TRACE
LogInfo = vim.log.levels.INFO

--------------------------------------------------------------------------------

---runs :normal natively with bang
---@param cmdStr string
function Normal(cmdStr) vim.cmd.normal { cmdStr, bang = true } end

function LeaveVisualMode()
	local escKey = vim.api.nvim_replace_termcodes("<Esc>", false, true, true)
	vim.api.nvim_feedkeys(escKey, "nx", false)
end

--------------------------------------------------------------------------------

---reads the full file
---@param filePath string
---@nodiscard
---@return string|nil file content or nil when not reading no successful
function ReadFile(filePath)
	local file, err = io.open(filePath, "r")
	if not file then
		vim.notify_once("Could not read: " .. err, vim.log.levels.ERROR)
		return
	end
	local content = file:read("*a")
	file:close()
	return content
end

---@param str string
---@param filePath string line(s) to add
---@nodiscard
---@return boolean whether the writing was successful
function AppendToFile(str, filePath)
	local file, err = io.open(filePath, "a")
	if not file then
		vim.notify("Could not append: " .. err, vim.log.levels.ERROR)
		return false
	end
	file:write(str .. "\n")
	file:close()
	return true
end
