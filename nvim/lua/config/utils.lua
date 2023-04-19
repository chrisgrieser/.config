local M = {}
--------------------------------------------------------------------------------

M.vimDataDir = vim.env.DATA_DIR .. "/vim-data/" -- read from .zshenv
M.error = vim.log.levels.ERROR
M.warn = vim.log.levels.WARN
M.trace = vim.log.levels.TRACE
M.getCursor = vim.api.nvim_win_get_cursor
M.setCursor = vim.api.nvim_win_set_cursor

---runs :normal natively with bang
---@param cmdStr string
function M.normal(cmdStr) vim.cmd.normal { cmdStr, bang = true } end

function M.leaveVisualMode()
	local escKey = vim.api.nvim_replace_termcodes("<Esc>", false, true, true)
	vim.api.nvim_feedkeys(escKey, "nx", false)
end

---reads the full file
---@param filePath string
---@nodiscard
---@return string|nil file content or nil when not reading no successful
function M.readFile(filePath)
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
function M.appendToFile(filePath, str)
	local file, err = io.open(filePath, "a")
	if not file then
		vim.notify("Could not append: " .. err, vim.log.levels.ERROR)
		return false
	end
	file:write(str .. "\n")
	file:close()
	return true
end

--------------------------------------------------------------------------------

---Sets the global BorderStyle variable and the matching BorderChars Variable.
---See also https://neovim.io/doc/user/api.html#nvim_open_win()
---(BorderChars is needed for Harpoon and Telescope, both of which do not accept
---a Borderstyle string.)
local borderstyle = "rounded"

--------------------------------------------------------------------------------

M.borderStyle = borderstyle
-- default: single/rounded
M.borderChars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" } 
M.borderHorizontal = "─" 

if borderstyle == "single" then
	M.borderChars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" }
elseif borderstyle == "double" then
	M.borderChars = { "═", "║", "═", "║", "╔", "╗", "╝", "╚" }
	M.borderHorizontal = "═"
end

return M
