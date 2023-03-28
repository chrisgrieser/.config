Bo = vim.bo 
Fn = vim.fn
Cmd = vim.cmd
Autocmd = vim.api.nvim_create_autocmd
GetCursor = vim.api.nvim_win_get_cursor
SetCursor = vim.api.nvim_win_set_cursor
Keymap = vim.keymap.set
Expand = vim.fn.expand
Iabbrev = vim.cmd.inoreabbrev

LogError = vim.log.levels.ERROR
LogWarn = vim.log.levels.WARN
LogTrace = vim.log.levels.TRACE
LogInfo = vim.log.levels.INFO

--------------------------------------------------------------------------------

---runs :normal natively with bang
---@param cmdStr string
function Normal(cmdStr) vim.cmd.normal { cmdStr, bang = true } end

---https://www.reddit.com/r/neovim/comments/oxddk9/comment/h7maerh/
---@param name string name of highlight group
---@param key "foreground"|"background"|"special"
---@nodiscard
---@return string|nil the value, or nil if hlgroup or key is not available
function GetHighlightValue(name, key)
	local ok, hl = pcall(vim.api.nvim_get_hl_by_name, name, true)
	if not ok then return end
	local value = hl[key]
	if not value then return end
	return string.format("#%06x", value)
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
	file:write(str.. "\n")
	file:close()
	return true
end
